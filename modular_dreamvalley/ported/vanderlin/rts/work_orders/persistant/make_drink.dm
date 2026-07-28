// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/persistant/make_drink.dm
// Note: upstream's name = "Make Food" here is a copy-paste leftover from
// persistant/make_food.dm - kept verbatim for parity since it's purely
// cosmetic (radial-menu label text via building_node.select_workorder()) and
// touching it isn't part of this port's scope, same treatment as
// building_datums/lumber_yard.dm's copy-pasted desc text.
/datum/persistant_workorder/make_drink
	name = "Make Food"
	ui_icon = 'icons/roguetown/items/food.dmi'
	work_type = /datum/work_order/make_drink

/datum/persistant_workorder/make_drink/apply_to_worker(mob/living/worker)
	arg_1 = pick(created_node.workspots)
	arg_3 = created_node
	. = ..()

/datum/persistant_workorder/make_drink/beer
	name = "Brew Beer"
	ui_icon_state = "bread_salo"

	arg_2 = /datum/bar_item/beer
