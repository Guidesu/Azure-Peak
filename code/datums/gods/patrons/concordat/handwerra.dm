// Merge of Malum (fire, destruction, rebirth / craft god of smiths) and Pestra (decay, disease, medicine) -
// unified as the patron of craft, knowledge, invention, teaching, and medicine: the maker's hands and the
// healer's hands are the same hands.
/datum/patron/concordat/handwerra
	name = "Handwerra"
	domain = "Goddess of Craft, Knowledge, Invention, Teaching, and Medicine"
	desc = "Opinionless goddess of hands put to use. Handwerra teaches that a well-forged blade, a well-set bone, and a well-taught \
	lesson are all the same work, seen from different angles: the world remade, a little, by someone who bothered to learn how. \
	Smiths and physicians alike claim her patronage without contradiction, and she offers no verdict on what her students choose to \
	build or mend. Some say this even-handedness is wisdom, the closest thing to fairness a craft can offer. Others say a goddess \
	who blesses the scalpel and the blade with the same unblinking care is no different from indifference, and that Handwerra simply \
	does not care what her gifts are used for."
	worshippers = "Smiths, Physicians, Apothecaries, Miners, Engineers, and the Sick"
	mob_traits = list(TRAIT_FORGEBLESSED, TRAIT_EMPATH, TRAIT_ROT_EATER)
	miracles = list(/datum/action/cooldown/spell/touch/orison				= CLERIC_ORI,
					/datum/action/cooldown/spell/miracle/ignition/malum		= CLERIC_T0,
					/datum/action/cooldown/spell/malum/reconstruction       = CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/diagnose				= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/pestra_leech			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 				= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle		= CLERIC_T1,
					/datum/action/cooldown/spell/malum/vigorousexchange		= CLERIC_T1,
					/datum/action/cooldown/spell/arcyne_forge/miracle		= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/infestation			= CLERIC_T1,
					/datum/action/cooldown/spell/malum/hammerfall			= CLERIC_T2,
					/datum/action/cooldown/spell/mending/malum				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/pestilent_blade		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/pestra_heal			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/attach_bodypart		= CLERIC_T2,
					/datum/action/cooldown/spell/malum/heatmetal			= CLERIC_T3,
					/datum/action/cooldown/spell/malum_blessing				= CLERIC_T3,
					/datum/action/cooldown/spell/miracle/fortify				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/cure_rot				= CLERIC_T3,
					/datum/action/cooldown/spell/malum/fortress				= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/malum	= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/pestra		= CLERIC_T4,
	)
	confess_lines = list(
		"HANDWERRA'S HANDS NEVER TIRE!",
		"TRUE VALUE IS IN THE TOIL!",
		"I AM AN INSTRUMENT OF CREATION AND OF CARE!",
		"MY AFFLICTION IS MY TESTAMENT!",
	)
	storyteller = /datum/storyteller/handwerra

	titles = list(
		"Forgemother",
		"Maker",
		"Lady of Pestilence", // legacy Pestra epithet, still murmured by the sick
		"Rot Mother",
	)

// Near a smelter, hearth, well, within the smithy, physician's hall, or the church
/datum/patron/concordat/handwerra/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer in the smith's building.
	if(istype(get_area(follower), /area/rogue/indoors/town/dwarfin))
		return TRUE
	// Allows prayer in the apothecary's building.
	if(istype(get_area(follower), /area/rogue/indoors/town/physician))
		return TRUE
	// Allows prayer in the heartbeast's sanctum.
	if(istype(get_area(follower), /area/rogue/indoors/town/pestra_sanctum))
		return TRUE
	// Allows prayer near hearths.
	for(var/obj/machinery/light/rogue/hearth/H in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer near smelters.
	for(var/obj/machinery/light/rogue/smelter/H in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer near wells.
	for(var/obj/structure/well/W in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Handwerra to hear my prayer I must either pray within the church, the smithy, the physician's hall, near a psycross, smelter, hearth, or well.."))
	return FALSE

/datum/patron/concordat/handwerra/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A tempering, clinical warmth is discharged out of [target]!")
	*message_self = span_info("I feel the heat of a forge - and the care of a steady hand - soothing my pains!")

	var/list/firey_stuff = list(/obj/machinery/light/rogue/torchholder, /obj/machinery/light/rogue/campfire, /obj/machinery/light/rogue/hearth, /obj/machinery/light/rogue/candle, /obj/machinery/light/rogue/forge)
	var/bonus = 0

	// extra healing for every source of fire/light near us
	for(var/obj/obj in oview(5, user))
		if(!(obj.type in firey_stuff))
			continue

		bonus = min(bonus + 0.5, 2.5)

	if(iscarbon(target))
		var/mob/living/carbon/carbon = target
		if(!(carbon.mobility_flags & MOBILITY_STAND) && !carbon.buckled) // laying on the floor
			bonus += 1
			target.adjustToxLoss(-1*15) // flat 15 tox healing on lesser miracle effect application
			target.blood_volume = min(target.blood_volume + (BLOOD_VOLUME_SURVIVE / 3), BLOOD_VOLUME_NORMAL)

	if(!bonus)
		return

	*situational_bonus = bonus
	*conditional_buff = TRUE
