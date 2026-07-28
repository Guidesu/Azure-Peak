// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/weeping.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/weeping (rogueores.dm).
// The silver_bane trait reference is preserved from Vanderlin's original (lore-wise "Enduring"/
// "weeping" metal is tied to the same silver-touched curse); see material_traits/silver_bane.dm
// for the note on how that trait is a thin stub deferring to this repo's real silver-vs-vampire system.
/datum/material/weeping
	name = "Enduring"
	show_as_filling = TRUE
	color = "#CECA9C"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 10
	integrity_modifier = 1.2
	solid_form = /obj/item/ingot/weeping

	traits = list(
		/datum/material_trait/silver_bane
	)

	value_modiifer = 2.25
