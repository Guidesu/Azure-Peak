// Scoped-down port of Vanderlin (OpenKeep)
// code/controllers/subsystem/matchmaker.dm (declares
// /datum/controller/subsystem/relations).
//
// Vanderlin's version ran round-start rival matchmaking across every
// participating mind, weighted by exact job-title match and department
// overlap, using SSticker.minds + a DivideOccupations hook this repo does
// not have. That whole matchmaking pass (assign_rivals, get_rival_candidates,
// try_late_join_rival, seed_rival_grudge, pick_grudge_pool, dept pooling) is
// intentionally NOT ported — see relations_types.dm / grudge_types.dm
// comments for why. What's kept is the one purely mechanical helper both
// the gossip verb and the TGUI "say gossip aloud" action need:
// get_or_create_gossip_relation, which finds or creates the listener's
// one-sided /datum/relation/acquaintance entry for a gossip subject.

SUBSYSTEM_DEF(relations)
	name = "Relations"
	flags = SS_NO_FIRE // Purely event-driven; no periodic processing needed.
	wait = 0

/datum/controller/subsystem/relations/Initialize(timeofday)
	dreamvalley_build_grudge_pool()
	return ..()

/// Finds the listener's existing relation to the subject, or creates a
/// one-sided acquaintance relation for "I've heard of this person."
/datum/controller/subsystem/relations/proc/get_or_create_gossip_relation(datum/mind/listener, datum/mind/subject)
	if(!listener || !subject || listener == subject)
		return null

	for(var/datum/relation/R in listener.relations)
		if(R.other == subject)
			if(!R.snapshot && subject.current && ishuman(subject.current))
				R.snapshot_name_only(subject.current)
			return R

	var/datum/relation/R = new /datum/relation/acquaintance()
	R.holder = listener
	R.other = subject
	R.symmetric = FALSE // listener knows of subject, not necessarily vice versa

	if(subject.current && ishuman(subject.current))
		R.snapshot_name_only(subject.current)

	LAZYADD(listener.relations, R)
	R.on_created()
	return R
