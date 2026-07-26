// Additive hooks on /datum/mind for the relations system, ported from
// Vanderlin (OpenKeep) code/datums/mind.dm (var/list/relations) and the
// get_relation/knows_as/add_relation procs referenced by
// code/controllers/subsystem/matchmaker.dm.
//
// This repo's own code/datums/mind.dm is left untouched (per porting
// rules, never redefine an existing var) — /datum/mind/relations is a new
// var this repo didn't have. Persistence: intentionally none, matching
// mind.known_people / mind.notes which also don't survive character_graph.dm
// snapshotting today (see _base.dm's header comment for the full rationale).

/datum/mind
	var/list/relations = list()

/// Finds the holder's relation of relation_type to target, if any.
/datum/mind/proc/get_relation(datum/mind/target, relation_type)
	if(!target)
		return null
	for(var/datum/relation/R in relations)
		if(R.other == target && (!relation_type || istype(R, relation_type)))
			return R
	return null

/datum/mind/proc/knows_as(datum/mind/target, relation_type)
	return !isnull(get_relation(target, relation_type))

/// Creates and attaches a new relation of relation_type to target. Mirrors
/// the mirrored copy onto target's side when the relation type is symmetric.
/datum/mind/proc/add_relation(datum/mind/target, relation_type)
	if(!target || target == src || !ispath(relation_type, /datum/relation))
		return null
	if(get_relation(target, relation_type))
		return get_relation(target, relation_type)

	var/datum/relation/R = new relation_type()
	R.holder = src
	R.other = target
	R.refresh_snapshot()
	LAZYADD(relations, R)
	R.on_created()

	if(R.symmetric)
		var/datum/relation/R_other = new relation_type()
		R_other.holder = target
		R_other.other = src
		R_other.refresh_snapshot()
		LAZYADD(target.relations, R_other)
		R_other.on_created()
		R.counterpart = R_other
		R_other.counterpart = R

	return R
