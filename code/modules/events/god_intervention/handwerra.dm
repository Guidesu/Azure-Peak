// Merge of the old Malum (malum_diligence) and Pestra (pestra_mercy) intervention events.
/datum/round_event_control/handwerra_diligence
	name = "Handwerra's Diligence"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/handwerra_diligence
	weight = 8
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 5
	allowed_storytellers = list(/datum/storyteller/handwerra)

/datum/round_event/handwerra_diligence/start()
	SSmapping.add_world_trait(/datum/world_trait/handwerra_diligence, 20 MINUTES)

/datum/round_event_control/handwerra_mercy
	name = "Handwerra's Mercy"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/handwerra_mercy
	weight = 8
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 10
	allowed_storytellers = list(/datum/storyteller/handwerra)

/datum/round_event/handwerra_mercy/start()
	SSmapping.add_world_trait(/datum/world_trait/handwerra_mercy, 20 MINUTES)
