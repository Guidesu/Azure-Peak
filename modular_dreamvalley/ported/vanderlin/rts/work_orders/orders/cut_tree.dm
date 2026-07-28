// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/cut_tree.dm
// (source file is misleadingly named cut_tree.dm but defines /datum/work_order/cut_wood -
// kept the same filename/type split as upstream for easy diffing against source.)
//
// The wood-cutting work order: worker walks to a /obj/effect/workspot inside
// a Lumber Yard building_node, works for work_time_left, then dumps
// mine_amount units of cut_mat into the node's materials_to_store list -
// same shape as mine.dm/farm_food.dm.
//
// MAT_WOOD default renamed to DV_RTS_MAT_WOOD - see _defines.dm header
// comment.
/datum/work_order/cut_wood
	name = "Cutting Tree"
	work_time_left = 30 SECONDS
	stamina_cost = 10

	var/cut_mat = DV_RTS_MAT_WOOD
	var/mine_amount = 1
	var/obj/effect/building_node/lumber_yard/lumber_yard

/datum/work_order/cut_wood/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/work_spot, obj/effect/building_node/lumber_yard/lumber)
	. = ..()
	lumber_yard = lumber
	set_movement_target(work_spot)

/datum/work_order/cut_wood/finish_work()
	lumber_yard.materials_to_store |= cut_mat
	lumber_yard.materials_to_store[cut_mat] += mine_amount
	. = ..()
