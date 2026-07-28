// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/craft_gear.dm
//
// Shared crafting work order dispatched by persistant/craft_gear.dm's
// subtypes across multiple professions (Blacksmith's pickaxe/axe/hammer/hoe/
// tanning_knife/cooking_knife jobs, Tailor's hat/shirt/spectacles jobs) -
// ported once here and reused, per this port's task instructions, rather
// than duplicated per profession.
//
// Consumes material_cost from the crafting_node's work_materials (hauled in
// via haul_materials.dm/add_material_request(), same pattern as
// forge_ingot.dm/sew_clothes.dm), then spawns item_path at the node's turf,
// wraps it in a new gear_type_path /datum/worker_gear instance (Part B of
// this phase - worker_gear/_base.dm), and stores both in the building_node
// via store_gear() (building_node/building_nodes.dm, already ported in
// Phase 2/3 with a forward-declaration stub for /datum/worker_gear - this
// phase provides the real type).
//
// ADAPTATION: upstream's finish_work() calls
// `crafting_node.store_gear(gear_item, gear_datum, gear_key)` - a 3-argument
// call. This port's building_node/building_nodes.dm.store_gear() (Phase 2/3)
// only takes 2 arguments (obj/item/item, datum/worker_gear/gear_datum) and
// generates its own gear_key internally, returning it - confirmed by reading
// that proc's current body before writing this file. The 3-argument upstream
// call would fail to compile against this port's actual store_gear()
// signature, so finish_work() below calls it with 2 arguments and uses the
// returned key, instead of pre-computing gear_key itself the way upstream
// does. This is a required adaptation for this repo's actual API, not a
// stylistic choice.
/datum/work_order/craft_gear
	name = "Crafting Gear"
	work_time_left = 45 SECONDS
	stamina_cost = 12
	var/gear_type_path
	var/item_path
	var/obj/effect/building_node/crafting_node
	var/list/material_cost = list()
	var/obj/effect/workspot/workspot

/datum/work_order/craft_gear/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/work_spot, obj/effect/building_node/node, item_type, list/materials, gear_type)
	. = ..()
	crafting_node = node
	item_path = item_type
	material_cost = materials
	workspot = work_spot
	gear_type_path = gear_type
	set_movement_target(work_spot)

/datum/work_order/craft_gear/start_working(mob/living/worker_mob)
	if(!crafting_node.use_work_materials(material_cost))
		worker.controller_mind.pause_task_for(30 SECONDS, workspot)
		crafting_node.add_material_request(src, material_cost, 3)
		return
	. = ..()

/datum/work_order/craft_gear/finish_work()
	// Spawn the item
	var/obj/item/gear_item = new item_path(get_turf(crafting_node))

	// Create and attach the worker_gear datum
	var/datum/worker_gear/gear_datum = new gear_type_path(gear_item, null, null)

	// Store it in the building node - store_gear() generates its own key
	// internally and returns it (see this file's header ADAPTATION comment).
	crafting_node.store_gear(gear_item, gear_datum)

	worker.visible_message(span_notice("[worker] finishes crafting [gear_item]!"))
	. = ..()
