/// Multi-biome procedural dungeon generation.
///
/// Inspired by Dungeon Meshi and deep-maint SS13 dungeons, this system
/// extends the template-based dungeon_generator with:
///
///   1. Depth-based biome layers — the deeper you go, the more dangerous
///      and different the environment becomes.
///   2. Procedural room generation — rooms can be generated on-the-fly
///      with biome-specific turfs, walls, loot, and mobs, not just from
///      pre-made .dmm templates.
///   3. Biome transitions — hallways between biomes visually shift
///      (e.g. crypt stone -> natural cave -> volcanic rock).
///
/// Biome layers (shallow to deep):
///   Layer 0: "ruins"     — collapsed buildings, wood/stone floors
///   Layer 1: "crypt"     — ancient burial chambers, hexstone
///   Layer 2: "cave"      — natural caverns, dirt/rock, underground water
///   Layer 3: "sewer"     — flooded corridors, metal grates, pipes
///   Layer 4: "lair"      — monster nests, volcanic rock, lava
///   Layer 5: "treasure"  — the deepest vault, guarded, richest loot

// ============================================================================
// Biome definitions
// ============================================================================

/datum/dungeon_biome
	var/name = "biome"
	/// Floor turf type for this biome
	var/floor_type = /turf/open/floor/rogue/hexstone
	/// Wall turf type for this biome
	var/wall_type = /turf/closed/wall/mineral/rogue/stone
	/// Area type for this biome
	var/area_type = /area/rogue/under/tomb
	/// Loot spawner types to scatter in procedural rooms (weighted)
	var/list/loot_spawners = list()
	/// Mob types to spawn in procedural rooms (weighted)
	var/list/mobs = list()
	/// Ambient sound for this biome
	var/ambient_sound = null
	/// Droning music for this biome
	var/droning_sound = null
	/// Minimum depth (in rooms from entrance) for this biome to appear
	var/min_depth = 0
	/// Maximum depth for this biome to appear
	var/max_depth = 100
	/// Relative weight for biome selection at a given depth
	var/weight = 10

/datum/dungeon_biome/ruins
	name = "ruins"
	floor_type = /turf/open/floor/rogue/ruinedwood
	wall_type = /turf/closed/wall/mineral/rogue/wooddark
	area_type = /area/rogue/under/tomb/ruins
	ambient_sound = AMB_GENCAVE
	droning_sound = 'sound/music/area/dungeon2.ogg'
	min_depth = 0
	max_depth = 3
	weight = 20
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_low = 5,
		/obj/effect/spawner/lootdrop/general_loot_mid = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/misc = 4,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/food = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/clothing = 2,
	)
	mobs = list(
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 10,
		/mob/living/carbon/human/species/skeleton/npc/ambush = 5,
		/mob/living/carbon/human/species/goblin/npc/ambush = 3,
	)

/datum/dungeon_biome/crypt
	name = "crypt"
	floor_type = /turf/open/floor/rogue/hexstone
	wall_type = /turf/closed/wall/mineral/rogue/stone
	area_type = /area/rogue/under/tomb/crypt
	ambient_sound = AMB_GENCAVE
	droning_sound = 'sound/music/area/dungeon2.ogg'
	min_depth = 1
	max_depth = 5
	weight = 15
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_mid = 4,
		/obj/effect/spawner/lootdrop/general_loot_hi = 2,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/weapons = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/armor = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/medical = 4,
		/obj/effect/spawner/lootdrop/valuable_candle_spawner = 2,
	)
	mobs = list(
		/mob/living/carbon/human/species/skeleton/npc/ambush = 10,
		/mob/living/carbon/human/species/skeleton/npc/mediumspread = 5,
		/mob/living/carbon/human/species/skeleton/npc/hardspread = 2,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 5,
	)

/datum/dungeon_biome/cave
	name = "cave"
	floor_type = /turf/open/floor/rogue/dirt
	wall_type = /turf/closed/mineral/rogue
	area_type = /area/rogue/under/tomb/cave
	ambient_sound = AMB_GENCAVE
	droning_sound = 'sound/music/area/decap.ogg'
	min_depth = 2
	max_depth = 7
	weight = 15
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_mid = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/materials = 5,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/misc = 3,
		/obj/effect/spawner/lootdrop/random_gem = 2,
	)
	mobs = list(
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/spider = 5,
		/mob/living/carbon/human/species/skeleton/npc/ambush = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar = 2,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf = 2,
	)

