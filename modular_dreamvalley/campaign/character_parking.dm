/**
 * Campaign Far Travel boundary.
 *
 * Azure's original Far Travel path deletes the body, forgets known people,
 * removes bounties and bank records, and forfeits some balances. A campaign
 * character must never enter that path - this reroutes it into an exact
 * character-graph capture that parks the body until its checkpoint is
 * written to disk (see campaign_transport.dm), then frees the slot instead
 * of deleting anything.
 */
/// Surfaces a validation failure with the actual blocker list, both to the
/// player (so it's clear what's wrong, not just that something is) and to
/// the admin log (so this is traceable after the fact instead of vanishing
/// the moment the chat message scrolls past).
/datum/dreamvalley_campaign_manager/proc/report_parking_validation_failure(mob/user, mob/living/carbon/human/departing_mob, stage, list/issues)
	var/list/preview = list()
	if(islist(issues))
		for(var/index in 1 to min(5, length(issues)))
			preview += "[issues[index]]"
	var/more_count = islist(issues) ? length(issues) - length(preview) : 0
	var/more_text = more_count > 0 ? " (+[more_count] more)" : ""
	var/detail = length(preview) ? preview.Join(", ") : "no blockers reported (record itself failed to build)"
	to_chat(user, span_boldwarning("Exact character [stage] did not validate: [detail][more_text]. Departure was cancelled without removing the body."))
	log_admin("DREAMVALLEY PARKING FAILED ([stage]): [key_name(departing_mob)] - [islist(issues) ? issues.Join(", ") : "no issues list"]")
	message_admins("DreamValley campaign save failed for [key_name_admin(departing_mob)] at [stage] stage - see log for full issue list.")

/datum/dreamvalley_campaign_manager/proc/handle_far_travel(mob/living/carbon/human/departing_mob, mob/user, obj/structure/far_travel/source)
	if(!enabled)
		return DREAMVALLEY_TRAVEL_UNHANDLED

	if(!departing_mob || !user || !source)
		return DREAMVALLEY_TRAVEL_HANDLED

	if(!character_parking_ready)
		var/list/audit = audit_character_for_parking(departing_mob)
		var/list/issues = audit["issues"]
		var/list/missing_sections = audit["missing_sections"]
		if(length(issues))
			var/list/preview = list()
			for(var/index in 1 to min(5, length(issues)))
				preview += "[issues[index]]"
			var/more_count = length(issues) - length(preview)
			var/more_text = more_count > 0 ? " (+[more_count] more)" : ""
			to_chat(user, span_boldwarning("Campaign travel audit found [length(issues)] exact-save blocker(s): [preview.Join(", ")][more_text]. Departure was cancelled safely."))
		else
			to_chat(user, span_boldwarning("The character graph captured cleanly, but its destructive round-trip and host transaction are not enabled yet. Departure was cancelled safely."))
		if(length(missing_sections))
			to_chat(user, span_notice("Remaining persistence stages: [missing_sections.Join(", ")]."))
		return DREAMVALLEY_TRAVEL_HANDLED

	if(departing_mob != user || !departing_mob.client)
		to_chat(user, span_boldwarning("Campaign parking can only be started by the player controlling that character."))
		return DREAMVALLEY_TRAVEL_HANDLED

	var/record_key = character_record_key(departing_mob.client)
	if(!record_key)
		to_chat(user, span_boldwarning("No Character Sheet slot is associated with this body. Departure was cancelled."))
		return DREAMVALLEY_TRAVEL_HANDLED
	if(pending_character_parking[record_key])
		to_chat(user, span_notice("This character is already waiting for its durable campaign checkpoint."))
		return DREAMVALLEY_TRAVEL_HANDLED

	if(alert(user, "Save this exact character and return to the Character Sheet? The body will only leave the world once the save writes to disk.", "Far Travel", "Save and leave", "Cancel") != "Save and leave")
		return DREAMVALLEY_TRAVEL_HANDLED
	if(QDELETED(departing_mob) || !departing_mob.client || get_dist(source, departing_mob) > 2)
		return DREAMVALLEY_TRAVEL_HANDLED

	source.in_use = TRUE
	user.visible_message(
		span_notice("[user] prepares for far travel."),
		span_notice("I prepare my character for a durable campaign save."),
	)
	if(!do_after(user, 50, target = source))
		source.in_use = FALSE
		return DREAMVALLEY_TRAVEL_HANDLED

	var/list/record = capture_character_draft(departing_mob)
	var/list/issues = record?["validation_issues"]
	if(!islist(record) || length(issues))
		source.in_use = FALSE
		report_parking_validation_failure(user, departing_mob, "capture", issues)
		return DREAMVALLEY_TRAVEL_HANDLED

	issues = validate_character_round_trip(departing_mob, record["core"])
	if(length(issues))
		source.in_use = FALSE
		report_parking_validation_failure(user, departing_mob, "round-trip", issues)
		return DREAMVALLEY_TRAVEL_HANDLED

	// Capture once more after the successful test so the staged record exactly
	// matches the body that will remain in-world while acknowledgement is pending.
	record = capture_character_draft(departing_mob)
	issues = record?["validation_issues"]
	if(!islist(record) || length(issues))
		source.in_use = FALSE
		report_parking_validation_failure(user, departing_mob, "post-restore capture", issues)
		return DREAMVALLEY_TRAVEL_HANDLED

	record["state"] = "parking"
	record["complete"] = TRUE
	record["missing_sections"] = list()
	record["validation_issues"] = list()
	var/list/previous_record = parked_characters[record_key]
	parked_characters[record_key] = record

	// Move the client to the normal lobby immediately so the exact staged body
	// cannot change while its checkpoint is in flight. The body is retained
	// until acknowledgement, and can therefore be recovered if writing fails.
	var/character_key = departing_mob.key
	var/mob/dead/new_player/lobby = new /mob/dead/new_player()
	lobby.key = character_key
	if(departing_mob.client || !lobby.client)
		if(previous_record)
			parked_characters[record_key] = previous_record
		else
			parked_characters -= record_key
		if(lobby.client)
			departing_mob.key = lobby.key
		qdel(lobby)
		source.in_use = FALSE
		to_chat(departing_mob, span_boldwarning("The Character Sheet transfer failed. Departure was cancelled."))
		return DREAMVALLEY_TRAVEL_HANDLED

	var/generation = request_durable_checkpoint()
	if(!isnum(generation))
		departing_mob.key = lobby.key
		qdel(lobby)
		if(previous_record)
			parked_characters[record_key] = previous_record
		else
			parked_characters -= record_key
		source.in_use = FALSE
		to_chat(departing_mob, span_boldwarning("The host did not accept the checkpoint request. Departure was cancelled and control was returned to the body."))
		return DREAMVALLEY_TRAVEL_HANDLED

	pending_character_parking[record_key] = list(
		"record_key" = record_key,
		"generation" = generation,
		"body" = departing_mob,
		"lobby" = lobby,
		"source" = source,
	)
	to_chat(lobby, span_notice("Saving [record["core"]?["identity"]?["real_name"]] to the campaign. The body will remain protected until checkpoint [generation] writes to disk."))
	return DREAMVALLEY_TRAVEL_HANDLED

