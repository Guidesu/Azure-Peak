// CEV-Eris Sanity System — Adapted for DreamValley
// This system coexists with DreamValley's existing stress system.
// Stress handles short-term mood events; Sanity handles long-term mental health,
// breakdowns, and insight (character development through rest).

/datum/sanity
	/// Owner mob
	var/mob/living/carbon/human/owner

	/// Current sanity level (0-100, 100 = sane, 0 = breakdown)
	var/level
	/// Maximum sanity level
	var/max_level = 100
	/// Recent change in level — used for insight gain calculation
	var/level_change = 0

	/// Passive gain multiplier
	var/sanity_passive_gain_multiplier = 1
	/// If >0, sanity damage is ignored
	var/sanity_invulnerability = 0

	/// Insight — accumulated through rest and experiences, spent on stat growth
	var/insight
	/// Maximum insight (INFINITY by default)
	var/max_insight = INFINITY
	/// Insight gain multiplier
	var/insight_gain_multiplier = 1
	/// Passive insight gain multiplier
	var/insight_passive_gain_multiplier = 0.5
	/// Insight rest gain multiplier
	var/insight_rest_gain_multiplier = 1
	/// Current insight rest progress
	var/insight_rest = 0
	/// Maximum insight rest
	var/max_insight_rest = 1
	/// Whether the character is resting (fulfilling desires)
	var/resting = 0
	/// Maximum resting stages
	var/max_resting = 1

	/// Rest timer for the "here and now" prompt
	var/rest_timer_active = FALSE
	var/rest_timer_time

	/// Valid inspiration sources (oddities, artifacts)
	var/list/valid_inspirations = list(/obj/item/oddity)
	/// Current desires for rest fulfillment
	var/list/desires = list()
	/// Probability of positive breakdown (out of 100)
	var/positive_prob = 20
	/// Probability of negative breakdown (out of 100)
	var/negative_prob = 30

	/// Threshold for view damage to cap sanity loss
	var/view_damage_threshold = 20
	/// Environmental cognitohazard multiplier
	var/environment_cap_coeff = 1

	/// Cooldown timers
	var/say_time = 0
	var/breakdown_time = 0
	var/spook_time = 0

	/// Multiplier for death viewing
	var/death_view_multiplier = 1

	/// Active breakdowns
	var/list/datum/breakdown/breakdowns = list()

	/// How often onLife() effects fire and are multiplied
	var/life_tick_modifier = 2

/datum/sanity/New(mob/living/carbon/human/H)
	if(!istype(H))
		qdel(src)
		return
	owner = H
	level = max_level
	insight = rand(0, 30)
	START_PROCESSING(SSsanity, src)

/datum/sanity/Destroy()
	STOP_PROCESSING(SSsanity, src)
	QDEL_LIST(breakdowns)
	owner = null
	return ..()

/datum/sanity/proc/get_willpower()
	if(!owner)
		return STAT_BASELINE
	return owner.STAWIL

/// Change sanity level by a delta amount
/datum/sanity/proc/changeLevel(delta)
	if(!owner || sanity_invulnerability > 0)
		return
	if(delta < 0)
		// Apply willpower resistance to negative changes
		var/wil = get_willpower()
		var/resistance = (wil - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)
		delta *= (1.2 - resistance)
	level = clamp(level + delta, 0, max_level)
	level_change += delta

/// Restore sanity level
/datum/sanity/proc/restoreLevel(amount)
	changeLevel(amount)

/// Give insight points
/datum/sanity/proc/give_insight(value)
	if(!owner)
		return
	var/new_value = value
	if(value > 0)
		new_value = max(0, value * insight_gain_multiplier * GLOBAL_INSIGHT_MOD)
	insight = min(insight + new_value, max_insight)

/// Give resting progress
/datum/sanity/proc/give_resting(value)
	resting = min(resting + value, max_resting)

/// Give insight rest progress (from fulfilling desires)
/datum/sanity/proc/give_insight_rest(value)
	if(!owner)
		return
	var/new_value = value
	if(value > 0)
		new_value = max(0, value * insight_rest_gain_multiplier * GLOBAL_INSIGHT_MOD)
	insight_rest += new_value

