// Ported from Vanderlin (OpenKeep): code/datums/runeword/runes.dm (runeword datum half)
// A runeword is a fixed sequence of rune keywords that, once socketed into
// an item's sockets in that exact order, transforms the item: renames it,
// applies bonus stat/combat rune_effects, and marks it as "complete" so it
// can't accept more runes. Spell-action grants (Vanderlin's spell_actions
// var) are NOT ported - this repo has no add_item_action() helper analogous
// to Vanderlin's, and re-deriving the whole item-granted-spell-action
// framework is out of scope for a gem/runeword port.
GLOBAL_LIST_INIT(dv_all_runewords, dv_initialize_runewords())

/proc/dv_initialize_runewords()
	var/list/runewords = list()
	for(var/datum/runeword/runeword_type as anything in subtypesof(/datum/runeword))
		runewords[runeword_type] = new runeword_type()
	return runewords

/datum/runeword
	var/name = ""
	/// Ordered lowercase rune_type sequence required, e.g. list("tir", "ral").
	var/list/runes = list()
	/// Item types (or subtypes thereof) this runeword is allowed to complete on.
	var/list/allowed_items = list()
	/// Rune-effect types (with their data args) applied once, permanently, on completion.
	var/list/stat_bonuses = list()
	/// Rune-effect types (with their data args) applied on every hit once completed.
	var/list/combat_effects = list()

/datum/runeword/proc/instance_stat_bonuses()
	var/list/instanced = list()
	for(var/effect_type in stat_bonuses)
		instanced += new effect_type(stat_bonuses[effect_type])
	return instanced

/datum/runeword/proc/instance_combat_effects()
	var/list/instanced = list()
	for(var/effect_type in combat_effects)
		instanced += new effect_type(combat_effects[effect_type])
	return instanced
