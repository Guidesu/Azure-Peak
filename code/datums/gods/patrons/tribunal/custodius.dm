// Direct successor to Undivided (the Divine Pantheon's "unity" godhead). Re-themed as Custodius, god of
// enforcement, oathbinding, and correction - the Tribunal's answer to "many hands, one law."
/datum/patron/tribunal/custodius
	name = "Custodius"
	domain = "God of Enforcement, Oathbinding, and Correction"
	desc = "The Word given hands. Where Praecursor speaks the law, Custodius is the one who sees it kept - the oath that binds a \
	sworn magistrate, the correction visited on whoever breaks it. His faithful see themselves as instruments of a necessary order, \
	that a law unenforced is no law at all, and that mercy without correction only breeds more of what needed correcting. Others see \
	in Custodius the zealotry of the Inquisition made divine: a god who cannot tell the difference between justice and cruelty so \
	long as both wear the same oath."
	worshippers = "Magistrates, Inquisitors, Enforcers, Oathkeepers, and Correctionists"
	mob_traits = list(TRAIT_UNDIVIDED)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/datum/action/cooldown/spell/miracle/ignition/undivided		= CLERIC_T0,
					/datum/action/cooldown/spell/undivided/recuperation			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal/undivided			= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/datum/action/cooldown/spell/undivided/twinned_gaze			= CLERIC_T1,
					/datum/action/cooldown/spell/undivided/perseverance			= CLERIC_T2,
					/datum/action/cooldown/spell/undivided/undivided_spellpack	= CLERIC_T2,
					/datum/action/cooldown/spell/custodius_expansion/oathbind	= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/fortify/undivided		= CLERIC_T3,
					/datum/action/cooldown/spell/undivided/gallow_humor			= CLERIC_T3,
					/datum/action/cooldown/spell/custodius_expansion/corrective_strike	= CLERIC_T3,
					/datum/action/cooldown/spell/undivided/undivided_battlecry	= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/undivided	= CLERIC_T4
	)
	confess_lines = list(
		"THE OATH SHALL SHIELD MY SOUL!",
		"I SERVE THE LAW ENFORCED!",
		"CORRECTION IS MERCY, PROPERLY UNDERSTOOD!",
	)
	storyteller = /datum/storyteller/praecursor // no unique storyteller for this one, since its so broad. No real reason to have a unique storyteller - Custodius contributes to the Tribunal's follower count.

	titles = list(
		"Enforcer",
		"The Bound Hand",
	)

/datum/patron/tribunal/custodius/can_pray(mob/living/follower)
	. = ..()
	// More restricted, needs to be within range of a pantheon cross or the church itself.
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE

/datum/patron/tribunal/custodius/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A wreath of stern, corrective power passes over [target]!") // we're always good, apparently.
	*message_self = ("I'm bathed in enforcing power!")

	*conditional_buff = TRUE
	*situational_bonus = 2
