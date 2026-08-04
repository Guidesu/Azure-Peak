/// Weapon modification items — apply to weapons to modify their stats.
/// Use a mod item on a weapon to attach it. Use a crowbar or hammer on a
/// modded weapon to remove mods.
///
/// Ported and adapted from CEV-Eris gun_upgrade system, fantasy-reskinned.

// ---------------------------------------------------------------------------
// Base weapon mod item
// ---------------------------------------------------------------------------

/obj/item/weapon_mod
	name = "weapon modification"
	desc = "A generic weapon modification."
	icon = 'icons/roguetown/weapons/weapon_mods.dmi'
	icon_state = "placeholder"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	/// Which slot this mod occupies on the weapon.
	var/slot = WEAPON_MOD_SLOT_BLADE
	/// List of weapon types this mod can be applied to. Uses WEAPON_TAG_* defines.
	var/list/valid_weapon_types = list(WEAPON_TAG_ALL)
	/// Associative list of upgrade key -> value. See WMOD_* defines.
	var/list/upgrades = list()
	/// Optional visual overlay to add to the weapon when attached.
	var/overlay_state = null
	/// Optional color for the overlay.
	var/overlay_color = null

/obj/item/weapon_mod/examine(mob/user)
	. = ..()
	. += span_notice("Slot: [slot]")
	if(length(upgrades))
		. += span_notice("Effects:")
		for(var/key in upgrades)
			. += "\t- [format_upgrade(key, upgrades[key])]"

/// Format an upgrade key/value pair for examine output.
/obj/item/weapon_mod/proc/format_upgrade(key, val)
	switch(key)
		if(WMOD_FORCE_ADD)
			return "[val > 0 ? "+" : ""][val] damage"
		if(WMOD_FORCE_MULT)
			return "[round((val - 1) * 100)]% damage"
		if(WMOD_WDEFENSE_ADD)
			return "[val > 0 ? "+" : ""][val] defense"
		if(WMOD_WDEFENSE_WBONUS_ADD)
			return "[val > 0 ? "+" : ""][val] wielded defense"
		if(WMOD_ARMOR_PEN_ADD)
			return "[val > 0 ? "+" : ""][val] armor penetration"
		if(WMOD_MAX_INTEGRITY_ADD)
			return "[val > 0 ? "+" : ""][val] durability"
		if(WMOD_INTDAMAGE_MULT)
			return "[round((val - 1) * 100)]% integrity damage"
		if(WMOD_MINSTR_ADD)
			return "[val > 0 ? "+" : ""][val] STR requirement"
		if(WMOD_WBALANCE_SHIFT)
			return val > 0 ? "swifter balance" : "heavier balance"
		if(WMOD_THROWFORCE_ADD)
			return "[val > 0 ? "+" : ""][val] throw damage"
		if(WMOD_BLOCK_CHANCE_ADD)
			return "[val > 0 ? "+" : ""][val]% block chance"
		if(WMOD_COVERAGE_ADD)
			return "[val > 0 ? "+" : ""][val]% projectile coverage"
		if(WMOD_CHARGESPEED_MULT)
			return "[round((val - 1) * 100)]% charge speed"
		if(WMOD_RELOADTIME_MULT)
			return "[round((val - 1) * 100)]% reload time"
		if(WMOD_DAMFACTOR_MULT)
			return "[round((val - 1) * 100)]% damage factor"
		if(WMOD_ACCFACTOR_MULT)
			return "[round((val - 1) * 100)]% accuracy factor"
		if(WMOD_SHARPNESS_SET)
			return "sharpness: [val == IS_SHARP_ACCURATE ? "razor" : val == IS_SHARP ? "sharp" : "blunt"]"
		if(WMOD_BURN_DAMAGE)
			return "+[val] burn damage on hit"
		if(WMOD_TOX_DAMAGE)
			return "+[val] toxin damage on hit"
		if(WMOD_HOLY_DAMAGE)
			return "+[val] holy damage on hit"
		else
			return "[key]: [val]"

/// Called when the mod item is used on a weapon. Attaches the mod.
/obj/item/weapon_mod/afterattack(atom/target, mob/user, proximity_flag, params)
	. = ..()
	if(!proximity_flag)
		return
	if(!isitem(target))
		return
	var/obj/item/weapon = target
	// Get or create the weapon_mods component
	var/datum/component/weapon_mods/WM = weapon.GetComponent(/datum/component/weapon_mods)
	if(!WM)
		WM = weapon.AddComponent(/datum/component/weapon_mods)
	if(!WM.can_apply(src, user))
		return
	WM.apply_mod(src, user)

