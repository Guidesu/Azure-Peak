/datum/sex_action/masturbate/anus
	name = "Finger butt"
	debug_erp_panel_verb = FALSE
	subtle_supported = TRUE // Stealth-mode extension

/datum/sex_action/masturbate/anus/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user != target)
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/anus/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/anus/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] starts fingering [user.p_their()] butt..."))

/datum/sex_action/masturbate/anus/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] stops fingering [user.p_their()] butt."))

/datum/sex_action/masturbate/anus/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_ANUS)

/datum/sex_action/masturbate/anus/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/do_subtle = is_being_done_subtly(user, target)
	stealth_visible_message(user, target, sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective(is_stealth = do_subtle)] fingers [user.p_their()] butt..."))

/datum/sex_action/masturbate/anus/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	sex_session.perform_sex_action(user, 2, 6, TRUE)
	sex_session.handle_passive_ejaculation()
