/datum/tat_directions
	var/datum/tat_build/owner_build
	var/foundation = TAT_FOUNDATION_SETTLED
	var/role_choice = TAT_ROLE_CHOICE_STARTER
	var/list/points = list()

/datum/tat_directions/New(datum/tat_build/B)
	. = ..()
	owner_build = B
	reset()

/datum/tat_directions/proc/reset()
	foundation = TAT_FOUNDATION_SETTLED
	role_choice = TAT_ROLE_CHOICE_STARTER
	points = list()
	for(var/direction in TAT_DIRECTION_ORDER)
		points[direction] = 0
	return TRUE

// Foundation and role normalizers retained for save compatibility only.
// The singular archetype ignores all role/foundation branching.
/datum/tat_directions/proc/normalize_foundation(value)
	if(value == TAT_FOUNDATION_WANDERER)
		return TAT_FOUNDATION_WANDERER
	return TAT_FOUNDATION_SETTLED

/datum/tat_directions/proc/get_default_role_for_foundation(value)
	value = normalize_foundation(value)
	return TAT_ROLE_CHOICE_STARTER

/datum/tat_directions/proc/normalize_role_choice(value, foundation_value = null)
	return TAT_ROLE_CHOICE_STARTER

/datum/tat_directions/proc/normalize_direction(direction)
	if(direction in TAT_DIRECTION_ORDER)
		return direction
	return null

/datum/tat_directions/proc/set_foundation(value)
	foundation = normalize_foundation(value)
	role_choice = TAT_ROLE_CHOICE_STARTER
	owner_build?.traits?.sanitize()
	owner_build?.skills?.refresh_after_trait_change()
	owner_build?.items?.sanitize()
	owner_build?.set_dirty()
	return TRUE

/datum/tat_directions/proc/set_role_choice(value)
	role_choice = TAT_ROLE_CHOICE_STARTER
	owner_build?.traits?.sanitize()
	owner_build?.skills?.refresh_after_trait_change()
	owner_build?.items?.sanitize()
	owner_build?.set_dirty()
	return TRUE

/datum/tat_directions/proc/get_role_choice()
	return TAT_ROLE_CHOICE_STARTER

/datum/tat_directions/proc/get_effective_role_trait()
	return null

/datum/tat_directions/proc/is_role_trait(trait_id)
	return FALSE

/datum/tat_directions/proc/get_role_choice_for_trait(trait_id)
	return null

/datum/tat_directions/proc/adopt_legacy_role_traits()
	if(!owner_build?.traits)
		return FALSE
	for(var/trait_id in owner_build.traits.selected)
		var/legacy_role = get_role_choice_for_trait(trait_id)
		if(!legacy_role)
			continue
		return TRUE
	return FALSE

/datum/tat_directions/proc/get_points(direction)
	direction = normalize_direction(direction)
	if(!direction)
		return 0
	return get_allocated_points(direction)

/datum/tat_directions/proc/get_allocated_points(direction)
	direction = normalize_direction(direction)
	if(!direction)
		return 0
	return max(0, round(points[direction] || 0))

/datum/tat_directions/proc/get_role_direction_points(direction)
	return 0

/datum/tat_directions/proc/is_towner_battle_direction(direction)
	return FALSE

/datum/tat_directions/proc/get_triangular_cost(value)
	value = max(0, round(text2num("[value]") || 0))
	return value

/datum/tat_directions/proc/get_discounted_towner_battle_cost(value)
	return max(0, round(text2num("[value]") || 0))

/datum/tat_directions/proc/has_towner_hunter_direction_discount(direction)
	return FALSE

/datum/tat_directions/proc/get_towner_battle_allocated_points(direction_override = null, override_value = null)
	return 0

/datum/tat_directions/proc/get_towner_battle_spent_points(direction_override = null, override_value = null)
	return 0

/datum/tat_directions/proc/get_spent_points(direction_override = null, override_value = null)
	var/total = 0
	for(var/direction in TAT_DIRECTION_ORDER)
		if(direction_override && direction == direction_override)
			total += max(0, round(text2num("[override_value]") || 0))
		else
			total += get_allocated_points(direction)
	total += get_ordinary_trait_spent_points()
	return total

