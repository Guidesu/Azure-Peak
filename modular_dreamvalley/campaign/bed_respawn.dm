/**
 * Bed respawn system.
 *
 * When a player sleeps on a bed (rogue bed, bedroll, inn bed), the bed's
 * location is recorded as their respawn point. If they die, they are
 * offered the option to respawn at that bed instead of ghosting. The bed
 * location is persisted in the campaign save so it survives between
 * sessions.
 *
 * The system is per-character (keyed by ckey/preference_slot, same as
 * campaign character records), so different characters on different
 * preference slots each have their own bed respawn point.
 */

/datum/dreamvalley_campaign_manager
	/// Per-character bed respawn points, keyed by "ckey/preference_slot".
	/// Each entry is list("x" = x, "y" = y, "z" = z, "bed_type" = type_path, "area_name" = name)
	var/list/bed_respawns = list()

/// Record a bed as the respawn point for the sleeping character.
/// Called from COMSIG_SLEEPING_ON_BED.
/datum/dreamvalley_campaign_manager/proc/record_bed_respawn(mob/living/sleeper, obj/structure/bed/rogue/bed)
	if(!istype(sleeper) || !istype(bed) || !sleeper.client)
		return
	var/record_key = character_record_key(sleeper.client)
	if(!record_key)
		return
	var/turf/T = get_turf(bed)
	if(!T)
		return
	var/area/A = get_area(bed)
	bed_respawns[record_key] = list(
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"bed_type" = "[bed.type]",
		"area_name" = A ? A.name : "unknown",
	)
	// Trigger a checkpoint so the bed respawn persists to disk.
	request_durable_checkpoint()
	to_chat(sleeper, span_notice("This bed is now your respawn point. If you die, you will wake up here."))

/// Get the bed respawn point for a character.
/datum/dreamvalley_campaign_manager/proc/get_bed_respawn(client/player)
	var/record_key = character_record_key(player)
	if(!record_key)
		return null
	var/list/respawn = bed_respawns[record_key]
	if(!islist(respawn))
		return null
	var/turf/T = locate(respawn["x"], respawn["y"], respawn["z"])
	if(!T)
		return null
	return respawn

/// Clear the bed respawn point for a character.
/datum/dreamvalley_campaign_manager/proc/clear_bed_respawn(client/player)
	var/record_key = character_record_key(player)
	if(!record_key)
		return
	bed_respawns -= record_key
	request_durable_checkpoint()

/// Offer bed respawn to a dead player. Called from human death().
/datum/dreamvalley_campaign_manager/proc/offer_bed_respawn(mob/living/carbon/human/H)
	if(!istype(H) || !H.client || H.stat != DEAD)
		return
	if(!enabled)
		return
	var/list/respawn = get_bed_respawn(H.client)
	if(!islist(respawn))
		return
	var/turf/T = locate(respawn["x"], respawn["y"], respawn["z"])
	if(!T)
		to_chat(H, span_warning("Your bed respawn point is no longer accessible."))
		return
	// Offer respawn after a short delay so the death cutscene plays first.
	addtimer(CALLBACK(src, PROC_REF(prompt_bed_respawn), H, respawn), 60)

/// Prompt the player to respawn at their bed.
/datum/dreamvalley_campaign_manager/proc/prompt_bed_respawn(mob/living/carbon/human/H, list/respawn)
	if(!istype(H) || !H.client || H.stat != DEAD)
		return
	if(QDELETED(H))
		return
	var/area_name = respawn["area_name"] || "unknown"
	var/choice = alert(H, \
		"You feel the warmth of a familiar bed calling you back from the void... Respawn at your bed in [area_name]?", \
		"Bed Respawn", \
		"Respawn at Bed", \
		"Stay Dead")
	if(choice != "Respawn at Bed")
		return
	if(!H || QDELETED(H) || H.stat != DEAD || !H.client)
		return
	do_bed_respawn(H, respawn)

/// Perform the bed respawn: revive the body and move it to the bed.
/datum/dreamvalley_campaign_manager/proc/do_bed_respawn(mob/living/carbon/human/H, list/respawn)
	if(!istype(H) || H.stat != DEAD)
		return
	var/turf/T = locate(respawn["x"], respawn["y"], respawn["z"])
	if(!T)
		to_chat(H, span_warning("Your bed respawn point is no longer accessible."))
		return

	// Revive the body fully.
	H.revive(full_heal = TRUE, admin_revive = TRUE)

	// Move to the bed turf.
	H.forceMove(T)

	// Visual/audio effects.
	H.flash_act()
	playsound(T, 'sound/magic/antimagic.ogg', 50, TRUE)
	to_chat(H, span_nicegreen("You wake up in a familiar bed, gasping for breath. You feel as though you've been given a second chance."))
	H.visible_message(span_notice("[H] stirs and wakes, as if from a terrible dream."), span_notice("You stir and wake."))

	// Log it.
	log_game("[key_name(H)] respawned at bed ([respawn["x"]],[respawn["y"]],[respawn["z"]]) in [respawn["area_name"]].")
	message_admins("[key_name_admin(H)] respawned at their bed in [respawn["area_name"]].")

/// Capture bed respawns for the campaign snapshot.
/datum/dreamvalley_campaign_manager/proc/capture_bed_respawns()
	var/list/result = list()
	for(var/key in bed_respawns)
		var/list/respawn = bed_respawns[key]
		if(islist(respawn))
			result[key] = respawn.Copy()
	return result

/// Load bed respawns from a campaign snapshot.
/datum/dreamvalley_campaign_manager/proc/load_bed_respawns(list/data)
	bed_respawns = list()
	if(!islist(data))
		return
	for(var/key in data)
		var/list/respawn = data[key]
		if(islist(respawn))
			bed_respawns[key] = respawn.Copy()

/// Hook COMSIG_SLEEPING_ON_BED to record bed respawns.
/obj/structure/bed/rogue/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SLEEPING_ON_BED, PROC_REF(on_sleeping_on_bed))

/obj/structure/bed/rogue/proc/on_sleeping_on_bed(datum/source, mob/living/sleeper)
	SIGNAL_HANDLER
	if(!GLOB.dreamvalley_campaign?.enabled)
		return
	GLOB.dreamvalley_campaign.record_bed_respawn(sleeper, src)

/// Player verb to check/clear their bed respawn point.
/mob/verb/check_bed_respawn()
	set category = "OOC"
	set name = "Check Bed Respawn"
	set desc = "Check or clear your current bed respawn point."

	if(!GLOB.dreamvalley_campaign?.enabled)
		to_chat(src, span_warning("The DreamValley campaign system is not active."))
		return
	if(!client)
		return
	var/list/respawn = GLOB.dreamvalley_campaign.get_bed_respawn(client)
	if(!islist(respawn))
		to_chat(src, span_notice("You have no bed respawn point set. Sleep on a bed to set one."))
		return
	to_chat(src, span_notice("Your bed respawn point is in [respawn["area_name"]] at ([respawn["x"]],[respawn["y"]],[respawn["z"]])."))
	if(alert(src, "Clear your bed respawn point?", "Bed Respawn", "Clear", "Keep") == "Clear")
		GLOB.dreamvalley_campaign.clear_bed_respawn(client)
		to_chat(src, span_notice("Bed respawn point cleared."))
