/**
 * In-world half of DreamValley's campaign save bridge.
 *
 * This manager identifies persistent objects and records changed turfs. The
 * Stardew host owns atomic checkpoints, the append-only journal, and backups.
 */
/datum/dreamvalley_campaign_manager
	/// This branch is a campaign codebase even when launched without Stardew.
	var/enabled = TRUE
	var/campaign_id = "default"
	var/data_root = "data/dreamvalley/campaigns"
	var/next_persistence_id = 1
	/// Stable ID to live runtime object for objects newer than the static DMM.
	var/list/persistent_objects = list()
	/// Complete parked records keyed by "ckey/preference-slot".
	var/list/parked_characters = list()
	/// Runtime-only parking transactions waiting for host durability acknowledgement.
	var/list/pending_character_parking = list()
	/// Runtime-only Continue transactions waiting for their resuming lock.
	var/list/pending_character_resumes = list()
	var/list/dirty_turfs = list()
	/// Complete latest state for every turf changed after the static DMM loaded.
	var/list/persisted_turfs = list()
	/// Prevent restoration changes from being journalled as player changes.
	var/restoring_snapshot = FALSE
	/// Host-side durable sequence/generation cursors loaded from bootstrap.
	var/journal_sequence = 0
	var/checkpoint_generation = 0
	/// Checkpoints written to the spool but not yet acknowledged by the host.
	var/list/pending_checkpoint_generations = list()
	var/last_acknowledged_generation = 0

	/// Round completion/reboot is replaced by explicit campaign save and shutdown.
	var/suppress_round_end = TRUE
	/// Endless campaigns must not generate the old per-round Triumph farm each night.
	var/suppress_daily_triumphs = TRUE
	/// Mundane world events can continue without turning the campaign into a PvP round.
	var/allow_ambient_storyteller_events = TRUE
	/// Antagonist assignment and antagonist injection are opt-in for private campaigns.
	var/allow_antagonists = FALSE
	/// Round/gamemode votes are replaced by host-owned campaign settings.
	var/allow_player_votes = FALSE
	/// Players enter through JOIN/Continue instead of automatic migrant waves.
	var/allow_automatic_migrants = FALSE
	/// Round contribution, survival, and round-end rewards do not fit an endless save.
	var/allow_round_rewards = FALSE

	/// In-game seconds advanced per real second.
	var/time_scale = DREAMVALLEY_DEFAULT_TIME_SCALE
	/// Short dawn, long day, short dusk, and a proportional night.
	var/dawn_start = DREAMVALLEY_DEFAULT_DAWN_START
	var/day_start = DREAMVALLEY_DEFAULT_DAY_START
	var/dusk_start = DREAMVALLEY_DEFAULT_DUSK_START
	var/night_start = DREAMVALLEY_DEFAULT_NIGHT_START
	/// Used when a campaign does not yet have a saved clock.
	var/start_time = DREAMVALLEY_DEFAULT_START_TIME
	/// Restored clock values supplied by a checkpoint.
	var/restored_station_time
	var/restored_days_passed

	/// The transaction still performs preflight and a shadow-body round trip;
	/// unsupported character state cancels safely before staging a checkpoint.
	var/character_parking_ready = TRUE

/datum/dreamvalley_campaign_manager/proc/configure(new_campaign_id)
	if(!istext(new_campaign_id) || !length(new_campaign_id))
		return FALSE

	campaign_id = new_campaign_id
	enabled = TRUE
	return TRUE

/datum/dreamvalley_campaign_manager/proc/configure_clock(new_time_scale, new_dawn_start, new_day_start, new_dusk_start, new_night_start)
	if(!isnum(new_time_scale) || new_time_scale <= 0)
		return FALSE
	if(!isnum(new_dawn_start) || !isnum(new_day_start) || !isnum(new_dusk_start) || !isnum(new_night_start))
		return FALSE
	if(new_dawn_start < 0 || new_dawn_start >= new_day_start)
		return FALSE
	if(new_day_start >= new_dusk_start || new_dusk_start >= new_night_start)
		return FALSE
	if(new_night_start >= DREAMVALLEY_DAY_LENGTH)
		return FALSE

	time_scale = new_time_scale
	dawn_start = new_dawn_start
	day_start = new_day_start
	dusk_start = new_dusk_start
	night_start = new_night_start

	apply_clock()
	return TRUE

