/**
 * Azure Peak character graph capture and restoration.
 *
 * This layer uses the codebase's native APIs for species, limbs, organs,
 * wounds, skills, aspects, spells, traits, and status effects. Records remain
 * incomplete when a runtime datum has state this generic layer cannot prove
 * safe; Far Travel and Continue use that completeness flag as a hard gate.
 */

/proc/dreamvalley_capture_scalar_vars(datum/source, list/variable_names)
	var/list/result = list()
	if(!source || !islist(variable_names))
		return result
	for(var/variable_name in variable_names)
		if(!(variable_name in source.vars))
			continue
		var/value = source.vars[variable_name]
		if(isnull(value) || isnum(value) || istext(value))
			result[variable_name] = value
		else if(ispath(value))
			result[variable_name] = "[value]"
	return result

/proc/dreamvalley_apply_scalar_vars(datum/target, list/state, list/exclude)
	if(!target || !islist(state))
		return
	for(var/variable_name in state)
		if(islist(exclude) && (variable_name in exclude))
			continue
		if(variable_name in target.vars)
			target.vars[variable_name] = state[variable_name]

/proc/dreamvalley_apply_path_vars(datum/target, list/state, list/variable_names)
	if(!target || !islist(state) || !islist(variable_names))
		return
	for(var/variable_name in variable_names)
		if(!(variable_name in target.vars))
			continue
		var/path_value = text2path(state[variable_name])
		if(path_value)
			target.vars[variable_name] = path_value

/proc/dreamvalley_path_list(list/datums_or_paths)
	var/list/result = list()
	if(!islist(datums_or_paths))
		return result
	for(var/value in datums_or_paths)
		if(ispath(value))
			result += "[value]"
		else if(istype(value, /datum))
			var/datum/entry = value
			result += "[entry.type]"
	return result

/proc/dreamvalley_character_inventory_slots()
	var/list/result = ALL_ITEM_SLOTS
	result |= list(
		SLOT_BACK,
		SLOT_BELT,
		SLOT_GLASSES,
		SLOT_L_STORE,
		SLOT_R_STORE,
		SLOT_S_STORE,
	)
	return result

/proc/dreamvalley_capture_json_value(value, list/issues, context)
	if(isnull(value) || isnum(value) || istext(value))
		return value
	if(ispath(value))
		return list("__dreamvalley_path" = "[value]")
	if(isfile(value))
		return list("__dreamvalley_file" = "[value]")
	if(!islist(value))
		issues += "non_serializable_value:[context]"
		return null
	var/list/source = value
	var/list/result = list()
	for(var/index in 1 to length(source))
		var/key = source[index]
		var/associated_value = source[key]
		if(!isnull(associated_value))
			var/safe_key
			if(istext(key) || isnum(key))
				safe_key = "[key]"
			else if(ispath(key))
				safe_key = "__dreamvalley_path_key:[key]"
			else
				issues += "non_serializable_key:[context]"
				continue
			result[safe_key] = dreamvalley_capture_json_value(associated_value, issues, "[context]/[safe_key]")
		else
			result += list(dreamvalley_capture_json_value(key, issues, "[context]/[index]"))
	return result

/proc/dreamvalley_restore_json_value(value)
	if(!islist(value))
		return value
	var/list/source = value
	if(length(source) == 1 && ("__dreamvalley_path" in source))
		return text2path(source["__dreamvalley_path"])
	if(length(source) == 1 && ("__dreamvalley_file" in source))
		return file(source["__dreamvalley_file"])
	var/list/result = list()
	for(var/index in 1 to length(source))
		var/key = source[index]
		var/associated_value = source[key]
		if(!isnull(associated_value))
			var/restored_key = key
			if(istext(key) && findtext(key, "__dreamvalley_path_key:") == 1)
				restored_key = text2path(copytext(key, length("__dreamvalley_path_key:") + 1))
			result[restored_key] = dreamvalley_restore_json_value(associated_value)
		else
			result += list(dreamvalley_restore_json_value(key))
	return result

/proc/dreamvalley_runtime_excluded_vars(list/additional_exclusions)
	var/list/result = list(
		"type", "parent_type", "vars", "tag", "datum_components",
		"gc_destroyed", "active_timers", "_listen_lookup", "_signal_procs",
		"weak_reference", "verbs", "loc", "locs", "contents", "x", "y", "z",
		"screen_loc", "vis_locs", "vis_contents", "overlays", "underlays",
		"appearance", "transform", "filters", "render_source", "render_target",
	)
	if(islist(additional_exclusions))
		result |= additional_exclusions
	return result

/proc/dreamvalley_capture_runtime_state(datum/source, list/issues, context, list/additional_exclusions)
	var/list/result = list()
	if(!source)
		return result
	var/list/excluded = dreamvalley_runtime_excluded_vars(additional_exclusions)
	for(var/variable_name in source.vars)
		if(variable_name in excluded)
			continue
		var/value = source.vars[variable_name]
		if(isnull(value) || isnum(value) || istext(value) || ispath(value) || isfile(value) || islist(value))
			result[variable_name] = dreamvalley_capture_json_value(value, issues, "[context]/[variable_name]")
			continue
		if(istype(value, /datum))
			var/datum/referenced = value
			issues += "runtime_reference:[context]/[variable_name]:[referenced.type]"
			continue
		issues += "runtime_value:[context]/[variable_name]"
	return result

/proc/dreamvalley_restore_runtime_state(datum/target, list/state)
	if(!target || !islist(state))
		return
	for(var/variable_name in state)
		if(!(variable_name in target.vars))
			continue
		target.vars[variable_name] = dreamvalley_restore_json_value(state[variable_name])

/**
 * Item components whose vars are private "who is holding/wielding me"
 * weakrefs back to the character that owns this graph (a ferramancy bind's
 * binder, a spellblade conduit's wielder). These regenerate deterministically
 * from the character being restored, so persistence reconnects them as a
 * graph-relative "self" pointer instead of reporting an unresolved live
 * reference.
 */
/datum/dreamvalley_campaign_manager/proc/dreamvalley_component_self_weakref_vars(datum/component/component)
	if(istype(component, /datum/component/skill_bind))
		return list("binder_ref")
	if(istype(component, /datum/component/arcyne_conduit))
		return list("owner_ref")
	return list()

