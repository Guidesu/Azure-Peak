/**
 * Local save/load for the DreamValley campaign checkpoint system.
 *
 * DM owns the whole loop with no external process involved: write a single
 * save file straight to disk on checkpoint, read it straight back on boot.
 * A local disk write is as durable as this server gets, so checkpoints are
 * considered durable the moment the write succeeds.
 *
 * Multiple campaigns are supported: each campaign has its own directory
 * under DREAMVALLEY_CAMPAIGNS_ROOT, with its own save.json. The active
 * campaign is selected by campaign_id and can be switched via admin verbs.
 */
#define DREAMVALLEY_SAVE_ROOT "data/dreamvalley"
#define DREAMVALLEY_CAMPAIGNS_ROOT "[DREAMVALLEY_SAVE_ROOT]/campaigns"
#define DREAMVALLEY_LEGACY_SAVE_FILE "[DREAMVALLEY_SAVE_ROOT]/save.json"

/// Per-campaign save file path. Each campaign gets its own directory so
/// multiple worlds can coexist on the same server.
/datum/dreamvalley_campaign_manager/proc/save_file_path()
	return "[DREAMVALLEY_CAMPAIGNS_ROOT]/[campaign_id]/save.json"

/// Per-campaign directory path.
/datum/dreamvalley_campaign_manager/proc/campaign_dir_path()
	return "[DREAMVALLEY_CAMPAIGNS_ROOT]/[campaign_id]"

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
	// Try the per-campaign save file first.
	var/save_path = save_file_path()
	var/raw = rustg_file_read(save_path)

	// If no per-campaign save exists, check for a legacy save at the old
	// single-file location and migrate it into the campaign directory.
	if((!istext(raw) || !length(raw)) && campaign_id == "default")
		var/legacy_raw = rustg_file_read(DREAMVALLEY_LEGACY_SAVE_FILE)
		if(istext(legacy_raw) && length(legacy_raw))
			raw = legacy_raw
			log_world("DreamValley: migrating legacy save file to campaign directory.")

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
	var/campaign_dir = campaign_dir_path()
	if(!fexists(campaign_dir))
		rustg_file_write("", "[campaign_dir]/.keep")
	var/result = rustg_file_write(encoded, save_file_path())
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
/// file, or 0 if it doesn't exist yet - used by the save-status UI.
/datum/dreamvalley_campaign_manager/proc/get_save_file_size()
	var/raw = rustg_file_read(save_file_path())
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

	var/path = save_file_path()
	if(fexists(path))
		fdel(path)

	return TRUE

/// List all campaign save directories on disk. Returns an associative list
/// of campaign_id -> list("name" = display_name, "generation" = gen, "saved_at" = text).
/datum/dreamvalley_campaign_manager/proc/list_campaigns()
	var/list/result = list()
	var/list/entries = rustg_file_read(DREAMVALLEY_CAMPAIGNS_ROOT)
	// rustg_file_read on a directory returns a newline-separated list of
	// file/directory names. If the directory doesn't exist, returns empty.
	if(!istext(entries) || !length(entries))
		// Also check for legacy save
		if(fexists(DREAMVALLEY_LEGACY_SAVE_FILE))
			result["default"] = list("name" = "Default (Legacy)", "generation" = 0, "saved_at" = "unknown")
		return result
	var/list/dir_names = splittext(entries, "\n")
	for(var/dir_name in dir_names)
		dir_name = trim(dir_name)
		if(!length(dir_name) || dir_name == ".keep")
			continue
		var/save_path = "[DREAMVALLEY_CAMPAIGNS_ROOT]/[dir_name]/save.json"
		var/raw = rustg_file_read(save_path)
		if(!istext(raw) || !length(raw))
			continue
		var/list/save_data
		try
			save_data = json_decode(raw)
		catch
			continue
		if(!islist(save_data))
			continue
		var/campaign_name = save_data["campaign_id"] || dir_name
		var/gen = save_data["checkpoint_generation"] || 0
		var/saved_at = save_data["saved_at"] || "unknown"
		result[dir_name] = list("name" = campaign_name, "generation" = gen, "saved_at" = saved_at)
	return result

