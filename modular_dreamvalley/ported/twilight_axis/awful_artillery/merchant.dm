// Ported from Twilight-Axis's awful_artillery/code/merchant.dm. Merchant
// guild crate supply packs for buying mortar parts/shells outright instead
// of crafting them. Pack names translated from Russian into English.

/datum/supply_pack/rogue/artillery
	group = "Artillery"
	crate_name = "merchant guild's crate"
	crate_type = /obj/structure/closet/crate/chest/merchant

/datum/supply_pack/rogue/artillery/mortar_wheels
	name = "Mortar Carriage Wheels x4"
	cost = 60
	contains = list(/obj/item/mortar_wheel, /obj/item/mortar_wheel, /obj/item/mortar_wheel, /obj/item/mortar_wheel)

/datum/supply_pack/rogue/artillery/mortar_lafet
	name = "Mortar Carriage"
	cost = 100
	contains = list(/obj/item/artillery_assembly/mortar)

/datum/supply_pack/rogue/artillery/mortar_barrel
	name = "Mortar Barrel"
	cost = 750
	contains = list(/obj/item/mortar_barrel)

/datum/supply_pack/rogue/artillery/mortar_sheel
	name = "Mortar Shell"
	cost = 120
	contains = list(/obj/item/artillery_shell/mortar)

/datum/supply_pack/rogue/artillery/mortar_shell_x8
	name = "Mortar Shells x8"
	cost = 750
	contains = list(/obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar, /obj/item/artillery_shell/mortar)