/**
 * Spell/status-effect vars that hold a direct reference to an /obj/item the
 * spell or effect has bound to (a ferramancy-bound weapon, a spellblade's
 * arcyne conduit). In normal play that item is always already present in the
 * character's own captured item graph, so these resolve to a graph-relative
 * item pointer (see dreamvalley_capture_owned_reference) instead of
 * reporting an unresolved live reference.
 */
/datum/dreamvalley_campaign_manager/proc/dreamvalley_owned_item_var_names(datum/source)
	if(istype(source, /datum/action/cooldown/spell/bind_armament))
		return list("bound")
	if(istype(source, /datum/status_effect/buff/arcyne_momentum))
		return list("bound_weapon")
	return list()

/**
 * Spell/status-effect vars that hold a direct reference to the
 * character itself (self-references) or to another object already
 * present in the character's own captured item graph (graph-relative
 * references). These are excluded from raw runtime state and instead
 * captured as graph-relative references so they can be restored
 * correctly after a park/continue cycle.
 */
/datum/dreamvalley_campaign_manager/proc/dreamvalley_graph_reference_vars(datum/source)
	if(istype(source, /datum/action/cooldown/spell))
		return list("owner", "target")
	if(istype(source, /datum/status_effect))
		return list("owner", "carbon_owner", "human_owner", "climber", "held_dagger")
	return list()

/**
 * Resolves a live value into a JSON-safe graph-relative reference: the
 * captured character itself, or an /obj/item already present in the
 * character's own captured item graph (item_ids). Anything else is a foreign
 * live reference this contract cannot prove safe, and is reported instead of
 * silently dropped.
 */
/datum/dreamvalley_campaign_manager/proc/dreamvalley_capture_owned_reference(value, mob/living/carbon/human/character, list/item_ids, list/issues, context)
	if(isnull(value))
		return null
	if(value == character)
		return list("kind" = "self")
	if(istype(value, /obj/item) && item_ids[value])
		return list("kind" = "item", "id" = item_ids[value])
	if(istype(value, /datum))
		var/datum/foreign = value
		issues += "unowned_reference:[context]:[foreign.type]"
	return null

/// Inverse of dreamvalley_capture_owned_reference.
/datum/dreamvalley_campaign_manager/proc/dreamvalley_restore_owned_reference(list/state, mob/living/carbon/human/character, list/restored_items)
	if(!islist(state))
		return null
	switch(state["kind"])
		if("self")
			return character
		if("item")
			return restored_items?[state["id"]]
	return null

/datum/dreamvalley_campaign_manager/proc/capture_reagents(atom/holder_atom, list/issues, context)
	if(!holder_atom?.reagents)
		return null
	var/datum/reagents/holder = holder_atom.reagents
	var/list/result = list(
		"maximum_volume" = holder.maximum_volume,
		"chem_temp" = holder.chem_temp,
		"last_tick" = holder.last_tick,
		"addiction_tick" = holder.addiction_tick,
		"flags" = holder.flags,
		"reagents" = list(),
		"addictions" = list(),
	)
	var/list/reagent_states = result["reagents"]
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		reagent_states += list(list(
			"type" = "[reagent.type]",
			"volume" = reagent.volume,
			"data" = dreamvalley_capture_json_value(reagent.data, issues, "[context]/reagent/[reagent.type]/data"),
			"vars" = dreamvalley_capture_scalar_vars(reagent, list(
				"current_cycle", "addiction_stage", "overdosed", "metabolizing",
				"overrides_metab", "self_consuming", "harmful",
			)),
		))
	var/list/addiction_states = result["addictions"]
	for(var/datum/reagent/addiction as anything in holder.addiction_list)
		addiction_states += list(list(
			"type" = "[addiction.type]",
			"volume" = addiction.volume,
			"data" = dreamvalley_capture_json_value(addiction.data, issues, "[context]/addiction/[addiction.type]/data"),
			"vars" = dreamvalley_capture_scalar_vars(addiction, list(
				"current_cycle", "addiction_stage", "overdosed", "metabolizing",
				"overrides_metab", "self_consuming", "harmful",
			)),
		))
	return result

/datum/dreamvalley_campaign_manager/proc/restore_reagents(atom/holder_atom, list/state)
	if(!holder_atom || !islist(state))
		return TRUE
	var/maximum_volume = state["maximum_volume"]
	if(!isnum(maximum_volume))
		return FALSE
	holder_atom.create_reagents(maximum_volume, state["flags"])
	var/datum/reagents/holder = holder_atom.reagents
	holder.chem_temp = state["chem_temp"]
	holder.last_tick = state["last_tick"]
	holder.addiction_tick = state["addiction_tick"]
	var/list/reagent_states = state["reagents"]
	for(var/list/reagent_state as anything in reagent_states)
		var/reagent_path = text2path(reagent_state["type"])
		var/volume = reagent_state["volume"]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(volume))
			return FALSE
		var/restored_data = dreamvalley_restore_json_value(reagent_state["data"])
		holder.add_reagent(reagent_path, volume, restored_data, holder.chem_temp, TRUE)
		var/datum/reagent/restored = holder.has_reagent(reagent_path)
		if(restored)
			dreamvalley_apply_scalar_vars(restored, reagent_state["vars"])
	var/list/addiction_states = state["addictions"]
	for(var/list/addiction_state as anything in addiction_states)
		var/addiction_path = text2path(addiction_state["type"])
		if(!ispath(addiction_path, /datum/reagent))
			return FALSE
		var/addiction_data = dreamvalley_restore_json_value(addiction_state["data"])
		var/datum/reagent/addiction = new addiction_path(addiction_data)
		addiction.holder = holder
		addiction.volume = addiction_state["volume"]
		dreamvalley_apply_scalar_vars(addiction, addiction_state["vars"])
		holder.addiction_list += addiction
	return TRUE

