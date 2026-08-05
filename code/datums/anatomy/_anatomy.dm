GLOBAL_LIST_INIT(anatomy_profiles, init_anatomy_profiles())

/proc/init_anatomy_profiles()
	. = list()
	for(var/profile_type in typesof(/datum/anatomy))
		.[profile_type] = new profile_type()

/datum/anatomy
	var/list/zones
	var/list/limb_names
	/// Grants TRAIT_BLOODLOSS_IMMUNE on spawn.
	var/undead = FALSE

/datum/anatomy/New()
	. = ..()
	zones = list()
	build_zones()

/datum/anatomy/proc/build_zones()
	return

/datum/anatomy/proc/add_zone(zone, damage_mult = 1, part_health_fraction = 0.4, part_health_minimum = 20, break_wound, hint, melee_hit_bonus = 0, ranged_hit_bonus = 0, min_wlength = 0)
	var/datum/anatomy_zone/new_zone = new()
	new_zone.zone = zone
	new_zone.damage_mult = damage_mult
	new_zone.part_health_fraction = part_health_fraction
	new_zone.part_health_minimum = part_health_minimum
	new_zone.break_wound = break_wound
	new_zone.hint = hint
	new_zone.melee_hit_bonus = melee_hit_bonus
	new_zone.ranged_hit_bonus = ranged_hit_bonus
	new_zone.min_wlength = min_wlength
	zones[zone] = new_zone

/datum/anatomy/proc/get_zone(zone_precise)
	if(!zone_precise || !length(zones))
		return null
	. = zones[zone_precise]
	if(.)
		return .
	return zones[check_zone(zone_precise)]

/datum/anatomy_zone
	var/zone
	var/damage_mult = 1
	var/part_health_fraction = 0.4
	var/part_health_minimum = 20
	var/break_wound
	var/hint
	var/melee_hit_bonus = 0
	var/ranged_hit_bonus = 0
	var/min_wlength = 0
