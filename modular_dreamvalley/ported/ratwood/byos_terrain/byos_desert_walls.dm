/turf/closed/wall/mineral/rogue/sandbrick
	name = "sandbrick wall"
	desc = "A wall of smooth, unyielding bricks."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/sandbrick_wall.dmi'
	icon_state = "sandbrick"
	smooth = SMOOTH_MORE
	blade_dulling = DULLING_BASH
	max_integrity = 1800
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	canSmoothWith = list(/turf/closed/wall/mineral/rogue/sandbrick)
	neighborlay = "dirtedge"
	climbdiff = 3
	damage_deflection = 10
	hardness = 3

/turf/closed/mineral/rogue/sandstone
	name = "sandstone"
	desc = "Dusty, sand-blasted rock."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/rock.dmi'
	icon_state = "wallformed"
	smooth = SMOOTH_TRUE | SMOOTH_MORE
	smooth_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/rock.dmi'
	canSmoothWith = list(/turf/closed/mineral/random/rogue/sandstone, /turf/closed/mineral/rogue/sandstone)
	turf_type = /turf/open/floor/rogue/naturalstone/sandstone
	baseturfs = /turf/open/floor/rogue/naturalstone/sandstone
	above_floor = /turf/open/floor/rogue/naturalstone/sandstone

/turf/closed/mineral/rogue/bedrock/sandstone
	name = "sandstone"
	desc = "Seems barren and nigh-indestructable"
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/rock.dmi'
	icon_state = "bedrock"
	above_floor = /turf/closed/mineral/rogue/bedrock

/turf/closed/mineral/random/rogue/sandstone
	name = "sandstone"
	desc = "Dusty, sand-blasted rock."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/rock.dmi'
	icon_state = "minlow"
	smooth = SMOOTH_TRUE | SMOOTH_MORE
	smooth_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/rock.dmi'
	canSmoothWith = list(/turf/closed/mineral/random/rogue/sandstone, /turf/closed/mineral/rogue/sandstone)
	turf_type = /turf/open/floor/rogue/naturalstone/sandstone
	baseturfs = /turf/open/floor/rogue/naturalstone/sandstone
	above_floor = /turf/open/floor/rogue/naturalstone/sandstone
	mineralSpawnChanceList = list(
		/turf/closed/mineral/rogue/sandstone/salt = 5,
		/turf/closed/mineral/rogue/sandstone/iron = 15,
		/turf/closed/mineral/rogue/sandstone/coal = 25)

/turf/closed/mineral/rogue/sandstone/salt
	icon_state = "mingold"
	mineralType = /obj/item/reagent_containers/powder/salt
	rockType = /obj/item/natural/rock/salt
	spreadChance = 33
	spread = 15

/turf/closed/mineral/rogue/sandstone/iron
	icon_state = "mingold"
	mineralType = /obj/item/rogueore/iron
	rockType = /obj/item/natural/rock/iron
	spreadChance = 23
	spread = 5

/turf/closed/mineral/rogue/sandstone/coal
	icon_state = "mingold"
	mineralType = /obj/item/rogueore/coal
	rockType = /obj/item/natural/rock/coal
	spreadChance = 33
	spread = 11

/turf/closed/mineral/rogue/sandstone/gem
	icon_state = "mingold"
	mineralType = /obj/item/roguegem/random
	rockType = /obj/item/natural/rock/gem
	spreadChance = 3
	spread = 2

/turf/closed/mineral/random/rogue/sandstone/med
	icon_state = "minmed"
	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/rogue/sandstone/salt = 5,
		/turf/closed/mineral/rogue/sandstone/iron = 33,
		/turf/closed/mineral/rogue/sandstone/coal = 14,
		/turf/closed/mineral/rogue/sandstone/gem = 1)

/turf/closed/mineral/random/rogue/sandstone/high
	icon_state = "minhigh"
	mineralChance = 33
	mineralSpawnChanceList = list(
		/turf/closed/mineral/rogue/sandstone/salt = 5,
		/turf/closed/mineral/rogue/sandstone/iron = 33,
		/turf/closed/mineral/rogue/sandstone/coal = 19,
		/turf/closed/mineral/rogue/sandstone/gem = 3)
