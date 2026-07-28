// Ported from Vanderlin (OpenKeep): code/datums/materials/molten_materials/metal_combine_recipes.dm
// Pure data recipes (see _base.dm for why these are kept without the reagent chemistry that
// originally invoked them). Materials referenced all exist in metals/ above.
/datum/molten_recipe/bronze
	name = "Bronze"
	materials_required = list(
		/datum/material/copper = 9,
		/datum/material/tin = 1,
	)
	temperature_required = 1423.15
	output = list(
		/datum/material/bronze = 10,
	)

/datum/molten_recipe/blacksteel
	name = "Blacksteel"
	materials_required = list(
		/datum/material/steel = 3,
		/datum/material/silver = 1,
	)
	temperature_required = 1953.15
	output = list(
		/datum/material/blacksteel = 2,
	)

/datum/molten_recipe/steel
	name = "Steel"
	materials_required = list(
		/datum/material/iron = 3,
		/datum/material/coke = 1,
	)
	temperature_required = 1866
	output = list(
		/datum/material/steel = 3,
	)
