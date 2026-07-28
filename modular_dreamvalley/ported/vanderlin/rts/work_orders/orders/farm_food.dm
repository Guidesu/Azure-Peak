// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/orders/farm_food.dm
//
// The farming work order: worker walks to a /obj/effect/workspot inside a
// Farm building_node, works for work_time_left, then dumps food_amount units
// of food_type into the node's materials_to_store list (later picked up by
// store_materials.dm and hauled to a stockpile - same pattern as mine.dm).
//
// food_type here is a plain string key (matching persistant/farm.dm's
// arg_2 = "Grain"/"Fruit"/"Vegetable"), not a DV_RTS_MAT_* define - this
// mirrors upstream exactly (source's persistant/farm.dm subtypes also pass
// bare string literals "Grain"/"Fruit"/"Vegetable" rather than MAT_* defines,
// which happen to already equal those exact strings - see _defines.dm's
// DV_RTS_MAT_GRAIN/DV_RTS_MAT_FRUIT/DV_RTS_MAT_VEG). Kept as literal strings
// for parity with upstream's persistant/farm.dm.
/datum/work_order/farm_food
	name = "Farming "
	work_time_left = 30 SECONDS
	stamina_cost = 10

	var/food_type = "Fruit"
	var/food_amount = 3
	var/obj/effect/building_node/farm/farm_node

/datum/work_order/farm_food/New(mob/living/new_worker, datum/work_order/type, obj/effect/workspot/farm_spot, farming_food, obj/effect/building_node/farm/farm)
	. = ..()
	food_type = farming_food
	farm_node = farm
	name += food_type
	set_movement_target(farm_spot)

/datum/work_order/farm_food/finish_work()
	farm_node.materials_to_store |= food_type
	farm_node.materials_to_store[food_type] += food_amount
	. = ..()
