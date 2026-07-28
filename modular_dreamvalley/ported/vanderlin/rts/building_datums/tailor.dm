// JUDGMENT CALL - not a direct port. Same situation as building_datums/tannery.dm:
// Vanderlin's upstream has /obj/effect/building_node/tailorshop
// (code/datums/rts/building_node/tailor.dm) and its sew_clothes/craft_gear
// persistent jobs, but NO /datum/building_datum/tailor and NO tailorshop.dmm
// map template anywhere in the source tree - it's unfinished/orphaned
// content upstream, same as the tannery.
//
// This building_datum plus map_templates/tailor.dm and
// _maps/templates/buildings/tailor.dmm are NEW FILES authored for this port,
// matching mines.dm's/tannery.dm's shape (free build, no resource cost,
// single required worker).
/datum/building_datum/tailor
	name = "Tailor Shop"
	desc = "This is where cloth is sewn and gear is made."

	building_template = "tailorshop"

	ui_icon = 'icons/roguetown/items/natural.dmi'
	ui_icon_state = "cloth"
