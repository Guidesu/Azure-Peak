// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/ancient_alloy.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/aalloy (rogueores.dm).
/datum/material/ancient_alloy
	name = "Ancient Alloy"
	show_as_filling = TRUE
	color = "#8b521c"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 5
	integrity_modifier = 0.96
	solid_form = /obj/item/ingot/aalloy
	value_modiifer = 1.25
