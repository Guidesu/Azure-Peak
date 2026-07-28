// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/non_mob_controller.dm
// (source type /atom/movable/screen/strategy_ui - renamed here to
// /atom/movable/screen/base_ui to avoid confusion with this port's own
// /atom/movable/screen/controller_ui from ui/controller_ui.dm, which is a
// different, unrelated screen-object family in the source too - upstream
// just happened to pick similar-sounding names for two independent HUD
// trees).
//
// PHASE 4 (UI). The always-on base/world overview HUD: shown from
// controller_mob.dm's Login() for the lifetime of the strategy_controller
// mob, holding the action bar/stat pane/unit preview/ability bar backdrop
// plus the category button row (decor/traps/builds/move/destroy/exit/
// bottom).
//
// FUNCTIONAL vs PLACEHOLDER judgment call for each category button, per the
// task's explicit direction to use judgment on what maps to features that
// actually exist:
//   - builds: FUNCTIONAL. Lists this port's three real building_datums
//     (core/stockpile/mines) and opens building_icon (ui/building_menu.dm),
//     exactly like the source's builds button opening the same panel.
//   - destroy: FUNCTIONAL. Toggles break_turf_mode and, on left-click,
//     queues a real /datum/work_order/break_turf via a /datum/queued_workorder
//     appended to in_progress_workorders - controller_mob.dm's process()
//     loop (Phase 1) already dispatches in_progress_workorders to idle
//     workers, and break_turf itself is a real Phase 2 work order (see
//     work_orders/orders/break_turf.dm). Ported into controller_mob.dm's
//     ClickOn()/a new handle_break_turf_click() (see that file) rather than
//     kept in the source's fuller form, since this port has none of
//     move_structure_mode/selected_structure/patrol_setup_active to check
//     alongside it (see controller_mob.dm's Phase 4 addition comment).
//   - move: PLACEHOLDER. Source's move button depends entirely on
//     /datum/work_order/move_structure, which does not exist anywhere in
//     this port (confirmed by grep - it's Phase 6/never-explicitly-scheduled
//     territory, not listed in any phase of the approved plan). The button
//     is shown (matching the source's HUD layout) but Click() only prints an
//     informational chat message instead of runtime-erroring on a missing
//     work order type.
//   - decor / traps: PLACEHOLDER, visually present but empty. Source's
//     decor/traps button lists are entirely /datum/building_datum/simple
//     subtypes (walls/floors/skull-walls for decor; flame/poison/chill/saw/
//     bomb/spike/spawner traps) - /datum/building_datum/simple itself
//     doesn't exist in this port (building_datums/_base_datum.dm's header
//     comment: only the map-template-backed subtype was ported) and none of
//     the individual simple_builds/*.dm subtypes were ported either (traps
//     are explicitly out of scope per the plan's "Deferred / explicitly out
//     of scope" section: "simple_builds/traps.dm ... not part of any phase
//     above"). Both buttons are shown for HUD-layout parity with the source
//     but have an empty buildings list, so the shared
//     controller_button/Click() below just no-ops (length(buildings) == 0)
//     with an informational chat message instead of opening an empty menu.
//   - bottom: PLACEHOLDER/omitted-of-behavior, matching upstream: source
//     never gives /controller_button/bottom a Click() override or a
//     `buildings` list anywhere (confirmed by grep) - it's a purely
//     decorative HUD slot upstream too. Shown here with no Click() override,
//     same as the source.
//   - exit: OMITTED ENTIRELY. Source's exit button transfers control back to
//     master.linked_overlord's overlord_body (Phase 7's Overlord antagonist
//     wrapper) - Phase 7 is cut per the plan, so this port's
//     strategy_controller has no linked_overlord var and no player-facing
//     "return to body" flow to exit into. Omitting the button (rather than
//     shipping a dead click) matches this port's only real exit path for
//     now: an admin ghosting/deleting the debug-spawned controller mob.
/atom/movable/screen/base_ui
	icon = 'modular_dreamvalley/icons/rts/rts_mob_hud.dmi'

/atom/movable/screen/base_ui/controller_ui
	screen_loc = "WEST,SOUTH"
	icon = null

	var/atom/movable/screen/base_ui/action/actions
	var/atom/movable/screen/base_ui/stat_pane/stat
	var/atom/movable/screen/base_ui/units_preview/units
	var/atom/movable/screen/base_ui/ability_bar/ability

	var/atom/movable/screen/base_ui/controller_button/bottom/bottom
	var/atom/movable/screen/base_ui/controller_button/move/move
	var/atom/movable/screen/base_ui/controller_button/destroy/destroy

	var/atom/movable/screen/base_ui/controller_button/decor/decor
	var/atom/movable/screen/base_ui/controller_button/traps/traps
	var/atom/movable/screen/base_ui/controller_button/builds/builds