/datum/dreamvalley_campaign_manager/proc/capture_item_component_manifest(obj/item/item, list/issues, item_id)
	var/list/component_types = list()
	var/list/component_states = list()
	var/list/seen_components = list()
	for(var/component_key in item.datum_components)
		var/component_value = item.datum_components[component_key]
		var/list/components = islist(component_value) ? component_value : list(component_value)
		for(var/datum/component/component as anything in components)
			if(!component || seen_components[component])
				continue
			seen_components[component] = TRUE
			component_types += "[component.type]"
			component_states += list(list(
				"type" = "[component.type]",
				"runtime" = dreamvalley_capture_runtime_state(
					component,
					issues,
					"item/[item_id]/component/[component.type]",
					list(
						"parent", "master", "is_using", "boxes", "closer",
						// Regenerated by the component's own Initialize()/move
						// handling; not required to identify the component.
						"visible_mask", "current_holder", "parent_attached_to",
					) + dreamvalley_component_self_weakref_vars(component),
				),
			))
	return list(
		"types" = component_types,
		"states" = component_states,
	)

/datum/dreamvalley_campaign_manager/proc/restore_item_components(obj/item/item, list/state, list/issues, item_id, mob/living/carbon/human/character)
	if(!islist(state))
		return
	var/list/current_types = list()
	var/list/current_components = list()
	var/list/seen_components = list()
	for(var/component_key in item.datum_components)
		var/component_value = item.datum_components[component_key]
		var/list/components = islist(component_value) ? component_value : list(component_value)
		for(var/datum/component/component as anything in components)
			if(!component || seen_components[component])
				continue
			seen_components[component] = TRUE
			current_types += "[component.type]"
			current_components += component
	var/list/saved_types = state["types"]
	for(var/saved_type in saved_types)
		if(!(saved_type in current_types))
			issues += "item_component_missing:[item_id]:[saved_type]"
	var/list/used_components = list()
	for(var/list/component_state as anything in state["states"])
		var/component_path = text2path(component_state["type"])
		var/datum/component/matching_component
		for(var/datum/component/candidate as anything in current_components)
			if(candidate.type != component_path || used_components[candidate])
				continue
			matching_component = candidate
			break
		if(!matching_component)
			issues += "item_component_restore_missing:[item_id]:[component_path]"
			continue
		used_components[matching_component] = TRUE
		dreamvalley_restore_runtime_state(matching_component, component_state["runtime"])
		for(var/var_name in dreamvalley_component_self_weakref_vars(matching_component))
			matching_component.vars[var_name] = WEAKREF(character)

/datum/dreamvalley_campaign_manager/proc/capture_character_items(mob/living/carbon/human/character, list/issues, list/item_ids)
	var/list/queue = list()
	if(!islist(item_ids))
		item_ids = list()
	var/list/placements = list()
	var/list/nodes = list()

	for(var/slot_id in dreamvalley_character_inventory_slots())
		var/obj/item/equipped = character.get_item_by_slot(slot_id)
		if(!equipped || item_ids[equipped])
			continue
		queue += equipped
		item_ids[equipped] = "item-[length(queue)]"
		placements[equipped] = list("kind" = "slot", "slot" = slot_id)

	for(var/hand_index in 1 to length(character.held_items))
		var/obj/item/held = character.held_items[hand_index]
		if(!held || item_ids[held])
			continue
		queue += held
		item_ids[held] = "item-[length(queue)]"
		placements[held] = list("kind" = "hand", "hand" = hand_index)

	for(var/obj/item/bodypart/bodypart as anything in character.bodyparts)
		for(var/obj/item/embedded as anything in bodypart.embedded_objects)
			if(item_ids[embedded])
				continue
			queue += embedded
			item_ids[embedded] = "item-[length(queue)]"
			placements[embedded] = list(
				"kind" = "embedded",
				"body_zone" = "[bodypart.body_zone]",
			)
		var/obj/item/bandage = bodypart.bandage
		if(bandage && !item_ids[bandage])
			queue += bandage
			item_ids[bandage] = "item-[length(queue)]"
			placements[bandage] = list(
				"kind" = "bandage",
				"body_zone" = "[bodypart.body_zone]",
			)

	var/queue_index = 0
	while(queue_index < length(queue))
		var/obj/item/item = queue[++queue_index]
		var/item_id = item_ids[item]
		var/list/node = list(
			"id" = item_id,
			"type" = "[item.type]",
			"placement" = placements[item],
			"parent_id" = null,
			"vars" = dreamvalley_capture_scalar_vars(item, list(
				"name", "desc", "icon_state", "color", "alpha", "dir",
				"pixel_x", "pixel_y", "pixel_z", "transform",
				"obj_integrity", "max_integrity", "integrity_failure",
				"w_class", "item_flags", "flags_inv", "slot_flags",
				"force", "force_dynamic", "force_wielded", "throwforce",
				"sharpness", "wlength", "wbalance", "wdefense",
				"wdefense_dynamic", "wdefense_wbonus", "minstr",
				"item_quality", "has_item_quality", "wielded", "altgripped",
				"current_alt_grip_index", "saved_intent_index", "heat",
				"is_embedded", "amount", "uses", "charges", "fuel",
				"quality", "sellprice", "smelted", "was_crafted",
				"medicine_quality", "medicine_amount", "bandage_health",
				"detail_color", "dye_color", "grid_width", "grid_height",
			)),
			"reagents" = capture_reagents(item, issues, item_id),
		)
		for(var/atom/movable/contained as anything in item.contents)
			if(!istype(contained, /obj/item))
				issues += "non_item_inventory_content:[item_id]:[contained.type]"
				continue
			var/obj/item/child = contained
			if(!item_ids[child])
				queue += child
				item_ids[child] = "item-[length(queue)]"
				placements[child] = list("kind" = "nested")
			var/child_id = item_ids[child]
			var/list/child_placement = placements[child]
			if(child_placement["kind"] != "nested")
				issues += "multiply_placed_item:[child_id]"
			else
				child_placement["parent_id"] = item_id
		node["components"] = capture_item_component_manifest(item, issues, item_id)
		nodes[item_id] = node

	for(var/item_id in nodes)
		var/list/node = nodes[item_id]
		var/list/placement = node["placement"]
		if(placement["kind"] == "nested")
			node["parent_id"] = placement["parent_id"]

	return list(
		"nodes" = nodes,
		"item_count" = length(queue),
	)