// ===========================================================================
// MELEE WEAPON MODS
// ===========================================================================

// ---------------------------------------------------------------------------
// Blade slot — edge treatments, oils, coatings
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/blade_oil_fire
	name = "searing blade oil"
	desc = "A vial of alchemical oil that ignites on contact. Apply to a blade to add fire damage."
	icon_state = "heatsink"
	slot = WEAPON_MOD_SLOT_BLADE
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_BURN_DAMAGE = 5,
		WMOD_FORCE_ADD = 1,
	)
	overlay_state = "oil_fire_overlay"

/obj/item/weapon_mod/blade_oil_poison
	name = "venom blade oil"
	desc = "A vial of toxic oil that seeps into wounds. Apply to a blade to add toxin damage."
	icon_state = "injector"
	slot = WEAPON_MOD_SLOT_BLADE
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_TOX_DAMAGE = 4,
	)
	overlay_state = "oil_poison_overlay"

/obj/item/weapon_mod/blade_oil_holy
	name = "sanctified blade oil"
	desc = "A vial of blessed oil that burns the undead. Apply to a blade to add holy damage."
	icon_state = "sanctifier"
	slot = WEAPON_MOD_SLOT_BLADE
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_HOLY_DAMAGE = 3,
	)
	overlay_state = "oil_holy_overlay"

/obj/item/weapon_mod/blade_edge_razor
	name = "razor edge whetstone"
	desc = "A premium whetstone that sharpens a blade beyond normal limits. Increases damage and sets sharpness to razor."
	icon_state = "diamond_blade"
	slot = WEAPON_MOD_SLOT_BLADE
	valid_weapon_types = list(WEAPON_TAG_SWORD, WEAPON_TAG_DAGGER, WEAPON_TAG_AXE)
	upgrades = list(
		WMOD_FORCE_ADD = 4,
		WMOD_SHARPNESS_SET = IS_SHARP_ACCURATE,
		WMOD_INTDAMAGE_MULT = 1.2,
	)

/obj/item/weapon_mod/blade_coating_rust
	name = "rust coating"
	desc = "A foul alchemical paste that corrodes armor on impact. Increases armor penetration but reduces damage."
	icon_state = "plate"
	slot = WEAPON_MOD_SLOT_BLADE
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_ARMOR_PEN_ADD = 2,
		WMOD_FORCE_ADD = -2,
	)

// ---------------------------------------------------------------------------
// Grip slot — handle wraps, grip modifications
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/grip_leather
	name = "leather grip wrap"
	desc = "A leather wrap for a weapon handle. Improves defense and reduces STR requirement."
	icon_state = "ergonomic"
	slot = WEAPON_MOD_SLOT_GRIP
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_WDEFENSE_ADD = 1,
		WMOD_MINSTR_ADD = -1,
	)

/obj/item/weapon_mod/grip_wire
	name = "wire grip wrap"
	desc = "A wire wrap for a weapon handle. Increases damage but raises STR requirement."
	icon_state = "ratchet"
	slot = WEAPON_MOD_SLOT_GRIP
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_FORCE_ADD = 2,
		WMOD_MINSTR_ADD = 1,
	)

/obj/item/weapon_mod/grip_balanced
	name = "balanced grip"
	desc = "A carefully balanced grip that makes the weapon swifter. Shifts balance toward swift."
	icon_state = "stabilizing"
	slot = WEAPON_MOD_SLOT_GRIP
	valid_weapon_types = list(WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_WBALANCE_SHIFT = 1,
		WMOD_WDEFENSE_ADD = 1,
	)

// ---------------------------------------------------------------------------
// Pommel slot — counterweights, pommel stones
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/pommel_heavy
	name = "heavy pommel"
	desc = "A heavy pommel that adds weight to the weapon's base. Increases defense and throw damage but shifts balance heavier."
	icon_state = "hammer_addon"
	slot = WEAPON_MOD_SLOT_POMMEL
	valid_weapon_types = list(WEAPON_TAG_SWORD, WEAPON_TAG_DAGGER, WEAPON_TAG_AXE)
	upgrades = list(
		WMOD_WDEFENSE_ADD = 2,
		WMOD_THROWFORCE_ADD = 3,
		WMOD_WBALANCE_SHIFT = -1,
	)

