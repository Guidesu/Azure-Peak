// Manor preference vars (used by DreamValley campaign UI)
/datum/preferences
	var/have_manor = FALSE
	var/manor_name = ""
	var/manor_type = "manor"
	var/check_manor_pref = FALSE

// Stub for manor production cycle - called from time.dm
/proc/process_manor_production_cycle(dawn_tick = FALSE, dusk_tick = FALSE)
	return

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
