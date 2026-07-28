// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/glimmering_slag.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/aaslag (rogueores.dm).
/datum/material/glimmering_slag
	name = "Glimmering Slag"
	show_as_filling = TRUE
	color = "#8b521c"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 10
	integrity_modifier = 0.85
	solid_form = /obj/item/ingot/aaslag
	value_modiifer = 1.1
