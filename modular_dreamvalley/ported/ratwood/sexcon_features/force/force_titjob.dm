// Ported from Ratwood-2.0's sex_actions/deviant/force_titjob.dm.
// Forces the target's cock (who must be held in an aggressive grab) between
// the user's tits, mirroring sexcon2's actions/sex/other/boobjob.dm but with
// the giver/receiver roles reversed and grab-gated instead of freely chosen.
/datum/sex_action/force/force_titjob
	name = "Jerk them off with your tits"
	intensity = 3
	subtle_supported = FALSE

/datum/sex_action/force/force_titjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/force/force_titjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/force/force_titjob/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] grabs [target]'s cock and shoves it between [user.p_their()] tits!")

/datum/sex_action/force/force_titjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [target]'s cock out from between [user.p_their()] tits.")

/datum/sex_action/force/force_titjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	target.visible_message(span_love("[target] cums over [user]'s tits!"))
	return "onto"

/datum/sex_action/force/force_titjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] shoves [target]'s cock between [user.p_their()] tits."))

/datum/sex_action/force/force_titjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	sex_session.perform_sex_action(target, 2, 4, TRUE)
	sex_session.handle_passive_ejaculation(user)
