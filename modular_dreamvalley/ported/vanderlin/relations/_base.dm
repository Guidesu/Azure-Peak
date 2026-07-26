// Ported from Vanderlin (OpenKeep) code/datums/relations/_base.dm and
// code/datums/relations/grudge/_base.dm.
//
// Vanderlin's full relations system also included round-start "rival
// matchmaking" seeded from job-title/department pools built off SS13
// crew-job infrastructure (DivideOccupations, department_flag weighting,
// a dedicated /datum/controller/subsystem/relations that ran at ticker
// start). This repo's job system marks department_flag as "Deprecated"
// (see code/modules/jobs/job_types/_job.dm) and has no equivalent
// round-start occupation-division hook, so none of that matchmaking
// machinery is ported — relations here are created only by direct player
// action (see relations_verbs.dm), never auto-seeded.
//
// Persistence note: relations live only on the /datum/mind for the
// current life, the same way mind.known_people and mind.notes already do
// in this codebase (see code/datums/mind.dm) — neither of those survive
// a death/respawn today, and this repo's character_graph.dm (Far Travel /
// Continue snapshotting) only captures a single character's own scalar
// state, not cross-mind reference lists, so relations are intentionally
// NOT added to that capture. This matches existing precedent rather than
// inventing a new persistence layer.

/datum/relation
	abstract_type = /datum/relation
	/// Display name shown in UI.
	var/name = "Relation"
	/// Flavour description shown to the holder.
	var/desc = ""
	/// List of /datum/relation_history attached to this relation.
	var/list/relation_history = null
	/// The mind that owns this relation entry.
	var/datum/mind/holder
	/// The mind on the other side.
	var/datum/mind/other
	/// For asymmetric relations, the counterpart datum on other's side.
	var/datum/relation/counterpart = null
	/// Whether this relation is symmetric (both sides share mutual awareness).
	var/symmetric = TRUE
	/// Relation types that cannot coexist with this one on the same pair.
	var/list/incompatible = null
	/// Snapshot of identity data at time of relation creation.
	/// Keys: "name", "job", "species", "gender", "age"
	var/list/snapshot = null
	/// Relation types this one supersedes; adding this relation removes those.
	var/list/upgrades = null
	/// Category string used for UI tab sorting, e.g. "Rival", "Known".
	var/category = "Known"

/// Called when this relation is first established. Override to do setup.
/datum/relation/proc/on_created()
	return

/// Returns TRUE if this relation type should replace an existing one (upgrade path).
/datum/relation/proc/upgrades_relation(datum/relation/other_rel)
	if(!upgrades || !other_rel)
		return FALSE
	return (other_rel.type in upgrades)

/// Returns a sentence describing the relationship from an outside perspective.
/datum/relation/proc/get_desc_string()
	SHOULD_CALL_PARENT(FALSE)
	return "[holder?.name] and [other?.name] have a relationship."

/datum/relation/proc/refresh_snapshot()
	if(!other?.current || !ishuman(other.current))
		return
	var/mob/living/carbon/human/H = other.current
	snapshot = list(
		"name" = H.real_name,
		"job" = H.get_role_title() || "Unknown",
		"species" = H.dna?.species?.name || "Unknown",
		"gender" = H.gender,
		"age" = H.age,
	)

/datum/relation/proc/snapshot_name_only(mob/living/carbon/human/H)
	snapshot = list(
		"name" = H.real_name,
		"job" = null,
		"species" = null,
		"gender" = null,
		"age" = null,
	)

/// Returns TRUE if this relation conflicts with an existing relation type.
/datum/relation/proc/conflicts_with(datum/relation/other_rel)
	if(!incompatible || !other_rel)
		return FALSE
	return (other_rel.type in incompatible)

/// Dissolve this relation from both minds and nullify counterpart links.
/datum/relation/proc/dissolve()
	if(holder)
		holder.relations -= src
	if(symmetric && other)
		for(var/datum/relation/R in other.relations)
			if(R.other == holder && R.type == type)
				other.relations -= R
				break
	if(counterpart)
		counterpart.counterpart = null
		counterpart.dissolve()
		counterpart = null

/// Adds a piece of history to this relation's history list and returns it.
/datum/relation/proc/add_history(datum/relation_history/history)
	LAZYADD(relation_history, history)
	return history

// Renamed from Vanderlin's /datum/history to /datum/relation_history to
// avoid any ambiguity with unrelated "history" concepts in this codebase
// (grep confirmed no existing /datum/history type here, but the more
// specific name is safer given how generic the word is).
/datum/relation_history
	var/label = "Incident"
	var/aggressor_text = ""
	var/victim_text = ""
	var/created_at = 0
	var/datum/mind/aggressor
	var/datum/mind/victim

/datum/relation_history/New(label, aggressor_text, victim_text, datum/mind/aggressor, datum/mind/victim)
	src.label = label
	src.aggressor_text = aggressor_text
	src.victim_text = victim_text
	src.aggressor = aggressor
	src.victim = victim
	src.created_at = world.time

/datum/relation_history/proc/attach_to(datum/relation/R)
	LAZYADD(R.relation_history, src)
	return src
