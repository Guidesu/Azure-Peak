GLOBAL_LIST_EMPTY(loadout_items)
GLOBAL_LIST_EMPTY(loadout_items_by_name)

/datum/loadout_item
	var/name = "Parent loadout datum"
	var/desc
	var/path
	var/cost = 1				//point cost in the loadout budget
	var/donoritem				//autoset on new if null
	var/list/ckeywhitelist
	var/donator_unlocked = FALSE
	var/triumph_cost
	var/sort_category = "Misc" 	//Used for sorting loadout items in the menu. Should be one of the following: One per each file

/datum/loadout_item/New()
	if(isnull(donoritem))
		if(ckeywhitelist || donator_unlocked)
			donoritem = TRUE
	// All triumph costs removed - everything is free
	triumph_cost = 0
	if(!isnull(path)) // First item in the loadout list is the parent datum, so we want to skip it
		var/obj/targetitem = path
		desc = targetitem.desc

// All donator/triumph restrictions removed - everyone can access everything
/datum/loadout_item/proc/donator_ckey_check(key)
	return TRUE