/datum/dreamvalley_campaign_manager/proc/capture_character_core(mob/living/carbon/human/character)
	var/list/issues = list()
	// Items are captured first so mind/status effects can resolve bound-item
	// vars (an arcyne conduit weapon, a ferramancy bind) to a graph-relative
	// item reference instead of reporting them as unresolved live references.
	var/list/item_ids = list()
	var/list/items = capture_character_items(character, issues, item_ids)
	var/list/result = list(
		"identity" = capture_character_identity(character),
		"vitals" = capture_character_vitals(character),
		"stats" = capture_character_stats(character),
		"skills" = capture_character_skills(character),
		"mind" = capture_character_mind(character, issues, item_ids),
		"bodyparts" = capture_character_bodyparts(character, issues),
		"organs" = capture_character_organs(character),
		"traits" = capture_character_traits(character, issues),
		"status_effects" = capture_character_status_effects(character, issues, item_ids),
		"reagents" = capture_reagents(character, issues, "character"),
		"items" = items,
		"validation_issues" = issues,
	)
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_identity(mob/living/carbon/human/character)
	var/list/identity_vars = dreamvalley_capture_scalar_vars(character, list(
		"real_name", "name", "age", "gender", "pronouns", "titles_pref",
		"clothes_pref", "voice_pack", "voice_type", "origin", "detail",
		"hairstyle", "hair_color", "facial_hairstyle", "facial_hair_color",
		"skin_tone", "eye_color", "voice_color", "voice_pitch", "detail_color",
		"domhand", "nickname", "highlight_color", "char_accent", "flavortext",
		"ooc_notes", "nsfwflavortext", "erpprefs", "headshot_link",
		"lich_headshot_link", "vampire_headshot_link", "vampire_skin",
		"vampire_eyes", "vampire_hair", "vampire_ears", "taur_type",
		"taur_color", "job", "advjob", "adaptive_name", "adaptive_name_title",
	))
	var/list/dna_state = list()
	if(character.dna)
		dna_state = dreamvalley_capture_scalar_vars(character.dna, list(
			"unique_enzymes", "uni_identity", "blood_type", "real_name",
			"stability", "scrambled", "current_body_size",
		))
		dna_state["species_type"] = character.dna.species ? "[character.dna.species.type]" : null
		dna_state["features"] = deepCopyList(character.dna.features)
		dna_state["body_markings"] = deepCopyList(character.dna.body_markings)
		var/list/organ_dna_states = list()
		for(var/organ_slot in character.dna.organ_dna)
			var/datum/organ_dna/organ_dna = character.dna.organ_dna[organ_slot]
			if(!organ_dna)
				continue
			organ_dna_states["[organ_slot]"] = list(
				"type" = "[organ_dna.type]",
				"vars" = dreamvalley_capture_scalar_vars(organ_dna, list(
					"organ_type", "accessory_type", "accessory_colors", "disabled",
					"eye_color", "heterochromia", "second_color", "penis_size",
					"functional", "ball_size", "virility", "breast_size",
					"lactating", "fertility",
				)),
			)
		dna_state["organ_dna"] = organ_dna_states
	identity_vars["dna"] = dna_state
	return identity_vars

/datum/dreamvalley_campaign_manager/proc/capture_character_vitals(mob/living/carbon/human/character)
	return dreamvalley_capture_scalar_vars(character, list(
		"stat", "maxHealth", "health", "bruteloss", "oxyloss", "toxloss",
		"fireloss", "cloneloss", "staminaloss", "blood_volume", "nutrition",
		"satiety", "thirst", "energy", "stamina", "max_energy", "max_stamina",
		"bodytemperature", "coretemperature", "on_fire", "fire_stacks",
		"hallucination", "druggy", "confused", "stuttering", "slurring",
		"cultslurring", "losebreath", "bleed_rate", "bleedsuppress",
		"hellbound", "infected", "burialrited",
	))

/datum/dreamvalley_campaign_manager/proc/capture_character_stats(mob/living/carbon/human/character)
	var/list/state = dreamvalley_capture_scalar_vars(character, list(
		"STASTR", "STAPER", "STAINT", "STACON", "STAWIL", "STASPD", "STALUC",
		"BUFSTR", "BUFPER", "BUFINT", "BUFCON", "BUFEND", "BUFSPE", "BUFLUC",
		"pain_threshold",
	))
	state["patron_type"] = istype(character.patron, /datum) ? "[character.patron.type]" : null
	return state

