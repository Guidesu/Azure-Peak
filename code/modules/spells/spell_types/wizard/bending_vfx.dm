// ═══════════════════════════════════════════════════════════════════
// BENDING VFX FRAMEWORK — Procedural visual effects for bending
//
// All effects are code-generated: no sprite files needed.
// Uses animate() transforms, particles, filters, screen overlays,
// and temp_visual objects to create dynamic elemental effects.
//
// Each element has a themed set of effects:
//   - Charge aura (while charging a spell)
//   - Cast burst (on spell release)
//   - Impact effect (on spell hit)
//   - Trail effect (for projectiles and dashes)
//   - Terrain effect (for persistent ground effects)
//   - Screen effect (for the caster's client)
// ═══════════════════════════════════════════════════════════════════

// ─── CHARGE AURA ───────────────────────────────────────────────────
// Attached to the caster via vis_contents while charging.
// Scales in intensity with charge time.

/obj/effect/abstract/bending_charge_aura
	name = "bending charge"
	desc = "Elemental energy gathering."
	icon = null
	plane = GAME_PLANE_UPPER
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/element_color = "#FFFFFF"
	var/intensity = 1.0

/obj/effect/abstract/bending_charge_aura/Initialize(mapload, color)
	. = ..()
	if(color)
		element_color = color
	// Start invisible, grow visible
	alpha = 0
	pixel_y = 4
	// Add an outline filter that we'll animate
	add_filter("charge_glow", 2, list("type" = "outline", "color" = element_color, "alpha" = 0, "size" = 0))
	// Add a second filter for inner glow
	add_filter("charge_inner", 1, list("type" = "outline", "color" = element_color, "alpha" = 0, "size" = 0))

/// Animate the charge aura growing in intensity (0.0 to 1.0)
/obj/effect/abstract/bending_charge_aura/proc/set_intensity(val)
	intensity = clamp(val, 0, 1)
	var/alpha_val = round(intensity * 200)
	var/size_val = round(intensity * 4)
	var/filter_idx = get_filter_index("charge_glow")
	if(filter_idx)
		animate(filters[filter_idx], alpha = alpha_val, size = size_val, time = 0.3 SECONDS, easing = SINE_EASING)
	var inner_idx = get_filter_index("charge_inner")
	if(inner_idx)
		animate(filters[inner_idx], alpha = round(alpha_val * 0.5), size = max(1, round(size_val * 0.5)), time = 0.3 SECONDS, easing = SINE_EASING)
	// Float up slightly
	animate(src, pixel_y = 4 + round(intensity * 8), time = 0.5 SECONDS, easing = SINE_EASING)

/obj/effect/abstract/bending_charge_aura/proc/fade_out()
	var/filter_idx = get_filter_index("charge_glow")
	if(filter_idx)
		animate(filters[filter_idx], alpha = 0, size = 0, time = 0.2 SECONDS)
	animate(src, alpha = 0, time = 0.2 SECONDS)
	QDEL_IN(src, 0.3 SECONDS)

// ─── CAST BURST ────────────────────────────────────────────────────
// A quick expanding ring effect on the caster when a spell is released.

/obj/effect/temp_visual/bending_cast_burst
	name = "elemental burst"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 6
	randomdir = 0
	alpha = 200

/obj/effect/temp_visual/bending_cast_burst/Initialize(mapload, color)
	. = ..()
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	// Start small, expand and fade
	transform = matrix(0.1, 0, 0, 0, 0.1, 0)
	animate(src, transform = matrix(0.8, 0, 0, 0, 0.8, 0), time = 0.3 SECONDS, easing = CUBIC_EASING)
	animate(alpha = 0, time = 0.2 SECONDS, easing = SINE_EASING)

// ─── IMPACT RING ───────────────────────────────────────────────────
// Expanding ring on spell hit location.

/obj/effect/temp_visual/bending_impact_ring
	name = "impact ring"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 8
	randomdir = 0
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/bending_impact_ring/Initialize(mapload, color, scale = 1.0)
	. = ..()
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	transform = matrix(0.2, 0, 0, 0, 0.2, 0)
	var/target_scale = 1.5 * scale
	animate(src, transform = matrix(target_scale, 0, 0, 0, target_scale, 0), time = 0.4 SECONDS, easing = CUBIC_EASING)
	animate(alpha = 0, time = 0.3 SECONDS, easing = SINE_EASING)

// ─── ELEMENTAL TRAIL ───────────────────────────────────────────────
// A trail of small effects left behind by dashes and projectiles.

/obj/effect/temp_visual/bending_trail
	name = "elemental trail"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 10
	randomdir = 0
	alpha = 180

