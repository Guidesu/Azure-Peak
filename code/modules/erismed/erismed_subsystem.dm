// ERISMED subsystem — processes all internal wounds

SUBSYSTEM_DEF(erismed)
	name = "ERISMED"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_NO_INIT
	var/list/processing = list()

/datum/controller/subsystem/erismed/fire()
	for(var/datum/internal_wound/IW in processing)
		if(!IW || QDELETED(IW))
			processing -= IW
			continue
		IW.process_wound()
