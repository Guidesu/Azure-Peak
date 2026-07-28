// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/persistant/farm.dm
//
// The three persistent farming jobs a Farm building_node owns (see
// building_node/farm.dm's persistant_nodes list) - each one is a singleton
// /datum/persistant_workorder that a worker gets bound to via
// worker_mind.assigned_work, matching persistant/mines.dm's pattern exactly.
// arg_2 is a bare string ("Grain"/"Fruit"/"Vegetable") rather than a
// DV_RTS_MAT_* define, matching upstream's own literal-string usage here -
// see work_orders/orders/farm_food.dm's header comment.
/datum/persistant_workorder/farm
	name = "Farm"
	ui_icon = 'icons/roguetown/items/produce.dmi'
	work_type = /datum/work_order/farm_food

/datum/persistant_workorder/farm/apply_to_worker(mob/living/worker)
	arg_1 = pick(created_node.workspots)
	arg_3 = created_node
	. = ..()

/datum/persistant_workorder/farm/grain
	name = "Farm Grains"
	ui_icon_state = "oatchaff"

	arg_2 = "Grain"

/datum/persistant_workorder/farm/fruit
	name = "Farm Fruits"
	ui_icon_state = "apple"

	arg_2 = "Fruit"

/datum/persistant_workorder/farm/vegetable
	name = "Farm Vegetables"
	ui_icon_state = "cabbage"

	arg_2 = "Vegetable"
