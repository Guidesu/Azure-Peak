/**
 * Forecast datums drive which particle_weather is likely to occur, per map, per time-of-day.
 *
 * SSParticleWeather picks one /datum/forecast subtype at Initialize() based on SSmapping.config.map_name,
 * then calls check_forecast(time_of_day) whenever GLOB.tod changes (see code/__HELPERS/time.dm settod()).
 * This replaces the old hardcoded switch(GLOB.tod) block that used to live directly in settod().
 */
/datum/forecast
	var/name = "Base Forecast"

	/// Weighted weather pools (weather type path = weight) for each time-of-day bucket.
	var/list/dusk_weather = list()
	var/list/day_weather = list()
	var/list/night_weather = list()
	var/list/dawn_weather = list()

	/// Chance (0-100) that ANY weather is rolled at all for this time-of-day bucket.
	var/dawn_prob = 35
	var/day_prob = 25
	var/night_prob = 35
	var/dusk_prob = 35

/**
 * Rolls whether weather should occur for the given time_of_day ("dawn"/"day"/"dusk"/"night"),
 * and if so, weighted-picks a /datum/particle_weather subtype from the matching pool.
 *
 * Returns null if no weather should occur (caller should not touch the running/queued weather).
 */
/datum/forecast/proc/pick_weather(time_of_day)
	var/list/weather_pool	//Copy so storyteller-conditional bonus entries don't leak into the base list

	switch(time_of_day)
		if("dusk")
			if(!prob(dusk_prob))
				return
			weather_pool = dusk_weather.Copy()

		if("night")
			if(!prob(night_prob))
				return
			weather_pool = night_weather.Copy()
			// NOTE: "Zizo"/"Graggar" are upstream Ratwood-2.0 storyteller names that don't currently
			// exist in this repo's pantheon (code/datums/storytellers/gods.dm) - left as harmless
			// dead branches in case those storytellers get ported later. Blood rain itself works fine
			// via the normal weighted pool regardless.
			if(SSgamemode.current_storyteller?.name == "Zizo" || SSgamemode.current_storyteller?.name == "Graggar")
				weather_pool[/datum/particle_weather/blood_rain_storm] = 10

		if("dawn")
			if(!prob(dawn_prob))
				return
			weather_pool = dawn_weather.Copy()
			// NOTE: "Eora" - see above, not currently a storyteller in this repo.
			if(SSgamemode.current_storyteller?.name == "Eora")
				weather_pool[/datum/particle_weather/sakura_gentle] = 10

		if("day")
			if(!prob(day_prob))
				return
			weather_pool = day_weather.Copy()

			if(SSgamemode.current_storyteller?.name == "Eora")
				weather_pool[/datum/particle_weather/sakura_gentle] = 10

			// Hurricane/tornado weather intentionally not ported - excluded from this project's scope.

	if(!weather_pool || !length(weather_pool))
		return

	return pickweight(weather_pool)