/datum/tat_directions/proc/get_ordinary_trait_spent_points()
	if(!owner_build?.traits)
		return 0
	var/total = 0
	for(var/trait_id in owner_build.traits.selected)
		if(get_trait_direction(trait_id) != TAT_DIRECTION_ORDINARY)
			continue
		total += get_trait_cost(trait_id) * owner_build.traits.get_trait_count(trait_id)
	return total

/datum/tat_directions/proc/get_next_point_cost(direction)
	direction = normalize_direction(direction)
	if(!direction)
		return 0
	var/current = get_allocated_points(direction)
	return max(0, get_spent_points(direction, current + 1) - get_spent_points())

/datum/tat_directions/proc/get_total_points()
	return TAT_DIRECTION_POINTS + (owner_build?.traits?.get_bonus_direction_points() || 0)

/datum/tat_directions/proc/get_role_bonus_points()
	return 0

/datum/tat_directions/proc/get_remaining_points()
	return get_total_points() - get_spent_points()

/datum/tat_directions/proc/set_points(direction, value)
	direction = normalize_direction(direction)
	if(!direction)
		return FALSE
	value = max(0, round(text2num("[value]") || 0))
	var/current = get_allocated_points(direction)
	if(value == current)
		return TRUE
	if(value > current && get_spent_points(direction, value) > get_total_points())
		return FALSE
	points[direction] = value
	owner_build?.traits?.sanitize()
	owner_build?.skills?.refresh_after_trait_change()
	owner_build?.items?.sanitize()
	owner_build?.set_dirty()
	return TRUE

/datum/tat_directions/proc/add_point(direction, amount = 1)
	direction = normalize_direction(direction)
	if(!direction)
		return FALSE
	amount = max(1, round(text2num("[amount]") || 1))
	return set_points(direction, get_points(direction) + amount)

/datum/tat_directions/proc/remove_point(direction, amount = 1)
	direction = normalize_direction(direction)
	if(!direction)
		return FALSE
	amount = max(1, round(text2num("[amount]") || 1))
	return set_points(direction, get_points(direction) - amount)

/datum/tat_directions/proc/get_trait_rule(trait_id)
	var/list/rule = GLOB.tat_direction_trait_rules[trait_id]
	if(islist(rule))
		return rule
	// The single Starter archetype deliberately removed the old web of
	// role/foundation gates. Every normal TAT trait, including the virtue
	// adapters, therefore spends from the shared Ordinary direction pool.
	if(owner_build?.traits?.check_trait(trait_id))
		return list("direction" = TAT_DIRECTION_ORDINARY, "requirements" = list(), "tier" = 0)
	return null

/datum/tat_directions/proc/is_direction_trait(trait_id)
	return islist(get_trait_rule(trait_id))

/datum/tat_directions/proc/get_trait_direction(trait_id)
	var/list/rule = get_trait_rule(trait_id)
	return rule ? rule["direction"] : null

/datum/tat_directions/proc/is_handicraft_cluster_trait(trait_id)
	return trait_id == TAT_TRAIT_MASTER_OF_CRAFTING || trait_id == TAT_TRAIT_STRAYING_SOUL

/datum/tat_directions/proc/get_first_selected_handicraft_cluster_trait()
	if(!owner_build?.traits?.selected)
		return null
	for(var/trait_id in owner_build.traits.selected)
		if(is_handicraft_cluster_trait(trait_id) && owner_build.traits.get_trait_count(trait_id) > 0)
			return trait_id
	return null

/datum/tat_directions/proc/get_handicraft_cluster_trait_cost(trait_id)
	if(!is_handicraft_cluster_trait(trait_id))
		return -1
	return max(0, owner_build?.traits?.get_base_cost(trait_id) || 0)

/datum/tat_directions/proc/get_trait_cost(trait_id)
	// Point system removed - all traits are free.
	return 0

/datum/tat_directions/proc/get_trait_tier(trait_id)
	var/list/rule = get_trait_rule(trait_id)
	return rule ? max(0, round(rule["tier"] || 0)) : 0

/datum/tat_directions/proc/get_trait_requirements(trait_id)
	// Point system removed - no direction point requirements.
	return list()

/datum/tat_directions/proc/trait_requirements_met(trait_id)
	// Freeform: all direction requirements removed
	return TRUE

