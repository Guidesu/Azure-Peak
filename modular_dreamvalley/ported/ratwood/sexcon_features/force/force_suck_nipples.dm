// Ported from Ratwood-2.0's sex_actions/force/force_suck_nipples.dm.
// Forces the target to suck the user's nipples, mirroring oral/suck_nipples.dm with reversed roles.
/datum/sex_action/force/force_suck_nipples
	name = "Force them to suck your nipples"
	intensity = 3

/datum/sex_action/force/force_suck_nipples/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/force/force_suck_nipples/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_BREASTS))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/force/force_suck_nipples/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s head to [user.p_their()] chest, forcing [target.p_them()] to suck!")

/datum/sex_action/force/force_suck_nipples/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s head away from [user.p_their()] chest.")

/datum/sex_action/force/force_suck_nipples/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_BREASTS)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/force/force_suck_nipples/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target] to suck [user.p_their()] nipples."))

/datum/sex_action/force/force_suck_nipples/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	target.make_sucking_noise()
	sex_session.perform_sex_action(user, 1, 0, TRUE)
	sex_session.handle_passive_ejaculation()
