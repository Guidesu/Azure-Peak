// Ported from Vanderlin (OpenKeep): code/datums/rts/controller_mob.dm
//
// JUDGMENT CALL (Phase 1 of the RTS port, see plan item #5): this file is
// PORTED TRIMMED, not full-with-stubs, for the same reason as work_mind.dm
// (see that file's header comment). The full source file's vars/procs
// reach into:
//   - UI (Phase 4): displayed_mob_ui/displayed_base_ui/gear_ui/inventory_ui/
//     building_icon screen-object vars and open/close/update procs on them.
//   - break-turf / move-structure / patrol click-modes (Phase 3/6):
//     ClickOn's break_turf_mode/move_structure_mode/patrol branches, plus
//     all their handler procs, reference /datum/work_order/move_structure
//     and /obj/pathfind_guy - neither exists yet (break_turf itself was
//     ported in Phase 2, see work_orders/orders/break_turf.dm, but the
//     admin-facing "click a turf to queue a break order" UX built on top of
//     it in ClickOn is still deferred - Phase 2's building pipeline queues
//     break_turf work orders itself via building_datum.try_work_on(), which
//     doesn't need any of this).
//   - the Overlord antagonist (Phase 7): linked_overlord var.
// Kept: the camera-mob appearance/base vars, worker_mobs/dead_workers/
// resource_stockpile/in_progress_workorders bookkeeping, add_new_worker,
// create_new_worker_mob (spawns a debug worker), process()'s
// in_progress_workorders dispatch loop, and should_stop_idle() trimmed to
// match. Login/Logout/onTransitZ/update_z from the source were NOT ported:
// they depend on /mob/camera vars (registered_z, SSmobs.camera_players_by_zlevel)
// that don't exist on this repo's /mob/camera base (code/modules/mob/camera/camera.dm)
// and are a z-level camera-tracking optimization, not required for this
// port's goals.
//
// PHASE 2 ADDITION (building pipeline un-defer, see plan item #6's "Un-
// deferring controller_mob.dm/work_mind.dm" section): held_build,
// building_requests, constructed_building_nodes, has_core,
// try_setup_build()/queue_building_build(), process()'s building_requests
// dispatch loop (assigns idle workers to building_datum.try_work_on()), and
// ClickOn()'s held_build left-click-to-place branch are now real, ported
// from the source almost verbatim (see inline notes for the two
// adaptations: no COMSIG_MOB_MOUSE_ENTERED cursor-follow, and the
// constructed_building_nodes material_requests/materials_to_store dispatch
// block in process() stays commented out since haul_materials/
// store_materials are Phase 3, not Phase 2). The right-click-to-select-
// worker branch is still a no-op (Phase 4 UI, displayed_mob_ui doesn't exist
// yet).
//
// PHASE 3 ADDITION (economy-loop un-defer, see plan item #3's "Un-deferring
// for Phase 3" section): process()'s constructed_building_nodes dispatch
// block is now real, ported from the source almost verbatim (see that
// block's inline comment for the one behavioral note: the source's
// building_icon?.update(src) call at the top of process() is Phase 4 UI and
// stays dropped, same as before). This is the core "economy" loop the whole
// plan builds toward - every tick, for every constructed building_node with
// pending materials_to_store, an idle worker gets assigned
// /datum/work_order/store_materials; for every node with pending
// material_requests the stockpile can at least partially satisfy, an idle
// worker gets assigned /datum/work_order/haul_materials. Combined with
// work_mind.dm's assigned_work dispatch (a worker manually bound to a Mine's
// persistent mining job via the new debug verb keeps re-mining every time it
// idles), this closes the full mine -> produce -> auto-haul -> stockpile
// loop.
//
// PHASE 4 ADDITION (UI un-defer, see the RTS Phase 4 plan's "Wiring into
// controller_mob.dm/work_mind.dm" section): displayed_base_ui/
// displayed_mob_ui/building_icon are now real vars, created in Initialize()
// (base_ui/building_icon) or lazily per-worker (each worker_mind's own
// .stats panel, see work_mind.dm). Login() now shows the base HUD, matching
// the source. ClickOn()'s right-click branch now actually opens a worker's
// panel (replacing the old no-op) and, if a building_node is right-clicked
// while a worker panel is open, offers that worker a job pick via the
// building_node's existing select_workorder()/override_click() (both were
// already ported in Phase 3's building_node/building_nodes.dm, just unused
// until now) - this is the same assign_persistent_work() plumbing the debug
// verb has used since Phase 3, just reachable from the real UI now instead
// of only from debug_assign_worker_to_mine().
//
// Also un-deferred: a trimmed break_turf_mode click-mode (toggled by
// ui/non_mob_controller.dm's destroy button) that queues a real
// /datum/work_order/break_turf via /datum/queued_workorder - this exists
// because the underlying work order and dispatch loop (process()'s
// in_progress_workorders block) were already fully functional since Phase
// 2/3, so gating it behind a button is a straightforward un-deferral, unlike
// move_structure_mode/patrol (both Phase 6, no backing work order/persistent
// job exists in this port yet - see ui/non_mob_controller.dm's header
// comment for the full breakdown of what's functional vs placeholder in the
// button row).
//
// PHASE 6 UN-DEFER: find_active_patrol_setup_mob()/handle_patrol_setup_click()/
// create_patrol_order()/update_mob_patrol_visuals()/clear_mob_patrol_visuals()/
// render_patrol_path()/render_patrol_turf() are now real, ported from the
// source almost verbatim (see each proc below). ClickOn() now checks
// find_active_patrol_setup_mob() first, before break_turf_mode, exactly
// matching the source's ordering.
//
// STILL NOT un-deferred: move_structure_mode + handle_move_structure_click()/
// is_structure_moveable()/is_valid_move_destination()/create_move_order() (no
// backing /datum/work_order/move_structure exists in this port - confirmed
// by grep, not part of any phase in the approved plan), and linked_overlord
// (Phase 7, cut entirely per the plan).
//
// A later phase restoring move_structure_mode should re-diff this file
// against the Vanderlin source rather than assume this version is otherwise
// complete.
/mob/camera/strategy_controller
	name = "Strategy Controller"
	real_name = "Strategy Controller"
	desc = "The overmind. It controls the kobolds."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "yalp_elor"
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
	see_invisible = SEE_INVISIBLE_LIVING
	// NOTE: source sets uses_intents = FALSE here (a var on Vanderlin's own
	// combat-intent system). This repo has no such var on /mob - dropped.
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	pass_flags = PASSCLOSEDTURF | PASSMOB | PASSTABLE
	next_move_modifier = 0

	var/list/worker_mobs = list()
	var/list/dead_workers = list()

	var/datum/stockpile/resource_stockpile

	var/list/in_progress_workorders = list()

	/// PHASE 2: pending /datum/building_datum instances a player has started
	/// placing (ghost shown) but not yet finished construction on.
	var/list/building_requests = list()

	var/list/constructed_building_nodes = list()

	/// PHASE 2: the building_datum currently being placed (ghost following
	/// clicks), if any. Mirrors the source's held_build - see
	/// building_datums/_base_datum.dm's setup_building_ghost()/clean_up().
	var/datum/building_datum/held_build

	/// PHASE 2: set by building_datum/core/construct_building() - only one
	/// World Core may ever be built per controller.
	var/has_core = FALSE

	var/worker_type = /mob/living/carbon/simple_animal/hostile/retaliate/rogue/fae/sprite

	/// PHASE 4 (UI): the per-worker panel currently displayed, if any (see
	/// ui/controller_ui.dm). Unlike the source, this port doesn't overwrite a
	/// shared instance - each worker_mind owns its own .stats panel
	/// (work_mind.dm) and this var just tracks which one (if any) is
	/// currently shown to this controller's client.
	var/atom/movable/screen/controller_ui/controller_ui/displayed_mob_ui

	/// PHASE 4 (UI): the always-on base/world overview HUD (ui/non_mob_controller.dm).
	var/atom/movable/screen/base_ui/controller_ui/displayed_base_ui

	/// PHASE 4 (UI): the purchasable-building grid (ui/building_menu.dm).
	var/atom/movable/screen/building_backdrop/building_icon

	/// PHASE 5 (UI): the gear-storage browser for a right-clicked
	/// building_node (ui/gear_menu.dm) and the equipped-gear panel for the
	/// currently displayed worker (ui/inventory_menu.dm). Both are lazily
	/// created on first open, matching building_icon's pattern above.
	var/atom/movable/screen/gear_menu_backdrop/gear_ui
	var/atom/movable/screen/worker_inventory_backdrop/inventory_ui

	/// PHASE 4 (UI): toggled by ui/non_mob_controller.dm's destroy button -
	/// see this file's header comment for what's functional vs placeholder.
	var/break_turf_mode = FALSE
	var/turf/break_start_turf = null

	/// PHASE 6 UN-DEFER: tracks every worker whose patrol-route markers are
	/// currently drawn into this controller's client.images, mirroring the
	/// source's identical bookkeeping var.
	var/list/mob/mobs_with_patrol_visuals = list()