/datum/dreamvalley_campaign_manager/proc/restore_clock(list/state)
	if(!islist(state))
		return FALSE

	var/saved_station_time = state["station_time"]
	var/saved_days = state["days_passed"]
	if(!isnum(saved_station_time) || saved_station_time < 0 || saved_station_time >= DREAMVALLEY_DAY_LENGTH)
		return FALSE
	if(!isnum(saved_days) || saved_days < 0)
		return FALSE

	restored_station_time = saved_station_time
	restored_days_passed = saved_days
	apply_clock()
	return TRUE

/datum/dreamvalley_campaign_manager/proc/apply_clock()
	if(!enabled)
		return FALSE

	if(SSticker)
		SSticker.station_time_rate_multiplier = time_scale
		SSticker.gametime_offset = isnum(restored_station_time) ? restored_station_time : start_time

	if(SSnightshift)
		SSnightshift.nightshift_dawn_start = dawn_start
		SSnightshift.nightshift_day_start = day_start
		SSnightshift.nightshift_dusk_start = dusk_start
		SSnightshift.nightshift_start_time = night_start

	if(isnum(restored_days_passed))
		GLOB.dayspassed = restored_days_passed

	return TRUE

/datum/dreamvalley_campaign_manager/proc/should_suppress_round_end()
	return enabled && suppress_round_end

/datum/dreamvalley_campaign_manager/proc/should_suppress_daily_triumphs()
	return enabled && suppress_daily_triumphs

/datum/dreamvalley_campaign_manager/proc/should_suppress_antagonists()
	return enabled && !allow_antagonists

/datum/dreamvalley_campaign_manager/proc/should_suppress_player_votes()
	return enabled && !allow_player_votes

/datum/dreamvalley_campaign_manager/proc/should_suppress_automatic_migrants()
	return enabled && !allow_automatic_migrants

/datum/dreamvalley_campaign_manager/proc/should_suppress_round_rewards()
	return enabled && !allow_round_rewards

/datum/dreamvalley_campaign_manager/proc/rules_status()
	return list(
		"ambient_storyteller_events" = allow_ambient_storyteller_events,
		"antagonists" = allow_antagonists,
		"player_votes" = allow_player_votes,
		"automatic_migrants" = allow_automatic_migrants,
		"round_rewards" = allow_round_rewards,
	)

/datum/dreamvalley_campaign_manager/proc/configure_rules(list/rules)
	if(!islist(rules))
		return FALSE

	if(!isnull(rules["ambient_storyteller_events"]))
		allow_ambient_storyteller_events = !!rules["ambient_storyteller_events"]
	if(!isnull(rules["antagonists"]))
		allow_antagonists = !!rules["antagonists"]
	if(!isnull(rules["player_votes"]))
		allow_player_votes = !!rules["player_votes"]
	if(!isnull(rules["automatic_migrants"]))
		allow_automatic_migrants = !!rules["automatic_migrants"]
	if(!isnull(rules["round_rewards"]))
		allow_round_rewards = !!rules["round_rewards"]

	apply_gamemode_rules(SSgamemode)
	return TRUE

/datum/dreamvalley_campaign_manager/proc/apply_gamemode_rules(datum/controller/subsystem/gamemode/gamemode)
	if(!enabled || !gamemode)
		return FALSE

	gamemode.allow_vote = allow_player_votes
	gamemode.halted_storyteller = !allow_ambient_storyteller_events
	if(!allow_antagonists)
		gamemode.selected_storyteller = /datum/storyteller/gamemode/extended
		if(!SSticker?.HasRoundStarted())
			gamemode.roundstart_storyteller = /datum/storyteller/gamemode/extended
	return TRUE

/datum/dreamvalley_campaign_manager/proc/clock_status()
	var/current_station_time
	if(SSticker)
		current_station_time = station_time()

	return list(
		"time_scale" = time_scale,
		"station_time" = current_station_time,
		"days_passed" = GLOB.dayspassed,
		"dawn_start" = dawn_start,
		"day_start" = day_start,
		"dusk_start" = dusk_start,
		"night_start" = night_start,
	)

/datum/dreamvalley_campaign_manager/proc/ensure_id(atom/movable/thing)
	if(!thing || !thing.dreamvalley_should_persist())
		return null

	if(!thing.dreamvalley_persistence_id)
		thing.dreamvalley_persistence_id = "[campaign_id]-[next_persistence_id++]"

	return thing.dreamvalley_persistence_id

/datum/dreamvalley_campaign_manager/proc/capture(atom/movable/thing)
	if(!enabled)
		return null

	var/persistent_id = ensure_id(thing)
	if(!persistent_id)
		return null

	return thing.dreamvalley_save_state()

