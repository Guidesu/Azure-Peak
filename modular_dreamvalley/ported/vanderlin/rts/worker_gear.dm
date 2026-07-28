// Ported from Vanderlin (OpenKeep): code/datums/rts/worker_gear/_base.dm
//
// This REPLACES this port's Phase 2/3 forward-declaration stub for
// /datum/worker_gear (building_node/building_nodes.dm's header comment
// flagged this file as the one to delete that stub for - the stub's single
// `var/slot` is superseded by the full var block below, which is a strict
// superset).
//
// TASK_KEY_QUALITY added to _defines.dm alongside this file - see that
// file's header comment for why it wasn't needed until now.
//
// DROPPED TASK_BONUSES (not dropped gear types): every task_bonuses entry
// keyed on /datum/work_order/play_music is removed from the three gear types
// that had one (instrument, performer_hat, performer_clothes) - play_music
// is Vanderlin's bar-performer idle-tendency work order
// (work_orders/orders/play_music.dm), which this port does not include
// (idle_tendancies/wander_to_building/socialize_with/play_music/mourn_dead/
// nappy_time are all out of scope per work_mind.dm's Phase 1 header comment:
// perform_idle() is a no-op stub in this port, and nothing dispatches
// play_music work orders). A task_bonuses list keyed on a type that doesn't
// exist would fail to compile (DM resolves type-path list keys at compile
// time, unlike the var/type-only forward-reference pattern used elsewhere in
// this port), so these three gear types keep their base stat modifiers
// (stamina_regen_modifier etc) but lose the play_music-specific bonus
// entries. instrument/performer_hat/performer_clothes are still fully valid
// gear datums otherwise - performer_clothes in particular is actively
// crafted by Tailor's craft_gear/performer_clothes job
// (work_orders/persistant/craft_gear.dm).
//
// Otherwise a direct, unmodified port: no MAT_* usage (all task_bonuses keys
// are DM work_order type-paths and TASK_KEY_* string defines, not stockpile
// material constants), and no other API adaptation needed - WORKER_SLOT_*
// (_defines.dm, Phase 1) and every /datum/work_order/* type referenced below
// (mine, break_turf, farm_food, cut_wood, forge_ingot, make_food, make_drink,
// tan_leather, sew_clothes) already exist in this port by this point in
// Phase 5.
/datum/worker_gear
	var/obj/item/item
	var/slot
	var/datum/worker_mind/owner

	// Gear effects
	var/work_speed_modifier = 1.0
	var/stamina_cost_modifier = 1.0
	var/walkspeed_modifier = 0
	var/stamina_regen_modifier = 1.0
	var/stamina_modifier = 0

	// Task-specific bonuses
	var/list/task_bonuses = list()

/datum/worker_gear/New(obj/item/new_item, new_slot, datum/worker_mind/new_owner)
	. = ..()
	item = new_item
	if(new_slot)
		slot = new_slot
	owner = new_owner

/datum/worker_gear/proc/get_task_bonus(datum/work_order/task, task_key)
	// Apply any task-specific bonuses
	for(var/task_type in task_bonuses)
		if(istype(task, task_type) && (task_key in task_bonuses[task_type]))
			var/list/bonuses = task_bonuses[task_type]
			return bonuses[task_key]
	return

/datum/worker_gear/proc/get_work_speed_modifier()
	return work_speed_modifier

/datum/worker_gear/proc/get_stamina_cost_modifier()
	return stamina_cost_modifier

/datum/worker_gear/proc/get_walkspeed_modifier()
	return walkspeed_modifier

/datum/worker_gear/proc/get_stamina_regen_modifier()
	return stamina_regen_modifier

/datum/worker_gear/proc/get_stamina_modifier()
	return stamina_modifier

/datum/worker_gear/instrument
	slot = WORKER_SLOT_HANDS

/datum/worker_gear/performer_hat
	slot = WORKER_SLOT_HEAD
	stamina_regen_modifier = 1.2

/datum/worker_gear/performer_clothes
	slot = WORKER_SLOT_SHIRT

/datum/worker_gear/pickaxe
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/mine = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9, TASK_KEY_QUANTITY = 2),
		/datum/work_order/break_turf = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/miner_cap
	slot = WORKER_SLOT_HEAD
	task_bonuses = list(
		/datum/work_order/mine = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9),
		/datum/work_order/break_turf = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/miner_shoes
	slot = WORKER_SLOT_SHOES
	task_bonuses = list(
		/datum/work_order/mine = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9),
		/datum/work_order/break_turf = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/miner_chest
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/mine = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9),
		/datum/work_order/break_turf = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/miner_pants
	task_bonuses = list(
		/datum/work_order/mine = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9),
		/datum/work_order/break_turf = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/hoe
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/farm_food = list(TASK_KEY_SPEED = 1.15, TASK_KEY_REDUCTION = 0.85, TASK_KEY_QUANTITY = 1.2)
	)