/datum/dreamvalley_campaign_manager/proc/capture_character_skills(mob/living/carbon/human/character)
	var/list/result = list()
	var/datum/skill_holder/holder = character.ensure_skills()
	for(var/skill_type in SSskills.all_skills)
		var/datum/skill/skill = GetSkillRef(skill_type)
		if(!skill)
			continue
		result["[skill.type]"] = list(
			"rank" = holder.known_skills[skill] || SKILL_LEVEL_NONE,
			"experience" = holder.skill_experience[skill] || 0,
		)
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_mind(mob/living/carbon/human/character, list/issues, list/item_ids)
	var/list/result = list()
	if(!character.mind)
		issues += "mind_missing"
		return result
	var/datum/mind/mind = character.mind
	result = dreamvalley_capture_scalar_vars(mind, list(
		"name", "ghostname", "memory", "special_role", "has_arcyne_momentum",
		"aspect_resets_used", "miming", "damnation_type", "hasSoul", "isholy",
		"unconvertable", "late_joiner", "last_death", "force_escaped",
		"lastrecipe", "mugshot_set", "heretic_nickname", "job_bitflag",
		"has_bomb", "has_drug_delivery", "triumph_discount_remaining",
	))
	result["assigned_role_type"] = mind.assigned_role ? "[mind.assigned_role.type]" : null
	result["assigned_role_title"] = mind.assigned_role?.title
	result["picked_advclass_type"] = mind.picked_advclass ? "[mind.picked_advclass.type]" : null
	result["known_people"] = deepCopyList(mind.known_people)
	result["notes"] = deepCopyList(mind.notes)
	result["learned_recipes"] = dreamvalley_path_list(mind.learned_recipes)
	result["major_aspects"] = dreamvalley_path_list(mind.major_aspects)
	result["minor_aspects"] = dreamvalley_path_list(mind.minor_aspects)
	result["spells"] = capture_character_spells(character, mind, issues, item_ids)
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_spells(mob/living/carbon/human/character, datum/mind/mind, list/issues, list/item_ids)
	var/list/result = list()
	var/spell_index = 0
	for(var/datum/spell as anything in mind.spell_list)
		spell_index++
		var/list/state = list(
			"type" = "[spell.type]",
			"order" = spell_index,
		)
		if(istype(spell, /datum/action/cooldown/spell))
			var/datum/action/cooldown/spell/action_spell = spell
			state["kind"] = "action"
			state["cooldown_remaining"] = max(0, action_spell.next_use_time - world.time)
			var/list/owned_var_names = dreamvalley_owned_item_var_names(action_spell)
			var/list/graph_ref_var_names = dreamvalley_graph_reference_vars(action_spell)
			state["runtime"] = dreamvalley_capture_runtime_state(
				action_spell,
				issues,
				"spell/[spell_index]/[spell.type]",
				list(
					"viewers", "next_use_time",
					"retrigger_timer", "auto_cancel_timer", "charge_sound_instance",
					"mob_charge_effect", "spell_glow_light",
					// Live summoned combat minions do not need to survive a
					// park/continue cycle; they are abandoned like any other
					// timed summon would be.
					"conjured_mobs",
				) + owned_var_names,
			)
			if(length(owned_var_names) || length(graph_ref_var_names))
				var/list/owned_refs = list()
				for(var/var_name in owned_var_names)
					owned_refs[var_name] = dreamvalley_capture_owned_reference(action_spell.vars[var_name], character, item_ids, issues, "spell/[spell_index]/[var_name]")
				for(var/var_name in graph_ref_var_names)
					owned_refs[var_name] = dreamvalley_capture_owned_reference(action_spell.vars[var_name], character, item_ids, issues, "spell/[spell_index]/[var_name]")
				state["owned_refs"] = owned_refs
			if(action_spell.currently_charging || action_spell.fully_charged || action_spell.charged)
				issues += "spell_active_cast:[spell_index]:[spell.type]"
		else if(istype(spell, /obj/effect/proc_holder/spell))
			var/obj/effect/proc_holder/spell/legacy_spell = spell
			state["kind"] = "legacy"
			state["last_process_age"] = max(0, world.time - legacy_spell.last_process_time)
			state["runtime"] = dreamvalley_capture_runtime_state(
				legacy_spell,
				issues,
				"spell/[spell_index]/[spell.type]",
				list(
					"action", "last_process_time", "ranged_ability_user",
					"mob_charge_effect", "reagents", "hud_list", "orbiters",
					"wires", "ai_controller", "language_holder", "throwing",
					"pulledby", "inertia_last_loc", "moving_from_pull",
					"force_moving", "move_packet", "pulling", "orbiting",
					"important_recursive_contents", "managed_vis_overlays",
					"managed_overlays", "alternate_appearances",
					"active_movement", "comp_lookup", "area", "group",
				),
			)
			if(legacy_spell.active || legacy_spell.ranged_ability_user)
				issues += "spell_active_cast:[spell_index]:[spell.type]"
		else
			issues += "unknown_spell_kind:[spell_index]:[spell.type]"
			continue
		result += list(state)
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_bodyparts(mob/living/carbon/human/character, list/issues)
	var/list/result = list()
	for(var/obj/item/bodypart/bodypart as anything in character.bodyparts)
		var/list/state = list(
			"type" = "[bodypart.type]",
			"vars" = dreamvalley_capture_scalar_vars(bodypart, list(
				"body_zone", "aux_zone", "status", "disabled", "brutestate",
				"burnstate", "brute_dam", "burn_dam", "stamina_dam",
				"max_stamina_damage", "max_damage", "max_pain_damage",
				"cremation_progress", "skin_tone", "body_gender", "species_id",
				"species_color", "mutation_color", "rotted", "skeletonized",
				"fingers", "organ_slowdown", "is_prosthetic", "bleeding",
				"unlimited_bleeding", "grievously_wounded",
			)),
			"markings" = deepCopyList(bodypart.markings),
			"aux_markings" = deepCopyList(bodypart.aux_markings),
			"features" = list(),
			"wounds" = list(),
		)
		var/list/feature_states = state["features"]
		for(var/datum/bodypart_feature/feature as anything in bodypart.bodypart_features)
			feature_states += list(list(
				"type" = "[feature.type]",
				"vars" = dreamvalley_capture_scalar_vars(feature, list(
					"name", "body_zone", "accessory_type", "accessory_colors",
					"feature_slot", "hair_color", "natural_gradient",
					"natural_color", "hair_dye_gradient", "hair_dye_color",
					"custom_mask_version",
				)),
				"colormasks" = dreamvalley_capture_json_value(
					feature.vars["colormasks"],
					issues,
					"bodypart/[bodypart.body_zone]/feature/[feature.type]/colormasks",
				),
			))
		var/list/wound_states = state["wounds"]
		for(var/datum/wound/wound as anything in bodypart.wounds)
			wound_states += list(list(
				"type" = "[wound.type]",
				"vars" = dreamvalley_capture_scalar_vars(wound, list(
					"name", "check_name", "severity", "whp", "sewn_whp",
					"bleed_rate", "sewn_bleed_rate", "clotting_rate",
					"sewn_clotting_rate", "clotting_threshold",
					"sewn_clotting_threshold", "woundpain", "sewn_woundpain",
					"sew_progress", "sew_threshold", "can_sew",
					"can_cauterize", "disabling", "critical", "mortal",
					"sleep_healing", "passive_healing", "embed_chance",
					"healable_by_miracles",
				)),
			))
		result["[bodypart.body_zone]"] = state
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_organs(mob/living/carbon/human/character)
	var/list/result = list()
	for(var/obj/item/organ/organ as anything in character.internal_organs)
		result["[organ.slot]"] = list(
			"type" = "[organ.type]",
			"vars" = dreamvalley_capture_scalar_vars(organ, list(
				"status", "zone", "slot", "organ_flags", "maxHealth", "damage",
				"prev_damage", "low_threshold_passed", "high_threshold_passed",
				"now_failing", "now_fixed", "high_threshold_cleared",
				"low_threshold_cleared", "had_owner",
			)),
		)
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_traits(mob/living/carbon/human/character, list/issues)
	var/list/result = list()
	for(var/trait_name in character.status_traits)
		var/list/saved_sources = list()
		var/list/sources = character.status_traits[trait_name]
		for(var/source in sources)
			if(istext(source) || isnum(source))
				saved_sources += list(list("kind" = "scalar", "value" = source))
			else if(ispath(source))
				saved_sources += list(list("kind" = "path", "value" = "[source]"))
			else
				issues += "trait_source:[trait_name]"
		if(length(saved_sources))
			result[trait_name] = saved_sources
	return result

