// Ported from Vanderlin (OpenKeep) code/datums/relations/gossip.dm.
//
// Vanderlin split gossip into "Rumor" and "Noble Gossip" tiers, the latter
// gated behind TRAIT_NOBLE_BLOOD / TRAIT_NOBLE_POWER. Neither trait exists
// in this codebase (grepped code/ — no hits), so the noble tier is folded
// into a single generic gossip tier rather than fabricating a noble-caste
// trait system this repo doesn't have.

/datum/relation_history/gossip
	/// The gossip text as the listener hears it, e.g. "stole from the treasury"
	var/heard_text = ""
	label = "Rumor"
