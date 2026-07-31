//Fireflies - slow floating, wandering glow
/particles/weather/fireflies
	// No bespoke "firefly_1"/"firefly_2" particle states exist on particle.dmi;
	// spark is the closest existing small-glowing-dot shape.
	icon_state             = "spark"
	color                  = "#ffe97a" // warm yellow glow
	count                  = 150 // 30 particles
	position               = generator("box", list(-500,-256,5), list(500,500,0))
	spin                   = generator("num",-2,2)
	gravity                = list(0, 1, 0) // no falling
	drift                  = generator("circle", 0, 2) // gentle wandering
	friction               = 0.4 // smooth, floaty motion
	transform              = null
	lifespan               = 30   // live for 30s max (fadein + lifespan + fade)
	//Weather effects
	maxSpawning            = 10
	minSpawning            = 5
	wind                   = 0.2 // barely affected by wind

/datum/particle_weather/fireflies
	name = "Fireflies"
	desc = "Tiny glowing insects drift lazily through the air."
	particleEffectType = /particles/weather/fireflies
	warning_message = span_greenannounce("Faint glows appear in the distance across the realm.")
	late_warning_message = span_greenannounce("Tiny lights begin to flicker in and out nearby.")
	scale_vol_with_severity = TRUE
	weather_sounds = list() // intentionally quiet

	minSeverity = 1
	maxSeverity = 5
	maxSeverityChange = 5
	severitySteps = 5

	immunity_type = null
	forecast_tag = "fireflies"
	probability = 20
	target_trait = PARTICLEWEATHER_FIREFLY

/datum/particle_weather/fireflies/weather_act(mob/living/L)
	if(issimple(L))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/M = L
		M.add_stress(/datum/stressevent/fireflies)
