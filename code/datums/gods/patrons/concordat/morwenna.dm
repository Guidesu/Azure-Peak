// Merge of the old Necra (death, afterlife) and Matthios (exchange, alchemy, theft, greed, debt) - death, memory,
// debt, and inheritance now sit under one figure: what you owed in life follows you to Morwenna's ledger, and what
// you leave behind is claimed by someone else's.
/datum/patron/concordat/morwenna
	name = "Morwenna"
	domain = "Goddess of Death, Memory, Debt, and Inheritance"
	desc = "The Veiled Lady of the underworld keeps two books: one of the dead, one of the debts they left unpaid. \
	Mourners and gravekeepers know her as the quiet reckoning that comes for everyone in the end; merchants and \
	moneylenders know her as the goddess who never truly forgives a ledger, only inherits it. Some say her accounting \
	is mercy - that death cancels cruelty and debt alike, that inheritance lets the dead's kindness outlive them. \
	Others say she is the coldest of the Six, that she profits equally from a mourner's grief and a debtor's ruin, \
	and that nothing - not even dying - truly settles what you owe her."
	worshippers = "Mourners, Gravekeepers, Merchants, Moneylenders, Highwaymen, and Downtrodden Peasants"
	mob_traits = list(TRAIT_SOUL_EXAMINE, TRAIT_NOSTINK, TRAIT_FREEMAN, TRAIT_MATTHIOS_EYES, TRAIT_SEEPRICES_SHITTY)
	/// Carried over from the old Matthios/Inhumen crafting_recipes pattern - Morwenna is the only Concordat god that
	/// needs this, so it's declared locally instead of adding it to the whole /datum/patron/concordat parent.
	var/list/crafting_recipes = list(/datum/crafting_recipe/roguetown/sewing/bandithood, /datum/crafting_recipe/roguetown/structure/matthios_cross_stone, /datum/crafting_recipe/roguetown/structure/matthios_cross_meat)
	miracles = list(/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/necras_sight				= CLERIC_T0,
					/datum/action/cooldown/spell/matthios/freemans_tools		= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 						= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/avert						= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/locate_dead 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/fog_ward					= CLERIC_T1, // Not bugged, only appears on fog rounds!
					/datum/action/cooldown/spell/matthios/mammonite				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance	= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/necra_consecrate			= CLERIC_T2,
					/datum/action/cooldown/spell/matthios/transact				= CLERIC_T2,
					/datum/action/cooldown/spell/matthios/barter				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/bless_cross				= CLERIC_T3,
					/datum/action/cooldown/spell/matthios/equalize				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/deaths_door				= CLERIC_T4,
					/datum/action/cooldown/spell/matthios/churn					= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/matthios		= CLERIC_T3,
	)
	confess_lines = list(
		"ALL SOULS FIND THEIR WAY TO MORWENNA!",
		"THE VEILED LEDGER IS OUR FINAL REPOSE!",
		"MORWENNA COLLECTS WHAT IS OWED!",
		"I FEAR NOT DEATH, MY LADY AWAITS ME - DEBTS AND ALL!",
	)
	storyteller = /datum/storyteller/morwenna

	titles = list(
		"Veiled Lady",
		"Corpse Mother",
		"Undermaiden",
		"Lord", // catchall for various titles carried over from Matthios
	)

/datum/patron/concordat/morwenna/post_equip(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/human = pious
		if(human.mind && length(crafting_recipes))
			for(var/recipe_path in crafting_recipes)
				human.mind.teach_crafting_recipe(recipe_path)

// Near a grave, coin, cross, or within the church
/datum/patron/concordat/morwenna/can_pray(mob/living/follower)
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
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer if the user has more than 100 mammon on them.
	var/mammon_count = get_mammons_in_atom(follower)
	if(mammon_count >= 100)
		return TRUE
	// Spend 5 mammon to pray.
	var/obj/item/held_item = follower.get_active_held_item()
	if(istype(held_item, /obj/item/roguecoin))
		var/helditemvalue = held_item.get_real_price()
		if(helditemvalue >= 5)
			qdel(held_item)
			return TRUE
	to_chat(follower, span_danger("For Morwenna to hear my prayer I must either pray within the church, near a psycross, near a grave, or flaunt or offer up wealth to settle my ledger.."))
	return FALSE

/datum/patron/concordat/morwenna/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A sense of quiet respite radiates from [target]!")
	*message_self = span_notice("I feel the Undermaiden's gaze turn from me for now!")

	var/bonus = 0

	if(iscarbon(target))
		var/mob/living/carbon/carbon = target
		if(carbon.health <= (carbon.maxHealth * 0.25))
			bonus += 2.5
		if(user.has_status_effect(/datum/status_effect/buff/necran_mists))
			bonus += 1.25

	if(HAS_TRAIT(target, TRAIT_FREEMAN))
		bonus += 2.5

	if(!bonus)
		return

	*conditional_buff = TRUE
	*situational_bonus = bonus
