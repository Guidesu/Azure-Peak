// Phase 1 verification aid for the Vanderlin RTS port (not part of the
// Vanderlin source - written for this port only).
//
// Spawns a /mob/camera/strategy_controller at the admin's turf and gives it
// one debug worker, to confirm both types Initialize()/New() and begin
// ticking under SSstrategy_master without runtime errors. Per the approved
// porting plan, Phase 1's verification bar is "a camera-mob controller and
// a debug worker mob exist and tick without errors; no player-facing way to
// trigger this yet (admin-only test verb is fine for verification)." This
// verb exists solely to satisfy that bar in a live-server smoke test; it is
// not wired into this repo's admin_verbs_debug_* GLOBAL_LIST_INIT
// verb-grant lists (code/modules/admin/verbs/*.dm) since it's a throwaway
// diagnostic, not a permanent admin tool - remove it once Phase 2+ adds a
// real player-facing way to spawn a controller (e.g. the Overlord antag's
// summon_worker spell in Phase 7).
/client/var/mob/camera/strategy_controller/debug_rts_controller

/client/proc/debug_spawn_rts_controller()
	set name = "Debug Spawn RTS Controller"
	set category = "Debug"
	set desc = "Spawns a strategy_controller + one debug worker at your turf to smoke-test the RTS port."

	if(!check_rights(R_DEBUG))
		return

	var/turf/spawn_turf = get_turf(mob)
	if(!spawn_turf)
		to_chat(usr, span_warning("No valid turf to spawn at."))
		return

	var/mob/camera/strategy_controller/controller = new(spawn_turf)
	var/mob/living/worker = controller.create_new_worker_mob(spawn_turf)
	debug_rts_controller = controller

	to_chat(usr, span_notice("Spawned strategy_controller ([REF(controller)]) with worker [worker] ([REF(worker)]). Watch for runtime errors over the next few ticks."))

// Phase 2 verification aid for the Vanderlin RTS port (not part of the
// Vanderlin source - written for this port only).
//
// Per the approved porting plan, Phase 2's building-pipeline goal is:
// "place -> break-obstruction -> construct -> register end-to-end flow works
// for at least the Core and Stockpile buildings, verified by an admin test
// spawning a controller and placing both." The plan's task text also says a
// purchasable-building-menu UI is explicitly out of scope for this phase
// ("a debug/admin verb triggering 'start placing building X' and a raw
// click-to-place is sufficient").
//
// This verb queues a building directly at a chosen turf via
// queue_building_build() (bypassing the ghost-follow-cursor flow entirely,
// since that flow's mouse-tracking hook (COMSIG_MOB_MOUSE_ENTERED) isn't
// wired up in this port yet - see building_datums/_base_datum.dm's header
// comment). This is enough to prove the real pipeline end to end:
// try_place_building() validates/charges resources and queues
// needed_broken_turfs, building_requests dispatches idle workers via
// try_work_on() to break_turf/construct_building work orders, and
// construct_building() finally loads the real building_node map template
// and calls on_construction() - the exact same code path the eventual
// building-menu UI (Phase 4) will drive.
//
// Usage: run debug_spawn_rts_controller() first (or reuse an existing one -
// this verb falls back to the last controller spawned by this client, then
// to any strategy_controller in the world if none was tracked), then run
// this verb once for the Core (it's free/instant/workerless, so it
// completes on the same tick) and again for the Stockpile (costs nothing per
// stockpile.dm's resource_cost inheriting the base zeroed-out list, but does
// require a worker to walk over and spend build_time constructing it - watch
// your worker path to the site and finish the build).
/client/proc/debug_place_rts_core()
	set name = "Debug Place RTS Core"
	set category = "Debug"
	set desc = "Queues a World Core building_datum at your turf on the last-spawned (or any) strategy_controller, to smoke-test the Phase 2 building pipeline."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/core, "Core (World Core)")

