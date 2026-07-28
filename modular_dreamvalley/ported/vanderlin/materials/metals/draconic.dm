// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/draconic.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/draconic (rogueores.dm).
/datum/material/draconic
	name = "Draconic"
	show_as_filling = TRUE
	color = "#70b8ff"
	hardness = DV_MAT_HARDNESS_HARD + 10
	integrity_modifier = 1.5
	solid_form = /obj/item/ingot/draconic
	melting_point = 1866
	value_modiifer = 3
