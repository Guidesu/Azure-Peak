// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/patrol.dm
//
// PHASE 6. The one-leg-of-the-route work order: walk to a patrol point,
// "work" (idle) there briefly, then advance the owning persistant_workorder
// to the next point so it gets reassigned on the worker's next idle tick.
// Direct port, no adaptations needed - set_movement_target()/finish_work()
// are both base /datum/work_order procs already ported in Phase 1
// (work_orders/_base_task.dm).
/datum/work_order/patrol
	name = "Patrolling to point"
	stamina_cost = 2
	work_time_left = 3 SECONDS
	visible_message = "patrols the area."
	var/datum/persistant_workorder/patrol/patrol_order

/datum/work_order/patrol/New(mob/living/new_worker, datum/work_order/type, turf/target_point, datum/persistant_workorder/patrol/source_patrol)
	. = ..()
	patrol_order = source_patrol
	set_movement_target(target_point)

/datum/work_order/patrol/finish_work()
	if(patrol_order)
		patrol_order.advance_to_next_point()
		// Will automatically get reassigned on next process cycle
	return ..()
