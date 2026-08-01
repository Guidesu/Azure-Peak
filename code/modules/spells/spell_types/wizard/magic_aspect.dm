/datum/magic_aspect
	var/name = "Discipline"
	var/latin_name = ""
	var/desc = "A chi discipline — the art of channeling one's inner energy to manipulate the natural world through stance, breath, and will."
	var/aspect_type = ASPECT_MAJOR
	/// Appended to implements when attuned: "Fire" -> "Staff of Fire"
	var/attuned_name = ""
	// Always granted spells
	var/list/fixed_spells = list()
	/// Choice spells - pick exactly one. Granted FIRST (before fixed) so they appear first on the action bar.
	var/list/choice_spells = list()
	/// Subset of choice_spells only selectable at Mastery (T4). Still live in choice_spells for the grant/swap machinery.
	var/list/mastery_choice_spells = list()
	/// Pointbuy are optionals - for point buy aspect
	var/list/pointbuy_spells = list()
	var/pointbuy_budget = 0
	/// When set, spells are granted in this order. Empty = legacy choice-first-then-fixed.
	var/list/spell_order = list()
	/// Named variant spell swaps. Assoc list: variant_name = list(base_path = replacement_path, ...)
	/// "mastery" is automatically applied for T4 casters.
	/// Other variants (e.g. "gefechtsgelehrter") are passed in via attune_aspect().
	var/list/variants = list()
	var/applied_variant
	var/school_color
	/// Physical gestures performed when assuming/releasing the discipline.
	/// Each entry is a visible emote shown to nearby players.
	var/list/binding_gestures = list()
	var/list/unbinding_gestures = list()
	/// The choice spell that was actually picked during attunement. Set by grant_choice_spell().
	var/chosen_spell

/datum/magic_aspect/proc/get_implement_name(base_name)
	if(!attuned_name)
		return base_name
	return "[base_name] of [attuned_name]"

/// Grant a single choice spell. Called before grant_spells() so it appears first on the action bar.
/datum/magic_aspect/proc/grant_choice_spell(datum/mind/target, spell_path)
	if(!spell_path || !(spell_path in choice_spells))
		return
	chosen_spell = spell_path
	if(target.has_spell(spell_path))
		return
	var/datum/new_spell = new spell_path
	mark_aspect_spell(new_spell)
	target.AddSpell(new_spell)

/datum/magic_aspect/proc/grant_fixed_one(datum/mind/target, spell_path)
	if(!spell_path || target.has_spell(spell_path))
		return null
	var/datum/new_spell = new spell_path
	mark_aspect_spell(new_spell)
	target.AddSpell(new_spell)
	return new_spell

/datum/magic_aspect/proc/grant_spells(datum/mind/target)
	var/list/granted = list()
	for(var/spell_path in fixed_spells)
		var/datum/new_spell = grant_fixed_one(target, spell_path)
		if(new_spell)
			granted += new_spell
	return granted

/// Grant this aspect's spells in spell_order (manifest) order when defined; the resolved choice pick
/// slots in at the ASPECT_CHOICE token. Falls back to choice-first-then-fixed when no manifest is set.
/datum/magic_aspect/proc/grant_ordered(datum/mind/target, choice_spell)
	if(!length(spell_order))
		if(choice_spell)
			grant_choice_spell(target, choice_spell)
		grant_spells(target)
		return
	for(var/entry in spell_order)
		if(entry == ASPECT_CHOICE)
			if(choice_spell)
				grant_choice_spell(target, choice_spell)
		else if(entry == ASPECT_POINTBUY)
			continue
		else
			grant_fixed_one(target, entry)
	for(var/spell_path in fixed_spells)
		grant_fixed_one(target, spell_path)
	if(choice_spell && !target.has_spell(choice_spell))
		grant_choice_spell(target, choice_spell)

