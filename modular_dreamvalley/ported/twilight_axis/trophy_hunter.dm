// Ported from Twilight-Axis: mounting monster-trophy heads in a headhook
// grants small passive stat bonuses while the hook is worn on a belt slot.
// Adapted to this fork: Twilight-Axis's rules used generic COMSIG_HEADHOOK_*
// signals sent by their own modified storage component; this fork's headhook
// uses the stock storage component, so we listen on the generic
// COMSIG_ATOM_ENTERED/EXITED the storage object already fires instead.
// The "aspirant rage" rule's Twilight-Axis-specific has_axedance() branch
// (a separate berserker mechanic this fork doesn't have) was dropped in
// favor of always applying its CON/WIL fallback bonus.
// Twilight-Axis only gave this component to Warrior/Slayer classes via edits
// to their job files; instead of touching base job code, this fork attaches
// it lazily to anyone who equips a headhook, so the trophy bonuses work for
// any class that finds/buys one.

/obj/item/storage/hip/headhook/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!(slot == SLOT_BELT_L || slot == SLOT_BELT_R))
		return
	if(!user.GetComponent(/datum/component/trophy_hunter))
		user.AddComponent(/datum/component/trophy_hunter)

/datum/trophy_rule
	var/name = "trophy rule"
	var/group_id = null

/datum/trophy_rule/proc/matches(obj/item/I)
	return FALSE

/datum/trophy_rule/proc/get_score(obj/item/I)
	return 0

/datum/trophy_rule/proc/build_effect(obj/item/I)
	return null

/datum/trophy_effect
	var/group_id
	var/effect_type
	var/value
	var/aux_value
	var/message

#define TROPHY_GROUP_ARMOR "armor"
#define TROPHY_GROUP_STRONG "strong"
#define TROPHY_GROUP_PERCEPTION "perception"
#define TROPHY_GROUP_RAGE "rage"

#define TROPHY_EFFECT_ARMOR "armor"
#define TROPHY_EFFECT_STR "str"
#define TROPHY_EFFECT_PER "per"
#define TROPHY_EFFECT_RAGE_PACKAGE "rage_package"

/datum/trophy_rule/troll_armor
	name = "troll armor"
	group_id = TROPHY_GROUP_ARMOR

/datum/trophy_rule/troll_armor/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/troll)

/datum/trophy_rule/troll_armor/get_score(obj/item/I)
	if(istype(I, /obj/item/natural/head/troll/cave))
		return 3
	if(istype(I, /obj/item/natural/head/troll/axe))
		return 2
	return 1

/datum/trophy_rule/troll_armor/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_ARMOR
	E.value = get_score(I)
	E.message = "You feel your skin harden with the resilience of a troll."
	return E

/datum/trophy_rule/minotaur_str
	name = "minotaur strength"
	group_id = TROPHY_GROUP_STRONG

/datum/trophy_rule/minotaur_str/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/minotaur)

/datum/trophy_rule/minotaur_str/get_score(obj/item/I)
	return 2

/datum/trophy_rule/minotaur_str/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_STR
	E.value = 1
	E.message = "You feel the crushing strength of the minotaur flow into your limbs."
	return E

/datum/trophy_rule/dragon_per
	name = "dragon perception"
	group_id = TROPHY_GROUP_PERCEPTION

/datum/trophy_rule/dragon_per/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/dragon) && !istype(I, /obj/item/natural/head/dragon/broodmother)

/datum/trophy_rule/dragon_per/get_score(obj/item/I)
	return 1

/datum/trophy_rule/dragon_per/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_PER
	E.value = 1
	E.message = "You feel the dragon's lethal precision sharpen your senses."
	return E

/datum/trophy_rule/aspirant_rage
	name = "aspirant rage"
	group_id = TROPHY_GROUP_RAGE

/datum/trophy_rule/aspirant_rage/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/dragon/broodmother)

/datum/trophy_rule/aspirant_rage/get_score(obj/item/I)
	return 15

/datum/trophy_rule/aspirant_rage/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_RAGE_PACKAGE
	E.value = 1
	E.message = "The fury you felt battling this horror burns through your body once more."
	return E

/datum/component/trophy_hunter
	var/mob/living/carbon/human/owner
	var/obj/item/storage/hip/headhook/active_hook
	var/list/rules = list()
	var/list/applied_effects = list() // group_id => /datum/trophy_effect

