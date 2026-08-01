// Direct successor to the old Praecursor patron (formerly Praecursor; formerly type-pathed as the standalone "old_god"). Same mechanical
// baseline preserved verbatim; renamed and re-flavored as the Tribunal's godhead - the Word, first law, and
// judgment, rather than "father of all" divinity.
/datum/patron/tribunal/praecursor
	name = "Praecursor"
	domain = "The Word, First Law, and Judgment"
	desc = "''The First Word. The law spoken before any other law existed.'' \
	</br>''He, who set the boundary between order and the formless dark.'' \
	</br>''He, who breathed the Word into the Tribunal to carry His judgment.'' \
	</br>''He, who spent Himself to bind the Unmaker with the Comet Syon.'' \
	</br>''He, who yet waits in silence to this dae; and who may yet still speak again.''"
	worshippers = "Magistrates, Zealots, Judges, Heretics-Turned-Faithful, and the Esoteric"
	mob_traits = list(TRAIT_VAELTIAN_GRIT) //Assigned to all mobs with Praecursor as the chosen patron. Gives a Willpower-scaling chance to resist succumbing to pain.
	miracles = list(/datum/action/cooldown/spell/touch/orison		= CLERIC_ORI,
					/datum/action/cooldown/spell/praecursor/bootcheck	= CLERIC_T0, //Personal spell - summons a completely random item upon use. Your mileage might vary.
					/datum/action/cooldown/spell/praecursor/endure		= CLERIC_T1, //External spell - seals bleeding wounds and helps to save people who've been critically injured.
					/datum/action/cooldown/spell/praecursor/prayer		= CLERIC_T1, //Internal spell - minor self-regeneration, repeatedly casted while still.
					/datum/action/cooldown/spell/praecursor/respite		= CLERIC_T2, //Ditto, but stronger. The original variant, intended for dedicated - non-Adventuring - combat classes.
					/datum/action/cooldown/spell/praecursor/persist		= CLERIC_T3, //Ditto-ditto. Intended for non-combative devotee classes, such as the Missionary and Absolver.
	)
	traits_tier = list(TRAIT_VAELTITE = CLERIC_T0) //Requires a minimal holy skill or the 'Devotee' virtue to unlock. Offers passive wound regeneration, but prevents healing from most miracles.
	confess_lines = list(
		"THERE IS ONLY ONE TRUE WORD!",
		"PRAECURSOR YET SPEAKS! PRAECURSOR YET ENDURES!",
		"REBUKE THE HEATHEN, SUNDER THE MONSTER!",
		"MY LORD - WITH EVERY BROKEN BONE, I SWORE I LYVED!",
		"EVEN NOW, THERE IS STILL HOPE FOR MAN! AVE THE WORD!",
		"WITNESS ME, PRAECURSOR; THE SACRIFICE MADE MANIFEST!",
	)

	titles = list(
		"The Word",
		"First Judge",
		"God", // people call him this for some reason, he has a name
	)

/////////////////////////////////
// Does God Hear Your Prayer ? //
/////////////////////////////////
// no he's dead - ok maybe he does

/datum/patron/tribunal/praecursor/can_pray(mob/living/follower)
	. = ..()
	. = TRUE
	// Allows prayer near psycross.
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if raining and outside. Praecursor weeps.
	var/datum/particle_weather/W = SSParticleWeather?.runningWeather
	if(istype(W, /datum/particle_weather/rain_gentle) || istype(W, /datum/particle_weather/rain_storm))
		if(istype(get_area(follower), /area/rogue/outdoors))
			return TRUE
	if(istype(W, /datum/particle_weather/blood_rain_gentle) || istype(W, /datum/particle_weather/blood_rain_storm))
		if(istype(get_area(follower), /area/rogue/outdoors))
			follower.add_stress(/datum/stressevent/something_stirs)
			follower.playsound_local(follower, 'sound/magic/psydonbleeds.ogg', 40, TRUE)
			return TRUE
	// Allows prayer if bleeding.
	if(follower.bleed_rate > 0)
		return TRUE
	// Allows prayer if holding silver psycross.
	if(istype(follower.get_active_held_item(), /obj/item/clothing/neck/roguetown/psicross/silver))
		return TRUE
	to_chat(follower, span_danger("..yet, I feel incomplete. To complete my prayer, I must stand before a structured cross, be grasping a silvered psycross, be bleeding from a wound, or be standing in the rain. Just as He weeps, so must I."))
	return FALSE
