/client/proc/cmd_admin_set_outpost_name()
	set category = "Admin"
	set name = "Set Outpost Name"
	set desc = "Set the settlement name and faction/company name for this round."

	if(!check_rights(R_ADMIN))
		return

	var/new_realm_name = input(usr, "Settlement name (shown as the location name)", "Set Outpost Name", SSticker.realm_name) as null|text
	if(!isnull(new_realm_name))
		new_realm_name = trim(new_realm_name)
		if(length(new_realm_name))
			SSticker.realm_name = new_realm_name

	var/new_faction_name = input(usr, "Faction/company name (shown in trade and treasury flavor)", "Set Outpost Name", SSticker.faction_name) as null|text
	if(!isnull(new_faction_name))
		new_faction_name = trim(new_faction_name)
		if(length(new_faction_name))
			SSticker.faction_name = new_faction_name

	log_admin("[key_name(usr)] set outpost name to '[SSticker.realm_name]', faction name to '[SSticker.faction_name]'.")
	message_admins("[key_name_admin(usr)] set outpost name to '[SSticker.realm_name]', faction name to '[SSticker.faction_name]'.")
