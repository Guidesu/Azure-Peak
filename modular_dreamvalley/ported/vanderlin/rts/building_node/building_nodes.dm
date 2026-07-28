// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/building_nodes.dm
//
// /obj/effect/building_node is the placed-instance/functional layer: the
// actual thing left behind in the world after a /datum/building_datum
// finishes construct_building(). This REPLACES this port's Phase 1
// /obj/effect/building_node forward-declaration stub
// (_phase2_stubs.dm, deleted as of this phase - see _dreamvalley.dm's
// #include list).
//
// ADAPTATION: handle_right_click() in the source opens the gear UI
// (user.open_gear_ui(src), Phase 5's gear_menu.dm/controller_mob.dm UI var).
// Neither exists yet in this port, so it's trimmed to a no-op for this
// phase, matching the same "reference the type, but don't call procs that
// don't exist yet" trimming rule used throughout this port (see work_mind.dm/
// controller_mob.dm Phase 1 header comments). The store_gear/retrieve_gear/
// get_stored_gear*/get_storage_capacity/can_store_more procs below are kept
// as direct ports even though /datum/worker_gear (Phase 5) doesn't exist as
// a real type yet: they only ever reference it in var/proc-arg type
// declarations (which DM resolves fine as an implicit forward-declared
// datum type, same as this port's Phase 1 stub pattern), they never call a
// proc on a worker_gear instance - so nothing here is load-bearing on Phase
// 5 actually existing, and Phase 5 can start using these storage procs for
// real immediately once it lands.
// PHASE 5: the forward-declaration stub that used to live here
// (/datum/worker_gear with just a "slot" var) has been deleted now that
// modular_dreamvalley/ported/vanderlin/rts/worker_gear.dm provides the real
// type - see that file's header comment. store_gear()/get_stored_gear_by_slot()
// below now resolve against the real type's full var block (a strict
// superset of the stub), unchanged otherwise.

/obj/effect/building_node
	name = "Building Node"
	desc = "A generic building"
	plane = DV_RTS_STRATEGY_PLANE

	///this is our template id
	var/work_template

	var/list/added_assignments

	var/list/workspots = list()

	var/maximum_workers = 1

	var/list/materials_to_store = list()

	var/list/material_requests = list()

	var/list/persistant_nodes = list()

	var/list/work_materials = list()

	var/list/stored_gear = list()

