// Native TGUI rebuild of the classic Customizers popup (ShowCustomizers /
// handle_customizer_topic in preferences_customizers.dm). The base
// /datum/customizer_choice class already exposes a uniform shape shared by
// most of the ~17 concrete customizer types (an optional accessory pick from
// `sprite_accessories`, plus N named color keys from the chosen
// /datum/sprite_accessory) — that generic shape gets one reusable panel here.
// A handful of subtypes add a small number of extra scalar fields on top
// (eye heterochromia, genital size/fertility/lactation, hair color +
// natural/dye gradients) — those are exposed as an `extra_fields` list so the
// same panel can render them without per-subtype React components.
//
// Head hair's "Customise" band-editor button is NOT rebuilt here — it opens
// a genuinely separate, already-complex sub-tool (open_hair_editor /
// /datum/custom_hair_ui) that is out of scope for this pass; that one button
// still launches the legacy hair editor window.
//
// All mutation still goes through the existing customizer_choice procs
// (set_accessory_type, reset_accessory_colors, validate_entry, etc.) so
// in-game behavior (organ DNA, sprite rendering) is unchanged — only the
// player-facing control surface moved from clickable hrefs to real TGUI
// widgets.

/datum/preferences
	var/datum/character_customizers_ui/dreamvalley_customizers_ui

/datum/preferences/proc/dreamvalley_open_customizers_ui(mob/user)
	if(!dreamvalley_customizers_ui)
		dreamvalley_customizers_ui = new(user.client)
	dreamvalley_customizers_ui.ui_interact(user)

/datum/character_customizers_ui
	var/client/owner

/datum/character_customizers_ui/New(client/C)
	owner = C

/datum/character_customizers_ui/Destroy()
	owner = null
	return ..()

/datum/character_customizers_ui/proc/get_prefs()
	return owner?.prefs

/datum/character_customizers_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_customizers_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterCustomizers", "Customization")
		ui.open()

