/**
 * Opt-in persistence contracts for DreamValley campaigns.
 *
 * Saving every datum in an SS13 process is neither useful nor safe: most are
 * controllers, caches, callbacks, particles, or other transient runtime state.
 * Game types opt in and return JSON-safe state through these procs instead.
 */

/datum/proc/dreamvalley_should_persist()
	return FALSE

/datum/proc/dreamvalley_save_state()
	return null

/datum/proc/dreamvalley_load_state(list/state)
	return

/datum/proc/dreamvalley_after_load()
	return

/**
 * Runtime-created objects can set dreamvalley_persistent to TRUE. The temporary
 * ID links later journal entries without becoming part of normal map state.
 */
/atom/movable
	var/dreamvalley_persistent = FALSE
	/// Physical runtime-created types opt in to automatic campaign registration.
	var/dreamvalley_auto_persist = FALSE
	var/tmp/dreamvalley_persistence_id
	/// TRUE when this object was already part of the static DMM base and was
	/// registered later because a player changed its persisted state (a door
	/// was locked, a closet opened, etc). Restoring such a record must locate
	/// the existing map instance instead of spawning a duplicate.
	var/tmp/dreamvalley_persistent_mapped = FALSE

/atom/movable/dreamvalley_should_persist()
	return dreamvalley_persistent

/atom/movable/dreamvalley_save_state()
	if(!dreamvalley_should_persist())
		return null

	var/turf/current_turf = get_turf(src)
	var/parent_id
	if(ismovable(loc))
		var/atom/movable/parent = loc
		if(parent.dreamvalley_should_persist())
			parent_id = GLOB.dreamvalley_campaign.register_persistent(parent)

	return list(
		"id" = dreamvalley_persistence_id,
		"type" = "[type]",
		"parent_id" = parent_id,
		"mapped" = dreamvalley_persistent_mapped,
		"x" = current_turf?.x,
		"y" = current_turf?.y,
		"z" = current_turf?.z,
		"vars" = dreamvalley_save_variables(),
	)

/datum/proc/dreamvalley_persistent_var_names()
	return list()

/atom/movable/dreamvalley_persistent_var_names()
	return list("name", "dir", "pixel_x", "pixel_y", "anchored", "density")

/obj/dreamvalley_persistent_var_names()
	var/list/names = ..()
	names += list("obj_integrity")
	return names

/obj/item/dreamvalley_persistent_var_names()
	var/list/names = ..()
	names += list("quality", "amount", "was_crafted", "is_carved")
	return names

/// Construction/machinery/door/container state that can differ from the
/// static DMM base once players interact with a mapped or runtime instance.
/obj/machinery/dreamvalley_persistent_var_names()
	var/list/names = ..()
	names += list("stat")
	return names

/obj/structure/closet/dreamvalley_persistent_var_names()
	var/list/names = ..()
	names += list("opened", "welded", "locked", "obj_broken")
	return names

/obj/structure/mineral_door/dreamvalley_persistent_var_names()
	var/list/names = ..()
	names += list("door_opened", "locked", "brokenstate", "lockbroken")
	return names

/datum/proc/dreamvalley_save_variables()
	var/list/result = list()
	for(var/variable_name in dreamvalley_persistent_var_names())
		if(!(variable_name in vars))
			continue
		var/value = vars[variable_name]
		if(isnull(value) || isnum(value) || istext(value))
			result[variable_name] = value
	return result

/datum/proc/dreamvalley_load_variables(list/saved_variables)
	if(!islist(saved_variables))
		return
	for(var/variable_name in dreamvalley_persistent_var_names())
		if(variable_name in saved_variables)
			vars[variable_name] = saved_variables[variable_name]

/atom/movable/dreamvalley_load_state(list/state)
	if(!islist(state))
		return
	var/list/saved_variables = state["vars"]
	dreamvalley_load_variables(saved_variables)

/**
 * Called by crafting/construction code for types that do not auto-persist,
 * and by mapped doors/containers/machinery the moment a player changes their
 * persisted state (locked, opened, broken, powered, etc). Registration is
 * idempotent and only needs to happen once; the object's live vars are read
 * fresh at every later checkpoint. Calls before the round is actually playing
 * or while a snapshot is being restored are ignored so map-load-time state
 * changes never get treated as player-driven deltas.
 */
/atom/movable/proc/dreamvalley_mark_persistent()
	if(!GLOB.dreamvalley_campaign?.enabled || GLOB.dreamvalley_campaign.restoring_snapshot)
		return null
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return null
	if(!dreamvalley_persistent)
		dreamvalley_persistent_mapped = TRUE
	return GLOB.dreamvalley_campaign.register_persistent(src)

// Runtime physical state persists by default. A transient subtype can override
// dreamvalley_auto_persist = FALSE without changing its normal game behavior.
/obj/item
	dreamvalley_auto_persist = TRUE

/obj/structure
	dreamvalley_auto_persist = TRUE

/obj/machinery
	dreamvalley_auto_persist = TRUE

/**
 * Turfs are represented as chunk deltas rather than assigning an ID and save
 * record to every tile in the base map.
 */
/turf/proc/dreamvalley_chunk_key(chunk_size = 16)
	var/chunk_x = round((x - 1) / chunk_size)
	var/chunk_y = round((y - 1) / chunk_size)
	return "[z]:[chunk_x]:[chunk_y]"
