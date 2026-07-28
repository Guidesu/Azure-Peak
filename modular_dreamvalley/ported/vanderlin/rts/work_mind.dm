// Ported from Vanderlin (OpenKeep): code/datums/rts/work_mind.dm
//
// JUDGMENT CALL (Phase 1 of the RTS port, see plan item #6): this file is
// PORTED TRIMMED, not full-with-stubs. The full source file is tightly
// coupled to systems from later phases:
//   - worker_gear (Phase 5): add_gear/remove_gear/update_gear_overlay/
//     get_icon_file/get_total_walkspeed_modifier and all their overlay
//     rendering. These don't just reference a type in a var declaration
//     (which a stub could satisfy) - they call procs (get_walkspeed_modifier,
//     build_worn_icon prep, etc) on /datum/worker_gear instances, which would
//     require stubbing out a working gear system, not a marker type.
//   - attacking_strategy (Phase 6): attack_mode var and
//     apply_attack_strategy()/suppress_attack(), plus check_worktree()'s
//     attack-branch.
//   - patrol work order + persistant/patrol (Phase 6/3): patrol_points,
//     patrol_setup_active, patrol_visual_images and their signal sends.
//   - idle_tendancies (present in source, but perform_idle()'s only
//     concrete implementation dispatches to Phase 3 work orders
//     (wander_to_building, socialize_with, play_music, mourn_dead,
//     nappy_time) that don't exist yet) - trimmed to a no-op start_idle()
//     for this phase; the idle_tendancies datum itself is not ported since
//     nothing else in Phase 1 needs it.
// Kept: the worker_mind identity/lifecycle (New/Destroy), the core
// check_worktree() tick loop with movement/pathfinding/current_task
// handling (minus the attack-mode branch), set_current_task/finish_work/
// stop_working/set_movement_target/set_paused_state/check_paused_state/
// pause_task_for, and enhanced_pathfinding. This is exactly what Phase 1's
// goal needs: "a debug worker mob exists and ticks without errors."
// worker_gear is still declared as a plain list of slot-name keys (matching
// WORKER_SLOT_* from _defines.dm) since work_orders/_base_task.dm's
// get_work_speed_modifier()/get_stamina_cost_modifier() iterate it and call
// has_gear_in_slot()/get_gear_in_slot() - both kept here as simple list
// lookups that safely return FALSE/null until Phase 5 populates them.
//
// PHASE 6 UN-DEFER (combat/patrol, see attacking_strategy.dm and
// work_orders/orders+persistant/patrol.dm): attack_mode is now a real
// /datum/worker_attack_strategy var, patrol_points/patrol_setup_active/
// patrol_visual_images are now real vars matching upstream's shape exactly,
// and check_worktree()'s attack-mode branch (short-circuits everything else
// when a target is being chased/engaged - "combat pre-empts work") is
// restored verbatim from the source. apply_attack_strategy()/suppress_attack()/
// stop_chase() are also restored - see below for each.
//
// A later phase restoring gear/attack/patrol should re-diff this file
// against the Vanderlin source rather than assume this trimmed version is
// otherwise complete.
//
// PHASE 3 ADDITION (un-defer persistent-job dispatch, see plan item #3's
// "Un-deferring for Phase 3" section): check_worktree()'s
// `if(assigned_work && !current_task && !paused_task)` branch below was
// already present verbatim since Phase 1 (it only ever referenced the
// /datum/persistant_workorder type in a var declaration, which Phase 1's
// persistant/_base.dm already provided) - it simply had nothing to dispatch
// to yet, since no persistant_workorder subtype existed until this phase's
// persistant/mines.dm. It required no code changes to "activate": once a
// worker_mind's assigned_work var is non-null (see the new
// assign_persistent_work() proc below), this loop keeps re-running
// apply_to_worker() every time the worker goes idle, exactly matching
// upstream's behavior.
//
// What DID need porting is the assignment entrypoint itself. Source's
// controller_mob.dm ClickOn() right-click branch (see that file's header
// comment) sets worker.controller_mind.assigned_work directly inline,
// gated on displayed_mob_ui (Phase 4 UI, not ported) being open. Since no UI
// exists yet, that inline logic is factored out here into a reusable proc
// any caller can use (the debug verb below, and later Phase 4's UI once it
// lands) - this mirrors the source's actual assignment semantics (stop the
// old in-flight task if switching to a different persistent job, then
// immediately apply_to_worker() so the worker doesn't sit idle until its
// next process() tick) without requiring displayed_mob_ui to exist.
/mob/living/var/datum/worker_mind/controller_mind

