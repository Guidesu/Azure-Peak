// JUDGMENT CALL - not a direct port. Vanderlin's upstream RTS source has a
// /obj/effect/building_node/tannery (code/datums/rts/building_node/tannery.dm,
// ported verbatim in building_node/tannery.dm) and a
// /datum/persistant_workorder/tan_leather job (persistant/tan_leather.dm)
// that dispatches /datum/work_order/tan_leather - but NO
// /datum/building_datum/tannery and NO tannery.dmm map template anywhere in
// the source tree (confirmed by grep across E:\GitHub\Vanderlin\code\datums\rts
// and E:\GitHub\Vanderlin\_maps\templates\buildings - "tannery" only appears
// in building_node/tannery.dm and the two tan_leather work-order files).
// Upstream's tannery building_node is unfinished/orphaned content: it exists
// in code but has no way to ever be placed in a real game.
//
// Since this port's task explicitly asks for a purchasable Tannery building
// (matching Blacksmith/Kitchen/Bar/etc's shape), this building_datum plus its
// map_templates/tannery.dm wrapper and _maps/templates/buildings/tannery.dmm
// are NEW FILES authored for this port, not ports of an existing upstream
// file - they follow the exact same shape as building_datums/mines.dm
// (free build, no resource cost, single required worker) since upstream gives
// no cost/template hints to follow.
/datum/building_datum/tannery
	name = "Tannery"
	desc = "This is where hides are tanned into leather."

	building_template = "tannery"

	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "leather"
