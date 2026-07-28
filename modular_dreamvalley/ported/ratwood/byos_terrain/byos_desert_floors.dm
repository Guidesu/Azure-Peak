/turf/open/floor/rogue/dunes
	name = "sand"
	desc = "Its course and rough, and it gets everywhere."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/desertfloor.dmi'
	icon_state = "dune1"
	footstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	landsound = 'sound/foley/jumpland/dirtland.wav'
	smooth = SMOOTH_TRUE
	canSmoothWith = list(
						/turf/open/floor/rogue/grass,
						/turf/open/floor/rogue/desert_grass,
						/turf/open/floor/rogue/dirt,
						/turf/open/floor/rogue/dirt/road,
						/turf/open/floor/rogue/dirt/desert,
						/turf/open/floor/rogue/dirt/road/desert,
						/turf/open/floor/rogue/cobble,
						/turf/open/floor/rogue/cobblerock,
						/turf/open/floor/rogue/cobble/mossy,
						/turf/open/floor/rogue/grassred,
						/turf/open/floor/rogue/grassyel,
						/turf/open/floor/rogue/grasscold,
						/turf/open/floor/rogue/grasspurple,
						/turf/open/floor/rogue/snowpatchy,
						/turf/open/floor/rogue/snow,
						/turf/open/floor/rogue/snowrough,)

/turf/open/floor/rogue/dunes/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/floor/rogue/dunes/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	icon_state = "dune[rand(1,16)]"

/turf/open/floor/rogue/grasspurple
	name = "fungal 'grass'"
	desc = "Thin fungal strands rising from the ground. Spongey to walk on."
	icon_state = "grass_purple"
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	landsound = 'sound/foley/jumpland/grassland.wav'
	slowdown = 0
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/open/floor/rogue/grassred,
						/turf/open/floor/rogue/grassyel,
						/turf/open/floor/rogue/grasscold,
						/turf/open/floor/rogue/snowpatchy,
						/turf/open/floor/rogue/snow,
						/turf/open/floor/rogue/snowrough,)
	neighborlay = "grass_purpleedge"

/turf/open/floor/rogue/grasspurple/Initialize(mapload)
	dir = pick(GLOB.cardinals)
	. = ..()

/turf/open/floor/rogue/grasspurple/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/floor/rogue/desert_grass
	name = "desert grass"
	desc = "Grass, barely."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/desertfloor.dmi'
	icon_state = "desertgrass"
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_SOFT_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	landsound = 'sound/foley/jumpland/grassland.wav'
	slowdown = 0
	smooth = SMOOTH_TRUE
	canSmoothWith = list(
						/turf/open/floor/rogue/grass,
						/turf/open/floor/rogue/dunes,
						/turf/open/floor/rogue/dirt,
						/turf/open/floor/rogue/dirt/road,
						/turf/open/floor/rogue/dirt/desert,
						/turf/open/floor/rogue/dirt/road/desert,
						/turf/open/floor/rogue/grassred,
						/turf/open/floor/rogue/grassyel,
						/turf/open/floor/rogue/grasscold,
						/turf/open/floor/rogue/grasspurple,
						/turf/open/floor/rogue/snowpatchy,
						/turf/open/floor/rogue/snow,
						/turf/open/floor/rogue/snowrough,
						/turf/open/floor/rogue/cobble,
						/turf/open/floor/rogue/cobblerock,
						/turf/open/floor/rogue/cobble/mossy,)
	spread_chance = 15
	burn_power = 6

/turf/open/floor/rogue/desert_grass/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)

/turf/open/floor/rogue/desert_grass/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/floor/rogue/desert_grass/turf_destruction(damage_flag)
	. = ..()
	src.ChangeTurf(/turf/open/floor/rogue/dirt/desert, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rogue/desert_grass/nospawn

/turf/open/floor/rogue/dirt/desert
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/desertfloor.dmi'

/turf/open/floor/rogue/dirt/desert/nospawn

/turf/open/floor/rogue/dirt/road/desert
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/desertfloor.dmi'

/turf/open/floor/rogue/naturalstone/sandstone
	name = "rough sandstone ground"
	desc = "Rough sandstone that's been exposed to the air either through erosion or the swing of a pickaxe. Dust wisps through the cracks."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/desertfloor.dmi'
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/open/floor/rogue,
						/turf/closed/mineral,
						/turf/closed/wall/mineral)

//Healing springs.
/turf/open/water/ocean/deep/thermalwater
	name = "healing hot spring"
	desc = "A warm spring with gentle ripples. Standing here soothes your body."
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "together"
	water_color = "#23b9df"
	water_reagent = /datum/reagent/water
	var/heal_interval = 5 SECONDS
	var/heal_amount = 20
	var/last_heal = 0
	temperature = 300

/turf/open/water/ocean/deep/thermalwater/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/turf/open/water/ocean/deep/thermalwater/process()
	if(world.time < last_heal + heal_interval)
		return

	for(var/mob/living/carbon/M in src)
		if(M.stat == DEAD)
			continue

		if(M.getBruteLoss())
			M.adjustBruteLoss(-heal_amount)
		if(M.getFireLoss())
			M.adjustFireLoss(-heal_amount)
		if(M.getToxLoss())
			M.adjustToxLoss(-heal_amount)
		if(M.getOxyLoss())
			M.adjustOxyLoss(-heal_amount*2)

	last_heal = world.time
