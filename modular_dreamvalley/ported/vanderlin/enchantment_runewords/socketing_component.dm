// Ported from Vanderlin (OpenKeep): code/datums/components/modifyable.dm
// (/datum/component/modifications), renamed dv_socketing to avoid any
// ambiguity with unrelated "modifications" naming in this codebase.
//
// Attach with AddComponent(/datum/component/dv_socketing, sockets, max_sockets)
// to make an item socket-capable. Hitting the item with an /obj/item/roguegem
// consumes the gem and grants its rolled effect; hitting it with an
// /obj/item/rune consumes the rune and, once the socketed rune sequence
// matches a /datum/runeword, completes that runeword on the item.
//
// PERMANENCE: matching Vanderlin, sockets/runewords/gem effects are
// permanent and not re-rollable or removable through this component -
// no persistence hooks beyond normal savefile var serialization are needed
// since everything is stored in plain component vars on the item.
/datum/component/dv_socketing
	var/sockets = 0
	var/max_sockets = 0
	/// Ordered list of rune_type strings / gem names already socketed, for runeword matching + examine text.
	var/list/socketed_runes = list()
	/// Instanced /datum/rune_effect that fire on hit (from gems and/or a completed runeword).
	var/list/combat_gem_effects = list()
	var/datum/runeword/active_runeword = null

/datum/component/dv_socketing/Initialize(initial_sockets = 0, initial_max_sockets = 0)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	sockets = initial_sockets
	max_sockets = initial_max_sockets

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_apply_combat_effects))
	RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_apply_combat_effects_ranged))

/datum/component/dv_socketing/proc/on_attackby(obj/item/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/roguegem))
		socket_gem(attacking_item, user)
		return COMPONENT_NO_AFTERATTACK

	if(istype(attacking_item, /obj/item/rune))
		socket_rune(attacking_item, user)
		return COMPONENT_NO_AFTERATTACK

	return NONE

/datum/component/dv_socketing/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(sockets <= 0)
		return

	examine_list += span_notice("This item has [sockets] socket[sockets > 1 ? "s" : ""] ([length(socketed_runes)] filled).")

	if(length(socketed_runes))
		examine_list += span_notice("Socketed: [english_list(socketed_runes)]")

		var/list/descs = get_grouped_effect_descriptions()
		if(length(descs))
			examine_list += span_info("Effects:")
			for(var/line in descs)
				examine_list += span_info("  [line]")

	if(active_runeword)
		examine_list += span_boldnotice("This item bears the [active_runeword.name] runeword!")

/datum/component/dv_socketing/proc/on_apply_combat_effects(obj/item/source, atom/target, mob/living/user, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag || !isliving(target) || !length(combat_gem_effects))
		return

	for(var/datum/rune_effect/effect in combat_gem_effects)
		effect.apply_combat_effect(target, user, 0)

/datum/component/dv_socketing/proc/on_apply_combat_effects_ranged(obj/projectile/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	if(!length(combat_gem_effects) || !isliving(target))
		return

	var/mob/living/shooter = isliving(firer) ? firer : null
	for(var/datum/rune_effect/effect in combat_gem_effects)
		if(!effect.ranged)
			continue
		effect.apply_combat_effect(target, shooter, 0)

/datum/component/dv_socketing/proc/can_socket_gem(obj/item/roguegem/gem)
	if(!istype(gem))
		return FALSE
	return length(socketed_runes) < sockets

/datum/component/dv_socketing/proc/socket_gem(obj/item/roguegem/gem, mob/user)
	if(!can_socket_gem(gem))
		if(user)
			to_chat(user, span_warning("This item cannot accept another gem!"))
		return FALSE

	var/obj/item/item_parent = parent
	var/slot_type = gem.get_slot_type(item_parent)
	var/datum/rune_effect/gem_effect = gem.create_rune_effect_for_slot(slot_type)

	if(!gem_effect)
		if(user)
			to_chat(user, span_warning("[gem] has no effect on this type of item!"))
		return FALSE

	LAZYADD(socketed_runes, gem.name)
	apply_gem_effect(gem_effect)

	if(user)
		to_chat(user, span_notice("You socket [gem] into [item_parent]."))
	qdel(gem)
	return TRUE

/datum/component/dv_socketing/proc/can_socket_rune(obj/item/rune/socket_rune_item)
	if(!istype(socket_rune_item))
		return FALSE
	return length(socketed_runes) < sockets

/datum/component/dv_socketing/proc/socket_rune(obj/item/rune/socket_rune_item, mob/user)
	if(!can_socket_rune(socket_rune_item))
		if(user)
			to_chat(user, span_warning("This item cannot accept another rune!"))
		return FALSE

	LAZYADD(socketed_runes, socket_rune_item.rune_type)

	if(user)
		to_chat(user, span_notice("You socket [socket_rune_item] into [parent]."))
	qdel(socket_rune_item)

	check_runeword_completion(user)
	return TRUE

/datum/component/dv_socketing/proc/apply_gem_effect(datum/rune_effect/effect)
	effect.apply_stat_effect(src, parent)
	LAZYADD(combat_gem_effects, effect)

/datum/component/dv_socketing/proc/check_runeword_completion(mob/user)
	var/obj/item/item_parent = parent

	for(var/runeword_type in GLOB.dv_all_runewords)
		var/datum/runeword/template = GLOB.dv_all_runewords[runeword_type]

		if(length(template.runes) != length(socketed_runes))
			continue

		var/match = TRUE
		for(var/i = 1 to length(template.runes))
			if(LAZYACCESS(socketed_runes, i) != template.runes[i])
				match = FALSE
				break
		if(!match)
			continue

		var/type_allowed = FALSE
		for(var/allowed_type in template.allowed_items)
			if(istype(item_parent, allowed_type))
				type_allowed = TRUE
				break
		if(!type_allowed)
			continue

		apply_runeword(template, user)
		return TRUE

	return FALSE

/datum/component/dv_socketing/proc/apply_runeword(datum/runeword/template, mob/user)
	var/obj/item/item_parent = parent

	active_runeword = template
	item_parent.name = "[template.name] [item_parent.name]"

	for(var/datum/rune_effect/effect in template.instance_stat_bonuses())
		apply_gem_effect(effect)

	for(var/datum/rune_effect/effect in template.instance_combat_effects())
		LAZYADD(combat_gem_effects, effect)

	if(user)
		to_chat(user, span_boldnotice("[item_parent] resonates as the [template.name] runeword completes!"))

/datum/component/dv_socketing/proc/get_grouped_effect_descriptions()
	if(!length(combat_gem_effects))
		return list()

	var/list/groups = list()
	for(var/datum/rune_effect/effect in combat_gem_effects)
		var/key = effect.get_group_key()
		if(!groups[key])
			groups[key] = list()
		groups[key] += effect

	var/list/descriptions = list()
	for(var/key in groups)
		var/list/effects_in_group = groups[key]
		var/datum/rune_effect/first_effect = effects_in_group[1]
		descriptions += first_effect.get_combined_description(effects_in_group)

	return descriptions

/datum/component/dv_socketing/proc/add_socket()
	if(sockets >= max_sockets)
		return FALSE
	sockets++
	return TRUE

/obj/item/proc/dv_make_socketable(sockets = 2, max_sockets = 2)
	AddComponent(/datum/component/dv_socketing, sockets, max_sockets)
