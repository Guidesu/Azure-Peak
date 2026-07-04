#define COMMAND_BAR_MATCH_NONE 0
#define COMMAND_BAR_MATCH_VISIBLE 1
#define COMMAND_BAR_MATCH_BLOCKED 2

/client/verb/toggle_command_bar_button()
	set name = "toggle-command-bar-button"
	set hidden = TRUE

	var/current = winget(src, "outputwindow.input", "command")
	if(current == "say")
		set_command_bar_mode(FALSE)
	else
		set_command_bar_mode(TRUE)

/client/verb/run_visible_commandbar_command(command as command_text)
	set name = "visible-command-bar"
	set hidden = TRUE

	if(holder)
		winset(src, null, list2params(list("command" = command)))
		return

	if(!can_run_visible_commandbar_command(command))
		to_chat(src, span_warning("That command is not available on my command panel."))
		return

	winset(src, null, list2params(list("command" = command)))

/client/proc/set_command_bar_mode(say_mode = TRUE)
	if(say_mode)
		winset(src, "outputwindow.input", "command=say")
		winset(src, "outputwindow.saybutton", "text=Say;is-checked=true")
		to_chat(src, span_notice("Command bar set to <b>SAY</b> mode. All input goes to say."))
	else
		var/input_command = holder ? "" : "visible-command-bar"
		winset(src, "outputwindow.input", "command=[input_command]")
		winset(src, "outputwindow.saybutton", "text=Cmd;is-checked=false")
		if(holder)
			to_chat(src, span_notice("Command bar set to <b>COMMAND</b> mode. Type verbs directly (e.g. say, adminhelp, ooc)."))
		else
			to_chat(src, span_notice("Command bar set to <b>COMMAND</b> mode. Only commands shown on my command panel can be used."))

/client/proc/show_command_bar_button()
	winset(src, "outputwindow.saybutton", "is-visible=true")
	winset(src, "outputwindow.input", "anchor2=92,100")

/client/proc/hide_command_bar_button()
	winset(src, "outputwindow.saybutton", "is-visible=false")
	winset(src, "outputwindow.input", "anchor2=100,100")
	set_command_bar_mode(TRUE)

/client/proc/check_localhost_command_bar()
	show_command_bar_button()
	var/localhost_addresses = list("127.0.0.1", "::1")
	if(isnull(address) || (address in localhost_addresses))
		set_command_bar_mode(FALSE)
		to_chat(src, span_notice("Localhost detected — command bar set to <b>COMMAND</b> mode automatically."))

/client/proc/can_run_visible_commandbar_command(command)
	var/command_name = get_commandbar_command_name(command)
	if(!command_name)
		return FALSE

	var/found_visible_verb = FALSE
	for(var/verb_entry in verbs)
		var/procpath/verb_path = verb_entry
		var/match_result = commandbar_verb_match_result(verb_path, command_name)
		if(match_result == COMMAND_BAR_MATCH_BLOCKED)
			return FALSE
		if(match_result == COMMAND_BAR_MATCH_VISIBLE)
			found_visible_verb = TRUE

	if(mob)
		for(var/verb_entry in mob.verbs)
			var/procpath/verb_path = verb_entry
			var/match_result = commandbar_verb_match_result(verb_path, command_name)
			if(match_result == COMMAND_BAR_MATCH_BLOCKED)
				return FALSE
			if(match_result == COMMAND_BAR_MATCH_VISIBLE)
				found_visible_verb = TRUE

	return found_visible_verb

/client/proc/get_commandbar_command_name(command)
	if(!command)
		return
	command = trim(command)
	if(!length(command))
		return

	var/space = findtext(command, " ")
	if(space)
		command = copytext(command, 1, space)

	return normalize_commandbar_command_name(command)

/client/proc/commandbar_verb_match_result(procpath/verb_path, command_name)
	if(!verb_path)
		return COMMAND_BAR_MATCH_NONE
	if(!verb_path.name)
		return COMMAND_BAR_MATCH_NONE
	if(normalize_commandbar_command_name(verb_path.name) != command_name)
		return COMMAND_BAR_MATCH_NONE
	if(verb_path.hidden)
		return COMMAND_BAR_MATCH_BLOCKED
	if(!verb_path.category)
		return COMMAND_BAR_MATCH_BLOCKED
	if(verb_path.invisibility && (!mob || (mob.see_invisible < verb_path.invisibility)))
		return COMMAND_BAR_MATCH_BLOCKED

	return COMMAND_BAR_MATCH_VISIBLE

/proc/normalize_commandbar_command_name(command_name)
	command_name = lowertext(trim(command_name))
	return replacetext(command_name, " ", "-")

#undef COMMAND_BAR_MATCH_NONE
#undef COMMAND_BAR_MATCH_VISIBLE
#undef COMMAND_BAR_MATCH_BLOCKED
