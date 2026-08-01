// ═══════════════════════════════════════════════════════════════════
// BENDING FLOW SYSTEM — Chi momentum for benders
//
// Each bending cast builds Flow stacks. Flow decays if you stop bending.
// At high Flow, spells get empowered: bonus damage, reduced cost, extra effects.
// Different elements have separate Flow counters — switching elements resets Flow.
//
// Flow tiers:
//   0-2: No bonus
//   3-5: +15% damage, -10% cost (Flowing)
//   6-8: +30% damage, -20% cost, +1 tile range (Surging)
//   9+:  +50% damage, -30% cost, empowered effects (Overflowing)
//
// Flow is lost on: knockdown, stun, 8s of no bending, switching element.
// Overfilling past 10 causes a chi backlash — lose all flow + brief slow.
// ═══════════════════════════════════════════════════════════════════

#define BENDING_FLOW_FILTER "bending_flow_glow"
#define BENDING_FLOW_DECAY_DELAY (8 SECONDS)
#define BENDING_FLOW_DECAY_INTERVAL (4 SECONDS)
#define BENDING_FLOW_MAX 10
#define BENDING_FLOW_OVERFLOW_THRESHOLD 10
#define BENDING_FLOW_TIER_FLOWING 3
#define BENDING_FLOW_TIER_SURGING 6
#define BENDING_FLOW_TIER_OVERFLOWING 9

// Element identifiers for flow tracking
#define BENDING_ELEMENT_FIRE "fire"
#define BENDING_ELEMENT_WATER "water"
#define BENDING_ELEMENT_EARTH "earth"
#define BENDING_ELEMENT_AIR "air"

// Flow tier bonuses (multipliers)
#define BENDING_FLOW_DAMAGE_MULT_PER_TIER list(1.0, 1.15, 1.30, 1.50)
#define BENDING_FLOW_COST_MULT_PER_TIER list(1.0, 0.90, 0.80, 0.70)

/atom/movable/screen/alert/status_effect/buff/bending_flow
	name = "Bending Flow (0)"
	desc = "Consecutive bending builds Flow. Higher Flow = more damage, lower cost. \
		Stop bending for 8s and Flow decays. Get knocked down or stunned and it's gone. \
		Overfill past 10 and chi backlashes — you lose everything and get slowed."
	icon_state = "buff"

/datum/status_effect/buff/bending_flow
	id = "bending_flow"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bending_flow
	duration = -1
	tick_interval = 20
	status_type = STATUS_EFFECT_UNIQUE

	/// Current flow stacks (0-10)
	var/stacks = 0
	/// Which element we're flowing in (switching resets flow)
	var/current_element = null
	/// Last time we gained a stack
	var/last_gain_time = 0
	/// Last time we decayed a stack
	var/last_decay_time = 0
	/// Whether we're in chi backlash state
	var/is_backlashing = FALSE
	/// Element-specific glow colors
	var/static/list/element_colors = list(
		BENDING_ELEMENT_FIRE = GLOW_COLOR_FIRE,
		BENDING_ELEMENT_WATER = GLOW_COLOR_ICE,
		BENDING_ELEMENT_EARTH = GLOW_COLOR_EARTHEN,
		BENDING_ELEMENT_AIR = GLOW_COLOR_KINESIS,
	)

/datum/status_effect/buff/bending_flow/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_STATUS_STUN, PROC_REF(on_break))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_break))
	update_alert()
	update_visuals()

/datum/status_effect/buff/bending_flow/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN))
	owner.remove_filter(BENDING_FLOW_FILTER)
	. = ..()

/// Called when the bender is stunned or knocked down — lose all flow
/datum/status_effect/buff/bending_flow/proc/on_break()
	SIGNAL_HANDLER
	if(stacks <= 0)
		return
	reset_flow()
	to_chat(owner, span_warning("My concentration shatters — the flow is lost!"))

