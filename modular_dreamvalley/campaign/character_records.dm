/**
 * Durable character-record boundary.
 *
 * A record belongs to the currently loaded preference slot, not merely to a
 * ckey. This lets Character Sheet editing keep its normal meaning while a
 * parked body remains an exact, separate Continue target.
 *
 * Draft records are intentionally marked incomplete until every graph section
 * has a verified serializer and restorer. Incomplete records are never offered
 * by can_continue_character().
 */

/datum/dreamvalley_campaign_manager/proc/character_record_key(client/player)
	if(!player)
		return null
	var/owner_ckey = ckey(player.key)
	if(!length(owner_ckey))
		return null
	var/preference_slot = player.prefs?.loaded_slot
	if(!isnum(preference_slot) || preference_slot < 1)
		preference_slot = player.prefs?.default_slot
	if(!isnum(preference_slot) || preference_slot < 1)
		preference_slot = 1
	return "[owner_ckey]/[preference_slot]"

/datum/dreamvalley_campaign_manager/proc/get_parked_character(client/player)
	var/record_key = character_record_key(player)
	if(!record_key)
		return null
	var/list/record = parked_characters[record_key]
	if(!islist(record))
		return null
	return record

/datum/dreamvalley_campaign_manager/proc/can_continue_character(client/player)
	var/list/record = get_parked_character(player)
	return islist(record) && record["state"] == "parked" && record["complete"] == TRUE

/datum/dreamvalley_campaign_manager/proc/copy_character_records()
	var/list/result = list()
	for(var/record_key in parked_characters)
		var/list/record = parked_characters[record_key]
		if(islist(record))
			result[record_key] = record.Copy()
	return result

/datum/dreamvalley_campaign_manager/proc/load_character_records(list/records)
	parked_characters = list()
	if(!islist(records))
		return TRUE
	for(var/record_key in records)
		var/list/record = records[record_key]
		if(!istext(record_key) || !islist(record))
			continue
		if(record["record_key"] != record_key)
			continue
		// A crash after the staging checkpoint is safe to recover as parked:
		// that checkpoint already contains the complete character graph and no
		// campaign character bodies are restored from the ordinary world graph.
		if((record["state"] in list("parking", "resuming")) && record["complete"] == TRUE)
			record["state"] = "parked"
		parked_characters[record_key] = record.Copy()
	return TRUE

/datum/dreamvalley_campaign_manager/proc/capture_character_draft(mob/living/carbon/human/character)
	if(!character?.client)
		return null
	var/record_key = character_record_key(character.client)
	if(!record_key)
		return null

	var/preference_slot = character.client.prefs?.loaded_slot
	if(!isnum(preference_slot) || preference_slot < 1)
		preference_slot = 1
	var/turf/position = get_turf(character)
	var/list/core = capture_character_core(character)
	var/list/core_issues = validate_character_core(core)

	var/list/equipment_manifest = list()
	for(var/slot_id in ALL_ITEM_SLOTS)
		var/obj/item/equipped = character.get_item_by_slot(slot_id)
		if(equipped)
			equipment_manifest["[slot_id]"] = list(
				"type" = "[equipped.type]",
				"name" = equipped.name,
			)
	for(var/hand_index in 1 to length(character.held_items))
		var/obj/item/held = character.held_items[hand_index]
		if(held)
			equipment_manifest["hand:[hand_index]"] = list(
				"type" = "[held.type]",
				"name" = held.name,
			)

	var/list/record = list(
		"schema_version" = 1,
		"graph_version" = 2,
		"mob_type" = "[character.type]",
		"record_key" = record_key,
		"owner_ckey" = ckey(character.client.key),
		"preference_slot" = preference_slot,
		"state" = "draft",
		"complete" = FALSE,
		"missing_sections" = character_record_missing_sections(core_issues, FALSE),
		"validation_issues" = core_issues,
		"core" = core,
		"position" = list(
			"x" = position?.x,
			"y" = position?.y,
			"z" = position?.z,
			"dir" = character.dir,
		),
		"equipment_manifest" = equipment_manifest,
	)
	return record

