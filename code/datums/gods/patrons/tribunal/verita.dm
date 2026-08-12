// No old-god source - written fresh as the Tribunal's third seat: truth, testimony, and contracts, rounding out
// Praecursor's Word and Custodius's enforcement with the evidentiary half of a courtroom. Mechanically sparse by
// design, per the brief, though given a slightly fuller kit than Kamenka since truth-detection spells already
// exist to draw from.
/datum/patron/tribunal/verita
	name = "Verita"
	domain = "Goddess of Truth, Testimony, and Contracts"
	desc = "The goddess who cannot be lied to, or so her faithful claim - Verita is the weight behind a sworn oath, the discomfort \
	that settles over a courtroom when someone's testimony doesn't add up. Magistrates and witnesses alike invoke her to bind a \
	contract or steady a nervous tongue, and her devout hold that a world where words mean nothing is a world already lost. Skeptics \
	note that truth, enforced by an institution, has a way of becoming whatever the institution needs it to be - and that Verita's \
	name is invoked as often to extract confessions as to prevent injustice."
	worshippers = "Magistrates, Notaries, Witnesses, Oathkeepers, and the Wrongly Accused"
	mob_traits = list(TRAIT_EXTEROCEPTION)
	traits_tier = list(TRAIT_JUSTICARSIGHT = CLERIC_T2)
	miracles = list(/datum/action/cooldown/spell/touch/orison				= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/diagnose			= CLERIC_ORI,
					/datum/action/cooldown/spell/miracle/heal 				= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle		= CLERIC_T1,
					/datum/action/cooldown/spell/undivided/twinned_gaze		= CLERIC_T2,
					/datum/action/cooldown/spell/verita/zone_of_truth		= CLERIC_T2,
					/datum/action/cooldown/spell/verita/binding_contract	= CLERIC_T3,
					/datum/action/cooldown/spell/miracle/fortify			= CLERIC_T3,
					/datum/action/cooldown/spell/verita/final_verdict		= CLERIC_T4,
	)
	confess_lines = list(
		"VERITA SEES THROUGH EVERY LIE!",
		"MY WORD IS MY BOND!",
		"THE TRUTH NEEDS NO DEFENSE, ONLY A WITNESS!",
	)

	titles = list(
		"The Unlied-To",
		"Witness-Sworn",
		"Keeper of Oaths",
	)

// Within the church, near a psycross, or wherever an oath or contract is actively being sworn.
/datum/patron/tribunal/verita/can_pray(mob/living/follower)
	. = ..()
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	to_chat(follower, span_danger("For Verita to hear my prayer I must either pray within the church or near a psycross, so that my words might be witnessed truly.."))
	return FALSE

/datum/patron/tribunal/verita/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A clarifying stillness settles over [target], as if witnessed by something impartial!")
	*message_self = span_notice("I feel plainly, undeniably seen!")

	if(HAS_TRAIT(target, TRAIT_PACIFISM))
		*conditional_buff = TRUE
		*situational_bonus = 1.5
