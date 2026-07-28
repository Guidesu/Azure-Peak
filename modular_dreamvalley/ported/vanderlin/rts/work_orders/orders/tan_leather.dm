// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/tan_leather.dm
//
// Consumes 1 DV_RTS_MAT_HIDE from the tannery node's work_materials (hauled
// in via haul_materials.dm/add_material_request(), same pattern as
// forge_ingot.dm), producing 1 DV_RTS_MAT_LEATHER into materials_to_store.
// MAT_HIDE/MAT_LEATHER renamed to DV_RTS_MAT_HIDE/DV_RTS_MAT_LEATHER - see
// _defines.dm header comment.
/datum/work_order/tan_leather
	name = "Tanning Leather"
	work_time_left = 40 SECONDS
	stamina_cost = 8
	var/obj/effect/building_node/tannery/tannery
	var/obj/effect/workspot/workspot

/datum/work_order/tan_leather/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/work_spot, obj/effect/building_node/tannery/tannery_node)
	. = ..()
	tannery = tannery_node
	workspot = work_spot
	set_movement_target(work_spot)

/datum/work_order/tan_leather/start_working(mob/living/worker_mob)
	if(!tannery.use_work_materials(list(DV_RTS_MAT_HIDE = 1)))
		worker.controller_mind.pause_task_for(30 SECONDS, workspot)
		tannery.add_material_request(src, list(DV_RTS_MAT_HIDE = 1), 3)
		return
	. = ..()

/datum/work_order/tan_leather/finish_work()
	tannery.materials_to_store |= DV_RTS_MAT_LEATHER
	tannery.materials_to_store[DV_RTS_MAT_LEATHER] += 1
	. = ..()
