// Ported from Ratwood-2.0's sex_actions/force/force_crotch_nuzzle.dm.
// Forces the target's face against the user's crotch, mirroring oral/crotch_nuzzle.dm with reversed roles.
/datum/sex_action/force/force_crotch_nuzzle
	name = "Force their face into your crotch"
	intensity = 2

/datum/sex_action/force/force_crotch_nuzzle/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force/force_crotch_nuzzle/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/force/force_crotch_nuzzle/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] shoves [target]'s face into [user.p_their()] crotch!")

/datum/sex_action/force/force_crotch_nuzzle/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s face away from [user.p_their()] crotch.")

/datum/sex_action/force/force_crotch_nuzzle/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/force/force_crotch_nuzzle/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums over [target]'s face!"))
	return "onto"

/datum/sex_action/force/force_crotch_nuzzle/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target]'s face against [user.p_their()] crotch."))

/datum/sex_action/force/force_crotch_nuzzle/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	sex_session.perform_sex_action(user, 0.5, 0, TRUE)
	sex_session.handle_passive_ejaculation()
