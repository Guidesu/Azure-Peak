// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/kitchen.dm
// MAT_GRAIN renamed to DV_RTS_MAT_GRAIN - see _defines.dm header comment.
//
// TRIMMED: upstream's try_feed() dispatches /datum/work_order/eat_food or
// /datum/work_order/nappy_time when a worker goes hungry - both are part of
// the idle_tendancies/try_restore_stamina() loop that work_mind.dm's Phase 1
// header comment already trims out of this port (worker_mind.check_worktree()
// simply stalls at 0 stamina rather than seeking food/sleep), and neither
// /datum/work_order/eat_food nor /datum/work_order/nappy_time exists in this
// port (out of scope - see this port's task scope notes on idle behaviors).
// Unlike a var/type declaration, a bare type-path literal passed as a proc
// argument (set_current_task(/datum/work_order/eat_food, ...)) IS validated
// at compile time by DM regardless of whether the proc is ever called, so
// try_feed() itself is dropped here rather than kept as unreachable dead
// code - it would fail to compile otherwise. consume_food()/add_food() (the
// actually-used data-layer procs called by make_food.dm's finish_work()) are
// kept as direct ports.
/datum/food_item
	var/name = "Bread"
	var/stamina_restore = 50
	var/created_amount = 1

	var/list/requirements = list(
		DV_RTS_MAT_GRAIN = 0,
		DV_RTS_MAT_FRUIT = 0,
		DV_RTS_MAT_VEG  = 0,
		DV_RTS_MAT_MEAT = 0,
	)

/datum/food_item/bread
	name = "Bread"
	stamina_restore = 50

	requirements = list(
		DV_RTS_MAT_GRAIN = 2
	)

/obj/effect/building_node/kitchen
	name = "Kitchen"
	icon = 'icons/roguetown/misc/lighting.dmi'
	icon_state = "kitchen_icon"

	work_template = "kitchen"

	persistant_nodes = list(
		/datum/persistant_workorder/make_food/bread,
	)

	var/list/stored_foods = list(

	)

	var/list/eating_spots = list(

	)

/obj/effect/building_node/kitchen/after_construction(list/turfs)
	. = ..()
	for(var/turf/turf as anything in turfs)
		for(var/obj/effect/foodspot/spot in turf.contents)
			eating_spots |= spot

/obj/effect/building_node/kitchen/proc/consume_food(datum/food_item/food_to_consume, mob/living/hungry_worker)
	hungry_worker.controller_mind.current_stamina = min(hungry_worker.controller_mind.maximum_stamina, hungry_worker.controller_mind.current_stamina + (initial(food_to_consume.stamina_restore)))

/obj/effect/building_node/kitchen/proc/add_food(datum/food_item/incoming_food)
	stored_foods |= incoming_food
	stored_foods[incoming_food] += initial(incoming_food.created_amount)

	var/datum/food_item/food = new incoming_food
	for(var/material in food.requirements)
		work_materials[material] -= food.requirements[material]
		work_materials[material] = max(0, work_materials[material])
	qdel(food)
