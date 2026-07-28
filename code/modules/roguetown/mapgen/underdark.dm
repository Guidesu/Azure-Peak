/obj/effect/landmark/mapGenerator/rogue/underdark
	mapGeneratorType = /datum/mapGenerator/underdark
	endTurfX = 255
	endTurfY = 450
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/underdark
	modules = list(/datum/mapGeneratorModule/underdarkstone, /datum/mapGeneratorModule/underdarkmud, /datum/mapGeneratorModule/underdarkveins)


/datum/mapGeneratorModule/underdarkstone
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/naturalstone)
	allowed_areas = list(/area/rogue/under/underdark)
	spawnableAtoms = list(/obj/structure/flora/rogueshroom/happy/random = 30,
							/obj/structure/flora/rogueshroom/happy/white = 6,
							/obj/structure/flora/rogueshroom/happy/fat = 4,
							/obj/structure/flora/rogueshroom/happy/angel = 1,
							/obj/structure/flora/mushroomcluster = 20,
							/obj/structure/flora/mushroomcluster/cute = 6,
							/obj/structure/flora/tinymushrooms = 20,
							/obj/structure/flora/tinymushrooms/cute = 6,
							/obj/structure/glowshroom = 10,
							/obj/structure/glowshroom/dendorite = 1,
							/obj/structure/roguerock = 25,
							/obj/item/natural/rock = 25,
							/obj/item/natural/rock/gem = 0.3,
							/obj/item/natural/rock/cinnabar = 0.4,
							/obj/item/natural/rock/salt = 0.6,
							/obj/structure/vine = 5,
							/obj/effect/hunting_track = 5,
							/obj/structure/zizo_bane = 5)

/datum/mapGeneratorModule/underdarkmud
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	allowed_areas = list(/area/rogue/under/underdark)
	allowed_turfs = list(/turf/open/floor/rogue/dirt)
	excluded_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/structure/flora/mushroomcluster = 20,
							/obj/structure/flora/mushroomcluster/cute = 5,
							/obj/structure/flora/roguegrass/thorn_bush = 10,
							/obj/structure/flora/rogueshroom/happy/random = 40,
							/obj/structure/flora/rogueshroom/happy/fat = 5,
							/obj/structure/flora/rogueshroom = 20,
							/obj/structure/flora/tinymushrooms = 20,
							/obj/structure/flora/tinymushrooms/cute = 5,
							/obj/structure/glowshroom = 8,
							/obj/structure/flora/roguegrass = 30,
							/obj/structure/flora/roguegrass/herb/random = 5,
							/obj/structure/flora/roguegrass/herb/manabloom = 1,
							/obj/item/magic/manacrystal = 0.4,
							/obj/effect/hunting_track = 5,
							/obj/structure/zizo_bane = 5)

//Rare ore veins buried deep, richer variety than the surface mountain veins given the underdark's mining depth.
/datum/mapGeneratorModule/underdarkveins
	clusterCheckFlags = CLUSTER_CHECK_SAME_TURFS
	clusterMin = 2
	clusterMax = 5
	allowed_turfs = list(/turf/open/floor/rogue/naturalstone)
	spawnableTurfs = list(/turf/closed/mineral/random/rogue = 3,
							/turf/closed/mineral/random/rogue/med = 1)
	allowed_areas = list(/area/rogue/under/underdark)
