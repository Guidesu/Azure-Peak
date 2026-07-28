// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/mine.dm
//
// The resource-gathering work order: worker walks to a /obj/effect/workspot
// inside a Mines building_node, works for work_time_left, then dumps
// mine_amount units of mine_mat into the node's materials_to_store list
// (later picked up by store_materials.dm and hauled to a stockpile - see
// that file and building_node/mines.dm/work_orders/persistant/mines.dm).
//
// MAT_STONE default renamed to DV_RTS_MAT_STONE - see _defines.dm header
// comment. Otherwise a direct port; finish_work()'s materials_to_store
// bump matches /obj/effect/building_node's list shape exactly (Phase 2).
/datum/work_order/mine
	name = "Mining "
	work_time_left = 30 SECONDS
	stamina_cost = 10

	var/mine_mat = DV_RTS_MAT_STONE
	var/mine_amount = 1
	var/obj/effect/building_node/mines/mine_node


/datum/work_order/mine/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/mine_spot, mining_material, obj/effect/building_node/mines/mine, work_time = 15 SECONDS)
	. = ..()
	mine_mat = mining_material
	mine_node = mine
	name += mining_material
	set_movement_target(mine_spot)
	work_time_left = work_time


/datum/work_order/mine/finish_work()
	mine_node.materials_to_store |= mine_mat
	mine_node.materials_to_store[mine_mat] += mine_amount
	. = ..()
