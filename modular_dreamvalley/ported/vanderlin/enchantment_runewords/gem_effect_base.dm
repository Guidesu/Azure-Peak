// Ported from Vanderlin (OpenKeep):
//   code/datums/runeword/gem_effects/_base.dm
//   code/datums/runeword/gem_effects/gem_cuts/_base.dm
//
// A /datum/gem_effect is what a gem "rolls" when it generates its
// socketing properties: separate possible effects depending on which slot
// category (weapon/armor/shield) it ends up socketed into. Quality
// (chipped/regular/flawless/perfect, see _defines.dm) scales the numbers.
/datum/gem_effect
	var/quality = DV_GEM_REGULAR

	var/weapon_effect_type = null
	var/list/weapon_effect_data = list()
	var/armor_effect_type = null
	var/list/armor_effect_data = list()
	var/shield_effect_type = null
	var/list/shield_effect_data = list()

	var/list/possible_weapon_effects = list()
	var/list/possible_armor_effects = list()
	var/list/possible_shield_effects = list()

	var/is_cut = FALSE
	var/datum/gem_cut/cut_type = null
	var/list/possible_cuts = list()

/datum/gem_effect/New(gem_quality = DV_GEM_REGULAR, forced_cut = null)
	quality = gem_quality
	cut_type = forced_cut
	initialize_effects()

/datum/gem_effect/proc/initialize_effects()
	if(cut_type)
		initialize_cut_effects()
	else
		initialize_random_effects()

/datum/gem_effect/proc/initialize_random_effects()
	if(length(possible_weapon_effects))
		var/chosen = pick(possible_weapon_effects)
		weapon_effect_type = chosen["type"]
		weapon_effect_data = generate_effect_data(chosen["data_template"])

	if(length(possible_armor_effects))
		var/chosen = pick(possible_armor_effects)
		armor_effect_type = chosen["type"]
		armor_effect_data = generate_effect_data(chosen["data_template"])

	if(length(possible_shield_effects))
		var/chosen = pick(possible_shield_effects)
		shield_effect_type = chosen["type"]
		shield_effect_data = generate_effect_data(chosen["data_template"])

/datum/gem_effect/proc/initialize_cut_effects()
	var/datum/gem_cut/new_cut = new cut_type()
	new_cut.setup_cut(quality)
	new_cut.transfer_properties(src)

/datum/gem_effect/proc/generate_effect_data(list/template)
	var/list/result = list()
	var/multiplier = quality

	for(var/i = 1 to length(template))
		var/value = template[i]
		if(islist(value))
			result += rand(value[1] * multiplier, value[2] * multiplier)
		else
			result += value * multiplier

	return result

/datum/gem_effect/proc/get_description()
	var/list/descriptions = list()

	if(weapon_effect_type)
		var/datum/rune_effect/temp_effect = new weapon_effect_type(weapon_effect_data)
		descriptions += "Weapon: [temp_effect.get_description()]"
		qdel(temp_effect)
	if(armor_effect_type)
		var/datum/rune_effect/temp_effect = new armor_effect_type(armor_effect_data)
		descriptions += "Armor: [temp_effect.get_description()]"
		qdel(temp_effect)
	if(shield_effect_type)
		var/datum/rune_effect/temp_effect = new shield_effect_type(shield_effect_data)
		descriptions += "Shield: [temp_effect.get_description()]"
		qdel(temp_effect)

	return jointext(descriptions, "\n")

/datum/gem_effect/proc/create_effect_for_slot(slot_type)
	switch(slot_type)
		if(DV_SOCKET_SLOT_WEAPON)
			if(weapon_effect_type)
				return new weapon_effect_type(weapon_effect_data)
		if(DV_SOCKET_SLOT_ARMOR)
			if(armor_effect_type)
				return new armor_effect_type(armor_effect_data)
		if(DV_SOCKET_SLOT_SHIELD)
			if(shield_effect_type)
				return new shield_effect_type(shield_effect_data)
	return null


/// A gem_cut is a guaranteed (non-random) roll applied by the gem-cutting
/// profession, transferring its fixed effect types onto the gem_effect.
/datum/gem_cut
	var/name = "generic"
	var/downgrade_chance = 10

	var/weapon_effect_type
	var/list/weapon_effect_data
	var/armor_effect_type
	var/list/armor_effect_data
	var/shield_effect_type
	var/list/shield_effect_data

/datum/gem_cut/proc/setup_cut(multiplier)
	return

/datum/gem_cut/proc/transfer_properties(datum/gem_effect/dest)
	dest.weapon_effect_type = weapon_effect_type
	dest.weapon_effect_data = weapon_effect_data
	dest.armor_effect_type = armor_effect_type
	dest.armor_effect_data = armor_effect_data
	dest.shield_effect_type = shield_effect_type
	dest.shield_effect_data = shield_effect_data
