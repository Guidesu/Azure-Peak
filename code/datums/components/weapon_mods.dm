/// Weapon modification component — tracks attached mods and applies/reverts
/// their stat modifications to the parent weapon.
///
/// This component is attached to a weapon when a mod is applied and removed
/// when the last mod is removed. It stores a list of attached mods keyed by
/// slot, and provides procs to apply/remove individual mods.
///
/// Design adapted from CEV-Eris gun_upgrade system, fantasy-reskinned.
/datum/component/weapon_mods
	/// List of attached mods, keyed by slot: list(WEAPON_MOD_SLOT_BLADE = /obj/item/weapon_mod)
	var/list/attached_mods = list()

/datum/component/weapon_mods/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SUCCESS, PROC_REF(on_attack_success))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))

/datum/component/weapon_mods/Destroy()
	for(var/slot in attached_mods)
		var/obj/item/weapon_mod/mod = attached_mods[slot]
		if(!QDELETED(mod))
			revert_mod(mod)
			mod.forceMove(get_turf(parent))
	attached_mods = list()
	return ..()

// ---------------------------------------------------------------------------
// Examine
// ---------------------------------------------------------------------------

/datum/component/weapon_mods/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!length(attached_mods))
		return
	examine_list += span_notice("This weapon has the following modifications:")
	for(var/slot in attached_mods)
		var/obj/item/weapon_mod/mod = attached_mods[slot]
		if(mod)
			examine_list += "\t- [span_notice("[mod.name]")] ([slot])"

// ---------------------------------------------------------------------------
// Attack-by: allow removing mods with a screwdriver or by clicking with an empty hand
// ---------------------------------------------------------------------------

/datum/component/weapon_mods/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER
	if(!attacking_item)
		return
	// Allow removing mods with a whetstone-like tool or by using a crowbar/screwdriver
	if(istype(attacking_item, /obj/item/weapon_mod))
		var/obj/item/weapon_mod/new_mod = attacking_item
		if(!can_apply(new_mod, user))
			return
		apply_mod(new_mod, user)
		return COMPONENT_NO_AFTERATTACK
	// Tools that can remove mods
	if(attacking_item.tool_behaviour == TOOL_CROWBAR || istype(attacking_item, /obj/item/rogueweapon/hammer))
		try_remove_prompt(user)
		return COMPONENT_NO_AFTERATTACK

/datum/component/weapon_mods/proc/try_remove_prompt(mob/user)
	var/list/removable = list()
	for(var/slot in attached_mods)
		var/obj/item/weapon_mod/mod = attached_mods[slot]
		if(mod)
			removable[mod.name] = slot
	if(!length(removable))
		to_chat(user, span_warning("There are no mods to remove from [parent]."))
		return
	var/choice = tgui_input_list(user, "Which modification to remove?", "Remove Mod", removable)
	if(!choice || QDELETED(parent) || QDELETED(user))
		return
	var/slot = removable[choice]
	var/obj/item/weapon_mod/mod = attached_mods[slot]
	if(!mod)
		return
	remove_mod(slot, user)

// ---------------------------------------------------------------------------
// Core apply/remove logic
// ---------------------------------------------------------------------------

/// Check if a mod can be applied to this weapon.
/datum/component/weapon_mods/proc/can_apply(obj/item/weapon_mod/mod, mob/user)
	if(!mod)
		return FALSE
	var/obj/item/weapon = parent
	// Check slot compatibility
	if(!(mod.slot in WEAPON_MOD_SLOTS))
		if(user)
			to_chat(user, span_warning("[mod] has an invalid slot."))
		return FALSE
	// Check if slot is already occupied
	if(attached_mods[mod.slot])
		if(user)
			to_chat(user, span_warning("[weapon] already has a mod in the [mod.slot] slot."))
		return FALSE
	// Check weapon type compatibility
	// WEAPON_TAG_ALL means any /obj/item (but we still require it to be a weapon-like item)
	var/is_compatible = FALSE
	for(var/type_path in mod.valid_weapon_types)
		if(istype(weapon, type_path))
			is_compatible = TRUE
			break
	if(!is_compatible)
		if(user)
			to_chat(user, span_warning("[mod] cannot be applied to [weapon]."))
		return FALSE
	return TRUE

