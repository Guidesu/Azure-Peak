/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge
	name = "Gore Charge"
	desc = "Lowers your horns and runs your quarry down."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 18 SECONDS
	min_range = 3
	max_range = 8
	use_chance = 50
	overhead_y_offset = 48
	overhead_x_offset = 16
	required_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

	telegraph_time = TELEGRAPH_HIGH_IMPACT
	telegraph_message = "throws back its head and ROARS, digging in its hooves!"
	telegraph_sound = list('sound/vo/mobs/minotaur/minoroar.ogg','sound/vo/mobs/minotaur/minoroar2.ogg','sound/vo/mobs/minotaur/minoroar3.ogg','sound/vo/mobs/minotaur/minoroar4.ogg')
	lock_facing = FALSE
	track_target = TRUE
	recovery_time = 4 SECONDS
	recovery_slowdown = 3
	recovery_status = /datum/status_effect/debuff/vulnerable
	recovery_message = "skids to a sudden halt, struggling to recover."

	var/step_delay = 1
	var/gore_damage = 55
	var/gore_exposed = 6 SECONDS
	var/slam_stun = 2 SECONDS
	var/slam_exposed = 6 SECONDS
	var/guard_topple = 4 SECONDS

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/telegraph_offsets(atom/target)
	var/list/offs = list()
	for(var/d in 1 to max_range)
		offs += list(list(-1, d), list(0, d), list(1, d))
	return offs

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/proc/row_turfs(turf/centre, facing)
	. = list(centre)
	for(var/side in perpendicular_dirs(facing))
		var/turf/flank = get_step(centre, side)
		if(flank && !flank.density)
			. += flank

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/proc/perpendicular_dirs(facing)
	switch(facing)
		if(EAST, WEST)
			return list(NORTH, SOUTH)
	return list(WEST, EAST)

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/on_guarded(mob/living/victim, mob/living/user)
	var/mob/living/simple_animal/bull = user
	user.visible_message(span_boldwarning("<b>[user]</b> is tripped and toppled!"))
	ability_sound(get_turf(user), 'sound/foley/zfall.ogg')
	if(istype(bull))
		bull.topple(guard_topple)
	open_up(user, guard_topple, /datum/status_effect/debuff/exposed, override_recovery = TRUE)

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/resolve(atom/target, facing)
	var/mob/living/bull = owner
	if(QDELETED(target))
		return
	guard_cancelled = FALSE
	ability_sound(get_turf(bull), 'sound/combat/clash_charge.ogg')
	bull.visible_message(span_danger("<b>[bull]</b> hurls itself forward!"))
	charge_run(bull, facing, max_range)

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/proc/charge_run(mob/living/bull, facing, lane)
	var/list/perp_dirs = perpendicular_dirs(facing)
	var/shove_toggle = 0
	for(var/i in 1 to lane)
		if(QDELETED(bull) || !windup_holds(bull))
			return
		var/turf/next = get_step(get_turf(bull), facing)
		if(!next || next.density)
			slam_into_wall(bull, next || get_turf(bull))
			return
		var/blocked = FALSE
		for(var/obj/structure/S in next)
			if(S.density && !S.climbable)
				blocked = TRUE
				break
		if(blocked)
			slam_into_wall(bull, next)
			return

		var/list/gored = list()
		var/fouled = FALSE
		for(var/turf/T in row_turfs(next, facing))
			for(var/mob/living/victim in T)
				if(victim == bull || victim.stat == DEAD)
					continue
				if(bull.faction_check_mob(victim))
					var/shove_dir = perp_dirs[(shove_toggle % 2) + 1]
					shove_toggle++
					var/turf/shove_dest = get_step(get_turf(victim), shove_dir)
					if(shove_dest && !shove_dest.density)
						victim.safe_throw_at(shove_dest, 1, 1, bull, force = MOVE_FORCE_STRONG)
					victim.visible_message(span_warning("[victim] is rammed aside by [bull]!"))
					fouled = TRUE
					continue
				gored += victim
		if(length(gored))
			for(var/mob/living/victim in gored)
				gore(bull, victim, facing)
				if(guard_cancelled)
					return
			return
		if(fouled)
			bull.visible_message(span_boldwarning("<b>[bull]</b> stumbles to a halt!"))
			return

		step(bull, facing)
		new /obj/effect/temp_visual/kinetic_blast(get_turf(bull))
		sleep(step_delay)

	bull.visible_message(span_notice("[bull] bring itself to a skidding halt!"))

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/proc/gore(mob/living/bull, mob/living/victim, facing)
	if(check_guard(victim, bull))
		return
	ability_sound(get_turf(victim), 'sound/combat/brutal_impalement.ogg')
	ability_sound(get_turf(victim), 'sound/combat/crit.ogg', 75)
	victim.visible_message(span_userdanger("[bull] gores [victim] on its horns!"))
	strike_mob(victim, bull, gore_damage, BRUTE, BCLASS_STAB, "stab", PEN_HEAVY, pick(BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(victim.mobility_flags & MOBILITY_STAND)
		victim.apply_status_effect(/datum/status_effect/debuff/exposed, gore_exposed)
	var/turf/behind = get_step(get_turf(victim), facing)
	if(behind && !behind.density)
		victim.safe_throw_at(behind, 1, 1, bull, force = MOVE_FORCE_STRONG)

/datum/action/cooldown/mob_cooldown/telegraphed/minotaur_charge/proc/slam_into_wall(mob/living/bull, turf/wall)
	bull.visible_message(span_boldwarning("<b>[bull]</b> slams headlong into \the [wall] and reels!"))
	ability_sound(wall, 'sound/misc/meteorimpact.ogg')
	shake_camera(bull, 3, 3)
	bull.Stun(slam_stun, ignore_canstun = TRUE)
	open_up(bull, slam_exposed, /datum/status_effect/debuff/exposed, override_recovery = TRUE)
