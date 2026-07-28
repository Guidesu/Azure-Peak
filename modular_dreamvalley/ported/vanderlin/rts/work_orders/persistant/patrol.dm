// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/persistant/patrol.dm
//
// PHASE 6. The persistent job that cycles a worker through its own
// controller_mind.patrol_points list (built by the player via a right-click
// sequence on controller_mob.dm - see that file's patrol_setup_active
// handling). Unlike every other persistant_workorder in this port
// (mine/farm/lumber_yard/etc), this one is NOT owned by a building_node -
// created_node stays null (source's New() signature passes source = null,
// matching upstream's create_patrol_order() call), since a patrol route
// belongs to the worker itself, not a jobsite.
//
// Direct port. apply_to_worker() reads worker.controller_mind.patrol_points
// (work_mind.dm's Phase 6 un-defer, see that file) instead of any building
// data.
/datum/persistant_workorder/patrol
	name = "Patrolling"
	ui_icon = 'icons/roguetown/misc/structure.dmi'
	ui_icon_state = "sign"
	work_type = /datum/work_order/patrol

	var/mob/living/patrolling_mob
	var/current_point_index = 1

/datum/persistant_workorder/patrol/New(obj/effect/building_node/source, mob/living/mob, list/turf/points)
	. = ..()
	patrolling_mob = mob
	current_point_index = 1

/datum/persistant_workorder/patrol/Destroy(force)
	patrolling_mob = null
	return ..()

/datum/persistant_workorder/patrol/apply_to_worker(mob/living/worker)
	if(!worker.controller_mind)
		return
	if(worker.controller_mind.current_task)
		return

	// Set current target point from the mob's own patrol points
	if(!length(worker.controller_mind.patrol_points))
		return

	if(current_point_index > length(worker.controller_mind.patrol_points))
		current_point_index = 1

	arg_1 = worker.controller_mind.patrol_points[current_point_index]
	worker.controller_mind.set_current_task(work_type, arg_1, src)

/datum/persistant_workorder/patrol/proc/advance_to_next_point()
	current_point_index++
	if(current_point_index > length(patrolling_mob.controller_mind.patrol_points))
		current_point_index = 1
