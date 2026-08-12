// Sanity effects — spooky things that happen at low sanity

/// Emote effect — character does involuntary emotes
/datum/sanity/proc/effect_emote()
	if(!owner)
		return
	var/list/emotes_bad = list(
		"twitches nervously.",
		"shivers uncontrollably.",
		"mumbles something incoherent.",
		"looks around frantically.",
		"breaks into a cold sweat.",
		"clutches their head.",
	)
	var/list/emotes_worse = list(
		"rocks back and forth.",
		"mutters to someone who isn't there.",
		"scratches at their own skin.",
		"stares into the void with hollow eyes.",
		"whimpers like a frightened child.",
		"gibbers uncontrollably!",
	)
	owner.emote("me", message = level < SANITY_THRESHOLD_CRITICAL ? pick(emotes_worse) : pick(emotes_bad), forced = "sanity")

/// Quote effect — character sees disturbing text
/datum/sanity/proc/effect_quote()
	if(!owner)
		return
	var/list/quotes_bad = list(
		"You are not alone.",
		"The shadows are watching.",
		"They hunger for you.",
		"Your soul is fraying at the edges.",
		"Something is wrong with this place.",
		"You can hear the whispers of the dead.",
	)
	var/list/quotes_worse = list(
		"THE WALLS ARE BREATHING.",
		"YOU ARE ALREADY DEAD.",
		"IT IS COMING FOR YOU.",
		"YOUR MIND IS UNRAVELING.",
		"THERE IS NO ESCAPE.",
		"THEY ARE ALL INSIDE YOUR HEAD.",
	)
	to_chat(owner, span_danger(level < SANITY_THRESHOLD_CRITICAL ? pick(quotes_worse) : pick(quotes_bad)))

/// Sound effect — character hears phantom sounds
/datum/sanity/proc/effect_sound()
	if(!owner)
		return
	var/list/sounds = list(
		'sound/effects/ghost.ogg',
		'sound/misc/alert.ogg',
		'sound/magic/ahh1.ogg',
		'sound/magic/ahh2.ogg',
	)
	var/sound/S = pick(sounds)
	owner.playsound_local(owner, S, 50, 0, 8)

/// Whisper effect — character mutters descriptions of nearby items
/datum/sanity/proc/effect_whisper()
	if(!owner)
		return
	var/list/atom/candidates = owner.contents.Copy()
	while(length(candidates))
		var/atom/A = pick(candidates)
		if(!A.desc)
			candidates -= A
			continue
		// Mutter the item's description
		owner.say("[A.desc]", forced = "sanity")
		break

/// Hallucination effect — character sees things that aren't there
/datum/sanity/proc/effect_hallucination()
	if(!owner || !owner.client)
		return
	var/datum/hallucination/sanity_mirage/H = new
	H.holder = owner
	H.activate()

// Hallucination datum for sanity mirages
/datum/hallucination/sanity_mirage
	var/mob/living/carbon/human/holder
	var/duration = 3 SECONDS
	var/list/things = list()

/datum/hallucination/sanity_mirage/proc/activate()
	if(!holder?.client)
		return
	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(holder, world.view+1))
		possible_points += F
	if(possible_points.len)
		var/image/thing = generate_mirage()
		things += thing
		thing.loc = pick(possible_points)
		holder.client.images += things
		addtimer(CALLBACK(src, PROC_REF(end)), duration)

/datum/hallucination/sanity_mirage/proc/generate_mirage()
	// Generate a spooky mirage image
	var/list/mirage_types = list(
		/obj/effect/decal/remains/human,
		/obj/effect/decal/cleanable/blood,
		/obj/item/oddity,
	)
	var/type = pick(mirage_types)
	var/atom/movable/temp = new type
	var/image/img = image(temp, layer = LOW_ITEM_LAYER)
	qdel(temp)
	return img

/datum/hallucination/sanity_mirage/proc/end()
	if(holder?.client)
		holder.client.images -= things
	things.Cut()
