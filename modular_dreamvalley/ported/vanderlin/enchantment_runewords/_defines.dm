// Ported from Vanderlin (OpenKeep): code/__DEFINES/enchantments.dm
// and gem quality constants scattered across Vanderlin's gem/runeword code.
//
// SCOPE NOTE: DreamValley has no mana system (no /datum/mana,
// no /datum/component/use_mana, no mob.mana_pool) at the time of this port.
// Vanderlin's mana_capacity/mana_regeneration enchantments and the
// mana_drain rune effect are therefore OMITTED from this port rather than
// stubbed against a guessed API — see enchantment_runewords notes in the
// final report. Everything below only concerns the runeword gem-socketing
// system and a small set of self-contained item enchantments.

/// Gem quality tiers (Vanderlin: GEM_REGULAR/GEM_CHIPPED/GEM_FLAWLESS/GEM_PERFECT)
#define DV_GEM_CHIPPED 1
#define DV_GEM_REGULAR 2
#define DV_GEM_FLAWLESS 3
#define DV_GEM_PERFECT 4

/// Slot categories used to pick which effect a gem grants when socketed.
#define DV_SOCKET_SLOT_WEAPON "weapon"
#define DV_SOCKET_SLOT_ARMOR "armor"
#define DV_SOCKET_SLOT_SHIELD "shield"

/// Filter overlay names used while an enchantment/runeword is glowing on an item.
#define DV_ENCHANT_FILTER_FORCE "dv_enchant_force"
#define DV_ENCHANT_FILTER_SEARING "dv_enchant_searing"
#define DV_ENCHANT_FILTER_DURABILITY "dv_enchant_durability"
#define DV_ENCHANT_FILTER_DIVINE "dv_enchant_divine"

/// Standalone weapon enchantment types (temporary, decaying buffs; see enchanted_weapon.dm)
#define DV_ENCHANT_SEARING_BLADE 1
#define DV_ENCHANT_FORCE_BLADE 2
#define DV_ENCHANT_DURABILITY 3
#define DV_ENCHANT_DIVINE_FIRE 4

#define DV_SEARING_BLADE_DAMAGE 8
#define DV_FORCE_BLADE_FORCE 5
#define DV_DURABILITY_INCREASE 100
#define DV_DIVINE_FIRE_DAMAGE 8

#define DV_ENCHANT_DEFAULT_DURATION (15 MINUTES)
