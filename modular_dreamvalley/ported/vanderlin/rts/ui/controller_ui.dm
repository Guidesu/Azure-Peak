// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/controller_ui.dm
//
// PHASE 4 (UI). The per-worker mob panel shown when a controller right-clicks
// one of its workers: a scaled-up portrait preview, name, current task text,
// and a stamina/workspeed stat readout, plus a row of buttons (see
// ui/buttons/mob_buttons.dm).
//
// PHASE 6 UN-DEFER: update_task_text() now checks
// worker_mind.attack_mode?.current_target first (attack_mode is a real var
// on work_mind.dm as of this phase - see attacking_strategy.dm), matching
// the source's original behavior of showing "Attacking X" over the plain
// current_task text whenever a worker is actively chasing/engaging a target.
//
// ADAPTATION: source's name_box/task maptext use MAPTEXT_BLACKMOOR()/
// MAPTEXT_CENTER() macros (Vanderlin-specific font/style wrappers, defined in
// its own __HELPERS/text.dm - grep confirmed before porting that neither
// macro exists in this repo). This repo's equivalent generic wrapper is
// MAPTEXT() (code/__HELPERS/text.dm, used throughout code/_onclick/hud/) -
// used here in their place. Text is centered via inline style instead of a
// dedicated CENTER macro.
//
// ADAPTATION: button_one/button_two (source: /controller_button/one,
// /controller_button/two - both plain unlabeled placeholder buttons with no
// Click() override in the entire Vanderlin source, confirmed by grep) are
// still NOT created here - they're dead upstream too, dropping them loses no
// functionality.
//
// PHASE 6 UN-DEFER: patrol_button is now created (Phase 4 deferred it - see
// that phase's header comment, now removed). Also added: attack_button, a
// NEW addition (not upstream Vanderlin - see this repo's attacking_strategy.dm
// header comment and _debug_verb.dm's Phase 6 addition for why): grep of the
// entire Vanderlin source (RTS + the since-cut Overlord antagonist) found
// apply_attack_strategy() is NEVER called from any player-reachable UI or
// spell upstream either - the only caller in the whole source is
// worker_attack_strategy/call_for_backup() (an already-fighting ally rallying
// help). Since Phase 7 (the Overlord antagonist, the only thing that might
// have wired a player-facing attack trigger) is cut, this port adds a
// minimal toggle button here so the ported combat layer is actually
// reachable in-game, mirroring the patrol button's toggle pattern exactly.
// See ui/buttons/mob_buttons.dm for both buttons' Click() handlers.
//
// Icon: 'icons/rts/rts_mob_hud.dmi', copied unmodified from Vanderlin's
// icons/hud/rts_mob_hud.dmi (confirmed present: character_preview, name,
// task, stats, blank_first, blank_second, partial_first, exit, patrol
// icon_states all exist in the copied file's zTXt icon-state list. There is
// no dedicated "attack"/"sword" icon_state in this file, so attack_button
// below reuses "blank_second" - an existing generic blank button face,
// already used as a placeholder face elsewhere in this HUD - distinguished
// by its highlight_color when toggled on).
/atom/movable/screen/controller_ui
	icon = 'modular_dreamvalley/icons/rts/rts_mob_hud.dmi'

/atom/movable/screen/controller_ui/controller_ui
	screen_loc = "WEST,SOUTH"
	icon = null

	var/atom/movable/screen/controller_ui/character_pane/character
	var/atom/movable/screen/controller_ui/name_pane/name_box
	var/atom/movable/screen/controller_ui/task_pane/task
	var/atom/movable/screen/controller_ui/stat_pane/stat

	var/atom/movable/screen/controller_ui/controller_button/mob_exit/mob_exit

	// PHASE 6 UN-DEFER: see this file's header comment.
	var/atom/movable/screen/controller_ui/controller_button/patrol/patrol_button
	var/atom/movable/screen/controller_ui/controller_button/attack/attack_button

	var/mob/living/worker_mob
	var/datum/worker_mind/worker_mind

/atom/movable/screen/controller_ui/controller_ui/Initialize(mapload, datum/hud/hud_owner, mob/living/worker, datum/worker_mind/creation_source)
	. = ..()
	hud = hud_owner
	worker_mob = worker
	worker_mind = creation_source
	create_and_position_buttons()

/atom/movable/screen/controller_ui/controller_ui/Destroy(force)
	QDEL_NULL(character)
	QDEL_NULL(name_box)
	QDEL_NULL(task)
	QDEL_NULL(stat)
	QDEL_NULL(mob_exit)
	QDEL_NULL(patrol_button)
	QDEL_NULL(attack_button)
	worker_mind = null
	worker_mob = null
	return ..()

/atom/movable/screen/controller_ui/controller_ui/vv_edit_var(var_name, var_value)
	switch (var_name)
		if ("screen_loc")
			update_screen_loc(var_value)
			return TRUE

	return ..()

