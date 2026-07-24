// Anatomy profiles for the simple mob critical wounds system, with design exaplanation per profile.

/* Trash quadruped, wounds are not really core to fighting these animals, and it is just 
 there to provide player a tangible sense of progress.
*/
/datum/anatomy/quadruped/trash/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.6, part_health_minimum = 30, break_wound = /datum/wound/cripple/maw, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")

/datum/anatomy/biped/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/skull, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb, hint = "legs")
