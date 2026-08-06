/datum/action/cooldown/mob_cooldown/telegraphed
	var/telegraph_time = TELEGRAPH_AREA_DENIAL
	var/telegraph_type = /obj/effect/temp_visual/trap
	var/redraw_interval = 2
	var/stop_at_dense = TRUE
	var/lock_facing = TRUE
	var/track_target = FALSE
	var/freeze_windup = TRUE
	var/committed = TRUE
	var/charging_slowdown = 0
	var/recovery_time = 0
	var/recovery_slowdown = 0
	var/expose_on_recovery = TRUE
	var/added_move_delay = 0
	var/telegraph_message
	var/telegraph_sound
	var/whiff_message
	var/recovery_message

/datum/action/cooldown/mob_cooldown/telegraphed/use_special(atom/target)
	INVOKE_ASYNC(src, PROC_REF(windup), target)
	return TRUE

/datum/action/cooldown/mob_cooldown/telegraphed/proc/telegraph_offsets(atom/target)
	return list()

/datum/action/cooldown/mob_cooldown/telegraphed/proc/telegraph_marks(atom/target)
	return list()

/datum/action/cooldown/mob_cooldown/telegraphed/proc/windup_holds(mob/living/user)
	return !QDELETED(user) && user.stat == CONSCIOUS && !user.incapacitated()

/datum/action/cooldown/mob_cooldown/telegraphed/proc/windup(atom/target)
	var/mob/living/user = owner
	if(!isliving(user))
		return
	user.face_atom(target)
	var/facing = telegraph_cardinal(user.dir)
	if(telegraph_message)
		user.visible_message(span_boldwarning("[user] [telegraph_message]"))
	if(telegraph_sound)
		playsound(get_turf(user), telegraph_sound, 100, TRUE)
	start_windup(user, facing)
	var/list/indicator = list()
	var/elapsed = 0
	while(elapsed < telegraph_time)
		if(!windup_holds(user))
			break
		if(track_target && !QDELETED(target))
			user.face_atom(target)
			facing = telegraph_cardinal(user.dir)
		var/list/wanted = telegraph_resolve_turfs(get_turf(user), facing, telegraph_offsets(target), stop_at_dense)
		wanted |= telegraph_marks(target)
		telegraph_apply(indicator, wanted, telegraph_type)
		sleep(redraw_interval)
		elapsed += redraw_interval
	end_windup(user)
	telegraph_clear(indicator)
	if(!windup_holds(user))
		clear_move_penalty(user)
		return
	resolve(target, facing)
	do_recovery(user)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/set_move_penalty(mob/living/user, mult)
	clear_move_penalty(user)
	if(mult <= 1 || QDELETED(user))
		return
	var/datum/ai_controller/controller = user.ai_controller
	if(!controller)
		return
	added_move_delay = controller.movement_delay * (mult - 1)
	controller.movement_delay += added_move_delay

/datum/action/cooldown/mob_cooldown/telegraphed/proc/clear_move_penalty(mob/living/user)
	if(!added_move_delay)
		return
	var/datum/ai_controller/controller = user?.ai_controller
	if(controller)
		controller.movement_delay -= added_move_delay
	added_move_delay = 0

/datum/action/cooldown/mob_cooldown/telegraphed/proc/start_windup(mob/living/user, facing)
	user.setDir(facing)
	if(committed)
		user.changeNext_move(telegraph_time)
	if(lock_facing)
		user.tempfixeye = TRUE
		user.nodirchange = TRUE
		user.facing_locked = TRUE
	if(freeze_windup)
		user.Immobilize(telegraph_time, ignore_canstun = TRUE)
	set_move_penalty(user, charging_slowdown)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/end_windup(mob/living/user)
	if(QDELETED(user))
		return
	if(lock_facing)
		user.tempfixeye = FALSE
		user.nodirchange = FALSE
		user.facing_locked = FALSE
	if(freeze_windup)
		user.SetImmobilized(0, ignore_canstun = TRUE)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/do_recovery(mob/living/user)
	if(!recovery_time || QDELETED(user))
		clear_move_penalty(user)
		return
	if(recovery_message)
		user.visible_message(span_boldwarning("[user] [recovery_message]"))
	if(expose_on_recovery)
		user.apply_status_effect(/datum/status_effect/debuff/exposed, recovery_time)
	set_move_penalty(user, recovery_slowdown)
	sleep(recovery_time)
	clear_move_penalty(user)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/resolve(atom/target, facing)
	return

