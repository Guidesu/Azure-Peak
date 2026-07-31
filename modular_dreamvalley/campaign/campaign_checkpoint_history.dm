/**
 * Versioned checkpoint history for the DreamValley campaign save system.
 *
 * campaign_transport.dm's save.json is a single rolling file - every checkpoint
 * overwrites the last one, so there's no way to go back to an earlier point in
 * the campaign once something goes wrong (a bad map edit, a griefed build, a
 * corrupted parked character). This adds a history directory alongside it:
 * every emit_checkpoint() also copies the just-written save.json into
 * data/dreamvalley/history/ under its own generation number, plus two
 * retention policies:
 *
 * - Rolling: the most recent DREAMVALLEY_HISTORY_ROLLING_LIMIT autosave-driven
 *   copies are kept: older ones are pruned automatically as new ones are made.
 * - Named: an admin can explicitly snapshot the CURRENT checkpoint under a
 *   label (e.g. "before-map-edit"). Named snapshots are never auto-pruned -
 *   only an admin deleting them removes them.
 *
 * Restoring a checkpoint (rolling or named) does NOT hot-swap the live world -
 * it stages that checkpoint's file as the primary save.json and requires an
 * actual reboot to take effect, same as how Continue already requires
 * returning to the lobby rather than rewriting a live body in place. This
 * avoids trying to reconcile a totally different snapshot's turfs/mobs/state
 * against whatever is already running and connected right now.
 */
#define DREAMVALLEY_HISTORY_ROOT "data/dreamvalley/history"
#define DREAMVALLEY_HISTORY_ROLLING_LIMIT 20
/// Named snapshots use this prefix so they're never mistaken for (or pruned
/// alongside) plain rolling generation copies, which use a bare number.
#define DREAMVALLEY_NAMED_SNAPSHOT_PREFIX "named_"

/datum/dreamvalley_campaign_manager/proc/checkpoint_history_path(generation)
	return "[DREAMVALLEY_HISTORY_ROOT]/[generation].json"

/datum/dreamvalley_campaign_manager/proc/named_snapshot_path(safe_label)
	return "[DREAMVALLEY_HISTORY_ROOT]/[DREAMVALLEY_NAMED_SNAPSHOT_PREFIX][safe_label].json"

/// Called right after emit_checkpoint() successfully writes save.json - copies that same
/// content into the history directory under its generation number, then prunes the rolling
/// window. Takes the already-encoded JSON directly instead of re-reading the file, so this
/// can't race a concurrent write.
/datum/dreamvalley_campaign_manager/proc/archive_checkpoint_to_history(generation, encoded_save_data)
	if(!fexists(DREAMVALLEY_HISTORY_ROOT))
		rustg_file_write("", "[DREAMVALLEY_HISTORY_ROOT]/.keep")
	rustg_file_write(encoded_save_data, checkpoint_history_path(generation))
	prune_rolling_history()

/// Deletes the oldest plain (non-named) history entries beyond the rolling limit.
/datum/dreamvalley_campaign_manager/proc/prune_rolling_history()
	var/list/generations = list()
	for(var/entry in flist(DREAMVALLEY_HISTORY_ROOT))
		if(findtext(entry, DREAMVALLEY_NAMED_SNAPSHOT_PREFIX) == 1)
			continue
		var/without_ext = copytext(entry, 1, length(entry) - length(".json") + 1)
		var/generation_num = text2num(without_ext)
		if(isnum(generation_num))
			generations += generation_num

	if(length(generations) <= DREAMVALLEY_HISTORY_ROLLING_LIMIT)
		return

	generations = sort_list(generations, GLOBAL_PROC_REF(cmp_numeric_asc))
	var/excess = length(generations) - DREAMVALLEY_HISTORY_ROLLING_LIMIT
	for(var/i in 1 to excess)
		var/path = checkpoint_history_path(generations[i])
		if(fexists(path))
			fdel(path)

/// Sanitizes a user-supplied label down to something filesystem-safe (matches this repo's
/// existing ckey()-style normalization spirit): lowercase letters/digits/underscore only.
/datum/dreamvalley_campaign_manager/proc/sanitize_snapshot_label(label)
	if(!istext(label))
		return null
	var/static/regex/bad_chars = regex(@"[^a-z0-9_]", "g")
	var/cleaned = bad_chars.Replace(lowertext(trim(label)), "_")
	cleaned = copytext(cleaned, 1, 65) // cap length, filenames don't need to be huge
	if(!length(cleaned))
		return null
	return cleaned

