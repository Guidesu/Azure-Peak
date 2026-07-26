// Direct successor to Xylix (trickery, freedom, inspiration) - re-themed toward trade, travel, borders, and the
// luck of the road, matching Ostrovia's origin_desc reference to "Viator's patronage of trade, travel, and the
// luck of the road."
/datum/patron/concordat/viator
	name = "Viator"
	domain = "God of Trade, Travel, Borders, and the Luck of the Road"
	desc = "The Wayward God, both famous and infamous for his sway over fortune found on the open road. Viator is known for the inspiration \
	of many a caravaner's tale, and speaks through his gift to man: the Tarot deck, read at crossroads and border-posts alike. Traders swear \
	his luck rewards the honest bargain and the fair toll, that he blesses whoever keeps the roads open between strangers. Smugglers and \
	highwaymen swear the same luck rewards whoever's quicker or cleverer at the crossing, honest bargain or none. Every border he's said to \
	have walked personally, and every border still remembers him a little differently."
	worshippers = "Traders, Caravaners, Gamblers, Bards, and the Silver-Tongued"
	mob_traits = list(TRAIT_XYLIX)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/xylixslip				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/ventriloquism			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/mimicry				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/tipscales				= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/vicious_mockery		= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/vendetta				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/mastersillusion		= CLERIC_T2,
					/obj/effect/proc_holder/spell/targeted/touch/parlor_trick	= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/abscond				= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/xylix		= CLERIC_T4,
	)
	traits_tier = list(TRAIT_XYLIX_DEVOTEE = CLERIC_T0) //Requires a minimal holy skill or the 'Devotee' virtue to unlock. Rerolls luck events
	confess_lines = list(
		"AUXENTIUS IS MY LIGHT!",
		"MILUŠE SEES ALL BY MOONLIGHT!",
		"IGNATIUS PROVIDES!",
		"WULFRIC GUARDS THE HEARTH!",
		"ALL SOULS FIND THEIR WAY TO MORWENNA!",
		"HAHAHAHA! AHAHAHA! HAHAHAHA!",
		"HANDWERRA'S HANDS NEVER TIRE!",
		"AURELIAN NEEDS NO PRIEST!",
		"VOLKOVOI IS THE BEAST I WORSHIP!",
		"HAUSVETTE IS MY JOY!",
		"REBUKE THE HERETICAL- PRAECURSOR ENDURES!",
	)
	storyteller = /datum/storyteller/viator

	titles = list(
		"Wayward God",
		"Luck",
		"Roadwarden",
	)

// Near a gambling machine, cross, or within the church
/datum/patron/concordat/viator/can_pray(mob/living/follower)
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
	// Allows prayer near gambling machines.
	for(var/obj/structure/roguemachine/lottery_roguetown/L in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Viator to hear my prayer I must either pray within the church, near a psycross, or near a machine of fortune blessed by the wayward god.."))
	return FALSE

/datum/patron/concordat/viator/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A fugue seems to manifest briefly across [target]!")
	*message_self = span_notice("My wounds vanish as if they had never been there! ")

	if(prob(50))
		*conditional_buff = TRUE
		*situational_bonus = rand(1, 2.5)
