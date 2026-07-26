// Direct successor to Baotha (hedonism, addiction, anguish, heartbreak). Re-themed toward harvest, hearth-luck,
// and community debt (see Auxentia's origin_desc: "a coin left for Hausvette at the hearth is no less pious than
// a vow sworn before Auxentius's magistrates"). Mechanics carried over verbatim; flavor shifted from a scorned
// hedonist goddess to a harvest/hearth figure whose debts are communal rather than personal ruin.
/datum/patron/oldkin/hausvette
	name = "Hausvette"
	domain = "Goddess of Harvest, Hearth-Luck, and Community Debt"
	desc = "The one you thank when the harvest comes in and the one you owe when it doesn't. Hausvette keeps the ledger of small \
	favors a village runs on: who fed whose children through a hard winter, whose roof got fixed on whose labor, who's owed a debt \
	that isn't written down anywhere but everyone remembers. Most households say her hearth-luck rewards generosity, that what you \
	give to your neighbors comes back doubled through her hand. Others - those who've watched a community turn on someone who took \
	more than they gave - know her as a keeper of grudges too, and that a debt owed to Hausvette's flock is collected one way or another."
	worshippers = "Farmers, Neighbors, Debtors, and the Community-Bound"
	mob_traits = list(TRAIT_DEPRAVED, TRAIT_CICERONE)
	traits_tier = list(TRAIT_CRACKHEAD = CLERIC_T1)
	crafting_recipes = list(/datum/crafting_recipe/roguetown/structure/baotha_cross_stone, /datum/crafting_recipe/roguetown/structure/baotha_cross_meat)
	miracles = list(/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/baothavice				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/baothablessings			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 						= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/insufflation					= CLERIC_T1,
					/obj/effect/proc_holder/spell/targeted/touch/loversruin			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/griefflower				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/blowingdust	= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/lasthigh					= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/joyride					= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/painkiller				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/baotha			= CLERIC_T4,
	)
	confess_lines = list(
		"HAUSVETTE KEEPS THE HEARTH!",
		"WHAT IS OWED IS REMEMBERED!",
		"HAUSVETTE IS MY JOY!",
	)
	storyteller = /datum/storyteller/hausvette

	titles = list(
		"Hearth-Keeper",
		"Harvest Mother",
		"Debt-Rememberer",
	)

/datum/patron/oldkin/hausvette/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the old folk-shrine cave
	if(istype(get_area(follower), /area/rogue/under/cave/inhumen))
		return TRUE
	// Allows prayer near her cross
	for(var/obj/structure/fluff/psycross/hausvette/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That consecrated cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayers in the bath house.
	if(istype(get_area(follower), /area/rogue/indoors/town/bath))
		return TRUE
	// Allows prayers if actively high on drugs.
	if(follower.has_status_effect(/datum/status_effect/buff/ozium) || follower.has_status_effect(/datum/status_effect/buff/moondust) || follower.has_status_effect(/datum/status_effect/buff/moondust_purest) || follower.has_status_effect(/datum/status_effect/buff/druqks) || follower.has_status_effect(/datum/status_effect/buff/starsugar))
		return TRUE
	// Allows prayers if the user is drunk.
	if(follower.has_status_effect(/datum/status_effect/buff/drunk))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/baotha in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Hausvette to hear my prayers I must either be near her folk-shrine, within the town's bathhouse, or actively partaking in one of various types of nose-candy!"))
	return FALSE

#define HAUSVETTE_SUFFERING_DIVIDER 3.535 // max bonus at 50 pain/bleedrate and pain_mod = 1

/datum/patron/oldkin/hausvette/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus,
	is_inhumen
)
	*is_inhumen = TRUE
	*message_out = span_info("Hedonistic impulses and emotions throb all about from [target].")
	*message_self = span_notice("An intoxicating rush of narcotic delight soothes my suffering!")

	if(!ishuman(target))
		*message_self = span_notice("An intoxicating rush of narcotic delight flows through me!")
		return

	var/mob/living/carbon/human/human_target = target
	var/bonus = 0

	if(human_target.has_status_effect(/datum/status_effect/buff/druqks) \
	|| human_target.has_status_effect(/datum/status_effect/buff/drunk))
		bonus += 0.5

	if(human_target.get_stress_event(/datum/stressevent/lasthigh))
		bonus += 0.5

	if(!HAS_TRAIT(target, TRAIT_NOPAIN) || HAS_TRAIT(target, TRAIT_CRACKHEAD))
		var/raw_suffering = 0

		for(var/datum/wound/wound in human_target.get_wounds())
			raw_suffering += wound.woundpain + wound.bleed_rate

		var/suffering = sqrt(raw_suffering) / HAUSVETTE_SUFFERING_DIVIDER
		var/to_add = HAS_TRAIT(target, TRAIT_DEPRAVED) ? suffering : suffering * human_target.physiology.pain_mod
		bonus += min(to_add, 2)

	*conditional_buff = TRUE
	*situational_bonus = bonus

#undef HAUSVETTE_SUFFERING_DIVIDER
