// Ported from Vanderlin (OpenKeep): code/datums/runeword/rune_effects/status_effect.dm
//
// Vanderlin gates trigger chance through a get_status_mod()/STATUS_KEY_*
// resistance layer that does not exist here, so trigger chance below is a
// flat prob() roll with no target-side resistance modifier. The "chill"
// variant is dropped: Vanderlin uses /datum/status_effect/debuff/chilled,
// which has no equivalent in this codebase, and faking a slow effect via an
// unrelated status type would be more misleading than omitting it.
/datum/rune_effect/status
	ranged = TRUE
	var/trigger_chance = 25
	var/intensity = 1

/datum/rune_effect/status/get_description()
	return "[trigger_chance]% chance to [name]"

/datum/rune_effect/status/get_combined_description(list/effects)
	var/total_chance = 0
	for(var/datum/rune_effect/status/effect in effects)
		total_chance += effect.trigger_chance
	return "[total_chance]% chance to [name]"

/datum/rune_effect/status/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		trigger_chance = effects[1]
	if(effects.len >= 2)
		intensity = effects[2]

/datum/rune_effect/status/bleed
	name = "bleed"

/datum/rune_effect/status/bleed/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target) || !prob(trigger_chance))
		return
	target.apply_damage(intensity * 2, BRUTE)

/datum/rune_effect/status/ignite
	name = "ignite"

/datum/rune_effect/status/ignite/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target) || !prob(trigger_chance))
		return
	target.adjust_fire_stacks(intensity)

/datum/rune_effect/status/poison
	name = "poison"

/datum/rune_effect/status/poison/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target) || !prob(trigger_chance) || !target.reagents)
		return
	target.reagents.add_reagent(/datum/reagent/toxin/venom, 2)
