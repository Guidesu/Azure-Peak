// ═══════════════════════════════════════════════════════════════════
// BENDING STANCES — Avatar-style martial arts forms
// Each element has distinct stances that modify how bending works.
// Stances are self-cast, swappable with Shift+G, and grant traits
// that affect spell cost, cooldown, speed, and defense.
// ═══════════════════════════════════════════════════════════════════

/// The base stance spell. Self-cast to enter a stance; Shift+G to cycle.
/// Only one stance may be active at a time. Entering a new stance replaces the old.
/datum/action/cooldown/spell/bending_stance
	name = "Bending Stance"
	desc = "Assume a martial arts stance that shapes how your bending flows. \
		Cycle stances with Shift+G. Each stance trades power, speed, defense, and efficiency differently. \
		Only one stance may be active at a time."
	button_icon = 'icons/mob/actions/mage_shared.dmi'
	button_icon_state = "form_blade"
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_ENERGY
	primary_resource_cost = 5

	invocation_type = INVOCATION_EMOTE
	charge_required = FALSE
	cooldown_time = 3 SECONDS
	shared_cooldown = "bending_stance"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	/// Index into stances list
	var/stance_index = 1
	/// Currently active stance trait (or null if none)
	var/active_stance_trait
	/// All available stances. Each: label, trait, gesture (enter), gesture (exit), desc
	/// Subtypes override this list with element-specific stances.
	var/list/stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a neutral ready stance, weight balanced",
			"exit_gesture" = "relaxes from their stance",
			"desc" = "Balanced. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
	)

/datum/action/cooldown/spell/bending_stance/Grant(mob/grant_to)
	. = ..()
	update_stance_maptext(stances[stance_index]["label"])

/datum/action/cooldown/spell/bending_stance/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/list/stance = stances[stance_index]
	var/new_trait = stance["trait"]

	// Remove old stance trait
	if(active_stance_trait && active_stance_trait != TRAIT_STANCE_NEUTRAL)
		REMOVE_TRAIT(H, active_stance_trait, "bending_stance")

	// Show exit gesture if we had a stance
	if(active_stance_trait)
		H.visible_message(span_notice("[H] [stance["exit_gesture"]]."), span_notice("You [stance["exit_gesture"]]."))

	// Enter new stance
	if(new_trait != TRAIT_STANCE_NEUTRAL)
		ADD_TRAIT(H, new_trait, "bending_stance")
	// Tempo stance also grants TRAIT_TEMPO so the real tempo system activates against NPCs
	if(new_trait == TRAIT_STANCE_TEMPO)
		ADD_TRAIT(H, TRAIT_TEMPO, "bending_stance")
	else
		REMOVE_TRAIT(H, TRAIT_TEMPO, "bending_stance")
	active_stance_trait = new_trait

	// Show enter gesture
	H.visible_message(span_notice("[H] [stance["enter_gesture"]]."), span_notice("You [stance["enter_gesture"]]."))

	to_chat(H, span_notice("<b>Stance: [stance["label"]]</b> — [stance["desc"]]"))
	update_stance_maptext(stance["label"])
	return TRUE

/datum/action/cooldown/spell/bending_stance/toggle_alt_mode(mob/user)
	stance_index = (stance_index % length(stances)) + 1
	var/list/stance = stances[stance_index]
	update_stance_maptext(stance["label"])
	to_chat(user, span_notice("Stance selected: [stance["label"]] — [stance["desc"]] (cast to assume)."))
	return TRUE

/datum/action/cooldown/spell/bending_stance/proc/update_stance_maptext(label)
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

/datum/action/cooldown/spell/bending_stance/Destroy()
	if(owner && active_stance_trait && active_stance_trait != TRAIT_STANCE_NEUTRAL)
		REMOVE_TRAIT(owner, active_stance_trait, "bending_stance")
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_TEMPO, "bending_stance")
	return ..()

/// Get the damage multiplier from the currently active stance (1.0 if no stance)
/datum/action/cooldown/spell/bending_stance/proc/get_damage_mult()
	if(!active_stance_trait || active_stance_trait == TRAIT_STANCE_NEUTRAL)
		return 1.0
	var/list/stance = stances[stance_index]
	return stance["damage_mult"] || 1.0