/mob/camera/strategy_controller/Initialize()
	. = ..()
	displayed_base_ui = new(null, hud_used)
	building_icon = new(null, hud_used)
	START_PROCESSING(SSstrategy_master, src)

/mob/camera/strategy_controller/proc/close_building_ui()
	building_icon.close_uis(src)

// PHASE 5 UN-DEFER: ported from Vanderlin (OpenKeep): code/datums/rts/controller_mob.dm.
// Un-trims building_node/building_nodes.dm's handle_right_click() (Phase 2/3
// stub) now that ui/gear_menu.dm is a real type - see that file's header
// comment.
/mob/camera/strategy_controller/proc/open_gear_ui(obj/effect/building_node/node)
	if(!gear_ui)
		gear_ui = new(null, hud_used)
	gear_ui.open_ui(src, node)

/mob/camera/strategy_controller/proc/close_gear_ui()
	if(gear_ui)
		gear_ui.close_uis(src)

// PHASE 5 UN-DEFER: opens/refreshes the equipped-gear panel for a worker
// alongside its existing stats panel - see ClickOn()'s right-click-on-a-
// worker branch below, which now calls this (Phase 4 left it a no-op per
// this file's header comment: "isliving(A)... minus gear_ui/inventory_ui").
/mob/camera/strategy_controller/proc/open_inventory_ui(datum/worker_mind/worker)
	if(!inventory_ui)
		inventory_ui = new(null, hud_used)
	inventory_ui.open_ui(src, worker)

