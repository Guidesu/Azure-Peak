// Ported from Vanderlin (OpenKeep): code/datums/rts/building_datums/farm.dm
// Direct port - no MAT_* usage, no adaptation needed. Free-form resource_cost
// inherits the zeroed-out base list from building_datums/_base_datum.dm
// (same as Stockpile/Mines) since upstream's farm.dm never overrides it.
/datum/building_datum/farm
	name = "Farm"
	desc = "This is where food is grown."

	building_template = "farm"

	ui_icon = 'icons/roguetown/items/produce.dmi'
	ui_icon_state = "wheatchaff"
