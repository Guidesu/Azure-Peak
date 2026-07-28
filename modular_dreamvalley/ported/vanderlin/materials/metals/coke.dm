// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/coke.dm
//
// ADAPTATION: Vanderlin's solid_form pointed at /obj/item/ore/coal, a type from Vanderlin's own
// ore hierarchy that doesn't exist here. This repo's equivalent raw fuel/smelting item is
// /obj/item/rogueore/coal (code/modules/roguetown/roguejobs/miner/rogueores.dm), so solid_form
// is retargeted there.
/datum/material/coke
	name = "Coke"
	show_as_filling = TRUE
	color = "#1C1C1C"
	solid_form = /obj/item/rogueore/coal
	melting_point = 1600 //Should not melt in a regular smelter