/// Topic handler for the rest prompt
/datum/sanity/Topic(href, href_list)
	if(href_list["here_and_now"])
		if(rest_timer_active)
			rest_timer_active = FALSE
			level_up()

/// Main life processing — called from SSsanity
/datum/sanity/proc/onLife()
	if(!owner || owner.stat == DEAD)
		return
	handle_breakdowns()
	if(HAS_TRAIT(owner, TRAIT_NOMOOD))
		return
	var/affect = SANITY_PASSIVE_GAIN * sanity_passive_gain_multiplier
	if(owner.stat) // unconscious
		changeLevel(affect)
		return
	if(!owner.eye_blind)
		affect += handle_area()
		affect -= handle_view()
	changeLevel(max(affect * life_tick_modifier, min((view_damage_threshold * environment_cap_coeff) - level, 0)))
	handle_insight()
	handle_level()
	if(rest_timer_active)
		if(rest_timer_time > 0)
			rest_timer_time -= 2 SECONDS
		else
			rest_timer_active = FALSE
			level_up()

/// Process viewing unpleasant things in range
/datum/sanity/proc/handle_view()
	. = 0
	if(sanity_invulnerability > 0)
		return
	var/wil = get_willpower()
	for(var/atom/A in view(owner.client ? owner.client : owner))
		if(A.sanity_damage)
			. += SANITY_DAMAGE_VIEW(A.sanity_damage, wil, get_dist(owner, A))

/// Process area-based sanity effects
/datum/sanity/proc/handle_area()
	var/area/my_area = get_area(owner)
	if(!my_area)
		return 0
	// Areas can have a sanity_hazard var that affects sanity
	if(istype(my_area))
		. = my_area.sanity_hazard
		if(. < 0)
			var/wil = get_willpower()
			. *= (wil - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)

/// Update active breakdowns
/datum/sanity/proc/handle_breakdowns()
	for(var/datum/breakdown/B in breakdowns)
		if(!B.update())
			breakdowns -= B

/// Handle insight gain and rest progression
/datum/sanity/proc/handle_insight()
	give_insight(INSIGHT_GAIN(level_change) * insight_passive_gain_multiplier * life_tick_modifier * GLOBAL_INSIGHT_MOD)
	if(resting < max_resting && insight >= INSIGHT_REST_THRESHOLD)
		if(!rest_timer_active)
			give_resting(1)
			to_chat(owner, span_notice("You have gained insight. [resting ? "Now you need to rest and reflect." : "Your previous insight has been discarded, shifting your desires for new ones."]"))
			pick_desires()
			owner.playsound_local(get_turf(owner), 'sound/magic/ahh1.ogg', 100, 0, 8)

/// Handle sanity-level-based spooky effects
/datum/sanity/proc/handle_level()
	level_change = SANITY_CHANGE_FADEOFF(level_change)
	if(level < SANITY_THRESHOLD_SPOOK && world.time >= spook_time)
		spook_time = world.time + rand(1 MINUTES, 8 MINUTES) - (SANITY_THRESHOLD_SPOOK - level) * 1 SECONDS
		var/static/list/effects_40 = list(
			PROC_REF(effect_emote) = 25,
			PROC_REF(effect_quote) = 50
		)
		var/static/list/effects_30 = effects_40 + list(
			PROC_REF(effect_sound) = 1,
			PROC_REF(effect_whisper) = 25
		)
		var/static/list/effects_20 = effects_30 + list(
			PROC_REF(effect_hallucination) = 30
		)
		call(src, pickweight(level < SANITY_THRESHOLD_BAD ? (level < SANITY_THRESHOLD_CRITICAL ? effects_20 : effects_30) : effects_40))()

