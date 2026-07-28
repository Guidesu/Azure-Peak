// Ported from Vanderlin (OpenKeep): code/datums/rts/building_datums/lumber_yard.dm
// Direct port. Note: upstream's desc text is a copy-paste leftover from
// mines.dm ("You can get ores, stones, and coal from here.."), which doesn't
// describe a lumber yard at all - kept verbatim here for parity with
// upstream since it's purely cosmetic (building_menu.dm tooltip text) and
// touching it isn't part of this port's scope.
/datum/building_datum/lumber_yard
	name = "Lumber Yard"
	desc = "You can get ores, stones, and coal from here.."

	building_template = "lumber"

	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "logsmall"
