// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/store_gear.dm
//
// ADAPTATION: upstream's finish_work() calls
// `target_storage.store_gear(gear_to_store)` (1 argument). This port's real
// store_gear(obj/item/item, datum/worker_gear/gear_datum) (building_node/
// building_nodes.dm) takes the item and the gear datum separately and
// generates/returns its own key - see work_orders/orders/craft_gear.dm's
// header comment for the same adaptation reasoning. finish_work() below
// passes both.
/datum/work_order/store_gear
	name = "Store Gear"
	visible_message = "is storing equipment."
	work_time_left = 3 SECONDS
	stamina_cost = 5
	can_continue = TRUE
	var/datum/worker_gear/gear_to_store
	var/obj/effect/building_node/target_storage

/datum/work_order/store_gear/New(mob/living/worker, obj/effect/building_node/storage_node, datum/worker_gear/gear)
	. = ..()
	target_storage = storage_node
	gear_to_store = gear
	work_target = storage_node

/datum/work_order/store_gear/start_working(mob/living/worker_mob)
	if(!target_storage || !gear_to_store)
		stop_work("missing target or gear")
		return
	if(!target_storage.Adjacent(worker_mob))
		set_movement_target(target_storage)
		return
	return ..()

/datum/work_order/store_gear/finish_work()
	var/datum/worker_gear/current_gear = worker.controller_mind.get_gear_in_slot(gear_to_store.slot)
	if(!current_gear || current_gear != gear_to_store)
		stop_work("gear no longer equipped")
		return
	var/obj/item/item_to_store = gear_to_store.item
	worker.controller_mind.worker_gear[gear_to_store.slot] = null
	target_storage.store_gear(item_to_store, gear_to_store)
	. = ..()
