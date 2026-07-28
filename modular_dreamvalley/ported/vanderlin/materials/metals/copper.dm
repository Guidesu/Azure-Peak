// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/copper.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/copper (rogueores.dm).
/datum/material/copper
	name = "Copper"
	show_as_filling = TRUE
	color = "#b87333"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 10
	integrity_modifier = 0.85
	solid_form = /obj/item/ingot/copper
	value_modiifer = 0.85
