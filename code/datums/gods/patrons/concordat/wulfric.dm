// Reframe of the old Abyssor - kept the "strongest of the pantheon, primal, world-shaking" energy but retargeted
// from a sea/dream god to a war-as-protection/sacrifice/hearth god. Mechanically identical (all Abyssor's traits,
// miracles, and water-adjacent flavor kept, since his fury is now themed as a flood of wrath rather than the sea
// itself - "the tide of war" still reads naturally over the same mechanics).
/datum/patron/concordat/wulfric
	name = "Wulfric"
	domain = "God of War-as-Protection, Sacrifice, and the Hearth"
	desc = "The strongest of the Six; when his fury is loosed, it is said whole fiefs flood with blood before he tires. \
	Wulfric is sworn to no side but the hearth - some hold that his war is a shield, that a father or a guardsman who \
	kills to protect their own does Wulfric's true work, and that his sacrifice is a debt he pays gladly to keep the \
	fire lit. Others see only the flood: a god of ruin who dresses conquest as protection, whose 'sacrifice' asks more \
	of the sacrificed than the sacrificer. Every hearth he has ever warmed was, at some point, a battlefield."
	worshippers = "Sailors, Guardsmen, Sworn Protectors, and Sages"
	mob_traits = list(TRAIT_ABYSSOR_SWIM, TRAIT_SEA_DRINKER)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/aquatic_compulsion	= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/abyssor_wind				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssor_bends			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssor_undertow		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/abyssheal				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/call_mossback			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/call_dreamfiend		= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/abyssal_infusion		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/abyssor		= CLERIC_T4,
	)
	var/paint_miracles = list(
		/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/aquatic_compulsion	= CLERIC_T0,
		/obj/effect/proc_holder/spell/self/abyssor_wind				= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
		/datum/action/cooldown/spell/ink_presence					= CLERIC_T1,
		/datum/action/cooldown/spell/paint_blessing					= CLERIC_T1,
		/datum/action/cooldown/spell/umbral_viscosity				= CLERIC_T2,
		/datum/action/cooldown/spell/transmute_ink					= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/call_dreamfiend		= CLERIC_T3,
		/datum/action/cooldown/spell/recharge_pylon					= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/dream		= CLERIC_T4,
	)
	confess_lines = list(
		"WULFRIC PROTECTS THE HEARTH!",
		"THE HEARTHFIRE'S FURY IS WULFRIC'S WILL!",
		"I GIVE MY BLOOD SO OTHERS NEED NOT GIVE THEIRS!",
	)
	titles = list(
		"Hearth-Warden",
		"Forgotten One",
		"Dreamer",
	)

	storyteller = /datum/storyteller/wulfric

// Near water, hearth, cross, or within the church.
/datum/patron/concordat/wulfric/can_pray(mob/living/follower)
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
	// Allows prayer near hearths.
	for(var/obj/machinery/light/rogue/hearth/H in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer near any body of water turf.
	for(var/turf/open/water in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Wulfric to hear my prayer I must either pray within the church, near a psycross, near a hearth I would defend, or at any body of water so that the tides of prayer may flow.."))
	return FALSE

/datum/patron/concordat/wulfric/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A mist of salt-scented vapour settles on [target]!")
	*message_self = span_notice("I'm invigorated by healing vapours!")

	if(istype(get_turf(target), /turf/open/water))
		*conditional_buff = TRUE
		*situational_bonus = 1.5