/mob/camera/strategy_controller/proc/close_inventory_ui()
	if(inventory_ui)
		inventory_ui.close_uis(src)

/mob/camera/strategy_controller/proc/add_assignments(list/assignments)
	return

/mob/camera/strategy_controller/proc/add_new_worker(mob/living/worker)
	worker_mobs |= worker

/mob/camera/strategy_controller/proc/create_new_worker_mob(atom/spawn_loc)
	var/turf/turf = get_turf(spawn_loc)
	var/mob/living/new_mob = new worker_type(turf)
	new_mob.controller_mind = new(new_mob, src)
	new_mob.faction |= FACTION_UNDEAD
	return new_mob

/// PHASE 2: starts placing a new building ghost of the given building_datum
/// type. Mirrors the source 1:1 - instantiate without a turf (so New()
/// doesn't try to build immediately), then ask it to set up its ghost.
/mob/camera/strategy_controller/proc/try_setup_build(datum/building_datum/building)
	if(held_build)
		held_build.clean_up(success = FALSE)

	var/datum/building_datum/build = new building(src)
	build.setup_building_ghost()

/// PHASE 2: places a building directly at source_turf, bypassing the
/// ghost-follow flow entirely - used by the debug verb (and, later, a menu
/// that already knows exactly where the player clicked).
/mob/camera/strategy_controller/proc/queue_building_build(datum/building_datum/building, turf/source_turf)
	new building(src, source_turf)