/datum/dreamvalley_campaign_manager/proc/capture_character_status_effects(mob/living/carbon/human/character, list/issues, list/item_ids)
	var/list/result = list()
	for(var/datum/status_effect/effect as anything in character.status_effects)
		var/remaining_duration = effect.duration
		if(remaining_duration != -1)
			remaining_duration = max(0, remaining_duration - world.time)
		var/remaining_tick = effect.tick_interval
		if(remaining_tick != -1)
			remaining_tick = max(0, remaining_tick - world.time)
		var/list/owned_var_names = dreamvalley_owned_item_var_names(effect)
		var/list/graph_ref_var_names = dreamvalley_graph_reference_vars(effect)
		var/list/effect_state = list(
			"type" = "[effect.type]",
			"remaining_duration" = remaining_duration,
			"remaining_tick" = remaining_tick,
			"runtime" = dreamvalley_capture_runtime_state(
				effect,
				issues,
				"status_effect/[effect.type]",
				list(
					"linked_alert", "mob_effect", "duration",
					"tick_interval",
					// Ephemeral combat-tick state that has always expired
					// long before a park/continue cycle can complete.
					"shield_origin", "device",
					// Regenerated visual light objects (see fire_stacks
					// moblight fixup below for the one case that needs it).
					"moblight", "mob_light_obj",
					// References to a different character's mob; cannot be
					// resolved within a single character's own graph.
					"date", "rewarded",
				) + owned_var_names,
			),
		)
		if(length(owned_var_names) || length(graph_ref_var_names))
			var/list/owned_refs = list()
			for(var/var_name in owned_var_names)
				owned_refs[var_name] = dreamvalley_capture_owned_reference(effect.vars[var_name], character, item_ids, issues, "status_effect/[effect.type]/[var_name]")
			for(var/var_name in graph_ref_var_names)
				owned_refs[var_name] = dreamvalley_capture_owned_reference(effect.vars[var_name], character, item_ids, issues, "status_effect/[effect.type]/[var_name]")
			effect_state["owned_refs"] = owned_refs
		result += list(effect_state)
	return result

/datum/dreamvalley_campaign_manager/proc/restore_character_core(mob/living/carbon/human/character, list/core)
	if(!character || !islist(core))
		return FALSE
	restoring_snapshot = TRUE
	restore_character_identity(character, core["identity"])
	restore_character_bodyparts(character, core["bodyparts"])
	restore_character_organs(character, core["organs"])
	// Items are restored before mind/status effects so a bound-weapon graph
	// reference (an arcyne conduit, a ferramancy bind) can resolve to the
	// exact restored item instance instead of a placeholder.
	var/list/restored_items = list()
	var/list/item_restore_issues = restore_character_items(character, core["items"], restored_items)
	if(length(item_restore_issues))
		restoring_snapshot = FALSE
		return FALSE
	restore_character_mind(character, core["mind"], restored_items)
	restore_character_traits(character, core["traits"])
	restore_character_status_effects(character, core["status_effects"], restored_items)
	restore_character_stats(character, core["stats"])
	restore_character_skills(character, core["skills"])
	restore_reagents(character, core["reagents"])
	dreamvalley_apply_scalar_vars(character, core["vitals"])
	character.update_body()
	character.update_hair()
	character.update_body_parts(TRUE)
	character.updatehealth()
	character.update_mobility()
	restoring_snapshot = FALSE
	return TRUE

/datum/dreamvalley_campaign_manager/proc/restore_character_items(mob/living/carbon/human/character, list/state, list/restored_items)
	var/list/issues = list()
	if(!islist(restored_items))
		restored_items = list()
	if(!islist(state) || !islist(state["nodes"]))
		issues += "item_graph_missing"
		return issues
	var/list/nodes = state["nodes"]
	var/list/existing_items = character.get_all_gear()
	character.unequip_everything()
	for(var/obj/item/existing as anything in existing_items)
		if(!QDELETED(existing))
			qdel(existing)

	var/turf/spawn_location = get_turf(character)
	for(var/item_id in nodes)
		var/list/node = nodes[item_id]
		var/item_path = islist(node) ? text2path(node["type"]) : null
		if(!ispath(item_path, /obj/item))
			issues += "invalid_item_type:[item_id]"
			continue
		var/obj/item/item = new item_path(spawn_location)
		if(QDELETED(item))
			issues += "item_deleted_during_initialize:[item_id]"
			continue
		restored_items[item_id] = item
		dreamvalley_apply_scalar_vars(item, node["vars"])
		if(!restore_reagents(item, node["reagents"]))
			issues += "item_reagent_restore_failed:[item_id]"
		restore_item_components(item, node["components"], issues, item_id, character)

	for(var/item_id in nodes)
		var/list/node = nodes[item_id]
		var/parent_id = node["parent_id"]
		if(!parent_id)
			continue
		var/obj/item/item = restored_items[item_id]
		var/obj/item/parent = restored_items[parent_id]
		if(!item || !parent)
			issues += "item_parent_missing:[item_id]:[parent_id]"
			continue
		item.forceMove(parent)

	for(var/item_id in nodes)
		var/list/node = nodes[item_id]
		var/list/placement = node["placement"]
		if(!islist(placement) || placement["kind"] == "nested")
			continue
		var/obj/item/item = restored_items[item_id]
		if(!item)
			continue
		switch(placement["kind"])
			if("slot")
				var/slot_id = placement["slot"]
				if(!character.equip_to_slot_if_possible(item, slot_id, FALSE, TRUE, FALSE, TRUE, TRUE))
					issues += "item_slot_restore_failed:[item_id]:[slot_id]"
			if("hand")
				var/hand_index = placement["hand"]
				if(!character.put_in_hand(item, hand_index, TRUE))
					issues += "item_hand_restore_failed:[item_id]:[hand_index]"
			if("embedded")
				var/obj/item/bodypart/bodypart = character.get_bodypart(placement["body_zone"])
				if(!bodypart?.add_embedded_object(item, TRUE))
					issues += "embedded_item_restore_failed:[item_id]:[placement["body_zone"]]"
			if("bandage")
				var/obj/item/bodypart/bodypart = character.get_bodypart(placement["body_zone"])
				if(!bodypart?.try_bandage(item))
					issues += "bandage_restore_failed:[item_id]:[placement["body_zone"]]"
			else
				issues += "unknown_item_placement:[item_id]:[placement["kind"]]"

	return issues

