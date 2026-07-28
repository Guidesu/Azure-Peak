// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/queued_workorder.dm
//
// TRIMMED: the source file also defines /obj/effect/visual_effect/turf_break
// (the blue break-in-progress overlay) and queued_workorder/New()'s special
// case for /datum/work_order/break_turf (which creates that overlay and
// registers COMSIG_CANCEL_TURF_BREAK on the target turf). Both belong to the
// break_turf work order, which is Phase 3 (work-order breadth), not Phase 1.
// Referencing /datum/work_order/break_turf here before it exists would be a
// compile error, so that special case (and the now-unused turf/break_overlay
// var and create_turf_break_overlay() proc) is dropped for this phase. A
// later phase porting orders/break_turf.dm should reintroduce that block
// here alongside COMSIG_CANCEL_TURF_BREAK (not yet defined in this repo's
// port either - see _defines.dm).
/datum/queued_workorder
	var/datum/work_order/work_path
	var/mob/camera/strategy_controller/master

	var/arg_1
	var/arg_2
	var/arg_3
	var/arg_4

/datum/queued_workorder/New(datum/work_order/work_path, mob/living/master, arg1, arg2, arg3, arg4)
	. = ..()
	src.master = master
	src.work_path = work_path
	src.arg_1 = arg1
	src.arg_2 = arg2
	src.arg_3 = arg3
	src.arg_4 = arg4

/datum/queued_workorder/proc/clean_up()
	master?.in_progress_workorders -= src
	master = null
	qdel(src)
