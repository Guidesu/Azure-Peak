// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/haul_materials.dm
//
// Two-phase work order: worker walks to a stockpile, grabs up to 5 units of
// each material a requesting /obj/effect/building_node has queued in its
// material_requests list, then walks back to the requesting node and dumps
// the goods into its work_materials list (consumed later by that node's own
// production work orders, e.g. mine.dm reading work_materials - though Mines
// itself has no material_requests, see building_node/mines.dm; this order
// exists generically for any future building_node that needs raw materials
// hauled in from the stockpile, such as Phase 5 professions).
//
// This is a direct port. No adaptation needed: work_order/_base_task.dm's
// start_working()/finish_work()/stop_work() plumbing (do_after, controller_mind
// pause/resume, stamina) already matches this repo's APIs (confirmed in
// Phase 1), and /datum/stockpile.stored_materials (Phase 1) /
// /obj/effect/building_node.material_requests/work_materials (Phase 2) are
// both already ported with the exact same list shapes the source reads/writes.
// MAT_* is not referenced directly in this file (the source is material-kind
// agnostic - it just iterates whatever keys are already in material_requests),
// so no DV_RTS_MAT_* renaming is needed here.
/datum/work_order/haul_materials
	name = "Hauling to "
	var/list/materials_to_get = list()

	var/obj/effect/building_node/stockpile/stockpile_node
	var/obj/effect/building_node/taking_node
	var/going_to_stockpile = TRUE

/datum/work_order/haul_materials/New(mob/living/new_worker, datum/work_order/type, obj/effect/building_node/resource_collector, mob/camera/strategy_controller/master)
	. = ..()
	if(!length(resource_collector.material_requests))
		stop_work("no material requests")
		return
	for(var/obj/effect/building_node/stockpile/pile in master.constructed_building_nodes)
		var/list/path = get_path_to(new_worker, get_turf(pile), TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250,1)
		if(length(path))
			stockpile_node = pile
			break
	if(!stockpile_node)
		stop_work("no stockpiles")
		return
	name += resource_collector.name
	taking_node = resource_collector
	set_movement_target(stockpile_node)

/datum/work_order/haul_materials/proc/grab_materials_from_stockpile()
	var/max_grab = 5

	for(var/requestor in taking_node.material_requests)
		for(var/item in taking_node.material_requests[requestor])
			if(max_grab <= 0)
				return
			var/material_count = stockpile_node.stockpile.stored_materials[item]
			var/grab_amount = min(max_grab, material_count)
			max_grab -= grab_amount

			materials_to_get |= item
			materials_to_get[item] = grab_amount

			taking_node.material_requests[requestor][item] -= grab_amount
			if(taking_node.material_requests[requestor][item] <= 0)
				taking_node.material_requests[requestor] -= item
				if(!length(taking_node.material_requests[requestor]))
					taking_node.material_requests -= requestor

			stockpile_node.stockpile.stored_materials[item] -= grab_amount
			stockpile_node.stockpile.stored_materials[item] = max(stockpile_node.stockpile.stored_materials[item], 0)

/datum/work_order/haul_materials/proc/return_materials()
	stockpile_node.stockpile.add_resources(materials_to_get)
	materials_to_get = list()

/datum/work_order/haul_materials/stop_work(reason = "unknown")
	. = ..()
	if(length(materials_to_get))
		return_materials()

// ADAPTATION: overrides _base_task.dm's start_working() entirely (rather
// than calling ..() partway through) to implement the two-leg walk, exactly
// as the source does - it duplicates the do_after()/pause bookkeeping twice
// (once per leg) instead of factoring it out, which this port preserves
// verbatim for parity with upstream. worker.controller_mind.paused is set
// directly here (matching the source) rather than via set_paused_state(),
// which skips the COMSIG_WORKER_PAUSED_CHANGED signal for these two legs -
// this is upstream's own behavior, not a port-introduced adaptation.
/datum/work_order/haul_materials/start_working(mob/living/worker_mob)
	worker.controller_mind.paused = TRUE
	worker.controller_mind.update_stat_panel()
	var/world_start_time = world.time
	if(visible_message)
		worker.visible_message("[worker] [visible_message]")

	if(!going_to_stockpile)
		if(!do_after(worker, work_time_left, target = work_target))
			worker.controller_mind.paused = FALSE
			if(!can_continue)
				stop_work("interrupted")
				return FALSE
			work_time_left = world.time - world_start_time
			return FALSE
		finish_work()
		return

	if(going_to_stockpile)
		if(!do_after(worker, work_time_left, target = work_target))
			worker.controller_mind.paused = FALSE
			if(!can_continue)
				stop_work("interrupted")
				return FALSE
			work_time_left = world.time - world_start_time
			return FALSE
		grab_materials_from_stockpile()
		set_movement_target(taking_node)
		going_to_stockpile = FALSE
		worker.controller_mind.paused = FALSE
		return

/datum/work_order/haul_materials/proc/add_materials_to_requestor()
	for(var/item in materials_to_get)
		taking_node.work_materials |= item
		taking_node.work_materials[item] += materials_to_get[item]
	materials_to_get = list()

/datum/work_order/haul_materials/finish_work()
	. = ..()
	add_materials_to_requestor()
