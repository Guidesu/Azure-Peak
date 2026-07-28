// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/persistant/forge_gear.dm
// (upstream's filename is forge_gear.dm despite defining
// /datum/persistant_workorder/craft_gear - kept the type name as-is since
// it's shared/reused across professions per this port's task instructions,
// not blacksmith-specific; the file itself is renamed craft_gear.dm here to
// match the work_order file it pairs with, work_orders/orders/craft_gear.dm).
//
// item_path/material_cost/gear_type are all MAT_*/type-path references that
// need real, existing types in this repo to resolve - see each subtype below
// for the substitutions made against upstream's item paths (this repo uses a
// different clothing/weapon type hierarchy than Vanderlin's:
// /obj/item/clothing/suit/roguetown/... instead of /obj/item/clothing/shirt/...,
// /obj/item/clothing/head/roguetown/... instead of /obj/item/clothing/head/...,
// and /obj/item/rogueweapon/... instead of /obj/item/weapon/...).
//
// DROPPED SUBTYPES (judgment call): upstream also has
// craft_gear/performer_hat (targets /obj/item/clothing/head/stewardtophat)
// and craft_gear/tailor_spectacles (targets
// /obj/item/clothing/face/spectacles/inqglasses) - neither a "steward top
// hat" nor a "spectacles"-family face-slot item exists anywhere in this
// repo's clothing tree (confirmed by grep across
// code/modules/clothing/rogueclothes/ and code/modules/clothing/glasses/).
// Since inventing a brand-new clothing item's stats/sprite is out of scope
// for a mechanical RTS port, these two craft jobs are not ported; Tailor's
// building_node (building_node/tailor.dm) omits them from its
// persistant_nodes list accordingly. Every other upstream craft_gear subtype
// (pickaxe/axe/hammer/hoe/tanning_knife/cooking_knife for Blacksmith,
// farming_hat/lumberjack_hat/chef_hat/farming_shirt/lumberjack_shirt/
// performer_clothes for Tailor) has a real equivalent item here and is
// ported below.
/datum/persistant_workorder/craft_gear
	ui_icon = 'icons/roguetown/items/misc.dmi'
	work_type = /datum/work_order/craft_gear
	var/list/gear_path
	var/list/material_cost
	var/datum/worker_gear/gear_type

/datum/persistant_workorder/craft_gear/apply_to_worker(mob/living/worker)
	arg_1 = pick(created_node.workspots)
	arg_2 = created_node
	arg_3 = pick(gear_path)
	arg_4 = material_cost
	arg_5 = gear_type
	. = ..()

// --- Blacksmith gear ---

/datum/persistant_workorder/craft_gear/pickaxe
	name = "Craft Pickaxe"
	ui_icon_state = "pick"
	ui_icon = 'icons/roguetown/weapons/tools.dmi'
	gear_path = list(/obj/item/rogueweapon/pick/militia, /obj/item/rogueweapon/pick/militia/steel)
	material_cost = list(DV_RTS_MAT_INGOT = 2, DV_RTS_MAT_WOOD = 1)
	gear_type = /datum/worker_gear/pickaxe

/datum/persistant_workorder/craft_gear/axe
	name = "Craft Axe"
	ui_icon = 'icons/roguetown/weapons/axes32.dmi'
	ui_icon_state = "axe"
	gear_path = list(/obj/item/rogueweapon/stoneaxe/woodcut, /obj/item/rogueweapon/stoneaxe/woodcut/steel)
	material_cost = list(DV_RTS_MAT_INGOT = 2, DV_RTS_MAT_WOOD = 1)
	gear_type = /datum/worker_gear/axe

/datum/persistant_workorder/craft_gear/hammer
	name = "Craft Hammer"
	ui_icon_state = "hammer"
	ui_icon = 'icons/roguetown/weapons/tools.dmi'
	gear_path = list(/obj/item/rogueweapon/mace/warhammer, /obj/item/rogueweapon/mace/warhammer/bronze)
	material_cost = list(DV_RTS_MAT_INGOT = 2, DV_RTS_MAT_WOOD = 1)
	gear_type = /datum/worker_gear/hammer