/// Switch to a different campaign. Saves the current campaign first, then
/// loads the new one. Returns TRUE on success.
/datum/dreamvalley_campaign_manager/proc/switch_campaign(new_campaign_id)
	if(!istext(new_campaign_id) || !length(new_campaign_id))
		return FALSE
	if(new_campaign_id == campaign_id)
		return TRUE

	// Save the current campaign state.
	if(enabled)
		auto_park_connected_characters()
		emit_checkpoint()

	// Clear in-memory state for the old campaign.
	parked_characters = list()
	pending_character_parking = list()
	pending_character_resumes = list()
	dirty_turfs = list()
	persisted_turfs = list()
	next_persistence_id = 1
	checkpoint_generation = 0
	last_checkpoint_at = null

	// Switch and load.
	configure(new_campaign_id)
	return load_save_file()

/// Create a new campaign with the given ID. Returns FALSE if the campaign
/// already exists or the ID is invalid.
/datum/dreamvalley_campaign_manager/proc/create_campaign(new_campaign_id)
	if(!istext(new_campaign_id) || !length(new_campaign_id))
		return FALSE
	// Sanitize: only allow alphanumeric, underscore, hyphen.
	var/safe_id = ""
	for(var/i = 1 to length(new_campaign_id))
		var/ch = copytext(new_campaign_id, i, i + 1)
		if((ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z") || (ch >= "0" && ch <= "9") || ch == "_" || ch == "-")
			safe_id += ch
		else
			safe_id += "_"
	if(!length(safe_id))
		return FALSE
	var/campaigns = list_campaigns()
	if(campaigns[safe_id])
		return FALSE
	// Create the directory.
	var/campaign_dir = "[DREAMVALLEY_CAMPAIGNS_ROOT]/[safe_id]"
	rustg_file_write("", "[campaign_dir]/.keep")
	return safe_id

/// Delete a campaign save. Returns TRUE on success. Cannot delete the
/// currently active campaign.
/datum/dreamvalley_campaign_manager/proc/delete_campaign(campaign_id_to_delete)
	if(!istext(campaign_id_to_delete) || !length(campaign_id_to_delete))
		return FALSE
	if(campaign_id_to_delete == campaign_id)
		return FALSE
	var/campaign_dir = "[DREAMVALLEY_CAMPAIGNS_ROOT]/[campaign_id_to_delete]"
	if(!fexists(campaign_dir))
		return FALSE
	return fdel(campaign_dir)

/// Get the active campaign ID for display.
/datum/dreamvalley_campaign_manager/proc/get_active_campaign_id()
	return campaign_id

/// Admin verb to switch campaigns.
/client/proc/cmd_admin_switch_campaign()
	set category = "Debug"
	set name = "Switch Campaign"
	set desc = "Switch to a different DreamValley campaign save (different world)."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return

	var/list/campaigns = GLOB.dreamvalley_campaign.list_campaigns()
	if(!length(campaigns))
		to_chat(usr, span_warning("No campaign saves found."))
		return
	var/list/display = list()
	for(var/cid in campaigns)
		var/list/info = campaigns[cid]
		display["[info["name"]] (gen [info["generation"]], [info["saved_at"]])"] = cid
	var/choice = input(usr, "Switch to which campaign? The current campaign will be saved first. This will disconnect all players.", "Switch Campaign") as null|anything in sortList(display)
	if(!choice || !display[choice])
		return
	var/target_id = display[choice]
	if(alert(usr, "Switch to campaign '[target_id]'? All connected players will be disconnected and the server will need to restart to load the new world state.", "Switch Campaign", "Switch", "Cancel") != "Switch")
		return
	log_admin("[key_name(usr)] switched DreamValley campaign from '[GLOB.dreamvalley_campaign.campaign_id]' to '[target_id]'.")
	message_admins("[key_name_admin(usr)] switched DreamValley campaign from '[GLOB.dreamvalley_campaign.campaign_id]' to '[target_id]'.")
	GLOB.dreamvalley_campaign.switch_campaign(target_id)
	to_chat(usr, span_notice("Switched to campaign '[target_id]'. The world will need a restart to fully load the new campaign state."))
	// Trigger a restart to load the new campaign's world state.
	world.Reboot("Campaign switched by [usr.client.key]")

/// Admin verb to create a new campaign.
/client/proc/cmd_admin_create_campaign()
	set category = "Debug"
	set name = "Create Campaign"
	set desc = "Create a new DreamValley campaign save (new world)."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return

	var/new_id = input(usr, "Enter a campaign ID (alphanumeric, underscore, hyphen only):", "Create Campaign") as text|null
	if(!new_id || !length(new_id))
		return
	var/result = GLOB.dreamvalley_campaign.create_campaign(new_id)
	if(!result)
		to_chat(usr, span_warning("Failed to create campaign '[new_id]'. It may already exist or the ID is invalid."))
		return
	to_chat(usr, span_notice("Created campaign '[result]'. Use 'Switch Campaign' to switch to it."))
	log_admin("[key_name(usr)] created DreamValley campaign '[result]'.")

/// Admin verb to delete a campaign.
/client/proc/cmd_admin_delete_campaign()
	set category = "Debug"
	set name = "Delete Campaign"
	set desc = "Delete a DreamValley campaign save. Cannot delete the active campaign."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return

	var/list/campaigns = GLOB.dreamvalley_campaign.list_campaigns()
	if(!length(campaigns))
		to_chat(usr, span_warning("No campaign saves found."))
		return
	var/list/display = list()
	for(var/cid in campaigns)
		if(cid == GLOB.dreamvalley_campaign.campaign_id)
			continue
		var/list/info = campaigns[cid]
		display["[info["name"]] (gen [info["generation"]])"] = cid
	if(!length(display))
		to_chat(usr, span_warning("No other campaigns to delete (the active campaign cannot be deleted)."))
		return
	var/choice = input(usr, "Delete which campaign? This cannot be undone.", "Delete Campaign") as null|anything in sortList(display)
	if(!choice || !display[choice])
		return
	var/target_id = display[choice]
	if(alert(usr, "Permanently delete campaign '[target_id]'? This cannot be undone.", "Delete Campaign", "Delete", "Cancel") != "Delete")
		return
	GLOB.dreamvalley_campaign.delete_campaign(target_id)
	to_chat(usr, span_boldannounce("Deleted campaign '[target_id]'."))
	log_admin("[key_name(usr)] deleted DreamValley campaign '[target_id]'.")

/// Admin verb to list all campaigns.
/client/proc/cmd_admin_list_campaigns()
	set category = "Debug"
	set name = "List Campaigns"
	set desc = "List all DreamValley campaign saves."

	if(!check_rights(R_ADMIN|R_DEBUG))
		return
	if(!GLOB.dreamvalley_campaign)
		to_chat(usr, span_warning("The DreamValley campaign system is not active on this server."))
		return

	var/list/campaigns = GLOB.dreamvalley_campaign.list_campaigns()
	if(!length(campaigns))
		to_chat(usr, span_notice("No campaign saves found."))
		return
	var/active = GLOB.dreamvalley_campaign.campaign_id
	var/list/lines = list()
	lines += "Active campaign: [active] (generation [GLOB.dreamvalley_campaign.checkpoint_generation])"
	lines += "---"
	for(var/cid in campaigns)
		var/list/info = campaigns[cid]
		var/marker = (cid == active) ? " *" : ""
		lines += "[info["name"]] (ID: [cid]) - gen [info["generation"]], saved [info["saved_at"]][marker]"
	to_chat(usr, span_notice(lines.Join("\n")))

#undef DREAMVALLEY_SAVE_ROOT
#undef DREAMVALLEY_CAMPAIGNS_ROOT
#undef DREAMVALLEY_LEGACY_SAVE_FILE