/datum/dreamvalley_campaign_manager/proc/validate_character_core(list/core)
	var/list/issues = list()
	if(!islist(core))
		issues += "character_core_missing"
		return issues

	for(var/required_section in list(
		"identity", "vitals", "stats", "skills", "mind", "bodyparts",
		"organs", "traits", "status_effects", "reagents", "items",
	))
		if(!(required_section in core))
			issues += "missing_core_section:[required_section]"

	var/list/capture_issues = core["validation_issues"]
	if(islist(capture_issues))
		issues |= capture_issues

	var/list/item_graph = core["items"]
	var/list/nodes = islist(item_graph) ? item_graph["nodes"] : null
	if(!islist(nodes))
		issues += "item_graph_nodes_missing"
		return issues
	if(item_graph["item_count"] != length(nodes))
		issues += "item_graph_count_mismatch"

	var/list/root_placements = list()
	for(var/item_id in nodes)
		var/list/node = nodes[item_id]
		if(!islist(node) || node["id"] != item_id)
			issues += "invalid_item_node:[item_id]"
			continue
		var/item_path = text2path(node["type"])
		if(!ispath(item_path, /obj/item))
			issues += "invalid_item_type:[item_id]"
		var/list/placement = node["placement"]
		var/placement_kind = islist(placement) ? placement["kind"] : null
		var/parent_id = node["parent_id"]
		if(placement_kind == "nested")
			if(!parent_id || !islist(nodes[parent_id]) || parent_id == item_id)
				issues += "invalid_item_parent:[item_id]"
		else if(placement_kind == "slot")
			var/slot_key = "slot:[placement["slot"]]"
			if(root_placements[slot_key])
				issues += "duplicate_item_placement:[slot_key]"
			root_placements[slot_key] = item_id
		else if(placement_kind == "hand")
			var/hand_key = "hand:[placement["hand"]]"
			if(root_placements[hand_key])
				issues += "duplicate_item_placement:[hand_key]"
			root_placements[hand_key] = item_id
		else if(placement_kind == "bandage")
			var/bandage_key = "bandage:[placement["body_zone"]]"
			if(root_placements[bandage_key])
				issues += "duplicate_item_placement:[bandage_key]"
			root_placements[bandage_key] = item_id
		else if(placement_kind != "embedded")
			issues += "invalid_item_placement:[item_id]"

		var/current_id = item_id
		var/hops = 0
		while(current_id && hops <= length(nodes))
			var/list/current_node = nodes[current_id]
			current_id = islist(current_node) ? current_node["parent_id"] : null
			hops++
		if(current_id)
			issues += "item_parent_cycle:[item_id]"

	return issues

/datum/dreamvalley_campaign_manager/proc/character_record_missing_sections(list/issues, round_trip_passed)
	var/list/missing = list()
	if(length(issues))
		missing += "runtime_state_contracts"
	for(var/issue in issues)
		var/issue_text = "[issue]"
		if(findtext(issue_text, "item_") || findtext(issue_text, "reagent") || findtext(issue_text, "bandage") || findtext(issue_text, "embedded"))
			missing |= "exact_item_graph"
		if(findtext(issue_text, "spell") || findtext(issue_text, "status_effect"))
			missing |= "spell_and_status_runtime_validation"
		if(findtext(issue_text, "component") || findtext(issue_text, "non_serializable"))
			missing |= "custom_datum_contracts"
	if(!round_trip_passed)
		missing |= "restore_validation"
	return missing