/obj/item/weapon_mod/pommel_light
	name = "lightweight pommel"
	desc = "A lightweight pommel that reduces weight. Shifts balance swifter and reduces STR requirement."
	icon_state = "dampener"
	slot = WEAPON_MOD_SLOT_POMMEL
	valid_weapon_types = list(WEAPON_TAG_SWORD, WEAPON_TAG_DAGGER, WEAPON_TAG_AXE)
	upgrades = list(
		WMOD_WBALANCE_SHIFT = 1,
		WMOD_MINSTR_ADD = -1,
	)

/obj/item/weapon_mod/pommel_gemstone
	name = "gemstone pommel"
	desc = "A decorative gemstone pommel. Increases defense slightly and adds value."
	icon_state = "booster"
	slot = WEAPON_MOD_SLOT_POMMEL
	valid_weapon_types = list(WEAPON_TAG_SWORD, WEAPON_TAG_DAGGER)
	upgrades = list(
		WMOD_WDEFENSE_ADD = 1,
		WMOD_WDEFENSE_WBONUS_ADD = 1,
	)
	var/gem_value = 50

// ---------------------------------------------------------------------------
// Guard slot — crossguards, hand protection
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/guard_reinforced
	name = "reinforced guard"
	desc = "A reinforced crossguard that provides better hand protection. Increases defense significantly."
	icon_state = "guard"
	slot = WEAPON_MOD_SLOT_GUARD
	valid_weapon_types = list(WEAPON_TAG_SWORD)
	upgrades = list(
		WMOD_WDEFENSE_ADD = 3,
		WMOD_WDEFENSE_WBONUS_ADD = 2,
	)

/obj/item/weapon_mod/guard_basket
	name = "basket guard"
	desc = "A basket-style guard that fully protects the hand. Greatly increases defense but shifts balance heavier."
	icon_state = "brace_bar"
	slot = WEAPON_MOD_SLOT_GUARD
	valid_weapon_types = list(WEAPON_TAG_SWORD)
	upgrades = list(
		WMOD_WDEFENSE_ADD = 5,
		WMOD_WDEFENSE_WBONUS_ADD = 3,
		WMOD_WBALANCE_SHIFT = -1,
		WMOD_MINSTR_ADD = 1,
	)

// ---------------------------------------------------------------------------
// Shaft slot — pole/handle replacement (polearms only)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/shaft_reinforced
	name = "reinforced shaft"
	desc = "A reinforced wooden shaft for polearms. Increases durability and defense."
	icon_state = "brace_bar"
	slot = WEAPON_MOD_SLOT_SHAFT
	valid_weapon_types = list(WEAPON_TAG_POLEARM)
	upgrades = list(
		WMOD_MAX_INTEGRITY_ADD = 100,
		WMOD_WDEFENSE_ADD = 2,
	)

/obj/item/weapon_mod/shaft_metal
	name = "metal shaft"
	desc = "A metal shaft for polearms. Greatly increases durability but raises STR requirement and shifts balance heavier."
	icon_state = "plate"
	slot = WEAPON_MOD_SLOT_SHAFT
	valid_weapon_types = list(WEAPON_TAG_POLEARM)
	upgrades = list(
		WMOD_MAX_INTEGRITY_ADD = 200,
		WMOD_WDEFENSE_ADD = 3,
		WMOD_MINSTR_ADD = 2,
		WMOD_WBALANCE_SHIFT = -1,
	)

// ===========================================================================
// RANGED WEAPON MODS
// ===========================================================================

// ---------------------------------------------------------------------------
// Bowstring slot — bowstring upgrades (bows only)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/bowstring_silk
	name = "silk bowstring"
	desc = "A high-quality silk bowstring. Increases damage factor and accuracy."
	icon_state = "rubbermesh"
	slot = WEAPON_MOD_SLOT_BOWSTRING
	valid_weapon_types = list(WEAPON_TAG_BOW)
	upgrades = list(
		WMOD_DAMFACTOR_MULT = 1.15,
		WMOD_ACCFACTOR_MULT = 1.1,
	)

/obj/item/weapon_mod/bowstring_sinew
	name = "sinew bowstring"
	desc = "A sinew bowstring. Maximizes damage but reduces accuracy."
	icon_state = "plasmablock"
	slot = WEAPON_MOD_SLOT_BOWSTRING
	valid_weapon_types = list(WEAPON_TAG_BOW)
	upgrades = list(
		WMOD_DAMFACTOR_MULT = 1.25,
		WMOD_ACCFACTOR_MULT = 0.9,
	)

