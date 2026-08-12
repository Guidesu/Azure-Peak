// DreamValley TAT extension: Alternate Form trait.
//
// Grants a self-targeted spell that lets a character temporarily assume the
// physical appearance of one of their parked (saved) characters from another
// preference slot. Only appearance is swapped — species, DNA, bodyparts, organs,
// hair, skin tone, eye color, and body size. Stats, skills, items, and mind
// stay with the caster. Casting again reverts to the original form.
//
// The trait is registered into GLOB.tat_available_traits and
// GLOB.tat_direction_trait_rules at world init so the TAT UI shows it
// without modifying upstream Twilight-Axis define files.

#define TAT_TRAIT_ALT_FORM "tat_alt_form"
#define ALT_FORM_TRAIT_SOURCE "alt_form_trait"

// Spell granted by the trait
/obj/effect/proc_holder/spell/self/alt_form
	name = "Assume Alternate Form"
	desc = "Transform your body into one of your saved characters. Cast again to revert."
	clothes_req = FALSE
	human_req = TRUE
	recharge_time = 100
	cooldown_min = 20
	invocation_type = "none"
	action_icon_state = "shapeshift"
	/// The saved appearance state we reverted FROM, used to restore.
	var/list/stored_original_appearance
	/// The record key of the currently-assumed form.
	var/current_alt_key

/obj/effect/proc_holder/spell/self/alt_form/cast(mob/living/carbon/human/user = usr)
	if(!istype(user) || !user.client)
		to_chat(user, span_warning("Something is wrong — you cannot use this right now."))
		return

	if(user.restrained(ignore_grab = FALSE))
		to_chat(user, span_warning("I am restrained and cannot transform!"))
		return

	// Already transformed? Revert.
	if(current_alt_key)
		revert_form(user)
		return

	// Gather parked characters belonging to this player across all preference slots.
	var/list/available = list()
	var/owner_ckey = ckey(user.client.key)
	if(!length(owner_ckey))
		to_chat(user, span_warning("You have no saved characters to draw upon."))
		return

	for(var/record_key in GLOB.dreamvalley_campaign?.parked_characters)
		var/list/record = GLOB.dreamvalley_campaign.parked_characters[record_key]
		if(!islist(record) || record["state"] != "parked" || record["complete"] != TRUE)
			continue
		if(record["owner_ckey"] != owner_ckey)
			continue
		// Skip the slot the current character is playing from.
		var/current_slot = user.client.prefs?.loaded_slot
		if(record["preference_slot"] == current_slot)
			continue
		var/list/core = record["core"]
		var/list/identity = core?["identity"]
		var/char_name = identity?["real_name"] || "Unknown"
		available["[char_name] (Slot [record["preference_slot"]])"] = record_key

	if(!length(available))
		to_chat(user, span_warning("You have no other saved characters to transform into. Park a character first via Far Travel."))
		return

	var/choice = tgui_input_list(user, "Which saved form shall you assume?", "Alternate Form", available)
	if(!choice || !available[choice])
		return

	var/record_key = available[choice]
	var/list/record = GLOB.dreamvalley_campaign.parked_characters[record_key]
	if(!islist(record) || record["state"] != "parked")
		to_chat(user, span_warning("That character is no longer available."))
		return

	var/list/core = record["core"]
	if(!islist(core))
		to_chat(user, span_warning("That character's save data is incomplete."))
		return

	// Capture current appearance for later reversion.
	stored_original_appearance = capture_appearance(user)
	if(!stored_original_appearance)
		to_chat(user, span_warning("Failed to capture current form. Transformation cancelled."))
		return

	// Apply the saved character's appearance to the current body.
	apply_appearance(user, core)
	current_alt_key = record_key

	to_chat(user, span_notice("Your body shifts and warps into a familiar form..."))
	playsound(user.loc, 'sound/magic/teleport_diss.ogg', 50, TRUE)

/obj/effect/proc_holder/spell/self/alt_form/proc/revert_form(mob/living/carbon/human/user)
	if(!stored_original_appearance)
		current_alt_key = null
		return

	to_chat(user, span_notice("You revert to your true form."))
	playsound(user.loc, 'sound/magic/teleport_diss.ogg', 50, TRUE)

	apply_appearance(user, stored_original_appearance)
	stored_original_appearance = null
	current_alt_key = null

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
		GLOB.tat_available_traits[TAT_TRAIT_ALT_FORM] = TAT_TRAIT_ENTRY("Alternate Form", 3, "Grants the ability to transform into one of your saved (parked) characters from another preference slot. Only appearance changes - stats, skills, and items remain your own. Cast the spell again to revert.")
	if(!GLOB.tat_direction_trait_rules)
		GLOB.tat_direction_trait_rules = list()
	if(!GLOB.tat_direction_trait_rules[TAT_TRAIT_ALT_FORM])
		GLOB.tat_direction_trait_rules[TAT_TRAIT_ALT_FORM] = TAT_DIRECTION_ENTRY(TAT_DIRECTION_MAGIC, list(TAT_DIRECTION_MAGIC = 2), 2)

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
	to_chat(H, span_notice("You feel a strange power stirring within — you can assume the form of your saved kin. Use the \"Assume Alternate Form\" ability."))
