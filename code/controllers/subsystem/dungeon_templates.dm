/// Dungeon template datum definitions.
///
/// Each datum maps to a .dmm file in _maps/dungeon_generator/ and declares
/// its connection offsets so the generator knows where doorways are.
///
/// Offset convention (0-based from the template's edge):
///   north_offset / south_offset: x-position of the doorway on that edge
///   east_offset  / west_offset:  y-position of the doorway on that edge
///   null = no connection on that edge
///
/// All room templates are 30x30 (centered offset = 15) except sewers (15x15, offset = 7).
/// The hallway is 10x4 (east/west offset = 1).

// ============================================================================
// Hallway templates
// ============================================================================

/datum/map_template/dungeon/hallway
	name = "stone hallway"
	mappath = "_maps/dungeon_generator/hallway/Malphpiece5.dmm"
	is_hallway = TRUE
	biome = "crypt"
	depth_tier = 0
	type_weight = 20
	// 10 wide, 4 tall — doorway centered on the 4-tall edge
	east_offset = 1
	west_offset = 1
	north_offset = null
	south_offset = null

// ============================================================================
// Room templates — 30x30 (offset 15 for centered connections)
// ============================================================================

/datum/map_template/dungeon/room/town_ruins
	name = "ruined town"
	mappath = "_maps/dungeon_generator/room/TownRuins.dmm"
	biome = "ruins"
	depth_tier = 0
	type_weight = 15
	north_offset = 15
	south_offset = 15
	east_offset = 15
	west_offset = 15

/datum/map_template/dungeon/room/small_church
	name = "abandoned church"
	mappath = "_maps/dungeon_generator/room/SmallChurch.dmm"
	biome = "crypt"
	depth_tier = 1
	type_weight = 12
	north_offset = 15
	south_offset = 15
	east_offset = 15
	west_offset = 15

/datum/map_template/dungeon/room/rouse_camp
	name = "rouse camp"
	mappath = "_maps/dungeon_generator/room/rousecamp.dmm"
	biome = "lair"
	depth_tier = 1
	type_weight = 10
	north_offset = 15
	south_offset = 15
	east_offset = 15
	west_offset = 15

/datum/map_template/dungeon/room/hc_tomb
	name = "burial tomb"
	mappath = "_maps/dungeon_generator/room/hctomb2.dmm"
	biome = "crypt"
	depth_tier = 2
	type_weight = 12
	north_offset = 15
	south_offset = 15
	east_offset = 15
	west_offset = 15

/datum/map_template/dungeon/room/queens_retreat
	name = "queen's retreat"
	mappath = "_maps/dungeon_generator/room/queensretreat.dmm"
	biome = "ruins"
	depth_tier = 2
	type_weight = 8
	north_offset = 15
	south_offset = 15
	east_offset = 15
	west_offset = 15

// ============================================================================
// Room templates — 15x15 (offset 7 for centered connections)
// ============================================================================

/datum/map_template/dungeon/room/sewers
	name = "flooded sewers"
	mappath = "_maps/dungeon_generator/room/sewers.dmm"
	biome = "sewer"
	depth_tier = 0
	type_weight = 15
	north_offset = 7
	south_offset = 7
	east_offset = 7
	west_offset = 7
