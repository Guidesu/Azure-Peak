// Ported from Vanderlin (OpenKeep): code/datums/rts/stockpile_datum.dm
// MAT_* constants renamed to DV_RTS_MAT_* - see _defines.dm header comment.
/datum/stockpile
	var/list/stored_materials = list(
		DV_RTS_MAT_STONE = 0,
		DV_RTS_MAT_WOOD = 0,
		DV_RTS_MAT_GEM = 0,
		DV_RTS_MAT_ORE = 0,
		DV_RTS_MAT_INGOT = 0,
		DV_RTS_MAT_COAL = 0,
		DV_RTS_MAT_GRAIN = 5,
		DV_RTS_MAT_MEAT = 0,
		DV_RTS_MAT_VEG = 0,
		DV_RTS_MAT_FRUIT = 0,
	)

/datum/stockpile/proc/has_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			return FALSE
		if(stored_materials[resource] < resources_to_spend[resource])
			return FALSE
	return TRUE

/datum/stockpile/proc/has_any_resources(list/resources_to_spend)
	var/has_any = FALSE
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			continue
		if(stored_materials[resource] >= 0)
			has_any = TRUE
	return has_any

/datum/stockpile/proc/add_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			continue
		stored_materials[resource] += resources_to_spend[resource]
	return TRUE

/datum/stockpile/proc/remove_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			continue
		stored_materials[resource] -= resources_to_spend[resource]
	return TRUE