/// Add flow stacks from a bending cast. element = BENDING_ELEMENT_*
/datum/status_effect/buff/bending_flow/proc/add_flow(element, amount = 1)
	if(is_backlashing)
		return 0
	// Switching elements resets flow
	if(current_element && current_element != element)
		if(stacks > 0)
			to_chat(owner, span_notice("I shift my focus from [current_element] to [element] — the [current_element] flow dissipates."))
		stacks = 0
	current_element = element

	var/old_stacks = stacks
	stacks = min(stacks + amount, BENDING_FLOW_OVERFLOW_THRESHOLD + 2) // Allow slight overflow for backlash check
	last_gain_time = world.time

	// Check for chi backlash (overflow)
	if(stacks > BENDING_FLOW_OVERFLOW_THRESHOLD)
		chi_backlash()
		return 0

	stacks = min(stacks, BENDING_FLOW_MAX)
	if(stacks == old_stacks)
		return 0

	owner.balloon_alert(owner, "Flow: [stacks]/[BENDING_FLOW_MAX]")
	update_visuals()
	update_alert()

	// Tier-up messages
	var/old_tier = get_tier(old_stacks)
	var/new_tier = get_tier(stacks)
	if(new_tier > old_tier)
		on_tier_up(new_tier)

	return stacks - old_stacks

/// Get the flow tier (0=none, 1=flowing, 2=surging, 3=overflowing)
/datum/status_effect/buff/bending_flow/proc/get_tier(s = -1)
	if(s < 0)
		s = stacks
	if(s >= BENDING_FLOW_TIER_OVERFLOWING)
		return 3
	if(s >= BENDING_FLOW_TIER_SURGING)
		return 2
	if(s >= BENDING_FLOW_TIER_FLOWING)
		return 1
	return 0

/// Get damage multiplier based on current flow tier
/datum/status_effect/buff/bending_flow/proc/get_damage_mult()
	var/tier = get_tier()
	return BENDING_FLOW_DAMAGE_MULT_PER_TIER[tier + 1]

/// Get cost multiplier based on current flow tier
/datum/status_effect/buff/bending_flow/proc/get_cost_mult()
	var/tier = get_tier()
	return BENDING_FLOW_COST_MULT_PER_TIER[tier + 1]

/// Get bonus range from flow (surging+ gives +1 tile, overflowing gives +2)
/datum/status_effect/buff/bending_flow/proc/get_range_bonus()
	var/tier = get_tier()
	if(tier >= 3)
		return 2
	if(tier >= 2)
		return 1
	return 0

/// Consume flow stacks to empower a spell. Returns stacks consumed.
/datum/status_effect/buff/bending_flow/proc/consume_stacks(amount)
	var/consumed = min(stacks, amount)
	stacks = max(stacks - amount, 0)
	owner.balloon_alert(owner, "Flow: [stacks]/[BENDING_FLOW_MAX]")
	update_visuals()
	update_alert()
	return consumed

/// Reset all flow
/datum/status_effect/buff/bending_flow/proc/reset_flow()
	stacks = 0
	current_element = null
	owner.balloon_alert(owner, "Flow: 0/[BENDING_FLOW_MAX]")
	update_visuals()
	update_alert()

/// Chi backlash — overflow punishment
/datum/status_effect/buff/bending_flow/proc/chi_backlash()
	stacks = 0
	is_backlashing = TRUE
	current_element = null
	owner.balloon_alert(owner, "Flow: 0/[BENDING_FLOW_MAX]")
	update_visuals()
	update_alert()
	owner.Slowdown(3)
	// Visual: flash red and shake
	var/turf/T = get_turf(owner)
	if(T)
		new /obj/effect/temp_visual/kinetic_blast(T)
		playsound(T, 'sound/magic/vlightning.ogg', 60, TRUE)
	to_chat(owner, span_boldwarning("Chi surges beyond my control! The energy lashes back through my body!"))
	// Recover from backlash after 3 seconds
	addtimer(CALLBACK(src, .proc/recover_from_backlash), 3 SECONDS)

/datum/status_effect/buff/bending_flow/proc/recover_from_backlash()
	is_backlashing = FALSE
	to_chat(owner, span_notice("My chi settles. I can bend again."))

/// Called when flow tier increases
/datum/status_effect/buff/bending_flow/proc/on_tier_up(tier)
	switch(tier)
		if(1)
			to_chat(owner, span_notice("The flow builds within me — my bending grows stronger!"))
			playsound(get_turf(owner), 'sound/magic/charging.ogg', 25, TRUE)
		if(2)
			to_chat(owner, span_notice("I'm surging! Chi courses through every form!"))
			playsound(get_turf(owner), 'sound/magic/charging.ogg', 40, TRUE)
		if(3)
			to_chat(owner, span_warning("Overflowing! Every form is empowered — but don't lose control!"))
			playsound(get_turf(owner), 'sound/magic/charged.ogg', 50, TRUE)

