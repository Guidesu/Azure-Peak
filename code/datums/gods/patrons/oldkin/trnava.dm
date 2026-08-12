// Direct successor to the Mossmother (hags, primordial evils, poisoned boons, eternal life). Old Kin's most
// "central" folk figure and the faith's godhead - the hag-cult reframed as fierce, poison-and-cure motherhood
// rather than a defeated evil waiting for revenge.
/datum/patron/oldkin/trnava
	name = "Trnava"
	domain = "Goddess of Forests, Poison-and-Cure, and Fierce Motherhood"
	desc = "The mother of the deep wood, old as the roots and twice as patient. Trnava's hands hold both the poison and the antidote, \
	and she makes no promise about which you'll be given - only that a mother protects her own by whatever means the forest provides. \
	Herbalists and midwives keep her jars of dried leaf and root, trusting that her cures are offered freely to those who ask with \
	respect. Others who cross her - or cross what she's chosen to protect - find that the same forest that heals will just as readily \
	poison, and that a mother's fierceness makes no distinction between mercy and vengeance when her children are threatened."
	worshippers = "Herbalists, Midwives, Foresters, and Mothers"
	mob_traits = list(TRAIT_EMPATH, TRAIT_ROT_EATER)
	undead_hater = FALSE
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/pestra_leech			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/infestation			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/pestilent_blade		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/pestra_heal			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/attach_bodypart		= CLERIC_T2,
					/datum/action/cooldown/spell/trnava/thorn_burst				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/cure_rot				= CLERIC_T3,
					/datum/action/cooldown/spell/trnava/mothers_wrath			= CLERIC_T3,
					/datum/action/cooldown/spell/trnava/poison_ward				= CLERIC_T3,
					/datum/action/cooldown/spell/trnava/wild_regrowth			= CLERIC_T4,
	)
	confess_lines = list(
		"TRNAVA SEES YOU!",
		"THE FOREST GIVES, THE FOREST TAKES!",
		"I AM THE LAND, AND THE LAND PROTECTS ITS OWN!",
		"CROSS ME, AND TASTE THE ROOT INSTEAD OF THE CURE.",
	)

	titles = list(
		"Forest Mother",
		"Root-Warden",
		"The Old Green Mother",
	)

/datum/patron/oldkin/trnava/can_pray(mob/living/follower)
	. = ..()
	to_chat(follower, span_danger("I do not need to pray to Trnava, she is with me always in the green."))
	return FALSE	//she doesn't need loud prayers, just quiet offerings

/datum/patron/oldkin/trnava/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A poultice-scent of root and leaf settles over [target], and their wounds knit closed!")
	*message_self = span_notice("My wounds close as if tended by unseen, careful hands.")

	if(iscarbon(target))
		var/mob/living/carbon/carbon = target
		if(!(carbon.mobility_flags & MOBILITY_STAND) && !carbon.buckled)
			*conditional_buff = TRUE
			*situational_bonus = 1
