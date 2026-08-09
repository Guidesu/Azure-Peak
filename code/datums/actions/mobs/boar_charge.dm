/datum/action/cooldown/mob_cooldown/boar_charge
	name = "Charge"
	desc = "Lowers its head and barrels forward."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 20 SECONDS
	npc_min_range = 2
	npc_max_range = 7
	required_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/charge_speed = 2
	var/windup_time = 0.7 SECONDS
	var/missed_once = FALSE

/datum/action/cooldown/mob_cooldown/boar_charge/use_special(atom/target)
	INVOKE_ASYNC(src, PROC_REF(wind_up), target)
	return TRUE

/datum/action/cooldown/mob_cooldown/boar_charge/proc/wind_up(atom/target)
	var/mob/living/boar = owner
	boar.visible_message("<b>[boar]</b> lowers its head and paws at the ground!")
	playsound(boar, 'sound/vo//mobs/boar/boar_charge.ogg', 75, TRUE)
	if(!do_after(boar, windup_time))
		StartCooldownSelf(0)
		return
	if(QDELETED(target) || QDELETED(boar) || boar.buckled || boar.incapacitated())
		StartCooldownSelf(0)
		return
	boar.visible_message(span_danger("<b>[boar]</b> charges!"))
	var/charge_dir = get_dir(boar, target)
	boar.throw_at(target, npc_max_range, charge_speed, boar, callback = CALLBACK(src, PROC_REF(on_charge_end), charge_dir))

/datum/action/cooldown/mob_cooldown/boar_charge/proc/on_charge_end(charge_dir)
	var/mob/living/boar = owner
	if(QDELETED(boar))
		return
	var/turf/landing_turf = get_turf(boar)
	var/turf/impact_turf = get_step(landing_turf, charge_dir)
	var/did_hit = FALSE
	if(!impact_turf)
		return
	var/list/turfs_to_check = list(impact_turf)
	if(charge_dir & (charge_dir - 1))
		turfs_to_check += get_step(landing_turf, (charge_dir & (NORTH|SOUTH)))
		turfs_to_check += get_step(landing_turf, (charge_dir & (EAST|WEST)))
	else
		turfs_to_check += get_step(impact_turf, turn(charge_dir, 90))
		turfs_to_check += get_step(impact_turf, turn(charge_dir, -90))

	var/swing_sfx = pick('sound/combat/ground_smash_start.ogg', 'sound/combat/flail_sweep_hit_minor.ogg')
	for(var/turf/T in turfs_to_check)
		var/delay = 0.5 SECONDS
		var/obj/effect/temp_visual/special_intent/fx = new (T, delay)
		fx.icon = 'icons/effects/effects.dmi'
		fx.icon_state = "sweep_fx"
	playsound(impact_turf, swing_sfx, 80, TRUE)

	var/mob/living/victim
	for(var/turf/check_turf in turfs_to_check)
		victim = locate(/mob/living) in check_turf
		if(victim && victim != boar)
			break
	if(victim)
		victim.visible_message(span_userdanger("[boar] gores [victim]!</span>"))
		if(iscarbon(victim))
			var/mob/living/carbon/C = victim
			var/obj/item/bodypart/chest = C.get_bodypart(BODY_ZONE_CHEST)
			if(chest)
				chest.add_wound(/datum/wound/slash/boar_gore)
		victim.Stun(2 SECONDS)
		victim.apply_status_effect(/datum/status_effect/debuff/exposed, 10 SECONDS)
		boar.Stun(3 SECONDS)
		victim.adjustBruteLoss(50)
		playsound(victim, 'sound/combat/crit.ogg', 75, TRUE)
		missed_once = FALSE
		return

	var/list/blocked_turfs = list()
	for(var/turf/check_turf in turfs_to_check)
		if(check_turf.is_blocked_turf(exclude_mobs = TRUE))
			blocked_turfs += check_turf
	if(length(blocked_turfs))
		did_hit = TRUE
		boar.visible_message(span_danger("[boar] slams into the environment with bone-shattering force!"))
		playsound(impact_turf, 'sound/combat/hits/onwood/fence_hit3.ogg', 100, TRUE)
		boar.Stun(3 SECONDS)
		on_wall_impact(boar, blocked_turfs)
		for(var/turf/T in range(1, impact_turf))
			var/obj/effect/temp_visual/special_intent/smash = new (T, 0.5 SECONDS)
			smash.icon = 'icons/effects/effects.dmi'
			smash.icon_state = "strike"
		for(var/mob/living/L in range(1, impact_turf))
			if(L == boar)
				continue
			L.visible_message(span_warning("The shockwave from [boar]'s impact knocks [L] off their feet!"))
			L.Knockdown(3 SECONDS)
			L.apply_status_effect(/datum/status_effect/debuff/dazed)
			L.adjustBruteLoss(20)

	if(did_hit)
		missed_once = FALSE
		return
	if(!missed_once)
		missed_once = TRUE
		StartCooldownSelf(0)
		boar.visible_message(span_notice("[boar] skids to a halt and prepares to lunges again!"))
	else
		missed_once = FALSE

/datum/action/cooldown/mob_cooldown/boar_charge/proc/on_wall_impact(mob/living/boar, list/blocked_turfs)
	return

/datum/action/cooldown/mob_cooldown/boar_charge/undead
	cooldown_time = 25 SECONDS
	charge_speed = 1
	windup_time = 0.75 SECONDS

/datum/action/cooldown/mob_cooldown/boar_charge/undead/on_wall_impact(mob/living/boar, list/blocked_turfs)
	for(var/turf/T in blocked_turfs)
		var/obj/structure/flora/hit_flora = locate(/obj/structure/flora) in T
		if(!hit_flora || !hit_flora.density)
			continue

		boar.visible_message(span_danger("The impact violently splinters [hit_flora], spraying sharp wooden thorns everywhere!"))
		playsound(T, 'sound/combat/Ranged/flatbow-shot-01.ogg', 100, TRUE)
		var/projectiles = rand(4, 9)
		var/base_angle_step = 360 / projectiles
		for(var/i in 1 to projectiles)
			var/angle = (i * base_angle_step) + rand(-15, 15)

			var/offset_x = round(cos(angle) * 4)
			var/offset_y = round(sin(angle) * 4)
			var/turf/target_turf = locate(T.x + offset_x, T.y + offset_y, T.z)

			if(!target_turf || target_turf == T)
				continue

			var/obj/projectile/bullet/thorn/P = new(T)
			P.starting = T
			P.firer = boar
			P.fired_from = hit_flora

			P.yo = target_turf.y - T.y
			P.xo = target_turf.x - T.x
			P.original = target_turf

			P.preparePixelProjectile(target_turf, T)
			P.fire()

/obj/projectile/bullet/thorn
	name = "sharp thorn wood splinter"
	desc = "A lethal, jagged piece of shattered wood flying at blinding speeds."
	icon = 'icons/roguetown/weapons/ranged/arrow_proj.dmi'
	icon_state = "thorn"
	damage = 60
	embedchance = 0
	armor_penetration = PEN_BSTEEL
	woundclass = BCLASS_PIERCE
	damage_type = BRUTE
	speed = 1.3
