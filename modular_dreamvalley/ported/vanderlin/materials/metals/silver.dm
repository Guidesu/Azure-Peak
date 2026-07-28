// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/silver.dm
// solid_form retargeted to this repo's existing /obj/item/ingot/silver (rogueores.dm).
/datum/material/silver
	name = "Silver"
	show_as_filling = TRUE
	color = "#d1e6e3"
	hardness = DV_MAT_HARDNESS_FLEXIBLE + 10
	integrity_modifier = 0.65
	solid_form = /obj/item/ingot/silver

	// See material_traits/silver_bane.dm: this repo already has a fully wired silver-vs-vampire/
	// werewolf punishment system (/datum/magic_item/mundane/silver, TRAIT_SILVER_WEAK). The ported
	// trait here is kept as a thin marker/reference rather than a competing implementation.
	traits = list(
		/datum/material_trait/silver_bane
	)

	value_modiifer = 1.5
