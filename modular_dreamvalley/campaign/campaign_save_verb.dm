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

	var/generation = GLOB.dreamvalley_campaign.request_durable_checkpoint()
	if(!isnum(generation))
		to_chat(usr, span_boldwarning("Checkpoint failed to write to disk - check the server log."))
		return

	log_admin("[key_name(usr)] forced a manual DreamValley checkpoint (generation [generation]).")
	message_admins("[key_name_admin(usr)] forced a manual campaign save (checkpoint [generation]).")
	to_chat(usr, span_notice("Checkpoint [generation] saved to data/dreamvalley/save.json."))

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
