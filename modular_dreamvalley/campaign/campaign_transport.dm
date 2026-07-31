/**
 * Local save/load for the DreamValley campaign checkpoint system.
 *
 * DM owns the whole loop with no external process involved: write a single
 * save file straight to disk on checkpoint, read it straight back on boot.
 * A local disk write is as durable as this server gets, so checkpoints are
 * considered durable the moment the write succeeds.
 */
#define DREAMVALLEY_SAVE_ROOT "data/dreamvalley"
#define DREAMVALLEY_SAVE_FILE "[DREAMVALLEY_SAVE_ROOT]/save.json"

SUBSYSTEM_DEF(dreamvalley)
	name = "DreamValley Campaign"
	init_order = INIT_ORDER_PERSISTENCE - 1
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	var/checkpoint_every_fires = 180
	var/dirty_checkpoint_delay_fires = 5
	var/fires_since_checkpoint = 0

/datum/controller/subsystem/dreamvalley/Initialize()
	GLOB.dreamvalley_campaign.load_save_file()
	return ..()

/datum/controller/subsystem/dreamvalley/fire(resumed = FALSE)
	if(!GLOB.dreamvalley_campaign.enabled)
		return

	GLOB.dreamvalley_campaign.poll_character_parking_transactions()
	GLOB.dreamvalley_campaign.poll_character_resume_transactions()
	fires_since_checkpoint++
	var/dirty_checkpoint_due = length(GLOB.dreamvalley_campaign.dirty_turfs) && fires_since_checkpoint >= dirty_checkpoint_delay_fires
	if(dirty_checkpoint_due || fires_since_checkpoint >= checkpoint_every_fires)
		GLOB.dreamvalley_campaign.emit_checkpoint()
		fires_since_checkpoint = 0

/datum/controller/subsystem/dreamvalley/Shutdown()
	if(GLOB.dreamvalley_campaign.enabled)
		GLOB.dreamvalley_campaign.auto_park_connected_characters()
		GLOB.dreamvalley_campaign.emit_checkpoint()

/datum/dreamvalley_campaign_manager/proc/load_save_file()
	var/raw = rustg_file_read(DREAMVALLEY_SAVE_FILE)
	if(!istext(raw) || !length(raw))
		return FALSE

	var/list/save_data
	try
		save_data = json_decode(raw)
	catch
		return FALSE
	if(!islist(save_data) || save_data["schema_version"] != 1)
		return FALSE

	var/saved_campaign_id = save_data["campaign_id"]
	if(istext(saved_campaign_id) && length(saved_campaign_id))
		configure(saved_campaign_id)

	var/saved_generation = save_data["checkpoint_generation"]
	if(isnum(saved_generation))
		checkpoint_generation = max(0, saved_generation)

	var/list/snapshot = save_data["snapshot"]
	if(islist(snapshot))
		load_snapshot(snapshot)

	return TRUE

/datum/dreamvalley_campaign_manager/proc/emit_checkpoint()
	if(!enabled)
		return FALSE

	drain_turf_deltas()
	checkpoint_generation++
	var/list/save_data = list(
		"schema_version" = 1,
		"campaign_id" = campaign_id,
		"checkpoint_generation" = checkpoint_generation,
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"),
		"snapshot" = capture_snapshot(),
	)
	var/encoded = json_encode(save_data)
	if(!fexists(DREAMVALLEY_SAVE_ROOT))
		rustg_file_write("", "[DREAMVALLEY_SAVE_ROOT]/.keep")
	var/result = rustg_file_write(encoded, DREAMVALLEY_SAVE_FILE)
	var/written = isnull(result) || result == "" || result == "true"
	if(!written)
		log_world("DreamValley checkpoint [checkpoint_generation] failed to write: [result]")
	else
		last_checkpoint_at = world.realtime
	return written

/datum/dreamvalley_campaign_manager/proc/request_durable_checkpoint()
	if(!emit_checkpoint())
		return null
	return checkpoint_generation

/// A local disk write is as durable as this server gets - no remote host to
/// wait on, so any checkpoint generation that has actually been written
/// (i.e. we've reached or passed it) counts as durable immediately.
/datum/dreamvalley_campaign_manager/proc/checkpoint_is_durable(generation)
	return isnum(generation) && generation > 0 && checkpoint_generation >= generation

/// Size in bytes (character length of the raw JSON) of the on-disk save
/// file, or 0 if it doesn't exist yet - used by the save-status UI
/// (campaign_save_status_ui.dm). DREAMVALLEY_SAVE_FILE is only in scope in
/// this file (undef'd below), so this getter is the only way another file
/// can read the path/size without duplicating the macro. Reads via the same
/// rustg_file_read() this manager already uses in load_save_file() - a
/// read-only text read, nothing destructive.
/datum/dreamvalley_campaign_manager/proc/get_save_file_size()
	var/raw = rustg_file_read(DREAMVALLEY_SAVE_FILE)
	if(!istext(raw))
		return 0
	return length(raw)

/// Wipes the on-disk save and every in-memory record it would have been
/// written from: parked characters, captured turf deltas, and the
/// checkpoint counter. Does NOT touch currently-loaded turfs/objects in the
/// running world - a reset means "forget the save," not "rewrite the live
/// map out from under connected players." The next checkpoint after this
/// starts a brand new generation-1 save from whatever state the world is
/// actually in from that point forward.
/datum/dreamvalley_campaign_manager/proc/reset_campaign_save()
	parked_characters = list()
	pending_character_parking = list()
	pending_character_resumes = list()
	dirty_turfs = list()
	persisted_turfs = list()
	next_persistence_id = 1
	checkpoint_generation = 0
	last_checkpoint_at = null

	if(fexists(DREAMVALLEY_SAVE_FILE))
		fdel(DREAMVALLEY_SAVE_FILE)

	return TRUE

#undef DREAMVALLEY_SAVE_ROOT
#undef DREAMVALLEY_SAVE_FILE
