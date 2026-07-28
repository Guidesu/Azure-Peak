// Ported from Vanderlin (E:\GitHub\Vanderlin\code\game\turfs\open\floor\roguefloor.dm).
//
// Source note: in Vanderlin these tiles live under a "delver" icon folder and are used as
// building blocks for the procedural dungeon/delve generator's desert biome, not a
// standalone "Desert Town" map. There is no dedicated desert town room template to port -
// see desert_biome/README context in the porting log. This file carries over only the
// plain floor-tile definitions (sand, sandstone tile, cracked earth); no jobs, factions,
// or NPCs are included.
//
// Adaptation notes:
// - Vanderlin's /turf/open/floor/sand/desert used a Vanderlin-only /obj/item/natural/clod/sand
//   pickup item on secondary-attack. That item type does not exist in this codebase, so the
//   pickup behavior was dropped; the tile is purely decorative here.
// - Vanderlin's SMOOTH_GROUP_* bitmask smoothing system does not exist in this codebase
//   (this repo uses the older smooth = SMOOTH_TRUE/SMOOTH_FALSE/SMOOTH_MORE system), so
//   smoothing_groups/smoothing_flags were dropped. cracked_earth keeps a light random
//   dir-based visual jitter, matching the source's Initialize() ChoicePick of GLOB.cardinals.
// - Base class is /turf/open/floor/rogue (this repo's base open floor), not Vanderlin's
//   /turf/open/floor.

/turf/open/floor/rogue/sand/desert
	name = "sand"
	desc = "Warm sand that, sadly, have been mixed with dirt."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "sand-1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/grassland.wav'
	slowdown = 0
	var/randomized = TRUE

/turf/open/floor/rogue/sand/desert/Initialize()
	. = ..()
	if(randomized)
		icon_state = "sand-[rand(1, 12)]"

/turf/open/floor/rogue/sand/desert/static
	randomized = FALSE

/turf/open/floor/rogue/sandstone_tile
	name = "sandstone floor"
	desc = "Flooring hewn from sandstone blocks."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "sandstonefloor-1"
	footstep = FOOTSTEP_STONE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/stoneland.wav'

/turf/open/floor/rogue/sandstone_tile/two
	icon_state = "sandstonefloor-2"

/turf/open/floor/rogue/sandstone_tile/three
	icon_state = "sandstonefloor-3"

/turf/open/floor/rogue/sandstone_tile/four
	icon_state = "sandstonefloor-4"

/turf/open/floor/rogue/sandstone_tile/five
	icon_state = "sandstonefloor-5"

/turf/open/floor/rogue/sandstone_tile/six
	icon_state = "sandstonefloor-6"

/turf/open/floor/rogue/cracked_earth
	name = "cracked earth"
	desc = "Dry, sun-baked earth, cracked into a mosaic by the heat."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "cracked_earth"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/dirtland.wav'

/turf/open/floor/rogue/cracked_earth/Initialize(mapload)
	. = ..()
	dir = pick(GLOB.cardinals)
