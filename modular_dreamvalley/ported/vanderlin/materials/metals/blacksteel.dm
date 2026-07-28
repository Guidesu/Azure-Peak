// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/blacksteel.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/blacksteel (rogueores.dm).
/datum/material/blacksteel
	name = "Blacksteel"
	show_as_filling = TRUE
	color = "#3f352a"
	hardness = DV_MAT_HARDNESS_VERY_HARD + 10
	integrity_modifier = 1.5
	solid_form = /obj/item/ingot/blacksteel
	melting_point = 1866

	value_modiifer = 1.25