/// Apply a mod to the weapon. Moves the mod item into the weapon's contents.
/datum/component/weapon_mods/proc/apply_mod(obj/item/weapon_mod/mod, mob/user)
	var/obj/item/weapon = parent
	attached_mods[mod.slot] = mod
	mod.forceMove(weapon)
	apply_mod_effects(mod)
	weapon.update_force_dynamic()
	weapon.update_wdefense_dynamic()
	if(user)
		user.visible_message(
			span_notice("[user] attaches [mod] to [weapon]."),
			span_notice("I attach [mod] to [weapon].")
		)
		playsound(weapon.loc, 'sound/items/bsmith1.ogg', 50, TRUE)

/// Remove a mod from the weapon by slot. Returns the mod to the user's hands or the floor.
/datum/component/weapon_mods/proc/remove_mod(slot, mob/user)
	var/obj/item/weapon_mod/mod = attached_mods[slot]
	if(!mod)
		return
	var/obj/item/weapon = parent
	revert_mod(mod)
	attached_mods -= slot
	weapon.update_force_dynamic()
	weapon.update_wdefense_dynamic()
	mod.forceMove(get_turf(weapon))
	if(user)
		user.put_in_hands(mod)
		user.visible_message(
			span_notice("[user] removes [mod] from [weapon]."),
			span_notice("I remove [mod] from [weapon].")
		)
		playsound(weapon.loc, 'sound/items/bsmith1.ogg', 50, TRUE)
	// If no mods remain, remove the component
	if(!length(attached_mods))
		qdel(src)

// ---------------------------------------------------------------------------
// Stat modification — apply and revert
// ---------------------------------------------------------------------------

/// Apply the stat effects of a mod to the weapon.
/datum/component/weapon_mods/proc/apply_mod_effects(obj/item/weapon_mod/mod)
	var/obj/item/weapon = parent
	for(var/key in mod.upgrades)
		var/val = mod.upgrades[key]
		apply_upgrade(weapon, key, val)

/// Revert the stat effects of a mod from the weapon.
/datum/component/weapon_mods/proc/revert_mod(obj/item/weapon_mod/mod)
	var/obj/item/weapon = parent
	for(var/key in mod.upgrades)
		var/val = mod.upgrades[key]
		revert_upgrade(weapon, key, val)
	weapon.update_force_dynamic()
	weapon.update_wdefense_dynamic()

