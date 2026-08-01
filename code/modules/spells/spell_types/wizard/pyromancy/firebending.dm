// ═══════════════════════════════════════════════════════════════════
// FIREBENDING — Multi-form fire manipulation
// A single spell with many forms cycled via Shift+G.
// Each form is a different firebending technique:
//   - Fire Bolt: Single projectile, balanced (classic)
//   - Fire Stream: Cone of flame, close range, scorch stacks
//   - Fire Bomb: Lobbed AOE explosion, high damage
//   - Flame Whip: Close-range line that pulls enemies in
//   - Fire Shield: Self-cast, reduces fire damage and reflects
//   - Ember Step: Dash leaving a trail of fire
//   - Fire Blade: Conjure a temporary flaming weapon
//   - Inferno: Massive AOE around self, ultimate
//   - Smoke Veil: Create a smoke cloud for escape
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/firebending
	name = "Firebending"
	desc = "The art of commanding flame. Cycle forms with Shift+G — \
		each form is a different technique: fire bolt, fire stream, fire bomb, \
		flame whip, fire shield, ember step, fire blade, inferno, smoke veil. \
		Only limited by your creativity and chi."
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	button_icon_state = "spitfire"
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_PYROMANCY

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_ENERGY
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_EMOTE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 4 SECONDS
	shared_cooldown = "firebending"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/form_index = 1
	var/list/forms = list(
		list("label" = "Fire Bolt", "desc" = "Hurl a single bolt of fire. Balanced damage, medium range, applies scorch.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 4 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Fire Stream", "desc" = "Cone of flame from your hands. Close range, hits multiple foes, heavy scorch stacks.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 6 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Fire Bomb", "desc" = "Lob an explosive fireball. AOE blast on impact, high damage, scatters foes.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "spitfire"),
		list("label" = "Flame Whip", "desc" = "Crack a whip of fire at close range. Pulls enemies toward you and scorches.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 5 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Fire Shield", "desc" = "Wreathe yourself in protective flame. Reduces incoming damage by 30% and burns attackers for 15 seconds. Self-cast.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 25 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Ember Step", "desc" = "Dash to target tile, leaving a trail of fire that burns anyone who steps on it.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 6 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Fire Blade", "desc" = "Conjure a blade of pure flame. Temporary weapon that deals burn damage and applies scorch on hit. Lasts 30 seconds.", "cost" = SPELLCOST_CANTRIP, "cooldown" = 15 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
		list("label" = "Inferno", "desc" = "Release a massive burst of fire in all directions. Ultimate — high damage, high cost, long cooldown.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 20 SECONDS, "charge" = CHARGETIME_HEAVY, "icon" = "spitfire"),
		list("label" = "Smoke Veil", "desc" = "Create a thick cloud of smoke at target tile. Blocks vision, extinguishes fires, perfect for escape.", "cost" = SPELLCOST_CANTRIP, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "spitfire"),
	)

/datum/action/cooldown/spell/firebending/Grant(mob/grant_to)
	. = ..()
	apply_form(form_index)

/datum/action/cooldown/spell/firebending/proc/apply_form(index)
	var/list/form = forms[index]
	primary_resource_cost = form["cost"]
	cooldown_time = form["cooldown"]
	charge_time = form["charge"]
	button_icon_state = form["icon"]
	build_all_button_icons()
	update_form_maptext(form["label"])

/datum/action/cooldown/spell/firebending/toggle_alt_mode(mob/user)
	form_index = (form_index % length(forms)) + 1
	apply_form(form_index)
	var/list/form = forms[form_index]
	to_chat(user, span_notice("<b>Firebending: [form["label"]]</b> — [form["desc"]]"))
	return TRUE

/datum/action/cooldown/spell/firebending/cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/list/form = forms[form_index]
	switch(form["label"])
		if("Fire Bolt")
			return cast_fire_bolt(H, cast_on)
		if("Fire Stream")
			return cast_fire_stream(H, cast_on)
		if("Fire Bomb")
			return cast_fire_bomb(H, cast_on)
		if("Flame Whip")
			return cast_flame_whip(H, cast_on)
		if("Fire Shield")
			return cast_fire_shield(H)
		if("Ember Step")
			return cast_ember_step(H, cast_on)
		if("Fire Blade")
			return cast_fire_blade(H)
		if("Inferno")
			return cast_inferno(H)
		if("Smoke Veil")
			return cast_smoke_veil(H, cast_on)
	return TRUE

// ─── FORM IMPLEMENTATIONS ───────────────────────────────────────────

/datum/action/cooldown/spell/firebending/proc/cast_fire_bolt(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] thrusts a palm forward, launching a bolt of fire!"), span_notice("I hurl a bolt of fire!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 60, TRUE)
	var/obj/projectile/magic/spitfire/proj = new /obj/projectile/magic/spitfire(get_turf(H))
	proj.damage = 40
	proj.range = 12
	proj.fire(dir2angle(dir))
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_fire_stream(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] sweeps both hands forward, unleashing a cone of flame!"), span_notice("I unleash a cone of fire!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 70, TRUE)
	// Fire 5 projectiles in a cone
	var/base_angle = dir2angle(dir)
	for(var/i in 1 to 5)
		var/obj/projectile/magic/spitfire/proj = new /obj/projectile/magic/spitfire(get_turf(H))
		proj.damage = 20
		proj.range = 6
		var/spread = (i - 3) * 15
		proj.fire(base_angle + spread)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_fire_bomb(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(get_dist(H, T) > 10)
		to_chat(H, span_warning("Too far to lob a fire bomb there."))
		return FALSE
	H.visible_message(span_warning("[H] hurls a roaring sphere of fire that explodes on impact!"), span_notice("I lob a fire bomb!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 80, TRUE)
	var/obj/projectile/magic/aoe/fireball/rogue/proj = new /obj/projectile/magic/aoe/fireball/rogue(get_turf(H))
	proj.damage = 60
	proj.range = 10
	proj.fire(Get_Angle(H, T))
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_flame_whip(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(get_dist(H, T) > 5)
		to_chat(H, span_warning("The flame whip can only reach 5 tiles."))
		return FALSE
	H.visible_message(span_warning("[H] cracks a whip of fire toward [target]!"), span_notice("I crack a whip of flame!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	// Damage along the line and pull enemies
	var/turf/current = get_turf(H)
	var/dir = get_dir(H, T)
	for(var/i in 1 to 5)
		current = get_step(current, dir)
		if(!current)
			break
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(25, BURN, null, L.run_armor_check(null, "fire", damage = 25))
			L.visible_message(span_danger("[L] is lashed by the flame whip!"), span_userdanger("A whip of fire lashes around me and yanks me forward!"))
			// Pull toward caster
			var/pull_dir = get_dir(L, H)
			var/turf/pull_to = get_step(L, pull_dir)
			if(pull_to)
				L.forceMove(pull_to)
		new /obj/effect/temp_visual/fire(current)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_fire_shield(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] erupts in a cloak of protective flame!"), span_notice("I wreathe myself in a shield of fire."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 60, TRUE)
	ADD_TRAIT(H, "fire_shield_buff", "firebending")
	H.add_atom_colour(GLOW_COLOR_FIRE, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, .proc/remove_fire_shield, H), 15 SECONDS)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/remove_fire_shield(mob/living/carbon/human/H)
	if(H)
		REMOVE_TRAIT(H, "fire_shield_buff", "firebending")
		H.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

/datum/action/cooldown/spell/firebending/proc/cast_ember_step(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 10)
		to_chat(H, span_warning("Too far to dash there."))
		return FALSE
	H.visible_message(span_warning("[H] bursts forward in a streak of flame!"), span_notice("I dash forward on a trail of embers!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	var/turf/current = get_turf(H)
	var/dir = get_dir(current, T)
	while(current && current != T)
		current = get_step(current, dir)
		if(!current)
			break
		new /obj/effect/temp_visual/fire(current)
		for(var/mob/living/L in current)
			if(L == H)
				continue
			L.apply_damage(15, BURN, null, L.run_armor_check(null, "fire", damage = 15))
	H.forceMove(T)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_fire_blade(mob/living/carbon/human/H)
	if(!H.get_empty_held_indexes())
		to_chat(H, span_warning("I need a free hand to shape a blade of fire."))
		return FALSE
	H.visible_message(span_warning("[H] clenches a fist, and a blade of pure flame ignites in their grip!"), span_notice("I shape a blade of fire in my hand."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	var/obj/item/rogueweapon/sword/sabre/ferramancy/W = new /obj/item/rogueweapon/sword/sabre/ferramancy(H.drop_location())
	W.name = "fire blade"
	W.desc = "A blade of pure flame, conjured by a firebender. Burns what it strikes."
	W.color = GLOW_COLOR_FIRE
	W.max_integrity = 100
	W.obj_integrity = 100
	W.AddComponent(/datum/component/conjured_item, GLOW_COLOR_FIRE, FALSE, H, src)
	H.put_in_hands(W)
	QDEL_IN(W, 30 SECONDS)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_inferno(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] throws their arms wide and erupts in a massive inferno!"), span_notice("I release an inferno in all directions!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 100, TRUE)
	for(var/mob/living/L in range(5, H))
		if(L == H)
			continue
		var/dist = get_dist(H, L)
		var/damage = max(60 - (dist * 10), 20)
		L.apply_damage(damage, BURN, null, L.run_armor_check(null, "fire", damage = damage))
		L.visible_message(span_danger("[L] is consumed by the inferno!"), span_userdanger("A wave of fire engulfs me!"))
		var/push_dir = get_dir(H, L)
		var/turf/push_to = get_step(L, push_dir)
		if(push_to)
			L.forceMove(push_to)
	new /obj/effect/temp_visual/explosion(get_turf(H))
	return TRUE

/datum/action/cooldown/spell/firebending/proc/cast_smoke_veil(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(get_dist(H, T) > 7)
		to_chat(H, span_warning("Too far to place a smoke veil there."))
		return FALSE
	H.visible_message(span_notice("[H] gestures, and a thick cloud of smoke billows forth!"), span_notice("I create a veil of smoke."))
	playsound(T, 'sound/magic/vlightning.ogg', 40, TRUE)
	for(var/turf/ST in range(2, T))
		new /obj/effect/particle_effect/smoke(ST)
	return TRUE

/datum/action/cooldown/spell/firebending/proc/update_form_maptext(label)
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
