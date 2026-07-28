// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/bar.dm
// MAT_GRAIN renamed to DV_RTS_MAT_GRAIN - see _defines.dm header comment.
//
// TRIMMED: same as building_node/kitchen.dm's try_feed() - upstream
// dispatches /datum/work_order/eat_drink or /datum/work_order/nappy_time,
// neither of which exists in this port (out of scope idle behaviors). Bare
// type-path literals passed as proc arguments are validated at compile time
// by DM regardless of whether the proc is ever called, so try_feed() is
// dropped entirely rather than kept as unreachable dead code - see
// building_node/kitchen.dm's header comment for the full reasoning.
// consume_drink()/add_drink() (the actually-used data-layer procs called by
// make_drink.dm's finish_work()) are kept as direct ports.
/datum/bar_item
	var/name = "Beer"
	var/stamina_restore = 10
	var/joy = 5
	var/created_amount = 1

	var/list/requirements = list(
		DV_RTS_MAT_GRAIN = 0,
		DV_RTS_MAT_FRUIT = 0,
		DV_RTS_MAT_VEG  = 0,
		DV_RTS_MAT_MEAT = 0,
	)

/datum/bar_item/beer
	name = "Beer"
	stamina_restore = 10
	joy = 10

	requirements = list(
		DV_RTS_MAT_GRAIN = 2
	)

/obj/effect/building_node/bar
	name = "Bar"
	icon = 'icons/roguetown/misc/lighting.dmi'
	icon_state = "hearth1"

	work_template = "bar"

	persistant_nodes = list(
		/datum/persistant_workorder/make_drink/beer,
	)

	var/list/stored_foods = list(

	)

	var/list/eating_spots = list(

	)

/obj/effect/building_node/bar/after_construction(list/turfs)
	. = ..()
	for(var/turf/turf as anything in turfs)
		for(var/obj/effect/foodspot/spot in turf.contents)
			eating_spots |= spot

/obj/effect/building_node/bar/proc/consume_drink(datum/food_item/food_to_consume, mob/living/hungry_worker)
	hungry_worker.controller_mind.current_stamina = min(hungry_worker.controller_mind.maximum_stamina, hungry_worker.controller_mind.current_stamina + (initial(food_to_consume.stamina_restore)))

/obj/effect/building_node/bar/proc/add_drink(datum/bar_item/incoming_food)
	stored_foods |= incoming_food
	stored_foods[incoming_food] += initial(incoming_food.created_amount)

	var/datum/bar_item/food = new incoming_food
	for(var/material in food.requirements)
		work_materials[material] -= food.requirements[material]
		work_materials[material] = max(0, work_materials[material])
	qdel(food)
