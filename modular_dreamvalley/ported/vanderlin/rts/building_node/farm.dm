// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/farm.dm
// Direct port. persistant_nodes references work_orders/persistant/farm.dm's
// three singleton farming jobs (ported alongside this file) - on_construction()
// (building_node/building_nodes.dm, Phase 2) instantiates one of each into
// this node's persistant_nodes list the moment the Farm finishes building.
/obj/effect/building_node/farm
	name = "Farm"
	work_template = "farm"

	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "wheatchaff"

	persistant_nodes = list(
		/datum/persistant_workorder/farm/grain,
		/datum/persistant_workorder/farm/fruit,
		/datum/persistant_workorder/farm/vegetable,
	)
