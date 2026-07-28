// TGUI character sheet — full replacement for the classic ShowChoices
// "Character" tab (identity, vices, colors, voice/bark, flavor & OOC text,
// gallery, loadout) matching TAT Build's look. Game Settings/OOC/Keybinds
// are separate tabchoice values on the classic window and untouched by this.
//
// The three per-species-dynamic subsystems (Customizers, Body Markings,
// Descriptors), Food Preferences, and Familiar Preferences already live in
// their own popups outside the tab-0 HTML block (ShowCustomizers/
// ShowMarkings/show_descriptors_ui/show_culinary_ui/fam_show_ui) — those
// keep working exactly as before, just launched by a button here instead of
// a text link. A native full React rebuild of those specifically is still a
// separate, larger follow-up.
//
// Live sprite preview: mirrors update_preview_icon()'s classic-window
// approach (preferences_setup.dm) — copy_to() a pooled dummy mob, flatten it
// with getFlatIcon(), then register the flattened icon as a tgui asset (the
// same registration pattern hair_asset()/hair_asset_url() use in
// customizer/customizers/bodypart_feature/hair.dm) and hand the resulting
// URL to ui_data() instead of driving BYOND screen-objects, since TGUI has
// no equivalent of the native preferences window's MAP control. Regenerated
// only when dirtied (see mark_preview_dirty()) rather than on every ui_data
// poll, since flattening+re-encoding a full-body icon on every tick would be
// wasteful — nothing here changes without the player taking an action first.

/datum/preferences
	var/datum/character_sheet_ui/dreamvalley_character_sheet_ui

/datum/preferences/proc/dreamvalley_open_character_sheet_ui(mob/user)
	// Same window this tab uses natively (see ShowChoices' winshow call and
	// the "finished" case's own close-up) — hide it so the TGUI panel
	// replaces it instead of floating on top of it.
	winshow(user, "preferencess_window", FALSE)
	dreamvalley_sanitize_character_sheet_prefs()
	if(!dreamvalley_character_sheet_ui)
		dreamvalley_character_sheet_ui = new(user.client)
	dreamvalley_character_sheet_ui.ui_interact(user)

// Defensive/repair fixups that used to run every time the classic tab-0 HTML
// was built (see the old ShowChoices Character tab). Preserved here so stale
// or invalid saved prefs still get auto-corrected when the sheet is opened.
/datum/preferences/proc/dreamvalley_sanitize_character_sheet_prefs()
	if(!voice_pack)
		voice_pack = "Default"
	if(istype(virtue_origin, /datum/virtue/none))
		virtue_origin = GLOB.virtues[/datum/virtue/origin/unknown]
	if(!length(pref_species.custom_selection))
		race_bonus = null
	if(!averse_chosen_faction)
		averse_chosen_faction = "Inquisition"

/datum/character_sheet_ui
	var/client/owner
	/// Cached tgui asset name for the last-flattened preview icon, or null if none generated yet.
	var/preview_asset_name
	/// Facing direction shown in the portrait; player can spin it with a button.
	var/preview_dir = SOUTH
	/// Set TRUE by mark_preview_dirty() whenever an appearance-affecting field changes; cleared once ui_data() re-flattens.
	var/preview_dirty = TRUE

/datum/character_sheet_ui/New(client/C)
	owner = C

/datum/character_sheet_ui/Destroy()
	owner = null
	return ..()

/datum/character_sheet_ui/proc/get_prefs()
	return owner?.prefs

/datum/character_sheet_ui/proc/mark_preview_dirty()
	preview_dirty = TRUE

/// Flattens a pooled dummy mob wearing the current prefs into a static icon and registers it as a tgui asset, mirroring update_preview_icon()'s classic MAP-based preview.
/datum/character_sheet_ui/proc/refresh_preview(mob/user)
	var/datum/preferences/P = get_prefs()
	if(!P || !P.pref_species)
		return
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	P.copy_to(mannequin, 1, TRUE, TRUE)
	mannequin.rebuild_obscured_flags()
	mannequin.dir = preview_dir
	var/icon/flat = getFlatIcon(mannequin, preview_dir, no_anim = TRUE)
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	if(!flat)
		return
	preview_asset_name = hair_asset(flat)
	preview_dirty = FALSE

/datum/character_sheet_ui/proc/get_preview_url(mob/user)
	if(preview_dirty || !preview_asset_name)
		refresh_preview(user)
	if(!preview_asset_name)
		return null
	return hair_asset_url(preview_asset_name, user)

/datum/character_sheet_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_sheet_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		mark_preview_dirty()
		ui = new(user, src, "CharacterSheet", "Character Sheet")
		ui.open()

/datum/character_sheet_ui/ui_static_data(mob/user)
	var/list/data = list()
	data["pronoun_options"] = GLOB.pronouns_list
	data["voice_type_options"] = GLOB.voice_types_list
	data["titles_options"] = list(TITLES_M, TITLES_F)
	data["clothes_options"] = list(CLOTHES_M, CLOTHES_F)

	var/list/voice_pack_options = list()
	for(var/pack_name in GLOB.voice_packs_list)
		voice_pack_options += pack_name
	data["voice_pack_options"] = voice_pack_options

	var/list/music_options = list()
	for(var/track_name in GLOB.cmode_tracks_by_name)
		music_options += track_name
	data["combat_music_options"] = music_options
	return data