/datum/dungeon_biome/sewer
	name = "sewer"
	floor_type = /turf/open/floor/rogue/hexstone
	wall_type = /turf/closed/wall/mineral/rogue/pipe
	area_type = /area/rogue/under/tomb/sewer
	ambient_sound = AMB_BEACH
	droning_sound = 'sound/music/area/dungeon2.ogg'
	min_depth = 3
	max_depth = 8
	weight = 10
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_low = 4,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/food = 5,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/misc = 4,
		/obj/effect/spawner/lootdrop/cheap_clutter_spawner = 3,
	)
	mobs = list(
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 15,
		/mob/living/carbon/human/species/goblin/npc/ambush/sea = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/spider = 3,
	)

/datum/dungeon_biome/lair
	name = "lair"
	floor_type = /turf/open/floor/rogue/volcanic
	wall_type = /turf/closed/mineral/rogue
	area_type = /area/rogue/under/tomb/lair
	ambient_sound = AMB_CAVELAVA
	droning_sound = 'sound/music/area/dragonden.ogg'
	min_depth = 5
	max_depth = 100
	weight = 12
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_hi = 4,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/weapons = 3,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/armor = 3,
		/obj/effect/spawner/lootdrop/random_gem = 3,
		/obj/effect/spawner/lootdrop/valuable_jewelry_spawner = 2,
	)
	mobs = list(
		/mob/living/carbon/human/species/skeleton/npc/hardspread = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/minotaur = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/troll = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 5,
	)

/datum/dungeon_biome/treasure
	name = "treasure vault"
	floor_type = /turf/open/floor/rogue/hexstone
	wall_type = /turf/closed/wall/mineral/rogue/stonebrick
	area_type = /area/rogue/under/tomb/treasure
	ambient_sound = AMB_GENCAVE
	droning_sound = 'sound/music/area/dragonden.ogg'
	min_depth = 7
	max_depth = 100
	weight = 5
	loot_spawners = list(
		/obj/effect/spawner/lootdrop/general_loot_hi = 5,
		/obj/effect/spawner/lootdrop/valuable_jewelry_spawner = 4,
		/obj/effect/spawner/lootdrop/valuable_clutter_spawner = 3,
		/obj/effect/spawner/lootdrop/random_gem = 4,
		/obj/effect/spawner/lootdrop/roguetown/dungeon/spells = 2,
	)
	mobs = list(
		/mob/living/carbon/human/species/skeleton/npc/hardspread = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/minotaur = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/troll = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/dragon = 1,
	)

// ============================================================================
// Biome manager — tracks depth and selects biomes
// ============================================================================

/datum/dungeon_biome_manager
	var/list/biomes = list()
	var/list/biome_by_depth = list()
	/// Maps turf coordinates to depth values for tracking
	var/list/depth_map = list()
	/// Current maximum depth reached
	var/max_depth_reached = 0

/datum/dungeon_biome_manager/New()
	for(var/bt in subtypesof(/datum/dungeon_biome))
		var/datum/dungeon_biome/B = new bt
		biomes[B.type] = B

/// Get the appropriate biome for a given depth (number of rooms from entrance)
/datum/dungeon_biome_manager/proc/get_biome_for_depth(depth)
	var/list/candidates = list()
	for(var/bt in biomes)
		var/datum/dungeon_biome/B = biomes[bt]
		if(depth >= B.min_depth && depth <= B.max_depth)
			candidates[B] = B.weight
	if(!length(candidates))
		// Fallback to the deepest available biome
		var/datum/dungeon_biome/fallback = biomes[/datum/dungeon_biome/crypt]
		return fallback
	return pickweight(candidates)

/// Get a biome by name
/datum/dungeon_biome_manager/proc/get_biome(name)
	for(var/bt in biomes)
		var/datum/dungeon_biome/B = biomes[bt]
		if(B.name == name)
			return B
	return null

// ============================================================================
// Procedural room generation
// ============================================================================

