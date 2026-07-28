// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/_base_task.dm
//
// ADAPTATION: Vanderlin's start_working() calls this repo's do_after()
// equivalent with `interaction_key = "work"`, a named parameter this repo's
// /proc/do_after (code/__HELPERS/mobs.dm) does not have. This repo's
// signature is do_after(mob/user, delay, needhand, atom/target, progress,
// datum/callback/extra_checks, same_direction, no_interrupt,
// allow_movement) - no interaction-key/self-interrupt-dedup concept exists,
// so the call below simply drops that argument. Everything else is a direct
// port; get_work_speed_modifier()/get_stamina_cost_modifier() are trimmed to
// always return a neutral 1 modifier for this phase, since /datum/worker_gear
// (Phase 5) doesn't exist yet - the source's loop body calls procs on that
// type (gear.get_work_speed_modifier(), gear.get_task_bonus()) which can't
// resolve, not merely reference the type in a var declaration, so an empty
// stub type wouldn't be enough to keep the original loop body intact.
// worker_mind.has_gear_in_slot()/get_gear_in_slot() (work_mind.dm) already
// always return FALSE/null in this phase for the same reason, so this is
// consistent - Phase 5 should restore both together.
//
// ADAPTATION: Vanderlin's stop_work() also calls worker.stop_doing("work")
// to force-cancel an in-flight do_after() by a string interaction key. This
// repo's do_after() tracks in-progress status with a plain boolean
// /mob/doing var that it clears itself on completion or interruption -
// there is no external "cancel by key" hook to call, so that call is
// dropped below; the rest of stop_work()'s cleanup is unchanged.
/datum/work_order
	var/name = "Generic Work Order"
	var/visible_message
	var/mob/living/worker
	var/atom/work_target
	var/stamina_cost
	var/work_time_left = 0
	var/can_continue = FALSE

/datum/work_order/New(mob/living/new_worker, datum/work_order/type, ...)
	. = ..()
	worker = new_worker

/datum/work_order/proc/start_working(mob/living/worker_mob)
	worker.controller_mind.set_paused_state(TRUE, "starting work")
	worker.controller_mind.update_stat_panel()
	work_time_left /= get_work_speed_modifier(worker_mob.controller_mind)
	var/world_start_time = world.time

	if(visible_message)
		worker.visible_message("[worker] [visible_message]")

	if(!do_after(worker, work_time_left, target = work_target))
		worker.controller_mind.set_paused_state(FALSE, "work interrupted")
		if(!can_continue)
			stop_work("interrupted")
			return FALSE
		work_time_left = world.time - world_start_time
		return FALSE
	finish_work()

/datum/work_order/proc/get_work_speed_modifier(datum/worker_mind/mind)
	// TRIMMED for Phase 1 - see header comment. Neutral until worker_gear (Phase 5).
	return 1

/datum/work_order/proc/finish_work()
	SHOULD_CALL_PARENT(TRUE)
	var/true_stamina_cost = round(stamina_cost * get_stamina_cost_modifier(worker.controller_mind), 1)
	worker.controller_mind.finish_work(TRUE, true_stamina_cost)
	worker.controller_mind.update_stat_panel()

/datum/work_order/proc/get_stamina_cost_modifier(datum/worker_mind/mind)
	// TRIMMED for Phase 1 - see header comment. Neutral until worker_gear (Phase 5).
	return 1

/datum/work_order/proc/set_movement_target(atom/target)
	if(!target)
		stop_work("no target")
	if(!length(get_path_to(worker, get_turf(target), TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250,1)))
		stop_work("unreachable target")
		return
	worker.controller_mind.set_movement_target(target)

/datum/work_order/proc/stop_work(reason = "unknown")
	SHOULD_CALL_PARENT(TRUE)
	if(worker.controller_mind.current_task == src)
		SEND_SIGNAL(worker.controller_mind, COMSIG_WORKER_TASK_FAILED, src, reason)
		worker.controller_mind.stop_working()
		worker.controller_mind.update_stat_panel()
