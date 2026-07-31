/datum/round_event_control/ignatius_taming
	name = "Taming Challenge"
	track = EVENT_TRACK_PERSONAL
	typepath = /datum/round_event/ignatius_taming
	weight = 10
	earliest_start = 10 MINUTES
	max_occurrences = 1
	min_players = 15

	tags = list(
		TAG_NATURE,
	)

/datum/round_event_control/ignatius_taming/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!istype(H) || H.stat == DEAD || !H.client)
			continue
		if(!H.patron || !istype(H.patron, /datum/patron/severance/ignatius))
			continue
		return TRUE

	return FALSE

/datum/round_event/ignatius_taming/start()
	var/list/valid_targets = list()

	for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
		if(!istype(human_mob) || human_mob.stat == DEAD || !human_mob.client)
			continue
		if(!human_mob.patron || !istype(human_mob.patron, /datum/patron/severance/ignatius))
			continue
		if(!human_mob.client.prefs || human_mob.client.prefs?.no_storyteller_events)
			continue
		valid_targets += human_mob

	if(!valid_targets.len)
		return

	var/mob/living/carbon/human/chosen_one = pick(valid_targets)

	var/datum/objective/tame_animal/new_objective = new(owner = chosen_one.mind)
	chosen_one.mind.add_personal_objective(new_objective)

	to_chat(chosen_one, span_userdanger("YOU ARE GOD'S CHOSEN!"))
	to_chat(chosen_one, span_notice("Ignatius calls you to bond with the wild creatures! Tame an animal to earn Ignatius's favor!"))
	chosen_one.playsound_local(chosen_one, 'sound/magic/barbroar.ogg', 100)
	
	chosen_one.mind.announce_personal_objectives()
