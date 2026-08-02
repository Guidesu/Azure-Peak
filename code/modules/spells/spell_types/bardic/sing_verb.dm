// ═══════════════════════════════════════════════════════════════════
// SING VERB — Vocal performance for bards without instruments
//
// Allows bards to sing their currently active song using only their voice,
// freeing their hands for combat. Works with the bardic inspiration system:
// applies the same song effects to the audience.
//
// The bard must have the inspiration datum (be a bard) and have at least
// one learned song. Singing uses the same stamina cost and cooldown as
// the instrument version.
// ═══════════════════════════════════════════════════════════════════

/mob/living/carbon/human/proc/sing()
	set name = "Sing"
	set category = "RoleUnique.Inspiration"

	if(!inspiration)
		to_chat(src, span_warning("I don't have the gift of inspiration."))
		return

	if(!mind)
		return

	// Find the bard's learned songs
	var/list/learned_songs = list()
	for(var/datum/action/cooldown/spell/song/S in mind.spell_list)
		learned_songs += S

	if(!length(learned_songs))
		to_chat(src, span_warning("I don't know any songs to sing!"))
		return

	// If only one song, sing it directly
	var/datum/action/cooldown/spell/song/target_song
	if(length(learned_songs) == 1)
		target_song = learned_songs[1]
	else
		// Let the bard pick which song to sing
		var/list/song_names = list()
		for(var/datum/action/cooldown/spell/song/S in learned_songs)
			song_names[S.name] = S
		var/choice = input(src, "Which song will I sing?", "Sing") as null|anything in song_names
		if(!choice)
			return
		target_song = song_names[choice]

	if(!target_song)
		return

	// Check if already singing this song — toggle off
	var/mob/living/carbon/human/H = src
	if(target_song.song_effect)
		for(var/datum/status_effect/existing in H.status_effects)
			if(existing.type == target_song.song_effect)
				H.remove_status_effect(existing)
				to_chat(H, span_warning("I stop singing."))
				return

	// Clear any existing song and its applied effects
	for(var/datum/status_effect/buff/playing_melody/melodies in H.status_effects)
		H.remove_status_effect(melodies)
	if(H.inspiration)
		for(var/mob/living/carbon/human/guy in H.inspiration.audience)
			for(var/datum/status_effect/buff/song/old_buff in guy.status_effects)
				guy.remove_status_effect(old_buff)

	// Check stamina cost
	var/cost = target_song.get_adjusted_cost(target_song.primary_resource_cost)
	if(H.staminaloss >= 100 - cost)
		to_chat(H, span_warning("I'm too exhausted to sing!"))
		return

	// Apply the song effect — singing uses the same effects as playing
	H.visible_message(
		span_notice("[H] begins to sing - [target_song.name]."),
		span_notice("I begin to sing - [target_song.name].")
	)
	playsound(get_turf(H), 'sound/magic/buffrollaccent.ogg', 50, TRUE)

	// Apply stamina cost
	H.stamina_add(cost)

	// Start cooldown
	target_song.StartCooldown(target_song.get_adjusted_cooldown())

	// Apply the song effect
	H.apply_status_effect(target_song.song_effect)

	// Set up a vocal singing flag so the melody tick knows we're singing, not playing
	var/datum/status_effect/buff/playing_melody/melody = locate(target_song.song_effect) in H.status_effects
	if(melody)
		melody.vocal_singing = TRUE
