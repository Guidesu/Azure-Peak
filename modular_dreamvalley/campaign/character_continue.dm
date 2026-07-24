/**
 * Slot-aware Continue flow.
 *
 * Continue never calls late-join job setup, AssignRole, EquipRank, or an
 * advclass outfit. It reconstructs only the exact parked graph belonging to
 * the Character Sheet slot currently loaded by the client.
 */

/proc/dreamvalley_character_continue_link(mob/user)
	if(!user?.client || !GLOB.dreamvalley_campaign?.can_continue_character(user.client))
		return ""
	var/list/record = GLOB.dreamvalley_campaign.get_parked_character(user.client)
	var/list/core = record?["core"]
	var/list/identity = core?["identity"]
	var/character_name = html_encode(identity?["real_name"] || "saved character")
	return "<a style='white-space:nowrap;' href='?_src_=prefs;preference=dreamvalley_continue'><b>CONTINUE [character_name]</b></a>"

/proc/dreamvalley_handle_continue_link(mob/user, list/href_list)
	if(href_list?["preference"] != "dreamvalley_continue")
		return FALSE
	if(!GLOB.dreamvalley_campaign)
		return TRUE
	GLOB.dreamvalley_campaign.begin_character_resume(user)
	return TRUE

/datum/dreamvalley_campaign_manager/proc/validate_parked_character_record(list/record)
	var/list/issues = list()
	if(!islist(record) || record["state"] != "parked" || record["complete"] != TRUE)
		issues += "parked_record_unavailable"
		return issues
	var/mob_path = text2path(record["mob_type"])
	if(!ispath(mob_path, /mob/living/carbon/human))
		issues += "parked_mob_type_invalid"
	var/list/position = record["position"]
	if(!islist(position) || !locate(position["x"], position["y"], position["z"]))
		issues += "parked_position_invalid"
	var/list/core = record["core"]
	issues |= validate_character_core(core)
	if(length(issues) || !ispath(mob_path, /mob/living/carbon/human))
		return issues

	var/mob/living/carbon/human/probe = new mob_path(null)
	if(!probe || QDELETED(probe))
		issues += "continue_probe_create_failed"
		return issues
	issues |= validate_character_round_trip(probe, core)
	qdel(probe)
	return issues

/datum/dreamvalley_campaign_manager/proc/begin_character_resume(mob/user)
	if(!istype(user, /mob/dead/new_player) || !user.client)
		to_chat(user, span_boldwarning("Continue is only available from the Character Sheet."))
		return FALSE
	var/record_key = character_record_key(user.client)
	if(!record_key || pending_character_resumes[record_key])
		to_chat(user, span_notice("This character is already being resumed."))
		return FALSE
	var/list/record = get_parked_character(user.client)
	if(!islist(record) || !can_continue_character(user.client))
		to_chat(user, span_boldwarning("The selected Character Sheet slot has no complete parked character."))
		user.client.prefs?.ShowChoices(user, 4)
		return FALSE

	var/list/identity = record["core"]?["identity"]
	var/character_name = identity?["real_name"] || "this character"
	if(alert(user, "Continue exactly where [character_name] stopped? Character Sheet edits are not applied to Continue.", "Continue", "Continue", "Cancel") != "Continue")
		return FALSE

	var/list/issues = validate_parked_character_record(record)
	if(length(issues))
		to_chat(user, span_boldwarning("The parked character did not pass its restore audit: [issues.Join(", ")]. Continue was cancelled."))
		return FALSE

	record["state"] = "resuming"
	var/generation = request_durable_checkpoint()
	if(!isnum(generation))
		record["state"] = "parked"
		to_chat(user, span_boldwarning("The host did not accept the resume checkpoint. Continue was cancelled."))
		return FALSE

	pending_character_resumes[record_key] = list(
		"record_key" = record_key,
		"generation" = generation,
		"lobby" = user,
	)
	to_chat(user, span_notice("Preparing [character_name] from durable checkpoint [generation]."))
	return TRUE

