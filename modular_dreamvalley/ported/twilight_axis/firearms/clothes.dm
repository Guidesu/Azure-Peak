// Ported from Twilight-Axis's modular_twilight_axis/firearms module
// (code/clothes/{feet,hats,neck}.dm merged into one file). All player-facing
// text translated from Russian into English.

/obj/item/clothing/shoes/roguetown/grenzelhoft/gunslinger
	name = "travel boots"

/obj/item/clothing/head/roguetown/bucklehat/gunslinger
	name = "gunslinger's hat"

/obj/item/clothing/head/roguetown/duelhat/gunslinger
	name = "dragoon's hat"

/obj/item/clothing/head/roguetown/helmet/tricorn/grenzel
	name = "reichsmarine tricorn"
	desc = "Grenzelhoft rules the waves of ten seas. Often worn by crewmen and officers of the Imperial Navy, this hat also features a metallic cap, enhancing its protective properties."
	max_integrity = ARMOR_INT_HELMET_LEATHER
	body_parts_covered = HEAD|HAIR|EARS
	armor = ARMOR_LEATHER

/obj/item/clothing/neck/roguetown/leather/blackpowder
	name = "blackpowder order coverall"
	desc = "A robust coverall, worn by the warriors of the Otavan Blackpowder Order. A garment fitting for the Final War."
	icon = 'modular_dreamvalley/icons/twilight_firearms/obj_neck.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_firearms/onmob_neck.dmi'
	icon_state = "confessor_coif"
	armor = ARMOR_PLATE
	max_integrity = ARMOR_INT_SIDE_STEEL
	resistance_flags = FIRE_PROOF
	body_parts_inherent = NECK
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	equip_delay_self = 7 SECONDS
	unequip_delay_self = 7 SECONDS
