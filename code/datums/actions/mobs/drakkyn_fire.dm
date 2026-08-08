/datum/action/cooldown/mob_cooldown/telegraphed/area/dragons_breath
	name = "Dragon's Breath"
	desc = "Exhale a cone of flame."
	button_icon = 'icons/obj/magic.dmi'
	button_icon_state = "fireball"
	cooldown_time = 25 SECONDS
	min_range = 0
	max_range = 4
	use_chance = 45
	required_zones = list(BODY_ZONE_PRECISE_MOUTH)

	telegraph_time = TELEGRAPH_AREA_DENIAL
	telegraph_type = /obj/effect/temp_visual/trap/primordial/fire
	telegraph_message = "draws a deep breath, throat glowing red!"
	telegraph_sound = 'sound/magic/fireball.ogg'

	damage = 55
	damage_type = BURN
	blade_class = BCLASS_BURN
	armor_flag = "fire"
	impact_sound = list('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg')
	hit_sound = 'sound/items/firelight.ogg'

	var/cone_range = 4
	var/scorch_stacks = 1

/datum/action/cooldown/mob_cooldown/telegraphed/area/dragons_breath/telegraph_offsets(atom/target)
	var/list/offs = list()
	for(var/d in 1 to cone_range)
		var/half = max(1, round(d / 2))
		for(var/lat in -half to half)
			offs += list(list(lat, d))
	return offs

/datum/action/cooldown/mob_cooldown/telegraphed/area/dragons_breath/on_impact_turf(turf/T, mob/living/user)
	new /obj/effect/temp_visual/dragonfire(T)
	for(var/atom/movable/A in T)
		if(ismob(A))
			continue
		A.fire_act()

/datum/action/cooldown/mob_cooldown/telegraphed/area/dragons_breath/hit_mob(mob/living/victim, mob/living/user)
	. = ..()
	apply_scorch_stack(victim, scorch_stacks)

/datum/action/cooldown/mob_cooldown/telegraphed/area/dragons_breath/greater
	cooldown_time = 20 SECONDS
	damage = 60
	cone_range = 5
	max_range = 5
	scorch_stacks = 2

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball
	name = "Fireball"
	desc = "Hurl a bolt of fire at a distant foe."
	button_icon = 'icons/obj/magic.dmi'
	button_icon_state = "fireball"
	cooldown_time = 20 SECONDS
	min_range = 4
	max_range = 9

	telegraph_time = TELEGRAPH_HIGH_IMPACT
	telegraph_type = /obj/effect/temp_visual/trap/primordial/fire
	telegraph_message = "gathers a knot of fire!"
	telegraph_sound = 'sound/magic/fireball.ogg'
	whiff_message = "loses its mark."

	projectile_type = /obj/projectile/magic/aoe/fireball/rogue
	fire_sound = 'sound/magic/fireball.ogg'
	var/damage_mult = 1

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/ready_projectile(obj/projectile/P, atom/target)
	if(damage_mult == 1)
		return
	P.damage *= damage_mult
	var/obj/projectile/magic/aoe/fireball/rogue/bolt = P
	if(istype(bolt))
		bolt.arcyne_aoe_damage *= damage_mult

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/drakkyn
	name = "Drakkyn Fireball"
	use_chance = 15
	required_zones = list(BODY_ZONE_PRECISE_MOUTH)
	telegraph_message = "rears back, fire gathering behinds its teeth!"
	whiff_message = "closes its mouth, smoke billowing out."

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/drakkyn/greater
	cooldown_time = 15 SECONDS
	damage_mult = 1.5

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/watcher
	name = "Eye of Fire"
	cooldown_time = 8 SECONDS
	min_range = 2
	max_range = 9
	use_chance = 70
	telegraph_message = "fixes its eye, glaring down its foe!"
	whiff_message = "'s eyes shut, the glow dimming."