/// Builds the extra small scalar fields a handful of customizer_choice
/// subtypes add beyond the generic accessory+color shape. Returns a list of
/// {key, label, kind, value, options} rows the frontend renders generically.
/datum/character_customizers_ui/proc/build_extra_fields(datum/customizer_choice/choice, datum/customizer_entry/entry)
	var/list/fields = list()

	if(istype(choice, /datum/customizer_choice/organ/eyes))
		var/datum/customizer_entry/organ/eyes/eyes_entry = entry
		var/datum/customizer_choice/organ/eyes/eyes_choice = choice
		fields += list(list("key" = "eye_color", "label" = "Eye Color", "kind" = "color", "value" = eyes_entry.eye_color))
		if(eyes_choice.allows_heterochromia)
			fields += list(list("key" = "heterochromia", "label" = "Heterochromia", "kind" = "toggle", "value" = !!eyes_entry.heterochromia))
			if(eyes_entry.heterochromia)
				fields += list(list("key" = "second_eye_color", "label" = "Second Color", "kind" = "color", "value" = eyes_entry.second_color))

	else if(istype(choice, /datum/customizer_choice/organ/penis))
		var/datum/customizer_entry/organ/penis/penis_entry = entry
		fields += list(list("key" = "penis_size", "label" = "Size", "kind" = "select", "value" = find_key_by_value(PENIS_SIZES_BY_NAME, penis_entry.penis_size), "options" = PENIS_SIZES_BY_NAME))
		fields += list(list("key" = "functional", "label" = "Functional", "kind" = "toggle", "value" = !!penis_entry.functional))

	else if(istype(choice, /datum/customizer_choice/organ/testicles))
		var/datum/customizer_entry/organ/testicles/testicles_entry = entry
		var/datum/customizer_choice/organ/testicles/testicles_choice = choice
		if(testicles_choice.can_customize_size)
			fields += list(list("key" = "ball_size", "label" = "Ball Size", "kind" = "select", "value" = find_key_by_value(TESTICLE_SIZES_BY_NAME, testicles_entry.ball_size), "options" = TESTICLE_SIZES_BY_NAME))
		fields += list(list("key" = "virile", "label" = "Virile", "kind" = "toggle", "value" = !!testicles_entry.virility))

	else if(istype(choice, /datum/customizer_choice/organ/breasts))
		var/datum/customizer_entry/organ/breasts/breasts_entry = entry
		fields += list(list("key" = "breast_size", "label" = "Breast Size", "kind" = "select", "value" = find_key_by_value(BREAST_SIZES_BY_NAME, breasts_entry.breast_size), "options" = BREAST_SIZES_BY_NAME))
		fields += list(list("key" = "lactating", "label" = "Lactation", "kind" = "toggle", "value" = !!breasts_entry.lactating))

	else if(istype(choice, /datum/customizer_choice/organ/vagina))
		var/datum/customizer_entry/organ/vagina/vagina_entry = entry
		fields += list(list("key" = "fertile", "label" = "Fertile", "kind" = "toggle", "value" = !!vagina_entry.fertility))

	else if(istype(choice, /datum/customizer_choice/bodypart_feature/hair))
		var/datum/customizer_entry/hair/hair_entry = entry
		var/datum/customizer_choice/bodypart_feature/hair/hair_choice = choice
		if(hair_choice.custom_hair_color)
			fields += list(list("key" = "hair_color", "label" = "Hair Color", "kind" = "color", "value" = hair_entry.hair_color))
			if(hair_choice.natgrad)
				var/datum/hair_gradient/nat_gradient = HAIR_GRADIENT(hair_entry.natural_gradient)
				fields += list(list("key" = "natural_gradient", "label" = "Natural Gradient", "kind" = "select", "value" = initial(nat_gradient.name), "options" = hair_gradient_types()))
				if(hair_entry.natural_gradient != /datum/hair_gradient/none)
					fields += list(list("key" = "natural_gradient_color", "label" = "Natural Gradient Color", "kind" = "color", "value" = hair_entry.natural_color))
			if(hair_choice.dyegrad)
				var/datum/hair_gradient/dye_gradient = HAIR_GRADIENT(hair_entry.dye_gradient)
				fields += list(list("key" = "dye_gradient", "label" = "Dye Gradient", "kind" = "select", "value" = initial(dye_gradient.name), "options" = hair_gradient_types()))
				if(hair_entry.dye_gradient != /datum/hair_gradient/none)
					fields += list(list("key" = "dye_gradient_color", "label" = "Dye Gradient Color", "kind" = "color", "value" = hair_entry.dye_color))
		if(istype(choice, /datum/customizer_choice/bodypart_feature/hair/head))
			fields += list(list("key" = "custom_hair_editor", "label" = "Advanced Editor", "kind" = "button", "value" = null))

	return fields

/datum/character_customizers_ui/ui_data(mob/user)
	var/datum/preferences/P = get_prefs()
	var/list/data = list()
	if(!P || !P.pref_species)
		return data

	var/list/customizer_rows = list()
	for(var/customizer_type in P.pref_species.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer.is_allowed(P))
			continue
		var/datum/customizer_entry/entry = P.get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)

		var/list/choice_options = list()
		for(var/choice_type in customizer.customizer_choices)
			var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
			choice_options[iter_choice.name] = choice_type

		var/list/accessory_options = list()
		var/current_accessory_name
		var/list/color_rows = list()
		if(choice.sprite_accessories && entry.accessory_type)
			var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
			current_accessory_name = accessory.name
			for(var/acc_type in choice.sprite_accessories)
				var/datum/sprite_accessory/iter_acc = SPRITE_ACCESSORY(acc_type)
				accessory_options[iter_acc.name] = acc_type
			if(choice.allows_accessory_color_customization && !accessory.color_disabled)
				var/list/color_list = color_string_to_list(entry.accessory_colors)
				for(var/index in 1 to accessory.color_keys)
					var/named_index = (accessory.color_keys == 1) ? accessory.color_key_name : accessory.color_key_names[index]
					color_rows += list(list("index" = index, "label" = named_index, "color" = color_list[index]))

		customizer_rows += list(list(
			"customizer_type" = "[customizer_type]",
			"name" = customizer.name,
			"disabled" = !!entry.disabled,
			"allows_disabling" = !!customizer.allows_disabling,
			"choice_name" = choice.name,
			"choice_options" = length(choice_options) > 1 ? choice_options : list(),
			"accessory_name" = current_accessory_name,
			"accessory_options" = length(accessory_options) > 1 ? accessory_options : list(),
			"allows_accessory_color_customization" = !!choice.allows_accessory_color_customization,
			"color_rows" = color_rows,
			"extra_fields" = build_extra_fields(choice, entry),
		))

	data["customizers"] = customizer_rows
	return data