/datum/component/trophy_hunter/Initialize()
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	owner = parent

	rules += new /datum/trophy_rule/troll_armor
	rules += new /datum/trophy_rule/minotaur_str
	rules += new /datum/trophy_rule/dragon_per
	rules += new /datum/trophy_rule/aspirant_rage

	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_item_equipped))
	RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_item_dropped))

/datum/component/trophy_hunter/Destroy()
	clear_active_hook()
	clear_effects()
	return ..()

/datum/component/trophy_hunter/proc/on_item_equipped(mob/user, obj/item/I, slot)
	if(!istype(I, /obj/item/storage/hip/headhook))
		return
	if(!(slot == SLOT_BELT_L || slot == SLOT_BELT_R))
		return

	set_active_hook(I)
	rebuild_effects()

/datum/component/trophy_hunter/proc/on_item_dropped(mob/user, obj/item/I)
	if(I != active_hook)
		return

	clear_active_hook()
	clear_effects()

/datum/component/trophy_hunter/proc/set_active_hook(obj/item/storage/hip/headhook/H)
	if(active_hook == H)
		return

	clear_active_hook()
	active_hook = H

	RegisterSignal(active_hook, COMSIG_ATOM_ENTERED, PROC_REF(on_hook_changed))
	RegisterSignal(active_hook, COMSIG_ATOM_EXITED, PROC_REF(on_hook_changed))

/datum/component/trophy_hunter/proc/clear_active_hook()
	if(!active_hook)
		return

	UnregisterSignal(active_hook, list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED
	))
	active_hook = null

/datum/component/trophy_hunter/proc/on_hook_changed()
	SIGNAL_HANDLER
	rebuild_effects()

/datum/component/trophy_hunter/proc/rebuild_effects()
	clear_effects()

	if(!owner || !active_hook)
		return

	var/list/best_effects = list()
	var/list/best_scores = list()

	for(var/obj/item/I in active_hook.contents)
		for(var/datum/trophy_rule/R as anything in rules)
			if(!R.matches(I))
				continue

			var/group_id = R.group_id
			var/score = R.get_score(I)

			if(!(group_id in best_effects) || score > best_scores[group_id])
				best_scores[group_id] = score
				best_effects[group_id] = R.build_effect(I)
			break

	for(var/group_id in best_effects)
		var/datum/trophy_effect/E = best_effects[group_id]
		apply_effect(E)
		applied_effects[group_id] = E

/datum/component/trophy_hunter/proc/clear_effects()
	if(!owner)
		return

	for(var/group_id in applied_effects)
		var/datum/trophy_effect/E = applied_effects[group_id]
		remove_effect(E)

	applied_effects.Cut()

/datum/component/trophy_hunter/proc/apply_effect(datum/trophy_effect/E)
	switch(E.effect_type)
		if(TROPHY_EFFECT_STR)
			owner.change_stat(STATKEY_STR, E.value)

		if(TROPHY_EFFECT_PER)
			owner.change_stat(STATKEY_PER, E.value)

		if(TROPHY_EFFECT_RAGE_PACKAGE)
			owner.change_stat(STATKEY_CON, E.value)
			owner.change_stat(STATKEY_WIL, E.value)

	if(E.message)
		to_chat(owner, span_notice(E.message))

/datum/component/trophy_hunter/proc/remove_effect(datum/trophy_effect/E)
	switch(E.effect_type)
		if(TROPHY_EFFECT_STR)
			owner.change_stat(STATKEY_STR, -E.value)

		if(TROPHY_EFFECT_PER)
			owner.change_stat(STATKEY_PER, -E.value)

		if(TROPHY_EFFECT_RAGE_PACKAGE)
			owner.change_stat(STATKEY_CON, -E.value)
			owner.change_stat(STATKEY_WIL, -E.value)

/datum/component/trophy_hunter/proc/get_armor_bonus_for_zone(def_zone, d_type)
	var/list/valid_damage_types = list("blunt", "slash", "stab", "pierce")
	if(!(d_type in valid_damage_types))
		return 0

	var/datum/trophy_effect/E = applied_effects[TROPHY_GROUP_ARMOR]
	if(!E)
		return 0

	return E.value

#undef TROPHY_GROUP_ARMOR
#undef TROPHY_GROUP_STRONG
#undef TROPHY_GROUP_PERCEPTION
#undef TROPHY_GROUP_RAGE
#undef TROPHY_EFFECT_ARMOR
#undef TROPHY_EFFECT_STR
#undef TROPHY_EFFECT_PER
#undef TROPHY_EFFECT_RAGE_PACKAGE
