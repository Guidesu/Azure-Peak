// Direct successor to Dendor (earth and nature) - re-themed as the active/growth half of the Severance (see
// Ognica's origin_desc: "Ignatius, god of growth, change, risk, and fire"). The more prayer-friendly, active
// godhead of the two - Kamenka is the quieter co-equal.
/datum/patron/severance/ignatius
	name = "Ignatius"
	domain = "God of Growth, Change, Risk, and Fire"
	desc = "The restless half of a single being torn in two, Ignatius is the fire that clears old growth to make room for new, the risk \
	that a settlement takes when it rebuilds on the same ash twice. Those who follow him say his fire is generous: it burns away what \
	no longer serves so that something better can take root, and that a life spent chasing change is a life well spent. Others say a \
	god of pure risk and change owes nothing to what he burns down, and that Ignatius's gifts always cost more than they first appear to."
	worshippers = "Druids, Gamblers, Smiths, Settlers, and Madmen"
	mob_traits = list(TRAIT_KNEESTINGER_IMMUNITY, TRAIT_LEECHIMMUNE)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/spiderspeak 			= CLERIC_T0,
					/obj/effect/proc_holder/spell/targeted/blesscrop			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/wildshape				= CLERIC_T2,
					/obj/effect/proc_holder/spell/targeted/conjure_vines		= CLERIC_T3,
					/obj/effect/proc_holder/spell/self/howl/call_of_the_moon	= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/ignatius		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/root_affinity			= CLERIC_T4,
	)
	confess_lines = list(
		"IGNATIUS PROVIDES!",
		"FROM ASH, NEW GROWTH!",
		"I ANSWER THE CALL OF RISK AND CHANGE!",
	)
	storyteller = /datum/storyteller/ignatius
	titles = list(
		"Ashfather",
		"Kindler",
		"Restless One",
	)

// In grove, bog, near ash, cross, or ritual chalk.
/datum/patron/severance/ignatius/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the druid tower + houses in the forest
	if(istype(get_area(follower), /area/rogue/indoors/shelter/woods))
		return TRUE
	// Allows prayer in outdoors wilderness, such as bog
	if(istype(get_area(follower), /area/rogue/outdoors/rtfield))
		return TRUE
	for(var/obj/structure/flora/roguetree/wise in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("I must either be in Ignatius's wilds, the Grove, near a wise tree, or near a Pantheon Cross for the Ashfather to hear my prays..."))
	return FALSE

/datum/patron/severance/ignatius/on_gain(mob/living/H)
	. = ..()
	H.AddComponent(/datum/component/wise_tree_alert)

/datum/patron/severance/ignatius/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A rush of primal energy spirals about [target]!")
	*message_self = span_notice("I'm infused with primal energies!")

	var/list/natural_stuff = list(/obj/structure/flora/roguegrass, /obj/structure/flora/roguetree, /obj/structure/flora/rogueshroom, /obj/structure/soil, /obj/structure/flora/newtree, /obj/structure/flora/tree, /obj/structure/glowshroom)
	var/bonus = 0

	// the more natural stuff around US, the more we heal
	for (var/obj/obj in oview(5, user))
		if(!(obj.type in natural_stuff))
			continue

		bonus = min(bonus + 0.1, 2)

	for(var/obj/structure/flora/roguetree/wise/tree in oview(5, user))
		bonus += 1.5

	if(!bonus)
		return

	*conditional_buff = TRUE
	*situational_bonus = bonus
