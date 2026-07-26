// Ported from Twilight-Axis's modular_twilight_axis/firearms module
// (code/craft/craft_recipes.dm + code/craft/artificer_recipes.dm merged).
// No player-facing text needed translation (already in English).

// --------- CRAFTING TABLE / CAULDRON RECIPES -----------

/datum/crafting_recipe/roguetown/survival/twilight_barker_light
	name = "barker with lamptern"
	reqs = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1, /obj/item/flashlight/flare/torch/lantern = 1)
	result = /obj/item/gun/ballistic/twilight_firearm/barker/barker_light
	verbage_simple = "fix"
	verbage = "fixes"
	craftdiff = 0

/datum/crafting_recipe/roguetown/leather/container/belt/twilight_holsterbelt
	name = "holster belt"
	result = /obj/item/storage/belt/rogue/leather/twilight_holsterbelt
	reqs = list(/obj/item/natural/hide/cured = 2,
				/obj/item/natural/fibers = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/container/twilight_ammoholder
	name = "ammo bag"
	result = /obj/item/quiver/twilight_bullet
	reqs = list(/obj/item/natural/hide/cured = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/leather/container/twilight_ammoholder_cannonball
	name = "cannonball bag"
	result = /obj/item/quiver/twilight_bullet/cannonball
	reqs = list(/obj/item/natural/hide/cured = 2,
				/obj/item/natural/fibers = 3)
	craftdiff = 1

//Silverdust blessing related stuff, for Inq funny gunpowder
/obj/item/alch/silverdust/examine(mob/user)
	. = ..()
	. += span_info("<font color = '#cfa446'>This object may be blessed by the lingering shard of COMET SYON.</font>")

/obj/item/alch/silverdust_blessed
	name = "blessed silver dust"
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'
	icon_state = "silverdust_blessed"
	major_pot = /datum/alch_cauldron_recipe/strong_antidote
	med_pot = /datum/alch_cauldron_recipe/antidote
	minor_pot = /datum/alch_cauldron_recipe/big_health_potion

/obj/item/alch/silverdust/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/flashlight/flare/torch/lantern/psycenser))
		var/obj/item/flashlight/flare/torch/lantern/psycenser/golgotha = A
		if(golgotha.on && (user.used_intent.type == /datum/intent/bless))
			playsound(src, 'sound/magic/holyshield.ogg', 100)
			src.visible_message(span_notice("[src] glistens with power as dust of COMET SYON lands upon it!"))
			new /obj/item/alch/silverdust_blessed(get_turf(src))
			qdel(src)
	..()

/datum/alch_grind_recipe/blessed_silver_bar
	valid_outputs = list(/obj/item/alch/silverdust_blessed = 1)

/datum/alch_grind_recipe/blessed_bullion
	name = "Blessed Silver Bullion"
	valid_input = /obj/item/ingot/silverblessed/bullion
	valid_outputs = list(/obj/item/alch/silverdust_blessed = 1)
	bonus_chance_outputs = list(/obj/item/alch/silverdust_blessed = 33, /obj/item/alch/firedust = 25)

/datum/crafting_recipe/roguetown/leather/twilight_powderflask
	name = "empty powderflask"
	result = /obj/item/twilight_powderflask_empty
	reqs = list(/obj/item/natural/hide/cured = 1,
				/obj/item/natural/fibers = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/basic
	name = "engineer black gunpowder"
	result = /obj/item/twilight_powderflask
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 4,
				/obj/item/alch/firedust = 1)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 2

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/fyre
	name = "engineer fyrepowder"
	result = /obj/item/twilight_powderflask/fyre
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/silverdust = 1)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 3

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/holyfyre
	name = "engineer holy fyrepowder"
	result = /obj/item/twilight_powderflask/holyfyre
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/silverdust_blessed = 1)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 2

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/thunder
	name = "engineer thunderpowder"
	result = /obj/item/twilight_powderflask/thunder
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 6,
				/obj/item/alch/airdust = 4)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 3

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/terror
	name = "engineer terrorpowder"
	result = /obj/item/twilight_powderflask/terror
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 6,
				/datum/reagent/medicine/manapot = 15)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 2

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/corrosive
	name = "engineer corrosive gunpowder"
	result = /obj/item/twilight_powderflask/corrosive
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/earthdust = 3)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 3