/// Generate a procedural room at the given turf with the given biome and dimensions.
/// This creates a room on-the-fly without a .dmm template.
/proc/generate_procedural_room(turf/center, datum/dungeon_biome/biome, width = 15, height = 15, depth = 0)
	if(!center || !biome)
		return FALSE

	var/start_x = center.x - round(width / 2)
	var/start_y = center.y - round(height / 2)
	var/z = center.z

	if(start_x < 1 || start_y < 1 || start_x + width > world.maxx || start_y + height > world.maxy)
		return FALSE

	// Carve the room — replace void/walls with floor
	for(var/tx in start_x to start_x + width - 1)
		for(var/ty in start_y to start_y + height - 1)
			var/turf/T = locate(tx, ty, z)
			if(!T)
				continue
			// Border becomes wall, interior becomes floor
			var/is_border = (tx == start_x || tx == start_x + width - 1 || ty == start_y || ty == start_y + height - 1)
			if(is_border)
				if(!istype(T, biome.floor_type) && !istype(T, biome.wall_type))
					T.ChangeTurf(biome.wall_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)
			else
				T.ChangeTurf(biome.floor_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)

	// Change the area for the interior
	var/area/biome_area = locate(biome.area_type)
	if(!biome_area)
		biome_area = new biome.area_type
	for(var/tx in start_x + 1 to start_x + width - 2)
		for(var/ty in start_y + 1 to start_y + height - 2)
			var/turf/T = locate(tx, ty, z)
			if(T && istype(T, biome.floor_type))
				biome_area.contents += T

	// Scatter loot spawners in the room
	if(length(biome.loot_spawners))
		var/loot_count = rand(2, 5)
		for(var/i in 1 to loot_count)
			var/loot_type = pickweight(biome.loot_spawners)
			var/lx = rand(start_x + 2, start_x + width - 3)
			var/ly = rand(start_y + 2, start_y + height - 3)
			var/turf/LT = locate(lx, ly, z)
			if(LT && !LT.density)
				new loot_type(LT)

	// Spawn mobs
	if(length(biome.mobs))
		var/mob_count = rand(1, 4)
		for(var/i in 1 to mob_count)
			var/mob_type = pickweight(biome.mobs)
			var/mx = rand(start_x + 2, start_x + width - 3)
			var/my = rand(start_y + 2, start_y + height - 3)
			var/turf/MT = locate(mx, my, z)
			if(MT && !MT.density)
				new mob_type(MT)

	// Place a loot chest in deeper rooms
	if(depth >= 3 && prob(30))
		var/chest_type = /obj/structure/closet/crate/chest/loot_chest
		if(depth >= 5 && prob(40))
			chest_type = /obj/structure/closet/crate/chest/loot_chest/locked
		var/cx = start_x + round(width / 2)
		var/cy = start_y + round(height / 2)
		var/turf/CT = locate(cx, cy, z)
		if(CT && !CT.density)
			new chest_type(CT)

	return TRUE

/// Generate a procedural hallway between two points with the given biome.
/proc/generate_procedural_hallway(turf/start, turf/end, datum/dungeon_biome/biome, width = 3)
	if(!start || !end || !biome)
		return FALSE

	var/z = start.z
	var/sx = start.x
	var/sy = start.y
	var/ex = end.x
	var/ey = end.y

	// L-shaped hallway: horizontal first, then vertical
	var/mid_x = ex
	var/mid_y = sy

	// Horizontal segment
	var/min_x = min(sx, mid_x)
	var	max_x = max(sx, mid_x)
	for(var/tx in min_x to max_x)
		for(var/ty in mid_y - round(width/2) to mid_y + round(width/2))
			var/turf/T = locate(tx, ty, z)
			if(T)
				var/is_border = (ty == mid_y - round(width/2) || ty == mid_y + round(width/2))
				if(is_border)
					if(!istype(T, biome.floor_type))
						T.ChangeTurf(biome.wall_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)
				else
					T.ChangeTurf(biome.floor_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)

	// Vertical segment
	var/min_y = min(mid_y, ey)
	var	max_y = max(mid_y, ey)
	for(var/ty in min_y to max_y)
		for(var/tx in ex - round(width/2) to ex + round(width/2))
			var/turf/T = locate(tx, ty, z)
			if(T)
				var/is_border = (tx == ex - round(width/2) || tx == ex + round(width/2))
				if(is_border)
					if(!istype(T, biome.floor_type))
						T.ChangeTurf(biome.wall_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)
				else
					T.ChangeTurf(biome.floor_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)

	return TRUE

// ============================================================================
// Enhanced dungeon generator with biome support
// ============================================================================

/datum/controller/subsystem/dungeon_generator/proc/init_biome_manager()
	if(!biome_manager)
		biome_manager = new()

/// Get the depth for a marker based on how far it is from the entrance
/datum/controller/subsystem/dungeon_generator/proc/get_marker_depth(obj/effect/dungeon_directional_helper/helper)
	if(!helper)
		return 0
	if(marker_depth[helper])
		return marker_depth[helper]
	return 0