/datum/tat_directions/proc/get_trait_requirement_text(trait_id)
	// Freeform: no requirement text
	return null

/datum/tat_directions/proc/get_spent_trait_points(direction)
	// Point system removed - no direction point spending.
	return 0

/datum/tat_directions/proc/get_remaining_trait_points(direction)
	direction = normalize_direction(direction)
	if(!direction)
		return 0
	return get_points(direction) - get_spent_trait_points(direction)

/datum/tat_directions/proc/can_select_trait(trait_id)
	if(!is_direction_trait(trait_id))
		return TRUE
	// Freeform: no direction point requirements, any trait can be selected
	return TRUE

/datum/tat_directions/proc/get_trait_block_reason(trait_id)
	if(!is_direction_trait(trait_id))
		return null
	// Freeform: no direction point requirements or block reasons
	return null

/datum/tat_directions/proc/sanitize()
	if(!islist(points))
		points = list()
	adopt_legacy_role_traits()
	foundation = normalize_foundation(foundation)
	role_choice = TAT_ROLE_CHOICE_STARTER
	if(round(text2num("[points[TAT_DIRECTION_DEFENSE]]") || 0) > 0)
		points[TAT_DIRECTION_COMBAT] = max(0, round(points[TAT_DIRECTION_COMBAT] || 0)) + max(0, round(text2num("[points[TAT_DIRECTION_DEFENSE]]") || 0))
		points -= TAT_DIRECTION_DEFENSE
	for(var/key in points.Copy())
		if(!(key in TAT_DIRECTION_ORDER))
			points -= key
	for(var/direction in TAT_DIRECTION_ORDER)
		points[direction] = max(0, round(text2num("[points[direction]]") || 0))
	while(get_spent_points() > get_total_points())
		var/changed = FALSE
		var/list/order = TAT_DIRECTION_ORDER
		var/i = length(order)
		while(i >= 1)
			var/direction = order[i]
			if(get_allocated_points(direction) <= 0)
				i--
				continue
			points[direction] = get_allocated_points(direction) - 1
			changed = TRUE
			break
		if(!changed)
			break
	return TRUE

/datum/tat_directions/proc/export_to_list()
	sanitize()
	var/list/exported_points = list()
	for(var/direction in TAT_DIRECTION_ORDER)
		exported_points[direction] = get_allocated_points(direction)
	return list(
		"foundation" = foundation,
		"role_choice" = TAT_ROLE_CHOICE_STARTER,
		"points" = exported_points,
	)

/datum/tat_directions/proc/import_from_list(list/data, run_sanitize = TRUE)
	reset()
	if(!islist(data))
		return FALSE
	foundation = normalize_foundation(data["foundation"])
	role_choice = TAT_ROLE_CHOICE_STARTER
	var/list/imported_points = data["points"]
	if(islist(imported_points))
		for(var/direction in imported_points)
			var/normalized = direction == TAT_DIRECTION_DEFENSE ? TAT_DIRECTION_COMBAT : normalize_direction(direction)
			if(normalized)
				points[normalized] = max(0, round(points[normalized] || 0)) + max(0, round(text2num("[imported_points[direction]]") || 0))
	if(run_sanitize)
		sanitize()
	return TRUE

/datum/tat_directions/proc/export_to_json_list()
	return export_to_list()

/datum/tat_directions/proc/import_from_json_list(list/data, run_sanitize = TRUE)
	return import_from_list(data, run_sanitize)

/datum/tat_directions/proc/build_ui_state()
	var/list/result = list()
	for(var/direction in TAT_DIRECTION_ORDER)
		result[direction] = list(
			"points" = 0,
			"spent" = 0,
			"remaining" = 0,
			"next_cost" = 0,
			"name" = GLOB.tat_direction_names[direction] || direction,
		)
	return list(
		"foundation" = foundation,
		"role_choice" = TAT_ROLE_CHOICE_STARTER,
		"points_total" = 0,
		"points_spent" = 0,
		"points_remaining" = 0,
		"directions" = result,
		"foundation_names" = GLOB.tat_foundation_names,
		"foundation_role_choices" = GLOB.tat_foundation_role_choices,
		"role_choice_names" = GLOB.tat_role_choice_names,
		"direction_order" = TAT_DIRECTION_ORDER,
	)

