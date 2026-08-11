/// Blacksmithing recipes for weapon modifications.
/// Metal-based mods: pommels, guards, shield bosses/rims, shafts, cranks, wire grips.

/datum/anvil_recipe/weapon_mods
	abstract_type = /datum/anvil_recipe/weapon_mods
	i_type = "Weapon Mods"
	display_category = ITEM_CAT_WEAPON_MODS

// --- Iron mods (novice smithing) ---

/datum/anvil_recipe/weapon_mods/iron/pommel_heavy
	name = "Heavy Pommel, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/pommel_heavy
	craftdiff = SKILL_LEVEL_NOVICE

/datum/anvil_recipe/weapon_mods/iron/pommel_light
	name = "Lightweight Pommel, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/pommel_light
	craftdiff = SKILL_LEVEL_NOVICE

/datum/anvil_recipe/weapon_mods/iron/guard_reinforced
	name = "Reinforced Guard, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/guard_reinforced
	craftdiff = SKILL_LEVEL_APPRENTICE

/datum/anvil_recipe/weapon_mods/iron/boss_iron
	name = "Shield Boss, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/boss_iron
	craftdiff = SKILL_LEVEL_NOVICE

/datum/anvil_recipe/weapon_mods/iron/rim_metal
	name = "Shield Rim, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/rim_metal
	craftdiff = SKILL_LEVEL_NOVICE

/datum/anvil_recipe/weapon_mods/iron/grip_wire
	name = "Wire Grip Wrap, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/grip_wire
	craftdiff = SKILL_LEVEL_NOVICE

/datum/anvil_recipe/weapon_mods/iron/crank_quick
	name = "Quick Crank, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/weapon_mod/crank_quick
	craftdiff = SKILL_LEVEL_APPRENTICE

// --- Steel mods (apprentice smithing) ---

/datum/anvil_recipe/weapon_mods/steel/guard_basket
	name = "Basket Guard, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/guard_basket
	craftdiff = SKILL_LEVEL_JOURNEYMAN

/datum/anvil_recipe/weapon_mods/steel/boss_steel
	name = "Shield Boss, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/boss_steel
	craftdiff = SKILL_LEVEL_APPRENTICE

/datum/anvil_recipe/weapon_mods/steel/rim_spiked
	name = "Spiked Shield Rim, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/rim_spiked
	craftdiff = SKILL_LEVEL_APPRENTICE

/datum/anvil_recipe/weapon_mods/steel/shaft_metal
	name = "Metal Shaft, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/shaft_metal
	craftdiff = SKILL_LEVEL_APPRENTICE

/datum/anvil_recipe/weapon_mods/steel/crank_heavy
	name = "Heavy Crank, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/crank_heavy
	craftdiff = SKILL_LEVEL_JOURNEYMAN

/datum/anvil_recipe/weapon_mods/steel/sight_pin
	name = "Sighting Pin, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/weapon_mod/sight_pin
	craftdiff = SKILL_LEVEL_APPRENTICE

// --- Silver mods (journeyman smithing) ---

/datum/anvil_recipe/weapon_mods/silver/pommel_gemstone
	name = "Gemstone Pommel, Silver (+1 Gem)"
	req_bar = /obj/item/ingot/silver
	additional_items = list(/obj/item/roguegem)
	created_item = /obj/item/weapon_mod/pommel_gemstone
	craftdiff = SKILL_LEVEL_JOURNEYMAN
