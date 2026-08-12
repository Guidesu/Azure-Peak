/datum/config_entry/string/admin_bans_channel
	default = null

/datum/config_entry/string/admin_bans_channel2
	default = null

/datum/config_entry/string/admin_notes_channel
	default = null

// TODO: Review each proc. They need to be simplified per DRY.

/world/proc/create_discord_embed_footer()
	return new /datum/tgs_chat_embed/footer(
		"[GLOB.rogue_round_id] / [time2text(world.timeofday, "DD.MM.YYYY hh:mm:ss", world.timezone)]"
	)

/world/proc/split_discord_log_text(text, max_length = 1900)
	var/list/chunks = list()
	var/remaining = "[text]"
	while(length_char(remaining) > max_length)
		var/cut_position = max_length + 1
		var/minimum_position = max(1, max_length - 250)
		for(var/newline_index = max_length; newline_index >= minimum_position; newline_index--)
			if(copytext_char(remaining, newline_index, newline_index + 1) == "\n")
				cut_position = newline_index + 1
				break
		if(cut_position == max_length + 1)
			for(var/space_index = max_length; space_index >= minimum_position; space_index--)
				if(copytext_char(remaining, space_index, space_index + 1) == " ")
					cut_position = space_index + 1
					break
		var/chunk = trim(copytext_char(remaining, 1, cut_position))
		if(length(chunk))
			chunks += chunk
		remaining = trim(copytext_char(remaining, cut_position))
	if(length(remaining))
		chunks += remaining
	return chunks

/world/proc/send_discord_ban_log(title, description, colour, player_ckey, admin_ckey, reason, admin_bans_channel, admin_bans_channel2)
	var/full_text = "[description]\n\n**:** `[player_ckey]`\n**:** `[admin_ckey]`\n**:**\n[reason]"
	if(length_char(full_text) <= 1900 && length_char(reason) <= 1000)
		var/datum/tgs_chat_embed/structure/embed = new()
		embed.title = title
		embed.description = description
		embed.colour = colour
		embed.footer = create_discord_embed_footer()
		var/datum/tgs_chat_embed/field/field_player_ckey = new(
			"", "`[player_ckey]`"
		)
		var/datum/tgs_chat_embed/field/field_admin_ckey = new(
			"", "`[admin_ckey]`"
		)
		var/datum/tgs_chat_embed/field/field_reason = new(
			"", "[copytext_char(reason, 1)]"
		)
		field_player_ckey.is_inline = TRUE
		field_admin_ckey.is_inline = TRUE
		field_reason.is_inline = FALSE
		embed.fields = list(
			field_player_ckey,
			field_admin_ckey,
			field_reason,
		)
		var/datum/tgs_message_content/message = new("")
		message.embed = embed
		if(admin_bans_channel)
			send2chat(message, admin_bans_channel)
		if(admin_bans_channel2)
			send2chat(message, admin_bans_channel2)
		return
	var/list/chunks = split_discord_log_text(full_text)
	for(var/index in 1 to chunks.len)
		var/datum/tgs_chat_embed/structure/embed = new()
		if(index == 1)
			embed.title = title
		embed.description = chunks[index]
		embed.colour = colour
		if(index == chunks.len)
			embed.footer = create_discord_embed_footer()
		var/datum/tgs_message_content/message = new("")
		message.embed = embed
		if(admin_bans_channel)
			send2chat(message, admin_bans_channel)
		if(admin_bans_channel2)
			send2chat(message, admin_bans_channel2)

