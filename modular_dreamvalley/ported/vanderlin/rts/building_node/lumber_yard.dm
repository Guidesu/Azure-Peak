// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/lumber_yard.dm
// Direct port. persistant_nodes references work_orders/persistant/lumber_yard.dm's
// single "Cut Wood" singleton job.
/obj/effect/building_node/lumber_yard
	name = "Lumber Yard"
	work_template = "lumber"

	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "logsmall"

	persistant_nodes = list(
		/datum/persistant_workorder/cut_wood,
	)
