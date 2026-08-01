/**
 * Manual "Save Game" trigger for the DreamValley campaign checkpoint system.
 * Normally emit_checkpoint() only fires on a timer (dreamvalley subsystem,
 * every checkpoint_every_fires ticks or shortly after a turf goes dirty) or on
 * world Shutdown(). This lets an admin force an out-of-band checkpoint of the
 * map/object/character snapshot on demand, same payload as the automatic one.
 */
/client/proc/cmd_admin_dreamvalley_save_now()
	set category = "Admin"
	set name = "Save Campaign Now"
	set desc = "Force an immediate DreamValley campaign checkpoint (map, objects, characters)."

	if(!check_rights(R_ADMIN))
		return

	if(!GLOB.dreamvalley_campaign?.enabled)
		to_chat(usr, span_boldwarning("The DreamValley campaign system is not enabled on this server."))
		return

	var/parked_count = GLOB.dreamvalley_campaign.auto_park_connected_characters()
	var/generation = GLOB.dreamvalley_campaign.request_durable_checkpoint()
	if(!isnum(generation))
		to_chat(usr, span_boldwarning("Checkpoint failed to write to disk - check the server log."))
		return

	var/failure_text = GLOB.dreamvalley_campaign.last_auto_park_failures ? " [GLOB.dreamvalley_campaign.last_auto_park_failures] character(s) failed capture; see server log." : ""
	log_admin("[key_name(usr)] forced a manual DreamValley checkpoint (generation [generation], [parked_count] connected characters parked, [GLOB.dreamvalley_campaign.last_auto_park_failures] failures).")
	message_admins("[key_name_admin(usr)] forced a manual campaign save (checkpoint [generation], [parked_count] connected characters parked, [GLOB.dreamvalley_campaign.last_auto_park_failures] failures).")
	to_chat(usr, span_notice("Checkpoint [generation] saved to data/dreamvalley/save.json. Parked [parked_count] connected character(s).[failure_text]"))

/**
 * Read-only visibility into the campaign save state - what's saved, where,
 * and how many characters/turfs are currently tracked. Answers "is it
 * working" and "where is it" without needing to open the variables panel.
 */
/client/proc/cmd_admin_dreamvalley_status()
	set category = "Admin"
	set name = "Campaign Save Status"
	set desc = "Show the current DreamValley campaign save state - last checkpoint, file location, and counts."

	if(!check_rights(R_ADMIN))
		return

	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_boldwarning("The DreamValley campaign system is not loaded."))
		return

	var/list/status = GLOB.dreamvalley_campaign.status()
	var/enabled_text = status["enabled"] ? "yes" : "no"
	var/list/lines = list(
		"<b>DreamValley Campaign Status</b>",
		"Enabled: [enabled_text]",
		"Save file: data/dreamvalley/save.json",
		"Last checkpoint generation: [status["checkpoint_generation"]]",
		"Parked characters (saved, awaiting Continue): [status["parked_characters"]]",
		"Characters currently parking (mid-save): [status["parking_characters"]]",
		"Characters currently resuming (mid-load): [status["resuming_characters"]]",
		"Dirty turfs pending next checkpoint: [status["dirty_turfs"]]",
		"Persisted turfs tracked total: [status["persisted_turfs"]]",
		"Persistent objects tracked: [status["persistent_objects"]]",
	)
	to_chat(usr, span_notice(lines.Join("<br>")))

/client/proc/cmd_admin_dreamvalley_save_and_shutdown()
	set category = "Server"
	set name = "Save Campaign and Shutdown"
	set desc = "Park all connected characters, save the campaign, and shut down the world."

	if(!check_rights(R_SERVER))
		return

	var/datum/dreamvalley_campaign_manager/manager = GLOB.dreamvalley_campaign
	if(!manager?.enabled)
		to_chat(usr, span_boldwarning("The DreamValley campaign system is not enabled on this server."))
		return
	if(manager.save_and_shutdown_in_progress)
		to_chat(usr, span_warning("A save-and-shutdown operation is already in progress."))
		return
	if(alert(usr, "Park every connected character, write the campaign checkpoint, and shut down the world?", "Save Campaign and Shutdown", "Save and shutdown", "Cancel") != "Save and shutdown")
		return

	manager.save_and_shutdown_in_progress = TRUE
	var/parked_count = manager.auto_park_connected_characters()
	if(manager.last_auto_park_failures)
		manager.save_and_shutdown_in_progress = FALSE
		to_chat(usr, span_boldwarning("Shutdown cancelled: [manager.last_auto_park_failures] connected character(s) could not be captured. Check the server log, resolve the character save errors, and try again."))
		return
	var/generation = manager.request_durable_checkpoint()
	if(!isnum(generation))
		manager.save_and_shutdown_in_progress = FALSE
		to_chat(usr, span_boldwarning("Campaign checkpoint failed. The server will remain running; check the server log."))
		return

	to_chat(world, span_boldannounce("Campaign checkpoint [generation] saved. Parked [parked_count] connected character(s). The server is shutting down."))
	log_admin("[key_name(usr)] saved campaign checkpoint [generation], parked [parked_count] connected character(s), and shut down the world.")
	message_admins("[key_name_admin(usr)] initiated a campaign save-and-shutdown at checkpoint [generation] ([parked_count] connected characters parked).")
	sleep(1 SECONDS)
	Master.Shutdown()
	world.Del()
