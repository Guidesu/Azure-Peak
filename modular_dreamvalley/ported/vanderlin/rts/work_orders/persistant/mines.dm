// Ported from Vanderlin (OpenKeep): code/datums/rts/work_orders/persistant/mines.dm
//
// The four persistent ore-mining jobs a Mines building_node owns (see
// building_node/mines.dm's persistant_nodes list) - each one is a singleton
// /datum/persistant_workorder that a worker gets bound to via
// worker_mind.assigned_work (see work_mind.dm's now-un-deferred
// check_worktree() dispatch, and building_node.select_workorder()'s radial
// menu, both Phase 3). Every time the assigned worker goes idle,
// apply_to_worker() re-queues a fresh /datum/work_order/mine at a random
// workspot inside the mine.
//
// MAT_ORE/MAT_STONE/MAT_COAL/MAT_GEM renamed to DV_RTS_MAT_* - see
// _defines.dm header comment.
//
// BUG FIX (not a functional adaptation, just correcting an obvious upstream
// copy-paste typo): the source's base /datum/persistant_workorder/mine sets
// name = "Farm" (leftover from copy-pasting persistant/farm.dm as the
// starting point) and .../mine/gem repeats name = "Mine Stone" from the
// .../mine/stones subtype above it instead of "Mine Gems". Both names are
// purely cosmetic (radial-menu label text, building_nodes.dm's
// select_workorder()) and have zero effect on game logic, so this port
// corrects them to sensible values instead of preserving the typos.
/datum/persistant_workorder/mine
	name = "Mine"
	ui_icon = 'icons/roguetown/items/ore.dmi'
	work_type = /datum/work_order/mine


/datum/persistant_workorder/mine/apply_to_worker(mob/living/worker)
	arg_1 = pick(created_node.workspots)
	arg_3 = created_node
	. = ..()

/datum/persistant_workorder/mine/ores
	name = "Mine Ores"
	ui_icon_state = "orecop1"

	arg_2 = DV_RTS_MAT_ORE
	arg_4 = 30 SECONDS

/datum/persistant_workorder/mine/stones
	name = "Mine Stone"
	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "stone1"

	arg_2 = DV_RTS_MAT_STONE
	arg_4 = 15 SECONDS

/datum/persistant_workorder/mine/coal
	name = "Mine Coal"
	ui_icon_state = "orecoal3"

	arg_2 = DV_RTS_MAT_COAL
	arg_4 = 20 SECONDS


/datum/persistant_workorder/mine/gem
	name = "Mine Gems"
	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "iridescent_scale"

	arg_2 = DV_RTS_MAT_GEM
	arg_4 = 45 SECONDS