/mob/living/proc/made_into_controller_mob()
	QDEL_NULL(ai_controller)

/datum/worker_mind
	var/mob/camera/strategy_controller/master
	var/mob/living/worker
	var/worker_name
	///10 is default so 20 is double etc
	var/work_speed = 10
	///our worker walk speed
	var/walkspeed = 5
	///100 is default
	var/maximum_stamina = 100
	var/current_stamina = 100

	var/datum/work_order/current_task
	var/turf/movement_target

	// PHASE 5 UN-DEFER: this used to be a plain list of slot-name keys (no
	// values), matching upstream's Phase-1-trimmed stand-in shape. Now that
	// worker_gear.dm (Phase 5) provides the real /datum/worker_gear type,
	// this is restored to upstream's actual shape - an associative
	// slot -> /datum/worker_gear map, each slot pre-seeded null (matching
	// upstream's add_gear()'s `worker_gear.Find(slot)` check, which requires
	// the slot key to already exist in the list, empty or not).
	var/list/worker_gear = list(
		(WORKER_SLOT_HEAD) = null,
		(WORKER_SLOT_PANTS) = null,
		(WORKER_SLOT_SHIRT) = null,
		(WORKER_SLOT_SHOES) = null,
		(WORKER_SLOT_HANDS) = null,
	)

	var/paused = FALSE

	var/list/current_path = list()
	var/next_recalc = 0

	var/datum/persistant_workorder/assigned_work

	var/paused_until = 0
	var/atom/move_back_after
	var/work_pause = FALSE
	var/datum/work_order/paused_task

	// PHASE 6 UN-DEFER: real vars now - see this file's header comment.
	// attack_mode is null until apply_attack_strategy() is called (either by
	// a player toggling attack-mode, or call_for_backup() rallying an ally -
	// see attacking_strategy.dm). patrol_points/patrol_setup_active/
	// patrol_visual_images match upstream's shape exactly; controller_mob.dm's
	// new patrol-setup click-mode populates patrol_points via a right-click
	// sequence while patrol_setup_active is TRUE.
	var/datum/worker_attack_strategy/attack_mode

	var/list/turf/patrol_points = list()
	var/patrol_setup_active = FALSE
	var/list/image/patrol_visual_images = list()

	/// PHASE 4 (UI): this worker's own per-worker HUD panel (ui/controller_ui.dm),
	/// created once at worker-mind creation exactly like the source's stats
	/// var, so any controller can right-click this worker and show/reuse the
	/// same panel instance rather than building a fresh one per click.
	var/atom/movable/screen/controller_ui/controller_ui/stats

/datum/worker_mind/New(mob/living/new_worker, mob/camera/strategy_controller/new_master)
	. = ..()
	master = new_master
	worker = new_worker

	worker.pass_flags |= PASSMOB
	worker.density = FALSE

	worker_name = pick( world.file2list("strings/rt/names/dwarf/dwarmm.txt") )
	worker.real_name = "[worker_name] the [worker.real_name]"
	worker.name = worker.real_name

	master.add_new_worker(worker)
	worker.made_into_controller_mob()
	stats = new /atom/movable/screen/controller_ui/controller_ui(null, null, worker, src)
	START_PROCESSING(SSstrategy_master, src)