// ---------------------------------------------------------------------------
// Sight slot — aiming aids (bows and crossbows)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/sight_pin
	name = "sighting pin"
	desc = "A small pin sight that helps with aiming. Increases accuracy factor."
	icon_state = "laser_guide"
	slot = WEAPON_MOD_SLOT_SIGHT
	valid_weapon_types = list(WEAPON_TAG_BOW, WEAPON_TAG_CROSSBOW)
	upgrades = list(
		WMOD_ACCFACTOR_MULT = 1.2,
	)

// ---------------------------------------------------------------------------
// Crank slot — cocking mechanism (crossbows only)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/crank_quick
	name = "quick crank"
	desc = "A quick-release crank mechanism for crossbows. Reduces reload time but reduces damage."
	icon_state = "motor"
	slot = WEAPON_MOD_SLOT_CRANK
	valid_weapon_types = list(WEAPON_TAG_CROSSBOW)
	upgrades = list(
		WMOD_RELOADTIME_MULT = 0.7,
		WMOD_CHARGESPEED_MULT = 0.7,
		WMOD_DAMFACTOR_MULT = 0.9,
	)

/obj/item/weapon_mod/crank_heavy
	name = "heavy crank"
	desc = "A heavy-duty crank mechanism for crossbows. Increases damage but slows reload."
	icon_state = "hydraulic"
	slot = WEAPON_MOD_SLOT_CRANK
	valid_weapon_types = list(WEAPON_TAG_CROSSBOW)
	upgrades = list(
		WMOD_RELOADTIME_MULT = 1.3,
		WMOD_CHARGESPEED_MULT = 1.3,
		WMOD_DAMFACTOR_MULT = 1.2,
	)

// ===========================================================================
// SHIELD MODS
// ===========================================================================

// ---------------------------------------------------------------------------
// Boss slot — center boss (shields only)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/boss_iron
	name = "iron shield boss"
	desc = "An iron center boss for shields. Increases block chance and durability."
	icon_state = "plasmablock"
	slot = WEAPON_MOD_SLOT_BOSS
	valid_weapon_types = list(WEAPON_TAG_SHIELD)
	upgrades = list(
		WMOD_BLOCK_CHANCE_ADD = 10,
		WMOD_MAX_INTEGRITY_ADD = 50,
		WMOD_FORCE_ADD = 2,
	)

/obj/item/weapon_mod/boss_steel
	name = "steel shield boss"
	desc = "A premium steel center boss for shields. Greatly increases block chance and durability."
	icon_state = "cell_mount"
	slot = WEAPON_MOD_SLOT_BOSS
	valid_weapon_types = list(WEAPON_TAG_SHIELD)
	upgrades = list(
		WMOD_BLOCK_CHANCE_ADD = 15,
		WMOD_MAX_INTEGRITY_ADD = 100,
		WMOD_FORCE_ADD = 3,
		WMOD_WDEFENSE_ADD = 1,
	)

// ---------------------------------------------------------------------------
// Rim slot — edge reinforcement (shields only)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/rim_metal
	name = "metal shield rim"
	desc = "A metal rim that reinforces a shield's edge. Increases coverage and durability."
	icon_state = "guard"
	slot = WEAPON_MOD_SLOT_RIM
	valid_weapon_types = list(WEAPON_TAG_SHIELD)
	upgrades = list(
		WMOD_COVERAGE_ADD = 15,
		WMOD_MAX_INTEGRITY_ADD = 75,
	)

/obj/item/weapon_mod/rim_spiked
	name = "spiked shield rim"
	desc = "A spiked metal rim that turns a shield into an offensive weapon. Increases force but reduces coverage."
	icon_state = "spike"
	slot = WEAPON_MOD_SLOT_RIM
	valid_weapon_types = list(WEAPON_TAG_SHIELD)
	upgrades = list(
		WMOD_FORCE_ADD = 5,
		WMOD_COVERAGE_ADD = -10,
		WMOD_WDEFENSE_ADD = -1,
	)

// ---------------------------------------------------------------------------
// Coating slot — paint/coating (shields and blades)
// ---------------------------------------------------------------------------

/obj/item/weapon_mod/coating_holy
	name = "sanctified coating"
	desc = "A blessed coating that can be applied to shields or blades. Adds holy damage on hit."
	icon_state = "sanctifier"
	slot = WEAPON_MOD_SLOT_COATING
	valid_weapon_types = list(WEAPON_TAG_SHIELD, WEAPON_TAG_MELEE)
	upgrades = list(
		WMOD_HOLY_DAMAGE = 2,
	)
