// Renamed from "The Otavan Accords" - Otava no longer exists as a nation under the new cosmology, so its Inquisition
// treaty is reassigned to Vergenmark: the Tribunal enclave whose harsher fringe (never officially called an
// Inquisition, though everyone knows what it is) plays the same "foreign zealots operating by treaty" role.
/datum/decree/otavan_accords
	id = DECREE_OTAVAN_ACCORDS
	name = "The Vergenmark Accords"
	category = DECREE_CATEGORY_NEW
	mechanical_text = "Inquisition members pay no taxes."
	flavor_text = {"In the name of the Word, under Praecursor's watch, be it known that Vergenmark's harsher fringe, sworn servants of Praecursor and emissaries of the Tribunal, shall keep vigil against heresy athupon this land: to defend and protect the Duchy of Azuria from those who would do it harm, and to counsel and advise the leaders and peoples of the nation. This fringe is hereby granted the right to try foreigners, those sanctioned and outlawed by the Duchy for crimes of high heresy, or those who are handed over by order of Crown and Court. They are to be granted permission to aid in trials of citizenry alongside the lawful authorities of the land, save for the Nobility, who must be tried before the Crown.

In exchange, as foreign adherents sanctioned by treaty, they shall bear no tax nor levy, neither upon their persons nor upon the instruments of their office; nor shall the Crown hinder their holy duty, save by lawful cause shown before the Bishop or Council.

Yeven under the seal of the Crown, in witness of Praecursor and the Six."}
	revoke_text = "The %RULER% has broken the Vergenmark Accords. Vergenmark's harsher fringe is stripped of its treaty protections - and Vergenmark shall not take such an insult lightly."
	restore_text = "The %RULER% has affirmed the Vergenmark Accords. Vergenmark's harsher fringe resumes its duty to purge the land of heretics, free from the Crown's interference."

/datum/decree/otavan_accords/roll_initial_year()
	return 1492 // Canonical year

/datum/decree/otavan_accords/apply_exemption(mob/living/payer, tax_category)
	if(!active)
		return FALSE
	if(payer.job in GLOB.inquisition_positions)
		return TRUE
	return FALSE
