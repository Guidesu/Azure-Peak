// Sanity damage assignments — gives existing DreamValley objects sanity impact
// This file assigns sanity_damage values to existing objects without modifying their original files

// ============== CORPSES AND REMAINS ==============

/obj/effect/decal/remains/human
	sanity_damage = 0.5

/obj/effect/decal/remains/robot
	sanity_damage = 0.3

// ============== BLOOD AND GORE ==============

/obj/effect/decal/cleanable/blood
	sanity_damage = 0.3

/obj/effect/decal/cleanable/blood/splatter
	sanity_damage = 0.2

/obj/effect/decal/cleanable/blood/drip
	sanity_damage = 0.1

/obj/effect/decal/cleanable/trail_holder
	sanity_damage = 0.2

// ============== DARK OBJECTS ==============

/obj/effect/decal/cleanable/shreds
	sanity_damage = 0.4

// ============== HOLY OBJECTS (negative sanity_damage = restore) ==============
// These restore sanity when viewed

/obj/structure/roguetown/shrine
	sanity_damage = -1.0

// ============== SCARY STRUCTURES ==============

/obj/structure/closet/dirthole
	sanity_damage = 0.8

/obj/structure/burial_shroud
	sanity_damage = 0.6