/mob/camera/strategy_controller/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)

	// PHASE 6 UN-DEFER: patrol-setup click-mode - checked FIRST, exactly
	// matching the source's ordering (patrol_setup_active pre-empts
	// break_turf_mode too, since both mutually exclude each other from the
	// button side - see ui/buttons/mob_buttons.dm's patrol/attack Click()).
	var/mob/living/patrol_mob = find_active_patrol_setup_mob()
	if(patrol_mob)
		handle_patrol_setup_click(A, modifiers, patrol_mob)
		return

	// PHASE 4 UN-DEFER: break_turf_mode click-mode - see this file's header
	// comment for why this is functional while move_structure_mode is not.
	// Checked before held_build/right-click handling, mirroring the source's
	// ordering of its click-mode checks at the top of ClickOn().
	if(break_turf_mode)
		handle_break_turf_click(A, modifiers)
		return

	if(LAZYACCESS(modifiers, LEFT_CLICK) && get_turf(A))
		if(held_build)
			if(held_build.try_place_building(src, get_turf(A)))
				var/datum/building_datum/last_type = held_build.type
				held_build.clean_up(success = TRUE)
				if(LAZYACCESS(modifiers, SHIFT_CLICKED))
					try_setup_build(last_type)
			else
				building_requests -= held_build
				held_build.clean_up()
			return

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		// PHASE 4 UN-DEFER: right-clicking a building_node while a worker
		// panel is open offers that worker a job pick from the node's
		// persistant_nodes (radial menu via select_workorder(), both already
		// ported in Phase 3's building_node/building_nodes.dm) and binds it
		// via work_mind.dm's assign_persistent_work() - the same proc the
		// Phase 3 debug verb uses, just reachable from the real UI now.
		// Direct port of the source's equivalent branch, minus its
		// attack-strategy-specific inline logic (Phase 6, not ported).
		if(istype(A, /obj/effect/building_node) && displayed_mob_ui)
			var/obj/effect/building_node/node = A
			var/mob/living/worker_mob = displayed_mob_ui.worker_mob
			if(worker_mob?.controller_mind && !node.override_click(src))
				var/datum/persistant_workorder/chosen_workorder = node.select_workorder(src)
				if(chosen_workorder)
					worker_mob.controller_mind.assign_persistent_work(chosen_workorder)
			return

		// PHASE 5 ADDITION (not in upstream's ClickOn() - see
		// building_node/building_nodes.dm's handle_right_click()/Click()
		// header comment): upstream relies on /obj/effect/building_node's own
		// Click() override to open the gear UI (handle_right_click() ->
		// user.open_gear_ui(src)), reachable whenever ClickOn() falls through
		// to ..() without handling the click itself. This port's ClickOn()
		// fully handles every building_node right-click above (job-assignment
		// branch) whenever a worker panel is open, so Click() never gets a
		// chance to fire in that case - but if NO worker panel is currently
		// open (displayed_mob_ui null), the branch above is skipped entirely
		// and this used to fall through to bare ..() with no gear UI ever
		// opening. Added explicitly here so right-clicking a building_node
		// with nothing selected opens its gear storage (ui/gear_menu.dm),
		// matching this phase's task of making stored gear reachable via the
		// UI without requiring a worker to be selected first.
		if(istype(A, /obj/effect/building_node))
			var/obj/effect/building_node/node = A
			open_gear_ui(node)
			return

		// PHASE 4 UN-DEFER, PHASE 5 restores inventory_ui: right-clicking a
		// controlled worker opens/updates its per-worker panel
		// (ui/controller_ui.dm) plus its equipped-gear panel
		// (ui/inventory_menu.dm), closing any previously-displayed ones
		// first. Direct port of the source's equivalent branch.
		if(isliving(A))
			var/mob/living/living = A
			if(living.controller_mind)
				displayed_base_ui?.remove_ui(client)
				if(displayed_mob_ui)
					displayed_mob_ui.remove_ui(client)
					close_inventory_ui()
				displayed_mob_ui = living.controller_mind.stats
				displayed_mob_ui.add_ui(client)
				open_inventory_ui(living.controller_mind)
			return

	return ..()