/datum/dreamvalley_campaign_manager/proc/restore_character_identity(mob/living/carbon/human/character, list/state)
	if(!islist(state))
		return
	var/list/dna_state = state["dna"]
	var/species_path = islist(dna_state) ? text2path(dna_state["species_type"]) : null
	if(ispath(species_path, /datum/species))
		character.set_species(species_path, icon_update = FALSE)
		sleep(0)
	// "dna" is a nested sub-structure, not a scalar, but it collides with the
	// mob's own real /datum/dna "dna" var — applying it blindly here would
	// overwrite character.dna with a plain list. The dna_state block below is
	// the only thing allowed to touch character.dna.
	dreamvalley_apply_scalar_vars(character, state, list("dna"))
	if(character.dna && islist(dna_state))
		dreamvalley_apply_scalar_vars(character.dna, dna_state)
		var/list/features = dna_state["features"]
		var/list/body_markings = dna_state["body_markings"]
		if(islist(features))
			character.dna.features = deepCopyList(features)
		if(islist(body_markings))
			character.dna.body_markings = deepCopyList(body_markings)
		var/list/organ_dna_states = dna_state["organ_dna"]
		if(islist(organ_dna_states))
			for(var/datum/organ_dna/old_organ_dna as anything in character.dna.organ_dna)
				qdel(old_organ_dna)
			character.dna.organ_dna = list()
			for(var/organ_slot in organ_dna_states)
				var/list/organ_dna_state = organ_dna_states[organ_slot]
				var/organ_dna_path = text2path(organ_dna_state["type"])
				if(!ispath(organ_dna_path, /datum/organ_dna))
					continue
				var/datum/organ_dna/restored_organ_dna = new organ_dna_path()
				dreamvalley_apply_scalar_vars(restored_organ_dna, organ_dna_state["vars"])
				dreamvalley_apply_path_vars(restored_organ_dna, organ_dna_state["vars"], list(
					"organ_type", "accessory_type",
				))
				character.dna.organ_dna[organ_slot] = restored_organ_dna
		character.dna.update_body_size()

/datum/dreamvalley_campaign_manager/proc/restore_character_stats(mob/living/carbon/human/character, list/state)
	if(!islist(state))
		return
	var/patron_path = text2path(state["patron_type"])
	if(ispath(patron_path, /datum/patron))
		character.set_patron(patron_path)
	dreamvalley_apply_scalar_vars(character, state)

/datum/dreamvalley_campaign_manager/proc/restore_character_skills(mob/living/carbon/human/character, list/states)
	if(!islist(states))
		return
	var/datum/skill_holder/holder = character.ensure_skills()
	holder.known_skills = list()
	for(var/skill_text in states)
		var/skill_path = text2path(skill_text)
		var/datum/skill/skill = GetSkillRef(skill_path)
		var/list/state = states[skill_text]
		if(!skill || !islist(state))
			continue
		holder.known_skills[skill] = state["rank"] || SKILL_LEVEL_NONE
		holder.skill_experience[skill] = state["experience"] || 0

/datum/dreamvalley_campaign_manager/proc/restore_character_bodyparts(mob/living/carbon/human/character, list/states)
	if(!islist(states))
		return
	var/list/existing_parts = character.bodyparts.Copy()
	for(var/obj/item/bodypart/existing as anything in existing_parts)
		var/list/state = states["[existing.body_zone]"]
		var/saved_type = islist(state) ? text2path(state["type"]) : null
		if(!state || existing.type != saved_type)
			existing.drop_limb(TRUE)
			if(!QDELETED(existing))
				qdel(existing)

	for(var/body_zone in states)
		var/list/state = states[body_zone]
		if(!islist(state))
			continue
		var/bodypart_path = text2path(state["type"])
		if(!ispath(bodypart_path, /obj/item/bodypart))
			continue
		var/obj/item/bodypart/bodypart = character.get_bodypart(body_zone)
		if(!bodypart)
			bodypart = new bodypart_path(character)
			bodypart.attach_limb(character, TRUE)
		dreamvalley_apply_scalar_vars(bodypart, state["vars"])
		if(islist(state["markings"]))
			bodypart.markings = deepCopyList(state["markings"])
		if(islist(state["aux_markings"]))
			bodypart.aux_markings = deepCopyList(state["aux_markings"])
		bodypart.remove_all_bodypart_features()
		for(var/list/feature_state as anything in state["features"])
			var/feature_path = text2path(feature_state["type"])
			if(!ispath(feature_path, /datum/bodypart_feature))
				continue
			var/datum/bodypart_feature/feature = new feature_path()
			var/list/feature_vars = feature_state["vars"]
			var/accessory_path = text2path(feature_vars["accessory_type"])
			if(accessory_path)
				feature.set_accessory_type(accessory_path, feature_vars["accessory_colors"], character)
			dreamvalley_apply_scalar_vars(feature, feature_vars)
			dreamvalley_apply_path_vars(feature, feature_vars, list(
				"accessory_type", "natural_gradient", "hair_dye_gradient",
			))
			if(("colormasks" in feature.vars) && islist(feature_state["colormasks"]))
				feature.vars["colormasks"] = deepCopyList(feature_state["colormasks"])
			bodypart.add_bodypart_feature(feature)
		for(var/datum/wound/old_wound as anything in bodypart.wounds)
			bodypart.remove_wound(old_wound)
		var/list/wound_states = state["wounds"]
		for(var/list/wound_state as anything in wound_states)
			var/wound_path = text2path(wound_state["type"])
			if(!ispath(wound_path, /datum/wound))
				continue
			var/datum/wound/restored_wound = new wound_path()
			if(restored_wound.apply_to_bodypart(bodypart, TRUE, FALSE))
				dreamvalley_apply_scalar_vars(restored_wound, wound_state["vars"])
			else
				qdel(restored_wound)

