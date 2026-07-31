// Native TGUI rebuild of the classic Descriptors popup (show_descriptors_ui /
// handle_descriptors_topic in preferences_descriptors.dm). Two uniform
// shapes: a dropdown per species descriptor_choice, and a fixed-size list of
// custom descriptor slots (optional prefix dropdown + free-text content).

/datum/preferences
	var/datum/character_descriptors_ui/dreamvalley_descriptors_ui

/datum/preferences/proc/dreamvalley_open_descriptors_ui(mob/user)
	if(!dreamvalley_descriptors_ui)
		dreamvalley_descriptors_ui = new(user.client)
	dreamvalley_descriptors_ui.ui_interact(user)

/datum/character_descriptors_ui
	var/client/owner

/datum/character_descriptors_ui/New(client/C)
	owner = C

/datum/character_descriptors_ui/Destroy()
	owner = null
	return ..()

/datum/character_descriptors_ui/proc/get_prefs()
	RETURN_TYPE(/datum/preferences)
	return owner?.prefs

/datum/character_descriptors_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_descriptors_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterDescriptors", "Describe Myself")
		ui.open()

/datum/character_descriptors_ui/ui_data(mob/user)
	var/datum/preferences/P = get_prefs()
	var/list/data = list()
	if(!P || !P.pref_species)
		return data

	var/list/choice_rows = list()
	for(var/choice_type in P.pref_species.descriptor_choices)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
		var/datum/descriptor_entry/entry = P.get_descriptor_entry_for_choice(choice_type)
		if(!entry)
			continue
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(entry.descriptor_type)
		var/list/options = list()
		for(var/desc_type in choice.descriptors)
			var/datum/mob_descriptor/iter_descriptor = MOB_DESCRIPTOR(desc_type)
			options[iter_descriptor.name] = desc_type
		choice_rows += list(list(
			"choice_type" = "[choice_type]",
			"name" = choice.name,
			"current" = descriptor.name,
			"options" = options,
		))
	data["choices"] = choice_rows

	var/static/list/full_translation = CUSTOM_PREFIX_TRANSLATION_LIST
	var/static/list/article_translation = CUSTOM_ARTICLE_TRANSLATION_LIST
	var/static/list/full_input = CUSTOM_PREFIX_INPUT_LIST
	var/static/list/article_input = CUSTOM_ARTICLE_INPUT_LIST
	var/static/list/custom_descriptor_types = CUSTOM_DESCRIPTOR_TYPE_LIST
	var/static/list/prefix_support = CUSTOM_DESCRIPTOR_SHOWS_PREFIX
	var/static/list/article_only_types = CUSTOM_DESCRIPTOR_ARTICLE_ONLY

	var/list/custom_rows = list()
	for(var/i in 1 to CUSTOM_DESCRIPTOR_AMOUNT)
		var/desc_type = custom_descriptor_types[i]
		if(!P.has_descriptor_type_in_entries(desc_type))
			continue
		var/datum/custom_descriptor_entry/custom_entry = P.custom_descriptors[i]
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
		var/has_prefix = (desc_type in prefix_support)
		var/is_article_only = (desc_type in article_only_types)
		var/prefix_display
		var/list/prefix_options
		if(has_prefix)
			var/translation = is_article_only ? article_translation : full_translation
			prefix_options = is_article_only ? article_input : full_input
			prefix_display = translation["[custom_entry.prefix_type]"]
			if(!prefix_display)
				prefix_display = is_article_only ? "a" : "Has a"
		custom_rows += list(list(
			"index" = i,
			"name" = descriptor.name,
			"has_prefix" = has_prefix,
			"prefix_display" = prefix_display,
			"prefix_options" = prefix_options || list(),
			"content_text" = custom_entry.content_text,
		))
	data["custom_descriptors"] = custom_rows
	return data

/datum/character_descriptors_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/user = ui.user
	var/datum/preferences/P = get_prefs()
	if(!P)
		return TRUE

	switch(action)
		if("set_descriptor")
			var/choice_type = text2path(params["choice_type"])
			if(!choice_type || !(choice_type in P.pref_species.descriptor_choices))
				return TRUE
			var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
			var/list/options = list()
			for(var/desc_type in choice.descriptors)
				var/datum/mob_descriptor/iter_descriptor = MOB_DESCRIPTOR(desc_type)
				options[iter_descriptor.name] = desc_type
			var/picked_type = options[params["value"]]
			if(!picked_type)
				return TRUE
			var/datum/descriptor_entry/entry = P.get_descriptor_entry_for_choice(choice_type)
			if(entry)
				entry.descriptor_type = picked_type

		if("set_custom_prefix")
			var/static/list/full_input = CUSTOM_PREFIX_INPUT_LIST
			var/static/list/article_input = CUSTOM_ARTICLE_INPUT_LIST
			var/static/list/custom_descriptor_types = CUSTOM_DESCRIPTOR_TYPE_LIST
			var/static/list/article_only_types = CUSTOM_DESCRIPTOR_ARTICLE_ONLY
			var/index = text2num(params["index"])
			if(!index || (index < 1) || (index > length(P.custom_descriptors)))
				return TRUE
			var/datum/custom_descriptor_entry/custom_entry = P.custom_descriptors[index]
			var/is_article_only = (custom_descriptor_types[index] in article_only_types)
			var/input_list = is_article_only ? article_input : full_input
			var/new_prefix_type = input_list[params["value"]]
			if(isnull(new_prefix_type))
				return TRUE
			custom_entry.prefix_type = new_prefix_type

		if("set_custom_content")
			var/index = text2num(params["index"])
			if(!index || (index < 1) || (index > length(P.custom_descriptors)))
				return TRUE
			var/datum/custom_descriptor_entry/custom_entry = P.custom_descriptors[index]
			var/new_content = params["value"]
			if(isnull(new_content))
				return TRUE
			new_content = STRIP_HTML_SIMPLE(lowertext(new_content), CUSTOM_DESCRIPTOR_TEXT_LENGTH)
			custom_entry.content_text = new_content

		if("print_descriptor_setup")
			var/mob/living/temp = new /mob/living(null)
			temp.pronouns = P.pronouns
			P.apply_descriptors(temp)
			var/list/desc_lines = build_cool_description(temp.get_mob_descriptors(FALSE, null), temp)
			qdel(temp)
			var/output = ""
			if(!(user.client?.prefs?.full_examine))
				output = "<details><summary>[span_info("Details")]</summary>"
			for(var/line in desc_lines)
				output += span_info(line)
				output += "<br>"
			if(!(user.client?.prefs?.full_examine))
				if(length(desc_lines))
					output += "</details>"
			to_chat(user, output)

	return TRUE
