// The Concordat - Court of Six Seats. Civic, orthodox, and the closest thing Vaeltis has to a "mainstream" church.
// Direct mechanical successor to the old /datum/patron/divine parent. Kept as an abstract parent since all six
// members share the same associated_faith and none of them need Concordat-wide overrides beyond that (unlike the
// old Inhumen, which needed its own profane_words/crafting_recipes pattern).
/datum/patron/concordat
	name = null
	associated_faith = /datum/faith/concordat
