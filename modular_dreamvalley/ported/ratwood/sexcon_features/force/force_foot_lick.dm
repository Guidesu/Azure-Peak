// Ported from Ratwood-2.0's sex_actions/force/force_foot_lick.dm.
// Forces the target to lick the user's feet, mirroring oral/foot_lick.dm with reversed roles.
/datum/sex_action/force/force_foot_lick
	name = "Force them to lick your feet"
	intensity = 2

/datum/sex_action/force/force_foot_lick/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force/force_foot_lick/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	// User must be standing, target forced down to floor level
	if(user.resting)
		return FALSE
	if(!target.resting)
		return FALSE
	return TRUE

/datum/sex_action/force/force_foot_lick/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] shoves [target]'s face down to [user.p_their()] feet!")

/datum/sex_action/force/force_foot_lick/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s face away from [user.p_their()] feet.")

/datum/sex_action/force/force_foot_lick/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/force/force_foot_lick/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target] to lick [user.p_their()] feet."))

/datum/sex_action/force/force_foot_lick/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	target.make_sucking_noise()
	sex_session.perform_sex_action(user, 1, 0, TRUE)
	sex_session.handle_passive_ejaculation()
