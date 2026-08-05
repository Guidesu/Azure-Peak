#define TTK_SAMPLES 8000

/datum/ttk_build
	var/name
	var/weapon_type
	var/intent_type
	var/wielded = FALSE
	var/ranged = FALSE
	var/ammo_type
	var/period = 10
	var/list/stats = list()

/datum/ttk_build/swift
	name = "Swift - sabre"
	weapon_type = /obj/item/rogueweapon/sword/sabre
	intent_type = /datum/intent/sword/cut/sabre
	stats = list("STASTR" = 10, "STAPER" = 10, "STASPD" = 14)

/datum/ttk_build/spear
	name = "Spear hunter"
	weapon_type = /obj/item/rogueweapon/spear
	intent_type = /datum/intent/spear/thrust
	wielded = TRUE
	stats = list("STASTR" = 11, "STAPER" = 13, "STASPD" = 10)

/datum/ttk_build/bow
	name = "Bow hunter"
	weapon_type = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	ammo_type = /obj/projectile/bullet/reusable/arrow/iron
	ranged = TRUE
	period = 27.5
	stats = list("STASTR" = 10, "STAPER" = 15, "STASPD" = 10)

/proc/ttk_dummy(list/stats)
	var/mob/living/carbon/human/dummy = new(locate(1, 1, 1))
	dummy.status_flags |= GODMODE
	for(var/stat in stats)
		dummy.vars[stat] = stats[stat]
	return dummy

/// Rolls the real accuracy proc N times and returns the observed hit rate.
/proc/ttk_melee_hit_rate(mob/living/user, mob/living/target, zone, obj/item/weapon)
	var/hits = 0
	for(var/i in 1 to TTK_SAMPLES)
		if(resolve_aimed_zone(zone, user, target, 0) == zone)
			hits++
	return hits / TTK_SAMPLES

/proc/ttk_ranged_hit_rate(mob/living/target, zone, accuracy)
	var/hits = 0
	for(var/i in 1 to TTK_SAMPLES)
		if(target.bullet_hit_accuracy_check(accuracy, zone) == zone)
			hits++
	return hits / TTK_SAMPLES

/proc/ttk_build_damage(datum/ttk_build/build, mob/living/user)
	if(build.ranged)
		var/obj/projectile/proto = build.ammo_type
		var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/launcher = build.weapon_type
		var/per_scaling = 1 + ((min(user.STAPER, RANGED_STAT_SOFTCAP) - 10) * RANGED_STAT_MULT) \
			+ (max(0, user.STAPER - RANGED_STAT_SOFTCAP) * RANGED_STAT_CAPPEDMULT)
		return initial(proto.damage) * initial(launcher.damfactor) * per_scaling
	var/obj/item/weapon = new build.weapon_type()
	weapon.wielded = build.wielded
	weapon.update_force_dynamic()
	user.put_in_active_hand(weapon)
	user.used_intent = new build.intent_type()
	var/damage = get_complex_damage(weapon, user)
	qdel(weapon)
	return damage

/client/proc/review_ttk_benchmarks()
	set category = "Debug"
	set name = "Review TTK Benchmarks"
	set desc = "Compute perfect-play TTK for each benchmark build against every mob with a profile."
	if(!check_rights(R_DEBUG))
		return

	var/list/html = list("<h1>Benchmark TTK</h1><p><small>Damage from <b>get_complex_damage</b>; hit rates are [TTK_SAMPLES] rolls of the real accuracy procs.</small></p>")
	var/list/builds = list()
	for(var/build_type in subtypesof(/datum/ttk_build))
		builds += new build_type()

	// Per-build damage and body DPS.
	html += "<h2>Damage</h2><table border='1' cellpadding='4'><tr><th>Build</th><th>Per hit</th><th>Interval</th><th>Body DPS</th></tr>"
	var/list/dps_by_build = list()
	for(var/datum/ttk_build/build in builds)
		var/mob/living/carbon/human/user = ttk_dummy(build.stats)
		var/damage = ttk_build_damage(build, user)
		var/dps = damage / (build.period / 10)
		dps_by_build[build.name] = dps
		html += "<tr><td>[build.name]</td><td>[round(damage, 0.1)]</td><td>[build.period / 10]s</td><td><b>[round(dps, 0.1)]</b></td></tr>"
		qdel(user)
	html += "</table>"

	// Melee head accuracy across the PER range, against a live tough biped.
	html += "<h2>Head hit rate vs biped/tough by PER</h2>"
	html += "<table border='1' cellpadding='4'><tr><th>PER</th><th>Melee head</th><th>Melee leg</th><th>Ranged head</th></tr>"
	var/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/probe = new(locate(1, 1, 1))
	probe.status_flags |= GODMODE
	for(var/per in 10 to 18)
		var/mob/living/carbon/human/user = ttk_dummy(list("STAPER" = per))
		var/melee_head = ttk_melee_hit_rate(user, probe, BODY_ZONE_HEAD, null)
		var/melee_leg = ttk_melee_hit_rate(user, probe, BODY_ZONE_L_LEG, null)
		var/obj/projectile/arrow = /obj/projectile/bullet/reusable/arrow/iron
		var/arrow_accuracy = initial(arrow.accuracy) + ((per - 9) * 4) + ((per - 8) * 3)
		var/ranged_head = ttk_ranged_hit_rate(probe, BODY_ZONE_HEAD, arrow_accuracy)
		html += "<tr><td>[per]</td><td>[round(melee_head * 100, 0.1)]%</td><td>[round(melee_leg * 100, 0.1)]%</td><td>[round(ranged_head * 100, 0.1)]%</td></tr>"
		qdel(user)
	html += "</table>"
	qdel(probe)

	// Raw TTK across every mob carrying a profile.
	html += "<h2>Raw kill</h2><table border='1' cellpadding='4'><tr><th>Mob</th><th>HP</th>"
	for(var/datum/ttk_build/build in builds)
		html += "<th>[build.name]</th>"
	html += "</tr>"
	var/list/rows = list()
	for(var/mob_type in typesof(/mob/living/simple_animal))
		var/mob/living/simple_animal/prototype = mob_type
		if(!initial(prototype.anatomy_type))
			continue
		rows[mob_type] = initial(prototype.maxHealth)
	for(var/mob_type in rows)
		var/hp = rows[mob_type]
		html += "<tr><td>[mob_type]</td><td>[hp]</td>"
		for(var/datum/ttk_build/build in builds)
			html += "<td>[round(hp / dps_by_build[build.name], 0.1)]s</td>"
		html += "</tr>"
	html += "</table>"

	usr << browse(html.Join(""), "window=ttkreview;size=1100x900")

#undef TTK_SAMPLES
