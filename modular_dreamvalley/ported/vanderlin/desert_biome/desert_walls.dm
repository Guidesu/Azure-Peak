// Ported from Vanderlin (E:\GitHub\Vanderlin\code\game\turfs\closed\wall\walls.dm).
//
// See desert_turfs.dm for the "Desert Town" scope investigation note - this is a delve
// dungeon-generator tileset, not a standalone town. Only wall/window structure defs
// are carried over; no jobs, factions, or NPCs.
//
// Adaptation notes:
// - Vanderlin builds these on /turf/closed/wall/mineral using SMOOTH_BITMASK smoothing
//   groups (SMOOTH_GROUP_*), which do not exist in this codebase at all. This repo's
//   analogous base is /turf/closed/wall/mineral/rogue, which uses the older
//   smooth = SMOOTH_TRUE/SMOOTH_FALSE/SMOOTH_MORE system instead.
// - Both desert_sandstone.dmi and desert_slopstone.dmi ship a static "wallformed" icon
//   state alongside their bitmask-directional states (this is exactly the fallback state
//   Vanderlin itself uses via MAP_SWITCH() when bitmask smoothing is off), so these are
//   defined here as simple non-smoothing (smooth = SMOOTH_FALSE) walls using that state -
//   no bitmask smoothing infrastructure needed.
// - "desert_soapstone" from the source was renamed to match its actual icon file,
//   desert_slopstone.dmi (the source's own file naming is inconsistent between the type
//   name "desert_soapstone" and the icon file "desert_slopstone.dmi"); kept as
//   /turf/closed/wall/mineral/rogue/desert_slopstone to avoid a misleading name here.

/turf/closed/wall/mineral/rogue/desert_sandstone
	name = "sandstone wall"
	desc = "A wall of sun-baked sandstone."
	icon = 'icons/delver/desert_sandstone.dmi'
	icon_state = "wallformed"
	smooth = SMOOTH_FALSE
	blade_dulling = DULLING_BASH
	max_integrity = 1800
	sheet_type = /obj/item/natural/stone
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	above_floor = /turf/open/floor/rogue/sandstone_tile

/turf/closed/wall/mineral/rogue/desert_sandstone/window
	name = "sandstone murder hole"
	desc = "A wall of sandstone with a convenient small indent, perfect to let loose arrows against invaders."
	icon_state = "wallformed"
	opacity = FALSE
	max_integrity = 900
	var/window_state = "window_open"

/turf/closed/wall/mineral/rogue/desert_sandstone/window/Initialize()
	. = ..()
	add_overlay(mutable_appearance('icons/delver/desert_objects.dmi', window_state, layer = ABOVE_NORMAL_TURF_LAYER))

/turf/closed/wall/mineral/rogue/desert_sandstone/window/brass
	window_state = "window_brass"

/turf/closed/wall/mineral/rogue/desert_slopstone
	name = "soapstone wall"
	desc = "A wall of smooth, waxy soapstone."
	icon = 'icons/delver/desert_slopstone.dmi'
	icon_state = "wallformed"
	smooth = SMOOTH_FALSE
	blade_dulling = DULLING_BASH
	max_integrity = 1800
	sheet_type = /obj/item/natural/stone
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	above_floor = /turf/open/floor/rogue/sandstone_tile