/datum/dreamvalley_campaign_manager/proc/cancel_character_resume(record_key, message)
	var/list/record = parked_characters[record_key]
	if(islist(record) && record["complete"] == TRUE)
		record["state"] = "parked"
	var/list/transaction = pending_character_resumes[record_key]
	var/mob/dead/new_player/lobby = transaction?["lobby"]
	if(lobby && !QDELETED(lobby) && message)
		to_chat(lobby, span_boldwarning(message))
		lobby.new_player_panel()
	pending_character_resumes -= record_key
	request_durable_checkpoint()

/datum/dreamvalley_campaign_manager/proc/poll_character_resume_transactions()
	if(!length(pending_character_resumes))
		return 0
	var/completed = 0
	for(var/record_key in pending_character_resumes.Copy())
		var/list/transaction = pending_character_resumes[record_key]
		if(!islist(transaction))
			pending_character_resumes -= record_key
			continue
		if(!checkpoint_is_durable(transaction["generation"]))
			continue

		var/list/record = parked_characters[record_key]
		var/mob/dead/new_player/lobby = transaction["lobby"]
		if(!islist(record) || record["state"] != "resuming" || record["complete"] != TRUE)
			cancel_character_resume(record_key, "The saved character record changed while Continue was waiting.")
			continue
		if(!lobby || QDELETED(lobby) || !lobby.client)
			cancel_character_resume(record_key, null)
			continue

		var/list/position = record["position"]
		var/turf/resume_turf = locate(position["x"], position["y"], position["z"])
		var/mob_path = text2path(record["mob_type"])
		if(!resume_turf || !ispath(mob_path, /mob/living/carbon/human))
			cancel_character_resume(record_key, "The saved world position or body type is no longer valid.")
			continue

		var/mob/living/carbon/human/restored_body = new mob_path(resume_turf)
		var/datum/mind/restored_mind = new /datum/mind()
		restored_body.mind = restored_mind
		restored_mind.current = restored_body
		restored_mind.active = FALSE
		if(!restore_character_core(restored_body, record["core"]))
			qdel(restored_body)
			qdel(restored_mind)
			cancel_character_resume(record_key, "The exact body could not be reconstructed. The parked record was retained.")
			continue

		var/list/restored_core = capture_character_core(restored_body)
		var/list/issues = validate_character_core(restored_core)
		for(var/section in list(
			"identity", "vitals", "stats", "skills", "mind", "bodyparts",
			"organs", "traits", "status_effects", "reagents", "items",
		))
			if(!character_section_round_trip_matches(section, record["core"][section], restored_core[section]))
				issues += "continue_mismatch:[section]"
		if(length(issues))
			qdel(restored_body)
			qdel(restored_mind)
			cancel_character_resume(record_key, "The reconstructed body failed validation: [issues.Join(", ")]. The parked record was retained.")
			continue

		restored_body.dir = position["dir"]
		SSticker.minds |= restored_mind
		var/datum/mind/lobby_mind = lobby.mind
		var/character_key = lobby.key
		lobby.spawning = TRUE
		restored_body.key = character_key
		if(!restored_body.client)
			lobby.spawning = FALSE
			qdel(restored_body)
			qdel(restored_mind)
			cancel_character_resume(record_key, "Client transfer failed. The parked record was retained.")
			continue

		parked_characters -= record_key
		pending_character_resumes -= record_key
		qdel(lobby)
		if(lobby_mind && lobby_mind != restored_mind && !QDELETED(lobby_mind))
			qdel(lobby_mind)
		to_chat(restored_body, span_nicegreen("Continued [restored_body.real_name] from the exact parked campaign state."))
		log_game("[key_name(restored_body)] continued a DreamValley character from slot record [record_key].")
		request_durable_checkpoint()
		completed++
	return completed