/client/proc/debug_place_rts_stockpile()
	set name = "Debug Place RTS Stockpile"
	set category = "Debug"
	set desc = "Queues a Stockpile building_datum at your turf on the last-spawned (or any) strategy_controller, to smoke-test the Phase 2 building pipeline."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/stockpile, "Stockpile")

/client/proc/_debug_place_rts_building(build_path, build_name)
	var/mob/camera/strategy_controller/controller = debug_rts_controller
	if(!controller || QDELETED(controller))
		for(var/mob/camera/strategy_controller/existing in GLOB.mob_list)
			controller = existing
			break

	if(!controller)
		to_chat(usr, span_warning("No strategy_controller found - run Debug Spawn RTS Controller first."))
		return

	var/turf/target_turf = get_turf(mob)
	if(!target_turf)
		to_chat(usr, span_warning("No valid turf to place at."))
		return

	controller.queue_building_build(build_path, target_turf)
	to_chat(usr, span_notice("Queued [build_name] on controller [REF(controller)] at [target_turf.x],[target_turf.y]. If it needs workers, watch [controller]'s worker(s) path in and construct it; on_construction() should register it in constructed_building_nodes when done."))

// Phase 3 verification aid for the Vanderlin RTS port (not part of the
// Vanderlin source - written for this port only).
//
// Per the approved porting plan, Phase 3's goal is: "a worker can be
// assigned to a mine, produce ore into the node, get auto-hauled to the
// stockpile by a second worker - proving the persistent-job + hauler-
// dispatch loop the whole economy depends on." That needs, in order:
//   1. A Stockpile already built (Phase 2's debug_place_rts_stockpile),
//      since haul_materials/store_materials both require a reachable
//      /obj/effect/building_node/stockpile in constructed_building_nodes -
//      see those files' New(). Without one, both work orders immediately
//      stop_work("no stockpile(s)").
//   2. A Mine built and constructed (this verb places one via the same
//      queue_building_build() pattern Phase 2's debug verbs use).
//   3. A second worker bound to one of the Mine's four persistant_nodes
//      jobs via the new work_mind.dm assign_persistent_work() proc, so
//      check_worktree() keeps re-queuing /datum/work_order/mine on it
//      every time it idles.
//   4. Nothing else - once the worker starts producing
//      materials_to_store, controller_mob.dm's process() loop (this
//      phase's un-deferred haul/store dispatch block) automatically assigns
//      *any* other idle worker (including the same one, once it goes idle
//      between mining bouts, or a third worker if one exists) to
//      store_materials, walking the ore to the stockpile.
//
// This verb reuses the last-spawned (or any) strategy_controller exactly
// like debug_place_rts_core/stockpile above, places a Mine at the admin's
// turf, spawns one dedicated extra worker, and binds that worker to
// "Mine Ores" (/datum/persistant_workorder/mine/ores) so ore production
// starts immediately once the Mine finishes construction. The existing
// worker(s) on the controller remain free to pick up the auto-hauling once
// materials_to_store has something in it - per the plan's phrasing ("get
// auto-hauled to the stockpile by a second worker"), this verb spawns that
// second worker explicitly rather than assuming the controller already has
// one (debug_spawn_rts_controller only creates one worker).
//
// Usage: debug_spawn_rts_controller -> debug_place_rts_stockpile (and wait
// for the worker to walk over and build it) -> debug_place_rts_mine_and_assign_miner
// (place the Mine somewhere reachable, wait for construction) -> watch: the
// assigned miner should start walking to a workspot inside the Mine, mine
// for 30 seconds, dump ore into materials_to_store, then either it or the
// other worker should automatically pick up store_materials and haul the
// ore to the Stockpile's /datum/stockpile.stored_materials[DV_RTS_MAT_ORE].
// Use debug_rts_check_economy (below) to print current state without
// digging through variables manually.
/client/proc/debug_place_rts_mine_and_assign_miner()
	set name = "Debug Place RTS Mine + Assign Miner"
	set category = "Debug"
	set desc = "Queues a Mine building_datum at your turf, spawns a dedicated worker, and binds it to the Mine Ores persistent job once built - smoke-tests the Phase 3 mine->haul->stockpile loop."

	if(!check_rights(R_DEBUG))
		return

	var/mob/camera/strategy_controller/controller = debug_rts_controller
	if(!controller || QDELETED(controller))
		for(var/mob/camera/strategy_controller/existing in GLOB.mob_list)
			controller = existing
			break

	if(!controller)
		to_chat(usr, span_warning("No strategy_controller found - run Debug Spawn RTS Controller first."))
		return

	var/turf/target_turf = get_turf(mob)
	if(!target_turf)
		to_chat(usr, span_warning("No valid turf to place at."))
		return

	var/mob/living/miner = controller.create_new_worker_mob(target_turf)
	controller.queue_building_build(/datum/building_datum/mines, target_turf)

	to_chat(usr, span_notice("Queued Mine on controller [REF(controller)] at [target_turf.x],[target_turf.y], and spawned dedicated worker [miner] ([REF(miner)]). Once the Mine finishes construction, run Debug Assign Worker To Mine to bind [miner] (or any worker) to a mining job."))

