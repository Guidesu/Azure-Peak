// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/make_drink.dm
//
// BUG NOTE (preserved from upstream, not fixed by this port): the source's
// New() signature is literally named /datum/work_order/eat_food/New(...) -
// a copy-paste leftover from eat_food.dm that means upstream's make_drink.dm
// silently OVERRIDES /datum/work_order/eat_food's New() instead of defining
// its own (make_drink never explicitly defines a New() of its own type at
// all - it inherits /datum/work_order's base New()). Since this port does
// not include eat_food.dm/eat_drink.dm (out of scope - see this port's idle-
// behavior scope notes), that particular collision can't happen here, but
// the make_drink/New() proc below is kept AS ITS OWN TYPE
// (/datum/work_order/make_drink/New(), not /datum/work_order/eat_food/New())
// since that's clearly the intent and upstream's typo would be actively
// wrong to reproduce in a codebase where eat_food doesn't exist to
// accidentally collide with.
/datum/work_order/make_drink
	name = "Brewing "
	work_time_left = 15 SECONDS
	stamina_cost = 5

	var/datum/bar_item/food_item
	var/obj/effect/building_node/bar/kitchen_node
	var/obj/effect/workspot/workspot

/datum/work_order/make_drink/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/cook_spot, datum/food_item/cooking_food, obj/effect/building_node/kitchen/kitchen)
	. = ..()
	food_item = cooking_food
	kitchen_node = kitchen
	name += initial(cooking_food.name)
	set_movement_target(cook_spot)
	workspot = cook_spot

/datum/work_order/make_drink/start_working(mob/living/worker_mob)
	if(!kitchen_node.use_work_materials(initial(food_item.requirements)))
		worker.controller_mind.pause_task_for(30 SECONDS, workspot)
		var/datum/bar_item/temp_item = new food_item
		kitchen_node.add_material_request(src, temp_item.requirements, 3)
		qdel(temp_item)
		return
	. = ..()

/datum/work_order/make_drink/finish_work()
	. = ..()
	kitchen_node.add_drink(food_item)
