// ═══════════════════════════════════════════════════════════════════
// AIRBENDING — Multi-form air & wind manipulation
// A single spell with many forms cycled via Shift+G.
// Each form is a different airbending technique:
//   - Air Blast: Single projectile, pushes back
//   - Air Blade: Cutting blade of compressed air
//   - Air Shield: Self-cast, deflects projectiles
//   - Wind Step: Dash to target, evasive
//   - Air Burst: AoE push around self, knocks back all foes
//   - Tornado: Create a tornado that pulls enemies in
//   - Air Suffocate: Targeted — crush the air from a foe's lungs
//   - Cloud Ride: Fly/levitate for a duration
//   - Whisper Wind: Send a message to a far-away target (utility)
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/airbending
	name = "Airbending"
	desc = "The art of commanding wind and air. Cycle forms with Shift+G — \
		each form is a different technique: air blast, air blade, air shield, \
		wind step, air burst, tornado, air suffocate, cloud ride, whisper wind. \
		Only limited by your creativity and chi."
	button_icon = 'icons/mob/actions/mage_kinesis.dmi'
	button_icon_state = "soulshot"
	spell_color = GLOW_COLOR_KINESIS
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_KINESIS

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
	shared_cooldown = "airbending"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/form_index = 1
	var/list/forms = list(
		list("label" = "Air Blast", "desc" = "Fire a blast of compressed air. Pushes enemies back, light damage, long range.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 4 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Air Blade", "desc" = "Launch a cutting blade of compressed air. High damage, piercing, medium range.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 5 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Air Shield", "desc" = "Wreathe yourself in a shield of swirling air. Deflects projectiles and reduces damage for 15 seconds. Self-cast.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 20 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Wind Step", "desc" = "Dash to target tile instantly, evading attacks. Leaves no trace. Pure mobility.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 5 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Air Burst", "desc" = "Release a shockwave of air around yourself. Knocks back and damages all nearby foes.", "cost" = SPELLCOST_MINOR_PROJECTILE, "cooldown" = 8 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Tornado", "desc" = "Summon a tornado at target location. Pulls enemies inward and batters them for 5 seconds.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 15 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "soulshot"),
		list("label" = "Air Suffocate", "desc" = "Pull the air from a target's lungs. High damage, silences, prevents speech. Lethal at close range.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 12 SECONDS, "charge" = CHARGETIME_MAJOR, "icon" = "soulshot"),
		list("label" = "Cloud Ride", "desc" = "Ride a cloud of air, levitating off the ground. Grants free movement over obstacles for 20 seconds. Self-cast.", "cost" = SPELLCOST_MAJOR_PROJECTILE, "cooldown" = 25 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
		list("label" = "Whisper Wind", "desc" = "Send a whispered message on the wind to any living target you can name. Utility — no damage.", "cost" = SPELLCOST_CANTRIP, "cooldown" = 5 SECONDS, "charge" = CHARGETIME_POKE, "icon" = "soulshot"),
	)

/datum/action/cooldown/spell/airbending/Grant(mob/grant_to)
	. = ..()
	apply_form(form_index)

/datum/action/cooldown/spell/airbending/proc/apply_form(index)
	var/list/form = forms[index]
	primary_resource_cost = form["cost"]
	cooldown_time = form["cooldown"]
	charge_time = form["charge"]
	button_icon_state = form["icon"]
	build_all_button_icons()
	update_form_maptext(form["label"])

/datum/action/cooldown/spell/airbending/toggle_alt_mode(mob/user)
	form_index = (form_index % length(forms)) + 1
	apply_form(form_index)
	var/list/form = forms[form_index]
	to_chat(user, span_notice("<b>Airbending: [form["label"]]</b> — [form["desc"]]"))
	return TRUE

/datum/action/cooldown/spell/airbending/cast(atom/cast_on)
	..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/list/form = forms[form_index]
	// ── Bending Flow: gain flow stacks on cast ──
	add_bending_flow(H, BENDING_ELEMENT_AIR, 1)
	// ── Bending Combo: register form cast for combo tracking ──
	register_bending_form_cast(H, BENDING_ELEMENT_AIR, form["label"])
	// ── VFX: cast burst on caster ──
	create_bending_cast_burst(get_turf(H), GLOW_COLOR_KINESIS)
	switch(form["label"])
		if("Air Blast")
			return cast_air_blast(H, cast_on)
		if("Air Blade")
			return cast_air_blade(H, cast_on)
		if("Air Shield")
			return cast_air_shield(H)
		if("Wind Step")
			return cast_wind_step(H, cast_on)
		if("Air Burst")
			return cast_air_burst(H)
		if("Tornado")
			return cast_tornado(H, cast_on)
		if("Air Suffocate")
			return cast_air_suffocate(H, cast_on)
		if("Cloud Ride")
			return cast_cloud_ride(H)
		if("Whisper Wind")
			return cast_whisper_wind(H)
	return TRUE

// ─── FORM IMPLEMENTATIONS ───────────────────────────────────────────

/datum/action/cooldown/spell/airbending/proc/cast_air_blast(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] thrusts both palms forward, blasting a torrent of air!"), span_notice("I blast a torrent of air!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	var/obj/projectile/magic/soulshot/proj = new /obj/projectile/magic/soulshot(get_turf(H))
	proj.damage = round(25 * get_bending_flow_damage_mult(H))
	proj.range = 12 + get_bending_flow_range_bonus(H)
	proj.fire(dir2angle(dir))
	// VFX: air gust at target
	addtimer(CALLBACK(GLOBAL_PROC, .proc/create_bending_air_gust, T, GLOW_COLOR_KINESIS), 0.3 SECONDS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_air_blade(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	var/dir = get_dir(H, T)
	H.visible_message(span_warning("[H] slashes through the air, sending a cutting blade of wind!"), span_notice("I launch a blade of compressed air!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 50, TRUE)
	var/obj/projectile/energy/airblade/proj = new /obj/projectile/energy/airblade(get_turf(H))
	proj.damage = round(40 * get_bending_flow_damage_mult(H))
	proj.range = 10 + get_bending_flow_range_bonus(H)
	proj.fire(dir2angle(dir))
	// VFX: air gust at target
	addtimer(CALLBACK(GLOBAL_PROC, .proc/create_bending_air_gust, T, GLOW_COLOR_KINESIS), 0.3 SECONDS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_air_shield(mob/living/carbon/human/H)
	H.visible_message(span_notice("[H] is wreathed in a swirling shield of air!"), span_notice("I create a shield of swirling air around me."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	ADD_TRAIT(H, "air_shield_buff", "airbending")
	H.add_atom_colour(GLOW_COLOR_KINESIS, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, .proc/remove_air_shield, H), 15 SECONDS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/remove_air_shield(mob/living/carbon/human/H)
	if(H)
		REMOVE_TRAIT(H, "air_shield_buff", "airbending")
		H.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

/datum/action/cooldown/spell/airbending/proc/cast_wind_step(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 10)
		to_chat(H, span_warning("Too far to wind step there."))
		return FALSE
	H.visible_message(span_notice("[H] vanishes in a gust of wind and reappears elsewhere!"), span_notice("I step on the wind and appear at my target."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	create_bending_air_gust(get_turf(H), GLOW_COLOR_KINESIS)
	H.forceMove(T)
	create_bending_air_gust(T, GLOW_COLOR_KINESIS)
	create_bending_cast_burst(T, GLOW_COLOR_KINESIS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_air_burst(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] claps both hands together, releasing a shockwave of air!"), span_notice("I release a shockwave of air!"))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 80, TRUE)
	for(var/mob/living/L in range(4, H))
		if(L == H)
			continue
		var/dist = get_dist(H, L)
		var/damage = max(round((25 - (dist * 5)) * get_bending_flow_damage_mult(H)), 8)
		L.apply_damage(damage, BRUTE, null, L.run_armor_check(null, "blunt", damage = damage))
		L.Knockdown(10)
		// Push away from caster
		var/push_dir = get_dir(H, L)
		var/turf/push_to = get_step(L, push_dir)
		if(push_to)
			L.forceMove(push_to)
		L.visible_message(span_danger("[L] is thrown back by the shockwave!"), span_userdanger("A shockwave of air slams into me!"))
	// VFX: expanding air ring
	create_bending_impact_ring(get_turf(H), GLOW_COLOR_KINESIS, 2.0)
	create_bending_air_gust(get_turf(H), GLOW_COLOR_KINESIS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_tornado(mob/living/carbon/human/H, atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(get_dist(H, T) > 7)
		to_chat(H, span_warning("Too far to summon a tornado there."))
		return FALSE
	H.visible_message(span_warning("[H] spirals their arms, summoning a tornado!"), span_notice("I summon a tornado!"))
	playsound(T, 'sound/magic/vlightning.ogg', 80, TRUE)
	// Pull enemies toward the center and damage them
	for(var/mob/living/L in range(4, T))
		if(L == H)
			continue
		var/pull_dir = get_dir(L, T)
		var/turf/pull_to = get_step(L, pull_dir)
		if(pull_to)
			L.forceMove(pull_to)
		L.apply_damage(round(20 * get_bending_flow_damage_mult(H)), BRUTE, null, L.run_armor_check(null, "blunt", damage = 20))
		L.Knockdown(15)
		L.visible_message(span_danger("[L] is caught in the tornado!"), span_userdanger("A tornado whips me around!"))
	// VFX: expanding air ring + gust
	create_bending_impact_ring(T, GLOW_COLOR_KINESIS, 2.5)
	create_bending_air_gust(T, GLOW_COLOR_KINESIS)
	consume_bending_flow(H, 2)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_air_suffocate(mob/living/carbon/human/H, atom/target)
	if(!isliving(target))
		to_chat(H, span_warning("Air suffocate can only target living beings."))
		return FALSE
	var/mob/living/L = target
	if(get_dist(H, L) > 7)
		to_chat(H, span_warning("Too far to pull the air from their lungs."))
		return FALSE
	H.visible_message(span_warning("[H] clenches a fist at [L], and the air around them vanishes!"), span_notice("I pull the air from [L]'s lungs!"))
	playsound(get_turf(L), 'sound/magic/vlightning.ogg', 50, TRUE)
	L.apply_damage(round(45 * get_bending_flow_damage_mult(H)), OXY, null, forced = TRUE)
	L.apply_damage(round(15 * get_bending_flow_damage_mult(H)), BRUTE, null, L.run_armor_check(null, "blunt", damage = 15))
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.silent = max(C.silent, 50)
	L.visible_message(span_danger("[L] gasps and clutches their throat, unable to breathe!"), span_userdanger("The air is pulled from my lungs — I can't breathe!"))
	// VFX: air gust swirling around the target
	create_bending_air_gust(get_turf(L), GLOW_COLOR_KINESIS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/cast_cloud_ride(mob/living/carbon/human/H)
	H.visible_message(span_notice("[H] rises into the air on a cushion of wind!"), span_notice("I ride the air, lifting off the ground."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 40, TRUE)
	ADD_TRAIT(H, "cloud_ride_buff", "airbending")
	H.add_atom_colour(GLOW_COLOR_KINESIS, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, .proc/remove_cloud_ride, H), 20 SECONDS)
	return TRUE

/datum/action/cooldown/spell/airbending/proc/remove_cloud_ride(mob/living/carbon/human/H)
	if(H)
		REMOVE_TRAIT(H, "cloud_ride_buff", "airbending")
		H.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

/datum/action/cooldown/spell/airbending/proc/cast_whisper_wind(mob/living/carbon/human/H)
	var/message = input(H, "What message do you wish to send on the wind?", "Whisper Wind") as text|null
	if(!message)
		return FALSE
	var/target_name = input(H, "To whom do you send this whisper? (Enter their name)", "Whisper Wind") as text|null
	if(!target_name)
		return FALSE
	H.visible_message(span_notice("[H] whispers into their palm and releases it to the wind."), span_notice("I send a whisper on the wind to [target_name]..."))
	playsound(get_turf(H), 'sound/magic/vlightning.ogg', 20, TRUE)
	for(var/mob/living/M in GLOB.mob_list)
		if(M == H)
			continue
		if(findtext(M.real_name, target_name) || findtext(M.name, target_name))
			to_chat(M, span_notice("<i>A whisper on the wind reaches your ears: \"[message]\"</i>"))
			to_chat(H, span_notice("Your whisper reaches [M.name]."))
			return TRUE
	to_chat(H, span_warning("The wind could not find [target_name]."))
	return TRUE

/datum/action/cooldown/spell/airbending/proc/update_form_maptext(label)
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