/// Sends a TGS message about a player or role block.
/world/proc/TgsAnnounceBan(player_ckey, admin_ckey, duration, time_message, roles, reason, severity, applies_to_admins)
	if(!TgsAvailable())
		return

	var/admin_bans_channel = CONFIG_GET(string/admin_bans_channel)
	var/admin_bans_channel2 = CONFIG_GET(string/admin_bans_channel2)


	if(!admin_bans_channel && !admin_bans_channel2)
		return

	var/severity_dict = list(
		"high" = "",
		"medium" = "",
		"minor" = "",
		"none" = "None",
	)

	var/is_role_ban = roles[1] != "Server"

	var/title = is_role_ban ? " " : ""
	var/description = "     ."

	if(is_role_ban)
		var/list/role_lines = list()
		for(var/role_name in roles)
			role_lines += "• `[role_name]`"
		description = "     :\n[role_lines.Join("\n")]"

	description += "\n"

	var/localized_severity = severity_dict[lowertext(severity)]
	if(localized_severity != "none")
		description += "** :** [localized_severity]\n"

	description += "** :** [duration ? time_message : "FOREVER"]"

	if(applies_to_admins)
		description += "\n*  *"

	send_discord_ban_log(
		title,
		description,
		"#ed8796",
		player_ckey,
		admin_ckey,
		reason,
		admin_bans_channel,
		admin_bans_channel2,
	)

/// Sends a TGS Discord message about a player PQ change.
/world/proc/TgsAnnouncePQChanges(value, player_ckey, admin_ckey, reason)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)

	if(!admin_notes_channel)
		return

	var/datum/tgs_chat_embed/structure/embed = new()
	embed.title = " PQ"
	embed.description = reason ? "****\n" + reason : "  !"
	embed.colour = value > 0 ? "#a6da95" : "#ed8796"
	embed.footer = create_discord_embed_footer()

	var/datum/tgs_chat_embed/field/field_player_ckey = new(
		"", "`[player_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_admin_ckey = new(
		"", "`[admin_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_changed_value = new(
		" ", "`[value]`"
	)

	field_player_ckey.is_inline = TRUE
	field_admin_ckey.is_inline = TRUE
	field_changed_value.is_inline = TRUE

	embed.fields = list(
		field_player_ckey,
		field_admin_ckey,
		field_changed_value,
	)

	var/datum/tgs_message_content/message = new("")
	message.embed = embed

	send2chat(
		message,
		admin_notes_channel
	)


/world/proc/TgsAnnounceTriumphChanges(value, player_ckey, admin_ckey, reason)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)

	if(!admin_notes_channel)
		return

	var/datum/tgs_chat_embed/structure/embed = new()
	embed.title = " "
	embed.description = reason ? "****\n" + reason : "  !"
	embed.colour = value > 0 ? "#a6da95" : "#ed8796"
	embed.footer = create_discord_embed_footer()

	var/datum/tgs_chat_embed/field/field_player_ckey = new(
		"", "`[player_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_admin_ckey = new(
		"", "`[admin_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_changed_value = new(
		" ", "`[value]`"
	)

	field_player_ckey.is_inline = TRUE
	field_admin_ckey.is_inline = TRUE
	field_changed_value.is_inline = TRUE

	embed.fields = list(
		field_player_ckey,
		field_admin_ckey,
		field_changed_value,
	)

	var/datum/tgs_message_content/message = new("")
	message.embed = embed

	send2chat(
		message,
		admin_notes_channel
	)

/world/proc/TgsAnnounceNote(note, player_ckey, admin_ckey)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)

	if(!admin_notes_channel)
		return

	var/datum/tgs_chat_embed/structure/embed = new()
	embed.title = "PQ Note"
	embed.description = note
	embed.colour = "#8aadf4"
	embed.footer = create_discord_embed_footer()

	var/datum/tgs_chat_embed/field/field_player_ckey = new(
		"", "`[player_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_admin_ckey = new(
		"", "`[admin_ckey]`"
	)

	field_player_ckey.is_inline = TRUE
	field_admin_ckey.is_inline = TRUE

	embed.fields = list(
		field_player_ckey,
		field_admin_ckey,
	)

	var/datum/tgs_message_content/message = new("")
	message.embed = embed

	send2chat(
		message,
		admin_notes_channel
	)

