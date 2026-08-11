// Weapon modification supply packs for merchant catalogs.

/datum/supply_pack/rogue/weapon_mods
	group = "Weapon Modifications"
	crate_name = "merchant guild's crate"
	crate_type = /obj/structure/closet/crate/chest/merchant

// --- Blade slot mods ---

/datum/supply_pack/rogue/weapon_mods/blade_oil_fire
	name = "Searing Blade Oil"
	cost = 25
	contains = list(/obj/item/weapon_mod/blade_oil_fire)

/datum/supply_pack/rogue/weapon_mods/blade_oil_poison
	name = "Venom Blade Oil"
	cost = 35
	contains = list(/obj/item/weapon_mod/blade_oil_poison)

/datum/supply_pack/rogue/weapon_mods/blade_oil_holy
	name = "Sanctified Blade Oil"
	cost = 40
	contains = list(/obj/item/weapon_mod/blade_oil_holy)

/datum/supply_pack/rogue/weapon_mods/blade_edge_razor
	name = "Razor Edge Whetstone"
	cost = 30
	contains = list(/obj/item/weapon_mod/blade_edge_razor)

/datum/supply_pack/rogue/weapon_mods/blade_coating_rust
	name = "Rust Coating"
	cost = 20
	contains = list(/obj/item/weapon_mod/blade_coating_rust)

// --- Grip slot mods ---

/datum/supply_pack/rogue/weapon_mods/grip_leather
	name = "Leather Grip Wraps"
	cost = 10
	contains = list(/obj/item/weapon_mod/grip_leather)

/datum/supply_pack/rogue/weapon_mods/grip_wire
	name = "Wire Grip Wrap"
	cost = 15
	contains = list(/obj/item/weapon_mod/grip_wire)

/datum/supply_pack/rogue/weapon_mods/grip_balanced
	name = "Balanced Grip"
	cost = 20
	contains = list(/obj/item/weapon_mod/grip_balanced)

// --- Pommel slot mods ---

/datum/supply_pack/rogue/weapon_mods/pommel_heavy
	name = "Heavy Pommel"
	cost = 12
	contains = list(/obj/item/weapon_mod/pommel_heavy)

/datum/supply_pack/rogue/weapon_mods/pommel_light
	name = "Lightweight Pommel"
	cost = 12
	contains = list(/obj/item/weapon_mod/pommel_light)

/datum/supply_pack/rogue/weapon_mods/pommel_gemstone
	name = "Gemstone Pommel"
	cost = 50
	contains = list(/obj/item/weapon_mod/pommel_gemstone)

// --- Guard slot mods ---

/datum/supply_pack/rogue/weapon_mods/guard_reinforced
	name = "Reinforced Guard"
	cost = 18
	contains = list(/obj/item/weapon_mod/guard_reinforced)

/datum/supply_pack/rogue/weapon_mods/guard_basket
	name = "Basket Guard"
	cost = 30
	contains = list(/obj/item/weapon_mod/guard_basket)

// --- Shaft slot mods ---

/datum/supply_pack/rogue/weapon_mods/shaft_reinforced
	name = "Reinforced Shaft"
	cost = 15
	contains = list(/obj/item/weapon_mod/shaft_reinforced)

/datum/supply_pack/rogue/weapon_mods/shaft_metal
	name = "Metal Shaft"
	cost = 25
	contains = list(/obj/item/weapon_mod/shaft_metal)

// --- Bowstring slot mods ---

/datum/supply_pack/rogue/weapon_mods/bowstring_silk
	name = "Silk Bowstring"
	cost = 22
	contains = list(/obj/item/weapon_mod/bowstring_silk)

/datum/supply_pack/rogue/weapon_mods/bowstring_sinew
	name = "Sinew Bowstring"
	cost = 15
	contains = list(/obj/item/weapon_mod/bowstring_sinew)

// --- Sight slot mods ---

/datum/supply_pack/rogue/weapon_mods/sight_pin
	name = "Sighting Pin"
	cost = 18
	contains = list(/obj/item/weapon_mod/sight_pin)

// --- Crank slot mods ---

/datum/supply_pack/rogue/weapon_mods/crank_quick
	name = "Quick Crank"
	cost = 25
	contains = list(/obj/item/weapon_mod/crank_quick)

/datum/supply_pack/rogue/weapon_mods/crank_heavy
	name = "Heavy Crank"
	cost = 25
	contains = list(/obj/item/weapon_mod/crank_heavy)

// --- Shield boss slot mods ---

/datum/supply_pack/rogue/weapon_mods/boss_iron
	name = "Iron Shield Boss"
	cost = 15
	contains = list(/obj/item/weapon_mod/boss_iron)

/datum/supply_pack/rogue/weapon_mods/boss_steel
	name = "Steel Shield Boss"
	cost = 25
	contains = list(/obj/item/weapon_mod/boss_steel)

// --- Shield rim slot mods ---

/datum/supply_pack/rogue/weapon_mods/rim_metal
	name = "Metal Shield Rim"
	cost = 15
	contains = list(/obj/item/weapon_mod/rim_metal)

/datum/supply_pack/rogue/weapon_mods/rim_spiked
	name = "Spiked Shield Rim"
	cost = 30
	contains = list(/obj/item/weapon_mod/rim_spiked)

// --- Coating slot mods ---

/datum/supply_pack/rogue/weapon_mods/coating_holy
	name = "Sanctified Coating"
	cost = 30
	contains = list(/obj/item/weapon_mod/coating_holy)

// --- Bundles ---

/datum/supply_pack/rogue/weapon_mods/blade_oil_bundle
	name = "Blade Oil Bundle (3 Random)"
	cost = 60
	contains = list(
		/obj/item/weapon_mod/blade_oil_fire,
		/obj/item/weapon_mod/blade_oil_poison,
		/obj/item/weapon_mod/blade_oil_holy,
	)

/datum/supply_pack/rogue/weapon_mods/grip_bundle
	name = "Grip Bundle (3 Types)"
	cost = 40
	contains = list(
		/obj/item/weapon_mod/grip_leather,
		/obj/item/weapon_mod/grip_wire,
		/obj/item/weapon_mod/grip_balanced,
	)

/datum/supply_pack/rogue/weapon_mods/shield_bundle
	name = "Shield Mod Bundle (Boss + Rim)"
	cost = 35
	contains = list(
		/obj/item/weapon_mod/boss_iron,
		/obj/item/weapon_mod/rim_metal,
	)
