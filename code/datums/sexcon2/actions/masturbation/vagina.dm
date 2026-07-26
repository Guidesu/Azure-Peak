/datum/sex_action/masturbate/vagina
	name = "Stroke clit"
	debug_erp_panel_verb = FALSE
	subtle_supported = TRUE // Stealth-mode extension

/datum/sex_action/masturbate/vagina/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user != target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/vagina/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] starts stroking [user.p_their()] clit..."))

/datum/sex_action/masturbate/vagina/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	stealth_visible_message(user, target, span_warning("[user] stops stroking."))

/datum/sex_action/masturbate/vagina/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_VAGINA)

/datum/sex_action/masturbate/vagina/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/do_subtle = is_being_done_subtly(user, target)
	stealth_visible_message(user, target, sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective(is_stealth = do_subtle)] strokes [user.p_their()] clit..."))

/datum/sex_action/masturbate/vagina/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	sex_session.perform_sex_action(user, 2, 4, TRUE)

	sex_session.handle_passive_ejaculation()
