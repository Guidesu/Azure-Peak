/**
 * Persistent physical-object graph.
 *
 * Only registered objects are captured. Runtime items, structures, and
 * machinery register automatically through /obj/Initialize. Mapped objects
 * (doors, closets, machinery already placed in the DMM) stay unregistered
 * until a player actually changes their state, at which point
 * dreamvalley_mark_persistent() registers them and flags them as mapped so
 * reloads reattach to the existing map instance instead of spawning a
 * duplicate. Containers are restored in two passes so nested items can refer
 * to parents regardless of record order.
 */

/datum/dreamvalley_campaign_manager/proc/register_persistent(atom/movable/thing, requested_id)
	if(!enabled || !thing || QDELETED(thing))
		return null

	thing.dreamvalley_persistent = TRUE
	if(istext(requested_id) && length(requested_id))
		thing.dreamvalley_persistence_id = requested_id

	var/persistent_id = ensure_id(thing)
	if(!persistent_id)
		return null
	persistent_objects[persistent_id] = thing
	return persistent_id

/datum/dreamvalley_campaign_manager/proc/unregister_persistent(atom/movable/thing)
	if(!thing?.dreamvalley_persistence_id)
		return FALSE
	var/persistent_id = thing.dreamvalley_persistence_id
	if(persistent_objects[persistent_id] == thing)
		persistent_objects -= persistent_id
	return TRUE

/datum/dreamvalley_campaign_manager/proc/register_persistent_contents(atom/movable/root)
	if(!root)
		return
	var/list/queue = list(root)
	while(length(queue))
		var/atom/movable/container = queue[1]
		queue.Cut(1, 2)
		if(!container || QDELETED(container))
			continue
		for(var/atom/movable/child in container.contents)
			if(!child.dreamvalley_auto_persist)
				continue
			register_persistent(child)
			queue += child

/datum/dreamvalley_campaign_manager/proc/capture_persistent_objects()
	var/list/registered_ids = persistent_objects.Copy()
	for(var/persistent_id in registered_ids)
		var/atom/movable/root = persistent_objects[persistent_id]
		register_persistent_contents(root)

	var/list/result = list()
	registered_ids = persistent_objects.Copy()
	for(var/persistent_id in registered_ids)
		var/atom/movable/thing = persistent_objects[persistent_id]
		if(!thing || QDELETED(thing))
			persistent_objects -= persistent_id
			continue
		var/list/state = capture(thing)
		if(state)
			result += list(state)
	return result

/**
 * Mapped doors/containers/machinery are never spawned by a checkpoint; they
 * already exist from the static DMM. Reattach the saved record to the first
 * unclaimed instance of that exact type on the saved turf instead of creating
 * a duplicate on top of it.
 */
/datum/dreamvalley_campaign_manager/proc/locate_mapped_object(turf/target_turf, object_path)
	if(!target_turf || !ispath(object_path, /obj))
		return null
	for(var/atom/movable/candidate in target_turf.contents)
		if(candidate.dreamvalley_persistence_id)
			continue
		if(candidate.type == object_path)
			return candidate
	return null

/datum/dreamvalley_campaign_manager/proc/load_persistent_objects(list/states)
	if(!islist(states))
		return TRUE

	var/list/restored_by_id = list()
	restoring_snapshot = TRUE

	// First create/locate every object at its saved turf and establish stable IDs.
	for(var/list/state as anything in states)
		if(!islist(state))
			continue
		var/persistent_id = state["id"]
		var/type_text = state["type"]
		var/x = state["x"]
		var/y = state["y"]
		var/z = state["z"]
		var/mapped = state["mapped"]
		if(!istext(persistent_id) || !length(persistent_id) || !istext(type_text))
			continue
		var/object_path = text2path(type_text)
		var/turf/spawn_turf
		if(isnum(x) && isnum(y) && isnum(z))
			spawn_turf = locate(x, y, z)
		if(!ispath(object_path, /obj) || !spawn_turf)
			continue

		var/obj/restored
		if(mapped)
			restored = locate_mapped_object(spawn_turf, object_path)
			if(!restored)
				// The mapped instance is gone (map or content changed); skip
				// rather than spawn a duplicate that was never really there.
				continue
			restored.dreamvalley_persistent_mapped = TRUE
		else
			restored = new object_path(spawn_turf)
		if(!restored || QDELETED(restored))
			continue
		register_persistent(restored, persistent_id)
		restored_by_id[persistent_id] = restored

	// Then rebuild containment and apply explicitly supported mutable state.
	for(var/list/state as anything in states)
		if(!islist(state))
			continue
		var/persistent_id = state["id"]
		var/atom/movable/restored = restored_by_id[persistent_id]
		if(!restored || QDELETED(restored))
			continue
		var/parent_id = state["parent_id"]
		if(istext(parent_id))
			var/atom/movable/parent = restored_by_id[parent_id]
			if(parent && !QDELETED(parent))
				restored.forceMove(parent)
		restored.dreamvalley_load_state(state)

	for(var/persistent_id in restored_by_id)
		var/atom/movable/restored = restored_by_id[persistent_id]
		if(restored && !QDELETED(restored))
			restored.dreamvalley_after_load()

	restoring_snapshot = FALSE
	return TRUE