/// PHASE 4 UN-DEFER: trimmed version of the source's
/// handle_break_turf_click() - only the single-turf case is ported (no
/// shift-click area selection), since this port has no equivalent bulk-order
/// UX need yet and the plan's Phase 4 goal is just "make the core loop
/// player-triggerable", not full click-mode parity. Right click cancels a
/// pending break order on the clicked turf.
/mob/camera/strategy_controller/proc/handle_break_turf_click(atom/A, list/modifiers)
	var/turf/T = get_turf(A)
	if(!T)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		cancel_break_order_single(T)
		return

	create_break_order_single(T)

/mob/camera/strategy_controller/proc/create_break_order_single(turf/T)
	if(!can_break_turf(T))
		to_chat(src, span_warning("Cannot break [T.name]."))
		return

	for(var/datum/queued_workorder/existing_order in in_progress_workorders)
		if(existing_order.work_path == /datum/work_order/break_turf && existing_order.arg_1 == T)
			to_chat(src, span_warning("Break order already exists for this turf."))
			return

	var/datum/queued_workorder/new_queued = new /datum/queued_workorder(/datum/work_order/break_turf, src, T)
	in_progress_workorders += new_queued

/mob/camera/strategy_controller/proc/cancel_break_order_single(turf/T)
	for(var/datum/queued_workorder/order in in_progress_workorders)
		if(order.work_path == /datum/work_order/break_turf && order.arg_1 == T)
			SEND_SIGNAL(T, COMSIG_CANCEL_TURF_BREAK)
			in_progress_workorders -= order
			qdel(order)
			return
	to_chat(src, span_warning("No break order found for this turf."))

/mob/camera/strategy_controller/proc/can_break_turf(turf/T)
	if(isclosedturf(T) && !istype(T, /turf/closed/indestructible/rock))
		return TRUE

	for(var/obj/structure/structure in T.contents)
		if(is_type_in_list(structure, GLOB.breakable_types))
			return TRUE

	return FALSE

// PHASE 6 UN-DEFER: ported from Vanderlin (OpenKeep): code/datums/rts/controller_mob.dm.
// Direct port of the source's patrol-setup click-mode: find_active_patrol_setup_mob()
// checks whether the currently displayed worker panel's worker has
// patrol_setup_active set (toggled by ui/buttons/mob_buttons.dm's patrol
// button), and handle_patrol_setup_click() records left-clicked turfs as
// patrol_points / finalizes the route into a real patrol job on right-click.
/mob/camera/strategy_controller/proc/find_active_patrol_setup_mob()
	if(displayed_mob_ui?.worker_mob?.controller_mind?.patrol_setup_active)
		return displayed_mob_ui.worker_mob
	return null

/mob/camera/strategy_controller/proc/handle_patrol_setup_click(atom/A, list/modifiers, mob/living/target_mob)
	var/turf/T = get_turf(A)
	if(!T)
		return

	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)

	if(right_click)
		if(length(target_mob.controller_mind.patrol_points) >= 2)
			create_patrol_order(target_mob, target_mob.controller_mind.patrol_points.Copy())
			to_chat(src, span_notice("Patrol created with [length(target_mob.controller_mind.patrol_points)] points for [target_mob.name]."))
		else
			to_chat(src, span_warning("Need at least 2 patrol points to create a patrol."))

		target_mob.controller_mind.patrol_setup_active = FALSE

		if(displayed_mob_ui && displayed_mob_ui.worker_mob == target_mob && displayed_mob_ui.patrol_button)
			displayed_mob_ui.patrol_button.patrol_mode = FALSE
			displayed_mob_ui.patrol_button.color = null
			displayed_mob_ui.patrol_button.highlighted = FALSE

		update_mob_patrol_visuals(target_mob)
		return

	if(!(T in target_mob.controller_mind.patrol_points))
		target_mob.controller_mind.patrol_points += T
		to_chat(src, span_notice("Added patrol point [length(target_mob.controller_mind.patrol_points)] for [target_mob.name] at [T.x], [T.y]. Right click to finish patrol setup."))
		update_mob_patrol_visuals(target_mob)

