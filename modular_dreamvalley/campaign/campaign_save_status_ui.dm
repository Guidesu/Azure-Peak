/**
 * Save-status + control UI for the DreamValley campaign system.
 *
 * Two audiences, one backend datum:
 * - Admins get the full picture: world save health, dirty/pending state, dungeon
 *   generator and economy subsystem health, every parked character record, and
 *   mutation actions (force checkpoint, force-unpark/cancel-resume, delete a
 *   single parked record).
 * - Players get a read-only narrow slice: just their own parked character(s)
 *   and the same world save-health line (so they can tell "is the server
 *   actually saving" without seeing anyone else's info or any controls).
 */
/datum/dreamvalley_campaign_manager/var/datum/dreamvalley_save_status_ui/save_status_ui

/datum/dreamvalley_save_status_ui
	var/datum/dreamvalley_campaign_manager/manager

/datum/dreamvalley_save_status_ui/New(datum/dreamvalley_campaign_manager/owner_manager)
	manager = owner_manager

/datum/dreamvalley_save_status_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/dreamvalley_save_status_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CampaignSaveStatus", "Campaign Save Status")
		ui.open()

/datum/dreamvalley_save_status_ui/proc/is_admin_viewer(mob/user)
	return user?.client && check_rights_for(user.client, R_ADMIN|R_DEBUG)

/datum/dreamvalley_save_status_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!is_admin_viewer(usr))
		return TRUE
	if(!manager)
		return TRUE

	switch(action)
		if("force_checkpoint")
			var/parked_count = manager.auto_park_connected_characters()
			var/generation = manager.request_durable_checkpoint()
			if(isnum(generation))
				to_chat(usr, span_notice("Forced a checkpoint - now at generation [generation]. Parked [parked_count] connected character(s); capture failures: [manager.last_auto_park_failures]."))
				log_admin("[key_name(usr)] forced a DreamValley campaign checkpoint (generation [generation], [parked_count] connected characters parked, [manager.last_auto_park_failures] failures).")
			else
				to_chat(usr, span_warning("Checkpoint write failed - see server log."))
			return TRUE

		if("delete_parked_record")
			var/record_key = params["record_key"]
			if(!record_key || !islist(manager.parked_characters) || !manager.parked_characters[record_key])
				to_chat(usr, span_warning("That parked record no longer exists."))
				return TRUE
			var/list/record = manager.parked_characters[record_key]
			var/list/identity = record["core"]?["identity"]
			var/display_name = identity?["real_name"] || identity?["name"] || record_key
			if(alert(usr, "Permanently delete the parked record for [display_name]? This cannot be undone.", "Delete Parked Record", "Delete", "Cancel") != "Delete")
				return TRUE
			manager.parked_characters -= record_key
			manager.request_durable_checkpoint()
			to_chat(usr, span_boldannounce("Deleted parked record for [display_name]."))
			log_admin("[key_name(usr)] deleted DreamValley parked record '[record_key]' ([display_name]).")
			message_admins("[key_name_admin(usr)] deleted DreamValley parked record '[record_key]' ([display_name]).")
			return TRUE

		if("cancel_pending_parking")
			var/record_key = params["record_key"]
			var/list/transaction = manager.pending_character_parking[record_key]
			if(!record_key || !islist(transaction))
				to_chat(usr, span_warning("That pending parking transaction no longer exists."))
				return TRUE
			var/mob/living/carbon/human/body = transaction["body"]
			var/mob/dead/new_player/lobby = transaction["lobby"]
			var/obj/structure/far_travel/source = transaction["source"]
			manager.pending_character_parking -= record_key
			var/list/existing = manager.parked_characters[record_key]
			if(islist(existing) && existing["state"] == "parking")
				manager.parked_characters -= record_key
			if(lobby && !QDELETED(lobby) && lobby.client)
				to_chat(lobby, span_boldwarning("An admin cancelled your pending campaign save. Your body has been returned."))
			if(body && !QDELETED(body) && lobby?.key)
				body.key = lobby.key
			if(source && !QDELETED(source))
				source.in_use = FALSE
			to_chat(usr, span_boldannounce("Cancelled pending parking transaction for '[record_key]' and returned control to the body."))
			log_admin("[key_name(usr)] cancelled a stuck DreamValley parking transaction ('[record_key]').")
			message_admins("[key_name_admin(usr)] cancelled a stuck DreamValley parking transaction ('[record_key]').")
			return TRUE

		if("cancel_pending_resume")
			var/record_key = params["record_key"]
			if(!record_key || !islist(manager.pending_character_resumes[record_key]))
				to_chat(usr, span_warning("That pending resume transaction no longer exists."))
				return TRUE
			manager.cancel_character_resume(record_key, "An admin cancelled your pending Continue. Your saved character is still parked safely.")
			to_chat(usr, span_boldannounce("Cancelled pending resume transaction for '[record_key]'."))
			log_admin("[key_name(usr)] cancelled a stuck DreamValley resume transaction ('[record_key]').")
			message_admins("[key_name_admin(usr)] cancelled a stuck DreamValley resume transaction ('[record_key]').")
			return TRUE

		if("switch_campaign")
			var/target_id = params["campaign_id"]
			if(!target_id || target_id == manager.campaign_id)
				return TRUE
			if(alert(usr, "Switch to campaign '[target_id]'? All connected players will be disconnected and the server will restart.", "Switch Campaign", "Switch", "Cancel") != "Switch")
				return TRUE
			log_admin("[key_name(usr)] switched DreamValley campaign from '[manager.campaign_id]' to '[target_id]' via UI.")
			message_admins("[key_name_admin(usr)] switched DreamValley campaign from '[manager.campaign_id]' to '[target_id]'.")
			manager.switch_campaign(target_id)
			world.Reboot("Campaign switched by [usr.client.key]")
			return TRUE

		if("create_campaign")
			var/new_id = input(usr, "Enter a campaign ID (alphanumeric, underscore, hyphen only):", "Create Campaign") as text|null
			if(!new_id || !length(new_id))
				return TRUE
			var/result = manager.create_campaign(new_id)
			if(!result)
				to_chat(usr, span_warning("Failed to create campaign '[new_id]'. It may already exist or the ID is invalid."))
				return TRUE
			to_chat(usr, span_notice("Created campaign '[result]'."))
			log_admin("[key_name(usr)] created DreamValley campaign '[result]' via UI.")
			return TRUE

		if("delete_campaign")
			var/target_id = params["campaign_id"]
			if(!target_id || target_id == manager.campaign_id)
				return TRUE
			if(alert(usr, "Permanently delete campaign '[target_id]'? This cannot be undone.", "Delete Campaign", "Delete", "Cancel") != "Delete")
				return TRUE
			manager.delete_campaign(target_id)
			to_chat(usr, span_boldannounce("Deleted campaign '[target_id]'."))
			log_admin("[key_name(usr)] deleted DreamValley campaign '[target_id]' via UI.")
			return TRUE

