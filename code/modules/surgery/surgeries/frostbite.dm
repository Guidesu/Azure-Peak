/// Frostbite debridement (Weather & Temperature Overhaul, Phase 1 port).
/// Surgically removes the frostbite wound (see code/datums/wounds/types/special.dm) from a limb.
/datum/surgery/debride_frostbite
	name = "Frostbite debridement"
	target_mobtypes = list(/mob/living/carbon/human)

	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_PRECISE_L_FOOT,
	)

	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp,
		/datum/surgery_step/retract,
		/datum/surgery_step/debride_frostbite,
		/datum/surgery_step/cauterize,
	)

/datum/surgery_step/debride_frostbite
	name = "Debride frostbitten tissue"
	time = 8 SECONDS
	accept_hand = FALSE

	implements = list(
		TOOL_SCALPEL = 80,
		TOOL_SHARP = 60,
	)

	target_mobtypes = list(/mob/living/carbon/human)

	surgery_flags = SURGERY_INCISED | SURGERY_RETRACTED
	// No SURGERY_CONSTRUCT flag exists in this repo's surgery_flags_blocked bitfield, and it's
	// moot anyway: construct mobs (TRAIT_IRONMAN) never receive /datum/wound/frostbite in the
	// first place (handle_environment() routes them to the overheat/brittle debuffs instead),
	// so validate_bodypart()'s "has_frostbite" check below already excludes them in practice.

	skill_min = SKILL_LEVEL_JOURNEYMAN
	skill_median = SKILL_LEVEL_EXPERT

/datum/surgery_step/debride_frostbite/validate_bodypart(mob/user, mob/living/carbon/target, obj/item/bodypart/bodypart, target_zone)
	. = ..()
	if(!.)
		return

	var/has_frostbite = FALSE

	for(var/datum/wound/frostbite/F in bodypart.wounds)
		has_frostbite = TRUE

	if(!has_frostbite)
		to_chat(user, span_warning("There is no frostbite to remove on [target]'s [parse_zone(target_zone)]."))

	return has_frostbite

/datum/surgery_step/debride_frostbite/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	display_results(user, target,
		span_notice("I begin removing dead frostbitten tissue from [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins removing frostbitten tissue from [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins removing frostbitten tissue from [target]'s [parse_zone(target_zone)].")
	)
	return TRUE

/datum/surgery_step/debride_frostbite/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	display_results(user, target,
		span_notice("I successfully remove the frostbitten tissue from [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] removes frostbitten tissue from [target]'s [parse_zone(target_zone)]!"),
		span_notice("[user] removes frostbitten tissue from [target]'s [parse_zone(target_zone)]!")
	)

	var/obj/item/bodypart/bodypart = target.get_bodypart(check_zone(target_zone))
	target.apply_damage(5, BRUTE, target_zone)

	// Remove frostbite from treated limb
	if(bodypart)
		for(var/datum/wound/frostbite/F in bodypart.wounds)
			qdel(F)

	// Check if ANY frostbite wounds remain elsewhere, for fullscreen overlay purposes
	var/has_frostbite = FALSE
	var/list/zones = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
	)

	for(var/zone in zones)
		var/obj/item/bodypart/BP = target.get_bodypart(zone)
		if(!BP)
			continue

		for(var/datum/wound/W in BP.wounds)
			if(istype(W, /datum/wound/frostbite))
				has_frostbite = TRUE
				break

		if(has_frostbite)
			break

	// Only clear the frostbite overlay if there's no other frostbite left
	if(!has_frostbite && iscarbon(target))
		var/mob/living/carbon/C = target
		C.clear_fullscreen("frostbite")

	return TRUE
