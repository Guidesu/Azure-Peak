// Ported from Twilight-Axis: modular_twilight_axis/code/game/objects/items/rogueitems/horns.dm
//
// This repo already has its own /obj/item/signal_horn base (code/game/objects/items/signal_horn.dm)
// tied to the warden ambush-budget system (attack_self() checks threat regions, calls
// user.consider_ambush(), etc.) - that base and its WARDEN_AMBUSH_MIN/MAX defines were NOT
// duplicated here.
//
// Two distinct pieces were ported from horns.dm:
//
// 1. /obj/item/signal_horn/vanguard_battle - a genuine new subtype of this repo's existing
//    /obj/item/signal_horn base. Only its sound_horn() override (unique sound + flavor text) is
//    ported; attack_self()/the ambush plumbing is inherited unchanged from the parent.
//
// 2. /obj/item/signal_hornn (red/blue/green) - a mechanically SEPARATE horn family from the
//    source repo that has nothing to do with the ambush system: it's a triple-purpose
//    rally/alert/full-alarm broadcaster gated on three new /datum/intent subtypes (rally, alert,
//    alarm), announcing distance+direction to every living player on the map. Source repeated the
//    full body of this logic three times (once per color) with only the sound file and flavor
//    line changed; de-duplicated here into a shared /obj/item/signal_hornn parent with a
//    proc/get_horn_sound(purpose) hook, matching this repo's general preference for shared bases
//    over copy-pasted subtypes (see e.g. signal_horn's own single sound_horn()).
//
// Adaptation notes:
// - All player-facing text translated from the source's Russian to English; mechanics are a
//   faithful port (same cooldown, same distance bands, same direction detection).
// - icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi' doesn't exist in this tree.
//   Copied verbatim into modular_dreamvalley/icons/twilight_horns/misc.dmi (confirmed via the
//   dmi's own zTXt metadata that it has signal_horn/signal_horn_red/signal_horn_blue/
//   signal_horn_green icon states).
// - Sound files (RallyRetinue.ogg, AlertRetinue.ogg, FullAlertRetinue.ogg, and the Watchmen/
//   Vanguard equivalents) didn't exist in this repo's sound/ tree. Copied verbatim into
//   modular_dreamvalley/sound/twilight_horns/.
// - /datum/intent/rally, /alert, /alarm are new - grepped this repo first and confirmed no
//   existing intents use those names.

/datum/intent/rally
	name = "rally signal"
	desc = "Upon hearing a single blast of the horn, all subordinates are to report for muster."
	icon_state = "inrally"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/datum/intent/alert
	name = "alert signal"
	desc = "Upon hearing a double blast of the horn, all subordinates are to arm themselves and arrive as soon as possible."
	icon_state = "inalert"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/datum/intent/alarm
	name = "full alarm signal"
	desc = "Upon hearing a triple blast of the horn, all subordinates are to drop what they are doing and come to the rescue."
	icon_state = "inalarm"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/obj/item/signal_hornn
	name = "signal horn"
	desc = "Used to muster troops and sound alarms."
	icon = 'modular_dreamvalley/icons/twilight_horns/misc.dmi'
	icon_state = "signal_horn"
	possible_item_intents = list(/datum/intent/rally, /datum/intent/alert, /datum/intent/alarm)
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 32
	grid_width = 64
	var/last_horn = 0
	/// Flavor name for the group this horn rallies, used in broadcast text ("the guard's horn", etc).
	var/horn_owner_desc = "horn"

/obj/item/signal_hornn/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_horn + 30 SECONDS)
		to_chat(user, span_warning("My lungs need to rest before I can blow [src] again!"))
		return
	user.visible_message(span_warning("[capitalize(user.name)] is about to blow [src]!"))
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/rally)
		last_horn = world.time
		sound_horn_purpose(user, "rally")
	else if(do_after(user, 15) && user.used_intent.type == /datum/intent/alert)
		last_horn = world.time
		sound_horn_purpose(user, "alert")
	else if(do_after(user, 15) && user.used_intent.type == /datum/intent/alarm)
		last_horn = world.time
		sound_horn_purpose(user, "alarm")

