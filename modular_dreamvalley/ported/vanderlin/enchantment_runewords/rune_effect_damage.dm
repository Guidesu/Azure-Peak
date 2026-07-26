// Ported from Vanderlin (OpenKeep): code/datums/runeword/rune_effects/damage.dm
//
// Vanderlin's version uses a separate elemental damage/resistance layer
// (FIRE_DAMAGE/COLD_DAMAGE/LIGHTNING_DAMAGE + apply_elemental_damage()) that
// does not exist in this codebase - here, damage types are BRUTE/BURN/TOX/
// OXY/CLONE/STAMINA only. "Elemental" flavors below are folded onto BURN
// (fire/lightning) or TOX (cold/necrotic flavor text only, no real chill
// mechanic exists here) and apply straight through mob/living/apply_damage().
/datum/rune_effect/damage
	ranged = TRUE
	var/damage_type = BURN
	var/min_damage = 1
	var/max_damage = 3
	var/flavor = "elemental"

/datum/rune_effect/damage/get_description()
	return "Adds [min_damage]-[max_damage] [flavor] damage"

/datum/rune_effect/damage/get_group_key()
	return "[flavor] damage"

/datum/rune_effect/damage/get_combined_description(list/effects)
	var/total_min = 0
	var/total_max = 0
	for(var/datum/rune_effect/damage/effect in effects)
		total_min += effect.min_damage
		total_max += effect.max_damage
	return "Adds [total_min]-[total_max] [flavor] damage"

/datum/rune_effect/damage/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		min_damage = effects[1]
	if(effects.len >= 2)
		max_damage = effects[2]

/datum/rune_effect/damage/proc/get_bonus_damage()
	return rand(min_damage, max_damage)

/datum/rune_effect/damage/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target))
		return
	var/damage = get_bonus_damage()
	if(damage <= 0)
		return
	target.apply_damage(damage, damage_type)
	if(user)
		to_chat(user, span_notice("Your weapon deals [damage] additional [flavor] damage!"))

/datum/rune_effect/damage/fire
	name = "fire damage"
	damage_type = BURN
	flavor = "fire"

/datum/rune_effect/damage/fire/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	. = ..()
	if(istype(target))
		target.adjust_fire_stacks(1)

/datum/rune_effect/damage/lightning
	name = "lightning damage"
	damage_type = BURN
	flavor = "lightning"

/datum/rune_effect/damage/holy
	name = "holy damage"
	damage_type = BURN
	flavor = "holy"

/datum/rune_effect/damage/holy/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target))
		return
	var/damage = get_bonus_damage()
	if(damage <= 0)
		return
	if(target.mob_biotypes & MOB_UNDEAD)
		damage *= 2
	target.apply_damage(damage, BURN)
	if(user)
		to_chat(user, span_notice("Your weapon deals [damage] additional holy damage!"))

/datum/rune_effect/damage/necrotic
	name = "necrotic damage"
	damage_type = TOX
	flavor = "necrotic"

/datum/rune_effect/damage/necrotic/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(!istype(target))
		return
	if(target.mob_biotypes & MOB_UNDEAD)
		return // heals undead in Vanderlin's original intent (no damage); we just no-op rather than fake a heal hook
	var/damage = get_bonus_damage()
	if(damage <= 0)
		return
	target.apply_damage(damage, TOX)
	if(user)
		to_chat(user, span_notice("Your weapon deals [damage] additional necrotic damage!"))
