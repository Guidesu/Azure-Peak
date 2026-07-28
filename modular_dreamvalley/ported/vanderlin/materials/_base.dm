// Ported from Vanderlin (OpenKeep): code/datums/materials/_base.dm
//
// SCOPE NOTE: this is Vanderlin's crafting-material-IDENTITY layer (what an
// item is MADE OF: steel, bronze, blacksteel, etc), NOT this repo's item
// quality-tier system (how WELL an item was made: crude/fine/masterwork,
// see code/__DEFINES/item_quality.dm) and NOT the base SS13 engine material
// system (code/__DEFINES/materials.dm, SSmaterials, MAT_CATEGORY_*,
// getmaterialref()). All three are independent and can coexist on the same
// item. Do not confuse the three.
//
// Vanderlin's /datum/material used a `hardness` var driven by MAT_VALUE_*
// defines that don't exist in this codebase (they aren't the same as this
// repo's MAT_CATEGORY_* engine defines). Rather than collide with or
// silently alias the engine's namespace, this port defines its own
// DV_MAT_HARDNESS_* constants below, scoped to this material-identity layer
// only. Numeric values match Vanderlin's original MAT_VALUE_* scale.
#define DV_MAT_HARDNESS_SOFT       5
#define DV_MAT_HARDNESS_FLEXIBLE   10
#define DV_MAT_HARDNESS_RIGID      15
#define DV_MAT_HARDNESS_HARD       20
#define DV_MAT_HARDNESS_VERY_HARD  30

/datum/material
	abstract_type = /datum/material

	var/name
	///temperature in kelvin this melts at, until we get refiners this is largely not a thing
	var/melting_point = 1358.15
	///our materials color
	var/color
	/// What object does this material form when solidified. Ported materials point this at
	/// ingot/bar item types that already exist in this codebase (code/modules/roguetown/roguejobs/miner/rogueores.dm)
	/// rather than introducing new duplicate ingot items.
	var/obj/item/solid_form
	/// Should we show up as part of reagent fillings? Kept from Vanderlin for datum parity, but this
	/// repo has no molten-metal reagent (see molten_materials/_base.dm note) so this currently has no reader.
	var/show_as_filling = FALSE

	///the temperature it "finishes" at finishing can be different for various things
	var/finishing_temperature = 700
	///the integrity modifier applied to created gear
	var/integrity_modifier = 1
	///our value modifier
	var/value_modiifer = 1
	///basically a list of material traits think things like firestarter etc
	var/list/traits = list()
	///how hard our material is
	var/hardness

/**
 * DreamValley integration layer.
 *
 * Vanderlin attaches /datum/material identity to gear implicitly through its smeltery/reagent
 * chemistry (molten metal reagents merge and solidify into a specific material's ingot). This
 * repo's blacksmithing instead crafts directly from typed ingot items (/obj/item/ingot/steel,
 * /obj/item/ingot/silver, etc, see rogueores.dm) via /datum/anvil_recipe.req_bar. So the natural,
 * lowest-risk hook point here is: tag each existing ingot type with the material datum it
 * represents, then propagate that tag onto whatever the ingot is forged into.
 */

/// Global lookup: ingot/bar item typepath -> the /datum/material type it represents.
/// Auto-populated from every concrete /datum/material's solid_form var (see dv_build_material_bar_map
/// below), so individual material files just need to set solid_form and don't need any separate
/// registration boilerplate.
GLOBAL_LIST_INIT(dv_material_bar_map, dv_build_material_bar_map())

/proc/dv_build_material_bar_map()
	var/list/map = list()
	for(var/datum/material/mat_type as anything in subtypesof(/datum/material))
		if(IS_ABSTRACT(mat_type))
			continue
		var/obj/item/bar_type = initial(mat_type.solid_form)
		if(!bar_type)
			continue
		// First material to claim a given bar type wins; ported materials are 1:1 with their
		// bars so this should never actually collide, but favor determinism over a runtime error.
		if(!map[bar_type])
			map[bar_type] = mat_type
	return map

/proc/dv_get_material_for_bar(obj/item/bar)
	if(!bar)
		return null
	return dv_get_material_for_bar_type(bar.type)

/// Typepath variant of dv_get_material_for_bar - used where only the bar's typepath is available,
/// e.g. /datum/anvil_recipe.req_bar (see item_hooks.dm), which stores a typepath rather than an
/// item instance.
/proc/dv_get_material_for_bar_type(obj/item/bar_type)
	if(!ispath(bar_type, /obj/item))
		return null
	var/matched_type = GLOB.dv_material_bar_map[bar_type]
	if(matched_type)
		return matched_type
	// fall back to walking up the type tree, in case of a bar subtype (e.g. blessed variants)
	// we didn't explicitly register (see ingot/steelholy, ingot/silverblessed in rogueores.dm).
	for(var/registered_type in GLOB.dv_material_bar_map)
		if(ispath(bar_type, registered_type))
			return GLOB.dv_material_bar_map[registered_type]
	return null
