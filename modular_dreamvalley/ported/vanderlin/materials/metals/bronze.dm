// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/bronze.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/bronze (rogueores.dm).
/datum/material/bronze
	name = "Bronze"
	show_as_filling = TRUE
	color = "#ccbc63"
	hardness = DV_MAT_HARDNESS_RIGID + 10
	integrity_modifier = 0.85
	solid_form = /obj/item/ingot/bronze

	value_modiifer = 0.9
