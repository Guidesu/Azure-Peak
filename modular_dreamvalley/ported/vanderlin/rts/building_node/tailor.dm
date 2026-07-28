// Ported from Vanderlin (OpenKeep): code/datums/rts/building_node/tailor.dm
// See building_datums/tailor.dm's header comment for why the
// building_datum/map_template/.dmm around this node are new files.
//
// DROPPED: upstream's list also includes
// /datum/persistant_workorder/craft_gear/performer_hat and
// /datum/persistant_workorder/craft_gear/tailor_spectacles - both removed
// per work_orders/persistant/craft_gear.dm's header comment (no matching
// item type exists in this repo for either).
/obj/effect/building_node/tailorshop
	name = "Tailor Shop"
	work_template = "tailorshop"
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "cloth"
	persistant_nodes = list(
		/datum/persistant_workorder/sew_clothes,
		/datum/persistant_workorder/craft_gear/farming_hat,
		/datum/persistant_workorder/craft_gear/lumberjack_hat,
		/datum/persistant_workorder/craft_gear/chef_hat,
		/datum/persistant_workorder/craft_gear/farming_shirt,
		/datum/persistant_workorder/craft_gear/lumberjack_shirt,
		/datum/persistant_workorder/craft_gear/performer_clothes,
	)
