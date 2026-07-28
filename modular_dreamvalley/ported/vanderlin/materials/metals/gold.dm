// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/gold.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/gold (rogueores.dm).
/datum/material/gold
	name = "Gold"
	show_as_filling = TRUE
	color = "#ffcc33"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 5
	integrity_modifier = 0.5
	solid_form = /obj/item/ingot/gold
	melting_point = 1337
	value_modiifer = 2