/datum/crafting_recipe/roguetown/engineering/twilight_powderflask/arcyne
	name = "engineer arcyne gunpowder"
	result = /obj/item/twilight_powderflask/arcyne
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/magicdust = 2,
				/datum/reagent/medicine/manapot = 30)
	verbage_simple = "work on"
	verbage = "finishes"
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 3

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask
	name = "mix black gunpowder"
	result = /obj/item/twilight_powderflask
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 4,
				/obj/item/alch/firedust = 1)
	verbage_simple = "work on"
	verbage = "finishes"
	category = "Table"
	skillcraft = /datum/skill/craft/alchemy
	craftdiff = 2

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/fyre
	name = "mix fyrepowder"
	result = /obj/item/twilight_powderflask/fyre
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/silverdust = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/holyfyre
	name = "mix holy fyrepowder"
	result = /obj/item/twilight_powderflask/holyfyre
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/silverdust_blessed = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/thunder
	name = "mix thunderpowder"
	result = /obj/item/twilight_powderflask/thunder
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 6,
				/obj/item/alch/airdust = 4)
	craftdiff = 3

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/terror
	name = "mix terrorpowder"
	result = /obj/item/twilight_powderflask/terror
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/coaldust = 6,
				/datum/reagent/medicine/manapot = 15)
	craftdiff = 2

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/corrosive
	name = "mix corrosive gunpowder"
	result = /obj/item/twilight_powderflask/corrosive
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/earthdust = 3)
	craftdiff = 3

/datum/crafting_recipe/roguetown/alchemy/twilight_powderflask/arcyne
	name = "mix arcyne gunpowder"
	result = /obj/item/twilight_powderflask/arcyne
	reqs = list(/obj/item/twilight_powderflask_empty = 1,
				/obj/item/alch/firedust = 4,
				/obj/item/alch/magicdust = 2,
				/datum/reagent/medicine/manapot = 30)
	craftdiff = 3

// --------- ANVIL RECIPES: AMMUNITION -----------

/datum/anvil_recipe/engineering/twilight_ammunition
	i_type = "Ammo (Engineering)"

/datum/anvil_recipe/engineering/twilight_ammunition/musket
	name = "Lead bullets 8x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead
	createditem_num = 8
	craftdiff = 2

/datum/anvil_recipe/engineering/twilight_ammunition/silver_musket
	name = "Silver bullets 8x "
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead/silver
	createditem_num = 8
	craftdiff = 5

/datum/anvil_recipe/engineering/twilight_ammunition/runelock
	name = "Runed spheres 6x "
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead/runelock
	createditem_num = 6
	craftdiff = 5

/datum/anvil_recipe/engineering/twilight_ammunition/cannonball
	name = "Lead cannonballs 6x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball
	createditem_num = 6
	craftdiff = 2

/datum/anvil_recipe/engineering/twilight_ammunition/grapeshot
	name = "Grapeshot 6x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball/grapeshot
	createditem_num = 6
	craftdiff = 2

/datum/anvil_recipe/weapons/twilight_ammunition
	i_type = "Ammo (Smithing)"

/datum/anvil_recipe/weapons/twilight_ammunition/musket
	name = "Lead bullets 8x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead
	createditem_num = 8
	craftdiff = 2

/datum/anvil_recipe/weapons/twilight_ammunition/silver_musket
	name = "Silver bullets 8x "
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead/silver
	createditem_num = 8
	craftdiff = 5

/datum/anvil_recipe/weapons/twilight_ammunition/runelock
	name = "Runed spheres 6x "
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_lead/runelock
	createditem_num = 6
	craftdiff = 5

/datum/anvil_recipe/weapons/twilight_ammunition/cannonball
	name = "Lead cannonballs 6x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball
	createditem_num = 6
	craftdiff = 2

/datum/anvil_recipe/weapons/twilight_ammunition/grapeshot
	name = "Grapeshot 6x "
	req_bar = /obj/item/ingot/tin
	created_item = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball/grapeshot
	createditem_num = 6
	craftdiff = 2

// --------- ANVIL RECIPES: GUNS -----------

/obj/item/twilight_gunlock
	name = "Gun Lock"
	icon_state = "gunlock"
	desc = "The 'firing' part of a gun."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'

/obj/item/twilight_gunstock
	name = "Gun Stock"
	icon_state = "gunstock"
	desc = "The 'holding' part of a gun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'

/obj/item/twilight_simplestock
	name = "Simple Stock"
	icon_state = "ironstock"
	desc = "The 'holding' part of a gun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'

/obj/item/twilight_gunbarrel
	name = "Gun Barrel"
	icon_state = "gunbarrel"
	desc = "The 'aiming' part of a gun."
	smeltresult = /obj/item/ingot/steel
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'

/obj/item/twilight_ironbarrel
	name = "Iron Barrel"
	icon_state = "ironbarrel"
	desc = "The 'aiming' part of a gun."
	smeltresult = /obj/item/ingot/iron
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_dreamvalley/icons/twilight_firearms/misc.dmi'

/datum/anvil_recipe/engineering/twilight_guns
	i_type = "Firearms"

/datum/anvil_recipe/engineering/twilight_guns/barrel
	name = "Gun Barrel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/twilight_gunbarrel
	additional_items = list(/obj/item/ingot/steel = 1)
	craftdiff = 3