/// Returns the sound file for a given purpose ("rally"/"alert"/"alarm"). Overridden per-color subtype.
/obj/item/signal_hornn/proc/get_horn_sound(purpose)
	return 'sound/items/horn/signalhorn.ogg'

/obj/item/signal_hornn/proc/sound_horn_purpose(mob/living/user, purpose)
	var/purpose_text
	switch(purpose)
		if("rally")
			purpose_text = "muster call"
		if("alert")
			purpose_text = "alert call"
		if("alarm")
			purpose_text = "full alarm"
	user.visible_message(span_warning("[capitalize(user.name)] blows [horn_owner_desc]!"))
	var/horn_sound = get_horn_sound(purpose)
	playsound(src, horn_sound, 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the "
		var/direction = get_dir(player, origin_turf)
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", although I cannot make out an exact direction"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		player.playsound_local(get_turf(player), horn_sound, 35, FALSE, pressure_affected = FALSE)
		to_chat(player, span_warning("I hear the [purpose_text] of [horn_owner_desc] somewhere[disttext][dirtext]!"))

/obj/item/signal_hornn/red
	name = "sergeant's horn"
	icon_state = "signal_horn_red"
	horn_owner_desc = "the sergeant's horn"

/obj/item/signal_hornn/red/get_horn_sound(purpose)
	switch(purpose)
		if("rally")
			return 'modular_dreamvalley/sound/twilight_horns/RallyRetinue.ogg'
		if("alert")
			return 'modular_dreamvalley/sound/twilight_horns/AlertRetinue.ogg'
		if("alarm")
			return 'modular_dreamvalley/sound/twilight_horns/FullAlertRetinue.ogg'

/obj/item/signal_hornn/blue
	name = "town guard horn"
	icon_state = "signal_horn_blue"
	horn_owner_desc = "the town guard's horn"

/obj/item/signal_hornn/blue/get_horn_sound(purpose)
	switch(purpose)
		if("rally")
			return 'modular_dreamvalley/sound/twilight_horns/RallyWatchmen.ogg'
		if("alert")
			return 'modular_dreamvalley/sound/twilight_horns/AlertWatchmen.ogg'
		if("alarm")
			return 'modular_dreamvalley/sound/twilight_horns/FullAlertWatchmen.ogg'

/obj/item/signal_hornn/green
	name = "vanguard's horn"
	icon_state = "signal_horn_green"
	horn_owner_desc = "the vanguard's horn"

/obj/item/signal_hornn/green/get_horn_sound(purpose)
	switch(purpose)
		if("rally")
			return 'modular_dreamvalley/sound/twilight_horns/RallyVanguard.ogg'
		if("alert")
			return 'modular_dreamvalley/sound/twilight_horns/AlertVanguard.ogg'
		if("alarm")
			return 'modular_dreamvalley/sound/twilight_horns/FullAlertVanguard.ogg'

//====================================================================
// New subtype of this repo's EXISTING /obj/item/signal_horn base
// (code/game/objects/items/signal_horn.dm) - inherits attack_self()
// and the ambush-budget plumbing unchanged, only overrides the sound.
//====================================================================

/obj/item/signal_horn/vanguard_battle
	name = "vanguard battle horn"
	desc = "A horn used by the Vanguard bog patrols. Blowing it attracts the attention of various creatures and rapscallions, enabling the Vanguard to clear them out."

/obj/item/signal_horn/vanguard_battle/sound_horn(mob/living/user)
	user.visible_message(span_userdanger("[user] blows the horn!"))
	playsound(src, 'sound/items/horn/bogguardhorn.ogg', 100, TRUE)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/turf/origin_turf = get_turf(src)

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7 || distance > 21) // two screens away
			continue
		var/dirtext = " to the "
		var/direction = get_dir(player, origin_turf)
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = "although I cannot make out an exact direction"

		player.playsound_local(get_turf(player), 'sound/items/horn/bogguardhorn.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, span_warning("I hear the Vanguard battle horn somewhere [dirtext]"))

	return user.consider_ambush(TRUE, TRUE, min_dist = 2, max_dist = 9)
