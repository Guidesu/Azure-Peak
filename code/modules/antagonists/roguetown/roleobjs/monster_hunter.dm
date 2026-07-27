/datum/antagonist/monster_hunter
	name = "Monster Hunter"
	roundend_category = "monster hunters"
	antagpanel_category = "Monster Hunters"
	show_name_in_check_antagonists = FALSE

/datum/antagonist/monster_hunter/get_antag_cap_weight()
	return 0

/datum/antagonist/monster_hunter/on_gain()
	. = ..()
	if(owner)
		owner.special_role = "Monster Hunter"

/datum/antagonist/monster_hunter/on_removal()
	. = ..()
	if(owner)
		owner.special_role = null
