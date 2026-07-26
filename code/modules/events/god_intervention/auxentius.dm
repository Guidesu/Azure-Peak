// Merge of the old Astrata (astrata_grandeur) and Ravox (ravox_resolve) intervention events.
/datum/round_event_control/auxentius_grandeur
	name = "Auxentius's Grandeur"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/auxentius_grandeur
	weight = 8
	earliest_start = 15 MINUTES
	max_occurrences = 1
	min_players = 20
	todreq = list("dusk", "dawn", "day")
	allowed_storytellers = list(/datum/storyteller/auxentius)

/datum/round_event_control/auxentius_grandeur/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return FALSE
	if(GLOB.patron_follower_counts["Auxentius"] < 4)
		return FALSE

/datum/round_event/auxentius_grandeur/start()
	for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
		if(!istype(human_mob) || human_mob.stat == DEAD || !human_mob.client)
			continue

		if(!human_mob.patron || !istype(human_mob.patron, /datum/patron/concordat/auxentius))
			continue

		// Only for Auxentian clergy and nobles
		if(!(human_mob.mind?.assigned_role in GLOB.church_positions) && !human_mob.is_noble())
			continue

		human_mob.add_stress(/datum/stressevent/astrata_grandeur)

		to_chat(human_mob, span_notice("Auxentius shines brightly todae - and just as he sits first among the Six Seats, so must you guide others with a firm hand. The Sun Lord demands no less from those who bask in his glory."))
		human_mob.playsound_local(human_mob, 'sound/magic/bless.ogg', 100)

/datum/round_event_control/auxentius_resolve
	name = "Auxentius's Resolve"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/auxentius_resolve
	weight = 8
	earliest_start = 25 MINUTES
	max_occurrences = 1
	min_players = 30
	allowed_storytellers = list(/datum/storyteller/auxentius)

/datum/round_event_control/auxentius_resolve/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return FALSE
	if(GLOB.patron_follower_counts["Auxentius"] < 3)
		return FALSE

/datum/round_event/auxentius_resolve/start()
	var/mob/living/carbon/human/weakest
	var/weakest_stat
	for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
		if(!istype(human_mob) || human_mob.stat == DEAD || !human_mob.client)
			continue

		if(!human_mob.patron || !istype(human_mob.patron, /datum/patron/concordat/auxentius))
			continue

		if(!weakest)
			weakest_stat = human_mob.get_stat_level(STATKEY_STR)
			weakest = human_mob

		var/mob_stat_level = human_mob.get_stat_level(STATKEY_STR)
		if(mob_stat_level < weakest_stat)
			weakest = human_mob
		else if(mob_stat_level == weakest_stat && prob(50))
			weakest = human_mob

	if(!weakest)
		return

	weakest.change_stat(STATKEY_STR, 1)
	weakest.change_stat(STATKEY_WIL, 1)
	weakest.change_stat(STATKEY_CON, 1)
	to_chat(weakest, span_green("You may be weak compared to your fellow warriors of justice, but still you persevere. Auxentius honors those who fight even when victory seems impossible. Let his gift of strength be your whetstone — now strike!"))
	weakest.playsound_local(weakest, 'sound/vo/male/knight/rage (6).ogg', 70)
