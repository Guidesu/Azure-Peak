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
		to_chat(usr, span_boldwarning("Checkpoint request failed - the host did not accept it."))
		return

	log_admin("[key_name(usr)] forced a manual DreamValley checkpoint (generation [generation]).")
	message_admins("[key_name_admin(usr)] forced a manual campaign save (checkpoint [generation]).")
	to_chat(usr, span_notice("Checkpoint [generation] queued. It will be confirmed durable once the host acknowledges it."))
