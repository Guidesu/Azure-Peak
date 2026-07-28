// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/break_turf.dm
//
// Ported now (Phase 2) rather than Phase 3 per the approved plan's note that
// building construction cannot function without break_turf/construct_building
// - a building_datum with any closed turf in its footprint queues these via
// try_work_on() before it will ever queue construct_building.
//
// ADAPTATION: source's finish_work() calls breaking_turf.atom_destruction("blunt")
// for closed turfs. This repo's /turf has no atom_destruction proc (confirmed
// by reading code/game/turfs/turf_defense.dm before porting) - the
// equivalent hook here is /turf/proc/turf_destruction(damage_flag), which is
// what take_damage() calls once integrity drops to 0. Calling it directly
// (bypassing take_damage/integrity entirely) matches the source's intent of
// "instantly clear this turf once the work order finishes" rather than
// simulating combat damage.
/datum/work_order/break_turf
	name = "Mining "
	stamina_cost = 5
	work_time_left = 10 SECONDS
	visible_message = "starts to mine."

	var/datum/building_datum/on_failure_datum
	var/turf/breaking_turf

/datum/work_order/break_turf/New(mob/living/new_worker, datum/work_order/type, turf/turf_to_break, datum/building_datum/source_datum)
	. = ..()
	name += capitalize(turf_to_break.name)
	on_failure_datum = source_datum
	breaking_turf = turf_to_break
	set_movement_target(turf_to_break)
	RegisterSignal(turf_to_break, COMSIG_CANCEL_TURF_BREAK, PROC_REF(stop_work))

/datum/work_order/break_turf/Destroy(force)
	. = ..()
	if(breaking_turf)
		UnregisterSignal(breaking_turf, COMSIG_CANCEL_TURF_BREAK)

/datum/work_order/break_turf/finish_work()
	if(isclosedturf(breaking_turf))
		breaking_turf.turf_destruction("blunt")
	else
		for(var/obj/structure/structure as anything in breaking_turf.contents)
			if(is_type_in_list(structure, GLOB.breakable_types))
				qdel(structure)
	breaking_turf = null
	. = ..()

/datum/work_order/break_turf/stop_work(reason = "unknown")
	. = ..()
	if(on_failure_datum)
		on_failure_datum.needed_broken_turfs |= breaking_turf