/// Trigger a breakdown when sanity hits 0
/datum/sanity/proc/check_breakdown()
	if(level > 0)
		return
	if(world.time < breakdown_time)
		return
	breakdown_time = world.time + SANITY_COOLDOWN_BREAKDOWN
	var/list/positive_types = subtypesof(/datum/breakdown/positive)
	var/list/negative_types = subtypesof(/datum/breakdown/negative)
	var/list/common_types = subtypesof(/datum/breakdown/common)
	var/is_positive = prob(positive_prob)
	var/chosen_type
	if(is_positive && positive_types.len)
		chosen_type = pick(positive_types)
	else if(negative_types.len)
		chosen_type = pick(negative_types)
	else if(common_types.len)
		chosen_type = pick(common_types)
	if(!chosen_type)
		return
	var/datum/breakdown/B = new chosen_type(src)
	if(!B.can_occur())
		qdel(B)
		// Try a negative one if positive failed
		if(is_positive && negative_types.len)
			chosen_type = pick(negative_types)
			B = new chosen_type(src)
			if(!B.can_occur())
				qdel(B)
				return
		else
			return
	if(B.occur())
		breakdowns += B
		restoreLevel(B.restore_sanity_pre)

/// Pick new desires for rest fulfillment
/datum/sanity/proc/pick_desires()
	desires = list()
	var/list/candidates = list(
		INSIGHT_DESIRE_FOOD,
		INSIGHT_DESIRE_ALCOHOL,
		INSIGHT_DESIRE_PRAYER,
		INSIGHT_DESIRE_MUSIC,
	)
	for(var/i = 0; i < INSIGHT_DESIRE_COUNT; i++)
		if(!candidates.len)
			break
		desires += pick_n_take(candidates)

/// Add rest progress from fulfilling a desire
/datum/sanity/proc/add_rest(type, amount)
	if(!(type in desires))
		amount /= 16
	give_insight_rest(amount)
	if(insight_rest >= INSIGHT_REST_THRESHOLD)
		insight_rest = 0
		finish_rest()

/// Complete rest — prompt for stat improvement
/datum/sanity/proc/finish_rest()
	desires = list()
	if(!rest_timer_active)
		to_chat(owner, "<font color='purple'>You have rested well.\
			<br>Select what you wish to do with your fulfilled insight <a HREF=?src=\ref[src];here_and_now=TRUE>here and now</a> or get to safety first if you are in danger.\
			<br>The prompt will appear in one minute.</font>")
		rest_timer_active = TRUE
		rest_timer_time = INSIGHT_REST_TIMER
		owner.playsound_local(get_turf(owner), 'sound/magic/ahh2.ogg', 100, 0, 8)

/// Level up — spend insight on stats
/datum/sanity/proc/level_up()
	rest_timer_active = FALSE
	if(!owner || !owner.mind)
		return
	var/rest = input(owner, "How would you like to improve yourself?", "Rest complete", null) in list(
		"Internalize your recent experiences",
		"Meditate on an oddity",
		"Save your insight for later"
	)
	if(rest == "Meditate on an oddity")
		var/oddity_found = FALSE
		for(var/obj/item/oddity/O in owner.contents)
			oddity_found = TRUE
			use_oddity(O)
			break
		if(!oddity_found)
			to_chat(owner, span_notice("You have no oddity to meditate on. Internalizing instead."))
			internalize_experience()
	else if(rest == "Internalize your recent experiences")
		internalize_experience()
	else
		to_chat(owner, span_notice("You hold onto your insight for now."))
	// Reset insight after spending
	insight = 0

/// Internalize experiences — gain a small stat boost
/datum/sanity/proc/internalize_experience()
	if(!owner)
		return
	var/list/stat_choices = list("Strength", "Perception", "Intelligence", "Constitution", "Willpower", "Speed", "Fortune")
	var/chosen = input(owner, "Which attribute to improve?", "Internalize", null) in stat_choices
	if(!chosen)
		return
	var/boost = 1
	apply_stat_boost(chosen, boost)
	to_chat(owner, span_green("You feel wiser. Your [chosen] has improved!"))
	restoreLevel(max_level)

