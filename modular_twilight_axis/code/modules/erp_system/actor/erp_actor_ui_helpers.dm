/datum/erp_actor_ui_helpers
	var/static/list/zone_translations = list(
		BODY_ZONE_HEAD              = "head",
		BODY_ZONE_CHEST             = "torso",
		BODY_ZONE_R_ARM             = "right arm",
		BODY_ZONE_L_ARM             = "left arm",
		BODY_ZONE_R_LEG             = "right leg",
		BODY_ZONE_L_LEG             = "left leg",
		BODY_ZONE_PRECISE_R_INHAND  = "right palm",
		BODY_ZONE_PRECISE_L_INHAND  = "left palm",
		BODY_ZONE_PRECISE_R_FOOT    = "right foot",
		BODY_ZONE_PRECISE_L_FOOT    = "left foot",
		BODY_ZONE_PRECISE_SKULL     = "forehead",
		BODY_ZONE_PRECISE_EARS      = "ears",
		BODY_ZONE_PRECISE_R_EYE     = "right eye",
		BODY_ZONE_PRECISE_L_EYE     = "left eye",
		BODY_ZONE_PRECISE_NOSE      = "nose",
		BODY_ZONE_PRECISE_MOUTH     = "mouth",
		BODY_ZONE_PRECISE_NECK      = "neck",
		BODY_ZONE_PRECISE_STOMACH   = "stomach",
		BODY_ZONE_PRECISE_GROIN     = "groin",
	)

/// Builds organ type filter entries for UI based on current action slots and free slots.
/datum/erp_actor_ui_helpers/proc/get_organ_type_filters_ui(datum/erp_actor/A)
	var/list/out = list()

	if(A.organs_dirty)
		A.rebuild_organs()

	for(var/type in A.action_slots)
		var/list/slots = A.action_slots[type]
		if(!islist(slots) || !slots.len)
			continue

		var/total = slots.len
		var/free = 0
		var/list/seen = list()

		for(var/datum/erp_sex_organ/O in slots)
			if(seen[O])
				continue
			seen[O] = TRUE
			free += O.get_free_slots()

		free = clamp(free, 0, total)

		out += list(list(
			"type" = "[type]",
			"name" = "[type]",
			"total" = total,
			"free" = free,
			"busy" = (free <= 0)
		))

	return out

/// Returns currently selected zone from the physical mob (or null if not a mob).
/datum/erp_actor_ui_helpers/proc/get_selected_zone(datum/erp_actor/A)
	var/atom/P = A.physical
	if(!P || !ismob(P))
		return null

	var/mob/M = P
	return M.zone_selected

/// Returns translated zone text for UI/messages.
/datum/erp_actor_ui_helpers/proc/get_zone_text(datum/erp_actor/A, zone)
	return zone_translations[zone] || "body"

/// Returns target-zone text for current selected zone, normalized for the target actor.
/datum/erp_actor_ui_helpers/proc/get_target_zone_text_for(datum/erp_actor/A, datum/erp_actor/target_actor)
	var/zone = get_selected_zone(A)
	if(!zone)
		return "body"

	zone = target_actor?.normalize_target_zone(zone, A) || zone
	if(target_actor)
		return get_zone_text(target_actor, zone)

	return get_zone_text(A, zone)
