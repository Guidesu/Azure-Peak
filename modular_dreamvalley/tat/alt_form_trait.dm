// DreamValley TAT extension: Alternate Form trait.
//
// Grants a self-targeted spell that lets a character temporarily assume the
// physical appearance of one of their saved characters from another
// preference slot. Only appearance is swapped - species, DNA, bodyparts,
// hair, skin tone, eye color, and body size. Stats, skills, items,
// and mind stay with the caster. Casting again reverts to the original form.
//
// The character to transform into is selected at the TAT trait screen when
// the trait is picked. The selection is stored as a preference slot number
// in the build's magic_profile under "alt_form_slot" and persists with the
// save. When the player joins the game with this trait, the spell reads the
// appearance data from that savefile slot and applies it on cast.
//
// The trait is registered into GLOB.tat_available_traits and
// GLOB.tat_direction_trait_rules at world init so the TAT UI shows it
// without modifying upstream Twilight-Axis define files.

#define TAT_TRAIT_ALT_FORM "tat_alt_form"
#define ALT_FORM_TRAIT_SOURCE "alt_form_trait"
#define ALT_FORM_MAGIC_KEY "alt_form_slot"

// Spell granted by the trait
/obj/effect/proc_holder/spell/self/alt_form
	name = "Assume Alternate Form"
	desc = "Transform your body into your selected saved character. Cast again to revert."
	clothes_req = FALSE
	human_req = TRUE
	recharge_time = 100
	cooldown_min = 20
	invocation_type = "none"
	action_icon_state = "shapeshift"
	/// The saved appearance state we reverted FROM, used to restore.
	var/list/stored_original_appearance
	/// The slot number of the currently-assumed form.
	var/current_alt_slot

/obj/effect/proc_holder/spell/self/alt_form/cast(mob/living/carbon/human/user = usr)
	if(!istype(user) || !user.client)
		to_chat(user, span_warning("Something is wrong - you cannot use this right now."))
		return

	if(user.restrained(ignore_grab = FALSE))
		to_chat(user, span_warning("I am restrained and cannot transform!"))
		return

	// Already transformed? Revert.
	if(current_alt_slot)
		revert_form(user)
		return

	// Read the preemptively-selected slot from the TAT build.
	var/datum/tat_build/build = user.client?.prefs?.dreamvalley_get_tat_build()
	var/stored_slot = text2num("[build?.get_magic_value(ALT_FORM_MAGIC_KEY)]") || 0

	if(!stored_slot)
		to_chat(user, span_warning("No alternate form selected. Use \"Select Alternate Form\" in the OOC tab to choose."))
		return

	// Don't transform into yourself.
	if(stored_slot == user.client.prefs?.loaded_slot)
		to_chat(user, span_warning("That is your current form. Select a different character slot."))
		return

	// Load the appearance data from the savefile slot.
	var/list/core = dreamvalley_load_alt_form_appearance(user.client, stored_slot)
	if(!islist(core))
		to_chat(user, span_warning("Could not load that character's appearance. The save may be missing or corrupted."))
		return

	// Capture current appearance for later reversion.
	stored_original_appearance = capture_appearance(user)
	if(!stored_original_appearance)
		to_chat(user, span_warning("Failed to capture current form. Transformation cancelled."))
		return

	// Apply the saved character's appearance to the current body.
	apply_appearance(user, core)
	current_alt_slot = stored_slot

	to_chat(user, span_notice("Your body shifts and warps into a familiar form..."))
	playsound(user.loc, 'sound/magic/teleport_diss.ogg', 50, TRUE)

/obj/effect/proc_holder/spell/self/alt_form/proc/revert_form(mob/living/carbon/human/user)
	if(!stored_original_appearance)
		current_alt_slot = null
		return

	to_chat(user, span_notice("You revert to your true form."))
	playsound(user.loc, 'sound/magic/teleport_diss.ogg', 50, TRUE)

	apply_appearance(user, stored_original_appearance)
	stored_original_appearance = null
	current_alt_slot = null

