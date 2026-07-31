/datum/species
	var/amtfail = 0

/datum/species/proc/get_accent_list(mob/living/carbon/human/H, type)
	switch(H.char_accent)
		if("No accent")
			return
		if("Dwarf accent")
			return strings("dwarfcleaner_replacement.json", type)
		if("Dwarf Gibberish accent")
			return strings("dwarf_replacement.json", type)
		if("Dark Elf accent")
			return strings("french_replacement.json", type)
		if("Elf accent")
			return strings("russian_replacement.json", type)
		if("Grenzelhoft accent")
			return strings("german_replacement.json", type)
		if("Hammerhold accent")
			return strings("Anglish.json", type)
		if("Assimar accent")
			return strings("proper_replacement.json", type)
		if("Lizard accent")
			return strings("brazillian_replacement.json", type)
		if("Tiefling accent")
			return strings("spanish_replacement.json", type)
		if("Half Orc accent")
			return strings("middlespeak.json", type)
		if("Urban Orc accent")
			return strings("norf_replacement.json", type)
		if("Hissy accent")
			return strings("hissy_replacement.json", type)
		if("Inzectoid accent")
			return strings("inzectoid_replacement.json", type)
		if("Feline accent")
			return strings("feline_replacement.json", type)
		if("Slopes accent")
			return strings("welsh_replacement.json", type)

/datum/species/proc/get_accent(mob/living/carbon/human/H)
	return get_accent_list(H,"full")

/datum/species/proc/get_accent_any(mob/living/carbon/human/H) //determines if accent replaces in-word text
	return get_accent_list(H,"syllable")

/datum/species/proc/get_accent_start(mob/living/carbon/human/H)
	return get_accent_list(H,"start")

/datum/species/proc/get_accent_end(mob/living/carbon/human/H)
	return get_accent_list(H,"end")

/// Multi-word phrase replacements for the speaker's accent. None of our current accent
/// dictionaries define a "multiword" section, so this safely returns null instead of
/// crashing strings() on a missing key - treat_message_accent() no-ops on a null list.
/datum/species/proc/get_accent_multiword(mob/living/carbon/human/H)
	return get_accent_list_safe(H, "multiword")

/// Like get_accent_list(), but returns null instead of CRASH()ing when the accent's
/// json file has no entry for the requested type.
/datum/species/proc/get_accent_list_safe(mob/living/carbon/human/H, type)
	var/filename = get_accent_filename(H)
	if(!filename)
		return
	if(!fexists("strings/[filename]"))
		return
	var/list/cached = GLOB.string_cache?[filename]
	if(!cached)
		load_strings_file(filename)
		cached = GLOB.string_cache[filename]
	if(cached && (type in cached))
		return cached[type]

/// Returns the json filename backing the speaker's current accent, or null for "No accent"
/// or any accent we don't have data for. Kept in sync with the switch in get_accent_list().
/datum/species/proc/get_accent_filename(mob/living/carbon/human/H)
	switch(H.char_accent)
		if("Dwarf accent")
			return "dwarfcleaner_replacement.json"
		if("Dwarf Gibberish accent")
			return "dwarf_replacement.json"
		if("Dark Elf accent")
			return "french_replacement.json"
		if("Elf accent")
			return "russian_replacement.json"
		if("Grenzelhoft accent")
			return "german_replacement.json"
		if("Hammerhold accent")
			return "Anglish.json"
		if("Assimar accent")
			return "proper_replacement.json"
		if("Lizard accent")
			return "brazillian_replacement.json"
		if("Tiefling accent")
			return "spanish_replacement.json"
		if("Half Orc accent")
			return "middlespeak.json"
		if("Urban Orc accent")
			return "norf_replacement.json"
		if("Hissy accent")
			return "hissy_replacement.json"
		if("Inzectoid accent")
			return "inzectoid_replacement.json"
		if("Feline accent")
			return "feline_replacement.json"
		if("Slopes accent")
			return "welsh_replacement.json"

#define REGEX_FULLWORD 1
#define REGEX_STARTWORD 2
#define REGEX_ENDWORD 3
#define REGEX_ANY 4

