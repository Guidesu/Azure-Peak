// Direct rename of the old Ignatius vines/fertility/ire intervention events (now Ignatius's).
/datum/round_event_control/ignatius_vines_malus
	name = "Ignatius's Vines (Malus)"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/ignatius_vines
	weight = 8
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 3
	todreq = list("dusk", "night", "dawn", "day")
	allowed_storytellers = list(/datum/storyteller/ignatius)

/datum/round_event/ignatius_vines/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/vine/SV = new()

	for(var/area/rogue/outdoors/town/A in world)
		for(var/turf/open/F in A)
			if(F.Enter(SV))
				if(!istype(F, /turf/open/transparent/openspace))
					turfs += F

	qdel(SV)

	var/maxi = 15
	for(var/i in 1 to rand(5,maxi))
		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/T = pick_n_take(turfs)
			message_admins("VINES at [ADMIN_VERBOSEJMP(T)]")
			new /datum/vine_controller(T, event = src, potency = 0.1, muts = list(/datum/vine_mutation/thorns, /datum/vine_mutation/woodening)) //spawn a controller at turf


/datum/round_event_control/ignatius_vines_boon
	name = "Ignatius's Vines (Boon)"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/ignatius_vines_good
	earliest_start = 10 MINUTES
	weight = 4
	max_occurrences = 2
	min_players = 3
	todreq = list("dusk", "night", "dawn", "day")
	allowed_storytellers = list(/datum/storyteller/ignatius)

/datum/round_event/ignatius_vines_good/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/vine/SV = new()

	for(var/area/rogue/outdoors/town/A in world)
		for(var/turf/open/F in A)
			if(F.Enter(SV))
				if(!istype(F, /turf/open/transparent/openspace))
					turfs += F

	qdel(SV)

	var/maxi = 15
	for(var/i in 1 to rand(5,maxi))
		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/T = pick_n_take(turfs)
			message_admins("VINES at [ADMIN_VERBOSEJMP(T)]")
			new /datum/vine_controller(T, event = src, potency = 0.1, muts = list(/datum/vine_mutation/light, /datum/vine_mutation/healing, /datum/vine_mutation/woodening)) //spawn a controller at turf


/datum/round_event_control/ignatius_fertility
	name = "Ignatius's Blessing"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/ignatius_fertility
	weight = 4
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 3
	allowed_storytellers = list(/datum/storyteller/ignatius)

/datum/round_event/ignatius_fertility/start()
	SSmapping.add_world_trait(/datum/world_trait/ignatius_fertility, 20 MINUTES)

/datum/round_event_control/ignatius_ire
	name = "Ignatius's Ire"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/ignatius_ire
	weight = 4
	earliest_start = 10 MINUTES
	max_occurrences = 2
	min_players = 3
	allowed_storytellers = list(/datum/storyteller/ignatius)

/datum/round_event/ignatius_ire/start()
	SSmapping.add_world_trait(/datum/world_trait/ignatius_drought, 10 MINUTES)
