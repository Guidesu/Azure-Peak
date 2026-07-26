// Ported from Vanderlin (OpenKeep): code/datums/runeword/gem_effects/*.dm
// (gemerald.dm, blortz.dm, toper.dm, saffira.dm, dorpel.dm, rubor.dm),
// trimmed to only reference rune_effect subtypes actually ported here.
// Mapped onto this repo's existing /obj/item/roguegem color subtypes in
// gems_socketing.dm rather than duplicating a parallel gem item tree.

/datum/gem_effect/gemerald // green - gemerald
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/status/poison, "data_template" = list(list(15, 30))),
		list("type" = /datum/rune_effect/status/bleed, "data_template" = list(list(15, 30))),
		list("type" = /datum/rune_effect/stat/force, "data_template" = list(list(1, 3))),
	)
	possible_armor_effects = list(
		list("type" = /datum/rune_effect/stat/force, "data_template" = list(list(1, 2))),
	)

/datum/gem_effect/blortz // blue - blortz (cold-flavored, folded to necrotic/tox per damage.dm notes)
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/damage/necrotic, "data_template" = list(list(2, 5), list(4, 8))),
	)
	possible_shield_effects = list(
		list("type" = /datum/rune_effect/reflection, "data_template" = list(list(2, 5))),
	)

/datum/gem_effect/toper // yellow - toper (lightning-flavored)
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/damage/lightning, "data_template" = list(list(2, 5), list(5, 9))),
	)
	possible_armor_effects = list(
		list("type" = /datum/rune_effect/fear_aura, "data_template" = list(list(5, 15))),
	)

/datum/gem_effect/saffira // violet - saffira
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/life_steal, "data_template" = list(list(1, 3))),
	)
	possible_armor_effects = list(
		list("type" = /datum/rune_effect/stat/throw_force, "data_template" = list(list(1, 2))),
	)

/datum/gem_effect/dorpel // diamond - dorpel (holy/divine-flavored)
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/damage/holy, "data_template" = list(list(2, 6), list(6, 10))),
	)
	possible_shield_effects = list(
		list("type" = /datum/rune_effect/reflection, "data_template" = list(list(3, 6))),
	)

/datum/gem_effect/rubor // ruby - rontz (fire-flavored)
	possible_weapon_effects = list(
		list("type" = /datum/rune_effect/damage/fire, "data_template" = list(list(3, 8), list(8, 12))),
	)
	possible_armor_effects = list(
		list("type" = /datum/rune_effect/stat/force, "data_template" = list(list(1, 2))),
	)
