// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/buttons/mob_buttons.dm
//
// PHASE 4 (UI). Supporting button widgets for ui/controller_ui.dm's per-
// worker panel.
//
// Ported: mob_exit (closes the worker panel, reopens the base HUD - both
// displayed_mob_ui and displayed_base_ui are real vars on controller_mob.dm
// as of this phase, see that file).
//
// NOT ported (see ui/controller_ui.dm's header comment for why):
//   - controller_button/one, controller_button/two: source declares these as
//     plain reskinned controller_buttons with no Click() override anywhere
//     in the entire Vanderlin source (confirmed by grep before porting) -
//     dead/unused placeholders upstream too, so dropping them loses no
//     functionality.
//
// PHASE 6 UN-DEFER: controller_button/patrol is now ported (direct port of
// the source's version, toggling patrol_setup_active and delegating the
// actual click-sequence handling to controller_mob.dm's
// find_active_patrol_setup_mob()/handle_patrol_setup_click(), added this
// phase - see that file).
//
// PHASE 6 ADDITION: controller_button/attack is NEW, not in upstream
// Vanderlin - see ui/controller_ui.dm's header comment for why (grep-
// confirmed apply_attack_strategy() has no player-facing trigger anywhere in
// the entire Vanderlin source, including the cut Overlord antagonist).
// Mirrors the patrol button's toggle pattern: on, calls
// worker.controller_mind.apply_attack_strategy() (attacking_strategy.dm) so
// the worker starts hunting hostiles on its own next check_worktree() tick;
// off, calls suppress_attack() (work_mind.dm) to drop any current target and
// null attack_mode entirely, returning the worker to normal work dispatch.
/atom/movable/screen/controller_ui/controller_button/mob_exit
	icon_state = "exit"

/atom/movable/screen/controller_ui/controller_button/mob_exit/Click(location, control, params)
	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller) || !controller.client)
		return

	// Close the current mob UI
	if(controller.displayed_mob_ui)
		controller.displayed_mob_ui.remove_ui(controller.client)

	// Reopen the base UI
	if(controller.displayed_base_ui)
		controller.displayed_base_ui.add_ui(controller.client)
		controller.displayed_base_ui.add_ui_buttons(controller.client)

	return TRUE

/atom/movable/screen/controller_ui/controller_button/patrol
	icon_state = "patrol"
	highlight_color = "#4CAF50"
	var/patrol_mode = FALSE
	var/atom/movable/screen/controller_ui/controller_ui/parent_ui

/atom/movable/screen/controller_ui/controller_button/patrol/Destroy(force)
	parent_ui = null
	return ..()

/atom/movable/screen/controller_ui/controller_button/patrol/Click(location, control, params)
	. = ..()
	if(!parent_ui || !parent_ui.worker_mob)
		return

	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return

	var/mob/living/target_mob = parent_ui.worker_mob

	patrol_mode = !patrol_mode

	if(patrol_mode)
		controller.break_turf_mode = FALSE

		if(!target_mob.controller_mind.patrol_points)
			target_mob.controller_mind.patrol_points = list()
		target_mob.controller_mind.patrol_setup_active = TRUE

		color = highlight_color
		highlighted = TRUE
		to_chat(controller, span_notice("Patrol setup mode activated for [target_mob.name]. Left click to add patrol points, right click to finish patrol setup."))

		controller.update_mob_patrol_visuals(target_mob)
	else
		target_mob.controller_mind.patrol_setup_active = FALSE
		color = null
		highlighted = FALSE
		controller.clear_mob_patrol_visuals(target_mob)
		to_chat(controller, span_notice("Patrol setup mode deactivated for [target_mob.name]."))

// PHASE 6 ADDITION (not in upstream Vanderlin) - see this file's header
// comment. Reuses "blank_second" (ui/controller_ui.dm's header comment
// explains why: no dedicated attack/sword icon_state exists in
// rts_mob_hud.dmi).
/atom/movable/screen/controller_ui/controller_button/attack
	icon_state = "blank_second"
	highlight_color = "#ff6b6b"
	var/attack_mode_on = FALSE
	var/atom/movable/screen/controller_ui/controller_ui/parent_ui

/atom/movable/screen/controller_ui/controller_button/attack/Destroy(force)
	parent_ui = null
	return ..()

/atom/movable/screen/controller_ui/controller_button/attack/Click(location, control, params)
	. = ..()
	if(!parent_ui || !parent_ui.worker_mob)
		return

	var/mob/camera/strategy_controller/controller = usr
	if(!istype(controller))
		return

	var/mob/living/target_mob = parent_ui.worker_mob
	if(!target_mob.controller_mind)
		return

	attack_mode_on = !attack_mode_on

	if(attack_mode_on)
		// Turning on patrol/break-turf setup modes on this same worker no
		// longer makes sense once it's hunting hostiles on its own -
		// deactivate them the same way toggling patrol deactivates
		// break_turf_mode above.
		controller.break_turf_mode = FALSE
		if(parent_ui.patrol_button?.patrol_mode)
			parent_ui.patrol_button.patrol_mode = FALSE
			parent_ui.patrol_button.color = null
			parent_ui.patrol_button.highlighted = FALSE
			target_mob.controller_mind.patrol_setup_active = FALSE
			controller.clear_mob_patrol_visuals(target_mob)

		target_mob.controller_mind.apply_attack_strategy(/datum/worker_attack_strategy)

		color = highlight_color
		highlighted = TRUE
		to_chat(controller, span_notice("Attack mode activated for [target_mob.name]. It will now hunt down and engage nearby hostiles."))
	else
		target_mob.controller_mind.suppress_attack()
		target_mob.controller_mind.attack_mode = null

		color = null
		highlighted = FALSE
		to_chat(controller, span_notice("Attack mode deactivated for [target_mob.name]."))
