/// Weapon modification system — defines for attachment slots and upgrade types.
/// Ported and adapted from CEV-Eris gun_upgrade system, fantasy-reskinned.

// ---------------------------------------------------------------------------
// Attachment slots
// ---------------------------------------------------------------------------

/// Slot on the weapon where a mod can be attached. Each weapon type
/// supports different slots. A weapon can have at most one mod per slot.
#define WEAPON_MOD_SLOT_BLADE "blade"       // Edge treatment, blade oil, enchantment
#define WEAPON_MOD_SLOT_GRIP "grip"         // Handle wrap, grip modification
#define WEAPON_MOD_SLOT_POMMEL "pommel"     // Counterweight, pommel stone
#define WEAPON_MOD_SLOT_GUARD "guard"       // Crossguard, hand protection
#define WEAPON_MOD_SLOT_SHAFT "shaft"       // Pole/handle replacement (polearms)
#define WEAPON_MOD_SLOT_BOWSTRING "bowstring" // Bowstring upgrade (bows)
#define WEAPON_MOD_SLOT_SIGHT "sight"       // Aiming aid (bows/crossbows)
#define WEAPON_MOD_SLOT_CRANK "crank"       // Cocking mechanism (crossbows)
#define WEAPON_MOD_SLOT_BOSS "boss"         // Center boss (shields)
#define WEAPON_MOD_SLOT_RIM "rim"           // Edge reinforcement (shields)
#define WEAPON_MOD_SLOT_COATING "coating"   // Paint/coating (shields, blades)

/// All valid slots, used for validation. This is a macro that expands to a list.
#define WEAPON_MOD_SLOTS list( \
	WEAPON_MOD_SLOT_BLADE, \
	WEAPON_MOD_SLOT_GRIP, \
	WEAPON_MOD_SLOT_POMMEL, \
	WEAPON_MOD_SLOT_GUARD, \
	WEAPON_MOD_SLOT_SHAFT, \
	WEAPON_MOD_SLOT_BOWSTRING, \
	WEAPON_MOD_SLOT_SIGHT, \
	WEAPON_MOD_SLOT_CRANK, \
	WEAPON_MOD_SLOT_BOSS, \
	WEAPON_MOD_SLOT_RIM, \
	WEAPON_MOD_SLOT_COATING, \
)

// ---------------------------------------------------------------------------
// Upgrade type keys — what stat the mod modifies
// ---------------------------------------------------------------------------

#define WMOD_FORCE_MULT "force_mult"           // Multiplier to force (1.1 = +10%)
#define WMOD_FORCE_ADD "force_add"             // Flat addition to force
#define WMOD_WDEFENSE_ADD "wdefense_add"       // Flat addition to wdefense
#define WMOD_WDEFENSE_WBONUS_ADD "wdefense_wbonus_add" // Flat add to wdefense_wbonus
#define WMOD_ARMOR_PEN_ADD "armor_pen_add"     // Flat addition to armor_penetration
#define WMOD_MAX_INTEGRITY_ADD "max_integrity_add" // Flat addition to max_integrity
#define WMOD_INTDAMAGE_MULT "intdamage_mult"   // Multiplier to intdamage_factor
#define WMOD_MINSTR_ADD "minstr_add"           // Flat addition to minstr
#define WMOD_WBALANCE_SHIFT "wbalance_shift"   // Shift wbalance by this (-1 heavier, +1 swifter)
#define WMOD_THROWFORCE_ADD "throwforce_add"   // Flat addition to throwforce
#define WMOD_BLOCK_CHANCE_ADD "block_chance_add" // Flat addition to block_chance (shields)
#define WMOD_COVERAGE_ADD "coverage_add"       // Flat addition to coverage (shields)
#define WMOD_CHARGESPEED_MULT "chargespeed_mult" // Multiplier to chargingspeed (crossbows)
#define WMOD_RELOADTIME_MULT "reloadtime_mult" // Multiplier to reloadtime (crossbows)
#define WMOD_DAMFACTOR_MULT "damfactor_mult"   // Multiplier to damfactor (bows/crossbows)
#define WMOD_ACCFACTOR_MULT "accfactor_mult"   // Multiplier to accfactor (bows/crossbows)
#define WMOD_SHARPNESS_SET "sharpness_set"     // Set sharpness to this value
#define WMOD_BURN_DAMAGE "burn_damage"         // Bonus burn damage on hit
#define WMOD_TOX_DAMAGE "tox_damage"           // Bonus toxin damage on hit
#define WMOD_HOLY_DAMAGE "holy_damage"         // Bonus holy damage on hit (vs undead)
#define WMOD_DAMAGE_VS_TYPE "damage_vs_type"   // Bonus damage vs specific mob_biotypes
#define WMOD_SILENT "silent"                   // Makes weapon silent (no hitsound/swingsound)

// ---------------------------------------------------------------------------
// Weapon type tags — which weapons can accept which mods.
// These are actual type paths so is_type_in_list() works directly.
// ---------------------------------------------------------------------------

#define WEAPON_TAG_SWORD /obj/item/rogueweapon/sword
#define WEAPON_TAG_AXE /obj/item/rogueweapon/stoneaxe
#define WEAPON_TAG_DAGGER /obj/item/rogueweapon/huntingknife
#define WEAPON_TAG_POLEARM /obj/item/rogueweapon/spear
#define WEAPON_TAG_BLUNT /obj/item/rogueweapon/mace
#define WEAPON_TAG_WHIP /obj/item/rogueweapon/whip
#define WEAPON_TAG_BOW /obj/item/gun/ballistic/revolver/grenadelauncher/bow
#define WEAPON_TAG_CROSSBOW /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
#define WEAPON_TAG_SHIELD /obj/item/rogueweapon/shield
#define WEAPON_TAG_MELEE /obj/item/rogueweapon
#define WEAPON_TAG_RANGED /obj/item/gun/ballistic/revolver/grenadelauncher
#define WEAPON_TAG_ALL /obj/item
