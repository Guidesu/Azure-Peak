// Native TGUI rebuild of the classic Body Markings popup (ShowMarkings /
// handle_body_markings_topic in preferences_body_markings.dm). Unlike
// Customizers, this system already has one uniform data shape — an ordered,
// per-zone list of marking-name -> color pairs — so it needed no per-type
// investigation, just a straight translation of the existing href actions
// (add/remove/reorder/recolor/reset/preset) into ui_act cases.

/datum/preferences
	var/datum/character_markings_ui/dreamvalley_markings_ui

/datum/preferences/proc/dreamvalley_open_markings_ui(mob/user)
	if(!dreamvalley_markings_ui)
		dreamvalley_markings_ui = new(user.client)
	dreamvalley_markings_ui.ui_interact(user)

/datum/character_markings_ui
	var/client/owner

/datum/character_markings_ui/New(client/C)
	owner = C

/datum/character_markings_ui/Destroy()
	owner = null
	return ..()

/datum/character_markings_ui/proc/get_prefs()
	return owner?.prefs

/datum/character_markings_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_markings_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterMarkings", "Body Markings")
		ui.open()

/datum/character_markings_ui/proc/zone_display_name(zone)
	switch(zone)
		if(BODY_ZONE_R_ARM)
			return "Right Arm"
		if(BODY_ZONE_L_ARM)
			return "Left Arm"
		if(BODY_ZONE_HEAD)
			return "Head"
		if(BODY_ZONE_CHEST)
			return "Chest"
		if(BODY_ZONE_R_LEG)
			return "Right Leg"
		if(BODY_ZONE_L_LEG)
			return "Left Leg"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "Right Hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "Left Hand"
	return "[zone]"

/datum/character_markings_ui/ui_data(mob/user)
	var/datum/preferences/P = get_prefs()
	var/list/data = list()
	if(!P || !P.pref_species)
		return data

	var/list/zone_rows = list()
	for(var/zone in GLOB.marking_zones)
		var/list/marking_rows = list()
		var/list/zone_markings = P.body_markings[zone]
		if(zone_markings)
			var/index = 0
			for(var/marking_name in zone_markings)
				index++
				marking_rows += list(list(
					"name" = marking_name,
					"color" = zone_markings[marking_name],
					"index" = index,
					"can_move_up" = (index > 1),
					"can_move_down" = (index < length(zone_markings)),
				))
		zone_rows += list(list(
			"zone" = "[zone]",
			"display_name" = zone_display_name(zone),
			"markings" = marking_rows,
			"can_add" = !zone_markings || (length(zone_markings) < MAXIMUM_MARKINGS_PER_LIMB),
		))

	data["zones"] = zone_rows
	data["has_presets"] = length(marking_sets_for_species(P.pref_species)) > 0
	return data

/datum/character_markings_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/user = ui.user
	var/datum/preferences/P = get_prefs()
	if(!P)
		return TRUE

	var/zone = params["zone"]
	var/name = params["name"]

	switch(action)
		if("use_preset")
			var/list/candidates = marking_sets_for_species(P.pref_species)
			if(!length(candidates))
				return TRUE
			var/desired_set = tgui_input_list(user, "Choose your new body markings:", "Character Preference", candidates)
			if(desired_set)
				var/datum/body_marking_set/BMS = GLOB.body_marking_sets[desired_set]
				P.body_markings = assemble_body_markings_from_set(BMS, P.features, P.pref_species)

		if("reset_all_colors")
			P.reset_body_marking_colors()

		if("reset_color")
			if(!P.body_markings[zone] || !P.body_markings[zone][name])
				return TRUE
			var/datum/body_marking/BM = GLOB.body_markings[name]
			P.body_markings[zone][name] = BM.get_default_color(P.features, P.pref_species)

		if("change_color")
			if(!P.body_markings[zone] || !P.body_markings[zone][name])
				return TRUE
			var/color = P.body_markings[zone][name]
			var/new_color = color_pick_sanitized(user, "Choose your markings color:", "Character Preference", "#[color]")
			if(new_color)
				if(!P.body_markings[zone] || !P.body_markings[zone][name])
					return TRUE
				P.body_markings[zone][name] = sanitize_hexcolor(new_color, 6)

		if("marking_move_up")
			var/list/marking_list = LAZYACCESS(P.body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || --current_index < 1)
				return TRUE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content

		if("marking_move_down")
			var/list/marking_list = LAZYACCESS(P.body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || ++current_index > length(marking_list))
				return TRUE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content

		if("add_marking")
			if(!GLOB.body_markings_per_limb[zone])
				return TRUE
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, P.pref_species)
			if(P.body_markings[zone])
				if(P.body_markings[zone].len >= MAXIMUM_MARKINGS_PER_LIMB)
					return TRUE
				for(var/keyed_name in P.body_markings[zone])
					possible_candidates -= keyed_name
			if(!possible_candidates.len)
				return TRUE
			var/desired_marking = tgui_input_list(user, "Choose your new marking to add:", "Character Preference", possible_candidates)
			if(desired_marking)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				if(!P.body_markings[zone])
					P.body_markings[zone] = list()
				P.body_markings[zone][BD.name] = BD.get_default_color(P.features, P.pref_species)

		if("remove_marking")
			if(!P.body_markings[zone] || !P.body_markings[zone][name])
				return TRUE
			P.body_markings[zone] -= name
			if(P.body_markings[zone].len == 0)
				P.body_markings -= zone

		if("change_marking")
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, P.pref_species)
			if(P.body_markings[zone])
				for(var/keyed_name in P.body_markings[zone])
					possible_candidates -= keyed_name
			if(!possible_candidates.len)
				return TRUE
			var/desired_marking = tgui_input_list(user, "Choose a marking to change the current one to:", "Character Preference", possible_candidates)
			if(desired_marking)
				if(!P.body_markings[zone] || !P.body_markings[zone][name])
					return TRUE
				var/held_index = LAZYFIND(P.body_markings[zone], name)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				var/marking_content = BD.get_default_color(P.features, P.pref_species)
				P.body_markings[zone] -= name
				P.body_markings[zone].Insert(held_index, desired_marking)
				P.body_markings[zone][desired_marking] = marking_content

	if(ishuman(user))
		var/mob/living/carbon/human/humanized = user
		humanized.update_body_parts(TRUE)
	if(get_prefs()?.dreamvalley_character_sheet_ui)
		get_prefs().dreamvalley_character_sheet_ui.mark_preview_dirty()
	return TRUE
