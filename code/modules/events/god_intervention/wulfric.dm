// Direct rename of the old Abyssor's Rage intervention event.
/datum/round_event_control/wulfric_rage
	name = "Wulfric's Rage"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/wulfric_rage
	weight = 8
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 20
	allowed_storytellers = list(/datum/storyteller/wulfric)

/datum/round_event/wulfric_rage/start()
	SSmapping.add_world_trait(/datum/world_trait/wulfric_rage, 20 MINUTES)
