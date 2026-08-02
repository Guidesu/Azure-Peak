// ═══════════════════════════════════════════════════════════════════
// WATERBENDING — Multi-form water & ice manipulation
// A single spell with many forms cycled via Shift+G.
// Each form is a different waterbending technique:
//   - Ice Shard: Single projectile, fast, piercing
//   - Water Whip: Close-range line that knocks down
//   - Ice Wall: Raise a barrier of ice
//   - Frost Wave: Cone of ice, slows and damages
//   - Healing Water: Self-cast or target, heals wounds
//   - Ice Skate: Slide across ice at high speed
//   - Water Grab: Freeze a target's feet in place
//   - Glacier: Massive AOE ice explosion
//   - Mist Form: Become misty — reduce damage, pass through
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/waterbending
	name = "Waterbending"
	desc = "The art of commanding water and ice. Cycle forms with Shift+G — \
		each form is a different technique: ice shard, water whip, ice wall, \
		frost wave, healing water, ice skate, water grab, glacier, mist form. \
		Only limited by your creativity and chi."
	button_icon = 'icons/mob/actions/mage_cryomancy.dmi'
	button_icon_state = "frost_bolt"
	spell_color = GLOW_COLOR_ICE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_CRYOMANCY

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_ENERGY
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_EMOTE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 4 SECONDS
	shared_cooldown = "waterbending"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/form_index = 1
	var/list/forms = list(
		list("label" = "Ice Shard", "desc" = "Hurl a sharp shard of ice. Fast, piercing, applies frost stacks.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 4 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
		list("label" = "Water Whip", "desc" = "Crack a whip of water at close range. Knocks down and pulls enemies.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 5 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
		list("label" = "Ice Wall", "desc" = "Raise a wall of ice at the target tile. Blocks movement and projectiles. Lasts 20 seconds.", "cost" = SPELLCOST_CANTRIP, "cooldown" = 10 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
		list("label" = "Frost Wave", "desc" = "Cone of ice shards. Hits multiple foes, slows movement, applies frost.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 6 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
		list("label" = "Healing Water", "desc" = "Channel healing water into a target. Restores health and removes wounds. Can self-cast.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 12 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "frost_bolt"),
		list("label" = "Ice Skate", "desc" = "Create a path of ice and slide to the target tile at high speed. Knocks aside foes in the path.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 6 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
		list("label" = "Water Grab", "desc" = "Freeze a target's feet in a block of ice. Immobilizes them for 5 seconds.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "frost_bolt"),
		list("label" = "Glacier", "desc" = "Summon a massive glacier that explodes outward. AOE damage + freeze. Ultimate.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 20 SECONDS, "charge" = CHARGETIME_HEAVY, "icon" = "frost_bolt"),
		list("label" = "Mist Form", "desc" = "Transform your body into mist. Take -40% damage and pass through foes for 10 seconds. Self-cast.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 25 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "frost_bolt"),
	)

/datum/action/cooldown/spell/waterbending/Grant(mob/grant_to)
	. = ..()
	apply_form(form_index)

/datum/action/cooldown/spell/waterbending/proc/apply_form(index)
	var/list/form = forms[index]
	primary_resource_cost = form["cost"]
	cooldown_time = form["cooldown"]
	charge_time = form["charge"]
	button_icon_state = form["icon"]
	build_all_button_icons()
	update_form_maptext(form["label"])

/datum/action/cooldown/spell/waterbending/toggle_alt_mode(mob/user)
	form_index = (form_index % length(forms)) + 1
	apply_form(form_index)
	var/list/form = forms[form_index]
	to_chat(user, span_notice("<b>Waterbending: [form["label"]]</b> — [form["desc"]]"))
	return TRUE

/datum/action/cooldown/spell/waterbending/cast(atom/cast_on)
	..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/list/form = forms[form_index]
	// ── Bending Flow: gain flow stacks on cast ──
	add_bending_flow(H, BENDING_ELEMENT_WATER, 1)
	// ── Bending Combo: register form cast for combo tracking ──
	register_bending_form_cast(H, BENDING_ELEMENT_WATER, form["label"])
	// ── VFX: cast burst on caster ──
	create_bending_cast_burst(get_turf(H), GLOW_COLOR_ICE)
	switch(form["label"])
		if("Ice Shard")
			return cast_ice_shard(H, cast_on)
		if("Water Whip")
			return cast_water_whip(H, cast_on)
		if("Ice Wall")
			return cast_ice_wall(H, cast_on)
		if("Frost Wave")
			return cast_frost_wave(H, cast_on)
		if("Healing Water")
			return cast_healing_water(H, cast_on)
		if("Ice Skate")
			return cast_ice_skate(H, cast_on)
		if("Water Grab")
			return cast_water_grab(H, cast_on)
		if("Glacier")
			return cast_glacier(H)
		if("Mist Form")
			return cast_mist_form(H)
	return TRUE

// ─── FORM IMPLEMENTATIONS ───────────────────────────────────────────

/datum/action/cooldown/spell/waterbending/proc/cast_ice_shard(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] flicks a wrist, launching a shard of ice!"), span_notice("I hurl a shard of ice!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	var/obj/projectile/magic/frostbolt/proj = new /obj/projectile/magic/frostbolt(get_turf(H))
	proj.damage = round(35 * get_bending_flow_damage_mult(H))
	proj.range = 12 + get_bending_flow_range_bonus(H)
	proj.fire(dir2angle(dir))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/create_bending_impact_ring, T, GLOW_COLOR_ICE, 1.0), 0.3 SECONDS)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_water_whip(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(get_dist(H, T) > 5)
		to_chat(H, span_warning("The water whip can only reach 5 tiles."))
		return FALSE
	H.visible_message(span_warning("[H] lashes out with a whip of water!"), span_notice("I crack a whip of water!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	var/turf/current = get_turf(H)
	var/dir = get_dir(H, T)
	for(var/i in 1 to 5)
		current = get_step(current, dir)
		if(!current)
			break
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(20, BURN, null, L.run_armor_check(null, "fire", damage = 20))
			L.Knockdown(15)
			L.visible_message(span_danger("[L] is knocked down by the water whip!"), span_userdanger("A whip of water sweeps my legs out from under me!"))
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_ice_wall(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 7)
		to_chat(H, span_warning("Too far to raise an ice wall there."))
		return FALSE
	H.visible_message(span_notice("[H] thrusts both palms forward — a wall of ice erupts from the ground!"), span_notice("I raise a wall of ice."))
	playsound(T, 'sound/magic/vlightning.ogg', 50, TRUE)
	var/obj/structure/earthen_wall/wall = new /obj/structure/earthen_wall(T)
	wall.name = "ice wall"
	wall.desc = "A wall of solid ice, raised by a waterbender."
	wall.color = GLOW_COLOR_ICE
	wall.max_integrity = 150
	wall.obj_integrity = 150
	wall.timeleft = 20 SECONDS
	QDEL_IN(wall, 20 SECONDS)
	// VFX: ice floor effect around the wall
	for(var/turf/ST in range(1, T))
		create_bending_ice_floor(ST)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_frost_wave(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] sweeps both arms forward, unleashing a wave of frost!"), span_notice("I unleash a wave of frost!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 60, TRUE)
	var/base_angle = dir2angle(dir)
	for(var/i in 1 to 5)
		var/obj/projectile/magic/frost_shard/proj = new /obj/projectile/magic/frost_shard(get_turf(H))
		proj.damage = 18
		proj.range = 6
		var/spread = (i - 3) * 12
		proj.fire(base_angle + spread)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_healing_water(mob/living/carbon/human/H, atom/target)
	if(!isliving(target))
		to_chat(H, span_warning("The healing water can only target living beings."))
		return FALSE
	var/mob/living/L = target
	H.visible_message(span_notice("[H] channels a stream of glowing water over [L]!"), span_notice("I channel healing water over [target == H ? "myself" : L]."))
	playsound(get_turf(L), 'sound/magic/vlightning.ogg', 40, TRUE)
	L.adjustBruteLoss(-30)
	L.adjustFireLoss(-20)
	L.adjustToxLoss(-10, forced = TRUE)
	new /obj/effect/temp_visual/snap_freeze(get_turf(L))
	to_chat(L, span_notice("Healing water flows through you, mending your wounds."))
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_ice_skate(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 10)
		to_chat(H, span_warning("Too far to skate there."))
		return FALSE
	H.visible_message(span_notice("[H] creates a path of ice and skates forward!"), span_notice("I skate across a path of ice!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	var/turf/current = get_turf(H)
	var/dir = get_dir(current, T)
	while(current && current != T)
		current = get_step(current, dir)
		if(!current)
			break
		create_bending_ice_floor(current)
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(round(12 * get_bending_flow_damage_mult(H)), BURN, null, L.run_armor_check(null, "fire", damage = 12))
			L.Knockdown(10)
	H.forceMove(T)
	create_bending_cast_burst(T, GLOW_COLOR_ICE)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_water_grab(mob/living/carbon/human/H, atom/target)
	if(!isliving(target))
		to_chat(H, span_warning("Water grab can only target living beings."))
		return FALSE
	var/mob/living/L = target
	if(get_dist(H, L) > 7)
		to_chat(H, span_warning("Too far to reach with water grab."))
		return FALSE
	H.visible_message(span_warning("[H] extends a hand — water surges around [L]'s feet and freezes solid!"), span_notice("I freeze [L]'s feet in a block of ice!"))
	playsound(get_turf(L), 'sound/magic/vlightning.ogg', 50, TRUE)
	L.apply_damage(10, BURN, null, L.run_armor_check(null, "fire", damage = 10))
	L.Immobilize(50)
	L.visible_message(span_danger("[L] is frozen in a block of ice!"), span_userdanger("Water surges around my feet and freezes — I'm stuck!"))
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_glacier(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] raises both arms and a massive glacier erupts from the ground!"), span_notice("I summon a glacier!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 100, TRUE)
	for(var/mob/living/L in range(5, H))
		if(L == H)
			continue
		var/dist = get_dist(H, L)
		var/damage = max(round((50 - (dist * 8)) * get_bending_flow_damage_mult(H)), 15)
		L.apply_damage(damage, BURN, null, L.run_armor_check(null, "fire", damage = damage))
		L.Knockdown(20)
		L.Immobilize(30)
		L.visible_message(span_danger("[L] is shattered by the glacier!"), span_userdanger("A glacier erupts beneath me and shatters!"))
	// VFX: massive expanding ring + ice floor
	create_bending_impact_ring(get_turf(H), GLOW_COLOR_ICE, 3.0)
	for(var/turf/IT in range(3, get_turf(H)))
		create_bending_ice_floor(IT)
	consume_bending_flow(H, 2)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/cast_mist_form(mob/living/carbon/human/H)
	H.visible_message(span_notice("[H]'s body becomes translucent and misty!"), span_notice("I transform my body into mist."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	ADD_TRAIT(H, "mist_form_buff", "waterbending")
	H.alpha = 120
	// VFX: mist particles around the caster
	create_bending_cast_burst(get_turf(H), GLOW_COLOR_ICE)
	addtimer(CALLBACK(src, .proc/remove_mist_form, H), 10 SECONDS)
	return TRUE

/datum/action/cooldown/spell/waterbending/proc/remove_mist_form(mob/living/carbon/human/H)
	if(H)
		REMOVE_TRAIT(H, "mist_form_buff", "waterbending")
		H.alpha = 255

/datum/action/cooldown/spell/waterbending/proc/update_form_maptext(label)
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