/// Apply a single upgrade key/value pair to a weapon.
/datum/component/weapon_mods/proc/apply_upgrade(obj/item/weapon, key, val)
	switch(key)
		if(WMOD_FORCE_ADD)
			weapon.force += val
			if(weapon.force_wielded)
				weapon.force_wielded += val
		if(WMOD_FORCE_MULT)
			weapon.force = round(weapon.force * val)
			if(weapon.force_wielded)
				weapon.force_wielded = round(weapon.force_wielded * val)
		if(WMOD_WDEFENSE_ADD)
			weapon.wdefense += val
		if(WMOD_WDEFENSE_WBONUS_ADD)
			weapon.wdefense_wbonus += val
		if(WMOD_ARMOR_PEN_ADD)
			weapon.armor_penetration += val
		if(WMOD_MAX_INTEGRITY_ADD)
			weapon.modify_max_integrity(weapon.max_integrity + val, can_break = FALSE)
		if(WMOD_INTDAMAGE_MULT)
			weapon.intdamage_factor *= val
		if(WMOD_MINSTR_ADD)
			weapon.minstr = max(0, weapon.minstr + val)
		if(WMOD_WBALANCE_SHIFT)
			weapon.wbalance = clamp(weapon.wbalance + val, WBALANCE_HEAVY, WBALANCE_SWIFT)
		if(WMOD_THROWFORCE_ADD)
			weapon.throwforce += val
		if(WMOD_BLOCK_CHANCE_ADD)
			weapon.block_chance += val
		if(WMOD_COVERAGE_ADD)
			if(istype(weapon, /obj/item/rogueweapon/shield))
				var/obj/item/rogueweapon/shield/S = weapon
				S.coverage += val
		if(WMOD_CHARGESPEED_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.chargingspeed = round(C.chargingspeed * val)
		if(WMOD_RELOADTIME_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.reloadtime = round(C.reloadtime * val)
		if(WMOD_DAMFACTOR_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.damfactor *= val
		if(WMOD_ACCFACTOR_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.accfactor *= val
		if(WMOD_SHARPNESS_SET)
			weapon.sharpness = val

/// Revert a single upgrade key/value pair from a weapon.
/datum/component/weapon_mods/proc/revert_upgrade(obj/item/weapon, key, val)
	switch(key)
		if(WMOD_FORCE_ADD)
			weapon.force -= val
			if(weapon.force_wielded)
				weapon.force_wielded -= val
		if(WMOD_FORCE_MULT)
			weapon.force = round(weapon.force / val)
			if(weapon.force_wielded)
				weapon.force_wielded = round(weapon.force_wielded / val)
		if(WMOD_WDEFENSE_ADD)
			weapon.wdefense -= val
		if(WMOD_WDEFENSE_WBONUS_ADD)
			weapon.wdefense_wbonus -= val
		if(WMOD_ARMOR_PEN_ADD)
			weapon.armor_penetration -= val
		if(WMOD_MAX_INTEGRITY_ADD)
			weapon.modify_max_integrity(weapon.max_integrity - val, can_break = FALSE)
		if(WMOD_INTDAMAGE_MULT)
			weapon.intdamage_factor /= val
		if(WMOD_MINSTR_ADD)
			weapon.minstr = max(0, weapon.minstr - val)
		if(WMOD_WBALANCE_SHIFT)
			weapon.wbalance = clamp(weapon.wbalance - val, WBALANCE_HEAVY, WBALANCE_SWIFT)
		if(WMOD_THROWFORCE_ADD)
			weapon.throwforce -= val
		if(WMOD_BLOCK_CHANCE_ADD)
			weapon.block_chance -= val
		if(WMOD_COVERAGE_ADD)
			if(istype(weapon, /obj/item/rogueweapon/shield))
				var/obj/item/rogueweapon/shield/S = weapon
				S.coverage -= val
		if(WMOD_CHARGESPEED_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.chargingspeed = round(C.chargingspeed / val)
		if(WMOD_RELOADTIME_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.reloadtime = round(C.reloadtime / val)
		if(WMOD_DAMFACTOR_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.damfactor /= val
		if(WMOD_ACCFACTOR_MULT)
			if(istype(weapon, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
				var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/C = weapon
				C.accfactor /= val
		if(WMOD_SHARPNESS_SET)
			// Revert to default sharpness based on weapon type
			if(istype(weapon, /obj/item/rogueweapon))
				weapon.sharpness = initial(weapon.sharpness)

// ---------------------------------------------------------------------------
// On-hit effects (burn, toxin, holy damage)
// ---------------------------------------------------------------------------

/datum/component/weapon_mods/proc/on_attack_success(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	for(var/slot in attached_mods)
		var/obj/item/weapon_mod/mod = attached_mods[slot]
		if(!mod || !mod.upgrades)
			continue
		if(mod.upgrades[WMOD_BURN_DAMAGE])
			var/dmg = mod.upgrades[WMOD_BURN_DAMAGE]
			target.apply_damage(dmg, BURN)
			target.visible_message(
				span_warning("Flames leap from [parent]!"),
				span_warning("Flames sear you from [parent]!")
			)
		if(mod.upgrades[WMOD_TOX_DAMAGE])
			var/dmg = mod.upgrades[WMOD_TOX_DAMAGE]
			target.apply_damage(dmg, TOX)
			target.visible_message(
				span_warning("A sickly venom drips from [parent]!"),
				span_warning("Venom burns in your veins from [parent]!")
			)
		if(mod.upgrades[WMOD_HOLY_DAMAGE])
			var/dmg = mod.upgrades[WMOD_HOLY_DAMAGE]
			if(target.mob_biotypes & MOB_UNDEAD)
				dmg *= 2
			target.apply_damage(dmg, BURN)
			target.visible_message(
				span_warning("Holy light blazes from [parent]!"),
				span_warning("Divine fire sears you from [parent]!")
			)