/// Build the list of available saved characters for a player, keyed by
/// slot number (as string) -> display name. Excludes the current preference
/// slot and empty slots.
/proc/dreamvalley_get_available_alt_forms(mob/user)
	var/list/available = list()
	if(!user?.client?.prefs)
		return available
	var/datum/preferences/prefs = user.client.prefs
	if(!prefs.path || !fexists(prefs.path))
		return available
	var/savefile/S = new /savefile(prefs.path)
	if(!S)
		return available
	var/current_slot = prefs.loaded_slot
	var/max_slots = prefs.max_save_slots
	for(var/slot in 1 to max_slots)
		if(slot == current_slot)
			continue
		S.cd = "/character[slot]"
		var/real_name
		S["real_name"] >> real_name
		if(!real_name)
			continue
		available["[slot]"] = "[real_name] (Slot [slot])"
	return available

/// Load appearance-relevant data from a savefile slot and return it in the
/// format expected by apply_appearance().
/proc/dreamvalley_load_alt_form_appearance(client/C, slot)
	if(!C?.prefs?.path || !fexists(C.prefs.path))
		return null
	var/savefile/S = new /savefile(C.prefs.path)
	if(!S)
		return null
	S.cd = "/character[slot]"

	var/real_name
	S["real_name"] >> real_name
	if(!real_name)
		return null

	// Read species name and resolve to type path.
	var/species_name
	S["species"] >> species_name
	var/species_path
	if(species_name && GLOB.species_list[species_name])
		species_path = GLOB.species_list[species_name]
	else
		species_path = /datum/species/human/northern

	// Read identity appearance vars.
	var/age
	var/gender
	var/pronouns
	var/hairstyle
	var/hair_color
	var/facial_hairstyle
	var/facial_hair_color
	var/skin_tone
	var/eye_color
	var/detail
	var/highlight_color
	var/char_accent
	S["age"] >> age
	S["gender"] >> gender
	S["pronouns"] >> pronouns
	S["hairstyle_name"] >> hairstyle
	S["hair_color"] >> hair_color
	S["facial_style_name"] >> facial_hairstyle
	S["facial_hair_color"] >> facial_hair_color
	S["skin_tone"] >> skin_tone
	S["eye_color"] >> eye_color
	S["detail"] >> detail
	S["highlight_color"] >> highlight_color
	S["char_accent"] >> char_accent

	// Read DNA features.
	var/list/features = list()
	S["feature_mcolor"] >> features["mcolor"]
	S["feature_mcolor2"] >> features["mcolor2"]
	S["feature_mcolor3"] >> features["mcolor3"]
	S["feature_ethcolor"] >> features["ethcolor"]
	var/body_size
	S["body_size"] >> body_size
	if(!isnull(body_size))
		features["body_size"] = body_size

	// Read body markings.
	var/list/body_markings
	S["body_markings"] >> body_markings

	// Read customizer entries for organ DNA.
	var/list/customizer_entries
	S["customizer_entries"] >> customizer_entries

	// Build the core list in the format apply_appearance expects.
	var/list/core = list()
	core["identity"] = list(
		"age" = age,
		"gender" = gender,
		"pronouns" = pronouns,
		"hairstyle" = hairstyle,
		"hair_color" = hair_color,
		"facial_hairstyle" = facial_hairstyle,
		"facial_hair_color" = facial_hair_color,
		"skin_tone" = skin_tone,
		"eye_color" = eye_color,
		"detail_color" = detail,
		"highlight_color" = highlight_color,
		"char_accent" = char_accent,
	)
	core["dna"] = list(
		"species_type" = "[species_path]",
		"features" = features,
		"body_markings" = islist(body_markings) ? body_markings : list(),
		"current_body_size" = body_size,
	)
	// Organ DNA is reconstructed from customizer entries if available.
	// We skip organ_dna here - it will be left as default for the species.
	// Bodyparts are also left to be rebuilt by set_species().
	return core