/datum/dreamvalley_campaign_manager/proc/validate_character_round_trip(mob/living/carbon/human/character, list/saved_core)
	var/list/issues = validate_character_core(saved_core)
	if(length(issues))
		return issues
	if(!character)
		issues += "round_trip_source_missing"
		return issues

	// Never test restoration against the live player. A disposable nullspace
	// body catches missing component constructors, equipment failures, and
	// subclass state mismatches without touching the source character.
	var/mob/living/carbon/human/shadow = new character.type(null)
	if(!shadow || QDELETED(shadow))
		issues += "round_trip_shadow_create_failed"
		return issues
	shadow.invisibility = INVISIBILITY_MAXIMUM
	var/datum/mind/shadow_mind = new /datum/mind()
	shadow.mind = shadow_mind
	shadow_mind.current = shadow
	shadow_mind.active = FALSE

	if(!restore_character_core(shadow, saved_core))
		issues += "restore_failed"
		qdel(shadow)
		qdel(shadow_mind)
		return issues
	var/list/restored_core = capture_character_core(shadow)
	issues |= validate_character_core(restored_core)
	if(length(issues))
		qdel(shadow)
		qdel(shadow_mind)
		return issues
	for(var/section in list(
		"identity", "vitals", "stats", "skills", "mind", "bodyparts",
		"organs", "traits", "status_effects", "reagents", "items",
	))
		if(!character_section_round_trip_matches(section, saved_core[section], restored_core[section]))
			issues += "round_trip_mismatch:[section]"
	qdel(shadow)
	qdel(shadow_mind)
	return issues

/datum/dreamvalley_campaign_manager/proc/character_section_round_trip_matches(section, saved_value, restored_value)
	var/saved_copy = islist(saved_value) ? deepCopyList(saved_value) : saved_value
	var/restored_copy = islist(restored_value) ? deepCopyList(restored_value) : restored_value
	if(section == "mind")
		var/list/saved_mind = saved_copy
		var/list/restored_mind = restored_copy
		var/list/saved_spells = saved_mind?["spells"]
		var/list/restored_spells = restored_mind?["spells"]
		if(length(saved_spells) != length(restored_spells))
			return FALSE
		for(var/index in 1 to length(saved_spells))
			var/list/saved_spell = saved_spells[index]
			var/list/restored_spell = restored_spells[index]
			for(var/time_field in list("cooldown_remaining", "last_process_age"))
				var/saved_time = saved_spell[time_field]
				var/restored_time = restored_spell[time_field]
				if(isnum(saved_time) && isnum(restored_time) && abs(saved_time - restored_time) > 2)
					return FALSE
				if(time_field in saved_spell)
					saved_spell[time_field] = 0
				if(time_field in restored_spell)
					restored_spell[time_field] = 0
	else if(section == "status_effects")
		var/list/saved_effects = saved_copy
		var/list/restored_effects = restored_copy
		if(length(saved_effects) != length(restored_effects))
			return FALSE
		for(var/index in 1 to length(saved_effects))
			var/list/saved_effect = saved_effects[index]
			var/list/restored_effect = restored_effects[index]
			for(var/time_field in list("remaining_duration", "remaining_tick"))
				var/saved_time = saved_effect[time_field]
				var/restored_time = restored_effect[time_field]
				if(isnum(saved_time) && isnum(restored_time) && abs(saved_time - restored_time) > 2)
					return FALSE
				saved_effect[time_field] = 0
				restored_effect[time_field] = 0
	return json_encode(saved_copy) == json_encode(restored_copy)

/datum/dreamvalley_campaign_manager/proc/audit_character_for_parking(mob/living/carbon/human/character)
	var/list/record = capture_character_draft(character)
	if(!islist(record))
		return list(
			"ready" = FALSE,
			"issues" = list("character_record_capture_failed"),
			"missing_sections" = list("character_record"),
		)
	return list(
		"ready" = record["complete"] == TRUE,
		"issues" = record["validation_issues"],
		"missing_sections" = record["missing_sections"],
		"item_count" = record["core"]?["items"]?["item_count"],
	)