/// Use an oddity for a stat boost — Eris-style scaling
/// Reads the oddity's oddity_stats list, doubles each value (like Eris),
/// and adds it to the owner's oddity_stat_bonuses layer.
/datum/sanity/proc/use_oddity(obj/item/oddity/O)
	if(!O || !owner)
		return
	if(!O.oddity_stats || !length(O.oddity_stats))
		// Fallback: no oddity_stats defined, give a small random boost
		var/list/stat_choices = list("Strength", "Perception", "Intelligence", "Constitution", "Willpower", "Speed", "Fortune")
		var/chosen = input(owner, "Which attribute to enhance with the oddity?", "Oddity Meditation", null) in stat_choices
		if(!chosen)
			return
		var/boost = rand(2, 4)
		apply_stat_boost(chosen, boost)
		to_chat(owner, span_green("The oddity resonates with you! Your [chosen] has increased by [boost]!"))
		restoreLevel(max_level)
		if(O.single_use)
			qdel(O)
		return
	// Eris-style: apply all stats from the oddity, doubled
	for(var/stat in O.oddity_stats)
		var/stat_up = O.oddity_stats[stat] * 2 // Eris doubles the value
		owner.add_oddity_stat_bonus(stat, stat_up)
		var/stat_name = pretty_stat_name(stat)
		if(stat_up > 0)
			to_chat(owner, span_green("Your [stat_name] goes up by [stat_up]!"))
		else if(stat_up < 0)
			to_chat(owner, span_danger("Your [stat_name] drains by [abs(stat_up)]!"))
		else
			to_chat(owner, span_notice("Your [stat_name] is unchanged."))
	to_chat(owner, span_green("The oddity resonates with you, reshaping your essence!"))
	restoreLevel(max_level)
	if(O.single_use)
		qdel(O)

/// Pretty-print a stat key as a readable name
/datum/sanity/proc/pretty_stat_name(stat)
	switch(stat)
		if(STAT_STRENGTH)
			return "Strength"
		if(STAT_PERCEPTION)
			return "Perception"
		if(STAT_INTELLIGENCE)
			return "Intelligence"
		if(STAT_CONSTITUTION)
			return "Constitution"
		if(STAT_WILLPOWER)
			return "Willpower"
		if(STAT_SPEED)
			return "Speed"
		if(STAT_FORTUNE)
			return "Fortune"
	return stat

/// Apply a stat boost to the owner via the oddity bonus layer
/datum/sanity/proc/apply_stat_boost(stat_name, amount)
	if(!owner)
		return
	var/stat_key
	switch(stat_name)
		if("Strength")
			stat_key = STAT_STRENGTH
		if("Perception")
			stat_key = STAT_PERCEPTION
		if("Intelligence")
			stat_key = STAT_INTELLIGENCE
		if("Constitution")
			stat_key = STAT_CONSTITUTION
		if("Willpower")
			stat_key = STAT_WILLPOWER
		if("Speed")
			stat_key = STAT_SPEED
		if("Fortune")
			stat_key = STAT_FORTUNE
	if(stat_key)
		owner.add_oddity_stat_bonus(stat_key, amount)

/// Take sanity damage from psychic/magical sources
/datum/sanity/proc/onPsyDamage(damage)
	var/wil = get_willpower()
	damage = apply_clothing_protection(damage)
	changeLevel(-SANITY_DAMAGE_PSY(damage, wil))
	if(level <= 0)
		check_breakdown()

/// Take sanity damage from body injury
/datum/sanity/proc/onHurt(damage)
	var/wil = get_willpower()
	damage = apply_clothing_protection(damage)
	changeLevel(-SANITY_DAMAGE_HURT(damage, wil))
	if(level <= 0)
		check_breakdown()

/// Take sanity damage from witnessing death
/datum/sanity/proc/onWitnessDeath()
	var/wil = get_willpower()
	changeLevel(-SANITY_DAMAGE_DEATH(wil))
	if(level <= 0)
		check_breakdown()

/// Get sanity level for HUD/external checks
/datum/sanity/proc/get_level()
	return level

/// Get insight for external checks
/datum/sanity/proc/get_insight()
	return insight
