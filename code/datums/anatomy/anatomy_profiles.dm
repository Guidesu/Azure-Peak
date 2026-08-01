// Anatomy profiles for the simple mob critical wounds system, with design exaplanation per profile.

/* Trash quadruped, wounds are not really core to fighting these animals, and it is just
 there to provide player a tangible sense of progress.
*/
/datum/anatomy/quadruped
	limb_names = list(
		BODY_ZONE_HEAD = "head",
		BODY_ZONE_PRECISE_R_EYE = "head",
		BODY_ZONE_PRECISE_L_EYE = "head",
		BODY_ZONE_PRECISE_SKULL = "head",
		BODY_ZONE_PRECISE_EARS = "head",
		BODY_ZONE_PRECISE_NOSE = "nose",
		BODY_ZONE_PRECISE_MOUTH = "mouth",
		BODY_ZONE_PRECISE_NECK = "neck",
		BODY_ZONE_CHEST = "flank",
		BODY_ZONE_L_ARM = "foreleg",
		BODY_ZONE_R_ARM = "foreleg",
		BODY_ZONE_PRECISE_L_HAND = "foreleg",
		BODY_ZONE_PRECISE_R_HAND = "foreleg",
		BODY_ZONE_L_LEG = "hind leg",
		BODY_ZONE_R_LEG = "hind leg",
		BODY_ZONE_PRECISE_L_FOOT = "hind leg",
		BODY_ZONE_PRECISE_R_FOOT = "hind leg",
		BODY_ZONE_PRECISE_STOMACH = "stomach",
		BODY_ZONE_PRECISE_GROIN = "tail",
	)

/datum/anatomy/quadruped/trash/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.6, part_health_minimum = 30, break_wound = /datum/wound/cripple/maw, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/limb, hint = "legs")

/* Standard quadruped like direbear, mole that has an actual substantial HP pool. Crippling is a real mid fight tactic. Forelegs lower offensive output, hind legs lower movement. Part health being lower means that a fight would involve 2 - 3 parts instead of just 1 into death.
*/
/datum/anatomy/quadruped/standard/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 45, break_wound = /datum/wound/cripple/maw, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.3, part_health_minimum = 40, break_wound = /datum/wound/cripple/arm/foreleg, hint = "forelegs")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.3, part_health_minimum = 40, break_wound = /datum/wound/cripple/arm/foreleg, hint = "forelegs")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.3, part_health_minimum = 40, break_wound = /datum/wound/cripple/limb, hint = "hind legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.3, part_health_minimum = 40, break_wound = /datum/wound/cripple/limb, hint = "hind legs")

/* Deadite quadruped. Legs cripple, dragging down both its stride and its swings. Destroying the
head kills it where it stands and bars reanimation for good - half its health poured into a single
zone, which is the payoff for aiming instead of flailing.
*/
/datum/anatomy/quadruped/undead/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.5, part_health_minimum = 30, break_wound = /datum/wound/cripple/decapitate/small, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb/undead, hint = "forelegs")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb/undead, hint = "forelegs")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb/undead, hint = "hind legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb/undead, hint = "hind legs")

/datum/anatomy/biped
	limb_names = list(
		BODY_ZONE_HEAD = "head",
		BODY_ZONE_PRECISE_R_EYE = "head",
		BODY_ZONE_PRECISE_L_EYE = "head",
		BODY_ZONE_PRECISE_SKULL = "head",
		BODY_ZONE_PRECISE_EARS = "head",
		BODY_ZONE_PRECISE_NOSE = "nose",
		BODY_ZONE_PRECISE_MOUTH = "mouth",
		BODY_ZONE_PRECISE_NECK = "neck",
		BODY_ZONE_CHEST = "chest",
		BODY_ZONE_L_ARM = "arm",
		BODY_ZONE_R_ARM = "arm",
		BODY_ZONE_PRECISE_L_HAND = "hand",
		BODY_ZONE_PRECISE_R_HAND = "hand",
		BODY_ZONE_L_LEG = "leg",
		BODY_ZONE_R_LEG = "leg",
		BODY_ZONE_PRECISE_L_FOOT = "foot",
		BODY_ZONE_PRECISE_R_FOOT = "foot",
		BODY_ZONE_PRECISE_STOMACH = "gut",
		BODY_ZONE_PRECISE_GROIN = "groin",
	)

/datum/anatomy/biped/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.45, part_health_minimum = 25, break_wound = /datum/wound/cripple/skull, hint = "head")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb, hint = "legs")
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound = /datum/wound/cripple/limb, hint = "legs")

/* Tough biped, taller than a human. Head is gated by reach, and is an instant kill with
less hp than their global HP pool. It also stop it from reanimating. Guts is a part that allows you to kill them by disembowelment. Legs will topple it. Arms will weaken its attacks.
Aiming legs should be nearly guaranteed due to their profile
*/
/datum/anatomy/biped/tough/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 100, break_wound = /datum/wound/cripple/decapitate, hint = "head", min_wlength = WLENGTH_GREAT, melee_hit_bonus = -10, ranged_hit_bonus = -15) // Better build up that PER chudling
	add_zone(BODY_ZONE_PRECISE_STOMACH, damage_mult = 1, part_health_fraction = 0.6, part_health_minimum = 150, break_wound = /datum/wound/cripple/guts, hint = "gut")
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/limb/topple, hint = "legs", melee_hit_bonus = 40)
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/limb/topple, hint = "legs", melee_hit_bonus = 40)

/* Deadite tough biped. Mirrors the living profile - a reach-gated head that kills and bars
reanimation, legs that topple, arms that weaken. No guts zone: an undead has nothing left to spill that would stop it.
*/
/datum/anatomy/biped/tough/undead/build_zones()
	add_zone(BODY_ZONE_HEAD, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 100, break_wound = /datum/wound/cripple/decapitate, hint = "head", min_wlength = WLENGTH_GREAT, melee_hit_bonus = -10, ranged_hit_bonus = -15)
	add_zone(BODY_ZONE_L_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_R_ARM, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/arm, hint = "arms")
	add_zone(BODY_ZONE_L_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/limb/topple, hint = "legs", melee_hit_bonus = 40)
	add_zone(BODY_ZONE_R_LEG, damage_mult = 1, part_health_fraction = 0.35, part_health_minimum = 80, break_wound = /datum/wound/cripple/limb/topple, hint = "legs", melee_hit_bonus = 40)
