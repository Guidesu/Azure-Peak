#define STAGE_EXPANSION 1
#define STAGE_CLEANUP 2

SUBSYSTEM_DEF(dungeon_generator)
	name = "Dungeon Generator"
	init_order = 15
	runlevels = RUNLEVEL_GAME | RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP
	wait = 0.5 SECONDS

	var/list/parent_types = list()
	var/list/templates_by_category = list() 
	var/list/templates_by_connection = list()
	var/list/templates_by_connection_and_depth = list()
	var/list/filler_templates_by_connection = list()
	var/list/markers = list() 
	var/list/failed_markers = list() 
	var/list/placed_count = list()

	var/generation_stage = STAGE_EXPANSION
	var/marker_process_limit = 5
	var/repetition_penalty = 2

	var/target_z = 0
	/// Hard safety range for where a dungeon piece is ever allowed to land, resolved
	/// alongside target_z from the same "Dungeon Map"/"Dungeon Map 2" space_level
	/// names (see LoadGroup() in mapping.dm - "[name][i ? " [i + 1]" : ""]" naming).
	/// can_place() refuses anything outside this range no matter what target_z or a
	/// z_off computation comes out to, as a backstop against ever placing dungeon
	/// content onto a station map's own z-levels.
	var/list/allowed_z_range = list()
	var/setup_done = FALSE
	var/setup_attempts = 0
	var/max_setup_attempts = 12
	var/loot_pool_finalized = FALSE
	var/generation_complete = FALSE
	/// Players can reach the tomb well before generation fully finishes - a
	/// large multi-biome dungeon can take well over a minute to place every
	/// room. Waiting for finalize_generation() to run the loot sweep left
	/// early-generated rooms' spawners sitting inert (visible as the bare
	/// "General low/mid" etc. spawner objects) for however long the rest of
	/// generation still had left. Sweep periodically during generation too,
	/// not just once at the very end - process_deferred_loot_pool() already
	/// tolerates repeat calls safely (see loot_pool.dm).
	var/next_interim_loot_sweep = 0

	var/prot_min_x = 0; var/prot_max_x = 0; var/prot_min_y = 0; var/prot_max_y = 0

/datum/controller/subsystem/dungeon_generator/Initialize(start_timeofday)
	var/list/dungeon_templates = list()
	templates_by_connection = list()
	templates_by_connection_and_depth = list()
	filler_templates_by_connection = list()
	for(var/direction in GLOB.cardinals)
		var/key = direction_key(direction)
		templates_by_connection[key] = list()
		templates_by_connection_and_depth[key] = list()
		filler_templates_by_connection[key] = list()

	for(var/path in subtypesof(/datum/map_template/dungeon))
		var/datum/map_template/dungeon/path_type = path
		if(initial(path_type.abstract_type) == path || ispath(path, /datum/map_template/dungeon/entry))
			continue 

		var/datum/map_template/dungeon/T = new path
		if(!T || !T.mappath) continue

		parent_types[path] = initial(path_type.type_weight) || 10
		dungeon_templates += T
		cache_template_connections(T)

	
	templates_by_category[/datum/map_template/dungeon] = dungeon_templates

	addtimer(CALLBACK(src, .proc/find_initial_map_data), 50) 
	return ..()

/**
 * target_z used to be inferred from "whichever dungeon_directional_helper this
 * for(...) in world loop finds first" - `in world` iteration order isn't
 * something DM guarantees, and the actual z that lands on depends entirely on
 * how many z-levels the current map config loads before "Dungeon Map"
 * (otherz/dungeon.json) does. That's what made the tomb appear to regenerate
 * on a different z-level than expected: the number was never pinned to
 * anything, just whatever came out of load order that boot.
 *
 * "Dungeon Map" (see otherz/dungeon.json's map_name, and how
 * /datum/controller/subsystem/mapping/proc/LoadGroup() names each space_level
 * after it) is the one stable identifier for this z-level regardless of load
 * order, so resolve target_z from that instead.
 */
