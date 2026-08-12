// No old-god source - written fresh as Ignatius's stiller co-equal (see Kamenrad's origin_desc: "Kamenka, god of
// stillness, preservation, duty, and stone"). Mechanically sparse by design; a small, thematically-appropriate
// trait set rather than a full miracle list, since there's no mechanical precedent to carry over.
/datum/patron/severance/kamenka
	name = "Kamenka"
	domain = "God of Stillness, Preservation, Duty, and Stone"
	desc = "The stiller half of a single being torn in two, Kamenka is the terrace that holds soil for a great-grandchild not yet born, \
	the wall that has not fallen because someone kept it standing. Those who keep his shrine say his patience is the deepest kind of \
	care: a duty carried out long after anyone is watching, a promise kept to people who aren't born yet. Others say a god who values \
	preservation above all else is a god who'd rather see a dying thing propped up than let it go, and that duty without change is just \
	another word for stagnation."
	worshippers = "Masons, Elders, Terrace-Keepers, and the Dutiful"
	mob_traits = list(TRAIT_NOSLEEP)
	traits_tier = list(TRAIT_FORGEBLESSED = CLERIC_T1)
	miracles = list(/datum/action/cooldown/spell/touch/orison				= CLERIC_ORI,
					/datum/action/cooldown/spell/kamenka/stones_patience	= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 				= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle		= CLERIC_T1,
					/datum/action/cooldown/spell/kamenka/preserve			= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/fortify			= CLERIC_T2,
					/datum/action/cooldown/spell/mending/malum				= CLERIC_T2,
					/datum/action/cooldown/spell/kamenka/petrify			= CLERIC_T3,
					/datum/action/cooldown/spell/malum/fortress				= CLERIC_T4,
					/datum/action/cooldown/spell/kamenka/monument			= CLERIC_T4,
	)
	confess_lines = list(
		"KAMENKA ENDURES!",
		"WHAT STANDS, STANDS FOR A REASON!",
		"MY DUTY OUTLASTS ME!",
	)
	titles = list(
		"Stonekeeper",
		"The Still One",
		"Terrace-Warden",
	)

// Within the church, near a psycross, or near worked stone/masonry - Kamenka rewards patience over spectacle.
/datum/patron/severance/kamenka/can_pray(mob/living/follower)
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
	// Allows prayer in the smith's building - stone and duty both.
	if(istype(get_area(follower), /area/rogue/indoors/town/dwarfin))
		return TRUE
	to_chat(follower, span_danger("For Kamenka to hear my prayer I must either pray within the church, near a psycross, or near worked stone raised with patient hands.."))
	return FALSE

/datum/patron/severance/kamenka/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A steadying stillness settles over [target], like stone that has stood for centuries!")
	*message_self = span_notice("I feel unshakeable, like something built to last!")

	if(!(target.mobility_flags & MOBILITY_MOVE))
		*conditional_buff = TRUE
		*situational_bonus = 1.5
