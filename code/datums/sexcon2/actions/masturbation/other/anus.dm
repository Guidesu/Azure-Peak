/datum/sex_action/masturbate/other/anus
	name = "Finger their butt"
	check_same_tile = FALSE
	debug_erp_panel_verb = FALSE
	subtle_supported = TRUE // Stealth-mode extension

/datum/sex_action/masturbate/other/anus/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/anus/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_ANUS))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/anus/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] starts fingering [target]'s butt..."))

/datum/sex_action/masturbate/other/anus/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] stops fingering [target]'s butt."))

/datum/sex_action/masturbate/other/anus/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	sex_locks |= new /datum/sex_session_lock(target, ORGAN_SLOT_ANUS)

/datum/sex_action/masturbate/other/anus/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/do_subtle = is_being_done_subtly(user, target)
	stealth_visible_message(user, target, sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective(is_stealth = do_subtle)] fingers [target]'s butt..."))

/datum/sex_action/masturbate/other/anus/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	sex_session.perform_sex_action(target, 2, 6, TRUE)
	sex_session.handle_passive_ejaculation(target)
