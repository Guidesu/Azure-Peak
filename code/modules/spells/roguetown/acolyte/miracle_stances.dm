// ═══════════════════════════════════════════════════════════════════
// DIVINE STANCES — Patron-specific martial forms for miracalists
// Each patron grants stances themed to their domain. Stances modify
// how miracles flow — healing power, damage, devotion cost, and tempo.
// Uses devotion instead of chi. Cycle with Shift+G, cast to assume.
// ═══════════════════════════════════════════════════════════════════

/// Base divine stance spell. Self-cast to enter; Shift+G to cycle.
/datum/action/cooldown/spell/miracle_stance
	name = "Divine Stance"
	desc = "Assume a stance of faith that shapes how your miracles flow. \
		Cycle stances with Shift+G. Each stance trades healing, damage, devotion cost, and tempo differently. \
		Only one stance may be active at a time."
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon_state = "solarflare"
	spell_color = "#ffd700"
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = 5

	invocation_type = INVOCATION_EMOTE
	charge_required = FALSE
	cooldown_time = 3 SECONDS
	shared_cooldown = "miracle_stance"

	associated_skill = /datum/skill/magic/holy
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_HUMAN
	has_visual_effects = FALSE

	/// Index into stances list
	var/stance_index = 1
	/// Currently active stance trait
	var/active_stance_trait
	/// All available stances. Subtypes override with patron-specific stances.
	var/list/stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0,
			"cooldown_mult" = 1.0,
			"heal_mult" = 1.0,
			"damage_mult" = 1.0,
		),
	)

/datum/action/cooldown/spell/miracle_stance/Grant(mob/grant_to)
	. = ..()
	update_stance_maptext(stances[stance_index]["label"])

/datum/action/cooldown/spell/miracle_stance/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/list/stance = stances[stance_index]
	var/new_trait = stance["trait"]

	// Remove old stance trait
	if(active_stance_trait && active_stance_trait != TRAIT_STANCE_NEUTRAL)
		REMOVE_TRAIT(H, active_stance_trait, "miracle_stance")

	// Show exit gesture
	if(active_stance_trait)
		H.visible_message(span_notice("[H] [stance["exit_gesture"]]."), span_notice("You [stance["exit_gesture"]]."))

	// Enter new stance
	if(new_trait != TRAIT_STANCE_NEUTRAL)
		ADD_TRAIT(H, new_trait, "miracle_stance")
	// Tempo stance also grants TRAIT_TEMPO so the real tempo system activates
	if(new_trait == TRAIT_STANCE_TEMPO)
		ADD_TRAIT(H, TRAIT_TEMPO, "miracle_stance")
	else
		REMOVE_TRAIT(H, TRAIT_TEMPO, "miracle_stance")
	active_stance_trait = new_trait

	// Show enter gesture
	H.visible_message(span_notice("[H] [stance["enter_gesture"]]."), span_notice("You [stance["enter_gesture"]]."))

	to_chat(H, span_notice("<b>Stance: [stance["label"]]</b> — [stance["desc"]]"))
	update_stance_maptext(stance["label"])
	return TRUE

/datum/action/cooldown/spell/miracle_stance/toggle_alt_mode(mob/user)
	stance_index = (stance_index % length(stances)) + 1
	var/list/stance = stances[stance_index]
	update_stance_maptext(stance["label"])
	to_chat(user, span_notice("Stance selected: [stance["label"]] — [stance["desc"]] (cast to assume)."))
	return TRUE

/// Called when a miracle is cast while a stance is active — tempo stance benefits from the real tempo system
/datum/action/cooldown/spell/miracle_stance/proc/on_miracle_cast(mob/living/carbon/human/H)
	if(!active_stance_trait || active_stance_trait == TRAIT_STANCE_NEUTRAL)
		return
	// Tempo stance uses the real tempo system (TRAIT_TEMPO) — bonuses are applied
	// automatically via get_tempo_bonus() in spell_cooldown.dm's get_adjusted_cost/cooldown
	if(active_stance_trait == TRAIT_STANCE_TEMPO && HAS_TRAIT(H, TRAIT_TEMPO))
		var/attacker_count = length(H.tempo_attackers)
		if(attacker_count >= TEMPO_ONE)
			to_chat(H, span_notice("The rhythm of battle flows through you — [attacker_count] foes, your miracles surge with tempo!"))

