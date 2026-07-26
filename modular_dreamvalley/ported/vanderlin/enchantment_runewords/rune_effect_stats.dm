// Ported from Vanderlin (OpenKeep): code/datums/runeword/rune_effects/stats.dm
// Flat item-stat modifiers (force, throw force, weight). Applied once,
// directly to the item, when the gem/runeword is socketed.
/datum/rune_effect/stat
	var/increase = 3

/datum/rune_effect/stat/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		increase = effects[1]

/datum/rune_effect/stat/get_combined_description(list/effects)
	var/total_increase = 0
	for(var/datum/rune_effect/stat/effect in effects)
		total_increase += effect.increase
	return "+[total_increase] [name]"

/datum/rune_effect/stat/force
	name = "physical damage"

/datum/rune_effect/stat/force/apply_stat_effect(datum/component/dv_socketing/source, obj/item/item)
	item.force += increase
	if(item.force_wielded)
		item.force_wielded += increase * 2

/datum/rune_effect/stat/throw_force
	name = "thrown physical damage"

/datum/rune_effect/stat/throw_force/apply_stat_effect(datum/component/dv_socketing/source, obj/item/item)
	item.throwforce += increase

// NOTE: Vanderlin also has /datum/rune_effect/stat/lightweight, which shaves
// a percentage off item.item_weight (a continuous mass value). This repo's
// item base class only has w_class (a weight-class enum, not a scalar mass),
// so there's no meaningful percentage to shave. Omitted rather than faked.