/datum/action/cooldown/mob_cooldown/telegraphed/proc/strike_mob(mob/living/victim, mob/living/user, damage, damage_type = BRUTE, blade_class = BCLASS_BLUNT, armor_flag = "blunt", armor_pen = PEN_NONE, def_zone)
	if(QDELETED(victim))
		return 0
	if(!def_zone)
		def_zone = pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/armor = victim.run_armor_check(def_zone, armor_flag, blade_dulling = blade_class, armor_penetration = armor_pen, damage = damage)
	var/dealt = victim.apply_damage(damage, damage_type, def_zone, armor)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, user, damage)
	if(!dealt)
		return 0
	var/wound_damage = max(0, damage - armor)
	if(wound_damage > 0)
		if(iscarbon(victim))
			var/mob/living/carbon/C = victim
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(def_zone))
			affecting?.bodypart_attacked_by(blade_class, wound_damage, user, def_zone, crit_message = TRUE)
		else
			victim.simple_woundcritroll(blade_class, wound_damage, user, def_zone, crit_message = TRUE)
	return wound_damage

/datum/action/cooldown/mob_cooldown/telegraphed/area
	lock_facing = TRUE
	var/damage = 40
	var/damage_type = BRUTE
	var/blade_class = BCLASS_BLUNT
	var/armor_flag = "blunt"
	var/armor_pen = PEN_NONE
	var/impact_sound
	var/spare_allies = TRUE

/datum/action/cooldown/mob_cooldown/telegraphed/area/resolve(atom/target, facing)
	var/mob/living/user = owner
	var/turf/origin = get_turf(user)
	var/list/turfs = telegraph_resolve_turfs(origin, facing, telegraph_offsets(target), stop_at_dense)
	if(!length(turfs))
		return
	if(impact_sound)
		playsound(origin, impact_sound, 100, TRUE)
	var/list/struck = list()
	for(var/turf/T in turfs)
		on_impact_turf(T, user)
		for(var/mob/living/L in T.contents)
			if(L == user || (L in struck))
				continue
			if(spare_allies && user.faction_check_mob(L))
				continue
			struck += L
			hit_mob(L, user)

/datum/action/cooldown/mob_cooldown/telegraphed/area/proc/on_impact_turf(turf/T, mob/living/user)
	return

/datum/action/cooldown/mob_cooldown/telegraphed/area/proc/hit_mob(mob/living/victim, mob/living/user)
	return strike_mob(victim, user, damage, damage_type, blade_class, armor_flag, armor_pen)

/datum/action/cooldown/mob_cooldown/telegraphed/ranged
	lock_facing = FALSE
	track_target = TRUE
	var/projectile_type
	var/fire_sound
	var/mark_target = TRUE

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/telegraph_offsets(atom/target)
	return list(list(0, 0))

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/telegraph_marks(atom/target)
	if(!mark_target || QDELETED(target))
		return list()
	var/turf/T = get_turf(target)
	return T ? list(T) : list()

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/resolve(atom/target, facing)
	var/mob/living/user = owner
	if(!can_use(target))
		if(whiff_message)
			user.visible_message(span_warning("[user] [whiff_message]"))
		return
	user.face_atom(target)
	if(fire_sound)
		playsound(get_turf(user), fire_sound, 100, TRUE)
	fire_at(target)

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/proc/fire_at(atom/target)
	if(!projectile_type)
		return null
	var/turf/start = get_turf(owner)
	var/obj/projectile/P = new projectile_type(start)
	P.firer = owner
	P.original = target
	P.fired_from = start
	ready_projectile(P, target)
	P.preparePixelProjectile(target, owner)
	P.fire()
	return P

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/proc/ready_projectile(obj/projectile/P, atom/target)
	return
