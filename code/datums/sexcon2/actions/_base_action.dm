/datum/sex_session_lock
	var/mob/living/locked_host
	var/locked_organ_slot
	var/obj/item/locked_item

/datum/sex_session_lock/New(mob/_host, _locked_slot, obj/item/_locked_item)
	. = ..()
	locked_host = _host
	locked_organ_slot = _locked_slot
	locked_item = _locked_item
	LAZYADD(GLOB.locked_sex_objects, src)

/datum/sex_session_lock/Destroy(force, ...)
	. = ..()
	LAZYREMOVE(GLOB.locked_sex_objects, src)
	locked_host = null
	locked_item = null

/datum/sex_action
	abstract_type = /datum/sex_action

	/// Display name of the action
	var/name = "Generic Action"
	///Description for hover
	var/description = "Generic desc"

	/// Whether this action can continue indefinitely
	var/continous = TRUE
	/// How long each iteration takes
	var/do_time = 3.3 SECONDS
	/// Stamina cost per iteration
	var/stamina_cost = 0.5
	/// Whether to check if user is incapacitated
	var/check_incapacitated = TRUE
	/// Whether participants must be on same tile
	var/check_same_tile = TRUE
	/// Whether this requires a grab
	var/require_grab = FALSE
	/// Minimum grab state required
	var/required_grab_state = GRAB_PASSIVE
	/// Whether aggressive grab bypasses same tile requirement
	var/aggro_grab_instead_same_tile = FALSE
	///this is a list of locks we created to prevent penis portal powers
	var/list/datum/sex_session_lock/sex_locks = list()
	///this is the priority of our action for the target so when ejaculate messages are looked at its highest priority
	var/target_priority = 10
	///this is the priority of our action for the user
	var/user_priority = 10
	/// Whether this action supports knotting on climax
	var/knot_on_finish = FALSE
	/// Whether this action can trigger knots
	var/can_knot = FALSE
	///basically for actions being done by the user where the target is the inserter set this to true
	var/flipped = FALSE
	///Intensity of the climax from this action.
	var/intensity = 2
	///Used for determining whether the good lover bonus can apply
	var/masturbation = FALSE
	///Whenever or not you need to be adjacent to someone to use it
	var/ranged_action = FALSE
	///Whenever it should be actually displayed on the panel or not
	var/debug_erp_panel_verb = TRUE
	// Stealth-mode extension (ported from Ratwood-2.0 do_subtle_action): whether this action can be performed discreetly.
	///Only allow select actions to be done subtly/discreetly
	var/subtle_supported = FALSE

/datum/sex_action/Destroy()
	for(var/datum/sex_session_lock/lock in sex_locks)
		qdel(lock)
	sex_locks.Cut()

	return ..()

