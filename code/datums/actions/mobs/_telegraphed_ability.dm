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
	var/recovery_overridden = FALSE
	var/added_move_delay = 0
	var/telegraph_message
	var/telegraph_sound
	var/overhead_icon
	var/overhead_state
	var/overhead_y_offset = 32
	var/overhead_x_offset = 0
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
	show_overhead(user)
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
	added_move_delay = user.cached_multiplicative_slowdown * (mult - 1)
	user.add_movespeed_modifier(MOVESPEED_ID_TELEGRAPH_WINDUP, TRUE, 100, override = TRUE, multiplicative_slowdown = added_move_delay)

/datum/action/cooldown/mob_cooldown/telegraphed/proc/clear_move_penalty(mob/living/user)
	if(!added_move_delay)
		return
	user?.remove_movespeed_modifier(MOVESPEED_ID_TELEGRAPH_WINDUP)
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

/datum/action/cooldown/mob_cooldown/telegraphed/proc/show_overhead(mob/living/user)
	var/telegraph_ic = overhead_icon || button_icon
	var/telegraph_st = overhead_state || button_icon_state
	if(QDELETED(user) || !telegraph_ic || !telegraph_st)
		return
	user.play_overhead_indicator_simple(telegraph_ic, telegraph_st, telegraph_time, ABOVE_MOB_LAYER, null, overhead_y_offset, overhead_x_offset)

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