/datum/controller/subsystem/dungeon_generator/proc/find_initial_map_data()
	if(!target_z)
		for(var/datum/space_level/level in SSmapping.z_list)
			if(level.name == "Dungeon Map" || level.name == "Dungeon Map 2")
				allowed_z_range += level.z_value
			if(level.name == "Dungeon Map")
				target_z = level.z_value
		if(target_z)
			log_world("DUNGEON_DEBUG: target_z resolved to [target_z] (world.maxz=[world.maxz]), allowed_z_range=[allowed_z_range.Join(",")] via 'Dungeon Map' z_list lookup.")

	if(!target_z)
		setup_attempts++
		if(setup_attempts >= max_setup_attempts)
			log_world("DUNGEON_DEBUG: giving up after [setup_attempts] attempts - no z_list entry named 'Dungeon Map' ever appeared. z_list names: [dungeon_debug_zlist_names()]")
			generation_complete = TRUE
			can_fire = FALSE
			return
		addtimer(CALLBACK(src, .proc/find_initial_map_data), 50)
		return

	var/list/found_points = list()
	for(var/obj/effect/dungeon_directional_helper/H in world)
		if(H.z == target_z)
			found_points += H

	if(!length(found_points))
		setup_attempts++
		if(setup_attempts >= max_setup_attempts)
			generation_complete = TRUE
			can_fire = FALSE
			return
		addtimer(CALLBACK(src, .proc/find_initial_map_data), 50)
		return

	log_world("DUNGEON_DEBUG: found [length(found_points)] dungeon_directional_helper marker(s) on target_z=[target_z].")

	if(length(found_points) >= 4)
		var/obj/F = found_points[1]
		prot_min_x = F.x; prot_max_x = F.x; prot_min_y = F.y; prot_max_y = F.y
		for(var/i in 1 to 4)
			var/obj/O = found_points[i]
			prot_min_x = min(prot_min_x, O.x); prot_max_x = max(prot_max_x, O.x)
			prot_min_y = min(prot_min_y, O.y); prot_max_y = max(prot_max_y, O.y)

	markers |= found_points
	setup_done = TRUE
	setup_attempts = 0

/datum/controller/subsystem/dungeon_generator/proc/dungeon_debug_zlist_names()
	var/list/names = list()
	for(var/datum/space_level/level in SSmapping.z_list)
		names += "[level.z_value]:[level.name]"
	return names.Join(", ")

/datum/controller/subsystem/dungeon_generator/fire(resumed)
	if(!setup_done) return

	if(generation_complete)
		can_fire = FALSE
		return

	if(!length(markers) && !length(failed_markers))
		finalize_generation()
		return

	if(generation_stage == STAGE_EXPANSION)
		if(length(markers))
			process_markers(marker_process_limit)
		else
			generation_stage = STAGE_CLEANUP
	else if(generation_stage == STAGE_CLEANUP)
		if(length(failed_markers))
			process_failed_markers(marker_process_limit)
		else
			generation_stage = STAGE_EXPANSION

	if(world.time >= next_interim_loot_sweep)
		next_interim_loot_sweep = world.time + 10 SECONDS
		process_deferred_loot_pool("tomb_of_alotheos")

/datum/controller/subsystem/dungeon_generator/proc/process_markers(limit)
	var/processed = 0
	while(length(markers) && processed < limit)
		var/idx = rand(1, length(markers))
		var/obj/effect/dungeon_directional_helper/helper = markers[idx]
		markers.Cut(idx, idx + 1)
		
		if(helper && !QDELETED(helper))
			if(!try_grow_at_marker(helper))
				failed_markers |= helper
		processed++

/datum/controller/subsystem/dungeon_generator/proc/try_grow_at_marker(obj/effect/dungeon_directional_helper/helper)
	var/turf/origin = get_turf(helper)
	var/direction = helper.dir
	var/turf/start_step = get_step(origin, direction)
	if(!start_step) return FALSE

	if(start_step.density && !is_strictly_void(start_step))
		if(!is_protected(start_step.x, start_step.y) && prob(40))
			return try_bridge_gap(helper, start_step)
		return FALSE

	var/list/area_dims = scan_free_area(start_step, direction)
	var/max_dist = area_dims["h"]
	if(max_dist < 4) return FALSE 

	var/opp_dir = reverse_direction(direction)
	var/list/checking_list = get_candidate_templates(opp_dir, max_dist)
	
	for(var/datum/map_template/dungeon/T in checking_list)
		var/offset = T.get_dir_offset(opp_dir)
		if(offset == null) continue

		var/spawn_x = start_step.x; var/spawn_y = start_step.y
		if(direction == NORTH) spawn_x -= offset
		else if(direction == SOUTH) { spawn_x -= offset; spawn_y -= (T.height - 1); }
		else if(direction == EAST) spawn_y -= offset
		else if(direction == WEST) { spawn_x -= (T.width - 1); spawn_y -= offset; }

		var/turf/placement = locate(spawn_x, spawn_y, target_z)
		if(can_place(T, placement))
			if(T.load(placement))
				on_template_placed(T, placement)
				qdel(helper)
				return TRUE
		CHECK_TICK
	return FALSE

