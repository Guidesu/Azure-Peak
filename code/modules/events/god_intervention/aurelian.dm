// Direct rename of the old Zizo's Defilement / Pet Cementery intervention events.
/datum/round_event_control/aurelian_defilement
	name = "Aurelian's Defilement"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/aurelian_defilement
	weight = 4
	earliest_start = 25 MINUTES
	max_occurrences = 2
	min_players = 2
	allowed_storytellers = list(/datum/storyteller/aurelian)

/datum/round_event/aurelian_defilement/start()
	SSmapping.add_world_trait(/datum/world_trait/aurelian_defilement, 15 MINUTES)

/datum/round_event_control/aurelian_pet_cementery
	name = "Aurelian's Pet Cementery"
	typepath = /datum/round_event/aurelian_pet_cementery
	weight = 6
	earliest_start = 25 MINUTES
	max_occurrences = 2
	min_players = 35

/datum/round_event/aurelian_pet_cementery/start()
	//Long duration but you might not even notice it.
	SSmapping.add_world_trait(/datum/world_trait/aurelian_pet_cementery, 60 MINUTES)
