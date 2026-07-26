// Ported from Vanderlin (OpenKeep):
//   code/datums/runeword/word_combos/flamebrand.dm
//   code/datums/runeword/word_combos/scattershot.dm
// Flamebrand's spell_actions (granting a fireball spell) is dropped - see
// runeword_base.dm note. Scattershot's projectile-manipulation rune_effects
// (extra_projectiles, bounce, fork) are dropped since projectiles.dm was
// not ported (heavy dependency on Vanderlin-specific orbital/fork/split
// projectile components not present in this codebase).
/datum/runeword/flamebrand
	name = "Flamebrand"
	runes = list("tir", "ral")
	allowed_items = list(/obj/item/rogueweapon)
	stat_bonuses = list(
		/datum/rune_effect/stat/force = list(5),
		/datum/rune_effect/stat/throw_force = list(3),
	)
	combat_effects = list(
		/datum/rune_effect/damage/fire = list(3, 8),
	)

/datum/runeword/scattershot
	name = "Scattershot"
	runes = list("eld", "nef", "eth")
	allowed_items = list(/obj/item/rogueweapon)
	stat_bonuses = list(
		/datum/rune_effect/stat/force = list(2),
	)
	combat_effects = list(
		/datum/rune_effect/status/bleed = list(30, 2),
	)
