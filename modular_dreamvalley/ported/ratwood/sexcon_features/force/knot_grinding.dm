// Ported from Ratwood-2.0's sex_actions/deviant/knot_grinding.dm.
// Lets a currently-knotted pair keep grinding against each other while tied together.
// Ratwood's version branches pleasure by which orifice was knotted (SEX_PART_CUNT/ANUS/JAWS/SLIT_SHEATH)
// and a knotted_forced_by_bottom flag letting the bottom initiate; this repo's
// /datum/component/knotting (code/modules/sexcon/components/knotting.dm) tracks neither —
// only knotted_status/knotted_owner/knotted_recipient/knot_count — so this substitutes a single
// generic pleasure value instead of per-orifice branching, and only allows the knot's owner
// (top) to initiate, since there's no "forced_by_bottom" equivalent to check here.
/datum/sex_action/force/knot_grinding
	name = "Grind your knot"
	check_same_tile = FALSE
	subtle_supported = TRUE
	require_grab = FALSE

/datum/sex_action/force/knot_grinding/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	var/datum/component/knotting/knot = user.GetComponent(/datum/component/knotting)
	if(!knot || knot.knotted_status != KNOTTED_AS_TOP)
		return FALSE
	return target == knot.knotted_recipient

/datum/sex_action/force/knot_grinding/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	var/datum/component/knotting/knot = user.GetComponent(/datum/component/knotting)
	if(!knot || knot.knotted_status != KNOTTED_AS_TOP)
		return FALSE
	if(target != knot.knotted_recipient)
		return FALSE
	return TRUE

/datum/sex_action/force/knot_grinding/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] massages [user.p_their()] knot inside [target]...")

/datum/sex_action/force/knot_grinding/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] stops grinding [user.p_their()] knot inside [target].")

/datum/sex_action/force/knot_grinding/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/do_subtle = is_being_done_subtly(user, target)
	stealth_visible_message(user, target, sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective(is_stealth = do_subtle)] grinds [user.p_their()] knot inside [target]..."))

/datum/sex_action/force/knot_grinding/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	do_thrust_animate(user, target)

	sex_session.perform_sex_action(user, 2, 0.5, TRUE)
	sex_session.perform_sex_action(target, 2, 0, FALSE)
	sex_session.handle_passive_ejaculation()
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/force/knot_grinding/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/component/knotting/knot = user.GetComponent(/datum/component/knotting)
	if(!knot || knot.knotted_status != KNOTTED_AS_TOP)
		return TRUE
	return ..()