/datum/worker_gear/farming_hat
	slot = WORKER_SLOT_HEAD
	task_bonuses = list(
		/datum/work_order/farm_food = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)
	stamina_regen_modifier = 1.1

/datum/worker_gear/farming_boots
	slot = WORKER_SLOT_SHOES
	task_bonuses = list(
		/datum/work_order/farm_food = list(TASK_KEY_SPEED = 1.05, TASK_KEY_REDUCTION = 0.95)
	)
	walkspeed_modifier = -0.1

/datum/worker_gear/farming_shirt
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/farm_food = list(TASK_KEY_SPEED = 1.05, TASK_KEY_REDUCTION = 0.95)
	)
	stamina_modifier = 5

/datum/worker_gear/axe
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/cut_wood = list(TASK_KEY_SPEED = 1.2, TASK_KEY_REDUCTION = 0.8, TASK_KEY_QUANTITY = 1.5)
	)

/datum/worker_gear/lumberjack_hat
	slot = WORKER_SLOT_HEAD
	task_bonuses = list(
		/datum/work_order/cut_wood = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/lumberjack_boots
	slot = WORKER_SLOT_SHOES
	task_bonuses = list(
		/datum/work_order/cut_wood = list(TASK_KEY_SPEED = 1.08, TASK_KEY_REDUCTION = 0.92)
	)
	walkspeed_modifier = -0.15

/datum/worker_gear/lumberjack_shirt
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/cut_wood = list(TASK_KEY_SPEED = 1.05, TASK_KEY_REDUCTION = 0.95)
	)
	stamina_modifier = 8

/datum/worker_gear/hammer
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/forge_ingot = list(TASK_KEY_SPEED = 1.25, TASK_KEY_REDUCTION = 0.75, TASK_KEY_QUALITY = 1.1)
	)

/datum/worker_gear/smith_apron
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/forge_ingot = list(TASK_KEY_SPEED = 1.15, TASK_KEY_REDUCTION = 0.85)
	)
	stamina_regen_modifier = 1.15

/datum/worker_gear/smith_boots
	slot = WORKER_SLOT_SHOES
	task_bonuses = list(
		/datum/work_order/forge_ingot = list(TASK_KEY_SPEED = 1.05, TASK_KEY_REDUCTION = 0.95)
	)
// (forge_ingot now exists as of Blacksmith - see work_orders/orders/forge_ingot.dm)

/datum/worker_gear/cooking_knife
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/make_food = list(TASK_KEY_SPEED = 1.2, TASK_KEY_REDUCTION = 0.8, TASK_KEY_QUALITY = 1.15)
	)

/datum/worker_gear/chef_hat
	slot = WORKER_SLOT_HEAD
	task_bonuses = list(
		/datum/work_order/make_food = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9),
		/datum/work_order/make_drink = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/chef_apron
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/make_food = list(TASK_KEY_SPEED = 1.12, TASK_KEY_REDUCTION = 0.88),
		/datum/work_order/make_drink = list(TASK_KEY_SPEED = 1.12, TASK_KEY_REDUCTION = 0.88)
	)
	stamina_modifier = 5

/datum/worker_gear/brewing_paddle
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/make_drink = list(TASK_KEY_SPEED = 1.15, TASK_KEY_REDUCTION = 0.85, TASK_KEY_QUALITY = 1.1)
	)

/datum/worker_gear/brewer_apron
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/make_drink = list(TASK_KEY_SPEED = 1.1, TASK_KEY_REDUCTION = 0.9)
	)

/datum/worker_gear/tanning_knife
	slot = WORKER_SLOT_HANDS
	task_bonuses = list(
		/datum/work_order/tan_leather = list(TASK_KEY_SPEED = 1.2, TASK_KEY_REDUCTION = 0.8, TASK_KEY_QUALITY = 1.1)
	)

/datum/worker_gear/tanner_apron
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/tan_leather = list(TASK_KEY_SPEED = 1.15, TASK_KEY_REDUCTION = 0.85)
	)
	stamina_modifier = 5

/datum/worker_gear/sewing_needle
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/sew_clothes = list(TASK_KEY_SPEED = 1.25, TASK_KEY_REDUCTION = 0.75, TASK_KEY_QUALITY = 1.15)
	)

/datum/worker_gear/tailor_spectacles
	slot = WORKER_SLOT_HEAD

/datum/worker_gear/tailor_apron
	slot = WORKER_SLOT_SHIRT
	task_bonuses = list(
		/datum/work_order/sew_clothes = list(TASK_KEY_SPEED = 1.08, TASK_KEY_REDUCTION = 0.92)
	)
