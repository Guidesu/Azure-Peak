// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/building_menu.dm
//
// PHASE 4 (UI). The purchasable-building grid: a screen-object HUD panel of
// building_button icons, red/green-gated on whether the controller can
// currently afford (and, where required, has a stockpile to accept) the
// building. This is the first Phase 4 file per the plan, since it's what
// makes buildings player-triggerable without the Phase 1-3 debug verbs -
// clicking a button calls the exact same try_setup_build() proc
// controller_mob.dm has had since Phase 2.
//
// Direct port, no MAT_*/logic adaptation needed - resource_check() and
// stockpile_needed both already exist verbatim on /datum/building_datum
// (building_datums/_base_datum.dm), so update_build_state() below reads them
// as-is.
//
// ADAPTATION: source's building_button/icon defaults to
// 'icons/hud/storage.dmi' icon_state "background" (a generic HUD backdrop
// icon, nothing building-specific) - that .dmi/icon_state pair already
// exists in this repo unmodified (icons/hud/storage.dmi, repo root - not
// copied, referenced directly), so no change needed. building_backdrop's
// icon 'icons/hud/rts_ability_hud.dmi' icon_state "button_ui", and
// close_building's icon_state "close_bar" (same .dmi) both exist unmodified
// in the copied modular_dreamvalley/icons/rts/rts_ability_hud.dmi (confirmed
// against the file's zTXt icon-state list before porting).
//
// ADAPTATION: source's open_ui() branches on /datum/building_datum/simple
// (Vanderlin's single-atom "decor"/"trap" building type, e.g. walls/braziers)
// to build its button preview from created_atom's icon/icon_state instead of
// ui_icon/ui_icon_state. /datum/building_datum/simple does not exist in this
// port (see building_datums/_base_datum.dm's header comment - only the
// map-template-backed subtype is ported), so that branch is dropped; every
// building_datum this phase can ever pass through open_ui() is the plain
// map-template-backed kind, which always has ui_icon/ui_icon_state set (see
// core.dm/stockpile.dm/mines.dm).
/atom/movable/screen/close_building
	icon = 'modular_dreamvalley/icons/rts/rts_ability_hud.dmi'
	icon_state = "close_bar"
	screen_loc = "WEST,SOUTH:96"

/atom/movable/screen/building_button
	icon = 'icons/hud/storage.dmi'
	icon_state = "background"
	screen_loc = "WEST,SOUTH:96"
	var/build_state = TRUE
	var/datum/building_datum/build_datum
	var/datum/building_datum/datum_path

/atom/movable/screen/building_button/proc/update_build_state(mob/camera/strategy_controller/master)
	if(!build_datum)
		build_datum = new datum_path

	if(build_datum.stockpile_needed && !master.resource_stockpile)
		build_state = FALSE
		color = COLOR_RED_LIGHT
		return

	if(!build_datum.resource_check(master))
		build_state = FALSE
		color = COLOR_RED_LIGHT
		return

	build_state = TRUE
	color = null

/atom/movable/screen/building_button/Click(location, control, params)
	. = ..()
	if(!build_state)
		return
	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return
	controller.try_setup_build(datum_path)

/atom/movable/screen/close_building/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/clicker = usr
	if(!istype(clicker))
		return
	clicker.close_building_ui()

/atom/movable/screen/building_backdrop
	icon = 'modular_dreamvalley/icons/rts/rts_ability_hud.dmi'
	icon_state = "button_ui"
	screen_loc = "WEST,SOUTH:96"

	var/list/build_buttons = list()
	var/atom/movable/screen/close_building/close

	var/max_x = 3
	var/max_y = 6

	var/current_x = 0
	var/current_y = 0

/atom/movable/screen/building_backdrop/proc/update(mob/camera/strategy_controller/processer)
	if(!length(build_buttons))
		return
	for(var/atom/movable/screen/building_button/button in build_buttons)
		button.update_build_state(processer)

/atom/movable/screen/building_backdrop/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	hud = hud_owner
	close = new(null, hud_owner)

/atom/movable/screen/building_backdrop/proc/close_uis(mob/camera/strategy_controller/closer)
	for(var/atom/movable/screen/building_button/button as anything in build_buttons)
		build_buttons -= button
		closer.client.screen -= button
		qdel(button)
	closer.client.screen -= src
	closer.client.screen -= close
	current_x = 0
	current_y = 0

/atom/movable/screen/building_backdrop/proc/open_ui(mob/camera/strategy_controller/opener, list/building_datums)
	close_uis(opener)
	for(var/datum/building_datum/building_type as anything in building_datums)
		var/atom/movable/screen/building_button/new_button = new
		new_button.hud = hud
		var/datum/building_datum/building = building_type
		var/mutable_appearance/MA = mutable_appearance(initial(building.ui_icon), initial(building.ui_icon_state), new_button.layer + 0.1, new_button.plane)
		new_button.add_overlay(MA)
		new_button.name = initial(building.name)
		new_button.datum_path = building_type

		new_button.screen_loc = "WEST:[current_x*32],SOUTH:[96 + (current_y*32)]"

		current_x++

		if(current_x >= max_x)
			current_x = 0
			current_y++
		opener.client.screen += new_button
		build_buttons += new_button

	opener.client.screen += src
	opener.client.screen += close