/obj/effect/building_node/Click(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		handle_right_click(usr)

/obj/effect/building_node/proc/handle_right_click(mob/camera/strategy_controller/user)
	if(!istype(user))
		return
	// PHASE 5 UN-DEFER: ui/gear_menu.dm now exists - see this file's header
	// comment. NOTE: in practice this proc is not reached via the normal
	// click path in this port - /mob/camera/strategy_controller/ClickOn()
	// (controller_mob.dm) fully handles every right-click on a
	// /obj/effect/building_node itself (job-assignment when a worker panel
	// is open, open_gear_ui() otherwise) and never falls through to
	// ..() -> /atom/Click() for that case. This override is kept as a direct
	// port for parity with upstream and as a safety net for any future code
	// path that calls Click()/handle_right_click() directly instead of going
	// through ClickOn().
	user.open_gear_ui(src)

/obj/effect/building_node/proc/store_gear(obj/item/item, datum/worker_gear/gear_datum)
	if(!stored_gear)
		stored_gear = list()

	var/slot_type = gear_datum?.slot || "unknown"
	var/gear_type = gear_datum?.type || /datum/worker_gear

	// Create unique key
	var/gear_key = "[slot_type]_[gear_type]_[stored_gear.len + 1]"

	// Store both item and gear datum
	stored_gear[gear_key] = list("item" = item, "gear" = gear_datum)
	item.forceMove(src)

	return gear_key

/obj/effect/building_node/proc/retrieve_gear(gear_key)
	if(!stored_gear || !(gear_key in stored_gear))
		return null

	var/list/gear_data = stored_gear[gear_key]
	stored_gear -= gear_key

	return gear_data // Returns list("item" = item, "gear" = gear_datum)

/obj/effect/building_node/proc/get_stored_gear(gear_key)
	if(!stored_gear)
		return null
	return stored_gear[gear_key]

/obj/effect/building_node/proc/get_stored_gear_by_slot(slot_type)
	if(!stored_gear)
		return list()

	var/list/matching_gear = list()
	for(var/gear_key in stored_gear)
		var/list/gear_data = stored_gear[gear_key]
		var/datum/worker_gear/gear = gear_data["gear"]
		if(gear && gear.slot == slot_type)
			matching_gear[gear_key] = gear_data

	return matching_gear

/obj/effect/building_node/proc/get_all_stored_gear()
	if(!stored_gear)
		return list()
	return stored_gear.Copy()

/obj/effect/building_node/proc/get_storage_capacity(slot_type)
	return 20 // Can store 20 items per slot type

/obj/effect/building_node/proc/get_stored_count(slot_type)
	var/list/matching = get_stored_gear_by_slot(slot_type)
	return length(matching)

/obj/effect/building_node/proc/can_store_more(slot_type)
	return get_stored_count(slot_type) < get_storage_capacity(slot_type)

/obj/effect/building_node/proc/on_construction(mob/camera/strategy_controller/master_controller)
	SHOULD_CALL_PARENT(TRUE)
	master_controller.constructed_building_nodes |= src
	if(length(added_assignments))
		master_controller.add_assignments(added_assignments)

	var/datum/map_template/template = SSmapping.map_templates[work_template]

	var/list/turfs = template.get_affected_turfs(get_turf(src), TRUE)
	for(var/turf/turf as anything in turfs)
		for(var/obj/effect/workspot/spot in turf.contents)
			workspots |= spot
	after_construction(turfs, master_controller)

	var/list/created_nodes = list()
	for(var/datum/persistant_workorder/node as anything in persistant_nodes)
		created_nodes |= new node(src)
	persistant_nodes = created_nodes

/obj/effect/building_node/proc/after_construction(list/turfs, mob/camera/strategy_controller/master)
	SHOULD_CALL_PARENT(TRUE)
	// TRIMMED: source also links any /obj/structure/lootable_structure/stockpile
	// found on the building's turfs to master.resource_stockpile (Phase 7's
	// raidable-loot layer, stockpile_loot_spawner.dm/structures/
	// loot_structures.dm - neither ported yet). No lootable_structure type
	// exists in this port yet, so that loop is dropped for this phase; the
	// stockpile .dmm template below places plain crates/racks instead of
	// lootable_structure/stockpile variants (see the .dmm porting notes).
	return

/obj/effect/building_node/proc/add_material_request(location, list/resource_amount, multiplier = 1)
	if(location in material_requests)
		return
	material_requests |= location

	for(var/resource in resource_amount)
		resource_amount[resource] *= multiplier
	material_requests[location] = resource_amount

/obj/effect/building_node/proc/use_work_materials(list/used_materials)
	if(!length(work_materials))
		return FALSE

	for(var/material in used_materials)
		if(!(material in work_materials))
			return FALSE
		if(work_materials[material] < used_materials[material])
			return FALSE

	for(var/material in used_materials)
		work_materials[material] -= used_materials[material]
	return TRUE

/obj/effect/building_node/proc/select_workorder(mob/user)
	if(!length(persistant_nodes))
		return
	var/list/name_to_node = list()
	var/list/radial_options = list()
	for(var/datum/persistant_workorder/order in persistant_nodes)
		radial_options |= order.name
		radial_options[order.name] = image(order.ui_icon, order.ui_icon_state)
		name_to_node |= order.name
		name_to_node[order.name] = order

	var/picked = show_radial_menu(user, src, radial_options)
	if(!picked)
		return

	return name_to_node[picked]

/obj/effect/building_node/stockpile
	name = "Stockpile"
	work_template = "stockpile"

	var/datum/stockpile/stockpile

/obj/effect/building_node/stockpile/on_construction(mob/camera/strategy_controller/master_controller)
	. = ..()
	if(!master_controller.resource_stockpile)
		master_controller.resource_stockpile = new /datum/stockpile
	stockpile = master_controller.resource_stockpile

/obj/effect/building_node/proc/override_click(mob/camera/strategy_controller/user)
	return FALSE
