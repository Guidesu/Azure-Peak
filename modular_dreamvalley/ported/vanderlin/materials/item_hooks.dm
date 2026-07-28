// DreamValley integration glue for the ported Vanderlin material-identity system (see _base.dm
// for the overall design note). Not present in Vanderlin as a standalone file - Vanderlin wires
// material identity through its molten-metal reagent chemistry instead, which this repo doesn't
// have. This file is the equivalent "attach material to item" plumbing, built against this repo's
// actual ingot-based blacksmithing.
//
// Hook point chosen: a new var/datum/material/base_material directly on /obj/item, placed beside
// the existing item_quality/has_item_quality vars in code/game/objects/items.dm (same base class,
// same neighborhood) so the two concepts are visibly siblings rather than entangled. base_material
// is independent of item_quality: a "masterwork blacksteel longsword" is base_material = blacksteel
// AND item_quality = ITEM_QUALITY_MASTERWORK at the same time.
//
/obj/item
	/// What this item is made of, in Vanderlin material-identity terms (steel, bronze, blacksteel...).
	/// Independent of item_quality/has_item_quality above - material is WHAT it's made of, quality is
	/// HOW WELL it was made. Null means "no tracked material identity" (most items - this is opt-in,
	/// populated for blacksmithed gear via apply_material_from_bar() below).
	var/datum/material/base_material = null

// /obj/item/ingot subtypes are tagged with their represented /datum/material below (rather than
// editing rogueores.dm directly, keeping every Vanderlin-sourced line inside modular_dreamvalley/ported).
/obj/item/ingot/iron
	base_material = /datum/material/iron
/obj/item/ingot/copper
	base_material = /datum/material/copper
/obj/item/ingot/tin
	base_material = /datum/material/tin
/obj/item/ingot/bronze
	base_material = /datum/material/bronze
/obj/item/ingot/silver
	base_material = /datum/material/silver
/obj/item/ingot/steel
	base_material = /datum/material/steel
/obj/item/ingot/blacksteel
	base_material = /datum/material/blacksteel
/obj/item/ingot/gold
	base_material = /datum/material/gold
/obj/item/ingot/aalloy
	base_material = /datum/material/ancient_alloy
/obj/item/ingot/purifiedaalloy
	base_material = /datum/material/purified_alloy
/obj/item/ingot/aaslag
	base_material = /datum/material/glimmering_slag
/obj/item/ingot/weeping
	base_material = /datum/material/weeping
/obj/item/ingot/draconic
	base_material = /datum/material/draconic
/obj/item/ingot/lithmyc
	base_material = /datum/material/lithmyc
/obj/item/ingot/ketryl
	base_material = /datum/material/ketryl
/obj/item/ingot/avantyne
	base_material = /datum/material/avantyne

/// Copies a bar/ingot type's material identity onto a freshly crafted item. Called from
/// /datum/anvil_recipe/proc/handle_creation (Vanderlin-parallel integration point - that's where
/// Vanderlin-style "recipe finished, stamp the product" logic belongs) with the req_bar typepath
/// that recipe required (req_bar is a typepath, not an instance - see /datum/anvil_recipe.req_bar
/// and its istype(hingot, recipe.req_bar) usage in anvil.dm).
/obj/item/proc/apply_material_from_bar(obj/item/ingot/bar_type)
	if(!ispath(bar_type, /obj/item/ingot))
		return
	var/datum/material/mat_type = initial(bar_type.base_material) || dv_get_material_for_bar_type(bar_type)
	if(!mat_type)
		return
	base_material = mat_type
	if(initial(max_integrity) > 0 && isnum(max_integrity))
		var/mat_integrity_mod = initial(mat_type.integrity_modifier)
		if(mat_integrity_mod && mat_integrity_mod != 1)
			max_integrity = round(max_integrity * mat_integrity_mod)
			obj_integrity = max_integrity

/datum/anvil_recipe/handle_creation(obj/item/I)
	. = ..()
	if(istype(I) && ispath(req_bar, /obj/item/ingot))
		I.apply_material_from_bar(req_bar)
