//genstuff
/obj/effect/landmark/mapGenerator/rogue/decap
	mapGeneratorType = /datum/mapGenerator/decap
	endTurfX = 255
	endTurfY = 255
	startTurfX = 1
	startTurfY = 1


/datum/mapGenerator/decap
	modules = list(/datum/mapGeneratorModule/decapsnow,/datum/mapGeneratorModule/decaproad, /datum/mapGeneratorModule/decapgrass, /datum/mapGeneratorModule/decapveins)


/datum/mapGeneratorModule/decapsnow
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/snow)
	excluded_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/structure/flora/grass/both = 15,
	/obj/structure/flora/grass/brown = 20,
	/obj/structure/flora/grass/green = 20,
	/obj/item/grown/log/tree/stick = 16,
	/obj/structure/flora/roguegrass/pyroclasticflowers = 3,
	/obj/structure/flora/roguegrass/maneater/real=3,
	/obj/structure/flora/roguegrass/herb/random = 5,
	/obj/structure/leyline/normal/decap = 2,
	/obj/structure/flora/roguetree/pine = 8,
	/obj/structure/flora/roguetree/pine/dead = 2,
	/obj/structure/flora/roguetree/stump/pine = 3,
	/obj/structure/flora/rock = 6,
	/obj/structure/flora/rock/pile = 2,
	/obj/item/natural/stone = 10,
	/obj/item/natural/rock = 3,
	/obj/structure/roguerock = 5,
	/obj/structure/flora/tree/dead = 3,
	/obj/effect/decal/remains/bear = 0.3,
	/obj/effect/decal/remains/wolf = 0.3,
	/obj/effect/hunting_track = 3)
	spawnableTurfs = list(/turf/open/floor/rogue/snowpatchy=15,
							/turf/open/floor/rogue/snowrough=4)
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)

/datum/mapGeneratorModule/decaproad
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/item/natural/stone = 15,/obj/item/natural/rock = 3,/obj/item/grown/log/tree/stick = 6)
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)

/datum/mapGeneratorModule/decapgrass
	clusterCheckFlags =  CLUSTER_CHECK_SAME_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/grass, /turf/open/floor/rogue/grassred, /turf/open/floor/rogue/grassyel, /turf/open/floor/rogue/grasscold)
	excluded_turfs = list()
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)
	spawnableAtoms = list(/obj/structure/flora/roguegrass = 25,
							/obj/structure/flora/roguegrass/herb/random = 2,
							/obj/structure/flora/roguegrass/bush/westleach = 2,
							/obj/structure/flora/roguetree/pine = 4,
							/obj/structure/flora/roguetree/stump/pine = 1,
							/obj/structure/flora/rock = 2,
							/obj/item/natural/stone = 6,
							/obj/item/natural/rock = 1,
							/obj/item/grown/log/tree/stick = 3,
							/obj/effect/decal/remains/wolf = 0.2,
							/obj/effect/hunting_track = 3)

//Rare surface mineral veins jutting from the snowpack, matching the mountain range's ore variety.
/datum/mapGeneratorModule/decapveins
	clusterCheckFlags = CLUSTER_CHECK_SAME_TURFS
	clusterMin = 2
	clusterMax = 4
	allowed_turfs = list(/turf/open/floor/rogue/naturalstone, /turf/open/floor/rogue/dirt/road)
	spawnableTurfs = list(/turf/closed/mineral/random/rogue = 2)
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)
