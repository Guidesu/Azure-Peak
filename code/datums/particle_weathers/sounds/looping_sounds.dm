/datum/looping_sound/rain
	mid_sounds = 'sound/weather/rain/weather_rain.ogg'
	mid_length = 40 SECONDS
	volume = 200
	direct = TRUE

/datum/looping_sound/indoor_rain
	mid_sounds = 'sound/weather/rain/weather_rain_indoors.ogg'
	mid_length = 15 SECONDS
	volume = 500
	direct = TRUE

/datum/looping_sound/storm
	mid_sounds = 'sound/weather/rain/weather_storm.ogg'
	mid_length = 30 SECONDS
	volume = 150
	direct = TRUE

/datum/looping_sound/snow
	mid_sounds = 'sound/weather/snow/weather_snow.ogg'
	mid_length = 50 SECONDS
	volume = 150
	direct = TRUE

/datum/looping_sound/hail
	mid_sounds = 'sound/weather/hail/weather_hail.ogg'
	mid_length = 50 SECONDS
	volume = 110
	direct = TRUE

/datum/looping_sound/indoor_hail
	mid_sounds = 'sound/weather/hail/weather_hail_indoors.ogg'
	mid_length = 30 SECONDS
	volume = 175
	direct = TRUE

// No sound/weather/sand/*.ogg files exist in this repo (the PR's sandstorm audio
// assets were never sourced - binary files, not part of the ported diffs). Reuses
// the wind loop rather than referencing a sound file that doesn't exist and would
// silently fail to play; swap in real sandstorm audio if/when it's added.
/datum/looping_sound/sandstorm
	mid_sounds = list(
		'sound/weather/rain/wind_3.ogg'=1,
		'sound/weather/rain/wind_4.ogg'=1,
		)
	mid_length = 30 SECONDS
	volume = 160
	direct = TRUE

// No sound/weather/ashstorm/*.ogg files exist in this repo either - same
// missing-binary-asset situation as sandstorm above. Reuses the storm loop's
// low rumble as the closest available substitute.
/datum/looping_sound/ash
	mid_sounds = 'sound/weather/rain/weather_storm.ogg'
	mid_length = 30 SECONDS
	volume = 140
	direct = TRUE

/datum/looping_sound/indoor_ash
	mid_sounds = 'sound/weather/rain/wind_2.ogg'
	mid_length = 30 SECONDS
	volume = 180
	direct = TRUE

/datum/looping_sound/wind
	mid_sounds = 'sound/weather/rain/wind_1.ogg'
	mid_sounds = list(
		'sound/weather/rain/wind_1.ogg'=1,
		'sound/weather/rain/wind_2.ogg'=1,
		'sound/weather/rain/wind_3.ogg'=1,
		'sound/weather/rain/wind_4.ogg'=1,
		'sound/weather/rain/wind_5.ogg'=1,
		'sound/weather/rain/wind_6.ogg'=1
		)
	mid_length = 30 SECONDS
	volume = 150
	direct = TRUE
