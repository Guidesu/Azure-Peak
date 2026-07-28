// Job-start and map-generator landmarks used by byos.dmm.
// Ported from Ratwood-2.0 code/game/objects/effects/landmarks.dm.
// Base /obj/effect/landmark and /obj/effect/landmark/start already exist in this
// codebase; only these specific job-spawn leaves were missing.
// jobspawn_override entries are plain strings (job title keys), not type paths,
// so they don't require the referenced jobs to exist under any particular name
// for this to compile — but they do match this repo's existing job titles.

/obj/effect/landmark/start/banditlate
	name = "Bandit"
	icon_state = "arrow"
	jobspawn_override = list("Bandit")
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/orphanlate
	name = "Vagabondlate"
	icon_state = "arrow"
	jobspawn_override = list("Vagabond")
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/sheriff
	name = "Watch Captain"
	icon_state = "arrow"

/obj/effect/landmark/start/guard_captain
	name = "Knight Captain"
	icon_state = "arrow"

/obj/effect/landmark/start/barkeep
	name = "Barkeep"
	icon_state = "arrow"

/obj/effect/landmark/start/manorguardsman
	name = "Man at Arms"
	icon_state = "arrow"

/obj/effect/landmark/start/bogmaster
	name = "Master Warden"
	icon_state = "arrow"

/obj/effect/landmark/start/bogguardsman
	name = "Bog Guard"
	icon_state = "arrow"
	jobspawn_override = list("Bog Guard", "Vanguard")

/obj/effect/landmark/start/dungeoneer
	name = "Dungeoneer"
	icon_state = "arrow"

/obj/effect/landmark/start/watchman
	name = "Gatemaster"
	icon_state = "arrow"

/obj/effect/landmark/start/priest
	name = "Bishop"
	icon_state = "arrow"

/obj/effect/landmark/start/puritan
	name = "Inquisitor"
	icon_state = "arrow"

/obj/effect/landmark/start/inqlate
	name = "Inquisition Late"
	delete_after_roundstart = FALSE
	jobspawn_override = list("Absolver", "Orthodoxist", "Inquisitor")

/obj/effect/landmark/start/nightman
	name = "Bathmaster"
	icon_state = "arrow"

/obj/effect/landmark/start/nightmaiden
	name = "Bathhouse Attendant"
	icon_state = "arrow"

/obj/effect/landmark/start/beastmonger
	name = "Butcher"
	icon_state = "arrow"

/obj/effect/landmark/start/knavewench
	name = "Tapster"
	icon_state = "arrow"

/obj/effect/landmark/start/butler
	name = "Seneschal"
	icon_state = "arrow"

/obj/effect/landmark/start/churchling
	name = "Churchling"
	icon_state = "arrow"

/obj/effect/landmark/start/orphan
	name = "Vagabond"
	icon_state = "arrow"

/obj/effect/landmark/start/sapprentice
	name = "Smithy Apprentice"
	icon_state = "arrow"

//tribal

/obj/effect/landmark/start/tribalchieftain
	name = "Chieftain"
	icon_state = "arrow"

/obj/effect/landmark/start/tribalshaman
	name = "Tribal Shaman"
	icon_state = "arrow"

/obj/effect/landmark/start/tribalguard
	name = "Tribal Guard"
	icon_state = "arrow"

/obj/effect/landmark/start/tribalrabble
	name =  "Tribal Rabble"
	icon_state = "arrow"

/obj/effect/landmark/start/tribalvillager
	name = "Tribal"
	icon_state = "arrow"

/obj/effect/landmark/start/tribelate
	name = "Tribal Late"
	delete_after_roundstart = FALSE
	jobspawn_override = list("Chieftain", "Tribal Shaman", "Tribal Guard", "Tribal Rabble", "Tribal Villager")