/datum/dreamvalley_campaign_manager/proc/mark_turf_dirty(turf/changed_turf)
	if(!enabled || !changed_turf)
		return FALSE
	if(restoring_snapshot || !SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return FALSE

	var/key = "[changed_turf.x],[changed_turf.y],[changed_turf.z]"
	dirty_turfs[key] = changed_turf
	persisted_turfs[key] = capture_turf_state(changed_turf)
	return TRUE

/datum/dreamvalley_campaign_manager/proc/capture_turf_state(turf/changed_turf)
	if(!changed_turf)
		return null

	return list(
		"key" = "[changed_turf.x],[changed_turf.y],[changed_turf.z]",
		"chunk" = changed_turf.dreamvalley_chunk_key(),
		"type" = "[changed_turf.type]",
		"x" = changed_turf.x,
		"y" = changed_turf.y,
		"z" = changed_turf.z,
	)

/datum/dreamvalley_campaign_manager/proc/drain_turf_deltas()
	var/list/result = list()
	for(var/key in dirty_turfs)
		var/turf/changed_turf = dirty_turfs[key]
		if(!changed_turf)
			continue

		var/list/state = capture_turf_state(changed_turf)
		if(state)
			persisted_turfs[key] = state
			result += list(state)

	dirty_turfs.Cut()
	return result

/datum/dreamvalley_campaign_manager/proc/capture_snapshot()
	var/list/turfs = list()
	for(var/key in persisted_turfs)
		var/list/turf_state = persisted_turfs[key]
		if(islist(turf_state))
			turfs += list(turf_state.Copy())

	return list(
		"schema_version" = 1,
		"campaign_id" = campaign_id,
		"next_persistence_id" = next_persistence_id,
		"rules" = rules_status(),
		"clock" = clock_status(),
		"turfs" = turfs,
		"objects" = capture_persistent_objects(),
		"characters" = copy_character_records(),
	)

/datum/dreamvalley_campaign_manager/proc/load_snapshot(list/snapshot)
	if(!islist(snapshot))
		return FALSE

	var/list/rules = snapshot["rules"]
	if(islist(rules))
		configure_rules(rules)
	var/list/clock = snapshot["clock"]
	if(islist(clock))
		restore_clock(clock)
	var/saved_next_id = snapshot["next_persistence_id"]
	if(isnum(saved_next_id))
		next_persistence_id = max(1, saved_next_id)

	var/list/turfs = snapshot["turfs"]
	if(islist(turfs))
		restoring_snapshot = TRUE
		for(var/list/turf_state as anything in turfs)
			if(!islist(turf_state))
				continue
			var/x = turf_state["x"]
			var/y = turf_state["y"]
			var/z = turf_state["z"]
			var/type_text = turf_state["type"]
			if(!isnum(x) || !isnum(y) || !isnum(z) || !istext(type_text))
				continue
			var/turf/current = locate(x, y, z)
			var/turf_path = text2path(type_text)
			if(!current || !ispath(turf_path, /turf))
				continue
			var/turf/restored = current
			if(current.type != turf_path)
				restored = current.ChangeTurf(turf_path, flags = CHANGETURF_INHERIT_AIR)
			if(!restored)
				continue
			var/key = "[x],[y],[z]"
			persisted_turfs[key] = turf_state.Copy()
		restoring_snapshot = FALSE

	var/list/objects = snapshot["objects"]
	if(islist(objects))
		load_persistent_objects(objects)
	var/list/characters = snapshot["characters"]
	load_character_records(characters)
	dirty_turfs.Cut()
	return TRUE

/datum/dreamvalley_campaign_manager/proc/status()
	return list(
		"enabled" = enabled,
		"campaign_id" = campaign_id,
		"data_root" = data_root,
		"next_persistence_id" = next_persistence_id,
		"dirty_turfs" = length(dirty_turfs),
		"persisted_turfs" = length(persisted_turfs),
		"persistent_objects" = length(persistent_objects),
		"parked_characters" = length(parked_characters),
		"parking_characters" = length(pending_character_parking),
		"resuming_characters" = length(pending_character_resumes),
		"journal_sequence" = journal_sequence,
		"checkpoint_generation" = checkpoint_generation,
		"pending_checkpoints" = length(pending_checkpoint_generations),
		"last_acknowledged_generation" = last_acknowledged_generation,
		"suppress_round_end" = suppress_round_end,
		"suppress_daily_triumphs" = suppress_daily_triumphs,
		"rules" = rules_status(),
		"character_parking_ready" = character_parking_ready,
		"clock" = clock_status(),
	)

GLOBAL_DATUM_INIT(dreamvalley_campaign, /datum/dreamvalley_campaign_manager, new)