// PHASE 6 UN-DEFER: direct port. Builds the real /datum/persistant_workorder/patrol
// and binds it via assign_persistent_work() - the same plumbing every other
// persistent job in this port uses (work_mind.dm, Phase 3).
/mob/camera/strategy_controller/proc/create_patrol_order(mob/living/worker, list/turf/points)
	if(!worker.controller_mind)
		return

	var/datum/persistant_workorder/patrol/new_patrol = new(null, worker, points)
	worker.controller_mind.assign_persistent_work(new_patrol)

// PHASE 6 UN-DEFER: direct port, minus the source's temporary
// /obj/pathfind_guy helper mob (not part of any phase of this plan and not
// referenced anywhere else in this port) - the path-preview line between
// patrol points is computed with get_path_to() using the patrol points
// themselves as start/end via a plain turf-hop, which is sufficient for a
// visual preview and avoids introducing a new mob type for this alone.
/mob/camera/strategy_controller/proc/update_mob_patrol_visuals(mob/living/target_mob)
	clear_mob_patrol_visuals(target_mob)

	if(!target_mob.controller_mind.patrol_setup_active && !length(target_mob.controller_mind.patrol_points))
		return

	for(var/i in 1 to length(target_mob.controller_mind.patrol_points))
		var/turf/point = target_mob.controller_mind.patrol_points[i]
		var/image/point_img = image('icons/turf/debug.dmi', point, "patrol_point", ABOVE_LIGHTING_PLANE)
		point_img.plane = ABOVE_LIGHTING_PLANE
		point_img.color = target_mob.controller_mind.patrol_setup_active ? "#FFA500" : "#4CAF50" // Orange during setup, green when active
		target_mob.controller_mind.patrol_visual_images += point_img

		var/image/number_img = image('icons/turf/debug.dmi', point, "number_[i]", ABOVE_LIGHTING_PLANE + 0.1)
		number_img.plane = ABOVE_LIGHTING_PLANE + 0.1
		target_mob.controller_mind.patrol_visual_images += number_img

	if(length(target_mob.controller_mind.patrol_points) >= 2)
		for(var/i in 1 to length(target_mob.controller_mind.patrol_points))
			var/turf/current_point = target_mob.controller_mind.patrol_points[i]
			var/turf/next_point = target_mob.controller_mind.patrol_points[(i % length(target_mob.controller_mind.patrol_points)) + 1] // Loop back to start

			var/list/turf/path = get_path_to(current_point, next_point, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250, 1)
			if(length(path))
				target_mob.controller_mind.patrol_visual_images += render_patrol_path(path, target_mob.controller_mind.patrol_setup_active ? "#FFA500" : "#4CAF50")

	// Add to client view
	if(client)
		client.images += target_mob.controller_mind.patrol_visual_images

	// Track that this mob has visuals shown
	if(!(target_mob in mobs_with_patrol_visuals))
		mobs_with_patrol_visuals += target_mob

/mob/camera/strategy_controller/proc/clear_mob_patrol_visuals(mob/living/target_mob)
	if(!target_mob || !target_mob.controller_mind)
		return

	if(client)
		client.images -= target_mob.controller_mind.patrol_visual_images
	target_mob.controller_mind.patrol_visual_images = list()
	mobs_with_patrol_visuals -= target_mob

/mob/camera/strategy_controller/proc/render_patrol_path(list/turf/draw_list, color = "#4CAF50")
	if(!length(draw_list))
		return list()

	var/list/image/turf_images = list()
	// Render everything but the first and last
	for(var/i in 1 to (length(draw_list) - 1))
		var/turf/current_turf = draw_list[i]
		var/turf/next = draw_list[i + 1]
		turf_images += render_patrol_turf(current_turf, get_dir(current_turf, next), color)

	return turf_images

/mob/camera/strategy_controller/proc/render_patrol_turf(turf/draw, direction, color = "#4CAF50")
	var/image/arrow = image('icons/turf/debug.dmi', draw, "patrol_arrow", ABOVE_LIGHTING_PLANE, direction)
	arrow.plane = ABOVE_LIGHTING_PLANE
	arrow.color = color
	return arrow

