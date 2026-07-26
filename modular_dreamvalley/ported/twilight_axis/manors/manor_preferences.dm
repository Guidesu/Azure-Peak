// Ported from Twilight-Axis, part of the Manors system (see manor.dm).
// The classic preferences.dm chargen links this was originally wired to
// don't exist here (the Character tab was replaced by the TGUI character
// sheet — see modular_dreamvalley/campaign/character_sheet_ui.dm) so these
// fields are exposed there instead; see the ui_data/ui_act additions in
// this same folder.

/datum/preferences
	var/have_manor = TRUE
	var/manor_name = ""
	var/manor_type = "manor"

/datum/preferences/proc/get_manor_type_display_name(type = null)
	if(!type)
		type = manor_type
	switch(type)
		if("hunter_mansion")
			return "Hunter Mansion"
		if("village")
			return "Village"
		if("fisher_hamlet")
			return "Fisher Hamlet"
		if("mining_settlement")
			return "Mining Settlement"
	return "Manor"
