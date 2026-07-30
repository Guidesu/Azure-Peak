/datum/action/cooldown/mob_cooldown/boulder_throw
	name = "Boulder Throw"
	desc = "Rips a boulder out of the earth and hurls it."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 25 SECONDS
	lockout_time = 25 SECONDS
	min_range = 3
	max_range = 12
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/windup_time = 1.2 SECONDS

/datum/action/cooldown/mob_cooldown/boulder_throw/can_use(atom/target)
	return ..() && get_turf(target)

/datum/action/cooldown/mob_cooldown/boulder_throw/use_special(atom/target)
	var/mob/living/troll = owner
	var/turf/target_turf = get_turf(target)
	troll.visible_message(span_danger("<b>[troll]</b> rips a massive boulder right out of the earth and winds up!"))
	playsound(troll, 'sound/combat/ground_smash_start.ogg', 90, TRUE)

	for(var/turf/T in range(1, target_turf))
		new /obj/effect/temp_visual/special_intent/warning(T, windup_time)

	var/datum/action/cooldown/mob_cooldown/troll_shove/shove = locate() in troll.actions
	if(shove)
		shove.consecutive = 0

	addtimer(CALLBACK(src, PROC_REF(spawn_rock), target_turf), windup_time)
	return TRUE

/datum/action/cooldown/mob_cooldown/boulder_throw/proc/spawn_rock(turf/target_turf)
	var/mob/living/troll = owner
	if(QDELETED(troll) || troll.incapacitated() || !target_turf)
		return
	var/turf/start_turf = get_turf(troll)
	if(!start_turf)
		return

	var/obj/projectile/bullet/thrown_boulder/B = new(start_turf)
	B.starting = start_turf
	B.firer = troll
	B.original = target_turf
	B.yo = target_turf.y - start_turf.y
	B.xo = target_turf.x - start_turf.x
	B.preparePixelProjectile(target_turf, start_turf)
	B.fire()

/datum/action/cooldown/mob_cooldown/troll_shove
	name = "Shove"
	desc = "Clears some space with a backhand."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 0.7 SECONDS
	lockout_time = 0
	max_range = 2
	var/consecutive = 0
	var/escalation = 1 SECONDS
	var/max_cooldown = 10 SECONDS

/datum/action/cooldown/mob_cooldown/troll_shove/can_use(atom/target)
	if(!..())
		return FALSE
	if(!isliving(target))
		return FALSE
	var/mob/living/victim = target
	return !victim.incapacitated()

/datum/action/cooldown/mob_cooldown/troll_shove/use_special(atom/target)
	var/mob/living/troll = owner
	var/mob/living/victim = target
	troll.visible_message(span_danger("<b>[troll]</b> shoves [victim] back to clear some space!"))
	playsound(troll, 'sound/combat/flail_sweep_hit_minor.ogg', 80, TRUE)
	victim.Knockdown(1.5 SECONDS)
	victim.throw_at(get_edge_target_turf(victim, get_dir(troll, victim)), 4, 2, troll)
	consecutive++
	StartCooldownSelf(min(cooldown_time + (consecutive - 1) * escalation, max_cooldown))
	return TRUE

/obj/projectile/bullet/thrown_boulder
	name = "massive boulder"
	desc = "A terrifyingly huge slab of rock rocketing through the air."
	icon = 'icons/roguetown/weapons/ranged/arrow_proj.dmi'
	icon_state = "boulder"
	damage = 0
	speed = 1.8

/obj/projectile/bullet/thrown_boulder/Initialize(mapload, turf/target_turf, mob/living/boss_source)
	. = ..()
	playsound(src, 'sound/misc/meteorimpact.ogg', 80, TRUE)

/obj/projectile/bullet/thrown_boulder/on_hit(atom/target, blocked)
	var/turf/impact_turf = get_turf(target) || get_turf(src)
	explode_payload(impact_turf)
	return BULLET_ACT_HIT

/obj/projectile/bullet/thrown_boulder/proc/explode_payload(turf/epicentre)
	if(!epicentre)
		epicentre = get_turf(src)
	if(!epicentre)
		qdel(src)
		return

	playsound(epicentre, 'sound/misc/explode/explosionfar (1).ogg', 100, TRUE)

	for(var/dx in -2 to 2)
		for(var/dy in -2 to 2)
			var/abs_x = abs(dx)
			var/abs_y = abs(dy)
			if(abs_x == 2 && abs_y == 2)
				continue
			var/turf/T = locate(epicentre.x + dx, epicentre.y + dy, epicentre.z)
			if(!T)
				continue
			if(dx == 0 && dy == 0)
				process_impact_zone(T, zone_type = "O")
			else if(abs_x <= 1 && abs_y <= 1)
				process_impact_zone(T, zone_type = "R")
			else
				process_impact_zone(T, zone_type = "S")
	qdel(src)

/obj/projectile/bullet/thrown_boulder/proc/process_impact_zone(turf/T, zone_type)
	var/shatter_delay = 0.6 SECONDS
	var/obj/effect/temp_visual/special_intent/shatter = new (T, shatter_delay)
	shatter.icon = 'icons/effects/effects.dmi'
	shatter.icon_state = "sweep_fx"
	var/static/list/shatter_zones = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	switch(zone_type)
		if("O")
			for(var/mob/living/L in T)
				if(L == firer)
					continue
				L.visible_message(span_userdanger("The boulder lands directly on [L]!"))
				L.Knockdown(4 SECONDS)
				L.adjustBruteLoss(75)
				playsound(L, 'sound/combat/tf2crit.ogg', 90, TRUE)
				if(iscarbon(L))
					var/limbs_broken_this_hit = 0
					var/arm_broken_this_hit = FALSE
					var/mob/living/carbon/C = L
					for(var/obj/item/bodypart/BP in C.bodyparts)
						if(limbs_broken_this_hit >= 2)
							break
						if((BP.body_zone in shatter_zones) && !BP.has_wound(/datum/wound/fracture))
							var/is_arm = (BP.body_zone == BODY_ZONE_L_ARM || BP.body_zone == BODY_ZONE_R_ARM)
							if(is_arm && arm_broken_this_hit)
								continue
							if(prob(10))
								BP.add_wound(/datum/wound/fracture/no_bleed)
								limbs_broken_this_hit++
								if(is_arm)
									arm_broken_this_hit = TRUE
			if(istype(T, /turf/closed))
				T.ex_act(EXPLODE_HEAVY)
			for(var/obj/structure/S in T)
				S.ex_act(EXPLODE_HEAVY)
		if("R")
			shatter.color = "#888888"
			for(var/mob/living/L in T)
				if(L == firer)
					continue
				L.visible_message(span_userdanger("[L] is crushed by flying stone shrapnel!"))
				L.Knockdown(2 SECONDS)
				L.adjustBruteLoss(45)
			if(istype(T, /turf/closed))
				T.ex_act(EXPLODE_LIGHT)
			for(var/obj/structure/S in T)
				S.ex_act(EXPLODE_LIGHT)
		if("S")
			shatter.alpha = 150
			for(var/mob/living/L in T)
				if(L == firer)
					continue
				L.visible_message(span_warning("The blast wave sweeps [L] off their feet!"))
				L.Knockdown(1 SECONDS)
				L.apply_status_effect(/datum/status_effect/debuff/dazed)
				L.adjustBruteLoss(15)

/obj/projectile/bullet/thrown_boulder/Range()
	var/turf/current_turf = get_turf(src)
	if(current_turf == original)
		explode_payload(current_turf)
		return
	return ..()
