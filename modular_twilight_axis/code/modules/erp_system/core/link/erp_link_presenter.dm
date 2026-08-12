/datum/erp_link_presenter

/// Human-readable force text for templates/UI.
/datum/erp_link_presenter/proc/get_force_text(force)
	switch(force)
		if(SEX_FORCE_LOW)     return pick(list("gently", "tenderly", "softly", "delicately", "carefully"))
		if(SEX_FORCE_MID)     return pick(list("firmly", "energetically", "passionately", "confidently", "eagerly"))
		if(SEX_FORCE_HIGH)    return pick(list("roughly", "carelessly", "hard", "fierily", "savagely"))
		if(SEX_FORCE_EXTREME) return pick(list("brutally", "furiously", "relentlessly", "savagely", "mercilessly"))
	return "confidently"

/// Human-readable speed text for templates/UI.
/datum/erp_link_presenter/proc/get_speed_text(speed)
	switch(speed)
		if(SEX_SPEED_LOW)     return pick(list("slowly", "unhurriedly", "gently", "languidly", "steadily"))
		if(SEX_SPEED_MID)     return pick(list("rhythmically", "confidently", "smoothly", "insistently", "calmly"))
		if(SEX_SPEED_HIGH)    return pick(list("fast", "frequently", "hastily", "sharply", "intensely"))
		if(SEX_SPEED_EXTREME) return pick(list("aggressively", "swiftly", "turbulently", "furiously", "recklessly"))

	return "rhythmically"

/// Zone text routed via actor API (single source of truth for zone normalization).
/datum/erp_link_presenter/proc/get_target_zone_text(datum/erp_sex_link/L)
	return L?.actor_active?.get_target_zone_text_for(L?.actor_passive) || "body"

/// Minimal UI snapshot (kept fields match existing UI expectations).
/datum/erp_link_presenter/proc/get_ui_state(datum/erp_sex_link/L)
	if(!L)
		return list()

	return list(
		"active" = (L.state == LINK_STATE_ACTIVE),
		"force" = L.force,
		"speed" = L.speed,
		"action" = L.action?.name,
		"actor_active" = L.actor_active?.get_display_name(),
		"actor_passive" = L.actor_passive?.get_display_name()
	)

/// Message color based on force/speed (same algorithm as before).
/datum/erp_link_presenter/proc/get_message_color(datum/erp_sex_link/L)
	if(!L)
		return rgb(234, 200, 222)

	var/low_r = 234
	var/low_g = 200
	var/low_b = 222

	var/ext_r = 209
	var/ext_g = 70
	var/ext_b = 245

	var/fn = _norm_1_4(L.force)
	var/sn = _norm_1_4(L.speed)
	var/t = clamp((fn + sn) * 0.5, 0, 1)

	var/boost = 1.15
	t *= boost

	var/r = round(low_r + (ext_r - low_r) * t)
	var/g = round(low_g + (ext_g - low_g) * t)
	var/b = round(low_b + (ext_b - low_b) * t)

	r = clamp(r, 0, 255)
	g = clamp(g, 0, 255)
	b = clamp(b, 0, 255)

	return rgb(r, g, b)

/// Normalizes enum 1..4 to 0..1.
/datum/erp_link_presenter/proc/_norm_1_4(v)
	return clamp(((v || 1) - 1) / 3, 0, 1)

/// Wraps message text in a colored span (controller uses this).
/datum/erp_link_presenter/proc/spanify_sex(datum/erp_sex_link/L, text)
	if(!text)
		return null
	var/c = get_message_color(L)
	return "<span style='color:[c]; font-weight:500; font-size:75%; text-shadow: 0 1px 0 rgba(0,0,0,0.35);'>[text]</span>"
