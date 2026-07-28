// Ported from Vanderlin (OpenKeep): code/datums/materials/clay/_base.dm
//
// ADAPTATION: this repo already has its own clay item hierarchy under
// /obj/item/natural/clay and /obj/item/natural/clay/porcelain (code/modules/roguetown/roguejobs/
// ceramicist/clay_and_glass.dm, code/game/objects/items/rogueitems/ceramics.dm), used by the
// existing ceramicist job and the ported ceramics_kintsugi.dm pottery. /datum/material/clay/porcelain
// is retargeted at that existing porcelain item type. Vanderlin's fireclay variant has no matching
// item subtype here (no separate "fireclay" item chain), so its solid_form falls back to the base
// raw clay item type with a comment rather than inventing a new item.
/datum/material/clay
	name = "blue gray"
	color = "#7b8183"
	integrity_modifier = 0.25
	solid_form = /obj/item/natural/clay

/datum/material/clay/fireclay
	name = "fire"
	color = "#997e25"
	// No dedicated "fireclay" item subtype exists in this codebase; falls back to base clay item.
	// NOTE: this means /obj/item/natural/clay is ambiguous between /datum/material/clay and this
	// subtype in GLOB.dv_material_bar_map (see materials/_base.dm) - whichever registers first
	// wins the auto-built map. Harmless for clay (no combat stats hang off it) but documented so
	// nobody's surprised if dv_get_material_for_bar() reports plain "blue gray" clay for a fireclay item.
	solid_form = /obj/item/natural/clay

/datum/material/clay/porcelain
	name = "porcelain"
	color = "#e9e7e3"
	solid_form = /obj/item/natural/clay/porcelain
