// Ported from Ratwood-2.0's sex_actions/force/force_rimming.dm.
// Forces the target to rim the user, mirroring oral/rimming.dm with reversed roles.
/datum/sex_action/force/force_rimming
	name = "Force them to rim you"
	intensity = 3
	target_priority = 100

/datum/sex_action/force/force_rimming/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force/force_rimming/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_ANUS))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/force/force_rimming/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] shoves [target]'s face into [user.p_their()] ass!")

/datum/sex_action/force/force_rimming/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s face away from [user.p_their()] ass.")

/datum/sex_action/force/force_rimming/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_ANUS)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/force/force_rimming/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target] to rim [user.p_their()] ass."))

/datum/sex_action/force/force_rimming/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	do_thrust_animate(user, target)

	sex_session.perform_sex_action(user, 2, 0, TRUE)
	sex_session.perform_sex_action(target, 0, 5, FALSE)
	sex_session.handle_passive_ejaculation()
