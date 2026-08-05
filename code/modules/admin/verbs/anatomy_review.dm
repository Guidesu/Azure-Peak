/client/proc/review_anatomy_profiles()
	set category = "Debug"
	set name = "Review Anatomy Profiles"
	set desc = "Dump every anatomy profile, the mobs on it, and their real break thresholds."
	if(!check_rights(R_DEBUG))
		return

	var/list/users_by_profile = list()
	for(var/mob_type in typesof(/mob/living/simple_animal))
		var/mob/living/simple_animal/prototype = mob_type
		var/profile_type = initial(prototype.anatomy_type)
		if(!profile_type)
			continue
		if(!users_by_profile[profile_type])
			users_by_profile[profile_type] = list()
		users_by_profile[profile_type] += mob_type

	var/list/html = list("<h1>Anatomy Profiles</h1>")
	var/total_mobs = 0

	for(var/profile_type in GLOB.anatomy_profiles)
		var/datum/anatomy/profile = GLOB.anatomy_profiles[profile_type]
		if(!length(profile.zones))
			continue
		var/list/mob_types = users_by_profile[profile_type]
		html += "<h2>[profile_type]</h2>"
		if(!length(mob_types))
			html += "<p><b>UNUSED</b> - no mob assigns this profile.</p>"
			continue
		total_mobs += length(mob_types)

		html += "<table border='1' cellpadding='4'><tr><th>Mob</th><th>HP</th>"
		var/list/ordered_zones = list()
		for(var/zone in profile.zones)
			var/datum/anatomy_zone/part = profile.zones[zone]
			if(!part.break_wound || (part.hint in ordered_zones))
				continue
			ordered_zones += part.hint
			html += "<th>[part.hint]</th>"
		html += "</tr>"

		for(var/mob_type in mob_types)
			var/mob/living/simple_animal/prototype = mob_type
			var/max_health = initial(prototype.maxHealth)
			html += "<tr><td>[mob_type]</td><td>[max_health]</td>"
			var/list/done = list()
			for(var/zone in profile.zones)
				var/datum/anatomy_zone/part = profile.zones[zone]
				if(!part.break_wound || (part.hint in done))
					continue
				done += part.hint
				var/threshold = max(part.part_health_minimum, round(max_health * part.part_health_fraction, 1))
				var/pct = max_health ? round((threshold / max_health) * 100, 1) : 0
				html += "<td>[threshold] <i>([pct]%)</i></td>"
			html += "</tr>"
		html += "</table>"

		html += "<p><small>"
		var/list/notes = list()
		var/list/noted = list()
		for(var/zone in profile.zones)
			var/datum/anatomy_zone/part = profile.zones[zone]
			if(!part.break_wound || (part.hint in noted))
				continue
			noted += part.hint
			var/datum/wound/cripple/breakage = part.break_wound
			var/list/bits = list("<b>[part.hint]</b> -> [initial(breakage.name)]")
			if(part.min_wlength)
				bits += "needs wlength [part.min_wlength]"
			if(part.melee_hit_bonus)
				bits += "melee [part.melee_hit_bonus > 0 ? "+" : ""][part.melee_hit_bonus]"
			if(part.ranged_hit_bonus)
				bits += "ranged [part.ranged_hit_bonus > 0 ? "+" : ""][part.ranged_hit_bonus]"
			if(part.damage_mult != 1)
				bits += "dmg x[part.damage_mult]"
			notes += bits.Join(", ")
		html += notes.Join("<br>")
		html += "</small></p>"

	var/list/orphans = list()
	for(var/mob_type in typesof(/mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/prototype = mob_type
		if(!initial(prototype.anatomy_type))
			orphans += mob_type
	html += "<h2>No profile assigned ([length(orphans)])</h2><p><small>[orphans.Join("<br>")]</small></p>"

	html += "<p><b>[total_mobs]</b> mobs on a profile.</p>"
	usr << browse(html.Join(""), "window=anatomyreview;size=1000x800")