/obj/effect/temp_visual/bending_trail/Initialize(mapload, color)
	. = ..()
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	// Shrink and fade
	transform = matrix(0.8, 0, 0, 0, 0.8, 0)
	animate(src, transform = matrix(0.2, 0, 0, 0, 0.2, 0), alpha = 0, time = 0.8 SECONDS, easing = SINE_EASING)

// ─── TERRAIN EFFECTS ───────────────────────────────────────────────
// Persistent ground effects that affect movement and provide visuals.

/// Fire trail — burns anyone who steps on it
/obj/effect/temp_visual/bending_fire_trail
	name = "fire trail"
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	light_outer_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	duration = 30
	randomdir = 0
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/bending_fire_trail/Initialize(mapload)
	. = ..()
	// Flicker animation
	animate(src, alpha = 200, time = 0.3 SECONDS, loop = -1, easing = SINE_EASING)
	animate(alpha = 255, time = 0.3 SECONDS, easing = SINE_EASING)

/obj/effect/temp_visual/bending_fire_trail/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.apply_damage(8, BURN, null, L.run_armor_check(null, "fire", damage = 8))
		L.visible_message(span_danger("[L] is burned by the fire trail!"), span_userdanger("The fire trail scorches my feet!"))

/// Ice floor — slippery, slows movement, can freeze
/obj/effect/temp_visual/bending_ice_floor
	name = "ice floor"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	light_outer_range = 1
	light_color = GLOW_COLOR_ICE
	duration = 50
	randomdir = 0
	alpha = 120

/obj/effect/temp_visual/bending_ice_floor/Initialize(mapload)
	. = ..()
	add_atom_colour(GLOW_COLOR_ICE, FIXED_COLOUR_PRIORITY)
	// Shimmer
	animate(src, alpha = 80, time = 1 SECONDS, loop = -1, easing = SINE_EASING)
	animate(alpha = 140, time = 1 SECONDS, easing = SINE_EASING)

/obj/effect/temp_visual/bending_ice_floor/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.Slowdown(2)
		if(prob(20))
			L.Knockdown(5)
			L.visible_message(span_danger("[L] slips on the ice!"), span_userdanger("I slip on the icy ground!"))

/// Earth spike — a visual spike that erupts from the ground
/obj/effect/temp_visual/bending_earth_spike
	name = "rock spike"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 15
	randomdir = 0
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/bending_earth_spike/Initialize(mapload, color)
	. = ..()
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	// Erupt from below: start small at bottom, grow upward
	transform = matrix(0.1, 0, 0, 0, 0.1, 0)
	pixel_y = -16
	animate(src, transform = matrix(1.0, 0, 0, 0, 1.5, 0), pixel_y = 0, time = 0.2 SECONDS, easing = CUBIC_EASING)
	// Then crumble back
	addtimer(CALLBACK(src, .proc/crumble), 0.8 SECONDS)

/obj/effect/temp_visual/bending_earth_spike/proc/crumble()
	animate(src, transform = matrix(0.3, 0, 0, 0, 0.3, 0), pixel_y = -8, alpha = 0, time = 0.3 SECONDS, easing = SINE_EASING)

/// Air gust — a visual swirl that expands outward
/obj/effect/temp_visual/bending_air_gust
	name = "air gust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 8
	randomdir = 0
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/bending_air_gust/Initialize(mapload, color)
	. = ..()
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	// Spin and expand
	transform = matrix(0.3, 0, 0, 0, 0.3, 0)
	var/matrix/M = matrix(1.5, 0, 0, 0, 1.5, 0)
	M.Turn(180)
	animate(src, transform = M, alpha = 0, time = 0.4 SECONDS, easing = CUBIC_EASING)

// ─── SCREEN EFFECTS ────────────────────────────────────────────────
// Full-screen overlays for the caster's client during bending.

/atom/movable/screen/fullscreen/bending_charge_overlay
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	alpha = 0
	plane = FULLSCREEN_PLANE
	layer = FULLSCREEN_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/element_color = "#FFFFFF"

/atom/movable/screen/fullscreen/bending_charge_overlay/Initialize(mapload, color)
	. = ..()
	if(color)
		element_color = color
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	// Edge vignette effect: scale up so only edges are visible
	transform = matrix(3, 0, 0, 0, 3, 0)
	pixel_x = -128
	pixel_y = -128

/atom/movable/screen/fullscreen/bending_charge_overlay/proc/show_intensity(val)
	alpha = round(val * 60) // Subtle — max 60 alpha

/atom/movable/screen/fullscreen/bending_charge_overlay/proc/fade_out()
	animate(src, alpha = 0, time = 0.3 SECONDS)
	QDEL_IN(src, 0.4 SECONDS)

// ─── HELPER PROCS ──────────────────────────────────────────────────