/datum/character_customizers_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/user = ui.user
	var/datum/preferences/P = get_prefs()
	if(!P)
		return TRUE

	var/customizer_type = text2path(params["customizer_type"])
	if(!customizer_type)
		return TRUE
	var/datum/customizer_entry/entry = P.get_customizer_entry_for_customizer_type(customizer_type)
	if(!entry)
		return TRUE
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)

	switch(action)
		if("toggle_missing")
			if(customizer.allows_disabling)
				entry.disabled = !entry.disabled

		if("set_choice")
			var/list/choice_options = list()
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_options[iter_choice.name] = choice_type
			var/new_choice_type = choice_options[params["value"]]
			if(!new_choice_type || (new_choice_type == choice.type))
				return TRUE
			P.customizer_entries -= entry
			P.customizer_entries += customizer.create_customizer_entry(P, new_choice_type)

		if("set_accessory")
			if(!choice.sprite_accessories)
				return TRUE
			var/list/accessory_options = list()
			for(var/acc_type in choice.sprite_accessories)
				var/datum/sprite_accessory/iter_acc = SPRITE_ACCESSORY(acc_type)
				accessory_options[iter_acc.name] = acc_type
			var/new_acc_type = accessory_options[params["value"]]
			if(!new_acc_type)
				return TRUE
			choice.set_accessory_type(P, new_acc_type, entry)

		if("set_accessory_color")
			if(!choice.sprite_accessories || !choice.allows_accessory_color_customization)
				return TRUE
			var/index = text2num(params["index"])
			var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
			if(!index || (index > accessory.color_keys))
				return TRUE
			var/new_color = params["color"]
			if(!new_color)
				return TRUE
			var/list/color_list = color_string_to_list(entry.accessory_colors)
			color_list[index] = sanitize_hexcolor(new_color, 6, TRUE)
			entry.accessory_colors = color_list_to_string(color_list)

		if("reset_colors")
			if(!choice.sprite_accessories || !choice.allows_accessory_color_customization)
				return TRUE
			choice.reset_accessory_colors(P, entry)

		// ── Extra fields shared across the few non-generic customizer types ──
		if("set_extra_toggle")
			var/key = params["key"]
			if(istype(choice, /datum/customizer_choice/organ/eyes) && (key == "heterochromia"))
				var/datum/customizer_entry/organ/eyes/eyes_entry = entry
				var/datum/customizer_choice/organ/eyes/eyes_choice = choice
				if(eyes_choice.allows_heterochromia)
					eyes_entry.heterochromia = !eyes_entry.heterochromia
			else if(istype(choice, /datum/customizer_choice/organ/penis) && (key == "functional"))
				var/datum/customizer_entry/organ/penis/penis_entry = entry
				penis_entry.functional = !penis_entry.functional
			else if(istype(choice, /datum/customizer_choice/organ/testicles) && (key == "virile"))
				var/datum/customizer_entry/organ/testicles/testicles_entry = entry
				testicles_entry.virility = !testicles_entry.virility
			else if(istype(choice, /datum/customizer_choice/organ/breasts) && (key == "lactating"))
				var/datum/customizer_entry/organ/breasts/breasts_entry = entry
				breasts_entry.lactating = !breasts_entry.lactating
			else if(istype(choice, /datum/customizer_choice/organ/vagina) && (key == "fertile"))
				var/datum/customizer_entry/organ/vagina/vagina_entry = entry
				vagina_entry.fertility = !vagina_entry.fertility

		if("set_extra_color")
			var/key = params["key"]
			var/new_color = params["color"]
			if(!new_color)
				return TRUE
			if(istype(choice, /datum/customizer_choice/organ/eyes))
				var/datum/customizer_entry/organ/eyes/eyes_entry = entry
				if(key == "eye_color")
					eyes_entry.eye_color = sanitize_hexcolor(new_color, 6, TRUE)
				else if(key == "second_eye_color")
					eyes_entry.second_color = sanitize_hexcolor(new_color, 6, TRUE)
			else if(istype(choice, /datum/customizer_choice/bodypart_feature/hair))
				var/datum/customizer_entry/hair/hair_entry = entry
				if(key == "hair_color")
					hair_entry.hair_color = sanitize_hexcolor(new_color, 6, TRUE)
					P.clear_hair_cache(customizer_type)
					var/list/colors = hair_colors(hair_entry)
					hair_entry.pix_color = (hair_entry.pix_color in colors) ? hair_entry.pix_color : colors[1]
				else if(key == "natural_gradient_color")
					hair_entry.natural_color = sanitize_hexcolor(new_color, 6, TRUE)
					P.clear_hair_cache(customizer_type)
				else if(key == "dye_gradient_color")
					hair_entry.dye_color = sanitize_hexcolor(new_color, 6, TRUE)
					P.clear_hair_cache(customizer_type)

		if("set_extra_select")
			var/key = params["key"]
			var/value = params["value"]
			if(istype(choice, /datum/customizer_choice/organ/penis) && (key == "penis_size"))
				var/datum/customizer_entry/organ/penis/penis_entry = entry
				var/new_size = PENIS_SIZES_BY_NAME[value]
				if(!isnull(new_size))
					penis_entry.penis_size = sanitize_integer(new_size, MIN_PENIS_SIZE, MAX_PENIS_SIZE, DEFAULT_PENIS_SIZE)
			else if(istype(choice, /datum/customizer_choice/organ/testicles) && (key == "ball_size"))
				var/datum/customizer_entry/organ/testicles/testicles_entry = entry
				var/new_size = TESTICLE_SIZES_BY_NAME[value]
				if(!isnull(new_size))
					testicles_entry.ball_size = sanitize_integer(new_size, MIN_TESTICLES_SIZE, MAX_TESTICLES_SIZE, DEFAULT_TESTICLES_SIZE)
			else if(istype(choice, /datum/customizer_choice/organ/breasts) && (key == "breast_size"))
				var/datum/customizer_entry/organ/breasts/breasts_entry = entry
				var/new_size = BREAST_SIZES_BY_NAME[value]
				if(!isnull(new_size))
					breasts_entry.breast_size = sanitize_integer(new_size, MIN_BREASTS_SIZE, MAX_BREASTS_SIZE, DEFAULT_BREASTS_SIZE)
			else if(istype(choice, /datum/customizer_choice/bodypart_feature/hair) && (key == "natural_gradient"))
				var/datum/customizer_entry/hair/hair_entry = entry
				var/list/choice_list = hair_gradient_types()
				var/new_gradient = choice_list[value]
				if(new_gradient)
					hair_entry.natural_gradient = new_gradient
					P.clear_hair_cache(customizer_type)
			else if(istype(choice, /datum/customizer_choice/bodypart_feature/hair) && (key == "dye_gradient"))
				var/datum/customizer_entry/hair/hair_entry = entry
				var/list/choice_list = hair_gradient_types()
				var/new_gradient = choice_list[value]
				if(new_gradient)
					hair_entry.dye_gradient = new_gradient
					P.clear_hair_cache(customizer_type)

		if("set_extra_button")
			var/key = params["key"]
			if(istype(choice, /datum/customizer_choice/bodypart_feature/hair/head) && (key == "custom_hair_editor"))
				P.open_hair_editor(user, customizer_type)

	if(ishuman(user))
		var/mob/living/carbon/human/humanized = user
		humanized.update_body_parts(TRUE)
	if(get_prefs()?.dreamvalley_character_sheet_ui)
		get_prefs().dreamvalley_character_sheet_ui.mark_preview_dirty()
	return TRUE
