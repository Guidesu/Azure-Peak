// Ported from Vanderlin (OpenKeep): code/datums/rts/building_datums/mines.dm
// Direct port - no MAT_* usage, no adaptation needed. Free-form resource_cost
// inherits the zeroed-out base list from building_datums/_base_datum.dm
// (same as Stockpile), matching upstream (Vanderlin's mines.dm never
// overrides resource_cost either).
/datum/building_datum/mines
	name = "Mine"
	desc = "You can get ores, stones, and coal from here.."

	building_template = "mine"

	ui_icon = 'icons/roguetown/items/ore.dmi'
	ui_icon_state = "orecinnabar"
