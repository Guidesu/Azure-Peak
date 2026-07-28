// Ported from Vanderlin (OpenKeep): code/datums/rts/building_datums/_base_datum.dm
//
// /datum/building_datum is the blueprint/ghost-placement/construction-order
// layer: the thing a controller instantiates when it wants to place a
// building, which tracks the placement preview, resource cost, obstruction
// break-down, and hands out /datum/work_order/construct_building tasks to
// idle workers until construct_building() actually loads the real
// /obj/effect/building_node map template into the world.
//
// MAT_* renamed to DV_RTS_MAT_* - see _defines.dm header comment.
//
// ADAPTATION: source's setup_building_ghost()/move_effect() register
// COMSIG_MOB_MOUSE_ENTERED on the controller mob so the placement ghost
// follows the mouse cursor across turfs before the player commits to a
// location. This repo has no such signal wired up on mobs/atoms (Vanderlin-
// specific mouse-tracking infrastructure this port doesn't have a
// counterpart for). Per this phase's scope ("a raw click-to-place is
// sufficient... proving the construction pipeline works end-to-end, not
// making it player-friendly yet"), setup_building_ghost() below drops the
// COMSIG_MOB_MOUSE_ENTERED registration and instead just plants the preview
// at the controller's own turf; move_effect() is kept as-is for a later
// phase to wire up to whatever cursor-tracking hook it restores (Phase 4 UI
// pass should revisit this).
/obj/effect/building_outline
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	glide_size = 1000

/obj/effect/conflicting_area
	name = ""
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "red"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/conflicting_area/Initialize()
	. = ..()
	QDEL_IN(src, 5 SECONDS)

GLOBAL_LIST_INIT(cached_building_images, list())

// Places a building map template. For a single atom, use /datum/building_datum/simple instead.
// (NOTE: /datum/building_datum/simple - Vanderlin's simple_builds/_base.dm -
// is not part of this phase's scope; only the map-template-backed subtype
// used by Core/Stockpile is ported.)
/datum/building_datum
	var/mob/camera/strategy_controller/master
	var/name = "Generic Name"
	var/desc = "Generic Desc"
	///this is our template id
	var/building_template
	var/obj/effect/building_outline/generated_MA
	var/list/resource_cost = list(
		DV_RTS_MAT_STONE = 0,
		DV_RTS_MAT_WOOD = 0,
		DV_RTS_MAT_GEM = 0,
		DV_RTS_MAT_ORE = 0,
		DV_RTS_MAT_INGOT = 0,
		DV_RTS_MAT_COAL = 0,
		DV_RTS_MAT_GRAIN = 0,
		DV_RTS_MAT_MEAT = 0,
		DV_RTS_MAT_VEG = 0,
		DV_RTS_MAT_FRUIT = 0,
	)

	var/list/needed_broken_turfs = list()

	var/build_time = 40 SECONDS
	var/workers_required = 1
	var/current_workers = 0
	var/turf/center_turf

	var/building_node_path
	var/building_right_now = FALSE

	var/stockpile_needed = TRUE

	var/ui_icon
	var/ui_icon_state

/datum/building_datum/New(mob/camera/strategy_controller/created, turf/turf)
	. = ..()
	if(turf)
		if(!try_place_building(created, turf))
			return INITIALIZE_HINT_QDEL
	if(created)
		master = created
		master.building_requests |= src
		generate_preview()

/datum/building_datum/proc/generate_preview()
	if(!(type in GLOB.cached_building_images))
		var/datum/map_template/template = SSmapping.map_templates[building_template]
		var/turf/T = get_turf(master)
		var/obj/effect/building_outline/cached = template.load_as_building(T, TRUE)

		cached.alpha = 190
		cached.color = COLOR_CYAN

		generated_MA = new
		generated_MA.appearance = cached.appearance
		GLOB.cached_building_images |= type
		GLOB.cached_building_images[type] = cached

	else
		generated_MA = new
		var/obj/effect/building_outline/cached = GLOB.cached_building_images[type]
		generated_MA.appearance = cached.appearance

