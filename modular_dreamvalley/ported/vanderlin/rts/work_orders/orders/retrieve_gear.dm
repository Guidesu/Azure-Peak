// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/retrieve_gear.dm
//
// ADAPTATION: upstream treats source_storage.stored_gear as a flat list
// containing /datum/worker_gear instances directly (`gear_to_retrieve in
// source_storage.stored_gear`, `source_storage.retrieve_gear(gear_to_retrieve)`).
// This port's actual /obj/effect/building_node.stored_gear (building_node/
// building_nodes.dm, Phase 2/3) is instead a gear_key -> list("item"=item,
// "gear"=gear) map (see that file's store_gear()/retrieve_gear(gear_key)),
// which ui/gear_menu.dm's gear_slot screen objects (this phase) already key
// off of. So this work order is constructed with the gear_key string
// (matching how gear_menu.dm's create_retrieve_gear_task() calls it), not a
// bare /datum/worker_gear reference - New()/start_working()/finish_work()
// below all look the gear up by key each time rather than holding a direct
// gear reference, since the key is this port's actual stable handle into
// stored_gear.
/datum/work_order/retrieve_gear
	name = "Retrieve Gear"
	visible_message = "is retrieving equipment."
	work_time_left = 3 SECONDS
	stamina_cost = 5
	can_continue = TRUE
	var/gear_key
	var/obj/effect/building_node/source_storage

/datum/work_order/retrieve_gear/New(mob/living/worker, obj/effect/building_node/storage_node, gear_key_to_retrieve)
	. = ..()
	source_storage = storage_node
	gear_key = gear_key_to_retrieve
	work_target = storage_node

/datum/work_order/retrieve_gear/start_working(mob/living/worker_mob)
	if(!source_storage || !gear_key)
		stop_work("missing source or gear")
		return

	if(!source_storage.Adjacent(worker_mob))
		set_movement_target(source_storage)
		return

	if(!source_storage.get_stored_gear(gear_key))
		stop_work("gear no longer available")
		return
	return ..()

/datum/work_order/retrieve_gear/finish_work()
	var/list/gear_data = source_storage.get_stored_gear(gear_key)
	if(!gear_data)
		stop_work("gear no longer available")
		return

	var/datum/worker_gear/gear_to_retrieve = gear_data["gear"]
	var/obj/item/gear_item = gear_data["item"]

	if(worker.controller_mind.has_gear_in_slot(gear_to_retrieve.slot))
		stop_work("slot already occupied")
		return

	source_storage.retrieve_gear(gear_key)
	gear_to_retrieve.owner = worker.controller_mind
	worker.controller_mind.worker_gear[gear_to_retrieve.slot] = gear_to_retrieve
	gear_item.forceMove(worker)

	SEND_SIGNAL(worker.controller_mind, COMSIG_WORKER_GEAR_CHANGED, gear_to_retrieve.slot, null, gear_to_retrieve)
	. = ..()
