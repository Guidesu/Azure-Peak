/*
	Lunar Cycle System for DreamValley

	The Vaeltic Calendar's 28-day month maps perfectly to a lunar cycle:
	Day 1  = New Moon
	Day 7  = First Quarter
	Day 14 = Full Moon
	Day 21 = Last Quarter
	Day 28 = New Moon (cycle repeats)

	Blood Moons occur on ~15% of full moons. During a blood moon:
	- NPC werewolves spawn in forests/wilderness
	- NPC gnolls spawn in appropriate regions
	- Blood rain weather is more likely
	- Players get a special dawn announcement

	GLOB.moon_phase is updated at dawn in settod() -> update_moon_phase()
*/

GLOBAL_VAR_INIT(moon_phase, MOON_PHASE_NEW)
GLOBAL_VAR_INIT(is_blood_moon, FALSE)
GLOBAL_VAR_INIT(full_moon_count, 0) // Tracks how many full moons have occurred for blood moon rolling

/// Returns the moon phase string for a given day-of-month (1-28)
/proc/get_moon_phase(day_of_month)
	if(!day_of_month)
		day_of_month = 1
	day_of_month = MODULUS((day_of_month - 1), LUNAR_CYCLE_DAYS) + 1
	switch(day_of_month)
		if(1)
			return MOON_PHASE_NEW
		if(2 to 6)
			return MOON_PHASE_WAXING_CRESCENT
		if(7)
			return MOON_PHASE_FIRST_QUARTER
		if(8 to 13)
			return MOON_PHASE_WAXING_GIBBOUS
		if(14)
			return MOON_PHASE_FULL
		if(15 to 20)
			return MOON_PHASE_WANING_GIBBOUS
		if(21)
			return MOON_PHASE_LAST_QUARTER
		if(22 to 27)
			return MOON_PHASE_WANING_CRESCENT
		if(28)
			return MOON_PHASE_NEW
	return MOON_PHASE_NEW

/// Returns a human-readable name for a moon phase
/proc/get_moon_phase_name(phase)
	switch(phase)
		if(MOON_PHASE_NEW)
			return "New Moon"
		if(MOON_PHASE_WAXING_CRESCENT)
			return "Waxing Crescent"
		if(MOON_PHASE_FIRST_QUARTER)
			return "First Quarter"
		if(MOON_PHASE_WAXING_GIBBOUS)
			return "Waxing Gibbous"
		if(MOON_PHASE_FULL)
			return "Full Moon"
		if(MOON_PHASE_WANING_GIBBOUS)
			return "Waning Gibbous"
		if(MOON_PHASE_LAST_QUARTER)
			return "Last Quarter"
		if(MOON_PHASE_WANING_CRESCENT)
			return "Waning Crescent"
	return "Unknown"

/// Returns TRUE if the current moon phase is a full moon
/proc/is_full_moon()
	return GLOB.moon_phase == MOON_PHASE_FULL

/// Returns TRUE if the current moon phase is a new moon
/proc/is_new_moon()
	return GLOB.moon_phase == MOON_PHASE_NEW

/// Called from settod() at dawn to update the moon phase and roll for blood moon
/proc/update_moon_phase()
	var/list/parts = resolve_ic_date_parts(GLOB.dayspassed)
	var/day_of_month = parts[1]
	var/new_phase = get_moon_phase(day_of_month)
	var/old_phase = GLOB.moon_phase

	if(new_phase == old_phase)
		return

	GLOB.moon_phase = new_phase

	// Roll for blood moon on full moon
	if(new_phase == MOON_PHASE_FULL && old_phase != MOON_PHASE_FULL)
		GLOB.full_moon_count++
		var/was_blood_moon = GLOB.is_blood_moon
		GLOB.is_blood_moon = prob(BLOOD_MOON_CHANCE)

		if(GLOB.is_blood_moon)
			announce_blood_moon()
			SSwildlife?.on_blood_moon()
		else if(was_blood_moon)
			// Blood moon has ended
			GLOB.is_blood_moon = FALSE

	// Announce full moon (non-blood) for werewolf players
	if(new_phase == MOON_PHASE_FULL && !GLOB.is_blood_moon)
		scom_announce("The moon hangs full and pale in the sky. The beasts stir.")
	else if(new_phase == MOON_PHASE_NEW)
		scom_announce("The moon is dark. The night is blind.")

/// Sends a world-wide announcement about the blood moon
/proc/announce_blood_moon()
	scom_announce("The moon rises red as blood. Something wicked hunts tonight.")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat != DEAD && H.client)
			H.playsound_local(get_turf(H), 'sound/blank.ogg', 60, FALSE, pressure_affected = FALSE)
