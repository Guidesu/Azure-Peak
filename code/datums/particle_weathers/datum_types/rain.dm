//Rain - goes down
/particles/weather/rain
	icon_state             = "drop"
	color                  = "#ccffff"
	position               = generator("box", list(-500,-256,0), list(400,500,0))
	grow			       = list(-0.01,-0.01)
	gravity                = list(0, -10, 0.5)
	drift                  = generator("circle", 0, 1) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	transform 			   = null // Rain is directional - so don't make it "3D"
	//Weather effects, max values
	maxSpawning            = 150
	minSpawning            = 40
	wind                   = 2
	spin                   = 0 // explicitly set spin to 0 - there is a bug that seems to carry generators over from old particle effects

/datum/particle_weather/rain_gentle
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/rain
	warning_message = span_greenannounce("Grey clouds gather up above the realm, beholding the gift of life.")
	late_warning_message = span_greenannounce("Heavy drops begin to fall in rapid succession.")

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rain)
	indoor_weather_sounds = list(/datum/looping_sound/indoor_rain)

	minSeverity = 1
	maxSeverity = 15
	maxSeverityChange = 2
	severitySteps = 5
	immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 70
	target_trait = PARTICLEWEATHER_RAIN
	forecast_tag = "rain"

//Makes you a little chilly
/datum/particle_weather/rain_gentle/weather_act(mob/living/L)
	if(HAS_TRAIT(L, TRAIT_WEATHER_PROTECTED))
		L.add_stress(/datum/stressevent/parasol_rain)
		return

	// Abyssorites like to be in the rain! They still get wet without a parasol, though.
	if(HAS_TRAIT(L, TRAIT_ABYSSOR_SWIM))
		L.add_stress(/datum/stressevent/abyssor_rain)

	if(L.bodytemperature > BODYTEMP_COLD_LEVEL_ONE_MAX + 3)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.apply_weather_temperature(-rand(3,9))
		else
			L.adjust_bodytemperature(-rand(3,9))
	L.adjust_fire_stacks(-100)
	L.SoakMob(FULL_BODY)
	wash_atom(L, CLEAN_WEAK)

/datum/particle_weather/rain_storm
	name = "Rain Storm"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/rain
	warning_message = span_greenannounce("Dark clouds gather up above the realm, sparks arcing between heavenly reaches.")
	late_warning_message = span_greenannounce("The wind shifts and the storm breaks.")

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/storm)
	indoor_weather_sounds = list(/datum/looping_sound/indoor_rain)

	minSeverity = 4
	maxSeverity = 100
	maxSeverityChange = 50
	severitySteps = 50
	immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 40
	target_trait = PARTICLEWEATHER_RAIN
	forecast_tag = "rain"

	COOLDOWN_DECLARE(thunder)

/datum/particle_weather/rain_storm/tick()
	if(!COOLDOWN_FINISHED(src, thunder))
		return

	var/lightning_strikes = 6
	for(var/i = 1 to lightning_strikes)
		var/atom/lightning_destination
		var/list/viable_players = list()
		for(var/client/client in GLOB.clients)
			if(!isliving(client.mob))
				continue
			var/mob/living/L = client.mob
			viable_players += L
		if(!viable_players.len)
			return

		lightning_destination = pick(viable_players)
		var/mob/living/humann = pick(viable_players)
		var/turf/humann_turf = get_turf(humann)
		var/area/A = get_area(humann)
		if(humann.badluck(4) && istype(A, /area/rogue/outdoors))
			humann.Immobilize(0.5 SECONDS)
			humann.apply_status_effect(/datum/status_effect/debuff/clickcd, 6 SECONDS)
			humann.electrocute_act(1, src, 1, SHOCK_NOSTUN)
			humann.apply_status_effect(/datum/status_effect/buff/lightningstruck, 6 SECONDS)
			new /obj/effect/temp_visual/lightning/storm(get_turf(humann_turf))
		if(lightning_destination)
			var/list/turfs = list()
			for(var/turf/open/turf in range(lightning_destination, 7))
				if(!turf.outdoor_effect || turf.outdoor_effect.weatherproof)
					continue
				turfs |= turf
			if(!length(turfs))
				return
			lightning_destination = pick(turfs)

		else
			lightning_destination = pick(SSParticleWeather.weathered_turfs)

		new /obj/effect/temp_visual/lightning/storm(get_turf(lightning_destination))
		COOLDOWN_START(src, thunder, rand(5, 40) * 1 SECONDS)

//Makes you a bit chilly
/datum/particle_weather/rain_storm/weather_act(mob/living/L)
	// Abyssorites like storms even more than they like rain!
	if(HAS_TRAIT(L, TRAIT_ABYSSOR_SWIM))
		L.add_stress(/datum/stressevent/abyssor_storm)

	if(L.bodytemperature > BODYTEMP_COLD_LEVEL_ONE_MAX + 5)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.apply_weather_temperature(-rand(9,15))
		else
			L.adjust_bodytemperature(-rand(9,15))
	L.adjust_fire_stacks(-100)
	L.SoakMob(FULL_BODY)
	wash_atom(L,CLEAN_STRONG)

/obj/effect/temp_visual/lightning/storm
	icon = 'icons/effects/32x96.dmi' // 32x200.dmi doesn't exist in this repo - reusing the base lightning effect's icon instead

	light_system = MOVABLE_LIGHT
	light_color = COLOR_PALE_BLUE_GRAY
	light_outer_range = 15
	light_power = 25
	duration = 12

/obj/effect/temp_visual/lightning/storm/Initialize(mapload, list/flame_hit)
	. = ..()
	playsound(get_turf(src),'sound/weather/rain/thunder_1.ogg', 80, TRUE)