/// Try to generate a procedural room at a marker location
/datum/controller/subsystem/dungeon_generator/proc/try_procedural_room(obj/effect/dungeon_directional_helper/helper)
	if(!use_procedural_generation || !helper)
		return FALSE

	init_biome_manager()
	var/depth = get_marker_depth(helper)
	var/datum/dungeon_biome/biome = biome_manager.get_biome_for_depth(depth)
	if(!biome)
		return FALSE

	var/turf/origin = get_turf(helper)
	var/direction = helper.dir
	var/turf/start_step = get_step(origin, direction)
	if(!start_step)
		return FALSE

	// Find a suitable area for the room
	var/room_size = pick(11, 13, 15, 17)
	var/center_x = start_step.x
	var/center_y = start_step.y

	// Offset center in the growth direction
	if(direction == NORTH) center_y += round(room_size / 2)
	else if(direction == SOUTH) center_y -= round(room_size / 2)
	else if(direction == EAST) center_x += round(room_size / 2)
	else if(direction == WEST) center_x -= round(room_size / 2)

	var/turf/center = locate(center_x, center_y, target_z)
	if(!center)
		return FALSE

	// Check if the area is free (all void)
	var/start_x = center.x - round(room_size / 2)
	var/start_y = center.y - round(room_size / 2)
	for(var/tx in start_x to start_x + room_size - 1)
		for(var/ty in start_y to start_y + room_size - 1)
			var/turf/T = locate(tx, ty, target_z)
			if(!T || (!is_strictly_void(T) && !istype(T, /turf/closed/mineral/rogue/bedrock)))
				return FALSE
			if(is_protected(tx, ty))
				return FALSE

	// Generate the room
	if(!generate_procedural_room(center, biome, room_size, room_size, depth))
		return FALSE

	// Record the biome
	room_biomes[center] = biome.name
	if(depth > max_depth_reached)
		max_depth_reached = depth

	// Create new directional helpers at the room edges for further growth
	var/edge_depth = depth + 1
	var/half = round(room_size / 2)
	// North edge
	var/turf/north_edge = locate(center.x, center.y + half, target_z)
	if(north_edge && !is_protected(north_edge.x, north_edge.y))
		var/obj/effect/dungeon_directional_helper/N = new /obj/effect/dungeon_directional_helper/north(north_edge)
		marker_depth[N] = edge_depth
		markers |= N
	// South edge
	var/turf/south_edge = locate(center.x, center.y - half, target_z)
	if(south_edge && !is_protected(south_edge.x, south_edge.y))
		var/obj/effect/dungeon_directional_helper/S = new /obj/effect/dungeon_directional_helper/south(south_edge)
		marker_depth[S] = edge_depth
		markers |= S
	// East edge
	var/turf/east_edge = locate(center.x + half, center.y, target_z)
	if(east_edge && !is_protected(east_edge.x, east_edge.y))
		var/obj/effect/dungeon_directional_helper/E = new /obj/effect/dungeon_directional_helper/east(east_edge)
		marker_depth[E] = edge_depth
		markers |= E
	// West edge
	var/turf/west_edge = locate(center.x - half, center.y, target_z)
	if(west_edge && !is_protected(west_edge.x, west_edge.y))
		var/obj/effect/dungeon_directional_helper/W = new /obj/effect/dungeon_directional_helper/west(west_edge)
		marker_depth[W] = edge_depth
		markers |= W

	// Carve a doorway in the wall facing the origin
	var/turf/door_turf = get_step(origin, direction)
	if(door_turf && door_turf.density)
		door_turf.ChangeTurf(biome.floor_type, null, CHANGETURF_INHERIT_AIR | CHANGETURF_IGNORE_AIR)

	qdel(helper)
	return TRUE

/// Override try_grow_at_marker to add procedural generation chance
/datum/controller/subsystem/dungeon_generator/try_grow_at_marker(obj/effect/dungeon_directional_helper/helper)
	if(!helper)
		return FALSE

	// Try procedural generation first
	if(use_procedural_generation && prob(procedural_room_chance))
		if(try_procedural_room(helper))
			return TRUE

	// Fall back to template-based generation
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
				// Track depth for templates too — spawn new markers with incremented depth
				var/depth = get_marker_depth(helper)
				room_biomes[placement] = T.biome
				if(depth > max_depth_reached)
					max_depth_reached = depth
				qdel(helper)
				return TRUE
		CHECK_TICK
	return FALSE

/// Override on_template_placed to track depth of new markers from templates
/datum/controller/subsystem/dungeon_generator/on_template_placed(datum/map_template/dungeon/T, turf/placement)
	placed_count[T.type]++
	// Find any new directional helpers that were spawned by the template
	// and assign them depth based on the current generation context
	for(var/obj/effect/dungeon_directional_helper/H in range(T.width, placement))
		if(!marker_depth[H])
			marker_depth[H] = max_depth_reached + 1