/// Create a charge aura on a mob and return it. Call set_intensity() during charge, fade_out() on release.
/proc/create_bending_charge_aura(mob/living/caster, element_color)
	if(!istype(caster))
		return null
	var/obj/effect/abstract/bending_charge_aura/aura = new(caster.loc, element_color)
	caster.vis_contents += aura
	return aura

/// Create a cast burst effect on a turf
/proc/create_bending_cast_burst(turf/T, element_color)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_cast_burst(T, element_color)

/// Create an impact ring on a turf
/proc/create_bending_impact_ring(turf/T, element_color, scale = 1.0)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_impact_ring(T, element_color, scale)

/// Create a trail effect on a turf
/proc/create_bending_trail(turf/T, element_color)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_trail(T, element_color)

/// Create a fire trail on a turf (burns people who cross it)
/proc/create_bending_fire_trail(turf/T)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_fire_trail(T)

/// Create an ice floor on a turf (slows and can knockdown)
/proc/create_bending_ice_floor(turf/T)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_ice_floor(T)

/// Create an earth spike visual on a turf
/proc/create_bending_earth_spike(turf/T, color = GLOW_COLOR_EARTHEN)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_earth_spike(T, color)

/// Create an air gust visual on a turf
/proc/create_bending_air_gust(turf/T, color = GLOW_COLOR_KINESIS)
	if(!T)
		return
	new /obj/effect/temp_visual/bending_air_gust(T, color)

/// Create a charge screen overlay on a mob's client
/proc/create_bending_charge_overlay(mob/living/caster, element_color)
	if(!istype(caster) || !caster.client)
		return null
	var/atom/movable/screen/fullscreen/bending_charge_overlay/overlay = new(null, element_color)
	caster.client.screen += overlay
	return overlay

/// Clean up a charge screen overlay from a mob's client
/proc/remove_bending_charge_overlay(mob/living/caster, atom/movable/screen/fullscreen/bending_charge_overlay/overlay)
	if(!caster || !caster.client || !overlay)
		return
	overlay.fade_out()
	addtimer(CALLBACK(src, .proc/remove_overlay_from_client, caster.client, overlay), 0.5 SECONDS)

/proc/remove_overlay_from_client(client/C, atom/movable/screen/overlay)
	if(!C || !overlay)
		return
	C.screen -= overlay
	qdel(overlay)

/// Create a line of effects between two turfs (for whip/line attacks)
/proc/create_bending_effect_line(turf/start, turf/end, element_color, effect_type = "trail")
	if(!start || !end)
		return
	var/turf/current = start
	var/dist = 0
	while(current && current != end && dist < 20)
		current = get_step(current, get_dir(current, end))
		dist++
		if(!current)
			break
		switch(effect_type)
			if("trail")
				create_bending_trail(current, element_color)
			if("fire")
				create_bending_fire_trail(current)
			if("ice")
				create_bending_ice_floor(current)
			if("spike")
				create_bending_earth_spike(current, element_color)
			if("gust")
				create_bending_air_gust(current, element_color)

/// Animate a mob being pushed/knocked back with a visual effect
/proc/bending_push_mob(mob/living/L, turf/from_turf, tiles = 1, damage = 0, damage_type = BRUTE, armor_type = "blunt")
	if(!L || !from_turf)
		return
	var/push_dir = get_dir(from_turf, L)
	var/turf/target_turf = get_turf(L)
	for(var/i in 1 to tiles)
		var/turf/next = get_step(target_turf, push_dir)
		if(!next || next.density)
			break
		target_turf = next
	// Animate the push
	animate(L, pixel_x = 0, pixel_y = 0, time = 0) // Reset
	var/offset_x = 0
	var/offset_y = 0
	switch(push_dir)
		if(NORTH)
			offset_y = 32 * tiles
		if(SOUTH)
			offset_y = -32 * tiles
		if(EAST)
			offset_x = 32 * tiles
		if(WEST)
			offset_x = -32 * tiles
		if(NORTHEAST)
			offset_x = 32 * tiles
			offset_y = 32 * tiles
		if(NORTHWEST)
			offset_x = -32 * tiles
			offset_y = 32 * tiles
		if(SOUTHEAST)
			offset_x = 32 * tiles
			offset_y = -32 * tiles
		if(SOUTHWEST)
			offset_x = -32 * tiles
			offset_y = -32 * tiles
	animate(L, pixel_x = offset_x, pixel_y = offset_y, time = 0.15 SECONDS, easing = CUBIC_EASING)
	animate(pixel_x = 0, pixel_y = 0, time = 0.15 SECONDS, easing = SINE_EASING)
	// Actually move them
	L.forceMove(target_turf)
	if(damage > 0)
		L.apply_damage(damage, damage_type, null, L.run_armor_check(null, armor_type, damage = damage))