/**
 * Takes a named, permanent snapshot of the CURRENT on-disk save.json (forcing a fresh
 * checkpoint first, so the snapshot always reflects "right now", not whatever the last
 * autosave happened to catch). Returns the sanitized label used, or null on failure
 * (invalid label, or a name collision with an existing named snapshot).
 */
/datum/dreamvalley_campaign_manager/proc/create_named_snapshot(label)
	var/safe_label = sanitize_snapshot_label(label)
	if(!safe_label)
		return null
	var/path = named_snapshot_path(safe_label)
	if(fexists(path))
		return null // don't silently clobber an existing named snapshot with the same label

	if(!emit_checkpoint())
		return null

	var/raw = rustg_file_read(DREAMVALLEY_SAVE_FILE)
	if(!istext(raw) || !length(raw))
		return null

	if(!fexists(DREAMVALLEY_HISTORY_ROOT))
		rustg_file_write("", "[DREAMVALLEY_HISTORY_ROOT]/.keep")
	rustg_file_write(raw, path)
	return safe_label

/// Lists every entry in the checkpoint history, newest first, for the admin UI.
/// Each row: generation (or null for named), label (or null for rolling), saved_at, is_named.
/datum/dreamvalley_campaign_manager/proc/list_checkpoint_history()
	var/list/rows = list()
	if(!fexists(DREAMVALLEY_HISTORY_ROOT))
		return rows

	for(var/entry in flist(DREAMVALLEY_HISTORY_ROOT))
		if(entry == ".keep")
			continue
		var/is_named = findtext(entry, DREAMVALLEY_NAMED_SNAPSHOT_PREFIX) == 1
		var/path = "[DREAMVALLEY_HISTORY_ROOT]/[entry]"
		var/raw = rustg_file_read(path)
		if(!istext(raw) || !length(raw))
			continue
		var/list/decoded
		try
			decoded = json_decode(raw)
		catch
			continue
		if(!islist(decoded))
			continue

		var/label = null
		if(is_named)
			var/without_prefix = copytext(entry, length(DREAMVALLEY_NAMED_SNAPSHOT_PREFIX) + 1)
			label = copytext(without_prefix, 1, length(without_prefix) - length(".json") + 1)

		rows += list(list(
			"file_key" = entry,
			"generation" = decoded["checkpoint_generation"],
			"saved_at" = decoded["saved_at"],
			"is_named" = is_named,
			"label" = label,
			"campaign_id" = decoded["campaign_id"],
		))

	sort_list(rows, GLOBAL_PROC_REF(cmp_checkpoint_rows_newest_first))
	return rows

/proc/cmp_checkpoint_rows_newest_first(list/a, list/b)
	return (b["saved_at"] || "") cmp (a["saved_at"] || "")

/**
 * Stages a chosen history entry as the primary save.json, WITHOUT touching the currently
 * running world - the restored state only takes effect on the next full reboot (same as
 * Continue never rewriting a live body in place). Returns TRUE on success.
 */
/datum/dreamvalley_campaign_manager/proc/restore_checkpoint_from_history(file_key)
	if(!istext(file_key) || findtext(file_key, "..") || findtext(file_key, "/"))
		return FALSE // reject anything that isn't a bare filename we generated ourselves
	var/path = "[DREAMVALLEY_HISTORY_ROOT]/[file_key]"
	if(!fexists(path))
		return FALSE

	var/raw = rustg_file_read(path)
	if(!istext(raw) || !length(raw))
		return FALSE

	// Validate it decodes before staging it as the live save - a corrupt history entry
	// should never be allowed to overwrite a currently-working save.json.
	var/list/decoded
	try
		decoded = json_decode(raw)
	catch
		return FALSE
	if(!islist(decoded) || decoded["schema_version"] != 1)
		return FALSE

	var/result = rustg_file_write(raw, DREAMVALLEY_SAVE_FILE)
	return isnull(result) || result == "" || result == "true"

/// Permanently deletes a named snapshot. Refuses to delete rolling (non-named) entries
/// through this proc - those are only ever cleaned up automatically by prune_rolling_history().
/datum/dreamvalley_campaign_manager/proc/delete_named_snapshot(file_key)
	if(!istext(file_key) || findtext(file_key, DREAMVALLEY_NAMED_SNAPSHOT_PREFIX) != 1)
		return FALSE
	if(findtext(file_key, "..") || findtext(file_key, "/"))
		return FALSE
	var/path = "[DREAMVALLEY_HISTORY_ROOT]/[file_key]"
	if(!fexists(path))
		return FALSE
	fdel(path)
	return TRUE

#undef DREAMVALLEY_HISTORY_ROOT
#undef DREAMVALLEY_HISTORY_ROLLING_LIMIT
#undef DREAMVALLEY_NAMED_SNAPSHOT_PREFIX
