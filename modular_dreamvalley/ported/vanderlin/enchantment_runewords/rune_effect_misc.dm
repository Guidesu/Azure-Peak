// Ported from Vanderlin (OpenKeep):
//   code/datums/runeword/rune_effects/lifesteal.dm
//   code/datums/runeword/rune_effects/reflection.dm
//   code/datums/runeword/rune_effects/fear_aura.dm
// (resistance.dm / mana_drain.dm / player_stats.dm / projectiles.dm /
// melee_conversions.dm omitted - see enchantment_runewords final report for why)

/datum/rune_effect/life_steal
	ranged = TRUE
	var/stealing_amount = 0

/datum/rune_effect/life_steal/get_description()
	return "Steals [stealing_amount] life per hit."

/datum/rune_effect/life_steal/get_group_key()
	return "lifesteal"

/datum/rune_effect/life_steal/get_combined_description(list/effects)
	var/total_min = 0
	for(var/datum/rune_effect/life_steal/effect in effects)
		total_min += effect.stealing_amount
	return "Steals [total_min] life per hit."

/datum/rune_effect/life_steal/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		stealing_amount = effects[1]

/datum/rune_effect/life_steal/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	if(isliving(user) && isliving(target) && target.stat != DEAD)
		user.heal_ordered_damage(stealing_amount, list(BRUTE, BURN, OXY))


/datum/rune_effect/reflection
	var/reflect = 3

/datum/rune_effect/reflection/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		reflect = effects[1]

/datum/rune_effect/reflection/get_description()
	return "Reflects [reflect] damage when struck in melee."

/datum/rune_effect/reflection/get_combined_description(list/effects)
	var/total_increase = 0
	for(var/datum/rune_effect/reflection/effect in effects)
		total_increase += effect.reflect
	return "Reflects [total_increase] damage when struck in melee."

/datum/rune_effect/reflection/apply_stat_effect(datum/component/dv_socketing/source, obj/item/item)
	RegisterSignal(item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_equipped))
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(remove_stats))

/datum/rune_effect/reflection/proc/check_equipped(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!source.item_action_slot_check(slot, equipper))
		remove_stats(source, equipper)
		return
	equipper.AddElement(/datum/element/relay_attackers)
	RegisterSignal(equipper, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(retaliate))

/datum/rune_effect/reflection/proc/remove_stats(obj/item/source, mob/living/equipper)
	SIGNAL_HANDLER
	UnregisterSignal(equipper, COMSIG_ATOM_WAS_ATTACKED)

/datum/rune_effect/reflection/proc/retaliate(mob/living/attacked, mob/living/attacker, damage)
	SIGNAL_HANDLER
	if(istype(attacker))
		attacker.apply_damage(reflect, BRUTE)


/datum/rune_effect/fear_aura
	var/fear_chance = 10
	COOLDOWN_DECLARE(fear_cooldown)

/datum/rune_effect/fear_aura/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		fear_chance = effects[1]

/datum/rune_effect/fear_aura/get_description()
	return "[fear_chance]% chance to frighten attackers when struck."

/datum/rune_effect/fear_aura/get_combined_description(list/effects)
	var/total_increase = 0
	for(var/datum/rune_effect/fear_aura/effect in effects)
		total_increase += effect.fear_chance
	return "[total_increase]% chance to frighten attackers when struck."

/datum/rune_effect/fear_aura/apply_stat_effect(datum/component/dv_socketing/source, obj/item/item)
	RegisterSignal(item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_equipped))
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(remove_stats))

/datum/rune_effect/fear_aura/proc/check_equipped(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!source.item_action_slot_check(slot, equipper))
		remove_stats(source, equipper)
		return
	equipper.AddElement(/datum/element/relay_attackers)
	RegisterSignal(equipper, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(retaliate))

/datum/rune_effect/fear_aura/proc/remove_stats(obj/item/source, mob/living/equipper)
	SIGNAL_HANDLER
	UnregisterSignal(equipper, COMSIG_ATOM_WAS_ATTACKED)

/datum/rune_effect/fear_aura/proc/retaliate(mob/living/attacked, mob/living/attacker, damage)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, fear_cooldown) || !isliving(attacker))
		return
	if(!prob(fear_chance))
		return
	COOLDOWN_START(src, fear_cooldown, 10 SECONDS)
	to_chat(attacker, span_userdanger("A wave of terror washes over you!"))
	attacker.Stun(1 SECONDS)