/datum/character_sheet_ui/proc/build_species_options(datum/preferences/P, mob/user)
	var/list/result = list()
	var/patreon_level = owner?.patreonlevel() || 0
	for(var/species_name in GLOB.roundstart_races)
		var/species_path = GLOB.species_list[species_name]
		if(!species_path)
			continue
		// base_name/sub_name/is_subrace are only finalized by /datum/species/New()'s
		// defaulting logic (see species.dm), so they must be read off a real
		// instance — :: static access returns the raw, often-unset compile-time
		// value and silently breaks this list. Matches the classic species-picker
		// in preferences.dm's Topic() switch, which also instantiates to inspect.
		var/datum/species/probe = new species_path()
		if(probe.patreon_req > patreon_level)
			qdel(probe)
			continue
		if(probe.is_subrace)
			qdel(probe)
			continue
		if(probe.base_name == P.pref_species.base_name)
			qdel(probe)
			continue
		result[probe.base_name] = species_path
		qdel(probe)
	return result

/datum/character_sheet_ui/proc/build_subspecies_options(datum/preferences/P, mob/user)
	var/list/result = list()
	for(var/species_name in GLOB.roundstart_races)
		var/species_path = GLOB.species_list[species_name]
		if(!species_path)
			continue
		var/datum/species/probe = new species_path()
		if(probe.base_name != P.pref_species.base_name)
			qdel(probe)
			continue
		if(probe.sub_name == P.pref_species.sub_name)
			qdel(probe)
			continue
		result[probe.sub_name] = species_path
		qdel(probe)
	return result

/datum/character_sheet_ui/proc/build_origin_options(datum/preferences/P)
	var/list/result = list()
	for(var/path as anything in GLOB.virtues)
		var/datum/virtue/V = GLOB.virtues[path]
		if(!V.name || V.name == P.virtue_origin?.name)
			continue
		if(!istype(V, /datum/virtue/origin))
			continue
		if(V.restricted && (P.pref_species.type in V.races))
			continue
		if(istype(V, /datum/virtue/origin/racial) && !(P.pref_species.type in V.races))
			continue
		result[V.name] = V.type
	return result

/datum/character_sheet_ui/proc/build_statpack_options()
	var/list/result = list()
	for(var/path as anything in GLOB.statpacks)
		var/datum/statpack/pack = GLOB.statpacks[path]
		if(!pack.name)
			continue
		if(istype(pack, /datum/statpack/wildcard/fated) || istype(pack, /datum/statpack/wildcard/virtuous))
			continue
		var/index = pack.name
		if(length(pack.stat_array))
			index += " [pack.generate_modifier_string()]"
		result[index] = path
	return result

/datum/character_sheet_ui/proc/build_faith_options()
	var/list/result = list()
	for(var/path as anything in GLOB.preference_faiths)
		var/datum/faith/faith = GLOB.faithlist[path]
		if(!faith.name)
			continue
		result[faith.name] = path
	return result

/datum/character_sheet_ui/proc/build_patron_options(datum/preferences/P)
	var/list/result = list()
	var/anchor_faith = P.selected_patron?.associated_faith || initial(P.default_patron.associated_faith)
	for(var/path as anything in GLOB.patrons_by_faith[anchor_faith])
		var/datum/patron/patron = GLOB.patronlist[path]
		if(!patron.name)
			continue
		result[patron.name] = path
	return result

/datum/character_sheet_ui/proc/build_extra_language_options(datum/preferences/P)
	var/static/list/selectable_languages = list(
		/datum/language/elvish,
		/datum/language/dwarvish,
		/datum/language/orcish,
		/datum/language/hellspeak,
		/datum/language/draconic,
		/datum/language/celestial,
		/datum/language/dvojezemi,
		/datum/language/auxentian,
		/datum/language/medullan,
		/datum/language/ostrovian,
		/datum/language/vergenmarkian,
	)
	var/list/result = list("None" = "None")
	for(var/language_path in selectable_languages)
		if(language_path in P.pref_species.languages)
			continue
		var/datum/language/language_ref = language_path
		result[language_ref::name] = language_path
	return result

/datum/character_sheet_ui/proc/build_taur_options(datum/preferences/P)
	var/list/result = list()
	for(var/taur_path in P.pref_species.get_taur_list())
		var/obj/item/bodypart/taur/taur_ref = taur_path
		result[taur_ref::name] = taur_path
	return result

/datum/character_sheet_ui/proc/get_language_display_name(language_path)
	if(!language_path || language_path == "None")
		return "None"
	var/datum/language/language_ref = language_path
	return language_ref::name

/datum/character_sheet_ui/proc/get_taur_display_name(taur_path)
	if(!taur_path)
		return null
	var/obj/item/bodypart/taur/taur_ref = taur_path
	return taur_ref::name

/datum/character_sheet_ui/proc/build_charflaw_options(datum/preferences/P)
	var/list/result = list()
	for(var/key in GLOB.character_flaws)
		var/flaw_path = GLOB.character_flaws[key]
		if(flaw_path == /datum/charflaw/noflaw)
			continue
		var/datum/charflaw/flaw_ref = flaw_path
		if(length(flaw_ref::restricted_species) && (P.pref_species.type in flaw_ref::restricted_species))
			continue
		var/already_has = FALSE
		for(var/datum/charflaw/existing in P.charflaws)
			if(existing.type == flaw_path && !istype(existing, /datum/charflaw/randflaw))
				already_has = TRUE
				break
		if(already_has)
			continue
		result[key] = flaw_path
	return result

/datum/character_sheet_ui/proc/build_bark_options(mob/user)
	var/list/result = list()
	for(var/path in GLOB.bark_list)
		var/datum/bark/B = GLOB.bark_list[path]
		if(initial(B.ignore))
			continue
		if(initial(B.ckeys_allowed))
			var/list/allowed = initial(B.ckeys_allowed)
			if(!allowed.Find(user.client.ckey))
				continue
		result[initial(B.name)] = initial(B.id)
	return result