/world/proc/TgsAnnounceAdminMessageEntry(admin_ckey, target_key, type, text, secret, expiry)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)

	if(!admin_notes_channel)
		return

	var/datum/tgs_chat_embed/structure/embed = new()
	embed.title = capitalize(type)
	embed.description = text
	embed.colour = "#ef9f76"
	embed.footer = create_discord_embed_footer()

	var/datum/tgs_chat_embed/field/field_player_ckey = new(
		"", "`[target_key]`"
	)

	var/datum/tgs_chat_embed/field/field_admin_ckey = new(
		"", "`[admin_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_secret = new(
		"Secret?", "[secret ? "Yes" : "No"]"
	)

	field_player_ckey.is_inline = TRUE
	field_admin_ckey.is_inline = TRUE
	field_secret.is_inline = TRUE

	embed.fields = list(
		field_player_ckey,
		field_admin_ckey,
		field_secret,
	)

	if(expiry)
		embed.fields.Add(new /datum/tgs_chat_embed/field("", "[expiry]"))

	var/datum/tgs_message_content/message = new("")
	message.embed = embed

	send2chat(
		message,
		admin_notes_channel
	)

/world/proc/TgsAnnounceUnban(player_ckey, admin_ckey, roles, reason)
	if(!TgsAvailable())
		return

	var/admin_bans_channel = CONFIG_GET(string/admin_bans_channel)
	var/admin_bans_channel2 = CONFIG_GET(string/admin_bans_channel2)

	if(!admin_bans_channel && !admin_bans_channel2)
		return

	var/list/unbanned_roles
	if(islist(roles))
		var/list/role_list = roles
		unbanned_roles = role_list.Copy()
	else
		unbanned_roles = list(roles)
	var/list/non_server_roles = list()
	var/server_unban = FALSE
	for(var/role in unbanned_roles)
		if(lowertext("[role]") == "server")
			server_unban = TRUE
		else
			non_server_roles |= role
	var/list/role_lines = list()
	for(var/role in non_server_roles)
		role_lines += "• `[role]`"
	var/description
	if(server_unban && !length(non_server_roles))
		description = "    !"
	else if(server_unban)
		description = "    !\n\n     :\n[role_lines.Join("\n")]"
	else if(length(non_server_roles) == 1)
		description = "      `[non_server_roles[1]]`!"
	else
		description = "     :\n[role_lines.Join("\n")]"

	send_discord_ban_log(
		"",
		description,
		"#a6da95",
		player_ckey,
		admin_ckey,
		reason,
		admin_bans_channel,
		admin_bans_channel2,
	)

/world/proc/TgsAnnounceBanEdit(player_ckey, admin_ckey, list/changes)
	if(!TgsAvailable() || !length(changes))
		return

	var/admin_bans_channel = CONFIG_GET(string/admin_bans_channel)
	var/admin_bans_channel2 = CONFIG_GET(string/admin_bans_channel2)

	if(!admin_bans_channel && !admin_bans_channel2)
		return

	var/list/change_names = list(
		"Key" = "",
		"IP" = "IP",
		"CID" = "CID",
		"Applies to admins" = "  ",
		"Duration" = "",
		"Reason" = "",
	)
	var/list/change_lines = list()
	for(var/change_key in changes)
		var/change_name = change_names[change_key]
		if(!change_name)
			change_name = change_key
		var/change_value = replacetext("[changes[change_key]]", "<br>", "\n")
		change_lines += "**[change_name]:**\n[change_value]"

	var/full_text = "**:** `[player_ckey]`\n**:** `[admin_ckey]`\n\n[change_lines.Join("\n\n")]"
	var/list/chunks = split_discord_log_text(full_text)
	for(var/index in 1 to chunks.len)
		var/datum/tgs_chat_embed/structure/embed = new()
		if(index == 1)
			embed.title = " "
		embed.description = chunks[index]
		embed.colour = "#f5a97f"
		if(index == chunks.len)
			embed.footer = create_discord_embed_footer()

		var/datum/tgs_message_content/message = new("")
		message.embed = embed
		if(admin_bans_channel)
			send2chat(message, admin_bans_channel)
		if(admin_bans_channel2)
			send2chat(message, admin_bans_channel2)

