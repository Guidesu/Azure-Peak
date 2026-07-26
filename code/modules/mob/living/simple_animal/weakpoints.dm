/mob/living/simple_animal
	var/anatomy_type
	var/list/part_damage
	var/list/broken_parts
	var/no_reanimate = FALSE

/mob/living/proc/register_part_damage(zone, damage, mob/living/user, obj/item/weapon)
	return

/mob/living/proc/get_zone_melee_hit_bonus(zone)
	return 0

/mob/living/proc/get_zone_ranged_hit_bonus(zone)
	return 0

/mob/living/simple_animal/proc/get_anatomy()
	if(!anatomy_type)
		return null
	return GLOB.anatomy_profiles[anatomy_type]

/mob/living/simple_animal/simple_limb_hit(zone)
	var/datum/anatomy/profile = get_anatomy()
	if(profile?.limb_names)
		var/named = profile.limb_names[zone] || profile.limb_names[check_zone(zone)]
		if(named)
			return named
	return ..()

/mob/living/simple_animal/proc/weakpoint_damage_mod(zone)
	var/datum/anatomy/profile = get_anatomy()
	if(!profile)
		return 1
	var/datum/anatomy_zone/hit_zone = profile.get_zone(zone)
	if(!hit_zone)
		return 1
	if(check_zone(zone) in broken_parts)
		return 1
	return hit_zone.damage_mult

/mob/living/simple_animal/get_zone_melee_hit_bonus(zone)
	var/datum/anatomy/profile = get_anatomy()
	if(!profile)
		return 0
	var/datum/anatomy_zone/hit_zone = profile.get_zone(zone)
	if(!hit_zone)
		return 0
	return hit_zone.melee_hit_bonus

/mob/living/simple_animal/get_zone_ranged_hit_bonus(zone)
	var/datum/anatomy/profile = get_anatomy()
	if(!profile)
		return 0
	var/datum/anatomy_zone/hit_zone = profile.get_zone(zone)
	if(!hit_zone)
		return 0
	return hit_zone.ranged_hit_bonus

/mob/living/simple_animal/register_part_damage(zone, damage, mob/living/user, obj/item/weapon)
	if(damage <= 0 || !HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
		return
	var/datum/anatomy/profile = get_anatomy()
	if(!profile)
		return
	var/datum/anatomy_zone/hit_zone = profile.get_zone(zone)
	if(!hit_zone || !hit_zone.break_wound)
		return
	if(hit_zone.min_wlength && !is_toppled())
		var/wlength = weapon?.wlength || WLENGTH_NORMAL
		if(wlength < hit_zone.min_wlength)
			return
	var/norm_zone = check_zone(zone)
	if(norm_zone in broken_parts)
		return
	if(!part_damage)
		part_damage = list()
	part_damage[norm_zone] += damage
	var/part_health = max(hit_zone.part_health_minimum, round(maxHealth * hit_zone.part_health_fraction, 1))
	if(part_damage[norm_zone] < part_health)
		return
	var/break_path = hit_zone.break_wound
	var/datum/wound/cripple/new_break = new break_path()
	new_break.crippled_zone = norm_zone
	if(simple_add_wound(new_break, crit_message = TRUE))
		LAZYADD(broken_parts, norm_zone)

/mob/living/simple_animal/proc/clear_part_damage(zone)
	if(part_damage)
		part_damage[zone] = 0
	LAZYREMOVE(broken_parts, zone)

/mob/living/simple_animal/proc/is_toppled()
	return has_wound(/datum/wound/cripple/limb/topple)
