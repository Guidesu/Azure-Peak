/// Dungeon framework core definitions.
///
/// This file defines the missing pieces that the dungeon_generator subsystem
/// (code/controllers/subsystem/dungeon_generator.dm) depends on:
///
///   - /turf/closed/dungeon_void: the "empty" turf that rooms replace
///   - /obj/effect/dungeon_directional_helper: markers that seed room growth
///   - /datum/map_template/dungeon: base template type with connection offsets
///   - /area/rogue/under/tomb: the dungeon area used by .dmm templates
///
/// Without these, the generator's subtypesof() calls return empty lists and
/// the dungeon never generates.

// ============================================================================
// Void turf — the "nothing" that dungeon rooms carve out of
// ============================================================================

/turf/closed/dungeon_void
	name = "void"
	desc = "The dungeon has not yet reached here."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "rockyashbed"
	density = TRUE
	opacity = TRUE
	/// Prevents mining/tunneling into void before generation fills it.
	max_integrity = 10000000
	damage_deflection = 99999999

/turf/closed/dungeon_void/attackby(obj/item/I, mob/user, params)
	return FALSE

/turf/closed/dungeon_void/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/dungeon_void/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/closed/dungeon_void/Melt()
	to_be_destroyed = FALSE
	return src

// ============================================================================
// Directional helper — marker object placed in the dungeon .dmm map
// ============================================================================

/obj/effect/dungeon_directional_helper
	name = "dungeon marker"
	desc = "Marks a direction for dungeon generation to expand."
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE
	/// Direction in which generation should expand from this marker.
	/// Set by subtypes or by the map.
	var/spawn_dir = null

/obj/effect/dungeon_directional_helper/Initialize(mapload)
	. = ..()
	if(spawn_dir)
		dir = spawn_dir
	else if(dir)
		spawn_dir = dir

/obj/effect/dungeon_directional_helper/north
	name = "dungeon marker (north)"
	spawn_dir = NORTH

/obj/effect/dungeon_directional_helper/south
	name = "dungeon marker (south)"
	spawn_dir = SOUTH

/obj/effect/dungeon_directional_helper/east
	name = "dungeon marker (east)"
	spawn_dir = EAST

/obj/effect/dungeon_directional_helper/west
	name = "dungeon marker (west)"
	spawn_dir = WEST

// ============================================================================
// Dungeon map template — base type for room/hallway templates
// ============================================================================

/datum/map_template/dungeon
	/// Weight for how often this template type is selected (higher = more common).
	var/type_weight = 10
	/// Connection offsets: where on each edge the "doorway" is.
	/// null = no connection on that edge.
	/// For NORTH/SOUTH: x-offset from the left edge (0-based).
	/// For EAST/WEST: y-offset from the bottom edge (0-based).
	var/north_offset = null
	var/south_offset = null
	var/east_offset = null
	var/west_offset = null
	/// Biome tag — used by the multi-biome generator to group templates.
	/// Examples: "crypt", "cave", "sewer", "ruins", "lair"
	var/biome = "crypt"
	/// Depth tier — controls how deep in the dungeon this template can appear.
	/// 0 = any depth, 1 = shallow, 2 = mid, 3 = deep
	var/depth_tier = 0
	/// If TRUE, this template is a hallway/corridor rather than a room.
	var/is_hallway = FALSE

/// Entry template — the starting room of the dungeon.
/// This is excluded from normal generation (see Initialize() in dungeon_generator.dm).
/datum/map_template/dungeon/entry
	abstract_type = /datum/map_template/dungeon/entry

// ============================================================================
// Tomb area — used by the dungeon .dmm template files
// ============================================================================

/area/rogue/under/tomb
	name = "tomb"
	icon_state = "tomb"
	droning_sound = 'sound/music/area/dungeon2.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ambientsounds = AMB_GENCAVE
	ambientnight = AMB_GENCAVE
	spookysounds = SPOOKY_CAVE
	spookynight = SPOOKY_CAVE
	ceiling_protected = TRUE
	loot_budget = LOOT_BUDGET_NECRAN_LABYRINTH
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/indoors
	name = "tomb interior"
	icon_state = "tomb_i"

// ============================================================================
// Multi-biome area definitions
// ============================================================================

/area/rogue/under/tomb/crypt
	name = "ancient crypt"
	icon_state = "crypt"
	ambientsounds = AMB_GENCAVE
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/cave
	name = "caverns"
	icon_state = "cave"
	ambientsounds = AMB_GENCAVE
	droning_sound = 'sound/music/area/decap.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/sewer
	name = "flooded sewers"
	icon_state = "sewer"
	ambientsounds = AMB_BEACH
	droning_sound = 'sound/music/area/dungeon2.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/ruins
	name = "sunken ruins"
	icon_state = "ruins"
	ambientsounds = AMB_GENCAVE
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/lair
	name = "monster lair"
	icon_state = "lair"
	ambientsounds = SPOOKY_CAVE
	droning_sound = 'sound/music/area/dragonden.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/treasure
	name = "treasure vault"
	icon_state = "treasure"
	loot_budget = LOOT_BUDGET_LICH_ARENA
	loot_pool_key = "tomb_of_alotheos"
	ceiling_protected = TRUE
