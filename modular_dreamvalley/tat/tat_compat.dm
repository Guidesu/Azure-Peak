// Names and paths which exist on Twilight Axis' newer base but not on the
// Azure Peak revision used by DreamValley. Unsupported choices are filtered by
// the integration layer; these declarations keep the imported engine's type
// references valid while preserving its upstream file layout.

#ifndef TRAIT_OUTLANDER
#define TRAIT_OUTLANDER "TAT Outlander"
#endif

#ifndef TRAIT_PARRYEXPERT
#define TRAIT_PARRYEXPERT "TAT Expert Parry"
#endif

#ifndef TRAIT_FIREARMS_MARKSMAN
#define TRAIT_FIREARMS_MARKSMAN "TAT Firearms Training"
#endif

/datum/skill/combat/twilight_firearms
	name = "Firearms (unavailable)"
	desc = "Reserved for a future Azure Peak firearms port."
	learnable_in_sleep = FALSE
	max_skillbook_level = 0

/datum/language/valorian
	parent_type = /datum/language/common
	name = "Valorian"

/datum/language/gyedzenese
	parent_type = /datum/language/common
	name = "Gyedzenese"

/obj/item/cushion/zybantine
	parent_type = /obj/item
	name = "zybantine cushion"

/obj/item/cushion/desert1
	parent_type = /obj/item
	name = "desert cushion"

/obj/item/cushion/desert2
	parent_type = /obj/item
	name = "desert cushion"

/obj/item/clothing/shoes/roguetown/shalal/reinforced
	name = "reinforced babouche"

/obj/item/storage/belt/rogue/leather/noblesash
	parent_type = /obj/item/storage/belt/rogue/leather/sash
	name = "noble sash"

/obj/item/storage/belt/rogue/leather/cloth/sash
	parent_type = /obj/item/storage/belt/rogue/leather/sash

/obj/item/clothing/under/roguetown/sirwal/fancy
	parent_type = /obj/item
	name = "fancy sirwal"

/obj/item/folding_peddler_stored
	parent_type = /obj/item/storage/backpack/rogue/backpack
	name = "folding peddler (unavailable)"

/obj/item/storage/backpack/rogue/backpack_trader
	parent_type = /obj/item/storage/backpack/rogue/backpack
	name = "trader's backpack"

/obj/item/book/rogue/trophy_rules
	name = "trophy rules"

/obj/item/roguecoin/goldkrona
	parent_type = /obj/item/roguecoin/gold

/obj/item/gun/ballistic/twilight_firearm
	name = "unported firearm"

/obj/effect/proc_holder/spell/targeted/create_seed
	name = "Create Seed (unavailable)"

/obj/effect/proc_holder/spell/self/beast_claws
	name = "Beast Claws (unavailable)"

/obj/effect/proc_holder/spell/self/beast_rage
	name = "Beast Rage (unavailable)"

/datum/component/combo_core/ronin

/datum/component/combo_core/soundbreaker

/datum/component/trophy_hunter

/datum/component/contractor

/datum/component/contractor/entity