/datum/controller/subsystem/dungeon_generator/proc/try_bridge_gap(obj/effect/dungeon_directional_helper/helper, turf/target_turf)
	if(!target_turf || !istype(target_turf, /turf/closed/wall/mineral/rogue)) return FALSE
	target_turf.ChangeTurf(/turf/open/floor/rogue/hexstone, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)
	qdel(helper)
	return TRUE

/datum/controller/subsystem/dungeon_generator/proc/scan_free_area(turf/start_T, dir)
	var/depth = 0
	for(var/i in 1 to 30)
		var/turf/T = get_step_dist(start_T, dir, i)
		if(!T || !is_strictly_void(T) || is_protected(T.x, T.y)) break
		depth = i
	return list("h" = depth) 

/datum/controller/subsystem/dungeon_generator/proc/get_step_dist(turf/start, dir, dist)
	var/tx = start.x; var/ty = start.y
	switch(dir)
		if(NORTH) ty += dist
		if(SOUTH) ty -= dist
		if(EAST) tx += dist
		if(WEST) tx -= dist
	return locate(tx, ty, target_z)

/datum/controller/subsystem/dungeon_generator/proc/can_place(datum/map_template/dungeon/T, turf/start_T)
	if(!start_T) return FALSE
	var/ex = start_T.x + T.width - 1
	var/ey = start_T.y + T.height - 1
	if(ex > world.maxx || ey > world.maxy || start_T.x < 1 || start_T.y < 1) return FALSE

	for(var/z_off in 0 to 1)
		var/cz = target_z + z_off
		if(cz > world.maxz) return FALSE
		if(length(allowed_z_range) && !(cz in allowed_z_range))
			log_world("DUNGEON_DEBUG: REFUSED placement of [T.type] at z=[cz] (outside allowed_z_range=[allowed_z_range.Join(",")]) - this would have overlapped a station map.")
			return FALSE
		for(var/turf/test in block(locate(start_T.x, start_T.y, cz), locate(ex, ey, cz)))
			if(z_off == 0)
				if(!is_strictly_void(test) || is_protected(test.x, test.y)) return FALSE
			else
				if(test.density && !is_strictly_void(test)) return FALSE
			for(var/obj/O in test)
				if(istype(O, /obj/effect/dungeon_directional_helper)) continue
				if(O.density) return FALSE
	return TRUE

/datum/controller/subsystem/dungeon_generator/proc/is_protected(x, y)
	return (x > prot_min_x && x < prot_max_x && y > prot_min_y && y < prot_max_y)

/datum/controller/subsystem/dungeon_generator/proc/is_strictly_void(turf/T)
	if(!T) return FALSE
	return (istype(T, /turf/closed/dungeon_void) || istype(T, /turf/closed/mineral/rogue/bedrock))

/datum/controller/subsystem/dungeon_generator/proc/on_template_placed(datum/map_template/dungeon/T, turf/placement)
	placed_count[T.type]++

/datum/controller/subsystem/dungeon_generator/proc/reverse_direction(dir)
	switch(dir)
		if(NORTH) return SOUTH
		if(SOUTH) return NORTH
		if(EAST)  return WEST
		if(WEST)  return EAST
	return dir

/datum/controller/subsystem/dungeon_generator/proc/direction_key(dir)
	return "[dir]"

