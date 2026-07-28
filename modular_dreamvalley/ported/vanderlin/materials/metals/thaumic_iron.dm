// Ported from Vanderlin (OpenKeep): code/datums/materials/metals/thaumic_iron.dm
//
// JUDGMENT CALL: Vanderlin's solid_form pointed at /obj/item/ingot/thaumic, a thaumaturgy-line
// ingot this repo does not have (no matching ore/smelting chain exists here). Rather than invent
// a new ingot item (out of scope for a materials-identity port) or drop the material entirely,
// the datum is kept for completeness/future use with solid_form left null. It will simply never
// get auto-registered into GLOB.dv_material_bar_map (see _base.dm) until a bar item is added.
/datum/material/thaumic_iron
	name = "Thaumic Iron"
	show_as_filling = TRUE
	color = "#5f4225"
	melting_point = 1811
	value_modiifer = 0.9