/// Capture appearance-relevant data from a human.
/obj/effect/proc_holder/spell/self/alt_form/proc/capture_appearance(mob/living/carbon/human/H)
	if(!istype(H) || !H.dna)
		return null

	var/list/state = list()

	// Identity vars that affect appearance.
	state["identity"] = dreamvalley_capture_scalar_vars(H, list(
		"age", "gender", "pronouns", "hairstyle", "hair_color",
		"facial_hairstyle", "facial_hair_color", "skin_tone", "eye_color",
		"detail_color", "highlight_color", "char_accent",
	))

	// DNA appearance data.
	var/list/dna_state = list()
	if(H.dna)
		dna_state["species_type"] = H.dna.species ? "[H.dna.species.type]" : null
		dna_state["features"] = deepCopyList(H.dna.features)
		dna_state["body_markings"] = deepCopyList(H.dna.body_markings)
		dna_state["current_body_size"] = H.dna.current_body_size
		var/list/organ_dna_states = list()
		for(var/organ_slot in H.dna.organ_dna)
			var/datum/organ_dna/organ_dna = H.dna.organ_dna[organ_slot]
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
	state["dna"] = dna_state

	// Bodypart appearance data.
	var/list/bodyparts = list()
	for(var/obj/item/bodypart/BP in H.bodyparts)
		bodyparts["[BP.body_zone]"] = list(
			"type" = "[BP.type]",
			"skin_tone" = BP.skin_tone,
			"species_color" = BP.species_color,
			"mutation_color" = BP.mutation_color,
		)
	state["bodyparts"] = bodyparts

	return state

/// Apply saved appearance data to a human, triggering icon updates.
/obj/effect/proc_holder/spell/self/alt_form/proc/apply_appearance(mob/living/carbon/human/H, list/core)
	if(!istype(H))
		return

	var/list/identity = core["identity"]
	var/list/dna_state = islist(identity) ? identity["dna"] : core["dna"]

	// Set species first (this rebuilds bodyparts).
	if(islist(dna_state))
		var/species_path = text2path(dna_state["species_type"])
		if(ispath(species_path, /datum/species))
			H.set_species(species_path, icon_update = FALSE)
			sleep(0)

	// Apply identity appearance vars.
	if(islist(identity))
		dreamvalley_apply_scalar_vars(H, identity, list("dna"))

	// Apply DNA appearance data.
	if(H.dna && islist(dna_state))
		dreamvalley_apply_scalar_vars(H.dna, dna_state)
		var/list/features = dna_state["features"]
		if(islist(features))
			H.dna.features = deepCopyList(features)
		var/list/body_markings = dna_state["body_markings"]
		if(islist(body_markings))
			H.dna.body_markings = deepCopyList(body_markings)
		var/list/organ_dna_states = dna_state["organ_dna"]
		if(islist(organ_dna_states))
			for(var/datum/organ_dna/old_organ_dna as anything in H.dna.organ_dna)
				qdel(old_organ_dna)
			H.dna.organ_dna = list()
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
				H.dna.organ_dna[organ_slot] = restored_organ_dna
		H.dna.update_body_size()

	// Apply bodypart skin colors.
	var/list/bodyparts = core["bodyparts"]
	if(islist(bodyparts))
		for(var/obj/item/bodypart/BP in H.bodyparts)
			var/list/bp_state = bodyparts["[BP.body_zone]"]
			if(!islist(bp_state))
				continue
			if(!isnull(bp_state["skin_tone"]))
				BP.skin_tone = bp_state["skin_tone"]
			if(!isnull(bp_state["species_color"]))
				BP.species_color = bp_state["species_color"]
			if(!isnull(bp_state["mutation_color"]))
				BP.mutation_color = bp_state["mutation_color"]

	// Force a full visual update.
	H.update_body_parts(TRUE)
	H.regenerate_icons()

/// Register the alt-form trait in TAT's global tables at world init.
/proc/dreamvalley_register_alt_form_trait()
	if(!GLOB.tat_available_traits)
		GLOB.tat_available_traits = list()
	if(!GLOB.tat_available_traits[TAT_TRAIT_ALT_FORM])
		GLOB.tat_available_traits[TAT_TRAIT_ALT_FORM] = TAT_TRAIT_ENTRY("Alternate Form", 3, "Grants the ability to transform into one of your saved characters from another preference slot. You must select which character at the trait screen. Only appearance changes - stats, skills, and items remain your own. Cast the spell again to revert.")
	if(!GLOB.tat_direction_trait_rules)
		GLOB.tat_direction_trait_rules = list()
	if(!GLOB.tat_direction_trait_rules[TAT_TRAIT_ALT_FORM])
		GLOB.tat_direction_trait_rules[TAT_TRAIT_ALT_FORM] = TAT_DIRECTION_ENTRY(TAT_DIRECTION_MAGIC, list(TAT_DIRECTION_MAGIC = 2), 2)