/datum/dreamvalley_save_status_ui/ui_data(mob/user)
	var/list/data = list()
	var/is_admin = is_admin_viewer(user)
	data["is_admin"] = is_admin
	data["enabled"] = manager?.enabled || FALSE
	data["campaign_id"] = manager?.campaign_id || "default"
	data["available_campaigns"] = build_available_campaigns()

	data["world_save"] = list(
		"checkpoint_generation" = manager?.checkpoint_generation || 0,
		"last_checkpoint_at" = manager?.last_checkpoint_at,
		"last_checkpoint_ago_text" = format_ago_text(manager?.last_checkpoint_at),
		"save_file_bytes" = manager?.get_save_file_size() || 0,
	)

	if(is_admin)
		data["parked_characters"] = build_all_parked_rows()
		data["pending_state"] = build_pending_state()
		data["subsystem_health"] = build_subsystem_health()
	else
		data["parked_characters"] = build_own_parked_rows(user)

	return data

/// Dirty/in-flight state that hasn't hit a durable checkpoint yet - separate from
/// the "last completed checkpoint" line above, which only shows what's already saved.
/datum/dreamvalley_save_status_ui/proc/build_pending_state()
	return list(
		"dirty_turf_count" = islist(manager?.dirty_turfs) ? length(manager.dirty_turfs) : 0,
		"pending_parking_count" = islist(manager?.pending_character_parking) ? length(manager.pending_character_parking) : 0,
		"pending_resume_count" = islist(manager?.pending_character_resumes) ? length(manager.pending_character_resumes) : 0,
	)

/// Other subsystems whose health is relevant to "is the campaign in a good state" -
/// surfaced here instead of admins needing to hunt through separate debug verbs.
/datum/dreamvalley_save_status_ui/proc/build_subsystem_health()
	var/list/dungeon = list(
		"setup_done" = FALSE,
		"generation_complete" = FALSE,
		"markers_remaining" = 0,
		"failed_markers_remaining" = 0,
		"rooms_placed" = 0,
	)

	var/list/economy = list(
		"last_processed_day" = SSeconomy?.last_processed_day || 0,
		"roundstart_events_fired" = SSeconomy?.roundstart_events_fired || FALSE,
	)

	return list(
		"dungeon" = dungeon,
		"economy" = economy,
	)