/datum/persistant_workorder/craft_gear/hoe
	name = "Craft Hoe"
	ui_icon_state = "hoe"
	ui_icon = 'icons/roguetown/weapons/tools.dmi'
	gear_path = list(/obj/item/rogueweapon/hoe)
	material_cost = list(DV_RTS_MAT_INGOT = 1, DV_RTS_MAT_WOOD = 1)
	gear_type = /datum/worker_gear/hoe

/datum/persistant_workorder/craft_gear/tanning_knife
	name = "Craft Tanning Knife"
	ui_icon = 'icons/roguetown/weapons/daggers32.dmi'
	ui_icon_state = "knife"
	gear_path = list(/obj/item/rogueweapon/huntingknife/copper)
	material_cost = list(DV_RTS_MAT_INGOT = 1)
	gear_type = /datum/worker_gear/tanning_knife

/datum/persistant_workorder/craft_gear/cooking_knife
	name = "Craft Cooking Knife"
	ui_icon = 'icons/roguetown/weapons/daggers32.dmi'
	ui_icon_state = "knife"
	gear_path = list(/obj/item/rogueweapon/huntingknife/chefknife, /obj/item/rogueweapon/huntingknife/chefknife/cleaver)
	material_cost = list(DV_RTS_MAT_INGOT = 1)
	gear_type = /datum/worker_gear/cooking_knife

// --- Tailor gear ---

/datum/persistant_workorder/craft_gear/farming_hat
	name = "Craft Farming Hat"
	ui_icon = 'icons/roguetown/clothing/head.dmi'
	ui_icon_state = "strawhat"
	gear_path = list(/obj/item/clothing/head/roguetown/strawhat)
	material_cost = list(DV_RTS_MAT_CLOTH = 2)
	gear_type = /datum/worker_gear/farming_hat

/datum/persistant_workorder/craft_gear/lumberjack_hat
	name = "Craft Lumberjack Hat"
	ui_icon = 'icons/roguetown/clothing/head.dmi'
	ui_icon_state = "chaperon"
	gear_path = list(/obj/item/clothing/head/roguetown/chaperon)
	material_cost = list(DV_RTS_MAT_LEATHER = 2)
	gear_type = /datum/worker_gear/lumberjack_hat

/datum/persistant_workorder/craft_gear/chef_hat
	name = "Craft Chef Hat"
	ui_icon = 'icons/roguetown/clothing/head.dmi'
	ui_icon_state = "cookhat"
	gear_path = list(/obj/item/clothing/head/roguetown/cookhat)
	material_cost = list(DV_RTS_MAT_CLOTH = 2)
	gear_type = /datum/worker_gear/chef_hat

/datum/persistant_workorder/craft_gear/farming_shirt
	name = "Craft Farming Shirt"
	ui_icon = 'icons/roguetown/clothing/armor.dmi'
	ui_icon_state = "apothshirt"
	gear_path = list(/obj/item/clothing/suit/roguetown/shirt/apothshirt)
	material_cost = list(DV_RTS_MAT_CLOTH = 3)
	gear_type = /datum/worker_gear/farming_shirt

/datum/persistant_workorder/craft_gear/lumberjack_shirt
	name = "Craft Lumberjack Shirt"
	ui_icon = 'icons/roguetown/clothing/armor.dmi'
	ui_icon_state = "lowcut"
	gear_path = list(/obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut)
	material_cost = list(DV_RTS_MAT_LEATHER = 4)
	gear_type = /datum/worker_gear/lumberjack_shirt

/datum/persistant_workorder/craft_gear/performer_clothes
	name = "Craft Performer Clothes"
	ui_icon = 'icons/roguetown/clothing/shirts.dmi'
	ui_icon_state = "artishirt"
	gear_path = list(/obj/item/clothing/suit/roguetown/shirt/undershirt/artificer)
	material_cost = list(DV_RTS_MAT_CLOTH = 3, DV_RTS_MAT_SILK = 2)
	gear_type = /datum/worker_gear/performer_clothes
