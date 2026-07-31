/**
 * Diagnostic for tracking down sustained time-dilation MC warnings pointing at
 * the lighting subsystem (SSlighting.fire / lighting_object.update). Reports
 * how many /atom/movable/lighting_object instances currently exist (one per
 * dynamically-lit turf, see create_all_lighting_objects()) and how many are
 * queued for an update right now, broken down by z-level, so an admin can see
 * whether load is spread evenly or concentrated on one map/z-level without
 * reading a raw profiler dump by hand. Light sources themselves aren't
 * globally tracked (they're only reachable via whichever atom owns them), so
 * this counts the lighting_objects the subsystem actually iterates instead.
 */
/client/proc/cmd_admin_lighting_diagnostic()
	set category = "Debug"
	set name = "Lighting Diagnostic"
	set desc = "Report lighting object counts and current queue sizes, broken down by z-level, to help diagnose sustained lighting-related time dilation."

	if(!check_rights(R_DEBUG))
		return

	var/list/objects_by_z = list()
	var/total_objects = 0
	for(var/atom/movable/lighting_object/O in world)
		total_objects++
		var/z = O.z || 0
		objects_by_z[z] = (objects_by_z[z] || 0) + 1

	var/list/queued_by_z = list()
	for(var/atom/movable/lighting_object/O in SSlighting.objects_queue)
		var/z = O.z || 0
		queued_by_z[z] = (queued_by_z[z] || 0) + 1

	var/list/lines = list(
		"<b>Lighting Diagnostic</b>",
		"Total lighting objects: [total_objects]",
		"Lighting queues right now - sources: [length(SSlighting.sources_queue)], corners: [length(SSlighting.corners_queue)], objects: [length(SSlighting.objects_queue)]",
		"",
		"<b>By z-level:</b>",
	)
	var/list/all_z = objects_by_z.Copy()
	for(var/z in queued_by_z)
		if(!(z in all_z))
			all_z[z] = 0
	var/list/sorted_z = sortList(all_z)
	for(var/z in sorted_z)
		lines += "z=[z]: [objects_by_z[z] || 0] lighting objects, [queued_by_z[z] || 0] currently queued for update"

	to_chat(usr, span_notice(lines.Join("<br>")))
	log_admin("[key_name(usr)] ran Lighting Diagnostic ([total_objects] lighting objects, [length(SSlighting.objects_queue)] queued).")
