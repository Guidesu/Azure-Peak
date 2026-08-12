//Rockhill is meant to be wet, foggy sort of weather. On occasion, snow, leaves and fireflies.
//Used as the default forecast (see SSParticleWeather Initialize()) for maps without a dedicated forecast, e.g. Hargh.
/datum/forecast/rockhill
	name = "Rockhill"
	day_weather = list(
		/datum/particle_weather/rain_gentle = 25,
		/datum/particle_weather/rain_storm = 20,
		/datum/particle_weather/leaves_gentle = 15,
		/datum/particle_weather/snow_gentle = 10,
		/datum/particle_weather/heat_wave = 10,
		/datum/particle_weather/dry_thunderstorm = 10,
		/datum/particle_weather/fog = 10,
	)
	dawn_weather = list(
		/datum/particle_weather/fog = 20,
		/datum/particle_weather/rain_gentle = 20,
		/datum/particle_weather/fireflies = 15,
		/datum/particle_weather/leaves_gentle = 15,
		/datum/particle_weather/snow_gentle = 10,
		/datum/particle_weather/dry_thunderstorm = 5,
		/datum/particle_weather/heat_wave = 5,
		/datum/particle_weather/snow_storm = 5,
		/datum/particle_weather/rain_storm = 5,
	)
	dusk_weather = list(
		/datum/particle_weather/fog = 20,
		/datum/particle_weather/rain_gentle = 20,
		/datum/particle_weather/rain_storm = 20,
		/datum/particle_weather/leaves_gentle = 15,
		/datum/particle_weather/fireflies = 15,
		/datum/particle_weather/snow_gentle = 10,
		/datum/particle_weather/dry_thunderstorm = 5,
		/datum/particle_weather/heat_wave = 5,
		/datum/particle_weather/snow_storm = 5,
	)
	night_weather = list(
		/datum/particle_weather/fog = 25,
		/datum/particle_weather/rain_gentle = 25,
		/datum/particle_weather/rain_storm = 20,
		/datum/particle_weather/fireflies = 20,
		/datum/particle_weather/snow_gentle = 15,
		/datum/particle_weather/leaves_gentle = 10,
		/datum/particle_weather/snow_storm = 5,
		/datum/particle_weather/heat_wave = 5,
		/datum/particle_weather/dry_thunderstorm = 5,
	)

	// Seasonal modifiers — boost weather appropriate to each season
	spring_weather_modifiers = list(
		/datum/particle_weather/rain_gentle = 1.5,
		/datum/particle_weather/rain_storm = 1.3,
		/datum/particle_weather/fog = 1.2,
		/datum/particle_weather/snow_gentle = 0.3,
		/datum/particle_weather/snow_storm = 0.1,
		/datum/particle_weather/heat_wave = 0.5,
	)
	summer_weather_modifiers = list(
		/datum/particle_weather/heat_wave = 2.0,
		/datum/particle_weather/fireflies = 1.8,
		/datum/particle_weather/dry_thunderstorm = 1.5,
		/datum/particle_weather/snow_gentle = 0.1,
		/datum/particle_weather/snow_storm = 0.0,
		/datum/particle_weather/leaves_gentle = 0.3,
		/datum/particle_weather/fog = 0.5,
	)
	autumn_weather_modifiers = list(
		/datum/particle_weather/leaves_gentle = 2.5,
		/datum/particle_weather/fog = 1.5,
		/datum/particle_weather/rain_storm = 1.3,
		/datum/particle_weather/fireflies = 0.5,
		/datum/particle_weather/heat_wave = 0.3,
		/datum/particle_weather/snow_gentle = 0.5,
	)
	winter_weather_modifiers = list(
		/datum/particle_weather/snow_gentle = 3.0,
		/datum/particle_weather/snow_storm = 3.0,
		/datum/particle_weather/fog = 1.3,
		/datum/particle_weather/fireflies = 0.0,
		/datum/particle_weather/leaves_gentle = 0.1,
		/datum/particle_weather/heat_wave = 0.0,
		/datum/particle_weather/dry_thunderstorm = 0.3,
		/datum/particle_weather/rain_gentle = 0.5,
		/datum/particle_weather/rain_storm = 0.3,
	)