/atom/movable/screen/controller_ui/controller_ui/proc/add_ui(client/client)
	if(!client)
		return
	update_all()
	client.screen += character
	client.screen += name_box
	client.screen += task
	client.screen += stat
	client.screen += mob_exit
	client.screen += patrol_button
	client.screen += attack_button

/atom/movable/screen/controller_ui/controller_ui/proc/remove_ui(client/client)
	if(!client)
		return
	update_all()
	client.screen -= character
	client.screen -= name_box
	client.screen -= task
	client.screen -= stat
	client.screen -= mob_exit
	client.screen -= patrol_button
	client.screen -= attack_button

/atom/movable/screen/controller_ui/controller_ui/proc/create_and_position_buttons()
	character = new
	character.hud = hud
	name_box = new
	name_box.hud = hud
	task = new
	task.hud = hud
	stat = new
	stat.hud = hud
	mob_exit = new
	mob_exit.hud = hud
	// PHASE 6 UN-DEFER: both need a back-reference to this panel so their
	// Click() handlers can look up worker_mob - mirrors upstream's
	// patrol_button.parent_ui assignment.
	patrol_button = new
	patrol_button.hud = hud
	patrol_button.parent_ui = src
	attack_button = new
	attack_button.hud = hud
	attack_button.parent_ui = src

	update_screen_loc()
	update_all()

/atom/movable/screen/controller_ui/controller_ui/proc/update_screen_loc(new_loc)
	if(new_loc)
		screen_loc = new_loc

	character.screen_loc = screen_loc
	name_box.screen_loc = screen_loc
	task.screen_loc = screen_loc
	stat.screen_loc = screen_loc
	mob_exit.screen_loc = screen_loc
	patrol_button.screen_loc = screen_loc
	attack_button.screen_loc = screen_loc

/atom/movable/screen/controller_ui/controller_ui/proc/update_all()
	update_character_visual()
	update_task_text()
	update_name_text()
	update_stat_text()

/atom/movable/screen/controller_ui/controller_ui/proc/update_text()
	update_task_text()
	update_name_text()
	update_stat_text()

/atom/movable/screen/controller_ui/controller_ui/proc/update_character_visual()
	if(!worker_mob)
		return
	var/mutable_appearance/MA = mutable_appearance()
	MA.appearance = worker_mob.appearance

	var/matrix/transform_matrix = matrix()
	transform_matrix.Scale(2, 2)
	MA.transform = transform_matrix

	MA.plane = plane
	MA.layer = layer + 0.1

	MA.pixel_y = 36
	MA.pixel_x = 126

	character.cut_overlays()
	character.add_overlay(MA)

/atom/movable/screen/controller_ui/controller_ui/proc/update_task_text()
	if(!worker_mind)
		return
	var/task_text = "Idle"
	if(worker_mind.attack_mode?.current_target)
		task_text = "Attacking [worker_mind.attack_mode.current_target]"
	else if(worker_mind.current_task)
		task_text = "[worker_mind.current_task.name]"
	task.maptext = MAPTEXT("<span style='text-align: center'>[task_text]</span>")

/atom/movable/screen/controller_ui/controller_ui/proc/update_name_text()
	if(!worker_mind)
		return
	name_box.maptext = MAPTEXT("<span style='font-size: 12pt'>[worker_mind.worker_name]</span>")

/atom/movable/screen/controller_ui/controller_ui/proc/update_stat_text()
	if(!worker_mind)
		return
	stat.maptext = MAPTEXT("<span style='text-align: center'>Stamina: [worker_mind.current_stamina]<br>Workspeed: [worker_mind.work_speed]</span>")

/atom/movable/screen/controller_ui/character_pane
	icon_state = "character_preview"

/atom/movable/screen/controller_ui/name_pane
	icon_state = "name"
	maptext_x = 206
	maptext_width = 120
	maptext_height = 32
	maptext_y = 64

/atom/movable/screen/controller_ui/task_pane
	icon_state = "task"
	maptext_x = 201
	maptext_width = 128
	maptext_height = 16
	maptext_y = 16

/atom/movable/screen/controller_ui/stat_pane
	icon_state = "stats"
	maptext_x = 346
	maptext_y = 62
	maptext_width = 128
	maptext_height = 32

/atom/movable/screen/controller_ui/controller_button
	icon_state = "blank_first"
	var/highlighted = FALSE
	var/highlight_color

/atom/movable/screen/controller_ui/controller_button/MouseExited()
	if(!usr.client)
		return

	. = ..()
	color = null
	if(highlighted)
		color = highlight_color

/atom/movable/screen/controller_ui/controller_button/MouseEntered(location,control,params)
	if(!usr.client)
		return

	. = ..()
	color = "#f0efab"