/datum/sex_action/proc/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(debug_erp_panel_verb)
		return FALSE
	if(user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		return TRUE //Battlefuck buff
	// Ratwood chastity_collar port, Stage 1: let worn intimate accessories (chastity devices, etc.) hide
	// this action from the target's menu entirely when it targets a locked-away organ.
	if(target && SEND_SIGNAL(target, COMSIG_CARBON_SEX_ACTION_VALIDATE, user, src, get_acted_sex_part(), TRUE) & COMPONENT_SEX_ACTION_BLOCK)
		return FALSE
	return TRUE

/datum/sex_action/proc/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SHOULD_CALL_PARENT(TRUE)
	// Ratwood chastity_collar port, Stage 1: let worn intimate accessories (chastity devices, etc.) veto
	// this action outright when it targets a locked-away organ. See COMSIG_CARBON_SEX_ACTION_VALIDATE
	// in code/__DEFINES/sex.dm for the full signal contract.
	if(target && SEND_SIGNAL(target, COMSIG_CARBON_SEX_ACTION_VALIDATE, user, src, get_acted_sex_part(), FALSE) & COMPONENT_SEX_ACTION_BLOCK)
		return FALSE
	return TRUE

/**
 * Ratwood chastity_collar port, Stage 1 helper.
 * Ratwood's old sexcon tagged every sex_action with a SEX_PART_* bitmask (cock/cunt/anus) describing which
 * of the receiving mob's own organs were involved, letting chastity's guard component check per-organ lock
 * state directly. sexcon2's /datum/sex_action has no such concept, and the existing BODY_ZONE_PRECISE_GROIN
 * constant is too coarse (it can't distinguish penis/vagina/anus, which chastity devices lock independently).
 * Rather than invent a full parallel targeting system in Stage 1 (out of scope — this is signal plumbing,
 * not a new targeting system), this defines a minimal SEX_PART_* bitmask (code/__DEFINES/sex.dm) scoped
 * purely to feeding this signal, and maps action type paths onto it by inspection of what body part each
 * action type actually acts on. receive_sex_action() on /datum/component/arousal (code/modules/sexcon/components/arousal.dm)
 * calls this same proc directly on the live action instance rather than duplicating the mapping.
 * Returns NONE if this action type doesn't clearly target one of the three chastity-relevant organs.
 */
/datum/sex_action/proc/get_acted_sex_part()
	if(istype(src, /datum/sex_action/sex/anal) || istype(src, /datum/sex_action/sex/other/anal) || istype(src, /datum/sex_action/masturbate/anus) || istype(src, /datum/sex_action/masturbate/other/anus) || istype(src, /datum/sex_action/toy/anus) || istype(src, /datum/sex_action/toy/other/anus))
		return SEX_PART_ANUS
	if(istype(src, /datum/sex_action/sex/vaginal) || istype(src, /datum/sex_action/sex/other/vagina) || istype(src, /datum/sex_action/masturbate/vagina) || istype(src, /datum/sex_action/masturbate/other/vagina) || istype(src, /datum/sex_action/toy/vagina) || istype(src, /datum/sex_action/toy/other/vagina))
		return SEX_PART_CUNT
	if(istype(src, /datum/sex_action/masturbate/penis) || istype(src, /datum/sex_action/masturbate/other/penis) || istype(src, /datum/sex_action/masturbate/penis_over))
		return SEX_PART_COCK
	return NONE

/datum/sex_action/proc/try_knot_on_climax(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!knot_on_finish)
		return FALSE
	if(!can_knot)
		return FALSE

	var/datum/sex_session/session = get_sex_session(user, target)
	if(!session)
		return FALSE
	return SEND_SIGNAL(user, COMSIG_SEX_TRY_KNOT, target, session.force, get_knot_count())

/datum/sex_action/proc/get_knot_count()
	return 0

/datum/sex_action/proc/check_location_accessible(mob/living/carbon/human/user, mob/living/carbon/human/target, location = BODY_ZONE_CHEST, grabs = FALSE, skipundies = TRUE)
	var/obj/item/bodypart/bodypart = target.get_bodypart(location)
	var/self_target = FALSE
	if(target == user)
		self_target = TRUE

	if(!bodypart)
		return FALSE

	if(user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		return TRUE //Battlefuck buff

	if(src.check_same_tile && (user != target || self_target))
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (src.aggro_grab_instead_same_tile && user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE

	if(src.require_grab && (user != target || self_target))
		var/grabstate = user.get_highest_grab_state_on(target)
		if((grabstate == null || grabstate < src.required_grab_state))
			return FALSE

	var/result = get_location_accessible(target, location = location, grabs = grabs, skipundies = skipundies)
	return result

/datum/sex_action/proc/get_users_penis(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.getorganslot(ORGAN_SLOT_PENIS)

/datum/sex_action/proc/has_double_penis(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	var/obj/item/organ/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis?.functional)
		return FALSE
	return penis.penis_type in list(
		PENIS_TYPE_TAPERED_DOUBLE,
		PENIS_TYPE_TAPERED_DOUBLE_KNOTTED
	)

/datum/sex_action/proc/has_slit_sheath(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	var/obj/item/organ/penis/penis = target.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return FALSE
	return penis.sheath_type == SHEATH_TYPE_SLIT

/datum/sex_action/proc/has_sensitive_ears(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	var/obj/item/organ/ears/ears = target.getorganslot(ORGAN_SLOT_EARS)
	if(!ears)
		return FALSE
	return ears.ear_sensitivity == EARS_SENSITIVE

/datum/sex_action/proc/find_original_owner_by_ckey(target_ckey)
	if(!target_ckey)
		return null

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.ckey == target_ckey)
			return H

	return null

/datum/sex_action/proc/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SHOULD_CALL_PARENT(TRUE)
	lock_sex_object(user, target)

	var/message = get_start_message(user, target)
	if(message)
		stealth_visible_message(user, target, message)

	var/sound = get_start_sound(user, target)
	if(sound)
		playsound(target, sound, is_being_done_subtly(user, target) ? 8 : 20, TRUE, ignore_walls = FALSE)

	return TRUE

// Stealth-mode extension (ported from Ratwood-2.0 do_subtle_action): shared helpers for discreet sex actions.
/// Returns TRUE if this action both supports and is currently being performed in subtle/discreet mode.
/datum/sex_action/proc/is_being_done_subtly(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!subtle_supported)
		return FALSE
	var/datum/sex_session/session = get_sex_session(user, target)
	if(!session)
		return FALSE
	return session.do_subtle_action

/// Wraps visible_message with a reduced vision_distance when the action is being done subtly, matching Ratwood's do_subtle_action treatment.
/datum/sex_action/proc/stealth_visible_message(mob/living/carbon/human/user, mob/living/carbon/human/target, message)
	var/subtle = is_being_done_subtly(user, target)
	user.visible_message(message, vision_distance = (subtle ? 1 : DEFAULT_MESSAGE_RANGE))
	if(subtle)
		var/datum/sex_session/session = get_sex_session(user, target)
		session?.suppress_moan = TRUE

/datum/sex_action/proc/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return null

/datum/sex_action/proc/get_start_sound(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return null

/datum/sex_action/proc/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/sex_action/proc/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/sex_action/proc/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SHOULD_CALL_PARENT(TRUE)
	unlock_sex_object(user, target)

	var/message = get_finish_message(user, target)
	if(message)
		stealth_visible_message(user, target, message)

	var/datum/sex_session/session = get_sex_session(user, target)
	if(session)
		session.suppress_moan = FALSE

	return

/// Override this to provide the message shown when the action finishes (e.g., withdrawal message)
/datum/sex_action/proc/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return null

/datum/sex_action/proc/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(sex_session.finished_check())
		return TRUE
	return FALSE


/datum/sex_action/proc/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return FALSE

/datum/sex_action/proc/unlock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	for(var/datum/sex_session_lock/lock as anything in sex_locks)
		qdel(lock)
	sex_locks.Cut()

/datum/sex_action/proc/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/sex_action/proc/check_sex_lock(mob/locked, organ_slot, obj/item/item)
	if(!organ_slot && !item)
		return FALSE
	for(var/datum/sex_session_lock/lock as anything in GLOB.locked_sex_objects)
		if(lock in sex_locks)
			continue
		if(lock.locked_host != locked)
			continue
		if(lock.locked_item != item && lock.locked_organ_slot != organ_slot)
			continue
		return TRUE
	return FALSE


/datum/sex_action/proc/do_onomatopoeia(mob/living/carbon/human/user)
	user.balloon_alert_to_viewers("Plap!", x_offset = rand(-15, 15), y_offset = rand(0, 25))

/datum/sex_action/proc/show_sex_effects(mob/living/carbon/human/user)
	for(var/i in 1 to rand(1, 3))
		if(!user.cmode) // Combat mode
			new /obj/effect/temp_visual/heart/sex_effects(get_turf(user))
		else
			new /obj/effect/temp_visual/heart/sex_effects/red_heart(get_turf(user))

