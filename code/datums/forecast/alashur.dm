//Al Ashur is meant to be sandy, dry thunderstorm sort of weather. Cold at night and fireflies.
//No desert map currently exists in this repo (upstream placeholder was "Desert Town") - kept for when one is added;
//SSParticleWeather falls back to /datum/forecast/rockhill if map_name doesn't match anything, so this is presently unreachable.
/datum/forecast/alashur
	name = "Al Ashur"
	day_weather = list(
		/datum/particle_weather/sand_gentle = 25,
		/datum/particle_weather/sand_storm = 20,
		/datum/particle_weather/dry_thunderstorm = 20,
		/datum/particle_weather/heat_wave = 20,
		/datum/particle_weather/ashstorm = 15,
		/datum/particle_weather/fireflies = 5,
	)
	dawn_weather = list(
		/datum/particle_weather/sand_gentle = 25,
		/datum/particle_weather/sand_storm = 20,
		/datum/particle_weather/dry_thunderstorm = 20,
		/datum/particle_weather/heat_wave = 15,
		/datum/particle_weather/ashstorm = 15,
		/datum/particle_weather/fireflies = 15,
	)
	dusk_weather = list(
		/datum/particle_weather/sand_gentle = 25,
		/datum/particle_weather/sand_storm = 20,
		/datum/particle_weather/dry_thunderstorm = 20,
		/datum/particle_weather/heat_wave = 15,
		/datum/particle_weather/ashstorm = 15,
		/datum/particle_weather/fireflies = 15,
	)
	night_weather = list(
		/datum/particle_weather/sand_gentle = 25,
		/datum/particle_weather/sand_storm = 20,
		/datum/particle_weather/dry_thunderstorm = 20,
		/datum/particle_weather/ashstorm = 15,
		/datum/particle_weather/fireflies = 15,
	)
