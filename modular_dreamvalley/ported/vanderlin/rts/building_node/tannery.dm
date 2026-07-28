// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/tannery.dm
// Direct port of the building_node itself. See building_datums/tannery.dm's
// header comment for why the building_datum/map_template/.dmm around this
// node are new files, not ports - upstream never shipped a way to place this
// node in a real game.
/obj/effect/building_node/tannery
	name = "Tannery"
	work_template = "tannery"
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "leather"
	persistant_nodes = list(
		/datum/persistant_workorder/tan_leather,
	)