// Separated from the placement verb above because construction is not
// instant (build_time on /datum/building_datum/mines inherits the base
// 40-second default, plus needing a worker to walk over and build it first)
// - the admin needs to place the Mine, wait for on_construction() to run
// (which populates persistant_nodes on the resulting
// /obj/effect/building_node/mines instance), and only then can a worker
// actually be bound to one of its jobs. Binds the LAST controller's
// LAST-SPAWNED worker (world.time order via worker_mobs' insertion order)
// to the first Mine found in constructed_building_nodes, picking the "Mine
// Ores" job specifically since ore is this port's DV_RTS_MAT_ORE - the
// stockpile constant most convenient to visually confirm in
// debug_rts_check_economy's stockpile dump below.
/client/proc/debug_assign_worker_to_mine()
	set name = "Debug Assign Worker To Mine"
	set category = "Debug"
	set desc = "Binds your controller's most-recently-spawned worker to a constructed Mine's 'Mine Ores' persistent job."

	if(!check_rights(R_DEBUG))
		return

	var/mob/camera/strategy_controller/controller = debug_rts_controller
	if(!controller || QDELETED(controller))
		for(var/mob/camera/strategy_controller/existing in GLOB.mob_list)
			controller = existing
			break

	if(!controller)
		to_chat(usr, span_warning("No strategy_controller found - run Debug Spawn RTS Controller first."))
		return

	if(!length(controller.worker_mobs))
		to_chat(usr, span_warning("Controller [REF(controller)] has no workers."))
		return

	var/obj/effect/building_node/mines/mine_node
	for(var/obj/effect/building_node/mines/existing in controller.constructed_building_nodes)
		mine_node = existing
		break

	if(!mine_node)
		to_chat(usr, span_warning("No constructed Mine found in [REF(controller)]'s constructed_building_nodes - place one with Debug Place RTS Mine + Assign Miner and wait for it to finish building first."))
		return

	var/datum/persistant_workorder/mine/ores/ore_job
	for(var/datum/persistant_workorder/mine/ores/existing in mine_node.persistant_nodes)
		ore_job = existing
		break

	if(!ore_job)
		to_chat(usr, span_warning("Mine [REF(mine_node)] has no 'Mine Ores' persistant_workorder - on_construction() may not have run yet."))
		return

	var/mob/living/worker = controller.worker_mobs[controller.worker_mobs.len]
	worker.controller_mind.assign_persistent_work(ore_job)

	to_chat(usr, span_notice("Bound worker [worker] ([REF(worker)]) to Mine [REF(mine_node)]'s 'Mine Ores' job. Watch it walk to a workspot and start mining; ore should accumulate in the node's materials_to_store, then get auto-hauled to the nearest Stockpile."))