/datum/dreamvalley_campaign_manager/proc/poll_character_parking_transactions()
	if(!length(pending_character_parking))
		return 0
	var/completed = 0
	for(var/record_key in pending_character_parking.Copy())
		var/list/transaction = pending_character_parking[record_key]
		if(!islist(transaction))
			pending_character_parking -= record_key
			continue
		var/generation = transaction["generation"]
		if(!checkpoint_is_durable(generation))
			continue

		var/list/record = parked_characters[record_key]
		if(!islist(record) || record["complete"] != TRUE)
			continue
		record["state"] = "parked"

		var/mob/living/carbon/human/body = transaction["body"]
		var/mob/dead/new_player/lobby = transaction["lobby"]
		var/obj/structure/far_travel/source = transaction["source"]
		if(lobby && !QDELETED(lobby))
			to_chat(lobby, span_nicegreen("Character saved. I can edit my Character Sheet or choose another character."))
			lobby.new_player_panel()
		if(body && !QDELETED(body))
			log_game("[key_name(body)] parked through DreamValley at checkpoint generation [generation].")
			var/datum/mind/parked_mind = body.mind
			qdel(body)
			if(parked_mind && !QDELETED(parked_mind))
				qdel(parked_mind)
		if(source && !QDELETED(source))
			source.in_use = FALSE

		pending_character_parking -= record_key
		completed++
		// Persist the user-facing "parked" state. Recovery also promotes the
		// already-durable "parking" state, so failure here cannot lose access.
		request_durable_checkpoint()
	return completed

/**
 * Silently captures every connected human character's exact record before a
 * server shutdown, so their body (identity, stats, and - critically - their
 * held/worn items) is actually part of the campaign save instead of only
 * ever being captured when a player manually walks through Far Travel's
 * interactive "Save and leave" flow.
 *
 * Without this, ordinary characters were never added to parked_characters at
 * all: emit_checkpoint()'s snapshot only knows about two things - the world
 * object graph (every individually-registered /obj, captured at its OWN
 * turf) and this parked_characters dict. A connected player's mob is never
 * part of the object graph (see dreamvalley_should_persist() in
 * persistence/contracts.dm - only /obj subtypes opt in, never /mob), so on
 * restart their held items reappeared as loose objects sitting directly on
 * whatever tile the mob was last standing on, with the character itself not
 * restored at all (can_continue_character() requires state == "parked",
 * which only Far Travel ever set).
 *
 * This deliberately skips handle_far_travel()'s whole interactive ceremony
 * (the confirmation alert(), do_after() channel, and the immediate
 * lobby-transfer/qdel of the body) - none of that makes sense mid-shutdown
 * with no time for a player to respond, and the body doesn't need to leave
 * the world early since the process is ending anyway. It only needs its
 * data captured and marked "parked" before emit_checkpoint() writes the
 * snapshot to disk right after this runs (see campaign_transport.dm's
 * Shutdown()).
 */
/datum/dreamvalley_campaign_manager/proc/auto_park_connected_characters()
	if(!enabled)
		return 0
	var/parked_count = 0
	for(var/mob/living/carbon/human/H as anything in GLOB.human_list)
		if(!H.client)
			continue
		var/record_key = character_record_key(H.client)
		if(!record_key)
			continue
		// A character already durably parked (via a completed Far Travel)
		// has no live body left to capture - nothing to do here.
		var/list/existing = parked_characters[record_key]
		if(islist(existing) && existing["state"] == "parked")
			continue

		var/list/record = capture_character_draft(H)
		var/list/issues = record?["validation_issues"]
		if(!islist(record) || length(issues))
			log_world("DreamValley auto-park at shutdown failed validation for [key_name(H)]: [islist(issues) ? issues.Join(", ") : "capture returned null"]")
			continue

		record["state"] = "parked"
		record["complete"] = TRUE
		record["missing_sections"] = list()
		record["validation_issues"] = list()
		parked_characters[record_key] = record
		parked_count++
	return parked_count

/proc/dreamvalley_handle_far_travel(mob/living/carbon/human/departing_mob, mob/user, obj/structure/far_travel/source)
	if(!GLOB.dreamvalley_campaign)
		return DREAMVALLEY_TRAVEL_UNHANDLED
	return GLOB.dreamvalley_campaign.handle_far_travel(departing_mob, user, source)
