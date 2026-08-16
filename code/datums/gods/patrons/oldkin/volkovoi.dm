// Direct successor to Graggar (conquest, war, strategy, bind-breaking). Re-themed as the Old Kin's winter-and-cull
// figure (see Ognica's origin_desc: "the old folk-custom of Volkovoi's winter-offering"). Mechanics carried
// verbatim; flavor shifted from an orc-conqueror god to a folk winter-hunger figure with the same "results,
// victory at a reasonable cost" ethos.
/datum/patron/oldkin/volkovoi
	name = "Volkovoi"
	domain = "God of Winter, Hunger, and the Cull"
	desc = "The god the old folk leave offerings for at the Gallows Oak so that the winter takes only what it must. Volkovoi is the \
	hard arithmetic of a hungry season: who eats, who doesn't, who is strong enough to make it to spring. Some Volkovoi-following \
	households swear his cull is mercy in disguise, a culling of the herd that spares the many by asking a sacrifice of the few, and \
	that a hard winter survived is proof of his favor. Others call it exactly what it looks like - starvation and violence dressed up \
	as necessity - and follow him anyway, because the winter doesn't care which story you tell about it."
	worshippers = "Hunters, the Hungry, Hard Winters' Survivors, and the Cruel"
	mob_traits = list(TRAIT_HORDE, TRAIT_ORGAN_EATER)
	traits_tier = list(TRAIT_NASTY_EATER = CLERIC_T1)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/datum/action/cooldown/spell/graggar/rush					= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/datum/action/cooldown/spell/graggar/hamstring				= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/graggar_net				= CLERIC_T2,
					/datum/action/cooldown/spell/graggar/graggar_battlecry		= CLERIC_T2,
					/datum/action/cooldown/spell/volkovoi_expansion/winters_bite	= CLERIC_T2,
					/datum/action/cooldown/spell/graggar/exsanguinate		 	= CLERIC_T3,
					/datum/action/cooldown/spell/volkovoi_expansion/hungers_call	= CLERIC_T3,
					/datum/action/cooldown/spell/graggar/avatar					= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/graggar		= CLERIC_T4,
	)
	confess_lines = list(
		"VOLKOVOI IS THE BEAST I WORSHIP!",
		"THROUGH THE CULL, SURVIVAL!",
		"THE WINTER GOD DEMANDS ITS DUE!",
	)
	storyteller = /datum/storyteller/volkovoi
	crafting_recipes = list(/datum/crafting_recipe/roguetown/structure/graggar_cross_stone, /datum/crafting_recipe/roguetown/structure/graggar_cross_meat)

	titles = list(
		"Winter-Father",
		"Cull-Bringer",
		"Sinistar",
	)

/datum/patron/oldkin/volkovoi/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus,
	is_inhumen
)
	*is_inhumen = TRUE
	*message_out = span_info("Foul fumes billow outward as [target] is restored!")
	*message_self = span_notice("A noxious scent burns my nostrils, but I feel better!")

	var/bonus = 0

	for(var/obj/effect/decal/cleanable/blood/blood in oview(5, target))
		bonus = min(bonus + 0.1, 2.5)

	if(!bonus)
		return

	*situational_bonus = bonus
	*conditional_buff = TRUE

/datum/patron/oldkin/volkovoi/on_gain(mob/living/living)
	. = ..()

	RegisterSignal(living, COMSIG_LIVING_DRINKED_LIMB_BLOOD, PROC_REF(on_drink_blood))

/datum/patron/oldkin/volkovoi/proc/on_drink_blood(mob/living/drinker, mob/living/target)
	SIGNAL_HANDLER

	drinker.adjust_hydration(8)

/datum/patron/oldkin/volkovoi/on_loss(mob/living/living)
	. = ..()

	UnregisterSignal(living, COMSIG_LIVING_DRINKED_LIMB_BLOOD)

// When bleeding, near blood on ground, folk-shrine, or ritual chalk
/datum/patron/oldkin/volkovoi/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the old folk-shrine cave
	if(istype(get_area(follower), /area/rogue/under/cave/inhumen))
		return TRUE
	// Allows prayer near his cross
	for(var/obj/structure/fluff/psycross/volkovoi/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That consecrated cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if actively bleeding.
	if(follower.bleed_rate > 0)
		return TRUE
	// Allows prayer near blood.
	for(var/obj/effect/decal/cleanable/blood in view(3, get_turf(follower)))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/graggar in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Volkovoi to hear my prayers I must either be near his folk-shrine, near fresh blood, or draw blood of my own!"))
	return FALSE