// Read-only inspection verb - prints the current state of every
// strategy_controller's stockpile and every constructed building_node's
// materials_to_store/material_requests, so an admin can watch the mine ->
// haul -> stockpile loop's numbers change over time without needing to
// open the variables debug panel on multiple objects.
/client/proc/debug_rts_check_economy()
	set name = "Debug Check RTS Economy"
	set category = "Debug"
	set desc = "Prints stockpile contents and every constructed building_node's pending materials_to_store/material_requests, for all strategy_controllers."

	if(!check_rights(R_DEBUG))
		return

	var/found_any = FALSE
	for(var/mob/camera/strategy_controller/controller in GLOB.mob_list)
		found_any = TRUE
		to_chat(usr, span_notice("--- Controller [REF(controller)] ---"))
		if(controller.resource_stockpile)
			to_chat(usr, "Stockpile: [json_encode(controller.resource_stockpile.stored_materials)]")
		else
			to_chat(usr, "Stockpile: none yet (build a World Core first).")

		for(var/obj/effect/building_node/node in controller.constructed_building_nodes)
			to_chat(usr, "Node [node] ([REF(node)]): materials_to_store=[json_encode(node.materials_to_store)] material_requests=[json_encode(node.material_requests)]")

		for(var/mob/living/worker in controller.worker_mobs)
			var/datum/worker_mind/mind = worker.controller_mind
			if(!mind)
				continue
			to_chat(usr, "Worker [worker] ([REF(worker)]): current_task=[mind.current_task ? mind.current_task.name : "none"] assigned_work=[mind.assigned_work ? mind.assigned_work.name : "none"] stamina=[mind.current_stamina]/[mind.maximum_stamina]")

	if(!found_any)
		to_chat(usr, span_warning("No strategy_controllers found."))

// Phase 5 verification aids for the Vanderlin RTS port (not part of the
// Vanderlin source - written for this port only).
//
// Thin wrappers around the existing _debug_place_rts_building() helper
// (Phase 2, above), one per profession building added this phase, so each
// can be smoke-tested the same way Phase 2/3 already verified Core/
// Stockpile/Mines: run Debug Spawn RTS Controller once, then any of these to
// queue that profession's building at your turf. Once built, right-click the
// building_node with no worker panel open to browse its gear storage
// (ui/gear_menu.dm), or select a worker first and right-click to assign it
// to one of the building's persistent jobs (same flow as
// debug_assign_worker_to_mine, just reachable from the real UI now).
/client/proc/debug_place_rts_farm()
	set name = "Debug Place RTS Farm"
	set category = "Debug"
	set desc = "Queues a Farm building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/farm, "Farm")

/client/proc/debug_place_rts_lumber_yard()
	set name = "Debug Place RTS Lumber Yard"
	set category = "Debug"
	set desc = "Queues a Lumber Yard building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/lumber_yard, "Lumber Yard")

/client/proc/debug_place_rts_tannery()
	set name = "Debug Place RTS Tannery"
	set category = "Debug"
	set desc = "Queues a Tannery building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/tannery, "Tannery")

/client/proc/debug_place_rts_tailor()
	set name = "Debug Place RTS Tailor Shop"
	set category = "Debug"
	set desc = "Queues a Tailor Shop building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/tailor, "Tailor Shop")

/client/proc/debug_place_rts_blacksmith()
	set name = "Debug Place RTS Blacksmith"
	set category = "Debug"
	set desc = "Queues a Blacksmith building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/blacksmith, "Blacksmith")

/client/proc/debug_place_rts_kitchen()
	set name = "Debug Place RTS Kitchen"
	set category = "Debug"
	set desc = "Queues a Kitchen building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/kitchen, "Kitchen")

/client/proc/debug_place_rts_bar()
	set name = "Debug Place RTS Bar"
	set category = "Debug"
	set desc = "Queues a Bar building_datum at your turf on the last-spawned (or any) strategy_controller."

	if(!check_rights(R_DEBUG))
		return
	_debug_place_rts_building(/datum/building_datum/bar, "Bar")
