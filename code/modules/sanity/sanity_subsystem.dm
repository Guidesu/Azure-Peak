// Sanity subsystem — processes all sanity datums

SUBSYSTEM_DEF(sanity)
	name = "Sanity"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_NO_INIT
	var/list/processing = list()

/datum/controller/subsystem/sanity/fire()
	for(var/datum/sanity/S in processing)
		if(!S || QDELETED(S))
			processing -= S
			continue
		S.onLife()