/proc/treat_message_accent(message, list/accent_list, chosen_regex)
	if(!message)
		return
	if(!accent_list)
		return message
	if(message[1] == "*")
		return message
	message = "[message]"
	for(var/key in accent_list)
		var/value = accent_list[key]
		if(islist(value))
			value = pick(value)

		switch(chosen_regex)
			if(REGEX_FULLWORD)
				// Full word regex (full world replacements)
				message = replacetextEx(message, regex("\\b[uppertext(key)]\\b|\\A[uppertext(key)]\\b|\\b[uppertext(key)]\\Z|\\A[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]\\b|\\A[capitalize(key)]\\b|\\b[capitalize(key)]\\Z|\\A[capitalize(key)]\\Z", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]\\b|\\A[key]\\b|\\b[key]\\Z|\\A[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_STARTWORD)
				// Start word regex (Some words that get different endings)
				message = replacetextEx(message, regex("\\b[uppertext(key)]|\\A[uppertext(key)]", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("\\b[capitalize(key)]|\\A[capitalize(key)]", "(\\w+)/g"), capitalize(value))
				message = replacetextEx(message, regex("\\b[key]|\\A[key]", "(\\w+)/g"), value)
			if(REGEX_ENDWORD)
				// End of word regex (Replaces last letters of words)
				message = replacetextEx(message, regex("[uppertext(key)]\\b|[uppertext(key)]\\Z", "(\\w+)/g"), uppertext(value))
				message = replacetextEx(message, regex("[key]\\b|[key]\\Z", "(\\w+)/g"), value)
			if(REGEX_ANY)
				// Any regex (syllables)
				// Careful about use of syllables as they will continually reapply to themselves, potentially canceling each other out
				message = replacetextEx(message, uppertext(key), uppertext(value))
				message = replacetextEx(message, key, value)

	return message

/// Applies the shared "accent_universal.json" word list, then the accent's own full-word
/// overlay on top (the accent's own replacement wins if both define the same word).
/proc/treat_message_accent_fullword(message, list/universal_list, list/accent_list)
	message = treat_message_accent(message, universal_list, REGEX_FULLWORD)
	message = treat_message_accent(message, accent_list, REGEX_FULLWORD)
	return message

/*
	Lets a player speak a name or foreign word exactly as they typed it by putting [brackets]
	around it. For each word or phrase in brackets, we save the original text and leave a
	numbered marker, like "<#1#>", where it was. The accent code doesn't touch the markers
	because they have no letters in them, so afterward accent_escape_restore puts the saved
	text back in place of each marker.
*/
/proc/accent_escape_extract(message, list/escapes)
	// A message starting with '*' is an emote, so skip
	if(!message || message[1] == "*")
		return message
	// This finds one [insert whatever here] at a time. Static so it is built once instead of on every call.
	var/static/regex/escape_regex = regex(@"\[([^\]]*)\]?")

	// Search from the start each time, since we rebuild the message whenever we pull one out. Each pass removes an opening bracket, so this always finishes.
	while(escape_regex.Find(message, 1))
		// Save the text that was inside the brackets.
		escapes += (escape_regex.group[1] || "")
		// Swap the [word] out for a numbered marker. The number is its place in the escapes list.
		message = copytext(message, 1, escape_regex.index) + "<#[escapes.len]#>" + copytext(message, escape_regex.index + length(escape_regex.match))
	return message

/*
	The other half of accent_escape_extract: puts each saved word back in place of its
	"<#N#>" marker, so the brackets are gone and the original words come back unchanged. Runs
	after the accent code so nothing changes the text we bring back.
*/
/proc/accent_escape_restore(message, list/escapes)
	if(!message)
		return message
	// Put each saved word back where its marker is. A player shouldn't be able to fake a marker
	for(var/i in 1 to escapes.len)
		message = replacetext(message, "<#[i]#>", escapes[i])
	return message

/*
	Takes the speaker's five accent word lists and applies each kind of replacement in turn.
	autopunct and do_trim are on for speech, while the emote-quote path turns them off so the
	quoted words are left exactly as typed (only the accent replacement itself is applied).
*/
/proc/apply_accent_pipeline(message, list/multiword, list/fullword, list/startword, list/endword, list/syllable, autopunct = TRUE, do_trim = TRUE)
	// Only pull out [] if the message actually has one, so we skip making the list when there is nothing to escape.
	var/list/accent_escapes
	if(message && findtext(message, "\["))
		accent_escapes = list()
		message = accent_escape_extract(message, accent_escapes)
	// Replace whole words that are made up of more than one word.
	message = treat_message_accent(message, multiword, REGEX_FULLWORD)
	// One pass over each word, applying the shared universal list and this accent's whole-word list at once.
	message = treat_message_accent_fullword(message, strings("accent_universal.json", "universal"), fullword)
	// Replace the start of words.
	message = treat_message_accent(message, startword, REGEX_STARTWORD)
	// Replace the end of words.
	message = treat_message_accent(message, endword, REGEX_ENDWORD)
	// Replace letters or syllables anywhere inside words.
	message = treat_message_accent(message, syllable, REGEX_ANY)

	if(autopunct)
		message = autopunct_bare(message)
	if(do_trim)
		message = trim(message)

	// Put the escaped words back last so they stay exactly as typed
	if(accent_escapes)
		message = accent_escape_restore(message, accent_escapes)
	return message

/*
	The emote version of the say escape brackets, working the other way around: it applies the
	speaker's accent ONLY to text inside "quotes" in a me/subtle emote and leaves the rest of
	the emote alone.
*/
/proc/accent_emote_quotes(message, mob/living/carbon/human/H)
	// Stop early for non-humans or messages with no quotes to handle.
	if(!message || !ishuman(H) || !H.dna?.species)
		return message
	if(!findtext(message, "\"") && !findtext(message, "&#34;") && !findtext(message, "&quot;"))
		return message
	if(!H.char_accent || H.char_accent == "No accent")
		return message

	// Look up the speaker's five accent word lists once.
	var/list/multiword = H.dna.species.get_accent_multiword(H)
	var/list/fullword = H.dna.species.get_accent(H)
	var/list/startword = H.dna.species.get_accent_start(H)
	var/list/endword = H.dna.species.get_accent_end(H)
	var/list/syllable = H.dna.species.get_accent_any(H)

	// Built once. Matches an opening quote in any of its three forms
	var/static/regex/quote_regex = regex(@{"(&#34;|&quot;|")([\S\s\n]*?)(&#34;|&quot;|")"})
	var/search_pos = 1

	while(quote_regex.Find(message, search_pos))
		var/match_at = quote_regex.index
		var/match_len = length(quote_regex.match)
		var/open_quote = quote_regex.group[1]
		var/inner_text = quote_regex.group[2]
		var/close_quote = quote_regex.group[3]
		// Accent only the text inside the quotes.
		var/accented = apply_accent_pipeline(inner_text, multiword, fullword, startword, endword, syllable, autopunct = FALSE, do_trim = FALSE)
		// Keep the same quote marks that were matched, whichever form they arrived in.
		var/rebuilt = "[open_quote][accented][close_quote]"
		// Put the accented text (with its quotes) back into the message.
		message = copytext(message, 1, match_at) + rebuilt + copytext(message, match_at + match_len)

		// Move past what we just wrote so we don't scan it again.
		search_pos = match_at + length(rebuilt)
	return message

/datum/species/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/H = source
	if(istype(H) && H.char_accent && H.char_accent != "No accent")
		var/list/multiword = get_accent_multiword(H)
		var/list/fullword = get_accent(H)
		var/list/startword = get_accent_start(H)
		var/list/endword = get_accent_end(H)
		var/list/syllable = get_accent_any(H)
		speech_args[SPEECH_MESSAGE] = apply_accent_pipeline(message, multiword, fullword, startword, endword, syllable)
	else
		message = autopunct_bare(message)
		speech_args[SPEECH_MESSAGE] = trim(message)

#undef REGEX_FULLWORD
#undef REGEX_STARTWORD
#undef REGEX_ENDWORD
#undef REGEX_ANY
