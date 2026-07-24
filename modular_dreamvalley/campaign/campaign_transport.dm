/**
 * File-spool transport between the OpenDream process and the Stardew host.
 *
 * The host creates the directories and bootstrap before launching OpenDream.
 * DM writes each message to a unique file only after JSON encoding completes;
 * the host validates and atomically commits it, then places an acknowledgement
 * in the inbox. This avoids opening another network listener.
 */
#define DREAMVALLEY_BRIDGE_ROOT "data/dreamvalley/bridge"
#define DREAMVALLEY_BRIDGE_BOOTSTRAP "[DREAMVALLEY_BRIDGE_ROOT]/bootstrap.json"
#define DREAMVALLEY_BRIDGE_OUTBOX "[DREAMVALLEY_BRIDGE_ROOT]/outbox"
#define DREAMVALLEY_BRIDGE_INBOX "[DREAMVALLEY_BRIDGE_ROOT]/inbox"

SUBSYSTEM_DEF(dreamvalley)
	name = "DreamValley Campaign"
	init_order = INIT_ORDER_PERSISTENCE - 1
	// Acknowledgements drive parking/Continue UI, so poll quickly. Periodic
	// checkpoint frequency remains one minute through checkpoint_every_fires.
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	var/checkpoint_every_fires = 60
	var/dirty_checkpoint_delay_fires = 5
	var/fires_since_checkpoint = 0

/datum/controller/subsystem/dreamvalley/Initialize()
	GLOB.dreamvalley_campaign.load_bridge_bootstrap()
	return ..()

/datum/controller/subsystem/dreamvalley/fire(resumed = FALSE)
	if(!GLOB.dreamvalley_campaign.enabled)
		return

	GLOB.dreamvalley_campaign.poll_acknowledgements()
	GLOB.dreamvalley_campaign.poll_character_parking_transactions()
	GLOB.dreamvalley_campaign.poll_character_resume_transactions()
	fires_since_checkpoint++
	var/dirty_checkpoint_due = length(GLOB.dreamvalley_campaign.dirty_turfs) && fires_since_checkpoint >= dirty_checkpoint_delay_fires
	if(dirty_checkpoint_due || fires_since_checkpoint >= checkpoint_every_fires)
		GLOB.dreamvalley_campaign.emit_checkpoint()
		fires_since_checkpoint = 0

/datum/controller/subsystem/dreamvalley/Shutdown()
	if(GLOB.dreamvalley_campaign.enabled)
		GLOB.dreamvalley_campaign.emit_checkpoint()

/datum/dreamvalley_campaign_manager/proc/load_bridge_bootstrap()
	var/raw = rustg_file_read(DREAMVALLEY_BRIDGE_BOOTSTRAP)
	if(!istext(raw) || !length(raw))
		return FALSE

	var/list/bootstrap
	try
		bootstrap = json_decode(raw)
	catch
		return FALSE
	if(!islist(bootstrap) || bootstrap["schema_version"] != 1)
		return FALSE

	var/bootstrap_campaign_id = bootstrap["campaign_id"]
	if(istext(bootstrap_campaign_id) && length(bootstrap_campaign_id))
		configure(bootstrap_campaign_id)

	var/active_generation = bootstrap["active_checkpoint_generation"]
	var/checkpoint_sequence = bootstrap["checkpoint_journal_sequence"]
	if(isnum(active_generation))
		checkpoint_generation = max(0, active_generation)
		last_acknowledged_generation = checkpoint_generation
	if(isnum(checkpoint_sequence))
		journal_sequence = max(0, checkpoint_sequence)

	var/list/snapshot = bootstrap["snapshot"]
	if(islist(snapshot))
		load_snapshot(snapshot)

	var/list/journal = bootstrap["journal"]
	if(islist(journal))
		for(var/list/entry as anything in journal)
			if(!islist(entry))
				continue
			var/sequence = entry["sequence"]
			if(isnum(sequence))
				journal_sequence = max(journal_sequence, sequence)
			if(entry["kind"] == "turf.changed")
				var/list/turf_state = entry["payload"]
				if(islist(turf_state))
					apply_turf_journal_state(turf_state)

	return TRUE

/datum/dreamvalley_campaign_manager/proc/apply_turf_journal_state(list/turf_state)
	var/x = turf_state["x"]
	var/y = turf_state["y"]
	var/z = turf_state["z"]
	var/type_text = turf_state["type"]
	if(!isnum(x) || !isnum(y) || !isnum(z) || !istext(type_text))
		return FALSE

	restoring_snapshot = TRUE
	var/turf/current = locate(x, y, z)
	var/turf_path = text2path(type_text)
	if(current && ispath(turf_path, /turf) && current.type != turf_path)
		current = current.ChangeTurf(turf_path, flags = CHANGETURF_INHERIT_AIR)
	restoring_snapshot = FALSE
	if(!current)
		return FALSE

	var/key = "[x],[y],[z]"
	persisted_turfs[key] = turf_state.Copy()
	return TRUE

/datum/dreamvalley_campaign_manager/proc/emit_checkpoint()
	if(!enabled)
		return FALSE

	drain_turf_deltas()
	checkpoint_generation++
	var/message_id = "checkpoint-[checkpoint_generation]-[world.realtime]"
	var/list/envelope = list(
		"schema_version" = 1,
		"campaign_id" = campaign_id,
		"message_id" = message_id,
		"kind" = "checkpoint",
		"generation" = checkpoint_generation,
		"journal_sequence" = journal_sequence,
		"payload" = capture_snapshot(),
	)
	var/encoded = json_encode(envelope)
	var/path = "[DREAMVALLEY_BRIDGE_OUTBOX]/[message_id].json"
	var/result = rustg_file_write(encoded, path)
	var/written = isnull(result) || result == "" || result == "true"
	if(written)
		pending_checkpoint_generations[message_id] = checkpoint_generation
	return written

/datum/dreamvalley_campaign_manager/proc/request_durable_checkpoint()
	if(!emit_checkpoint())
		return null
	return checkpoint_generation

/datum/dreamvalley_campaign_manager/proc/checkpoint_is_durable(generation)
	return isnum(generation) && generation > 0 && last_acknowledged_generation >= generation

/datum/dreamvalley_campaign_manager/proc/poll_acknowledgements()
	var/list/files = flist(DREAMVALLEY_BRIDGE_INBOX)
	if(!islist(files) || !length(files))
		return 0

	var/accepted_count = 0
	for(var/file_name as anything in files)
		if(!istext(file_name) || copytext(file_name, -1) == "/")
			continue
		var/path = "[DREAMVALLEY_BRIDGE_INBOX]/[file_name]"
		var/raw = rustg_file_read(path)
		if(!istext(raw) || !length(raw))
			continue

		var/list/acknowledgement
		try
			acknowledgement = json_decode(raw)
		catch
			continue
		if(!islist(acknowledgement) || acknowledgement["schema_version"] != 1)
			continue
		if(acknowledgement["campaign_id"] != campaign_id || !acknowledgement["accepted"])
			continue

		var/generation = acknowledgement["generation"]
		var/message_id = acknowledgement["message_id"]
		if(isnum(generation))
			last_acknowledged_generation = max(last_acknowledged_generation, generation)
		if(istext(message_id))
			pending_checkpoint_generations -= message_id
		fdel(path)
		accepted_count++

	return accepted_count

#undef DREAMVALLEY_BRIDGE_ROOT
#undef DREAMVALLEY_BRIDGE_BOOTSTRAP
#undef DREAMVALLEY_BRIDGE_OUTBOX
#undef DREAMVALLEY_BRIDGE_INBOX
