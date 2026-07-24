/// Spawns a human, runs the DreamValley character graph capture/restore
/// round trip used by Far Travel, and fails if any section does not survive
/// it exactly. On failure, logs the saved vs. restored JSON for every
/// mismatched section so the differing field can be identified from the log.
/datum/unit_test/dreamvalley_character_round_trip

/datum/unit_test/dreamvalley_character_round_trip/Run()
	if(!GLOB.dreamvalley_campaign)
		return Fail("GLOB.dreamvalley_campaign is not initialized.", __FILE__, __LINE__)
	var/datum/dreamvalley_campaign_manager/campaign = GLOB.dreamvalley_campaign
	campaign.enabled = TRUE

	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	if(!H)
		return Fail("Could not spawn a human.", __FILE__, __LINE__)
	var/datum/mind/H_mind = new /datum/mind()
	allocated += H_mind
	H.mind = H_mind
	H_mind.current = H
	H_mind.active = FALSE

	var/list/core = campaign.capture_character_core(H)
	var/list/core_issues = campaign.validate_character_core(core)
	if(length(core_issues))
		return Fail("Initial capture reported issues: [core_issues.Join(", ")]", __FILE__, __LINE__)

	var/list/issues = campaign.validate_character_round_trip(H, core)
	if(!length(issues))
		return

	// Re-run the same restore the validator does, but keep the shadow and
	// dump full saved/restored JSON for every mismatched section so the
	// exact differing field can be found from the log.
	var/mob/living/carbon/human/shadow = new H.type(null)
	allocated += shadow
	shadow.invisibility = INVISIBILITY_MAXIMUM
	var/datum/mind/shadow_mind = new /datum/mind()
	allocated += shadow_mind
	shadow.mind = shadow_mind
	shadow_mind.current = shadow
	shadow_mind.active = FALSE

	campaign.restore_character_core(shadow, core)
	var/list/restored_core = campaign.capture_character_core(shadow)

	for(var/section in list(
		"identity", "vitals", "stats", "skills", "mind", "bodyparts",
		"organs", "traits", "status_effects", "reagents", "items",
	))
		if(!campaign.character_section_round_trip_matches(section, core[section], restored_core[section]))
			log_world("DREAMVALLEY DIFF [section] SAVED::: [json_encode(core[section])]")
			log_world("DREAMVALLEY DIFF [section] RESTORED::: [json_encode(restored_core[section])]")

	return Fail("Round trip issues: [issues.Join(", ")]", __FILE__, __LINE__)
