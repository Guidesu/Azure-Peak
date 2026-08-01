// ═══════════════════════════════════════════════════════════════════
// EARTHBENDING — Multi-form earth manipulation
// A single spell with many forms cycled via Shift+G.
// Each form is a different earthbending technique:
//   - Boulder Throw: Hurl a massive boulder (heavy damage, slow)
//   - Rock Spike: Impale from below (line attack, high damage)
//   - Earth Wall: Raise a wall of stone (defensive barrier)
//   - Gravel Spray: Shotgun blast of small stones (close range, spread)
//   - Sinkhole: Drop the ground beneath a target (trap/CC)
//   - Earth Armor: Coat yourself in stone (self-buff, damage reduction)
//   - Tremor: AoE ground slam around self (knockdown + damage)
//   - Stone Skate: Ride a slab of earth at high speed (mobility)
//   - Rock Hand: Grab a target at range with a stone hand (pull/CC)
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/earthbending
	name = "Earthbending"
	desc = "The art of commanding stone and earth. Cycle forms with Shift+G — \
		each form is a different technique: boulder throw, rock spike, earth wall, \
		gravel spray, sinkhole, earth armor, tremor, stone skate, rock hand. \
		Only limited by your creativity and chi."
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	button_icon_state = "gravel_blast"
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_GEOMANCY

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_EMOTE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 4 SECONDS
	shared_cooldown = "earthbending"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	/// Current form index
	var/form_index = 1
	/// All available forms, cycled with Shift+G
	var/list/forms = list(
		list("label" = "Boulder", "desc" = "Hurl a massive boulder. Heavy damage, slow projectile, knocks back on hit.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "gravel_blast"),
		list("label" = "Rock Spike", "desc" = "Impale a target from below. Line attack from caster to target, high damage, ignores armor.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 7 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "gravel_blast"),
		list("label" = "Earth Wall", "desc" = "Raise a wall of stone at the target tile. Blocks movement and projectiles. Lasts 30 seconds.", "cost" = SPELLCOST_CANTRIP, "cooldown" = 10 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "gravel_blast"),
		list("label" = "Gravel Spray", "desc" = "Shotgun blast of small stones. Close range, wide spread, armor degradation.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 4 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "gravel_blast"),
		list("label" = "Sinkhole", "desc" = "Drop the ground beneath a target. Traps them in a pit for 5 seconds.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 12 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "gravel_blast"),
		list("label" = "Earth Armor", "desc" = "Coat yourself in stone armor. Reduces incoming damage by 40% for 20 seconds. Self-cast only.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 30 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "gravel_blast"),
		list("label" = "Tremor", "desc" = "Slam the ground, creating a shockwave around you. Knocks down and damages all nearby foes.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 10 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "gravel_blast"),
		list("label" = "Stone Skate", "desc" = "Ride a slab of earth at high speed. Dash to target tile, knocking aside anyone in the path.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 6 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "gravel_blast"),
		list("label" = "Rock Hand", "desc" = "Summon a giant stone hand that grabs a target at range, pulling them toward you.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "gravel_blast"),
	)

/datum/action/cooldown/spell/earthbending/Grant(mob/grant_to)
	. = ..()
	apply_form(form_index)

/datum/action/cooldown/spell/earthbending/proc/apply_form(index)
	var/list/form = forms[index]
	primary_resource_cost = form["cost"]
	cooldown_time = form["cooldown"]
	charge_time = form["charge"]
	button_icon_state = form["icon"]
	build_all_button_icons()
	update_form_maptext(form["label"])

/datum/action/cooldown/spell/earthbending/toggle_alt_mode(mob/user)
	form_index = (form_index % length(forms)) + 1
	apply_form(form_index)
	var/list/form = forms[form_index]
	to_chat(user, span_notice("<b>Earthbending: [form["label"]]</b> — [form["desc"]]"))
	return TRUE

/datum/action/cooldown/spell/earthbending/cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/list/form = forms[form_index]
	var/form_label = form["label"]

	// ── Bending Flow: gain flow stacks on cast ──
	add_bending_flow(H, BENDING_ELEMENT_EARTH, 1)
	// ── Bending Combo: register form cast for combo tracking ──
	register_bending_form_cast(H, BENDING_ELEMENT_EARTH, form_label)
	// ── VFX: cast burst on caster ──
	create_bending_cast_burst(get_turf(H), GLOW_COLOR_EARTHEN)

	switch(form_label)
		if("Boulder")
			return cast_boulder(H, cast_on)
		if("Rock Spike")
			return cast_rock_spike(H, cast_on)
		if("Earth Wall")
			return cast_earth_wall(H, cast_on)
		if("Gravel Spray")
			return cast_gravel_spray(H, cast_on)
		if("Sinkhole")
			return cast_sinkhole(H, cast_on)
		if("Earth Armor")
			return cast_earth_armor(H, cast_on)
		if("Tremor")
			return cast_tremor(H, cast_on)
		if("Stone Skate")
			return cast_stone_skate(H, cast_on)
		if("Rock Hand")
			return cast_rock_hand(H, cast_on)

	return TRUE

// ─── FORM IMPLEMENTATIONS ───────────────────────────────────────────

/// Boulder: Hurl a single heavy projectile that knocks back
/datum/action/cooldown/spell/earthbending/proc/cast_boulder(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(
		span_warning("[H] stomps forward and hurls a massive boulder!"),
		span_notice("I tear a boulder from the earth and hurl it!")
	)
	playsound(get_turf(H), 'sound/foley/stone_scrape.ogg', 80, TRUE)

	// Create a projectile
	var/obj/projectile/magic/gravel_blast/proj = new /obj/projectile/magic/gravel_blast(get_turf(H))
	proj.damage = round(45 * get_bending_flow_damage_mult(H))
	proj.knockdown = 20
	proj.range = 12 + get_bending_flow_range_bonus(H)
	proj.speed = 0.3
	proj.fire(dir2angle(dir))
	// VFX: earth spike at target
	addtimer(CALLBACK(GLOBAL_PROC, .proc/create_bending_earth_spike, T, GLOW_COLOR_EARTHEN), 0.3 SECONDS)
	return TRUE

/// Rock Spike: Line attack from caster to target, high damage
/datum/action/cooldown/spell/earthbending/proc/cast_rock_spike(mob/living/carbon/human/H, atom/target)
	var/turf/start = get_turf(H)
	var/turf/end = get_turf(target)
	if(!start || !end)
		return FALSE

	H.visible_message(
		span_warning("[H] drives their palm downward — a line of rock spikes erupts toward [target]!"),
		span_notice("I drive a line of rock spikes toward my target!")
	)
	playsound(start, 'sound/combat/hits/onstone/wallhit.ogg', 70, TRUE)

	var/turf/current = start
	var/dist = 0
	while(current && current != end && dist < 12)
		current = get_step(current, get_dir(current, end))
		dist++
		if(!current)
			break
		// Damage anything on this turf
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(round(35 * get_bending_flow_damage_mult(H)), BRUTE, null, L.run_armor_check(null, "blunt", damage = 35))
			L.visible_message(span_danger("A rock spike impales [L]!"), span_userdanger("A rock spike erupts beneath me and impales my leg!"))
			L.Knockdown(10)
		// Visual effect
		create_bending_earth_spike(current, GLOW_COLOR_EARTHEN)
	return TRUE

/// Earth Wall: Raise a dense wall at target tile
/datum/action/cooldown/spell/earthbending/proc/cast_earth_wall(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE

	// Check range
	if(get_dist(H, T) > 7)
		to_chat(H, span_warning("Too far away to raise a wall there."))
		return FALSE

	H.visible_message(
		span_notice("[H] thrusts both palms forward — a wall of stone erupts from the ground!"),
		span_notice("I raise a wall of stone at the target.")
	)
	playsound(T, 'sound/foley/stone_scrape.ogg', 60, TRUE)

	// Create a dense wall object (uses existing earthen_wall structure)
	var/obj/structure/earthen_wall/wall = new /obj/structure/earthen_wall(T)
	wall.timeleft = 30 SECONDS
	QDEL_IN(wall, 30 SECONDS)
	// VFX: earth spikes erupt around the wall
	for(var/turf/ST in range(1, T))
		create_bending_earth_spike(ST, GLOW_COLOR_EARTHEN)
	return TRUE

/// Gravel Spray: Close-range shotgun blast
/datum/action/cooldown/spell/earthbending/proc/cast_gravel_spray(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)

	H.visible_message(
		span_warning("[H] sweeps their arm forward — a spray of gravel bursts forth!"),
		span_notice("I spray a blast of gravel at my target!")
	)
	playsound(get_turf(H), 'sound/combat/hits/onstone/wallhit.ogg', 60, TRUE)

	// Fire 5 projectiles in a spread
	var/base_angle = dir2angle(dir)
	for(var/i in 1 to 5)
		var/obj/projectile/magic/gravel_blast/proj = new /obj/projectile/magic/gravel_blast(get_turf(H))
		proj.damage = 12
		proj.range = 6
		var/spread = (i - 3) * 12
		proj.fire(base_angle + spread)
	return TRUE

/// Sinkhole: Trap a target in a pit
/datum/action/cooldown/spell/earthbending/proc/cast_sinkhole(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 7)
		to_chat(H, span_warning("Too far away to collapse the ground there."))
		return FALSE

	H.visible_message(
		span_warning("[H] clenches their fist downward — the ground beneath [target] collapses!"),
		span_notice("I collapse the ground beneath my target!")
	)
	playsound(T, 'sound/foley/stone_scrape.ogg', 70, TRUE)

	for(var/mob/living/L in T)
		if(L == H)
			continue
		L.apply_damage(round(20 * get_bending_flow_damage_mult(H)), BRUTE, null, L.run_armor_check(null, "blunt", damage = 20))
		L.Knockdown(30)
		L.Immobilize(50)
		L.visible_message(span_danger("[L] plunges into a sinkhole!"), span_userdanger("The ground opens beneath me and I fall into a pit!"))

	create_bending_impact_ring(T, GLOW_COLOR_EARTHEN, 1.5)
	return TRUE

/// Earth Armor: Self-buff damage reduction
/datum/action/cooldown/spell/earthbending/proc/cast_earth_armor(mob/living/carbon/human/H)
	H.visible_message(
		span_notice("[H] pulls stone from the ground, coating themselves in a layer of rock armor!"),
		span_notice("I coat myself in stone armor.")
	)
	playsound(get_turf(H), 'sound/foley/stone_scrape.ogg', 50, TRUE)

	// Apply a temporary damage reduction trait
	ADD_TRAIT(H, "earth_armor_buff", "earthbending")
	addtimer(CALLBACK(src, .proc/remove_earth_armor, H), 20 SECONDS)

	// Visual indicator
	H.add_atom_colour(GLOW_COLOR_EARTHEN, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(H, /atom/proc/remove_atom_colour, TEMPORARY_COLOUR_PRIORITY), 20 SECONDS)
	return TRUE

/datum/action/cooldown/spell/earthbending/proc/remove_earth_armor(mob/living/H)
	if(H)
		REMOVE_TRAIT(H, "earth_armor_buff", "earthbending")

/// Tremor: AoE ground slam
/datum/action/cooldown/spell/earthbending/proc/cast_tremor(mob/living/carbon/human/H)
	H.visible_message(
		span_warning("[H] slams both fists into the ground — a shockwave ripples outward!"),
		span_notice("I slam the ground, sending a tremor in all directions!")
	)
	playsound(get_turf(H), 'sound/foley/stone_scrape.ogg', 90, TRUE)

	for(var/mob/living/L in range(4, H))
		if(L == H)
			continue
		var/dist = get_dist(H, L)
		var/damage = max(round((30 - (dist * 5)) * get_bending_flow_damage_mult(H)), 10)
		L.apply_damage(damage, BRUTE, null, L.run_armor_check(null, "blunt", damage = damage))
		L.Knockdown(15)
		L.visible_message(span_danger("[L] is caught in the tremor!"), span_userdanger("The ground heaves beneath me!"))

	// Visual effect
	// VFX: expanding ring + earth spikes around caster
	create_bending_impact_ring(get_turf(H), GLOW_COLOR_EARTHEN, 2.5)
	for(var/turf/ET in range(2, get_turf(H)))
		create_bending_earth_spike(ET, GLOW_COLOR_EARTHEN)
	consume_bending_flow(H, 2)
	return TRUE

/// Stone Skate: Dash to target tile
/datum/action/cooldown/spell/earthbending/proc/cast_stone_skate(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 10)
		to_chat(H, span_warning("Too far to skate there."))
		return FALSE

	H.visible_message(
		span_notice("[H] leaps onto a slab of stone and surges forward!"),
		span_notice("I ride a slab of earth toward my target!")
	)
	playsound(get_turf(H), 'sound/foley/stone_scrape.ogg', 60, TRUE)

	// Move the caster toward the target, knocking aside anyone in the path
	var/turf/current = get_turf(H)
	var/dist = 0
	while(current && current != T && dist < 10)
		current = get_step(current, get_dir(current, T))
		dist++
		if(!current)
			break
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(round(15 * get_bending_flow_damage_mult(H)), BRUTE, null, L.run_armor_check(null, "blunt", damage = 15))
			L.Knockdown(10)
			L.visible_message(span_danger("[H] slams through [L] on a slab of stone!"), span_userdanger("A slab of stone slams into me!"))

	H.forceMove(T)
	create_bending_cast_burst(T, GLOW_COLOR_EARTHEN)
	return TRUE

/// Rock Hand: Grab and pull a target
/datum/action/cooldown/spell/earthbending/proc/cast_rock_hand(mob/living/carbon/human/H, atom/target)
	if(!isliving(target))
		to_chat(H, span_warning("The rock hand can only grab living targets."))
		return FALSE
	var/mob/living/L = target
	if(get_dist(H, L) > 7)
		to_chat(H, span_warning("Too far away to reach with a stone hand."))
		return FALSE

	H.visible_message(
		span_warning("[H] thrusts out a hand — a giant stone hand erupts from the ground and grabs [L]!"),
		span_notice("I summon a stone hand to grab my target!")
	)
	playsound(get_turf(L), 'sound/foley/stone_scrape.ogg', 60, TRUE)

	L.apply_damage(15, BRUTE, null, L.run_armor_check(null, "blunt", damage = 15))
	L.Immobilize(20)

	// Pull the target toward the caster
	addtimer(CALLBACK(src, .proc/pull_target, H, L), 1 SECONDS)
	return TRUE

/datum/action/cooldown/spell/earthbending/proc/pull_target(mob/living/caster, mob/living/target)
	if(!caster || !target)
		return
	var/turf/caster_turf = get_turf(caster)
	var/turf/target_turf = get_turf(target)
	if(!caster_turf || !target_turf)
		return
	// Move target 2 tiles toward caster
	for(var/i in 1 to 2)
		var/turf/next = get_step(target_turf, get_dir(target_turf, caster_turf))
		if(next)
			target_turf = next
	target.forceMove(target_turf)
	target.visible_message(span_danger("[target] is dragged across the ground by the stone hand!"), span_userdanger("A stone hand drags me across the ground!"))

// ─── Maptext helper ─────────────────────────────────────────────────

/datum/action/cooldown/spell/earthbending/proc/update_form_maptext(label)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(label)
		holder.color = spell_color || "#ffffff"
