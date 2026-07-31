
/mob/living/carbon/human/Stun(amount, updating = TRUE, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, updating = TRUE, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Paralyze(amount, updating = TRUE, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, updating = TRUE, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, updating = 1, ignore_canstun = 0)
	if(!loc || QDELETED(src))
		return FALSE

	if(dna?.species)
		amount = dna.species.spec_stun(src, amount)

	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)

	return ..()

/mob/living/carbon/human/Sleeping(amount, updating = 1, ignore_canstun = 0)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk(source)
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/set_drugginess(amount)
	..()
//	if(!amount)
//		remove_language(/datum/language/beachbum)

/mob/living/carbon/human/adjust_drugginess(amount)
	..()
//	if(!dna.check_mutation(STONER))
//		if(druggy)
//			grant_language(/datum/language/beachbum)
//		else
//			remove_language(/datum/language/beachbum)

/// Map/time-of-day temperature modifier added to outdoor turf temperature in handle_environment().
/// Ported from the Weather & Temperature Overhaul PR; that PR drove this off per-mob time_flags bitflags
/// set by a weather/ToD subsystem this repo doesn't have wired up (out of scope for this port - weather
/// subsystems are untouched). Instead this reads the already-live GLOB.tod ("day"/"night"/"dusk"/"dawn")
/// maintained by settod() in __HELPERS/time.dm, which is simpler and needs no new plumbing.
/mob/living/carbon/human/proc/get_temp_modifier()
	var/modifier = 0
	var/is_day = (GLOB.tod == "day")
	var/is_night = (GLOB.tod == "night")

	// Map-specific adjustments
	if(SSmapping.config.map_name == "Rockhill")	//rockhill temperatures are moderate and wet climate
		if(is_day)
			modifier += 20
		else if(is_night)
			modifier -= 20

	else if(SSmapping.config.map_name == "Desert Town")	//desert map has wild temperature swings
		if(is_day)
			modifier += 100							//300+100 is 400, in the middle of the 'hot' temperature range
		else if(is_night)
			modifier -= 100							//300-100 is 200, in the middle of the 'cold' temperature range

	else if(SSmapping.config.map_name == "Dun World")	//Dunworld is colder than the other two maps
		if(is_day)
			modifier += 0							//No bonus for day time temperatures
		else if(is_night)
			modifier -= 60							//300-60 is 240, just enough for cold temperature outside, but not cold enough to cause hypothermia on water and other problems
	return modifier
