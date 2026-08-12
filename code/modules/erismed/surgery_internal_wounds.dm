// ERISMED — Surgery step for treating internal wounds
// Allows surgeons to diagnose and treat internal organ wounds

/datum/surgery/treat_internal_wounds
	name = "Treat internal wounds"
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_GROIN)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract,
		/datum/surgery_step/clamp,
		/datum/surgery_step/treat_internal_wound,
		/datum/surgery_step/cauterize,
	)

/datum/surgery_step/treat_internal_wound
	name = "treat internal wound"
	implements = list(
		/obj/item/natural/cloth/bandage = 60,
		/obj/item/reagent_containers/food/snacks/rogue/honey = 50,
		/obj/item/reagent_containers/glass/bottle = 40,
	)
	time = 3 SECONDS
	surgery_flags = SURGERY_INCISED | SURGERY_RETRACTED
	possible_intents = list(INTENT_HELP)
	skill_used = /datum/skill/misc/medicine
	skill_min = SKILL_LEVEL_NOVICE
	skill_median = SKILL_LEVEL_JOURNEYMAN

/datum/surgery_step/treat_internal_wound/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/list/organs_to_check = list()
	for(var/obj/item/organ/O in C.internal_organs)
		if(O.zone == target_zone)
			organs_to_check += O
	if(!length(organs_to_check))
		to_chat(user, span_warning("There are no organs here to treat."))
		return
	var/has_wounds = FALSE
	for(var/obj/item/organ/O in organs_to_check)
		if(length(O.internal_wounds))
			has_wounds = TRUE
			break
	if(!has_wounds)
		to_chat(user, span_notice("The organs here appear to be healthy internally."))
		return
	to_chat(user, span_notice("You begin treating the internal wounds..."))

/datum/surgery_step/treat_internal_wound/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	if(!iscarbon(target))
		return TRUE
	var/mob/living/carbon/C = target
	var/list/organs_to_check = list()
	for(var/obj/item/organ/O in C.internal_organs)
		if(O.zone == target_zone)
			organs_to_check += O
	var/treated = FALSE
	for(var/obj/item/organ/O in organs_to_check)
		for(var/datum/internal_wound/IW in O.internal_wounds)
			if(IW.apply_item(tool, user))
				to_chat(user, span_green("You successfully treat the [IW.name] in [O.name]."))
				treated = TRUE
				break
		if(treated)
			break
	if(!treated)
		to_chat(user, span_warning("The [tool] doesn't seem to help with the wounds here."))
	return TRUE
