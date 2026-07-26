// Ported from Vanderlin (OpenKeep): code/datums/runeword/rune_effects/_base.dm
//
// A /datum/rune_effect describes one discrete bonus a socketed gem or a
// completed runeword grants: a stat bump, a combat proc, a resistance, etc.
// These are plain data holders instantiated by /datum/component/dv_socketing
// (see socketing_component.dm) - they are not signal-registering datums
// themselves except where they explicitly RegisterSignal on the item they're
// attached to (see rune_effect_player.dm).
/datum/rune_effect
	var/name = ""
	/// If TRUE, this effect can trigger off ranged (projectile) hits as well as melee.
	var/ranged = FALSE

/datum/rune_effect/New(list/effect_data)
	if(effect_data)
		apply_effects_from_list(effect_data)

/// Populate this effect's tunables from the runeword/gem's stored data list.
/datum/rune_effect/proc/apply_effects_from_list(list/effects)
	return

/// Called on melee/ranged hit to apply the combat portion of this effect.
/datum/rune_effect/proc/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	return

/// Called once when the effect is socketed/applied, to touch item stats directly
/// or register any persistent signals (e.g. equip/unequip stat buffs).
/datum/rune_effect/proc/apply_stat_effect(datum/component/dv_socketing/source, obj/item/item)
	return

/datum/rune_effect/proc/get_description()
	return name || "Unknown effect"

/// Used to group multiple stacked instances of the "same" effect together
/// in examine text (e.g. two "+force" gems become one "+6 physical damage" line).
/datum/rune_effect/proc/get_group_key()
	return name

/datum/rune_effect/proc/get_combined_description(list/effects)
	return get_description()