/// Hook called from the upstream TAT ui_act when the alt-form trait is added.
/// Prompts the player to select which saved character to use as their alt form.
/proc/dreamvalley_prompt_alt_form_selection(datum/tat_build/build, mob/user)
	if(!build || !user?.client)
		return
	var/list/available = dreamvalley_get_available_alt_forms(user)
	if(!length(available))
		// No saved characters in other slots yet - allow the trait but
		// warn the player with a visible popup.
		build.set_magic_value(ALT_FORM_MAGIC_KEY, null)
		tgui_alert(user, "You have no saved characters in other preference slots yet.\n\nThe Alternate Form trait is still added - you can select which character to transform into later.\n\nCreate a character in another preference slot, then use \"Select Alternate Form\" in the OOC tab to choose.", "Alternate Form - No Saved Characters Yet")
		return
	// Show the selection prompt.
	var/choice = tgui_input_list(user, "Which saved character will be your alternate form?", "Alternate Form Selection", available)
	if(!choice || !available[choice])
		return
	var/slot_key = choice
	var/display_name = available[slot_key]
	build.set_magic_value(ALT_FORM_MAGIC_KEY, text2num(slot_key))
	to_chat(user, span_notice("Your alternate form is now set to: [display_name]"))
	tgui_alert(user, "Your alternate form is now set to: [display_name]\n\nYou will be able to transform into this character using the \"Assume Alternate Form\" ability in-game.", "Alternate Form Selected")

/// Player verb to re-select the alt-form character.
/mob/verb/select_alternate_form()
	set category = "OOC"
	set name = "Select Alternate Form"
	set desc = "Choose which saved character your Alternate Form trait transforms into."

	if(!client?.prefs)
		to_chat(src, span_warning("No preferences loaded."))
		return
	var/datum/tat_build/build = client.prefs.dreamvalley_get_tat_build()
	if(!build)
		to_chat(src, span_warning("No TAT build loaded."))
		return
	if(!build.traits?.has_trait(TAT_TRAIT_ALT_FORM))
		to_chat(src, span_warning("You do not have the Alternate Form trait."))
		return
	dreamvalley_prompt_alt_form_selection(build, src)

/// Hook called after TAT traits are applied to a human. Grants the alt-form
/// spell if the trait is selected. Called from tat_integration.dm.
/proc/dreamvalley_apply_alt_form_trait(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind)
		return
	var/datum/tat_build/build = H.client?.prefs?.dreamvalley_get_tat_build()
	if(!build)
		return
	if(!build.traits?.has_trait(TAT_TRAIT_ALT_FORM))
		return
	// Don't grant duplicates.
	if(H.HasSpell(/obj/effect/proc_holder/spell/self/alt_form))
		return
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/alt_form)
	ADD_TRAIT(H, TAT_TRAIT_ALT_FORM, ALT_FORM_TRAIT_SOURCE)

	// Check if the stored selection is still valid.
	var/stored_slot = text2num("[build.get_magic_value(ALT_FORM_MAGIC_KEY)]") || 0
	var/list/available = dreamvalley_get_available_alt_forms(H)
	if(!stored_slot || !available["[stored_slot]"])
		if(length(available))
			to_chat(H, span_warning("Your alternate form selection is missing or invalid. Use \"Select Alternate Form\" in the OOC tab to choose."))
		else
			to_chat(H, span_warning("You have the Alternate Form trait but no saved characters in other slots to transform into. Create a character in another preference slot, then use \"Select Alternate Form\" in the OOC tab."))
	else
		var/char_name = available["[stored_slot]"]
		to_chat(H, span_notice("You feel a strange power stirring within - you can assume the form of [char_name]. Use the \"Assume Alternate Form\" ability."))
