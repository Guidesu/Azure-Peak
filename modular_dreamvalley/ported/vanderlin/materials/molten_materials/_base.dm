// Ported from Vanderlin (OpenKeep): code/datums/materials/molten_materials/_base.dm
//
// SCOPE NOTE / DROPPED HALF: Vanderlin's original _base.dm defines TWO things: (1) /datum/molten_recipe,
// a self-contained data-only "combine these raw materials at this temperature into that material"
// recipe datum, and (2) /datum/reagent/molten_metal, a reagent that mobs can drink/carry which
// merges materials together via chemistry (RegisterSignal on COMSIG_REAGENTS_TEMP_CHANGE, etc).
//
// This codebase's smeltery (code/modules/roguetown/roguejobs/blacksmith/smelter.dm,
// code/modules/roguetown/roguejobs/miner/rogueores.dm) is entirely item-based: you smelt an ore
// item into a bar item directly, there is no molten-metal reagent chemistry layer at all. Porting
// /datum/reagent/molten_metal would mean inventing an entire parallel reagent-based smeltery this
// repo doesn't use anywhere, which is well outside "port the material identity layer". That half
// is dropped.
//
// /datum/molten_recipe itself has no reagent dependency in its own definition (try_create() only
// touches a data list and a temperature number, both passed in by the caller), so it's kept as a
// pure combination-recipe datum: useful now as documentation of which materials Vanderlin combines
// into which output, and directly reusable in the future if/when this repo grows a real molten
// smeltery. GLOB.molten_recipes is populated the same way Vanderlin's build-recipe globals are
// gathered elsewhere in this codebase (see e.g. GLOB.material_traits in material_traits/_base.dm).
GLOBAL_LIST_INIT(molten_recipes, dv_build_molten_recipes())

/proc/dv_build_molten_recipes()
	var/list/recipes = list()
	for(var/datum/molten_recipe/recipe_type as anything in subtypesof(/datum/molten_recipe))
		if(IS_ABSTRACT(recipe_type))
			continue
		recipes += new recipe_type()
	return recipes

/datum/molten_recipe
	abstract_type = /datum/molten_recipe
	var/name = "Generic Molten Recipe"
	var/category = "Metallurgy"

	var/list/materials_required = list()
	var/list/output = list()

	var/temperature_required

/datum/molten_recipe/proc/try_create(list/reagent_data, temperature)
	if(temperature < temperature_required)
		return FALSE

	var/list/materials_copy = materials_required.Copy()

	var/list/cared_values = list()
	for(var/item in reagent_data)
		if(!(item in materials_copy))
			continue
		cared_values |= item
		cared_values[item] = reagent_data[item]

	if(!length(cared_values) == length(materials_required))
		return

	var/smallest_multiplier = 0
	for(var/datum/material/material as anything in materials_copy)
		if(cared_values[material] < materials_copy[material])
			return
		var/multiplier = FLOOR(cared_values[material] / materials_copy[material], 1)
		if(!smallest_multiplier || (multiplier < smallest_multiplier))
			smallest_multiplier = multiplier

	return smallest_multiplier
