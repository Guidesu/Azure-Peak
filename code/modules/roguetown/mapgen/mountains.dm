
/obj/effect/landmark/mapGenerator/rogue/mountain
	mapGeneratorType = /datum/mapGenerator/mtn
	endTurfX = 255
	endTurfY = 255
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/mtn
	modules = list(/datum/mapGeneratorModule/mtn, /datum/mapGeneratorModule/mtnstone, /datum/mapGeneratorModule/mtnveins)

/datum/mapGeneratorModule/mtn
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/structure/roguerock = 20,
							/obj/item/natural/stone = 25,
							/obj/item/natural/rock = 12,
							/obj/structure/flora/rock = 10,
							/obj/structure/flora/rock/pile = 4,
							/obj/structure/flora/roguetree/pine = 4,
							/obj/structure/flora/roguetree/pine/dead = 1,
							/obj/structure/flora/roguetree/stump/pine = 2,
							/obj/structure/flora/roguegrass/herb/random = 3,
							/obj/item/grown/log/tree/stick = 6,
							/obj/item/natural/rock/iron = 0.8,
							/obj/item/natural/rock/tin = 0.8,
							/obj/item/natural/rock/copper = 0.8,
							/obj/item/natural/rock/coal = 1,
							/obj/item/natural/rock/salt = 0.5,
							/obj/item/natural/rock/gold = 0.15,
							/obj/item/natural/rock/silver = 0.2,
							/obj/item/natural/rock/gem = 0.1,
							/obj/effect/hunting_track = 3,
							/obj/effect/decal/remains/bear = 0.3)
	allowed_areas = list(/area/rogue/outdoors/mountains)

//Bare stone slopes: sparser rock/flora scattering directly on the natural stone surface.
/datum/mapGeneratorModule/mtnstone
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/naturalstone)
	spawnableAtoms = list(/obj/structure/roguerock = 14,
							/obj/item/natural/stone = 20,
							/obj/item/natural/rock = 9,
							/obj/structure/flora/rock = 8,
							/obj/structure/flora/roguetree/pine = 2,
							/obj/structure/flora/roguetree/stump/pine = 1,
							/obj/item/grown/log/tree/stick = 3,
							/obj/effect/hunting_track = 2)
	allowed_areas = list(/area/rogue/outdoors/mountains)

//Rare surface mineral veins jutting out of the mountainside, a sparse taste of what's mined below.
/datum/mapGeneratorModule/mtnveins
	clusterCheckFlags = CLUSTER_CHECK_SAME_TURFS
	clusterMin = 2
	clusterMax = 4
	allowed_turfs = list(/turf/open/floor/rogue/naturalstone, /turf/open/floor/rogue/dirt/road)
	spawnableTurfs = list(/turf/closed/mineral/random/rogue = 3)
	allowed_areas = list(/area/rogue/outdoors/mountains)
