// Direct rename of the old Baotha's Revelry intervention event.
/datum/round_event_control/hausvette_revelry
	name = "Hausvette's Revelry"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/hausvette_revelry
	weight = 8
	earliest_start = 15 MINUTES
	max_occurrences = 2
	min_players = 10
	allowed_storytellers = list(/datum/storyteller/hausvette)

/datum/round_event/hausvette_revelry/start()
	SSmapping.add_world_trait(/datum/world_trait/hausvette_revelry, 20 MINUTES)