/datum/dreamvalley_campaign_manager/proc/restore_character_organs(mob/living/carbon/human/character, list/states)
	if(!islist(states))
		return
	var/list/existing_organs = character.internal_organs.Copy()
	for(var/obj/item/organ/existing as anything in existing_organs)
		var/list/state = states["[existing.slot]"]
		var/saved_type = islist(state) ? text2path(state["type"]) : null
		if(!state || existing.type != saved_type)
			existing.Remove(character, special = TRUE, drop_if_replaced = FALSE)
			if(!QDELETED(existing))
				qdel(existing)

	for(var/organ_slot in states)
		var/list/state = states[organ_slot]
		if(!islist(state))
			continue
		var/organ_path = text2path(state["type"])
		if(!ispath(organ_path, /obj/item/organ))
			continue
		var/obj/item/organ/organ = character.getorganslot(organ_slot)
		if(!organ)
			organ = new organ_path()
			organ.Insert(character, special = TRUE, drop_if_replaced = FALSE)
		dreamvalley_apply_scalar_vars(organ, state["vars"])

/datum/dreamvalley_campaign_manager/proc/restore_character_mind(mob/living/carbon/human/character, list/state, list/restored_items)
	if(!character.mind || !islist(state))
		return
	var/datum/mind/mind = character.mind
	dreamvalley_apply_scalar_vars(mind, state)
	var/role_path = text2path(state["assigned_role_type"])
	if(ispath(role_path, /datum/job))
		mind.set_assigned_role(role_path)
	var/advclass_path = text2path(state["picked_advclass_type"])
	if(ispath(advclass_path, /datum/advclass))
		QDEL_NULL(mind.picked_advclass)
		mind.picked_advclass = new advclass_path()
	if(islist(state["known_people"]))
		mind.known_people = deepCopyList(state["known_people"])
	if(islist(state["notes"]))
		mind.notes = deepCopyList(state["notes"])
	mind.learned_recipes = list()
	for(var/recipe_text in state["learned_recipes"])
		var/recipe_path = text2path(recipe_text)
		if(recipe_path)
			mind.learned_recipes += recipe_path
	mind.remove_all_aspects()
	for(var/aspect_text in state["major_aspects"])
		var/aspect_path = text2path(aspect_text)
		if(ispath(aspect_path, /datum/magic_aspect))
			mind.attune_aspect(new aspect_path())
	for(var/aspect_text in state["minor_aspects"])
		var/aspect_path = text2path(aspect_text)
		if(ispath(aspect_path, /datum/magic_aspect))
			mind.attune_aspect(new aspect_path())
	restore_character_spells(character, mind, state["spells"], restored_items)

/datum/dreamvalley_campaign_manager/proc/restore_character_spells(mob/living/carbon/human/character, datum/mind/mind, list/states, list/restored_items)
	if(!islist(states))
		return
	mind.RemoveAllSpells()
	var/list/restored_order = list()
	for(var/list/state as anything in states)
		var/spell_path = text2path(state["type"])
		var/datum/restored_spell
		if(state["kind"] == "action" && ispath(spell_path, /datum/action/cooldown/spell))
			var/datum/action/cooldown/spell/action_spell = new spell_path()
			mind.AddSpell(action_spell, character)
			if(QDELETED(action_spell) || !(action_spell in mind.spell_list))
				continue
			dreamvalley_restore_runtime_state(action_spell, state["runtime"])
			var/list/owned_refs = state["owned_refs"]
			if(islist(owned_refs))
				for(var/var_name in owned_refs)
					action_spell.vars[var_name] = dreamvalley_restore_owned_reference(owned_refs[var_name], character, restored_items)
			var/cooldown_remaining = state["cooldown_remaining"]
			if(isnum(cooldown_remaining) && cooldown_remaining > 0)
				action_spell.StartCooldownSelf(cooldown_remaining)
			restored_spell = action_spell
		else if(state["kind"] == "legacy" && ispath(spell_path, /obj/effect/proc_holder/spell))
			var/obj/effect/proc_holder/spell/legacy_spell = new spell_path()
			mind.AddSpell(legacy_spell, character)
			if(QDELETED(legacy_spell) || !(legacy_spell in mind.spell_list))
				continue
			dreamvalley_restore_runtime_state(legacy_spell, state["runtime"])
			var/last_process_age = state["last_process_age"]
			if(isnum(last_process_age))
				legacy_spell.last_process_time = max(0, world.time - last_process_age)
			restored_spell = legacy_spell
		if(restored_spell)
			restored_order += restored_spell
	if(length(restored_order) == length(mind.spell_list))
		mind.spell_list = restored_order
		mind.rebuild_action_order()

/datum/dreamvalley_campaign_manager/proc/restore_character_traits(mob/living/carbon/human/character, list/states)
	if(!islist(states))
		return
	for(var/trait_name in states)
		var/list/sources = states[trait_name]
		for(var/list/source_state as anything in sources)
			var/source = source_state["value"]
			if(source_state["kind"] == "path")
				source = text2path(source)
			if(!isnull(source))
				ADD_TRAIT(character, trait_name, source)

/datum/dreamvalley_campaign_manager/proc/restore_character_status_effects(mob/living/carbon/human/character, list/states, list/restored_items)
	if(!islist(states))
		return
	var/list/existing_effects = character.status_effects?.Copy()
	for(var/datum/status_effect/existing as anything in existing_effects)
		qdel(existing)
	for(var/list/state as anything in states)
		var/effect_path = text2path(state["type"])
		if(!ispath(effect_path, /datum/status_effect))
			continue
		var/datum/status_effect/effect = character.apply_status_effect(effect_path)
		if(!effect)
			continue
		var/remaining_duration = state["remaining_duration"]
		if(isnum(remaining_duration))
			effect.duration = remaining_duration == -1 ? -1 : world.time + remaining_duration
		var/remaining_tick = state["remaining_tick"]
		if(isnum(remaining_tick))
			effect.tick_interval = remaining_tick == -1 ? -1 : world.time + remaining_tick
		dreamvalley_restore_runtime_state(effect, state["runtime"])
		var/list/owned_refs = state["owned_refs"]
		if(islist(owned_refs))
			for(var/var_name in owned_refs)
				effect.vars[var_name] = dreamvalley_restore_owned_reference(owned_refs[var_name], character, restored_items)
		if(istype(effect, /datum/status_effect/fire_handler/fire_stacks))
			var/datum/status_effect/fire_handler/fire_stacks/fire = effect
			if(fire.on_fire && fire.moblight_type && (!fire.moblight || QDELETED(fire.moblight)))
				fire.moblight = new fire.moblight_type(character)
