// Ported from Ratwood-2.0's sex_actions/force/force_footjob.dm.
// Forces the target's feet (who must be held in an aggressive grab) around the
// user's cock, mirroring sexcon2's actions/sex/other/footjob.dm but with the
// giver/receiver roles reversed and grab-gated instead of freely chosen.
/datum/sex_action/force/force_footjob
	name = "Use their feet to get off"
	intensity = 3
	subtle_supported = FALSE

/datum/sex_action/force/force_footjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/force/force_footjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_L_FOOT))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	return TRUE

/datum/sex_action/force/force_footjob/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] grabs [target]'s feet and clamps them around [user.p_their()] cock!")

/datum/sex_action/force/force_footjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [user.p_their()] cock out from inbetween [target]'s feet.")

/datum/sex_action/force/force_footjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums over [target]'s feet!"))
	return "onto"

/datum/sex_action/force/force_footjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] uses [target]'s feet to jerk off."))

/datum/sex_action/force/force_footjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)

	sex_session.perform_sex_action(user, 2, 4, TRUE)
	sex_session.handle_passive_ejaculation(target)