/// Get the cost multiplier from the currently active stance
/datum/action/cooldown/spell/bending_stance/proc/get_cost_mult()
	if(!active_stance_trait || active_stance_trait == TRAIT_STANCE_NEUTRAL)
		return 1.0
	var/list/stance = stances[stance_index]
	return stance["cost_mult"] || 1.0

/// Get the cooldown multiplier from the currently active stance
/datum/action/cooldown/spell/bending_stance/proc/get_cooldown_mult()
	if(!active_stance_trait || active_stance_trait == TRAIT_STANCE_NEUTRAL)
		return 1.0
	var/list/stance = stances[stance_index]
	return stance["cooldown_mult"] || 1.0

/// Global helper — find the active bending stance on a mob and return its damage multiplier
/proc/get_stance_damage_mult(mob/living/L)
	if(!L?.mind)
		return 1.0
	for(var/datum/action/cooldown/spell/bending_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_damage_mult()
	return 1.0

/// Global helper — find the active bending OR miracle stance and return its damage multiplier
/proc/get_any_stance_damage_mult(mob/living/L)
	if(!L?.mind)
		return 1.0
	for(var/datum/action/cooldown/spell/bending_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_damage_mult()
	for(var/datum/action/cooldown/spell/miracle_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_damage_mult()
	return 1.0

/// Global helper — find the active bending OR miracle stance and return its cost multiplier
/proc/get_any_stance_cost_mult(mob/living/L)
	if(!L?.mind)
		return 1.0
	for(var/datum/action/cooldown/spell/bending_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_cost_mult()
	for(var/datum/action/cooldown/spell/miracle_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_cost_mult()
	return 1.0

/// Global helper — find the active bending OR miracle stance and return its cooldown multiplier
/proc/get_any_stance_cooldown_mult(mob/living/L)
	if(!L?.mind)
		return 1.0
	for(var/datum/action/cooldown/spell/bending_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_cooldown_mult()
	for(var/datum/action/cooldown/spell/miracle_stance/stance in L.mind.spell_list)
		if(stance.active_stance_trait && stance.active_stance_trait != TRAIT_STANCE_NEUTRAL)
			return stance.get_cooldown_mult()
	return 1.0

// ═══════════════════════════════════════════════════════════════════
// FIRE STANCES — Northern Shaolin style
// Aggressive, forward-moving, fast strikes. Firebending is about
// power and initiative — press the attack, never give ground.
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/bending_stance/fire
	name = "Fire Stance"
	desc = "Assume a firebending stance from the Northern Shaolin tradition. \
		Fire stances emphasize aggression, speed, and overwhelming offense. \
		Cycle with Shift+G. Cast to assume the selected stance."
	button_icon_state = "form_blade"
	spell_color = GLOW_COLOR_FIRE
	attunement_school = ASPECT_NAME_PYROMANCY

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a neutral ready stance, weight balanced",
			"exit_gesture" = "relaxes from their stance",
			"desc" = "Balanced. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Flame Step",
			"trait" = TRAIT_STANCE_AGGRESSIVE,
			"enter_gesture" = "drops into a low forward stance, fists cocked at the hips like coiled springs",
			"exit_gesture" = "rises from the forward stance, the fire in their stance dimming",
			"desc" = "Aggressive. Faster cooldowns (+20%) and more damage (+15%), but chi costs +20% and you take +10% damage.",
			"cost_mult" = 1.2,
			"cooldown_mult" = 0.8,
			"damage_mult" = 1.15,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Dragon's Wrath",
			"trait" = TRAIT_STANCE_AGGRESSIVE,
			"enter_gesture" = "assumes a wide horse stance, arms spread like wings, chi flame rippling across their shoulders",
			"exit_gesture" = "closes their arms, the dragon's wings folding inward as the flame dies",
			"desc" = "All-out offense. Damage +30% and cooldowns -15%, but chi costs +40% and you take +25% damage. High risk, high reward.",
			"cost_mult" = 1.4,
			"cooldown_mult" = 0.85,
			"damage_mult" = 1.3,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Sun Guard",
			"trait" = TRAIT_STANCE_FLOWING,
			"enter_gesture" = "shifts to a side-on guard stance, one palm forward and one at the hip, flame flickering defensively",
			"exit_gesture" = "drops the guard, the defensive flame extinguishing",
			"desc" = "Defensive fire. Chi costs -15% and you take -10% damage, but damage -10% and cooldowns +10%.",
			"cost_mult" = 0.85,
			"cooldown_mult" = 1.1,
			"damage_mult" = 0.9,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Flame Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic, aggressive footwork pattern, each step sending a pulse of flame across the ground",
			"exit_gesture" = "stops the rhythmic footwork, the flame pulses dying",
			"desc" = "Battle rhythm. The more foes attack you, the stronger and cheaper your firebending becomes. Tempo empowers all bending.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// WATER STANCES — Tai Chi style
// Flowing, circular, redirective. Waterbending is about adaptation
// and turning the opponent's force against them.
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/bending_stance/water
	name = "Water Stance"
	desc = "Assume a waterbending stance from the Tai Chi tradition. \
		Water stances emphasize flow, redirection, and efficiency. \
		Cycle with Shift+G. Cast to assume the selected stance."
	button_icon_state = "form_blade"
	spell_color = GLOW_COLOR_ICE
	attunement_school = ASPECT_NAME_CRYOMANCY

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a neutral ready stance, weight balanced",
			"exit_gesture" = "relaxes from their stance",
			"desc" = "Balanced. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
		list(
			"label" = "River Flow",
			"trait" = TRAIT_STANCE_FLOWING,
			"enter_gesture" = "flows into a gentle Tai Chi stance, arms circling like a river current",
			"exit_gesture" = "lets the river current of their arms settle to stillness",
			"desc" = "Efficient flow. Chi costs -25% and cooldowns -10%, but damage -15%. Sustained bending.",
			"cost_mult" = 0.75,
			"cooldown_mult" = 0.9,
			"damage_mult" = 0.85,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Tidal Surge",
			"trait" = TRAIT_STANCE_AGGRESSIVE,
			"enter_gesture" = "shifts weight forward, arms sweeping upward like a rising wave",
			"exit_gesture" = "lets the wave subside, arms dropping to their sides",
			"desc" = "Building momentum. Damage +20% per consecutive cast (resets if you stop bending), but chi costs +15%.",
			"cost_mult" = 1.15,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0, // Base; the ramping is handled in cast
			"speed_bonus" = 0,
		),
		list(
			"label" = "Still Pool",
			"trait" = TRAIT_STANCE_ROOTED,
			"enter_gesture" = "settles into a perfectly still stance, weight sinking like water finding its level",
			"exit_gesture" = "ripples out of stillness, the calm surface breaking",
			"desc" = "Defensive calm. Take -25% damage and resist knockback, but cooldowns +20% and damage -10%. Tank waterbender.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.2,
			"damage_mult" = 0.9,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Tidal Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic back-and-forth sway, like the tide rolling in and out, each motion building momentum",
			"exit_gesture" = "stops the tidal swaying, the rhythm of the sea fading",
			"desc" = "Battle rhythm. The more foes attack you, the stronger and cheaper your waterbending becomes. Tempo empowers all bending.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// EARTH STANCES — Hung Gar style
// Rooted, solid, powerful. Earthbending is about standing your ground
// and hitting with the weight of a mountain.
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/bending_stance/earth
	name = "Earth Stance"
	desc = "Assume an earthbending stance from the Hung Gar tradition. \
		Earth stances emphasize rootedness, power, and endurance. \
		Cycle with Shift+G. Cast to assume the selected stance."
	button_icon_state = "form_blade"
	spell_color = GLOW_COLOR_EARTHEN
	attunement_school = ASPECT_NAME_GEOMANCY

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a neutral ready stance, weight balanced",
			"exit_gesture" = "relaxes from their stance",
			"desc" = "Balanced. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Mountain Root",
			"trait" = TRAIT_STANCE_ROOTED,
			"enter_gesture" = "drops into a deep horse stance, feet planting into the ground like roots into stone",
			"exit_gesture" = "lifts their feet from the deep stance, the earthen roots releasing",
			"desc" = "Immovable. Take -30% damage, immune to knockback, but cooldowns +25% and movement slowed. The mountain does not chase.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.25,
			"damage_mult" = 1.0,
			"speed_bonus" = -2,
		),
		list(
			"label" = "Boulder Crush",
			"trait" = TRAIT_STANCE_ROOTED,
			"enter_gesture" = "assumes a wide power stance, hands clenching as if gripping a boulder",
			"exit_gesture" = "opens their clenched hands, the boulder's weight releasing",
			"desc" = "Crushing power. Damage +35% but cooldowns +30% and chi costs +20%. Every hit is a finishing blow — if it lands.",
			"cost_mult" = 1.2,
			"cooldown_mult" = 1.3,
			"damage_mult" = 1.35,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Tremor Step",
			"trait" = TRAIT_STANCE_AGGRESSIVE,
			"enter_gesture" = "stomps forward into a lunging stance, the ground cracking beneath their feet",
			"exit_gesture" = "steps back from the lunge, the tremors settling",
			"desc" = "Mobile aggression. Cooldowns -15% and damage +10%, but you take +15% damage. Less rooted, more aggressive.",
			"cost_mult" = 1.1,
			"cooldown_mult" = 0.85,
			"damage_mult" = 1.1,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Quake Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic stomping pattern, each footfall sending a small tremor through the ground, building in intensity",
			"exit_gesture" = "stops the rhythmic stomping, the tremors settling to stillness",
			"desc" = "Battle rhythm. The more foes attack you, the stronger and cheaper your earthbending becomes. Tempo empowers all bending.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// AIR STANCES — Ba Gua style
// Evasive, circular, light. Airbending is about freedom and
// never being where the blow lands.
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/bending_stance/air
	name = "Air Stance"
	desc = "Assume an airbending stance from the Ba Gua tradition. \
		Air stances emphasize evasion, speed, and freedom of movement. \
		Cycle with Shift+G. Cast to assume the selected stance."
	button_icon_state = "form_blade"
	spell_color = GLOW_COLOR_KINESIS
	attunement_school = ASPECT_NAME_KINESIS

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a neutral ready stance, weight balanced",
			"exit_gesture" = "relaxes from their stance",
			"desc" = "Balanced. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
		list(
			"label" = "Wind Walker",
			"trait" = TRAIT_STANCE_EVASIVE,
			"enter_gesture" = "shifts weight to the balls of their feet, body swaying like a leaf in the wind",
			"exit_gesture" = "settles their weight back down, the leaf landing",
			"desc" = "Evasive. Movement speed +20%, chi costs -15%, but damage -20%. The wind cannot be grasped.",
			"cost_mult" = 0.85,
			"cooldown_mult" = 1.0,
			"damage_mult" = 0.8,
			"speed_bonus" = 2,
		),
		list(
			"label" = "Cyclone",
			"trait" = TRAIT_STANCE_AGGRESSIVE,
			"enter_gesture" = "begins circling their arms in wide spirals, air whipping around them into a vortex",
			"exit_gesture" = "stops the spiraling motion, the vortex dissipating",
			"desc" = "Whirling offense. Cooldowns -25% and damage +10%, but chi costs +25% and you take +15% damage. Relentless pressure.",
			"cost_mult" = 1.25,
			"cooldown_mult" = 0.75,
			"damage_mult" = 1.1,
			"speed_bonus" = 1,
		),
		list(
			"label" = "Cloud Drift",
			"trait" = TRAIT_STANCE_FLOWING,
			"enter_gesture" = "assumes a light, airy posture, weight barely touching the ground",
			"exit_gesture" = "lets their weight settle fully to the ground, the drift ending",
			"desc" = "Sustained flow. Chi costs -30% and cooldowns -5%, but damage -25%. For long, patient bending.",
			"cost_mult" = 0.7,
			"cooldown_mult" = 0.95,
			"damage_mult" = 0.75,
			"speed_bonus" = 1,
		),
		list(
			"label" = "Gale Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic circular motion, arms spiraling faster and faster like a building cyclone",
			"exit_gesture" = "slows the spiraling motion, the cyclone dissipating",
			"desc" = "Battle rhythm. The more foes attack you, the stronger and cheaper your airbending becomes. Tempo empowers all bending.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"damage_mult" = 1.0,
			"speed_bonus" = 0,
		),
	)
