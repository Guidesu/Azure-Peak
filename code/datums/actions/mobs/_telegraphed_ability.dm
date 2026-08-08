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
	var/lockout_on_recovery = TRUE
	var/recovery_status = /datum/status_effect/debuff/exposed
	var/cancel_on_guard = TRUE
	var/guard_cancelled = FALSE
	var/recovery_overridden = FALSE
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
	ability_sound(get_turf(user), telegraph_sound)
	start_windup(user, facing)
	recovery_overridden = FALSE
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
	if(recovery_overridden)
		clear_move_penalty(user)
		return
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
	open_up(user, recovery_time, expose_on_recovery ? recovery_status : null)
	set_move_penalty(user, recovery_slowdown)
	sleep(recovery_time)
	clear_move_penalty(user)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/resolve(atom/target, facing)
	return

/datum/action/cooldown/mob_cooldown/telegraphed/proc/ability_sound(atom/where, soundin, volume = 100)
	if(!soundin || !where)
		return
	playsound(where, islist(soundin) ? pick(soundin) : soundin, volume, TRUE)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/open_up(mob/living/user, duration, status, override_recovery = FALSE)
	if(QDELETED(user) || duration <= 0)
		return
	if(override_recovery)
		recovery_overridden = TRUE
	if(status)
		user.apply_status_effect(status, duration)
	if(lockout_on_recovery)
		user.apply_status_effect(/datum/status_effect/debuff/clickcd, duration)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/check_guard(mob/living/victim, mob/living/user)
	if(!cancel_on_guard || QDELETED(victim))
		return FALSE
	if(!victim.guard_deflect_spell(name, FALSE, user))
		return FALSE
	guard_cancelled = TRUE
	on_guarded(victim, user)
	return TRUE

/datum/action/cooldown/mob_cooldown/telegraphed/proc/on_guarded(mob/living/victim, mob/living/user)
	open_up(user, recovery_time || 5 SECONDS, /datum/status_effect/debuff/exposed, override_recovery = TRUE)

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
	var/hit_sound
	var/spare_allies = TRUE
	var/band_delay = 0
	var/expose_between_bands = TRUE
	var/require_target_in_area = TRUE
	var/list/band_damage_mult
	var/final_band_bonus = 0
	var/victim_slowdown = 0
	var/band_index = 0

/datum/action/cooldown/mob_cooldown/telegraphed/area/proc/telegraph_bands(atom/target)
	return list(telegraph_offsets(target))

/datum/action/cooldown/mob_cooldown/telegraphed/area/can_use(atom/target)
	. = ..()
	if(!. || !require_target_in_area)
		return .
	var/facing = telegraph_cardinal(get_dir(owner, target))
	var/found = FALSE
	for(var/turf/T in telegraph_resolve_turfs(get_turf(owner), facing, telegraph_offsets(target), stop_at_dense))
		for(var/mob/living/L in T)
			if(L == owner || L.stat == DEAD)
				continue
			if(spare_allies && owner.faction_check_mob(L))
				return FALSE
			found = TRUE
	return found

/datum/action/cooldown/mob_cooldown/telegraphed/area/resolve(atom/target, facing)
	var/mob/living/user = owner
	guard_cancelled = FALSE
	var/list/bands = telegraph_bands(target)
	var/list/struck = list()
	for(var/i in 1 to length(bands))
		if(guard_cancelled || !windup_holds(user))
			break
		band_index = i
		struck.Cut()
		var/turf/origin = get_turf(user)
		var/list/turfs = telegraph_resolve_turfs(origin, facing, bands[i], stop_at_dense)
		if(length(turfs))
			ability_sound(origin, impact_sound)
			for(var/turf/T in turfs)
				on_impact_turf(T, user)
				for(var/mob/living/L in T.contents)
					if(L == user || (L in struck))
						continue
					if(spare_allies && user.faction_check_mob(L))
						continue
					struck += L
					hit_mob(L, user)
		if(guard_cancelled)
			break
		if(band_delay && i < length(bands))
			if(expose_between_bands)
				open_up(user, band_delay, recovery_status)
			var/list/upcoming = list()
			for(var/j in i + 1 to length(bands))
				upcoming += bands[j]
			var/list/marks = list()
			telegraph_apply(marks, telegraph_resolve_turfs(get_turf(user), facing, upcoming, stop_at_dense), telegraph_type)
			sleep(band_delay)
			telegraph_clear(marks)
	if(guard_cancelled)
		user.visible_message(span_boldwarning("[user]'s swing is turned aside!"))

/datum/action/cooldown/mob_cooldown/telegraphed/area/proc/on_impact_turf(turf/T, mob/living/user)
	return

/datum/action/cooldown/mob_cooldown/telegraphed/area/proc/hit_mob(mob/living/victim, mob/living/user)
	if(check_guard(victim, user))
		return 0
	var/mult = 1
	if(length(band_damage_mult))
		mult = band_damage_mult[min(max(band_index, 1), length(band_damage_mult))]
	. = strike_mob(victim, user, damage * mult, damage_type, blade_class, armor_flag, armor_pen)
	if(!.)
		return
	ability_sound(get_turf(victim), hit_sound)
	if(victim_slowdown)
		victim.Slowdown(victim_slowdown)
	if(final_band_bonus && band_index >= length(band_damage_mult))
		strike_mob(victim, user, damage * final_band_bonus, damage_type, blade_class, armor_flag, PEN_NONE)

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
		ability_sound(get_turf(user), fire_sound)
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