/// Update the visual glow on the bender based on flow tier
/datum/status_effect/buff/bending_flow/proc/update_visuals()
	owner.remove_filter(BENDING_FLOW_FILTER)
	var/tier = get_tier()
	if(tier == 0)
		return
	var/color = current_element ? element_colors[current_element] : GLOW_COLOR_ARCANE
	var/alpha = 80 + (tier * 40) // 120, 160, 200
	var/size = tier // 1, 2, 3
	owner.add_filter(BENDING_FLOW_FILTER, 2, list("type" = "outline", "color" = color, "alpha" = alpha, "size" = size))
	// At overflowing, add a pulsing animation
	if(tier >= 3 && owner.filters)
		var/filter_idx = owner.get_filter_index(BENDING_FLOW_FILTER)
		if(filter_idx)
			animate(owner.filters[filter_idx], alpha = alpha + 40, time = 0.5 SECONDS, loop = -1, easing = SINE_EASING)
			animate(alpha = alpha - 20, time = 0.5 SECONDS, easing = SINE_EASING)

/datum/status_effect/buff/bending_flow/proc/update_alert()
	if(!linked_alert)
		return
	var/tier_name = list("Still", "Flowing", "Surging", "Overflowing")[get_tier() + 1]
	linked_alert.name = "Bending Flow ([stacks]/[BENDING_FLOW_MAX]) — [tier_name]"

/// Decay flow if we haven't bent in a while
/datum/status_effect/buff/bending_flow/tick()
	if(stacks <= 0 || is_backlashing)
		return
	if(world.time - last_gain_time < BENDING_FLOW_DECAY_DELAY)
		return
	if(world.time - last_decay_time < BENDING_FLOW_DECAY_INTERVAL)
		return
	last_decay_time = world.time
	stacks = max(stacks - 1, 0)
	owner.balloon_alert(owner, "Flow: [stacks]/[BENDING_FLOW_MAX]")
	update_visuals()
	update_alert()
	if(stacks == 0)
		current_element = null

// ─── Global helpers ─────────────────────────────────────────────────

/// Get the bending flow status effect on a mob (or null)
/proc/get_bending_flow(mob/living/target)
	if(!istype(target))
		return null
	return target.has_status_effect(/datum/status_effect/buff/bending_flow)

/// Get the flow damage multiplier for a mob (1.0 if no flow)
/proc/get_bending_flow_damage_mult(mob/living/L)
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		return 1.0
	return F.get_damage_mult()

/// Get the flow cost multiplier for a mob (1.0 if no flow)
/proc/get_bending_flow_cost_mult(mob/living/L)
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		return 1.0
	return F.get_cost_mult()

/// Get the flow range bonus for a mob (0 if no flow)
/proc/get_bending_flow_range_bonus(mob/living/L)
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		return 0
	return F.get_range_bonus()

/// Add flow to a mob from a bending cast. Creates the status effect if needed.
/proc/add_bending_flow(mob/living/L, element, amount = 1)
	if(!istype(L))
		return 0
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		F = L.apply_status_effect(/datum/status_effect/buff/bending_flow)
		if(!F)
			return 0
	return F.add_flow(element, amount)

/// Consume flow stacks from a mob. Returns amount consumed.
/proc/consume_bending_flow(mob/living/L, amount)
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		return 0
	return F.consume_stacks(amount)

/// Get current flow tier for a mob (0-3)
/proc/get_bending_flow_tier(mob/living/L)
	var/datum/status_effect/buff/bending_flow/F = get_bending_flow(L)
	if(!F)
		return 0
	return F.get_tier()

#undef BENDING_FLOW_FILTER
#undef BENDING_FLOW_DECAY_DELAY
#undef BENDING_FLOW_DECAY_INTERVAL
#undef BENDING_FLOW_MAX
#undef BENDING_FLOW_OVERFLOW_THRESHOLD
#undef BENDING_FLOW_TIER_FLOWING
#undef BENDING_FLOW_TIER_SURGING
#undef BENDING_FLOW_TIER_OVERFLOWING
#undef BENDING_FLOW_DAMAGE_MULT_PER_TIER
#undef BENDING_FLOW_COST_MULT_PER_TIER