/datum/worker_mind/Destroy(force)
	STOP_PROCESSING(SSstrategy_master, src)
	QDEL_NULL(stats)
	// PHASE 5 UN-DEFER: worker_gear is now a real slot->gear map (see this
	// file's var block and add_gear()/remove_gear_from_slot() above) - clean
	// up any equipped /datum/worker_gear instances before clearing the list,
	// matching upstream's Destroy().
	for(var/slot in worker_gear)
		var/datum/worker_gear/gear = worker_gear[slot]
		if(gear)
			qdel(gear)
	worker_gear = null
	worker = null
	master = null
	assigned_work = null
	movement_target = null
	move_back_after = null
	if(paused_task)
		QDEL_NULL(paused_task)
	if(current_task)
		QDEL_NULL(current_task)
	// PHASE 6 UN-DEFER: clean up attack_mode/patrol_points/patrol_visual_images -
	// direct port of the source's equivalent Destroy() cleanup lines.
	if(attack_mode)
		QDEL_NULL(attack_mode)
	patrol_points = null
	QDEL_LIST(patrol_visual_images)
	return ..()

// PHASE 5 UN-DEFER: ported from Vanderlin (OpenKeep): code/datums/rts/work_mind.dm.
// These five procs (add_gear/remove_gear_from_slot/remove_gear/get_gear_in_slot/
// get_item_in_slot/has_gear_in_slot) replace the Phase 1 always-FALSE/null
// stubs now that worker_gear is a real slot->gear map (see this file's var
// block above) and /datum/worker_gear (worker_gear.dm) is a real type.
//
// ADAPTATION (scope trim, not a compatibility fix): upstream's add_gear()
// also calls update_gear_overlay(slot) to render the item as a worn sprite
// on the worker mob (build_worn_icon()/getmoboverlay()/experimental_inhand
// in-hand rendering, get_icon_file() switching on
// icons/roguetown/clothing/onmob/*.dmi). That whole rendering pipeline is a
// large, cosmetic-only subsystem this port has not verified against this
// repo's actual item/clothing sprite API (righthand_file, build_worn_icon(),
// etc), and per this porting plan's explicitly deferred scope ("Art assets...
// port opportunistically per-phase if trivial, otherwise placeholder/
// reskinned icons are acceptable... not a blocker for any phase's functional
// verification"), it is NOT ported here. update_gear_overlay()/
// remove_gear_overlay()/update_all_gear_overlays()/get_icon_file()/
// get_slot_layer() are all omitted; add_gear()/remove_gear_from_slot()/
// remove_gear() below skip the overlay calls entirely. Gear is still fully
// functional mechanically - task_bonuses, stamina/walkspeed modifiers, and
// storage/retrieval via the gear UI (ui/gear_menu.dm, ui/inventory_menu.dm)
// all work identically to upstream - workers just don't visually change
// appearance when equipped. A future art pass can restore the overlay calls
// once this repo's actual clothing-sprite API is confirmed compatible.
/datum/worker_mind/proc/add_gear(obj/item/item, slot, datum/worker_gear/gear_type = /datum/worker_gear)
	if(!slot || !(slot in worker_gear))
		return FALSE

	// Remove existing gear from slot if any
	if(worker_gear[slot])
		remove_gear_from_slot(slot)

	// Create worker gear datum
	var/datum/worker_gear/new_gear = new gear_type(item, slot, src)
	worker_gear[slot] = new_gear
	item.forceMove(worker)

	// Signal gear change
	SEND_SIGNAL(src, COMSIG_WORKER_GEAR_CHANGED, slot, null, new_gear)
	return TRUE

/datum/worker_mind/proc/remove_gear_from_slot(slot)
	if(!worker_gear[slot])
		return FALSE

	var/datum/worker_gear/gear = worker_gear[slot]
	worker_gear[slot] = null
	if(gear.item)
		gear.item.forceMove(get_turf(worker))
	qdel(gear)

	// Signal gear removal
	SEND_SIGNAL(src, COMSIG_WORKER_GEAR_CHANGED, slot, gear, null)
	return TRUE

/datum/worker_mind/proc/remove_gear(obj/item/item)
	for(var/slot in worker_gear)
		var/datum/worker_gear/gear = worker_gear[slot]
		if(gear && gear.item == item)
			remove_gear_from_slot(slot)
			return TRUE
	return FALSE

/datum/worker_mind/proc/get_gear_in_slot(slot)
	return worker_gear[slot]

/datum/worker_mind/proc/get_item_in_slot(slot)
	var/datum/worker_gear/gear = worker_gear[slot]
	return gear?.item

