#define AI_CONTROLLER_PROCESSING_TILE_RANGE 15

/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// The tick cost of all active AI, calculated on fire.
	var/our_cost
	var/list/currentrun = list()
	///If TRUE, this subsystem only plans controllers within AI_CONTROLLER_PROCESSING_TILE_RANGE tiles of a client (via the spatial grid), cutting down on far-away/irrelevant mob processing. If FALSE, everything in the status bucket processes every fire like before.
	var/uses_cell_processing = TRUE

#define AI_STATUS_OFF_MAX_TIME 5 SECONDS

/datum/controller/subsystem/ai_controllers/Initialize(timeofday)
	setup_subtrees()
	return ..()

/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	if(length(GLOB.ai_subtrees))
		return
	for(var/subtree_type in subtypesof(/datum/ai_planning_subtree))
		var/datum/ai_planning_subtree/subtree = new subtree_type
		GLOB.ai_subtrees[subtree_type] = subtree

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(GLOB.ai_controllers_by_zlevel))
		GLOB.ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (GLOB.ai_controllers_by_zlevel.len < world.maxz)
		GLOB.ai_controllers_by_zlevel.len++
		GLOB.ai_controllers_by_zlevel[GLOB.ai_controllers_by_zlevel.len] = list()

///Builds the list of controllers we intend to plan for this run. If uses_cell_processing is off, this is just everything in our status bucket (old behavior).
///If it's on, we only grab controllers within AI_CONTROLLER_PROCESSING_TILE_RANGE tiles of a client, via the spatial grid, to avoid planning for mobs nobody is anywhere near.
/datum/controller/subsystem/ai_controllers/proc/build_currentrun()
	. = list()

	if(!uses_cell_processing || !SSspatial_grid)
		var/list/controller_list = GLOB.ai_controllers_by_status[planning_status]
		. = controller_list.Copy()
		return

	var/list/in_range_controllers = list()
	var/list/seen_cells = list()

	for(var/z_index in 1 to SSmobs.clients_by_zlevel.len)
		var/list/clients_here = SSmobs.clients_by_zlevel[z_index]
		if(!length(clients_here))
			continue

		for(var/mob/living/client_mob as anything in clients_here)
			var/turf/turf = get_turf(client_mob)
			if(!turf)
				continue
			for(var/datum/spatial_grid_cell/cell as anything in SSspatial_grid.get_cells_in_range(turf, AI_CONTROLLER_PROCESSING_TILE_RANGE))
				if(seen_cells[cell])
					continue
				seen_cells[cell] = TRUE
				for(var/atom/movable/hearable as anything in cell.hearing_contents)
					var/datum/ai_controller/found_controller = hearable.ai_controller
					if(found_controller)
						in_range_controllers[found_controller] = TRUE

	var/list/status_list = GLOB.ai_controllers_by_status[planning_status]
	for(var/datum/ai_controller/ai_controller as anything in in_range_controllers)
		if(ai_controller in status_list)
			. += ai_controller

/datum/controller/subsystem/ai_controllers/fire(resumed)
	var/timer = TICK_USAGE_REAL

	if(!resumed)
		src.currentrun = build_currentrun()

	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/ai_controller/ai_controller = currentrun[currentrun.len]
		currentrun.len--
		if(!ai_controller || QDELETED(ai_controller))
			continue
		if(!COOLDOWN_FINISHED(ai_controller, failed_planning_cooldown))
			continue
		if(!ai_controller.able_to_plan())
			continue
		ai_controller.SelectBehaviors(wait * 0.1)
		if(!LAZYLEN(ai_controller.current_behaviors)) //Still no plan
			COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)
		if(MC_TICK_CHECK)
			our_cost = MC_AVERAGE(our_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
			return

	our_cost = MC_AVERAGE(our_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

#undef AI_STATUS_OFF_MAX_TIME
#undef AI_CONTROLLER_PROCESSING_TILE_RANGE