/datum/building_datum/proc/resource_check(mob/camera/strategy_controller/user)
	var/has_cost = FALSE
	for(var/resource in resource_cost)
		if(resource_cost[resource])
			has_cost = TRUE
			break
	if(!has_cost)
		return TRUE
	if(!user.resource_stockpile)
		return FALSE
	if(!user.resource_stockpile?.has_resources(resource_cost))
		return FALSE
	return TRUE

/datum/building_datum/proc/try_place_building(mob/camera/strategy_controller/user, turf/placed_turf)
	if(!resource_check(user))
		return

	user.resource_stockpile?.remove_resources(resource_cost)

	var/datum/map_template/template = SSmapping.map_templates[building_template]
	var/list/turfs = template.get_affected_turfs(placed_turf, centered = TRUE)

	var/list/failed_locations = list()
	for(var/turf/turf in turfs)
		// ADAPTATION: source checks /turf/closed/mineral/bedrock, a type this
		// repo doesn't have (confirmed by grep - no bedrock subtype exists
		// under code/game/turfs/closed/minerals.dm here). The closest
		// equivalent "can never be excavated" terrain in this repo is
		// /turf/closed/indestructible/rock (code/game/turfs/closed/_closed.dm).
		if(istype(turf, /turf/closed/indestructible/rock))
			failed_locations |= turf
			continue

		for(var/obj/structure/structure in turf.contents)
			if(!is_type_in_list(structure, GLOB.breakable_types))
				failed_locations |= turf
				continue
		for(var/obj/machinery/structure in turf.contents)
			failed_locations |= turf
			continue

	if(length(failed_locations))
		for(var/turf/turf in failed_locations)
			new /obj/effect/conflicting_area(turf)

		return FALSE

	center_turf = placed_turf
	for(var/turf/turf in turfs)
		for(var/obj/structure/structure in turf.contents)
			if(is_type_in_list(structure, GLOB.breakable_types))
				if(!turf.break_overlay)
					create_turf_break_overlay(turf)
					continue

		if(!isclosedturf(turf))
			continue
		needed_broken_turfs |= turf
		if(!turf.break_overlay)
			create_turf_break_overlay(turf)

	return TRUE

/datum/building_datum/proc/try_work_on(mob/living/worker)
	if(!worker.controller_mind)
		return FALSE
	if(length(needed_broken_turfs))
		for(var/turf/turf in needed_broken_turfs)
			if(!length(get_path_to(worker, turf, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250,1)))
				continue
			worker.controller_mind.set_current_task(/datum/work_order/break_turf, turf, src)
			needed_broken_turfs -= turf
			return TRUE

	if(current_workers >= workers_required)
		return FALSE

	current_workers++
	worker.controller_mind.set_current_task(/datum/work_order/construct_building, src, center_turf)
	return TRUE

/datum/building_datum/proc/construct_building()
	if(building_right_now)
		return
	building_right_now = TRUE

	var/datum/map_template/template = SSmapping.map_templates[building_template]
	template.load(center_turf, TRUE)

	for(var/turf/place_on as anything in template.get_affected_turfs(center_turf ,centered = TRUE))
		for(var/obj/effect/building_node/effect in place_on)
			effect.on_construction(master)

	after_construction()
	master.building_requests -= src
	generated_MA.moveToNullspace()

/datum/building_datum/proc/after_construction()
	return

/datum/building_datum/proc/setup_building_ghost()
	// ADAPTATION: source registers COMSIG_MOB_MOUSE_ENTERED here to make the
	// preview follow the cursor - see file header comment. Dropped for this
	// phase; the ghost is simply planted at the controller's current turf.
	master.held_build = src
	if(generated_MA)
		var/turf/T = get_turf(master)
		if(T)
			generated_MA.forceMove(T)

/datum/building_datum/proc/move_effect(mob/source, turf/new_turf)
	generated_MA.forceMove(new_turf)

/datum/building_datum/proc/clean_up(mob/source, turf/new_turf, success = FALSE)
	master.held_build = null

	if(!success)
		generated_MA.moveToNullspace()
	else
		generated_MA.forceMove(center_turf)