/world/proc/TgsAnnounceAdminMessageEdit(editor_ckey, target_key, author_key, type, old_text, new_text)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)
	if(!admin_notes_channel)
		return

	var/pretty_type
	switch(type)
		if("note")
			pretty_type = ""
		if("message")
			pretty_type = ""
		if("watchlist entry")
			pretty_type = "  watchlist"
		else
			return

	var/old_discord_text = replacetext("[old_text]", "<br>", "\n")
	var/new_discord_text = replacetext("[new_text]", "<br>", "\n")
	var/full_text = "**:** `[target_key]`\n** :** `[author_key]`\n**:** `[editor_ckey]`\n\n**:**\n[old_discord_text]\n\n**:**\n[new_discord_text]"
	var/list/chunks = split_discord_log_text(full_text)
	for(var/index in 1 to chunks.len)
		var/datum/tgs_chat_embed/structure/embed = new()
		if(index == 1)
			embed.title = " [pretty_type]"
		embed.description = chunks[index]
		embed.colour = "#f5a97f"
		if(index == chunks.len)
			embed.footer = create_discord_embed_footer()

		var/datum/tgs_message_content/message = new("")
		message.embed = embed
		send2chat(message, admin_notes_channel)

/world/proc/TgsAnnounceAdminMessageDeletion(admin_ckey, target_key, type, text)
	if(!TgsAvailable())
		return

	var/admin_notes_channel = CONFIG_GET(string/admin_notes_channel)
	if(!admin_notes_channel)
		return

	var/pretty_type = capitalize("[type]")
	var/datum/tgs_chat_embed/structure/embed = new()
	embed.title = " [pretty_type]"
	embed.description = copytext_char("[text]", 1, 4000)
	embed.colour = "#ed8796"
	embed.footer = create_discord_embed_footer()

	var/datum/tgs_chat_embed/field/field_player_ckey = new(
		"", "`[target_key]`"
	)

	var/datum/tgs_chat_embed/field/field_admin_ckey = new(
		"", "`[admin_ckey]`"
	)

	var/datum/tgs_chat_embed/field/field_type = new(
		"", "`[type]`"
	)

	field_player_ckey.is_inline = TRUE
	field_admin_ckey.is_inline = TRUE
	field_type.is_inline = TRUE

	embed.fields = list(
		field_player_ckey,
		field_admin_ckey,
		field_type,
	)

	var/datum/tgs_message_content/message = new("")
	message.embed = embed

	send2chat(message, admin_notes_channel)

// Adjust PQ via discord bot

/datum/world_topic/pq_adjust
	keyword = "pqadjust"

/datum/world_topic/pq_adjust/Run(list/input)
	var/admin_ckey = ckey(input["admin"])
	var/target_ckey = ckey(input["ckey"])
	var/amount = text2num(input["amount"])
	var/reason = trim(input["reason"])

	if(!admin_ckey)
		return list("status" = "error", "message" = "Admin ckey is empty.")
	if(!can_adjust_playerquality_by_admin_ckey(admin_ckey))
		return list("status" = "error", "message" = "No rights to adjust PQ.")
	if(!target_ckey)
		return list("status" = "error", "message" = "Target ckey is empty.")
	if(admin_ckey == target_ckey)
		return list("status" = "error", "message" = "  PQ  .")
	if(isnull(amount))
		return list("status" = "error", "message" = "Amount is invalid.")
	amount = round(amount)
	if(amount < -20 || amount > 20)
		return list("status" = "error", "message" = "Amount must be between -20 and 20.")
	if(amount != 0 && !reason)
		return list("status" = "error", "message" = "Reason is required.")
	if(length_char(reason) > 500)
		reason = copytext_char(reason, 1, 501)

	var/folder_prefix = copytext(target_ckey, 1, 2)
	var/full_path = "data/player_saves/[folder_prefix]/[target_ckey]/preferences.sav"
	if(!fexists(full_path))
		return list("status" = "error", "message" = "User does not exist.")

	var/old_pq = get_playerquality(target_ckey, FALSE)
	adjust_playerquality(amount, target_ckey, admin_ckey, reason)
	var/new_pq = get_playerquality(target_ckey, FALSE)

	for(var/client/C in GLOB.clients)
		if(C.ckey == target_ckey)
			to_chat(C, "<span class='admin'><span class='prefix'>ADMIN LOG:</span> <span class='message linkify'>Your PQ has been adjusted by [amount] by [admin_ckey] for reason: [reason]</span></span>")
			break

	return list("status" = "ok", "ckey" = target_ckey, "admin" = admin_ckey, "amount" = amount, "old_pq" = old_pq, "new_pq" = new_pq)