/// Get the tempo power bonus for miracle damage/healing — uses the real tempo system
/datum/action/cooldown/spell/miracle_stance/proc/get_tempo_power_bonus()
	if(!owner)
		return 1.0
	var/mob/living/L = owner
	return L.get_tempo_bonus(TEMPO_TAG_SPELL_POWER)

/datum/action/cooldown/spell/miracle_stance/proc/update_stance_maptext(label)
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

/datum/action/cooldown/spell/miracle_stance/Destroy()
	if(owner && active_stance_trait && active_stance_trait != TRAIT_STANCE_NEUTRAL)
		REMOVE_TRAIT(owner, active_stance_trait, "miracle_stance")
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_TEMPO, "miracle_stance")
	return ..()

// ═══════════════════════════════════════════════════════════════════
// AUXENTIUS — Sun, Law, Oaths, Kingship
// Solar stances: judgement, radiance, and protective light
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/auxentius
	name = "Solar Stance"
	desc = "Assume a stance of the Sun God. Solar stances channel Auxentius's light \
		into judgement, radiance, or protection. Cycle with Shift+G."
	button_icon_state = "solarflare"
	spell_color = "#ffd700"

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "Judgement",
			"trait" = TRAIT_STANCE_JUDGEMENT,
			"enter_gesture" = "assumes a commanding stance, one hand raised toward the sun, eyes blazing with conviction",
			"exit_gesture" = "lowers their hand, the solar conviction fading from their eyes",
			"desc" = "Smite focus. Miracle damage +30%, but healing -20% and devotion costs +15%. The Sun judges the wicked.",
			"cost_mult" = 1.15, "cooldown_mult" = 0.9, "heal_mult" = 0.8, "damage_mult" = 1.3,
		),
		list(
			"label" = "Radiance",
			"trait" = TRAIT_STANCE_DEVOUT,
			"enter_gesture" = "spreads their arms wide, head tilted upward as if bathing in divine light",
			"exit_gesture" = "folds their arms inward, the radiance dimming",
			"desc" = "Balanced radiance. Devotion costs -20%, cooldowns -10%. Sustained, efficient miracles.",
			"cost_mult" = 0.8, "cooldown_mult" = 0.9, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "Aegis of Light",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "crosses their arms before their chest in a protective gesture, golden light flickering around them",
			"exit_gesture" = "uncrosses their arms, the protective light fading",
			"desc" = "Protective mercy. Healing +25% and you take -10% damage, but miracle damage -20%. The Sun shields the faithful.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.1, "heal_mult" = 1.25, "damage_mult" = 0.8,
		),
		list(
			"label" = "Solar Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic swaying motion, hands tracing circles like the sun's path across the sky",
			"exit_gesture" = "stops the rhythmic swaying, the solar rhythm ending",
			"desc" = "Rhythmic faith. Each miracle cast builds tempo (+10% power per stack, max 5). Resets if you stop casting. The Sun's rhythm empowers you in battle.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// ABYSSOR / WULFRIC — Water, Ocean, Depths
// Tidal stances: flow, pressure, and the deep's crushing weight
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/abyssor
	name = "Tidal Stance"
	desc = "Assume a stance of the Sea God. Tidal stances channel Abyssor's ocean \
		into flow, pressure, or the crushing depths. Cycle with Shift+G."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_ICE

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "River's Flow",
			"trait" = TRAIT_STANCE_DEVOUT,
			"enter_gesture" = "flows into a gentle stance, arms circling like a river current, eyes calm as still water",
			"exit_gesture" = "lets the river current of their arms settle to stillness",
			"desc" = "Flowing faith. Devotion costs -25% and cooldowns -10%, but damage -15%. The river sustains.",
			"cost_mult" = 0.75, "cooldown_mult" = 0.9, "heal_mult" = 1.0, "damage_mult" = 0.85,
		),
		list(
			"label" = "Crushing Depth",
			"trait" = TRAIT_STANCE_JUDGEMENT,
			"enter_gesture" = "drops their weight low, arms pressing downward as if pushing against the pressure of the deep ocean",
			"exit_gesture" = "releases the downward pressure, the ocean's weight lifting",
			"desc" = "Crushing pressure. Miracle damage +35% and knockback increased, but devotion costs +25% and healing -30%. The deep crushes all.",
			"cost_mult" = 1.25, "cooldown_mult" = 1.1, "heal_mult" = 0.7, "damage_mult" = 1.35,
		),
		list(
			"label" = "Healing Tide",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "assumes a gentle rocking stance, hands cupped as if holding water, a serene expression on their face",
			"exit_gesture" = "opens their cupped hands, the healing water slipping through their fingers",
			"desc" = "Healing tide. Healing +40% and devotion costs -10%, but damage -30%. The sea nourishes life.",
			"cost_mult" = 0.9, "cooldown_mult" = 1.0, "heal_mult" = 1.4, "damage_mult" = 0.7,
		),
		list(
			"label" = "Tidal Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic back-and-forth sway, like the tide rolling in and out",
			"exit_gesture" = "stops the tidal swaying, the rhythm of the sea fading",
			"desc" = "Tidal rhythm. Each miracle builds tempo (+10% power per stack, max 5). The tide's rhythm empowers you in battle.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// MALUM / HANDWERRA — Fire, Smithing, Crafting
// Forge stances: heat, hammer, and the anvil's endurance
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/malum
	name = "Forge Stance"
	desc = "Assume a stance of the Forge God. Forge stances channel Malum's fire \
		into heat, the hammer's blow, or the anvil's endurance. Cycle with Shift+G."
	button_icon_state = "solarflare"
	spell_color = GLOW_COLOR_FIRE

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "Forge Heat",
			"trait" = TRAIT_STANCE_ZEALOUS,
			"enter_gesture" = "assumes a wide, aggressive stance, hands clenched as if gripping a hammer, fire flickering in their eyes",
			"exit_gesture" = "opens their clenched hands, the forge fire dimming",
			"desc" = "Aggressive heat. Miracle damage +25% and cooldowns -15%, but devotion costs +20% and healing -15%. The forge burns hot.",
			"cost_mult" = 1.2, "cooldown_mult" = 0.85, "heal_mult" = 0.85, "damage_mult" = 1.25,
		),
		list(
			"label" = "Anvil's Endurance",
			"trait" = TRAIT_STANCE_MARTYR,
			"enter_gesture" = "plants their feet firmly, crossing their arms before their chest like an anvil absorbing blows",
			"exit_gesture" = "uncrosses their arms, the anvil's endurance releasing",
			"desc" = "Martyr's endurance. Take -25% damage and healing +15%, but miracle damage -20%. The anvil endures what the hammer cannot.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.15, "heal_mult" = 1.15, "damage_mult" = 0.8,
		),
		list(
			"label" = "Smith's Mercy",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "shifts to a careful, precise stance, hands steady as a master craftsman's, eyes focused on their work",
			"exit_gesture" = "relaxes the craftsman's focus, the precision fading",
			"desc" = "Craftsman's care. Healing +30% and devotion costs -15%, but damage -20%. The smith mends what they could break.",
			"cost_mult" = 0.85, "cooldown_mult" = 1.0, "heal_mult" = 1.3, "damage_mult" = 0.8,
		),
		list(
			"label" = "Hammer Rhythm",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic hammering motion, fists alternating like a blacksmith striking hot steel",
			"exit_gesture" = "stops the hammering rhythm, the forge going quiet",
			"desc" = "Forge tempo. Each miracle builds tempo (+10% power per stack, max 5). The hammer's rhythm empowers you in battle.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// NECRA / MORWENNA — Death, Memory, Debt
// Sepulchral stances: stillness, finality, and the weight of memory
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/necra
	name = "Sepulchral Stance"
	desc = "Assume a stance of the Death Goddess. Sepulchral stances channel Necra's domain \
		into stillness, finality, or the weight of memory. Cycle with Shift+G."
	button_icon_state = "solarflare"
	spell_color = "#9a8c98"

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "Stillness",
			"trait" = TRAIT_STANCE_DEVOUT,
			"enter_gesture" = "stands perfectly still, hands folded in a funerary pose, eyes closed in contemplation of the dead",
			"exit_gesture" = "opens their eyes and unfolds their hands, the stillness breaking",
			"desc" = "Perfect stillness. Devotion costs -30% and cooldowns -5%, but damage -25%. Death is patient.",
			"cost_mult" = 0.7, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 0.75,
		),
		list(
			"label" = "Final Judgement",
			"trait" = TRAIT_STANCE_JUDGEMENT,
			"enter_gesture" = "assumes a rigid, upright stance, one hand extended in a commanding gesture of finality",
			"exit_gesture" = "lowers their commanding hand, the finality passing",
			"desc" = "Final judgement. Miracle damage +40% vs undead and +20% vs living, but healing -40%. Death claims all.",
			"cost_mult" = 1.2, "cooldown_mult" = 1.1, "heal_mult" = 0.6, "damage_mult" = 1.2,
		),
		list(
			"label" = "Memory's Weight",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "bows their head, hands pressed to their heart as if carrying the weight of remembered lives",
			"exit_gesture" = "lifts their head, the weight of memory lifting",
			"desc" = "Memory's mercy. Healing +35% and you gain devotion +20% faster, but damage -25%. The dead are remembered.",
			"cost_mult" = 0.9, "cooldown_mult" = 1.0, "heal_mult" = 1.35, "damage_mult" = 0.75,
		),
		list(
			"label" = "Funeral March",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a slow, deliberate rhythmic step, like a funeral procession — each step measured and solemn",
			"exit_gesture" = "stops the procession step, the march ending",
			"desc" = "Funeral tempo. Each miracle builds tempo (+10% power per stack, max 5). The march of the dead empowers you in battle.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// NOC / MILUSE — Night, Moon, Knowledge
// Lunar stances: shadow, wisdom, and the moon's phases
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/noc
	name = "Lunar Stance"
	desc = "Assume a stance of the Moon God. Lunar stances channel Noc's domain \
		into shadow, wisdom, or the moon's shifting phases. Cycle with Shift+G."
	button_icon_state = "solarflare"
	spell_color = "#c9b6e4"

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "New Moon",
			"trait" = TRAIT_STANCE_DEVOUT,
			"enter_gesture" = "assumes a shadowed stance, one hand raised to obscure their face as if cloaking themselves in darkness",
			"exit_gesture" = "lowers their hand, the shadow lifting from their face",
			"desc" = "Shadowed faith. Devotion costs -25%, cooldowns -15%, but damage -20%. The new moon hides power.",
			"cost_mult" = 0.75, "cooldown_mult" = 0.85, "heal_mult" = 1.0, "damage_mult" = 0.8,
		),
		list(
			"label" = "Full Moon",
			"trait" = TRAIT_STANCE_ZEALOUS,
			"enter_gesture" = "spreads their arms wide, head tilted back to catch moonlight, pale luminescence gathering around them",
			"exit_gesture" = "folds their arms, the pale luminescence fading",
			"desc" = "Full power. Miracle damage +25% and healing +15%, but devotion costs +25%. The full moon empowers all.",
			"cost_mult" = 1.25, "cooldown_mult" = 1.0, "heal_mult" = 1.15, "damage_mult" = 1.25,
		),
		list(
			"label" = "Waning Mercy",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "assumes a gentle, reclining stance, hands open-palmed as if offering moonlight to the wounded",
			"exit_gesture" = "closes their open palms, the moonlight withdrawing",
			"desc" = "Waning care. Healing +30% and cooldowns -10%, but damage -25%. The waning moon soothes.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.9, "heal_mult" = 1.3, "damage_mult" = 0.75,
		),
		list(
			"label" = "Lunar Cycle",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a slow, circular motion with their hands, tracing the moon's phases from new to full and back",
			"exit_gesture" = "stops the circular motion, the lunar cycle ending",
			"desc" = "Lunar tempo. Each miracle builds tempo (+10% power per stack, max 5). The moon's cycle empowers you in battle.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// GENERIC / CUSTODIUS — Undivided, Balance
// Balanced stances for any patron or undivided faithful
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/miracle_stance/undivided
	name = "Balanced Stance"
	desc = "Assume a stance of balanced faith. These stances are available to any faithful, \
		regardless of patron. Cycle with Shift+G."
	button_icon_state = "solarflare"
	spell_color = "#e0e0e0"

	stances = list(
		list(
			"label" = "Neutral",
			"trait" = TRAIT_STANCE_NEUTRAL,
			"enter_gesture" = "settles into a calm, prayerful stance, hands clasped before their chest",
			"exit_gesture" = "unclasp their hands and relax from prayer",
			"desc" = "Balanced faith. No bonuses or penalties.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.0, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
		list(
			"label" = "Devotion",
			"trait" = TRAIT_STANCE_DEVOUT,
			"enter_gesture" = "kneels briefly in prayer, then rises with hands open-palmed in supplication",
			"exit_gesture" = "closes their palms and settles from supplication",
			"desc" = "Devoted faith. Devotion costs -20% and cooldowns -10%, but all power -10%. Sustained, efficient miracles.",
			"cost_mult" = 0.8, "cooldown_mult" = 0.9, "heal_mult" = 0.9, "damage_mult" = 0.9,
		),
		list(
			"label" = "Zeal",
			"trait" = TRAIT_STANCE_ZEALOUS,
			"enter_gesture" = "assumes a fierce, forward-leaning stance, fists clenched and eyes burning with faith",
			"exit_gesture" = "unclenches their fists, the zealous fire cooling",
			"desc" = "Zealous faith. Miracle damage +20% and cooldowns -10%, but devotion costs +20% and healing -10%. Faith as a weapon.",
			"cost_mult" = 1.2, "cooldown_mult" = 0.9, "heal_mult" = 0.9, "damage_mult" = 1.2,
		),
		list(
			"label" = "Mercy",
			"trait" = TRAIT_STANCE_MERCIFUL,
			"enter_gesture" = "assumes a gentle, open stance, hands extended palm-up as if offering healing to all",
			"exit_gesture" = "withdraws their open hands, the mercy fading",
			"desc" = "Merciful faith. Healing +30% and devotion costs -10%, but damage -25%. Faith as a salve.",
			"cost_mult" = 0.9, "cooldown_mult" = 1.0, "heal_mult" = 1.3, "damage_mult" = 0.75,
		),
		list(
			"label" = "Martyr",
			"trait" = TRAIT_STANCE_MARTYR,
			"enter_gesture" = "crosses their arms over their chest in an X, head bowed in willing sacrifice",
			"exit_gesture" = "uncrosses their arms, the sacrifice ending",
			"desc" = "Martyr's faith. Take -20% damage and healing +20%, but miracle damage -25%. Endure for others.",
			"cost_mult" = 1.0, "cooldown_mult" = 1.1, "heal_mult" = 1.2, "damage_mult" = 0.75,
		),
		list(
			"label" = "Sacred Tempo",
			"trait" = TRAIT_STANCE_TEMPO,
			"enter_gesture" = "begins a rhythmic, swaying prayer motion, body rocking back and forth in sacred rhythm",
			"exit_gesture" = "stops the sacred swaying, the rhythm ending",
			"desc" = "Battle rhythm. The more foes attack you, the stronger and cheaper your miracles become. Tempo empowers all faith.",
			"cost_mult" = 1.0, "cooldown_mult" = 0.95, "heal_mult" = 1.0, "damage_mult" = 1.0,
		),
	)

// ═══════════════════════════════════════════════════════════════════
// HELPER — Grant the appropriate divine stance based on patron
// Call this from acolyte/priest/cleric setup after devotion is granted
// ═══════════════════════════════════════════════════════════════════

/proc/grant_miracle_stance(mob/living/carbon/human/H)
	if(!H?.mind?.has_spell(/datum/action/cooldown/spell/miracle_stance))
		var/stance_type = /datum/action/cooldown/spell/miracle_stance/undivided
		if(H.patron)
			switch(H.patron.type)
				if(/datum/patron/concordat/auxentius)
					stance_type = /datum/action/cooldown/spell/miracle_stance/auxentius
				if(/datum/patron/concordat/wulfric)
					stance_type = /datum/action/cooldown/spell/miracle_stance/abyssor
				if(/datum/patron/concordat/handwerra)
					stance_type = /datum/action/cooldown/spell/miracle_stance/malum
				if(/datum/patron/concordat/morwenna)
					stance_type = /datum/action/cooldown/spell/miracle_stance/necra
				if(/datum/patron/concordat/miluse)
					stance_type = /datum/action/cooldown/spell/miracle_stance/noc
				else
					stance_type = /datum/action/cooldown/spell/miracle_stance/undivided
		H.mind.AddSpell(new stance_type)
