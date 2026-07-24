/**
 * Small, engine-neutral entry points for the host bridge.
 *
 * Keeping the boundary JSON-safe lets the same DM code work through OpenDream
 * today and a more direct native bridge later.
 */

/proc/dreamvalley_configure_campaign(campaign_id)
	return GLOB.dreamvalley_campaign.configure(campaign_id)

/proc/dreamvalley_configure_clock(time_scale, dawn_start, day_start, dusk_start, night_start)
	return GLOB.dreamvalley_campaign.configure_clock(time_scale, dawn_start, day_start, dusk_start, night_start)

/proc/dreamvalley_configure_rules_json(rules_json)
	var/list/rules = json_decode(rules_json)
	return GLOB.dreamvalley_campaign.configure_rules(rules)

/proc/dreamvalley_restore_clock_json(state_json)
	var/list/state = json_decode(state_json)
	return GLOB.dreamvalley_campaign.restore_clock(state)

/proc/dreamvalley_campaign_status_json()
	return json_encode(GLOB.dreamvalley_campaign.status())

/proc/dreamvalley_campaign_clock_json()
	return json_encode(GLOB.dreamvalley_campaign.clock_status())

/proc/dreamvalley_drain_turf_deltas_json()
	return json_encode(GLOB.dreamvalley_campaign.drain_turf_deltas())