/datum/character_sheet_ui/proc/build_examine_theme_options()
	var/list/result = list()
	var/list/all_themes = get_tgui_themes()
	for(var/theme_key in all_themes)
		if(theme_key == "trey_liam")
			continue
		result[all_themes[theme_key]] = theme_key
	return result

/datum/character_sheet_ui/proc/build_skin_tone_options(datum/preferences/P)
	var/list/result = P.pref_species.get_skin_list()
	if(istype(P.virtue, /datum/virtue/combat/second_chance) || istype(P.virtuetwo, /datum/virtue/combat/second_chance))
		result["Rotten"] = SKIN_COLOR_ROT
	return result

/datum/character_sheet_ui/ui_data(mob/user)
	var/datum/preferences/P = get_prefs()
	var/list/data = list()
	if(!P)
		return data

	data["real_name"] = P.real_name
	data["nickname"] = P.nickname
	data["pronouns"] = P.pronouns
	data["titles_pref"] = P.titles_pref
	data["clothes_pref"] = P.clothes_pref
	data["voice_type"] = P.voice_type
	data["voice_pack"] = P.voice_pack
	data["combat_music"] = P.combat_music?.name

	data["age"] = P.age
	data["age_options"] = P.pref_species.possible_ages

	data["species"] = P.pref_species.base_name
	data["species_options"] = build_species_options(P, user)

	data["subspecies"] = P.pref_species.sub_name
	data["subspecies_options"] = build_subspecies_options(P, user)

	data["origin"] = P.virtue_origin?.name
	data["origin_options"] = build_origin_options(P)

	data["race_bonus"] = P.race_bonus
	data["race_bonus_options"] = length(P.pref_species.custom_selection) ? P.pref_species.custom_selection : list()

	data["extra_language"] = get_language_display_name(P.extra_language)
	data["extra_language_options"] = build_extra_language_options(P)

	data["statpack"] = P.statpack?.name
	data["statpack_options"] = build_statpack_options()
	data["taur_type"] = get_taur_display_name(P.taur_type)
	data["taur_options"] = build_taur_options(P)
	data["taur_color"] = P.taur_color

	data["faith"] = GLOB.faithlist[P.selected_patron?.associated_faith]?.name
	data["faith_options"] = build_faith_options()

	data["patron"] = P.selected_patron?.name
	data["patron_options"] = build_patron_options(P)

	// ── Vices ──────────────────────────────────────────────────────
	var/list/charflaw_list = list()
	for(var/datum/charflaw/cf in P.charflaws)
		if(istype(cf, /datum/charflaw/noflaw))
			continue
		charflaw_list += list(list("name" = cf.name, "desc" = cf.desc))
	data["charflaws"] = charflaw_list
	data["charflaw_options"] = build_charflaw_options(P)
	data["max_vices"] = MAX_VICES

	var/has_averse = FALSE
	for(var/datum/charflaw/cf in P.charflaws)
		if(istype(cf, /datum/charflaw/averse))
			has_averse = TRUE
			break
	data["has_averse_vice"] = has_averse
	data["averse_faction"] = P.averse_chosen_faction
	data["averse_faction_options"] = GLOB.averse_factions

	// ── Body / colors ──────────────────────────────────────────────
	data["dominant_hand"] = (P.domhand == 1) ? "Left-handed" : "Right-handed"
	data["skin_tone_wording"] = P.pref_species.skin_tone_wording
	data["uses_skin_tones"] = !!P.pref_species.use_skintones
	data["skin_tone"] = P.skin_tone
	data["skin_tone_options"] = P.pref_species.use_skintones ? build_skin_tone_options(P) : list()
	data["uses_mutant_colors"] = (MUTCOLORS in P.pref_species.species_traits) || (MUTCOLORS_PARTSONLY in P.pref_species.species_traits)
	data["mutant_color"] = P.features["mcolor"]
	data["mutant_color2"] = P.features["mcolor2"]
	data["mutant_color3"] = P.features["mcolor3"]
	data["update_mutant_colors"] = !!P.update_mutant_colors
	data["body_size"] = round((P.features["body_size"] || 1) * 100)

	// ── Voice / bark ───────────────────────────────────────────────
	data["highlight_color"] = P.highlight_color
	data["voice_color"] = P.voice_color
	data["voice_pitch"] = P.voice_pitch
	var/datum/bark/current_bark = GLOB.bark_list[P.bark_id]
	data["bark_sound"] = current_bark ? initial(current_bark.name) : null
	data["bark_options"] = build_bark_options(user)
	data["bark_speed"] = P.bark_speed
	data["bark_pitch"] = P.bark_pitch
	data["bark_variance"] = P.bark_variance

	// ── Flavor / OOC text ────────────────────────────────────────
	data["flavortext"] = P.flavortext
	data["nsfwflavortext"] = P.nsfwflavortext
	data["ooc_notes"] = P.ooc_notes
	data["rumour"] = P.rumour
	data["noble_gossip"] = P.noble_gossip
	data["erpprefs"] = P.erpprefs
	data["ooc_extra"] = P.ooc_extra
	data["song_title"] = P.song_title
	data["song_artist"] = P.song_artist
	data["headshot_link"] = P.headshot_link
	data["examine_theme"] = P.examine_theme ? (get_tgui_themes()[P.examine_theme] || P.examine_theme) : "None (Use Viewer's)"
	data["examine_theme_options"] = build_examine_theme_options()
	data["img_gallery"] = P.img_gallery
	data["nsfw_img_gallery"] = P.nsfw_img_gallery

	// ── Estate (ported Manors system) ───────────────────────────────
	data["have_manor"] = P.have_manor
	data["manor_name"] = P.manor_name
	data["manor_type"] = P.manor_type
	data["manor_type_display"] = P.get_manor_type_display_name()
	data["manor_type_options"] = list("Manor", "Hunter Mansion", "Village", "Fisher Hamlet", "Mining Settlement")

	// ── Hub (meta links formerly on the classic Character tab) ─────
	data["playerquality_text"] = get_playerquality(user.ckey, text = TRUE)
	data["triumphs_text"] = user.get_triumphs() ? "\Roman [user.get_triumphs()]" : "None"
	data["triumph_buys_enabled"] = !!SStriumphs.triumph_buys_enabled
	data["agevetted"] = !!user.check_agevet()
	data["current_quirks"] = P.all_quirks.len ? P.all_quirks.Join(", ") : "None"
	data["roundstart_traits_enabled"] = !!CONFIG_GET(flag/roundstart_traits)

	// ── Live sprite preview ──────────────────────────────────────────
	data["preview_url"] = get_preview_url(user)
	data["preview_dir"] = preview_dir
	return data

