// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/buttons/non_mob_buttons.dm
// (renamed strategy_ui -> base_ui throughout - see ui/non_mob_controller.dm's
// header comment).
//
// PHASE 4 (UI). Category button Click() handlers for the base overview HUD.
// See ui/non_mob_controller.dm's header comment for the full functional-vs-
// placeholder breakdown; this file just implements what's declared there.
//
// NOT ported: /controller_button/exit (Overlord-only, Phase 7 cut - see
// ui/non_mob_controller.dm's header comment for why the button itself is
// omitted entirely, not just its Click()).
//
// bottom is intentionally left with no Click() override, matching upstream
// (source never gives it one either).

/atom/movable/screen/base_ui/controller_button/bottom
	icon_state = "button_4"

/atom/movable/screen/base_ui/controller_button/destroy
	icon_state = "break"
	highlight_color = "#ff6b6b"

// FUNCTIONAL - see ui/non_mob_controller.dm's header comment. Toggles
// controller_mob.dm's break_turf_mode (Phase 4 addition to that file) and
// clears the move button's highlight, mirroring the source's mutual-
// exclusion behavior minus the move_structure_mode/selected_structure/
// patrol branches this port doesn't have.
/atom/movable/screen/base_ui/controller_button/destroy/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return

	controller.break_turf_mode = !controller.break_turf_mode

	if(controller.break_turf_mode)
		color = highlight_color
		highlighted = TRUE
		to_chat(controller, span_notice("Break turf mode activated. Left click a turf/structure to queue a break order. Right click to cancel this mode."))
	else
		color = null
		highlighted = FALSE
		to_chat(controller, span_notice("Break turf mode deactivated."))

/atom/movable/screen/base_ui/controller_button/move
	icon_state = "move"
	highlight_color = "#6b9eff"

// PLACEHOLDER - see ui/non_mob_controller.dm's header comment.
// /datum/work_order/move_structure does not exist in this port; rather than
// toggle a move_structure_mode that would have nothing real to dispatch to
// (and no selected_structure/is_valid_move_destination/create_move_order
// support on controller_mob.dm), this button just informs the player it
// isn't implemented yet.
/atom/movable/screen/base_ui/controller_button/move/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return
	to_chat(controller, span_warning("Structure moving isn't available yet."))

/atom/movable/screen/base_ui/controller_button/decor
	icon_state = "decor"

	// PLACEHOLDER - empty on purpose. See ui/non_mob_controller.dm's header
	// comment: /datum/building_datum/simple and its wall/floor/skull-wall
	// subtypes are not part of this port.
	buildings = list()

/atom/movable/screen/base_ui/controller_button/builds
	icon_state = "builds"

	// FUNCTIONAL - PHASE 5: extended with the seven profession buildings
	// ported this phase (farm/lumber_yard/tannery/tailor/blacksmith/kitchen/
	// bar), alongside the three from earlier phases (core/stockpile/mines).
	buildings = list(
		/datum/building_datum/core,
		/datum/building_datum/stockpile,
		/datum/building_datum/mines,
		/datum/building_datum/farm,
		/datum/building_datum/lumber_yard,
		/datum/building_datum/tannery,
		/datum/building_datum/tailor,
		/datum/building_datum/blacksmith,
		/datum/building_datum/kitchen,
		/datum/building_datum/bar,
	)

/atom/movable/screen/base_ui/controller_button/traps
	icon_state = "traps"

	// PLACEHOLDER - empty on purpose. See ui/non_mob_controller.dm's header
	// comment: traps are explicitly out of scope per the approved plan.
	buildings = list()

/atom/movable/screen/base_ui/controller_button/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return
	if(!length(buildings))
		to_chat(controller, span_warning("Nothing available in this category yet."))
		return
	controller.building_icon.open_ui(controller, buildings)