/// Build a list of available campaigns for the UI.
/datum/dreamvalley_save_status_ui/proc/build_available_campaigns()
	var/list/result = list()
	if(!manager)
		return result
	var/list/campaigns = manager.list_campaigns()
	for(var/cid in campaigns)
		var/list/info = campaigns[cid]
		result += list(list(
			"id" = cid,
			"name" = info["name"],
			"generation" = info["generation"],
			"saved_at" = info["saved_at"],
			"is_active" = (cid == manager.campaign_id),
		))
	return result

/datum/dreamvalley_save_status_ui/proc/format_ago_text(at_time)
	if(!isnum(at_time) || at_time <= 0)
		return "never this session"
	var/elapsed_seconds = max(0, round((world.realtime - at_time) / 10))
	if(elapsed_seconds < 60)
		return "[elapsed_seconds]s ago"
	if(elapsed_seconds < 3600)
		return "[round(elapsed_seconds / 60)]m ago"
	return "[round(elapsed_seconds / 3600)]h ago"

/datum/dreamvalley_save_status_ui/proc/build_parked_row(record_key, list/record)
	var/list/core = record["core"]
	var/list/identity = core?["identity"]
	return list(
		"record_key" = record_key,
		"owner_ckey" = record["owner_ckey"],
		"real_name" = identity?["real_name"] || identity?["name"] || "Unknown",
		"state" = record["state"],
		"complete" = record["complete"] == TRUE,
	)

/datum/dreamvalley_save_status_ui/proc/build_all_parked_rows()
	var/list/rows = list()
	if(!islist(manager?.parked_characters))
		return rows
	for(var/record_key in manager.parked_characters)
		var/list/record = manager.parked_characters[record_key]
		if(islist(record))
			rows += list(build_parked_row(record_key, record))
	return rows

/datum/dreamvalley_save_status_ui/proc/build_own_parked_rows(mob/user)
	var/list/rows = list()
	if(!user?.client || !islist(manager?.parked_characters))
		return rows
	var/own_ckey = ckey(user.client.key)
	for(var/record_key in manager.parked_characters)
		var/list/record = manager.parked_characters[record_key]
		if(!islist(record))
			continue
		if(ckey(record["owner_ckey"]) != own_ckey)
			continue
		rows += list(build_parked_row(record_key, record))
	return rows

/client/proc/cmd_admin_campaign_save_status()
	set category = "Debug"
	set name = "Campaign Save Status"
	set desc = "View the DreamValley campaign world save status and every parked character."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return
	if(!GLOB.dreamvalley_campaign.save_status_ui)
		GLOB.dreamvalley_campaign.save_status_ui = new(GLOB.dreamvalley_campaign)
	GLOB.dreamvalley_campaign.save_status_ui.ui_interact(usr)

/mob/verb/cmd_my_campaign_save_status()
	set category = "OOC"
	set name = "My Campaign Save Status"
	set desc = "View your own parked character(s) and whether the campaign is saving."

	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return
	if(!GLOB.dreamvalley_campaign.save_status_ui)
		GLOB.dreamvalley_campaign.save_status_ui = new(GLOB.dreamvalley_campaign)
	GLOB.dreamvalley_campaign.save_status_ui.ui_interact(src)

/client/proc/cmd_admin_reset_campaign_save()
	set category = "Debug"
	set name = "Reset Campaign Save"
	set desc = "Wipe the DreamValley campaign save file and all parked characters. Cannot be undone."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return

	var/datum/dreamvalley_campaign_manager/manager = GLOB.dreamvalley_campaign
	var/parked_count = islist(manager.parked_characters) ? length(manager.parked_characters) : 0
	var/confirm_text = "Generation [manager.checkpoint_generation], [parked_count] parked character(s) on file. This deletes the save and cannot be undone. Type the campaign ID ([manager.campaign_id]) to confirm."
	var/typed = input(usr, confirm_text, "Reset Campaign Save") as text|null
	if(isnull(typed) || typed != manager.campaign_id)
		to_chat(usr, span_warning("Campaign save reset cancelled."))
		return

	GLOB.dreamvalley_campaign.reset_campaign_save()
	to_chat(usr, span_boldannounce("DreamValley campaign save has been reset. Generation is now 0, all parked characters cleared."))
	log_admin("[key_name(usr)] reset the DreamValley campaign save.")
	message_admins("[key_name_admin(usr)] reset the DreamValley campaign save.")
