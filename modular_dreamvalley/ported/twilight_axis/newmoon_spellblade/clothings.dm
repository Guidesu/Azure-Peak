// Ported from Twilight-Axis's church_classes/spellblade module. All
// player-facing text translated from Russian into English.

#define ARMOR_NEWMOON_HOOD list("blunt" = 3, "slash" = 4, "stab" = 4, "piercing" = 4, "fire" = 0)
#define ARMOR_NEWMOON_JACKET list("blunt" = 4, "slash" = 4, "stab" = 4, "piercing" = 4, "fire" = 0)
#define ARMOR_NEWMOON_MASK list("blunt" = 1, "slash" = 1, "stab" = 1, "piercing" = 1, "fire" = 0)

/obj/item/clothing/head/roguetown/roguehood/newmoon
	name = "newmoon hood"
	desc = "A hood woven from dense fabric in the Newmoon style. Sturdy against tearing and warm thanks to its lining. The secret of the weave remains a mystery even to the Newmoon Order themselves."
	color = "#78a3c9"
	slot_flags = ITEM_SLOT_HEAD
	armor = ARMOR_NEWMOON_HOOD
	body_parts_covered = HEAD|HAIR|EARS|NOSE|NECK
	max_integrity = 230
	armor_class = ARMOR_CLASS_MEDIUM
	alternate_worn_layer = HOOD_LAYER

/obj/item/clothing/suit/roguetown/armor/leather/newmoon_jacket
	name = "newmoon jacket"
	desc = "A heavy, well-made, yet well-protected coat of dense, sturdy fabric. It is the distinguishing mark of the Sacred Order of the Newmoon, with an amulet of Noc set at the center of its breastplate. A brazen symbol of radical Noctism."
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/spellblade_clothes.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/newmoon_spellblade/spellblade_clothes.dmi'
	icon_state = "newmoon_jacket"
	item_state = "newmoon_jacket"
	blocksound = SOFTHIT
	armor = ARMOR_NEWMOON_JACKET
	nodismemsleeves = TRUE
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	max_integrity = 300
	armor_class = ARMOR_CLASS_MEDIUM

/obj/item/clothing/mask/rogue/ragmask/newmoon
	name = "newmoon mask"
	desc = "A mask woven from a silky, breathable fabric."
	color = "#78a3c9"
	armor = ARMOR_NEWMOON_MASK
	body_parts_covered = FACE
	alternate_worn_layer = NECK_LAYER

/obj/item/clothing/mask/rogue/ragmask/newmoon/MiddleClick(mob/user)
	overarmor = !overarmor
	to_chat(user, span_info("I [overarmor ? "wear \the [src] under my hair" : "wear \the [src] over my hair"]."))
	if(overarmor)
		alternate_worn_layer = NECK_LAYER //Below Hair Layer
	else
		alternate_worn_layer = BACK_LAYER //Above Hair Layer
	user.update_inv_wear_mask()


/obj/item/clothing/suit/roguetown/shirt/tunic/newmoon
	name = "newmoon tunic"
	color = "#78a3c9"

/obj/item/clothing/cloak/half/newmoon
	name = "newmoon cloak"
	color = "#78a3c9"