/datum/controller/subsystem/dungeon_generator/proc/cache_template_connections(datum/map_template/dungeon/T)
	for(var/direction in GLOB.cardinals)
		if(T.get_dir_offset(direction) == null)
			continue
		var/key = direction_key(direction)
		templates_by_connection[key] += T
		var/list/depth_buckets = templates_by_connection_and_depth[key]
		var/required_depth = CEILING(max(T.width, T.height) / 2, 1)
		var/depth_key = "[required_depth]"
		if(!depth_buckets[depth_key])
			depth_buckets[depth_key] = list()
		depth_buckets[depth_key] += T
		if(T.width <= 6 && T.height <= 6)
			filler_templates_by_connection[key] += T

/datum/controller/subsystem/dungeon_generator/proc/get_candidate_templates(direction, max_depth)
	var/list/depth_buckets = templates_by_connection_and_depth[direction_key(direction)]
	var/list/candidates = list()
	for(var/depth in 1 to max_depth)
		var/list/bucket = depth_buckets["[depth]"]
		if(length(bucket))
			candidates += bucket
	return shuffle(candidates)

/datum/controller/subsystem/dungeon_generator/proc/finalize_loot_pool()
	if(loot_pool_finalized)
		return
	loot_pool_finalized = TRUE
	process_deferred_loot_pool("tomb_of_alotheos")
	// The very last room(s) placed via T.load() can still have spawners sitting
	// in SSatoms' LateInitialize queue (INITIALIZE_HINT_LATELOAD) when this
	// fires - they haven't been added to GLOB.loot_spawners_pending yet and get
	// missed by the sweep above. Retry once the queue has had time to drain.
	addtimer(CALLBACK(GLOBAL_PROC, .proc/process_deferred_loot_pool, "tomb_of_alotheos"), 3 SECONDS)

/datum/controller/subsystem/dungeon_generator/proc/finalize_generation()
	if(generation_complete)
		return
	finalize_loot_pool()
	generation_complete = TRUE
	markers.Cut()
	failed_markers.Cut()
	can_fire = FALSE

/datum/map_template/dungeon/proc/get_dir_offset(dir)
	switch(dir)
		if(NORTH) return north_offset
		if(SOUTH) return south_offset
		if(EAST) return east_offset
		if(WEST) return west_offset
	return null

/datum/controller/subsystem/dungeon_generator/proc/process_failed_markers(limit)
	var/processed = 0
	while(length(failed_markers) && processed < limit)
		var/obj/effect/dungeon_directional_helper/helper = failed_markers[1]
		failed_markers.Cut(1, 2)
		if(helper && !QDELETED(helper))
			// try_spawn_filler()'s return value used to be discarded and the marker qdel'd
			// unconditionally either way - a marker whose filler placement ALSO failed (same
			// can_place() constraints that failed its original growth attempt) just vanished
			// with nothing built and no further attempt, no new markers created to replace it.
			// With very few seed markers (the static "Dungeon Map" only places 4 - everything
			// else comes from room pieces spawning their own connector markers as they load),
			// losing even one or two of those 4 to a bad template roll can mean the entire
			// dungeon interior never gets seeded at all.
			if(!try_spawn_filler(helper.dir, get_turf(helper)))
				log_world("DUNGEON_DEBUG: try_spawn_filler FAILED for marker at [get_turf(helper)] dir=[helper.dir] - this seed is lost with nothing built there.")
			qdel(helper)
		processed++

/datum/controller/subsystem/dungeon_generator/proc/try_spawn_filler(direction, turf/target_turf)
	var/opp_dir = reverse_direction(direction)
	var/list/checking_list = shuffle(filler_templates_by_connection[direction_key(opp_dir)])
	
	for(var/datum/map_template/dungeon/T in checking_list)
		var/offset = T.get_dir_offset(opp_dir)
		if(offset == null) continue
		var/spawn_x = target_turf.x; var/spawn_y = target_turf.y
		if(direction == NORTH) spawn_x -= offset
		else if(direction == SOUTH) { spawn_x -= offset; spawn_y -= (T.height - 1); }
		else if(direction == EAST) spawn_y -= offset
		else if(direction == WEST) { spawn_x -= (T.width - 1); spawn_y -= offset; }

		var/turf/start_turf = locate(spawn_x, spawn_y, target_z)
		if(can_place(T, start_turf))
			if(T.load(start_turf))
				on_template_placed(T, start_turf)
				return TRUE
	return FALSE

#undef STAGE_EXPANSION
#undef STAGE_CLEANUP
