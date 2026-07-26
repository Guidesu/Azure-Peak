// Ported from Vanderlin (OpenKeep) code/datums/relations/{acquaintance,
// friend,rival,enemy,crossed,served_together}.dm.
//
// Not ported: family/spouse/divorced/ex — this repo has no marriage or
// romantic-partner tracking system (grepped for TRAIT_MARRIED, marry procs,
// found nothing), so those relation types would have nothing to hook into
// and are omitted rather than fabricated.

/datum/relation/acquaintance
	name = "Acquaintance"
	desc = "Someone you have crossed paths with."
	upgrades = list(/datum/relation/had_crossed, /datum/relation/was_crossed)

/datum/relation/acquaintance/get_desc_string()
	return "[holder?.name] and [other?.name] have met before."

/datum/relation/friend
	name = "Friend"
	desc = "You have known them for a while and get along well."
	incompatible = list(/datum/relation/enemy)
	upgrades = list(/datum/relation/acquaintance, /datum/relation/rival)
	category = "Friend"

/datum/relation/friend/get_desc_string()
	return "[holder?.name] and [other?.name] seem to be on good terms."

/datum/relation/enemy
	name = "Enemy"
	desc = "You have known them for a while and really cannot stand each other."
	incompatible = list(/datum/relation/friend)
	upgrades = list(/datum/relation/acquaintance, /datum/relation/rival)

/datum/relation/enemy/get_desc_string()
	return "[holder?.name] and [other?.name] do not get along well."

/datum/relation/rival
	name = "Rival"
	desc = "You are engaged in a constant struggle to prove who is the better."
	upgrades = list(/datum/relation/acquaintance)
	category = "Rival"

/datum/relation/rival/get_desc_string()
	return "[holder?.name] and [other?.name] are fiercely competitive with one another."

/datum/relation/had_crossed
	name = "Crossed"
	desc = "You have slighted them in the past and they likely hold a grudge."
	symmetric = FALSE

/datum/relation/had_crossed/get_desc_string()
	return "Something happened between [holder?.name] and [other?.name], and [other?.name] is upset about it."

/datum/relation/was_crossed
	name = "Was Crossed"
	desc = "You were slighted by them in the past and you remember it."
	symmetric = FALSE

/datum/relation/was_crossed/get_desc_string()
	return "Something happened between [holder?.name] and [other?.name], and [holder?.name] is upset about it."

/datum/relation/served_together
	name = "Served Together"
	desc = "You crossed paths during active service together."
	upgrades = list(/datum/relation/acquaintance)

/datum/relation/served_together/get_desc_string()
	return "[holder?.name] and [other?.name] served together at some point."
