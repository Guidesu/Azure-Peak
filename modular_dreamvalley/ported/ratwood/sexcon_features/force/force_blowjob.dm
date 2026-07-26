// Ported from Ratwood-2.0's sex_actions/force/force_blowjob.dm.
// Forces the target (who must be held in an aggressive grab) to suck the user's cock,
// mirroring sexcon2's actions/oral/blowjob.dm but with the giver/receiver roles reversed
// and grab-gated instead of freely chosen by the target.
/datum/sex_action/force/force_blowjob
	name = "Force them to suck your pintle"
	intensity = 4
	target_priority = 100
	subtle_supported = FALSE

/datum/sex_action/force/force_blowjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/force/force_blowjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/force/force_blowjob/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] forces [target]'s head down to swallow and suck on [user.p_their()] cock!")

/datum/sex_action/force/force_blowjob/get_start_sound(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg')

/datum/sex_action/force/force_blowjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [user.p_their()] cock out of [target]'s throat.")

/datum/sex_action/force/force_blowjob/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/force/force_blowjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums into [target]'s throat!"))
	return "into"

/datum/sex_action/force/force_blowjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target] to suck [user.p_their()] cock."))

/datum/sex_action/force/force_blowjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.make_sucking_noise()
	do_thrust_animate(user, target)

	sex_session.perform_sex_action(user, 2, 0, TRUE)
	sex_session.perform_sex_action(target, 0, 7, FALSE)
	sex_session.handle_passive_ejaculation()
