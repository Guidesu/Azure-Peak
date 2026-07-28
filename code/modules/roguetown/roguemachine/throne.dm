GLOBAL_VAR(king_throne)

/obj/structure/roguethrone
	name = "throne"
	desc = "A big throne, to hold the settlement leader's giant personality. Say 'secrets of the throat' with the crown on your head if you are confused."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "throne"
	density = FALSE
	can_buckle = 1
	pixel_x = -32
	max_integrity = 999999
	buckle_lying = FALSE
	obj_flags = NONE
	var/rebel_leader_sit_time = 0
	var/notified_rebel_able = FALSE

/obj/structure/roguethrone/post_buckle_mob(mob/living/M)
	..()
	density = TRUE
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 8)

/obj/structure/roguethrone/post_unbuckle_mob(mob/living/M)
	..()
	density = FALSE
	M.reset_offsets("bed_buckle")

/obj/structure/roguethrone/Initialize()
	. = ..()
	become_hearing_sensitive()
	if(GLOB.king_throne == null)
		GLOB.king_throne = src
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/structure/roguethrone/Destroy()
	lose_hearing_sensitivity()
	if(GLOB.king_throne == src)
		GLOB.king_throne = null
	GLOB.lordcolor -= src
	return ..()

/obj/structure/roguethrone/process()
	var/dt = 1 SECONDS
	process_rebel_leader_sit(dt)
	. = ..()

/obj/structure/roguethrone/proc/process_rebel_leader_sit(dt)
	if(!length(buckled_mobs))
		return
	var/mob/living/user = buckled_mobs[1]
	if(user.stat != CONSCIOUS)
		return
	var/datum/antagonist/prebel/P = user.mind?.has_antag_datum(/datum/antagonist/prebel)
	if(!P)
		return
	if(rebel_leader_sit_time == 0)
		to_chat(user, span_notice("Finally, I'm sitting on the throne - when I get more comfortable here I'll be able to announce victory. Other rebels here will help me get comfortable faster."))
	var/time_modifier = 1.0
	/// Increase modifier for every other conscious rebel in view
	for(var/mob/living/living_mob in view(7, loc))
		if(living_mob == user)
			continue
		if(living_mob.stat != CONSCIOUS)
			continue
		var/datum/antagonist/prebel/rebel_antag = living_mob.mind?.has_antag_datum(/datum/antagonist/prebel)
		if(!rebel_antag)
			continue
		time_modifier += REBEL_THRONE_SPEEDUP_PER_PERSON
	rebel_leader_sit_time += (dt * time_modifier)
	if(rebel_leader_sit_time >= REBEL_THRONE_TIME && !notified_rebel_able)
		notified_rebel_able = TRUE
		to_chat(user, span_notice("That's it - time to announce our victory!"))

/obj/structure/roguethrone/examine(mob/user)
	. = ..()
	. += span_notice("The throne of the [SSticker.realm_type] of [SSticker.realm_name].")

/obj/structure/roguethrone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("<b>Throat Commands</b> (say these at the Throat):")
	. += span_info("'Make Announcement' - broadcast a message (requires crown)")
	. += span_info("'Revise Charter' - revise or restore charters (requires crown, ruler only)")
	. += span_info("'Make Decree' - issue a royal decree (requires crown, ruler only)")
	. += span_info("'Purge Decrees' - remove all decrees (requires crown, ruler only)")
	. += span_info("'Set Laws' - set the laws of the land (requires crown, ruler only)")
	. += span_info("'Make Law' - create a new law (requires crown, ruler only)")
	. += span_info("'Remove Law (number)' - remove a specific law (requires crown, ruler only)")
	. += span_info("'Purge Laws' - remove all laws (requires crown, ruler only)")
	. += span_info("'Declare Outlaw' - outlaw someone (requires crown, ruler only)")
	. += span_info("'Set Taxes' - set the tax rate (requires crown, ruler only)")
	. += span_info("'Change Colors' - change the settlement's colors (requires crown, ruler only)")
	. += span_info("'Become Regent' - claim regency when ruler is absent (requires crown, noble blood, regency position)")
	. += span_info("'Summon Crown' / 'Summon Key' - retrieve royal items")

/obj/structure/roguethrone/lordcolor(primary,secondary)
	if(!primary || !secondary)
		return
	var/mutable_appearance/M = mutable_appearance(icon, "throne_primary", -(layer+0.1))
	M.color = primary
	add_overlay(M)
	M = mutable_appearance(icon, "throne_secondary", -(layer+0.1))
	M.color = secondary
	add_overlay(M)