/datum/anvil_recipe/engineering/twilight_guns/ironbarrel
	name = "Iron Barrel (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/twilight_ironbarrel
	additional_items = list(/obj/item/ingot/iron = 1)
	craftdiff = 1

/datum/anvil_recipe/engineering/twilight_guns/parts
	name = "Gun Lock (+1 Cog)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/twilight_gunlock
	additional_items = list(/obj/item/roguegear = 1)
	craftdiff = 1

/datum/anvil_recipe/engineering/twilight_guns/stock
	name = "Gun Stock (+1 Wood)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/natural/wood/plank = 1)
	created_item = /obj/item/twilight_gunstock
	craftdiff = 3

/datum/anvil_recipe/engineering/twilight_guns/ironstock
	name = "Simple Stock (+1 Wood)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/natural/wood/plank = 1)
	created_item = /obj/item/twilight_simplestock
	craftdiff = 1

/datum/anvil_recipe/engineering/twilight_guns/arquebus
	name = "Arquebus Rifle (+1 Stock) (+1 Lock) (+1 Barrel)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/twilight_gunstock = 1,
							/obj/item/twilight_gunbarrel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/arquebus
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/hunt_arquebus
	name = "Hunter's Arquebus (+2 Small Logs) (+1 Lock) (+1 Barrel) (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/grown/log/tree/small = 2,
							/obj/item/twilight_gunbarrel = 1,
							/obj/item/ingot/steel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/hunt_arquebus
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/handgonne
	name = "Culverin (+1 Stock) (+1 Barrel)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/twilight_gunstock = 1,
							/obj/item/twilight_gunbarrel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/handgonne
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/mortar
	name = "Hand mortar (+1 Simple Stock) (+1 Lock) (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/twilight_simplestock = 1,
							/obj/item/natural/hide/cured = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/mortar
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/arti_barker1
	name = "handle for barker (+1 Ignited Stone) (+1 Barker)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1, /obj/item/sharpener/ignited = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/barker/arti_barker1
	craftdiff = 3

/datum/anvil_recipe/engineering/twilight_guns/arti_barker2
	name = "hunter's barker (+1 Ignited Barker) (+2 Small Logs) (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/gun/ballistic/twilight_firearm/barker/arti_barker1 = 1, /obj/item/ingot/iron = 1, /obj/item/grown/log/tree/small = 2)
	created_item = /obj/item/gun/ballistic/twilight_firearm/barker/arti_barker2
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/arti_barker3
	name = "shepherd's barker (+1 hunter's barker) (+1 steel) (+2 Cured Leather)"
	req_bar = /obj/item/ingot/iron
	additional_items = list( /obj/item/gun/ballistic/twilight_firearm/barker/arti_barker2 = 1, /obj/item/ingot/steel = 1, /obj/item/natural/hide/cured = 2)
	created_item = /obj/item/gun/ballistic/twilight_firearm/barker/arti_barker3
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/flintgonne
	name = "Hakenbüchse (+1 Simple Stock) (+1 Lock) (+1 Iron Barrel)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/twilight_simplestock = 1,
							/obj/item/twilight_ironbarrel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/flintgonne
	craftdiff = 2

/datum/anvil_recipe/engineering/twilight_guns/barker
	name = "Barker (+1 Simple Stock) (+1 Iron Barrel)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/twilight_simplestock = 1,
							/obj/item/twilight_ironbarrel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/barker
	craftdiff = 1

/datum/anvil_recipe/engineering/twilight_guns/arquebus_pistol
	name = "Arquebus Pistol (+1 Stock) (+1 Lock) (+1 Barrel)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/twilight_gunstock = 1,
							/obj/item/twilight_gunbarrel = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol
	craftdiff = 4

/datum/anvil_recipe/engineering/twilight_guns/arquebus_decorated
	name = "Decorated Arquebus (+1 Stock) (+1 Lock) (+1 Barrel) (+1 Gold)"
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/twilight_gunlock = 1,
							/obj/item/twilight_gunstock = 1,
							/obj/item/twilight_gunbarrel = 1,
							/obj/item/ingot/gold = 1)
	created_item = /obj/item/gun/ballistic/twilight_firearm/arquebus/decorated
	craftdiff = 4

/datum/anvil_recipe/weapons/twilight_arquebus_decorated
	name = "Decorated Arquebus (+1 Arquebus Rifle)"
	req_bar = /obj/item/ingot/gold
	additional_items = list(/obj/item/gun/ballistic/twilight_firearm/arquebus)
	created_item = /obj/item/gun/ballistic/twilight_firearm/arquebus/decorated
	craftdiff = 2

/datum/anvil_recipe/weapons/twilight_ramrod
	name = "Ramrod"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/twilight_ramrod
	craftdiff = 1
