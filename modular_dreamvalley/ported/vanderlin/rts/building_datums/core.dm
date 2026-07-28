// Ported from Vanderlin (OpenKeep): code/datums/rts/building_datums/core.dm
//
// The "World Core" bootstrap building: free, instant, one-per-controller,
// and the thing that actually seeds a fresh colony with its first worker and
// starting resources. This is the building a controller places to start the
// whole RTS loop.
//
// MAT_* renamed to DV_RTS_MAT_* - see _defines.dm header comment. The
// `mob/camera/strategy_controller/var/has_core` addition from the source
// file is instead declared as a proper var block on controller_mob.dm (this
// port's controller_mob.dm now has it in its own var list, see that file),
// since this repo doesn't scatter var-only re-openings of a type across
// unrelated files the way upstream does.
/obj/structure/heart_of_nature
	name = "heart of the forest"
	desc = "A mystical tree home of the fae"

	icon = 'icons/obj/structures/sakura_tree.dmi'
	icon_state = "sakura_tree"
	obj_flags = CAN_BE_HIT | IGNORE_SINK

	bound_height = 128
	bound_width = 128

	// ADAPTATION: source uses a SET_BASE_PIXEL(-64, 0) macro
	// (code/game/atoms.dm's header comment references it as the intended way
	// to set base_pixel_x/y, but the macro itself is not actually defined
	// anywhere in this repo - a dead reference from an incomplete upstream
	// merge). Set the underlying vars directly instead; same effect.
	base_pixel_x = -64
	base_pixel_y = 0
	pixel_x = -64
	pixel_y = 0

/datum/building_datum/core
	name = "World Core"
	desc = "The heart of civilization. This mystical structure serves as the foundation for all development."
	building_template = "core_template"
	build_time = 0 // Instant build
	workers_required = 0 // No workers needed

	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "meld"

	resource_cost = list(
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

/datum/building_datum/core/try_place_building(mob/camera/strategy_controller/user, turf/placed_turf)
	if(user.has_core)
		user.visible_message("A World Core already exists! Only one can be built.")
		return FALSE
	if(!..())
		return FALSE

	construct_building()
	return TRUE

/datum/building_datum/core/resource_check(mob/camera/strategy_controller/user)
	if(user.has_core)
		return FALSE
	. = ..()

/datum/building_datum/core/construct_building()
	master.has_core = TRUE
	..()

	if(generated_MA)
		generated_MA.moveToNullspace()
		qdel(generated_MA)

/datum/building_datum/core/after_construction()
	var/turf/spawn_turf = get_step(center_turf, pick(GLOB.cardinals))
	if(!spawn_turf)
		spawn_turf = center_turf

	master.create_new_worker_mob(spawn_turf)
	if(!master.resource_stockpile)
		master.resource_stockpile = new /datum/stockpile()
	master.resource_stockpile.add_resources(list(
		DV_RTS_MAT_STONE = 10,
		DV_RTS_MAT_WOOD = 10,
		DV_RTS_MAT_GRAIN = 5
	))
	master.visible_message("The World Core pulses with energy! Your civilization begins...")
