// Ported from Vanderlin (OpenKeep) code/datums/relations/grudge/_grudge_type.dm
// and generic_grudges.dm.
//
// Vanderlin indexed grudge flavor text into pools keyed by exact job-title
// pairs and by department bitflags (dept_flag_to_key, GLOB.grudge_pool_by_job,
// GLOB.grudge_pool_by_dept), built at round start from every job's
// aggressor_titles/victim_titles and consumed by an automatic rival
// matchmaking pass hooked into SSticker after DivideOccupations.
//
// This repo's job system has no equivalent round-start occupation-division
// hook and explicitly deprecates department_flag (see
// code/modules/jobs/job_types/_job.dm: "var/department_flag = NONE
// //Deprecated"), so none of that pooling/matchmaking infrastructure is
// ported. Only the job-agnostic generic grudge flavors are kept; they are
// picked directly by the player-facing "Hold a Grudge" verb
// (relations_verbs.dm) rather than auto-assigned at round start.

/datum/grudge_type
	abstract_type = /datum/grudge_type
	/// The name of this grudge.
	var/grudge_name = "Generic Grudge"
	/// The aggressor's side of the grudge text.
	var/aggressor_text = "Generic statement."
	/// The victim's side of the grudge text.
	var/victim_text = "Generic statement."

/datum/grudge_type/old_debt
	grudge_name = "Old Debt"
	aggressor_text = "You owe them something and have been avoiding making it right."
	victim_text = "They owe you something and have made no effort to settle it."

/datum/grudge_type/public_embarrassment
	grudge_name = "Public Embarrassment"
	aggressor_text = "You said something at their expense that drew a laugh from the wrong crowd."
	victim_text = "They mocked you in front of others and the moment has not left you."

/datum/grudge_type/broken_promise
	grudge_name = "Broken Promise"
	aggressor_text = "You made a commitment to them that you did not keep."
	victim_text = "They made you a promise and never followed through."

/datum/grudge_type/reputation_damage
	grudge_name = "Reputation Damage"
	aggressor_text = "Rumours you may have spread came back to colour how others see them."
	victim_text = "Rumours traced back to them have made your reputation worse than you deserve."

GLOBAL_LIST_EMPTY(dreamvalley_grudge_pool_generic)

/proc/dreamvalley_build_grudge_pool()
	GLOB.dreamvalley_grudge_pool_generic = list()
	for(var/grudge_path in subtypesof(/datum/grudge_type))
		var/datum/grudge_type/G = grudge_path
		if(initial(G.grudge_name) == "Generic Grudge")
			continue
		GLOB.dreamvalley_grudge_pool_generic += grudge_path