/atom/movable/screen/base_ui/controller_ui/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	hud = hud_owner
	create_and_position_buttons(hud_owner)

/atom/movable/screen/base_ui/controller_ui/Destroy(force)
	QDEL_NULL(actions)
	QDEL_NULL(stat)
	QDEL_NULL(units)
	QDEL_NULL(ability)
	QDEL_NULL(bottom)
	QDEL_NULL(move)
	QDEL_NULL(decor)
	QDEL_NULL(traps)
	QDEL_NULL(builds)
	QDEL_NULL(destroy)
	return ..()

/atom/movable/screen/base_ui/controller_ui/vv_edit_var(var_name, var_value)
	switch (var_name)
		if ("screen_loc")
			update_screen_loc(var_value)
			return TRUE

	return ..()

/atom/movable/screen/base_ui/controller_ui/proc/add_ui(client/client)
	if(!client)
		return
	update_all()
	client.screen += actions

/atom/movable/screen/base_ui/controller_ui/proc/add_ui_buttons(client/client)
	if(!client)
		return
	update_all()
	client.screen += stat
	client.screen += units
	client.screen += ability
	client.screen += decor
	client.screen += traps
	client.screen += builds
	client.screen += bottom
	client.screen += destroy
	client.screen += move

/atom/movable/screen/base_ui/controller_ui/proc/remove_ui(client/client)
	if(!client)
		return
	update_all()
	client.screen -= actions
	client.screen -= stat
	client.screen -= units
	client.screen -= ability
	client.screen -= decor
	client.screen -= traps
	client.screen -= builds
	client.screen -= bottom
	client.screen -= destroy
	client.screen -= move

/atom/movable/screen/base_ui/controller_ui/proc/create_and_position_buttons(datum/hud/hud_owner)
	actions = new(null, hud_owner)
	units = new(null, hud_owner)
	ability = new(null, hud_owner)
	stat = new(null, hud_owner)
	decor = new(null, hud_owner)
	traps = new(null, hud_owner)
	builds = new(null, hud_owner)
	bottom = new(null, hud_owner)
	destroy = new(null, hud_owner)
	move = new(null, hud_owner)

	update_screen_loc()
	update_all()

/atom/movable/screen/base_ui/controller_ui/proc/update_screen_loc(new_loc)
	if(new_loc)
		screen_loc = new_loc

	actions.screen_loc = screen_loc
	units.screen_loc = screen_loc
	ability.screen_loc = screen_loc
	stat.screen_loc = screen_loc
	decor.screen_loc = screen_loc
	traps.screen_loc = screen_loc
	builds.screen_loc = screen_loc
	bottom.screen_loc = screen_loc
	destroy.screen_loc = screen_loc
	move.screen_loc = screen_loc

/atom/movable/screen/base_ui/controller_ui/proc/update_all()
	return

/atom/movable/screen/base_ui/controller_ui/proc/update_text()
	return

/atom/movable/screen/base_ui/action
	icon_state = "action"

/atom/movable/screen/base_ui/stat_pane
	icon_state = "stats"
	maptext_x = 346
	maptext_y = 62
	maptext_width = 128
	maptext_height = 32

/atom/movable/screen/base_ui/units_preview
	icon_state = "units_preview"

/atom/movable/screen/base_ui/ability_bar
	icon_state = "ability_bar"

// ADAPTATION: source's base controller_button defaults to icon_state
// "button_1", which does not exist in the copied rts_mob_hud.dmi (confirmed
// against the file's zTXt icon-state list before porting - it has
// "blank_first"/"blank_second"/"button_2"/"button_3"/"button_4" but no
// "button_1"). Every concrete subtype below overrides icon_state anyway, so
// this only affects the abstract base type itself (never instantiated
// directly) - falls back to "blank_first" as the closest equivalent blank
// button face.
/atom/movable/screen/base_ui/controller_button
	icon_state = "blank_first"

	var/list/buildings
	var/highlighted = FALSE
	var/highlight_color

/atom/movable/screen/base_ui/controller_button/MouseExited()
	if(!usr.client)
		return

	. = ..()
	color = null
	if(highlighted)
		color = highlight_color

/atom/movable/screen/base_ui/controller_button/MouseEntered(location,control,params)
	if(!usr.client)
		return

	. = ..()
	color = "#f0efab"
