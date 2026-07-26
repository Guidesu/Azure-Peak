// Merge of the old Necra (necra_requiem) and Matthios (matthios_fingers) intervention events.
/datum/round_event_control/morwenna_requiem
	name = "Morwenna's Requiem"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/morwenna_requiem
	weight = 8
	earliest_start = 15 MINUTES
	max_occurrences = 2
	min_players = 20
	allowed_storytellers = list(/datum/storyteller/morwenna)

/datum/round_event/morwenna_requiem/start()
	SSmapping.add_world_trait(/datum/world_trait/morwenna_requiem, 15 MINUTES)

/datum/round_event_control/morwenna_fingers
	name = "Morwenna's Fingers"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/morwenna_fingers
	weight = 8
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 20
	allowed_storytellers = list(/datum/storyteller/morwenna)

/datum/round_event/morwenna_fingers/start()
	SSmapping.add_world_trait(/datum/world_trait/morwenna_fingers, 20 MINUTES)