/datum/worker_mind/proc/has_gear_in_slot(slot)
	return worker_gear[slot] != null

/datum/worker_mind/proc/get_total_walkspeed_modifier()
	var/total_modifier = 0
	for(var/slot in worker_gear)
		var/datum/worker_gear/gear = worker_gear[slot]
		if(gear)
			total_modifier += gear.get_walkspeed_modifier()
	return total_modifier

/datum/worker_mind/proc/get_effective_walkspeed()
	return walkspeed + get_total_walkspeed_modifier()

/datum/worker_mind/proc/head_to_target()
	if(!movement_target)
		return

	if(next_recalc < world.time)
		enhanced_pathfinding()
		next_recalc = world.time + 2 SECONDS
	if(!length(current_path) && !worker.CanReach(movement_target))
		enhanced_pathfinding()
		if(!length(current_path))
			current_task.stop_work("no path")
	if(length(current_path) >= 3)
		walk_to(worker, current_path[3],0, get_effective_walkspeed())
		current_path -= current_path[3]
		current_path -= current_path[2]
		current_path -= current_path[1]
	else
		walk_to(worker, current_path[length(current_path)],0, get_effective_walkspeed())
		current_path = list()

/datum/worker_mind/proc/start_task()
	current_task.start_working(worker)

/datum/worker_mind/process()
	if(worker.stat >= DEAD)
		return
	check_worktree()

/datum/worker_mind/proc/start_idle()
	// TRIMMED: source dispatches to /datum/idle_tendancies/basic, which
	// assigns Phase 3 work orders (wander_to_building, nappy_time,
	// socialize_with, play_music, mourn_dead) that don't exist in Phase 1.
	// No-op for now; a debug worker with nothing assigned simply stands
	// still when idle, which is fine for this phase's verification goal.
	SEND_SIGNAL(src, COMSIG_WORKER_IDLE_START)

/datum/worker_mind/proc/set_current_task(datum/work_order/order, ...)
	var/list/arg_list = list(worker) + args
	var/old_task = current_task
	current_task = new order(arglist(arg_list))
	SEND_SIGNAL(src, COMSIG_WORKER_TASK_STARTED, current_task, old_task)

// PHASE 3 ADDITION - see this file's header comment. Ported from the inline
// logic in Vanderlin's controller_mob.dm ClickOn() right-click-on-a-
// building-node branch, factored into a proc so it doesn't need
// displayed_mob_ui (Phase 4 UI) to exist.
/datum/worker_mind/proc/assign_persistent_work(datum/persistant_workorder/new_work)
	var/datum/persistant_workorder/old_workorder = assigned_work
	assigned_work = new_work
	if(current_task && (old_workorder != new_work))
		current_task.stop_work("reassigned")
	if(assigned_work)
		assigned_work.apply_to_worker(worker)

/datum/worker_mind/proc/finish_work(success, stamina_cost)
	var/old_stamina = current_stamina
	var/finished_task = current_task
	current_stamina = max(0, current_stamina - stamina_cost)

	SEND_SIGNAL(src, COMSIG_WORKER_TASK_FINISHED, finished_task, success, stamina_cost)
	SEND_SIGNAL(src, COMSIG_WORKER_STAMINA_CHANGED, old_stamina, current_stamina, "task completion")

	current_task = null
	movement_target = null
	set_paused_state(FALSE, "work finished")
	walk(worker, 0)

/datum/worker_mind/proc/stop_working()
	var/stopped_task = current_task
	current_task = null
	movement_target = null
	set_paused_state(FALSE, "work stopped")

	if(stopped_task)
		SEND_SIGNAL(src, COMSIG_WORKER_TASK_FAILED, stopped_task, "work stopped")

	walk(worker, 0)

/datum/worker_mind/proc/set_movement_target(atom/target)
	var/old_target = movement_target
	walk(worker, 0)
	movement_target = target
	SEND_SIGNAL(src, COMSIG_WORKER_MOVEMENT_SET, old_target, target)

/datum/worker_mind/proc/set_paused_state(new_state, reason = "unknown")
	if(paused != new_state)
		var/old_state = paused
		paused = new_state
		SEND_SIGNAL(src, COMSIG_WORKER_PAUSED_CHANGED, old_state, new_state, reason)