/// Apply a named variant's spell swaps. T4 casters automatically get "mastery".
/datum/magic_aspect/proc/apply_variant(datum/mind/target, variant_name)
	if(!variant_name || !length(variants) || !(variant_name in variants))
		return
	applied_variant = variant_name
	var/list/swaps = variants[variant_name]
	if(!length(swaps))
		return
	for(var/base_path in swaps)
		var/upgrade_path = swaps[base_path]
		if(base_path == VARIANT_ADDITIVE)
			// Additive mastery - grant new spell without removing anything
			var/datum/added = new upgrade_path
			mark_aspect_spell(added)
			target.AddSpell(added)
			continue
		var/datum/existing = target.get_spell(base_path)
		if(existing)
			// Find position in spell_list to preserve order
			var/spell_index = target.spell_list.Find(existing)
			target.RemoveSpell(existing)
			var/datum/action/cooldown/spell/upgraded = new upgrade_path
			// Tag the spell desc with variant name for display — don't change the name
			upgraded.desc = "[upgraded.desc]\n<b>Variant:</b> [capitalize(variant_name)]"
			mark_aspect_spell(upgraded)
			// Insert at original position instead of appending
			if(spell_index && spell_index <= length(target.spell_list) + 1)
				target.spell_list.Insert(spell_index, upgraded)
				upgraded.Grant(target.current)
			else
				target.AddSpell(upgraded)
	target.rebuild_action_order()

/// Resolve a base choice-spell path to the spell actually granted, accounting for the applied variant swap.
/datum/magic_aspect/proc/resolve_variant_spell(base_path)
	if(!base_path || !applied_variant || !(applied_variant in variants))
		return base_path
	var/list/swaps = variants[applied_variant]
	return swaps[base_path] || base_path

/// Revoke all spells granted by this aspect.
/// skip_spells: flat list of spell paths that should NOT be removed (granted by another source).
/datum/magic_aspect/proc/revoke_spells(datum/mind/target, list/skip_spells)
	for(var/spell_path in choice_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		var/datum/existing = target.get_spell(spell_path)
		if(existing)
			target.RemoveSpell(existing)
	for(var/spell_path in fixed_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		var/datum/existing = target.get_spell(spell_path)
		if(existing)
			target.RemoveSpell(existing)
	for(var/variant_name in variants)
		var/list/swaps = variants[variant_name]
		for(var/base_path in swaps)
			var/upgrade_path = swaps[base_path]
			if(LAZYLEN(skip_spells) && (upgrade_path in skip_spells))
				continue
			var/datum/existing = target.get_spell(upgrade_path)
			if(existing)
				target.RemoveSpell(existing)
	for(var/spell_path in pointbuy_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		var/datum/existing = target.get_spell(spell_path)
		if(existing)
			target.RemoveSpell(existing)

/datum/magic_aspect/proc/mark_aspect_spell(datum/action/cooldown/spell/spell_instance)
	if(!istype(spell_instance))
		return
	spell_instance.refundable = FALSE
	spell_instance.source_aspect = type

/// Perform the physical gestures for assuming or releasing a discipline.
/// Returns TRUE if completed, FALSE if interrupted.
/// Each gesture is a visible emote performed with a brief do_after between them —
/// no spoken words, only stance and motion, like a martial arts form.
/datum/magic_aspect/proc/perform_gestures(mob/living/bender, binding = TRUE)
	var/list/gestures = binding ? binding_gestures : unbinding_gestures
	if(!length(gestures))
		return TRUE
	for(var/gesture in gestures)
		bender.visible_message(span_notice("[bender] [gesture]"), span_notice("You [gesture]"))
		if(!do_after(bender, 2 SECONDS, target = bender))
			return FALSE
	return TRUE

GLOBAL_LIST_INIT(magic_aspects_major, init_magic_aspects(ASPECT_MAJOR))
GLOBAL_LIST_INIT(magic_aspects_minor, init_magic_aspects(ASPECT_MINOR))
GLOBAL_LIST_INIT(magic_aspect_singletons, init_magic_aspect_singletons())

/proc/init_magic_aspects(filter_type)
	var/list/result = list()
	for(var/path in subtypesof(/datum/magic_aspect))
		var/datum/magic_aspect/A = path
		if(initial(A.aspect_type) == filter_type)
			result += path
	return result

/proc/init_magic_aspect_singletons()
	var/list/result = list()
	for(var/path in subtypesof(/datum/magic_aspect))
		result[path] = new path
	return result
