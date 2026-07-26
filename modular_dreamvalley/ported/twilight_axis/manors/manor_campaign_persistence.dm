// Campaign-layer persistence for the ported Manors system (see manor.dm).
// The source system is round-scoped (a manor is rebuilt from scratch every
// round); this fork's characters persist indefinitely across Far Travel and
// parking, so manor ownership and workstation assignments are captured and
// restored alongside the rest of the character state via character_graph.dm's
// capture_character_mind/restore_character_mind hooks.

/datum/dreamvalley_campaign_manager/proc/capture_character_manor(datum/mind/mind)
	var/datum/manor/manor = mind?.owned_manor
	if(!manor)
		return null

	var/list/workstation_states = list()
	for(var/datum/workstation/ws as anything in manor.workstations)
		workstation_states += list(list(
			"type" = "[ws.type]",
			"workers_employed" = ws.workers_employed,
			"workstation_size" = ws.workstation_size,
			"production_modifier" = ws.production_modifier,
		))

	return list(
		"manor_name" = manor.manor_name,
		"manor_size" = manor.manor_size,
		"manor_type" = manor.manor_type,
		"virtue_origin_type" = manor.virtue_origin ? "[manor.virtue_origin.type]" : null,
		"min_workers" = manor.min_workers,
		"total_workers" = manor.total_workers,
		"workers_limit" = manor.workers_limit,
		"patron_type" = "[manor.patron]",
		"last_cycle_productivity" = manor.last_cycle_productivity,
		"workstations" = workstation_states,
	)

/datum/dreamvalley_campaign_manager/proc/restore_character_manor(datum/mind/mind, list/state)
	if(!mind)
		return
	if(!islist(state))
		mind.owned_manor = null
		return

	var/datum/manor/manor = new /datum/manor()
	manor.manor_name = state["manor_name"] || manor.manor_name
	manor.manor_size = state["manor_size"] || manor.manor_size
	manor.manor_type = state["manor_type"] || manor.manor_type
	var/origin_path = text2path(state["virtue_origin_type"])
	if(ispath(origin_path, /datum/virtue/origin))
		manor.virtue_origin = new origin_path()
	manor.min_workers = isnum(state["min_workers"]) ? state["min_workers"] : manor.min_workers
	manor.total_workers = isnum(state["total_workers"]) ? state["total_workers"] : manor.total_workers
	manor.workers_limit = isnum(state["workers_limit"]) ? state["workers_limit"] : manor.workers_limit
	var/patron_path = text2path(state["patron_type"])
	if(ispath(patron_path, /datum/patron))
		manor.patron = patron_path
	manor.last_cycle_productivity = isnum(state["last_cycle_productivity"]) ? state["last_cycle_productivity"] : 0

	manor.workstations = list()
	for(var/list/ws_state as anything in state["workstations"])
		var/ws_path = text2path(ws_state["type"])
		if(!ispath(ws_path, /datum/workstation))
			continue
		var/datum/workstation/ws = new ws_path()
		ws.workers_employed = isnum(ws_state["workers_employed"]) ? ws_state["workers_employed"] : 0
		if(isnum(ws_state["workstation_size"]))
			ws.workstation_size = ws_state["workstation_size"]
		if(isnum(ws_state["production_modifier"]))
			ws.production_modifier = ws_state["production_modifier"]
		manor.workstations += ws

	mind.owned_manor = manor