/mob/camera/strategy_controller/process()
	// PHASE 4 UN-DEFER: refreshes the building-menu buttons' red/green
	// afford-gating every tick (see ui/building_menu.dm's
	// building_backdrop.update()). No-ops immediately if the menu isn't
	// currently open (empty build_buttons list).
	building_icon?.update(src)

	if(length(building_requests))
		for(var/mob/living/mob in worker_mobs)
			if(mob.stat >= DEAD)
				return
			if(!length(building_requests))
				return
			if(mob.controller_mind.current_task)
				continue
			if(mob.controller_mind.check_paused_state())
				continue

			for(var/datum/building_datum/building in building_requests)
				if(building.try_work_on(mob))
					return

	// PHASE 3: dispatch idle workers to haul a constructed building_node's
	// produced output to a stockpile (store_materials), or to fetch a
	// node's requested raw materials from a stockpile (haul_materials).
	// Direct port of the source's process() block - see this file's header
	// comment. ADAPTATION: source's outer building_icon?.update(src) call
	// (Phase 4 UI, a screen-object icon showing build progress) is dropped;
	// nothing else in this block references it.
	if(length(constructed_building_nodes))
		if(resource_stockpile)
			for(var/obj/effect/building_node/node in constructed_building_nodes)
				if(length(node.materials_to_store))
					for(var/mob/living/mob in worker_mobs)
						if(mob.stat >= DEAD)
							return
						if(mob.controller_mind.current_task)
							continue
						if(mob.controller_mind.check_paused_state())
							continue
						mob.controller_mind.set_current_task(/datum/work_order/store_materials, node, src)

				if(length(node.material_requests))
					var/passed = TRUE
					for(var/request in node.material_requests)
						if(!resource_stockpile.has_any_resources(node.material_requests[request]))
							passed = FALSE
					if(!passed)
						continue

					for(var/mob/living/mob in worker_mobs)
						if(mob.stat >= DEAD)
							return
						if(mob.controller_mind.current_task)
							continue
						if(mob.controller_mind.check_paused_state())
							continue
						mob.controller_mind.set_current_task(/datum/work_order/haul_materials, node, src)

	if(length(in_progress_workorders))
		for(var/mob/living/mob in worker_mobs)
			if(mob.stat >= DEAD)
				return
			if(!length(in_progress_workorders))
				return
			if(mob.controller_mind.current_task)
				continue
			if(mob.controller_mind.check_paused_state())
				continue

			for(var/datum/queued_workorder/workorder in in_progress_workorders)
				if(workorder.arg_1)
					if(!length(get_path_to(mob, workorder.arg_1, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250,1)))
						continue
				mob.controller_mind.set_current_task(workorder.work_path, workorder.arg_1, workorder.arg_2, workorder.arg_3, workorder.arg_4)
				in_progress_workorders -= workorder
				qdel(workorder)
				return

/mob/camera/strategy_controller/proc/should_stop_idle(datum/worker_mind/mind)
	if(length(in_progress_workorders))
		return TRUE
	if(length(building_requests))
		return TRUE
	// PHASE 3: keep a worker out of start_idle() if there's hauling work
	// available (a constructed node has produced output to store, or a
	// pending material request the stockpile can at least partly satisfy) -
	// direct port of the source's should_stop_idle(), which gained this
	// same check alongside process()'s haul/store dispatch loop above.
	if(length(constructed_building_nodes))
		if(resource_stockpile)
			for(var/obj/effect/building_node/node in constructed_building_nodes)
				if(length(node.materials_to_store))
					return TRUE
				if(length(node.material_requests))
					return TRUE
	return FALSE

// PHASE 4 UN-DEFER: shows the always-on base HUD (ui/non_mob_controller.dm)
// as soon as a client attaches to the controller mob. Direct port of the
// source's Login(), minus its update_z(T.z) call - that's part of the
// /mob/camera z-level camera-tracking optimization this port's base
// /mob/camera type doesn't have (see this file's Phase 1 header comment;
// this repo's /mob/camera has no registered_z/update_z/onTransitZ at all, so
// there is nothing to call here).
/mob/camera/strategy_controller/Login()
	. = ..()
	displayed_base_ui.add_ui(client)
	displayed_base_ui.add_ui_buttons(client)