/datum/worker_mind/proc/update_stat_panel()
	// PHASE 4 UN-DEFER: stats now exists (see this file's var block above) -
	// direct port of the source's update_stat_panel().
	stats?.update_text()

/datum/worker_mind/proc/check_paused_state()
	if(work_pause && (world.time > paused_until) && !current_task)
		set_movement_target(move_back_after)
		work_pause = FALSE
		current_task = paused_task
		paused_task = null
		return TRUE
	return FALSE

/datum/worker_mind/proc/check_worktree()
	if(paused)
		return

	// PHASE 6 UN-DEFER: combat pre-empts everything else. Direct port of the
	// source's attack-mode branch - if attack_mode is set and already has a
	// target, keep chasing/attacking it (can_attack_target() handles the
	// actual swing/shot once in range); if it has no target yet, try to
	// find one via find_targets() and immediately chase whatever it picks.
	// Either way this return's out before any of the normal work-tree checks
	// below run, exactly matching upstream's "attack pre-empts work"
	// behavior.
	if(attack_mode)
		if(attack_mode.current_target)
			if(!attack_mode.can_attack_target())
				walk_to(worker, attack_mode.current_target, 1, get_effective_walkspeed())
			return
		else if(attack_mode.find_targets())
			if(!attack_mode.can_attack_target())
				walk_to(worker, attack_mode.current_target, 1, get_effective_walkspeed())
				return

	if(check_paused_state())
		return

	if(movement_target && (!worker.CanReach(movement_target)))
		head_to_target()
		return
	if(current_task && world.time > paused_until)
		start_task()
		return
	if(current_stamina <= 0)
		// TRIMMED: source calls try_restore_stamina(), which assigns Phase 3
		// work orders (nappy_time, go_try_eat) that don't exist yet. A
		// debug worker simply stalls at 0 stamina in this phase.
		return
	if(assigned_work && !current_task && !paused_task)
		assigned_work.apply_to_worker(worker)
		return
	if(master.should_stop_idle(src))
		return
	start_idle()

/datum/worker_mind/proc/pause_task_for(duration = 60 SECONDS, atom/after_pause_target)
	move_back_after = after_pause_target
	work_pause = TRUE
	paused_task = current_task
	current_task = null
	paused_until = world.time + duration
	set_paused_state(TRUE, "task paused for [duration/10] seconds")

/datum/worker_mind/proc/enhanced_pathfinding()
	if(!movement_target)
		return

	current_path = get_path_to(worker, get_turf(movement_target),
		TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 32 + 1, 250, 1)
	SEND_SIGNAL(src, COMSIG_AI_PATH_GENERATED, current_path)

// PHASE 6 UN-DEFER: ported from Vanderlin (OpenKeep): code/datums/rts/work_mind.dm.
// stop_chase() halts the worker's movement (called by
// worker_attack_strategy/lose_target() when a chase times out or the target
// dies/vanishes). suppress_attack() fully clears the current attack (used by
// callers that need a worker to stand down immediately, e.g. future UI/
// admin tools) - drops the target, stops movement, and signals
// COMSIG_WORKER_ATTACK_END. apply_attack_strategy() is the entry point that
// gives a worker an attack_mode in the first place - either from a player
// toggling attack-mode on this worker (see controller_mob.dm/UI, if wired)
// or from worker_attack_strategy/call_for_backup() rallying a nearby ally.
/datum/worker_mind/proc/stop_chase()
	walk(worker, 0)

/datum/worker_mind/proc/suppress_attack()
	var/old_target = attack_mode?.current_target
	attack_mode?.lose_target()
	stop_chase()
	SEND_SIGNAL(src, COMSIG_WORKER_ATTACK_END, old_target, "suppressed")

/datum/worker_mind/proc/apply_attack_strategy(datum/worker_attack_strategy/attack_path = /datum/worker_attack_strategy)
	var/datum/worker_attack_strategy/new_attack = new attack_path(worker)
	attack_mode = new_attack
	SEND_SIGNAL(src, COMSIG_WORKER_ATTACK_START, attack_mode.current_target)
