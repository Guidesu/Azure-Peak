/// Leatherworking and general crafting recipes for weapon modifications.
/// Leather grips, balanced grips, bowstrings, reinforced shafts, whetstones.

// --- Leatherworking: leather grip wrap ---

/datum/crafting_recipe/roguetown/leather/weapon_mod/grip_leather
	name = "leather grip wrap"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/grip_leather
	reqs = list(/obj/item/natural/hide/cured = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

// --- General crafting: balanced grip (leather + iron) ---

/datum/crafting_recipe/roguetown/weapon_mod/grip_balanced
	name = "balanced grip"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/grip_balanced
	reqs = list(/obj/item/natural/hide/cured = 1,
				/obj/item/ingot/iron = 1)
	tools = list(/obj/item/rogueweapon/hammer)
	craftdiff = 2

// --- General crafting: bowstrings ---

/datum/crafting_recipe/roguetown/weapon_mod/bowstring_silk
	name = "silk bowstring"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/bowstring_silk
	reqs = list(/obj/item/natural/silk = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/weapon_mod/bowstring_sinew
	name = "sinew bowstring"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/bowstring_sinew
	reqs = list(/obj/item/alch/sinew = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

// --- General crafting: reinforced shaft (wood + iron) ---

/datum/crafting_recipe/roguetown/weapon_mod/shaft_reinforced
	name = "reinforced shaft"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/shaft_reinforced
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/ingot/iron = 1)
	tools = list(/obj/item/rogueweapon/hammer)
	craftdiff = 2

// --- General crafting: razor edge whetstone ---

/datum/crafting_recipe/roguetown/weapon_mod/blade_edge_razor
	name = "razor edge whetstone"
	display_category = ITEM_CAT_WEAPON_MODS
	result = /obj/item/weapon_mod/blade_edge_razor
	reqs = list(/obj/item/natural/stone = 2,
				/obj/item/alch/mineraldust = 1)
	craftdiff = 3
