// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/queued_workorder.dm
// (the /obj/effect/visual_effect/turf_break / turf/break_overlay / GLOB.breakable_types
// pieces of that file - see this repo's queued_workorder.dm header comment,
// which deferred these to "a later phase porting orders/break_turf.dm").
//
// Phase 2 needs this now: building_datum._base_datum.dm's try_place_building()
// creates this overlay on every closed turf blocking a building footprint, and
// work_order/break_turf (orders/break_turf.dm) registers/relies on
// COMSIG_CANCEL_TURF_BREAK via it.
//
// NOTE on GLOB.breakable_types: Vanderlin's entire RTS codebase references
// GLOB.breakable_types (is_type_in_list(structure, GLOB.breakable_types)) in
// building_datums/_base_datum.dm, controller_mob.dm and orders/break_turf.dm,
// but never actually declares/populates it anywhere in the source (confirmed
// by grepping the whole Vanderlin tree - no GLOBAL_LIST_INIT/GLOBAL_LIST for
// it exists there either). In upstream DM, referencing an undeclared global
// evaluates to null, so is_type_in_list(structure, null) is always FALSE in
// the original game too - meaning every /obj/structure on a building
// footprint always blocks placement/build unless it's on an open turf. This
// port declares it explicitly (as an empty list) purely so
// is_type_in_list()'s second argument is a real list rather than relying on
// implicit-global null semantics, while preserving the original's always-empty
// behavior. If a later phase wants specific structures to be
// building-destructible obstacles, populate this list then.
GLOBAL_LIST_INIT(breakable_types, list())

/turf
	var/obj/effect/visual_effect/turf_break/break_overlay

/obj/effect/visual_effect/turf_break
	name = ""
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "blue"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/turf/turf_to_break

/obj/effect/visual_effect/turf_break/Initialize(mapload, ...)
	. = ..()
	turf_to_break = loc
	RegisterSignal(turf_to_break, COMSIG_QDELETING, PROC_REF(clean_up))
	RegisterSignal(turf_to_break, COMSIG_CANCEL_TURF_BREAK, PROC_REF(clean_up))

/obj/effect/visual_effect/turf_break/proc/clean_up()
	turf_to_break.break_overlay = null
	UnregisterSignal(turf_to_break, COMSIG_QDELETING)
	turf_to_break = null
	qdel(src)

/proc/create_turf_break_overlay(turf/breaking_turf)
	breaking_turf.break_overlay = new /obj/effect/visual_effect/turf_break(breaking_turf)
