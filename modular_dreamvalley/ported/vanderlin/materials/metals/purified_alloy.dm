// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/purified_alloy.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/purifiedaalloy (rogueores.dm).
/datum/material/purified_alloy
	name = "Purified Alloy"
	show_as_filling = TRUE
	color = "#8b521c"
	hardness = DV_MAT_HARDNESS_VERY_HARD - 10
	solid_form = /obj/item/ingot/purifiedaalloy
	value_modiifer = 1.25