/datum/character_sheet_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/user = ui.user
	var/datum/preferences/P = get_prefs()
	if(!P)
		return TRUE

	switch(action)
		if("set_name")
			var/new_name = reject_bad_name(params["value"])
			if(new_name)
				P.real_name = new_name
			else
				to_chat(user, span_warning("Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ', . and ,."))
			return TRUE

		if("set_nickname")
			var/new_nick = reject_bad_name(params["value"])
			if(new_nick)
				P.nickname = new_nick
			else
				to_chat(user, span_warning("Invalid nickname. Your nickname should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ', . and ,."))
			return TRUE

		if("set_pronouns")
			if(!(params["value"] in GLOB.pronouns_list))
				return TRUE
			P.pronouns = params["value"]
			P.ResetJobs()
			to_chat(user, span_warning("Your character's pronouns are now [P.pronouns]. Your classes have been reset."))
			return TRUE

		if("set_titles_pref")
			if(!(params["value"] in list(TITLES_M, TITLES_F)))
				return TRUE
			P.titles_pref = params["value"]
			return TRUE

		if("set_clothes_pref")
			if(!(params["value"] in list(CLOTHES_M, CLOTHES_F)))
				return TRUE
			P.clothes_pref = params["value"]
			return TRUE

		if("set_voice_type")
			if(!(params["value"] in GLOB.voice_types_list))
				return TRUE
			P.voice_type = params["value"]
			return TRUE

		if("set_voice_pack")
			var/pack_name = params["value"]
			if(!(pack_name in GLOB.voice_packs_list))
				return TRUE
			P.voice_pack = pack_name
			return TRUE

		if("preview_voice_pack")
			if(P.voice_pack != "Default")
				var/datum/voicepack/VP = GLOB.voice_packs[GLOB.voice_packs_list[P.voice_pack]]
				if(VP && length(VP.preview))
					user.playsound_local(user, VP.get_sound(pick(VP.preview)), 100)
			return TRUE

		if("set_combat_music")
			var/track_name = params["value"]
			if(!(track_name in GLOB.cmode_tracks_by_name))
				return TRUE
			P.combat_music = GLOB.cmode_tracks_by_name[track_name]
			return TRUE

		if("set_age")
			var/new_age = params["value"]
			if(!(new_age in P.pref_species.possible_ages))
				return TRUE
			P.age = new_age
			var/list/hairs
			if((P.age == AGE_OLD) && (OLDGREY in P.pref_species.species_traits))
				hairs = P.pref_species.get_oldhc_list()
			else
				hairs = P.pref_species.get_hairc_list()
			P.hair_color = hairs[pick(hairs)]
			P.facial_hair_color = P.hair_color
			switch(P.age)
				if(AGE_ADULT)
					to_chat(user, "You preside in your 'prime', whatever this may be, and gain no bonus nor endure any penalty for your time spent alive.")
				if(AGE_MIDDLEAGED)
					to_chat(user, "Muscles ache and joints begin to slow as Aeon's grasp begins to settle upon your shoulders. (-1 SPD, +1 WIL +1 FOR)")
				if(AGE_OLD)
					to_chat(user, "In a place as lethal as VAELTIS, the elderly are all but marvels... or beneficiaries of the habitually privileged. (-1 STR, -2 SPE, -1 PER, -2 CON, +2 INT, +1 FOR)")
			P.ResetJobs()
			to_chat(user, span_warning("Classes reset."))
			return TRUE

		if("set_species")
			var/list/options = build_species_options(P, user)
			var/species_path = options[params["value"]]
			if(!species_path)
				return TRUE
			P.set_new_race(new species_path(), user)
			mark_preview_dirty()
			return TRUE

		if("set_subspecies")
			var/list/options = build_subspecies_options(P, user)
			var/species_path = options[params["value"]]
			if(!species_path)
				return TRUE
			P.set_new_race(new species_path(), user)
			mark_preview_dirty()
			return TRUE

		if("set_origin")
			var/list/options = build_origin_options(P)
			var/origin_path = options[params["value"]]
			if(!origin_path)
				return TRUE
			// Matches the classic picker: origins are assigned by reference to
			// the single shared GLOB.virtues instance, not a fresh copy.
			var/datum/virtue/chosen = GLOB.virtues[origin_path]
			P.virtue_origin = chosen
			to_chat(user, P.process_virtue_text(chosen))
			return TRUE

		if("open_origin_lore")
			if(!P.virtue_origin)
				return TRUE
			var/list/dat = list()
			dat += "<b>Origin Description:</b><br>"
			dat += "[P.virtue_origin.origin_desc]"
			var/datum/browser/popup = new(user, "Race Help", nwidth = 600, nheight = 450)
			popup.set_content(dat.Join())
			popup.open(FALSE)
			return TRUE

		if("open_patron_lore")
			if(!P.selected_patron)
				return TRUE
			var/datum/faith/patron_faith = GLOB.faithlist[P.selected_patron.associated_faith]
			var/list/dat = list()
			dat += "<b>[P.selected_patron.name] — [P.selected_patron.domain]</b><br>"
			if(patron_faith?.name)
				dat += "<i>Faith: [patron_faith.name]</i><br><br>"
			dat += "[P.selected_patron.desc]<br><br>"
			if(P.selected_patron.worshippers)
				dat += "<b>Worshippers:</b> [P.selected_patron.worshippers]"
			var/datum/browser/popup = new(user, "Patron Help", nwidth = 600, nheight = 450)
			popup.set_content(dat.Join())
			popup.open(FALSE)
			return TRUE

		if("set_statpack")
			var/list/options = build_statpack_options()
			var/statpack_path = options[params["value"]]
			if(!statpack_path)
				return TRUE
			P.statpack = GLOB.statpacks[statpack_path]
			to_chat(user, span_purple("[P.statpack.name]"))
			to_chat(user, span_purple("[P.statpack.description_string()]"))
			return TRUE

		if("set_race_bonus")
			if(!length(P.pref_species.custom_selection) || !(params["value"] in P.pref_species.custom_selection))
				return TRUE
			P.race_bonus = params["value"]
			return TRUE

		if("set_extra_language")
			var/list/options = build_extra_language_options(P)
			if(!(params["value"] in options))
				return TRUE
			P.extra_language = options[params["value"]]
			return TRUE

		if("set_taur_type")
			var/list/options = build_taur_options(P)
			if(params["value"] == "None")
				P.taur_type = null
				return TRUE
			var/taur_path = options[params["value"]]
			if(!taur_path)
				return TRUE
			P.taur_type = taur_path
			mark_preview_dirty()
			return TRUE

		if("set_taur_color")
			var/new_taur_color = color_pick_sanitized(user, "Choose your character's taur color:", "Character Preference", "#"+P.taur_color)
			if(new_taur_color)
				P.taur_color = sanitize_hexcolor(new_taur_color)
				mark_preview_dirty()
			return TRUE

		if("set_faith")
			var/list/options = build_faith_options()
			var/faith_path = options[params["value"]]
			if(!faith_path)
				return TRUE
			var/datum/faith/faith = GLOB.faithlist[faith_path]
			P.selected_patron = GLOB.patronlist[faith.godhead] || GLOB.patronlist[pick(GLOB.patrons_by_faith[faith_path])]
			return TRUE

		if("set_patron")
			var/list/options = build_patron_options(P)
			var/patron_path = options[params["value"]]
			if(!patron_path)
				return TRUE
			P.selected_patron = GLOB.patronlist[patron_path]
			return TRUE

		// ── Vices ──────────────────────────────────────────────────
		if("add_vice")
			for(var/datum/charflaw/existing in P.charflaws)
				if(istype(existing, /datum/charflaw/noflaw))
					P.charflaws.Remove(existing)
					break
			if(P.charflaws.len >= MAX_VICES)
				to_chat(user, "I can't be any more flawed.")
				return TRUE
			var/list/options = build_charflaw_options(P)
			var/flaw_path = options[params["value"]]
			if(!flaw_path)
				return TRUE
			var/datum/charflaw/C = new flaw_path()
			P.charflaws.Add(C)
			if(C.desc)
				to_chat(user, span_info(C.desc))
			return TRUE

		if("remove_vice")
			var/index = text2num(params["index"])
			if(index && (index >= 1) && (index <= P.charflaws.len))
				var/datum/charflaw/cf_to_remove = P.charflaws[index]
				P.charflaws.Remove(cf_to_remove)
				to_chat(user, span_notice("Vice removed: [cf_to_remove.name]."))
			if(!P.charflaws.len)
				var/datum/charflaw/no_flaw = new /datum/charflaw/noflaw()
				P.charflaws.Add(no_flaw)
				to_chat(user, span_info("No vices selected. 'No Flaw' has been automatically selected."))
			return TRUE

		if("set_averse_faction")
			if(!(params["value"] in GLOB.averse_factions))
				return TRUE
			P.averse_chosen_faction = params["value"]
			return TRUE

		// ── Body / colors ────────────────────────────────────────────
		if("set_domhand")
			P.domhand = (P.domhand == 1) ? 2 : 1
			return TRUE

		if("toggle_dnr")
			P.dnr_pref = !P.dnr_pref
			return TRUE

		if("set_skin_tone")
			var/list/options = build_skin_tone_options(P)
			var/tone = options[params["value"]]
			if(!tone)
				return TRUE
			P.skin_tone = tone
			P.features["mcolor"] = sanitize_hexcolor(P.skin_tone)
			P.try_update_mutant_colors()
			mark_preview_dirty()
			return TRUE

		if("set_mutant_color")
			var/new_color = color_pick_sanitized(user, "Choose your character's mutant #1 color:", "Character Preference", "#"+P.features["mcolor"])
			if(new_color)
				P.features["mcolor"] = sanitize_hexcolor(new_color)
				P.try_update_mutant_colors()
				mark_preview_dirty()
			return TRUE

		if("set_mutant_color2")
			var/new_color = color_pick_sanitized(user, "Choose your character's mutant #2 color:", "Character Preference", "#"+P.features["mcolor2"])
			if(new_color)
				P.features["mcolor2"] = sanitize_hexcolor(new_color)
				P.try_update_mutant_colors()
				mark_preview_dirty()
			return TRUE

		if("set_mutant_color3")
			var/new_color = color_pick_sanitized(user, "Choose your character's mutant #3 color:", "Character Preference", "#"+P.features["mcolor3"])
			if(new_color)
				P.features["mcolor3"] = sanitize_hexcolor(new_color)
				P.try_update_mutant_colors()
				mark_preview_dirty()
			return TRUE

		if("toggle_update_mutant_colors")
			P.update_mutant_colors = !P.update_mutant_colors
			mark_preview_dirty()
			return TRUE

		if("set_body_size")
			var/new_size = text2num(params["value"])
			if(!new_size)
				return TRUE
			new_size = clamp(new_size * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
			P.features["body_size"] = new_size
			mark_preview_dirty()
			return TRUE

		if("spin_preview")
			var/list/dirs = list(SOUTH, WEST, NORTH, EAST)
			var/cur_index = dirs.Find(preview_dir) || 1
			preview_dir = dirs[(cur_index % dirs.len) + 1]
			mark_preview_dirty()
			return TRUE

		// ── Voice / bark ─────────────────────────────────────────────
		if("set_highlight_color")
			var/new_color = color_pick_sanitized(user, "Choose your character's nickname highlight color:", "Character Preference", "#"+P.highlight_color)
			if(new_color)
				P.highlight_color = sanitize_hexcolor(new_color)
			return TRUE

		if("set_voice_color")
			var/new_color = input(user, "Choose your character's voice color:", "Character Preference", "#"+P.voice_color) as color|null
			if(new_color)
				P.voice_color = sanitize_hexcolor(new_color)
			return TRUE

		if("set_voice_pitch")
			var/new_pitch = tgui_input_number(user, "Choose your character's voice pitch ([MIN_VOICE_PITCH] to [MAX_VOICE_PITCH], lower is deeper):", "Voice Pitch", P.voice_pitch, 1.35, 0.8, round_value = FALSE)
			if(new_pitch)
				if(new_pitch < MIN_VOICE_PITCH || new_pitch > MAX_VOICE_PITCH)
					return TRUE
				P.voice_pitch = new_pitch
			return TRUE

		if("set_bark_sound")
			var/list/options = build_bark_options(user)
			var/bark_path = options[params["value"]]
			if(!bark_path)
				return TRUE
			P.bark_id = bark_path
			var/datum/bark/B = GLOB.bark_list[P.bark_id]
			P.bark_speed = round(clamp(P.bark_speed, initial(B.minspeed), initial(B.maxspeed)), 1)
			P.bark_pitch = clamp(P.bark_pitch, initial(B.minpitch), initial(B.maxpitch))
			P.bark_variance = clamp(P.bark_variance, initial(B.minvariance), initial(B.maxvariance))
			return TRUE

		if("set_bark_speed")
			var/datum/bark/B = GLOB.bark_list[P.bark_id]
			var/new_speed = text2num(params["value"])
			if(!new_speed || !B)
				return TRUE
			P.bark_speed = round(clamp(new_speed, initial(B.minspeed), initial(B.maxspeed)), 1)
			return TRUE

		if("set_bark_pitch")
			var/datum/bark/B = GLOB.bark_list[P.bark_id]
			var/new_pitch = text2num(params["value"])
			if(!new_pitch || !B)
				return TRUE
			P.bark_pitch = clamp(new_pitch, initial(B.minpitch), initial(B.maxpitch))
			return TRUE

		if("set_bark_variance")
			var/datum/bark/B = GLOB.bark_list[P.bark_id]
			var/new_variance = text2num(params["value"])
			if(isnull(new_variance) || !B)
				return TRUE
			P.bark_variance = clamp(new_variance, initial(B.minvariance), initial(B.maxvariance))
			return TRUE

		if("preview_bark")
			if(SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(user, span_warning("Bark previews can't play during initialization!"))
				return TRUE
			if(!COOLDOWN_FINISHED(P, bark_previewing))
				return TRUE
			if(!P.parent || !P.parent.mob)
				return TRUE
			COOLDOWN_START(P, bark_previewing, (5 SECONDS))
			var/atom/movable/barkbox = new(get_turf(P.parent.mob))
			barkbox.set_bark(P.bark_id)
			var/total_delay = 0
			for(var/i in 1 to (round((32 / P.bark_speed)) + 1))
				addtimer(CALLBACK(barkbox, TYPE_PROC_REF(/atom/movable, bark), list(P.parent.mob), 7, 70, BARK_DO_VARY(P.bark_pitch, P.bark_variance)), total_delay)
				total_delay += rand(DS2TICKS(P.bark_speed/4), DS2TICKS(P.bark_speed/4) + DS2TICKS(P.bark_speed/4)) TICKS
			QDEL_IN(barkbox, total_delay)
			return TRUE

		// ── Flavor / OOC text ────────────────────────────────────────
		if("set_flavortext")
			var/new_flavortext = tgui_input_text(user, "Input your character description:", "Flavortext", P.flavortext, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_flavortext))
				return TRUE
			if(new_flavortext == "")
				P.flavortext = null
			else
				P.flavortext = new_flavortext
				P.flavortext_cached = parsemarkdown_basic(html_encode(P.flavortext), hyperlink = TRUE)
				to_chat(user, span_notice("Successfully updated flavortext"))
				log_game("[user] has set their flavortext'.")
			return TRUE

		if("set_nsfwflavortext")
			var/new_nsfwflavortext = tgui_input_text(user, "Input your character description:", "NSFW Flavortext", P.nsfwflavortext, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_nsfwflavortext))
				return TRUE
			if(new_nsfwflavortext == "")
				P.nsfwflavortext = null
			else
				P.nsfwflavortext = new_nsfwflavortext
				P.nsfwflavortext_cached = parsemarkdown_basic(html_encode(P.nsfwflavortext), hyperlink = TRUE)
				to_chat(user, span_notice("Successfully updated NSFW flavortext"))
				log_game("[user] has set their NSFW flavortext'.")
			return TRUE

		if("set_ooc_notes")
			var/new_ooc_notes = tgui_input_text(user, "Input your OOC preferences:", "OOC notes", P.ooc_notes, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_ooc_notes))
				return TRUE
			if(new_ooc_notes == "")
				P.ooc_notes = null
			else
				P.ooc_notes = new_ooc_notes
				P.ooc_notes_cached = parsemarkdown_basic(html_encode(P.ooc_notes), hyperlink = TRUE)
			return TRUE

		if("set_rumour")
			var/new_rumour = tgui_input_text(user, "Input rumours about your character: (400 Character Limit)", "Rumours", P.rumour, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_rumour))
				return TRUE
			if(new_rumour == "")
				P.rumour = null
				return TRUE
			if(length(new_rumour) > 400)
				to_chat(user, span_warning("Too long! 400 character limit."))
				return TRUE
			P.rumour = new_rumour
			log_game("[user] has set their rumour'.")
			return TRUE

		if("set_gossip")
			var/new_gossip = tgui_input_text(user, "Input noble gossip about your character: (400 Character Limit)", "Noble Gossip", P.noble_gossip, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_gossip))
				return TRUE
			if(new_gossip == "")
				P.noble_gossip = null
				return TRUE
			if(length(new_gossip) > 400)
				to_chat(user, span_warning("Too long! 400 character limit."))
				return TRUE
			P.noble_gossip = new_gossip
			return TRUE

		if("preview_rumour")
			var/msg = ""
			if(P.rumour && length(P.rumour))
				var/rumour_display = html_encode(P.rumour)
				rumour_display = parsemarkdown_basic(rumour_display, hyperlink = TRUE)
				msg += "<b>You recall what you heard around Town about [P.real_name]...</b><br>[rumour_display]"
			if(length(P.noble_gossip))
				var/gossip_display = html_encode(P.noble_gossip)
				gossip_display = parsemarkdown_basic(gossip_display, hyperlink = TRUE)
				msg += "<br><b>Among Noble circles, you've heard...</b><br>[gossip_display]"
			if(msg)
				to_chat(user, msg)
			else
				to_chat(user, span_notice("No rumours or gossip set."))
			return TRUE

		if("set_erpprefs")
			var/new_erpprefs = tgui_input_text(user, "Input your preferences:", "ERP Preferences", P.erpprefs, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_erpprefs))
				return TRUE
			if(new_erpprefs == "")
				P.erpprefs = null
			else
				P.erpprefs = new_erpprefs
				P.erpprefs_cached = parsemarkdown_basic(html_encode(P.erpprefs), hyperlink = TRUE)
			return TRUE

		if("set_song_url")
			var/static/list/valid_extensions = list(".mp3", ".ogg", ".wav")
			var/new_extra_link = tgui_input_text(user, "Input the accessory link (https, hosts: discord, catbox):", "Song URL", P.ooc_extra, encode = FALSE)
			if(isnull(new_extra_link))
				return TRUE
			if(new_extra_link == "")
				P.ooc_extra = null
				return TRUE
			if(!valid_headshot_link(user, new_extra_link, FALSE, valid_extensions))
				return TRUE
			P.ooc_extra = new_extra_link
			log_game("[user] has set their Song URL to '[P.ooc_extra]'.")
			return TRUE

		if("set_song_title")
			var/new_title = tgui_input_text(user, "Input your song's title:", "Song title", P.song_title, encode = FALSE)
			if(isnull(new_title))
				return TRUE
			P.song_title = new_title
			return TRUE

		if("set_song_artist")
			var/new_artist = tgui_input_text(user, "Input your song's artist:", "Song Artist", P.song_artist, encode = FALSE)
			if(isnull(new_artist))
				return TRUE
			P.song_artist = new_artist
			return TRUE

		if("set_headshot")
			var/new_headshot_link = tgui_input_text(user, "Input the headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Headshot", P.headshot_link, encode = FALSE)
			if(isnull(new_headshot_link))
				return TRUE
			if(new_headshot_link == "")
				P.headshot_link = null
				return TRUE
			if(!valid_headshot_link(user, new_headshot_link))
				P.headshot_link = null
				return TRUE
			P.headshot_link = new_headshot_link
			log_game("[user] has set their Headshot image to '[P.headshot_link]'.")
			return TRUE

		if("set_examine_theme")
			var/list/options = build_examine_theme_options()
			if(params["value"] == "None (Use Viewer's)")
				P.examine_theme = null
				return TRUE
			var/theme_key = options[params["value"]]
			if(!theme_key)
				return TRUE
			P.examine_theme = theme_key
			return TRUE

		if("toggle_have_manor")
			P.have_manor = !P.have_manor
			return TRUE

		if("set_manor_name")
			var/new_name = reject_bad_name(params["value"])
			if(new_name)
				P.manor_name = new_name
			return TRUE

		if("set_manor_type")
			var/static/list/manor_type_paths = list(
				"Manor" = "manor",
				"Hunter Mansion" = "hunter_mansion",
				"Village" = "village",
				"Fisher Hamlet" = "fisher_hamlet",
				"Mining Settlement" = "mining_settlement",
			)
			var/type_path = manor_type_paths[params["value"]]
			if(!type_path)
				return TRUE
			P.manor_type = type_path
			return TRUE

		if("preview_examine")
			var/datum/examine_panel/preview_examine_panel = new(user)
			preview_examine_panel.pref = P
			preview_examine_panel.holder = user
			preview_examine_panel.viewing = user
			preview_examine_panel.ui_interact(user)
			return TRUE

		if("add_gallery_image")
			if(P.img_gallery.len >= 3)
				to_chat(user, "You already have three images in your gallery!")
				return TRUE
			var/new_galleryimg = tgui_input_text(user, "Input the image link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Gallery Image", encode = FALSE)
			if(isnull(new_galleryimg) || new_galleryimg == "")
				return TRUE
			if(!valid_headshot_link(user, new_galleryimg))
				to_chat(user, span_notice("Invalid image link. Make sure it's a direct link from a valid host (gyazo, discord, lensdump, imgbox, catbox)."))
				return TRUE
			P.img_gallery += new_galleryimg
			to_chat(user, span_notice("Successfully added image to gallery."))
			log_game("[user] has added an image to their gallery: '[new_galleryimg]'.")
			return TRUE

		if("clear_gallery")
			if(!P.img_gallery.len)
				to_chat(user, "You don't have any images in your gallery to clear!")
				return TRUE
			var/dachoice = tgui_alert(user, "Do you really want to clear your image gallery?", "Clear Gallery", list("Yae", "Nae"))
			if(dachoice != "Yae")
				return TRUE
			P.img_gallery = list()
			to_chat(user, span_notice("Successfully cleared image gallery."))
			log_game("[user] has cleared their image gallery.")
			return TRUE

		if("add_nsfw_gallery_image")
			if(P.nsfw_img_gallery.len >= 3)
				to_chat(user, "You already have three images in your NSFW gallery!")
				return TRUE
			var/new_galleryimg_nsfw = tgui_input_text(user, "Input the image link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "NSFW Gallery Image", encode = FALSE)
			if(isnull(new_galleryimg_nsfw) || new_galleryimg_nsfw == "")
				return TRUE
			if(!valid_headshot_link(user, new_galleryimg_nsfw))
				to_chat(user, span_notice("Invalid image link. Make sure it's a direct link from a valid host (gyazo, discord, lensdump, imgbox, catbox)."))
				return TRUE
			P.nsfw_img_gallery += new_galleryimg_nsfw
			to_chat(user, span_notice("Successfully added image to NSFW gallery."))
			log_game("[user] has added an image to their NSFW gallery: '[new_galleryimg_nsfw]'.")
			return TRUE

		if("clear_nsfw_gallery")
			if(!P.nsfw_img_gallery.len)
				to_chat(user, "You don't have any images in your NSFW gallery to clear!")
				return TRUE
			var/dachoice_nsfw = tgui_alert(user, "Do you really want to clear your NSFW image gallery?", "Clear NSFW Gallery", list("Yae", "Nae"))
			if(dachoice_nsfw != "Yae")
				return TRUE
			P.nsfw_img_gallery = list()
			to_chat(user, span_notice("Successfully cleared NSFW image gallery."))
			log_game("[user] has cleared their NSFW image gallery.")
			return TRUE

		// ── Subsystem popups (reused as-is) ───────────────────────────
		if("open_loadout")
			var/datum/loadout_menu/LM = new(user.client)
			LM.ui_interact(user)
			return TRUE

		if("open_culinary")
			P.show_culinary_ui(user)
			return TRUE

		if("save_sheet")
			P.save_preferences()
			P.save_character()
			to_chat(user, span_notice("CHARACTER SAVED."))
			return TRUE

		if("open_customizers")
			P.dreamvalley_open_customizers_ui(user)
			mark_preview_dirty()
			return TRUE

		if("open_origin_map")
			P.dreamvalley_open_origin_map_ui(user)
			return TRUE

		if("open_markings")
			P.dreamvalley_open_markings_ui(user)
			mark_preview_dirty()
			return TRUE

		if("open_descriptors")
			P.dreamvalley_open_descriptors_ui(user)
			mark_preview_dirty()
			return TRUE

		if("open_familiar_prefs")
			P.familiar_prefs.fam_show_ui()
			return TRUE

		// ── Hub (meta links formerly on the classic Character tab) ───
		if("open_tat")
			P.dreamvalley_open_tat(user)
			return TRUE

		if("change_slot")
			var/list/choices = list()
			if(P.path)
				var/savefile/S = new /savefile(P.path)
				if(S)
					for(var/i = 1, i <= P.max_save_slots, i++)
						var/name
						var/suffix
						S.cd = "/character[i]"
						S["real_name"] >> name
						S["topjob"] >> suffix
						if(!name)
							name = "Slot[i]"
						if(suffix)
							name += " — [suffix]"
						choices[name] = i
			var/choice = tgui_input_list(user, "CHOOSE A HERO", "ROGUETOWN", choices)
			if(!choice)
				return TRUE
			choice = choices[choice]
			for(var/datum/tgui/open_ui in user.tgui_open_uis)
				if(istype(open_ui.src_object, /datum/loadout_menu))
					open_ui.close()
			if(!P.load_character(choice))
				P.random_character(null, FALSE, FALSE)
				P.save_character()
			return TRUE

		if("open_villain_selection")
			P.SetAntag(user)
			return TRUE

		if("open_changelog")
			user.client.changelog()
			return TRUE

		if("open_lore_primer")
			P.LorePopup(user)
			return TRUE

		if("open_playerquality")
			check_pq_menu(user.ckey)
			return TRUE

		if("open_triumphs")
			user.show_triumphs_list()
			return TRUE

		if("open_triumph_buy_menu")
			SStriumphs.startup_triumphs_menu(user.client)
			return TRUE

		if("open_agevet")
			if(!user.check_agevet())
				to_chat(user, span_info("- You are a whitelisted player with full access to the server's features. If you'd also like to show others that you've been <b>AGE-VERIFIED</b> with a censored ID, you can open a ticket in Azure Peak's <b>#vet-here</b> channel. If you are already verified on Discord, but not in-game, ahelp. Note that this is a purely optional process, and - besides awarding a special header for your flavortext - doesn't affect you in any other way."))
			else
				to_chat(user, span_love("- You have been successfully <b>AGE-VERIFIED!</b>"))
			return TRUE

	return FALSE
