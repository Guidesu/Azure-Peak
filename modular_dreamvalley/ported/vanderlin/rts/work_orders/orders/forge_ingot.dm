// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/forge_ingot.dm
// MAT_ORE/MAT_COAL/MAT_INGOT renamed to DV_RTS_MAT_* - see _defines.dm
// header comment.
/datum/work_order/forge_ingot
	name = "Forging Ingots "
	work_time_left = 20 SECONDS
	stamina_cost = 5

	var/obj/effect/building_node/blacksmith/smith
	var/obj/effect/workspot/workspot

/datum/work_order/forge_ingot/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/cook_spot, obj/effect/building_node/blacksmith/blacksmith)
	. = ..()
	smith = blacksmith
	set_movement_target(cook_spot)
	workspot = cook_spot

/datum/work_order/forge_ingot/start_working(mob/living/worker_mob)
	if(!smith.use_work_materials(list(DV_RTS_MAT_ORE = 2, DV_RTS_MAT_COAL = 1)))
		worker.controller_mind.pause_task_for(30 SECONDS, workspot)
		smith.add_material_request(src, list(DV_RTS_MAT_ORE = 2, DV_RTS_MAT_COAL = 1), 3)
		return
	. = ..()

/datum/work_order/forge_ingot/finish_work()
	smith.materials_to_store |= DV_RTS_MAT_INGOT
	smith.materials_to_store[DV_RTS_MAT_INGOT] += 2
	. = ..()
