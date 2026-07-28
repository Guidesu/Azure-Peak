// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/steel.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/steel (rogueores.dm).
/datum/material/steel
	name = "Steel"
	show_as_filling = TRUE
	color = "#5c5454"
	hardness = DV_MAT_HARDNESS_HARD + 5
	integrity_modifier = 1.2
	solid_form = /obj/item/ingot/steel
	melting_point = 1866
