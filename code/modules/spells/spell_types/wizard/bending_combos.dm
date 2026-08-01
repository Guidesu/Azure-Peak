// ═══════════════════════════════════════════════════════════════════
// BENDING COMBO CHAIN SYSTEM — Element-specific combo sequences
//
// Tracks the last few forms cast by a bender. When a specific sequence
// is matched within the combo window, a bonus effect fires automatically.
//
// Combos are element-specific and form-based (not input-based like
// combo_core). Each element has 2-3 named combos with unique effects.
//
// Example: Fire Bolt → Fire Stream → Fire Bomb = "Cataclysm"
//          (all three effects fire in sequence, then a bonus explosion)
//
// The combo system is lightweight — it just tracks form labels and
// fires callbacks. The actual combo effects are defined in each
// bending spell file.
// ═══════════════════════════════════════════════════════════════════

#define BENDING_COMBO_WINDOW 6 SECONDS
#define BENDING_COMBO_MAX_HISTORY 5

/datum/bending_combo_rule
	/// Unique identifier for this combo
	var/combo_id
	/// Element this combo belongs to
	var/element
	/// Display name shown to the player
	var/name
	/// Description of the bonus effect
	var/desc
	/// Sequence of form labels that triggers this combo (in order)
	var/list/sequence
	/// Bonus flow stacks granted on combo completion
	var/flow_bonus = 3

/// Helper to create a combo rule without named args
/proc/make_combo_rule(id, elem, nme, dsc, seq, bonus)
	var/datum/bending_combo_rule/R = new
	R.combo_id = id
	R.element = elem
	R.name = nme
	R.desc = dsc
	R.sequence = seq
	R.flow_bonus = bonus
	return R

/// Global registry of bending combo rules, keyed by element
GLOBAL_LIST_EMPTY(bending_combo_rules)

/// Initialize the combo rule registry. Called once at world startup.
/proc/init_bending_combo_rules()
	if(length(GLOB.bending_combo_rules))
		return
	GLOB.bending_combo_rules = list(
		BENDING_ELEMENT_FIRE = list(),
		BENDING_ELEMENT_WATER = list(),
		BENDING_ELEMENT_EARTH = list(),
		BENDING_ELEMENT_AIR = list(),
	)

	// ─── FIRE COMBOS ───────────────────────────────────────────
	GLOB.bending_combo_rules[BENDING_ELEMENT_FIRE] += list(
		make_combo_rule("fire_cataclysm", BENDING_ELEMENT_FIRE, "Cataclysm", \
			"Fire Bolt -> Fire Stream -> Fire Bomb: Unleashes a massive bonus explosion at the last target.", \
			list("Fire Bolt", "Fire Stream", "Fire Bomb"), 4),
		make_combo_rule("fire_phoenix", BENDING_ELEMENT_FIRE, "Phoenix Rise", \
			"Ember Step -> Fire Shield -> Inferno: Erupts in a fiery rebirth, healing burn damage and releasing a massive inferno.", \
			list("Ember Step", "Fire Shield", "Inferno"), 5),
	)

	// ─── WATER COMBOS ──────────────────────────────────────────
	GLOB.bending_combo_rules[BENDING_ELEMENT_WATER] += list(
		make_combo_rule("water_glacier_chain", BENDING_ELEMENT_WATER, "Deep Freeze", \
			"Water Grab -> Frost Wave -> Glacier: The glacier is empowered, freezing all enemies solid.", \
			list("Water Grab", "Frost Wave", "Glacier"), 4),
		make_combo_rule("water_healing_wave", BENDING_ELEMENT_WATER, "Healing Wave", \
			"Ice Shard -> Healing Water -> Mist Form: Becomes a healing mist that heals all nearby allies.", \
			list("Ice Shard", "Healing Water", "Mist Form"), 3),
	)

	// ─── EARTH COMBOS ──────────────────────────────────────────
	GLOB.bending_combo_rules[BENDING_ELEMENT_EARTH] += list(
		make_combo_rule("earth_quake", BENDING_ELEMENT_EARTH, "Earthquake", \
			"Rock Spike -> Sinkhole -> Tremor: Creates a massive earthquake that knocks down everything in range.", \
			list("Rock Spike", "Sinkhole", "Tremor"), 4),
		make_combo_rule("earth_bullet", BENDING_ELEMENT_EARTH, "Bullet Storm", \
			"Gravel Spray -> Boulder -> Rock Hand: Fires a rapid barrage of boulders at the target.", \
			list("Gravel Spray", "Boulder", "Rock Hand"), 3),
	)

	// ─── AIR COMBOS ────────────────────────────────────────────
	GLOB.bending_combo_rules[BENDING_ELEMENT_AIR] += list(
		make_combo_rule("air_tempest", BENDING_ELEMENT_AIR, "Tempest", \
			"Air Blast -> Air Burst -> Tornado: Creates a massive cyclone that pulls in and batters all enemies.", \
			list("Air Blast", "Air Burst", "Tornado"), 4),
		make_combo_rule("air_suffocating_gust", BENDING_ELEMENT_AIR, "Suffocating Gust", \
			"Wind Step -> Air Blade -> Air Suffocate: The suffocation is empowered, dealing massive damage.", \
			list("Wind Step", "Air Blade", "Air Suffocate"), 4),
	)

// ─── COMBO TRACKER ─────────────────────────────────────────────────

/// Track bending form casts and check for combo matches.
/// Stored on the mob's mind as a simple list — no component needed.
/datum/bending_combo_tracker
	/// List of form labels recently cast, oldest first
	var/list/history = list()
	/// Last time a form was cast
	var/last_cast_time = 0
	/// Element of the current combo chain
	var/current_element = null

/// Register a form cast and check for combo matches.
/// Returns the matched combo rule or null.
/proc/register_bending_form_cast(mob/living/caster, element, form_label)
	if(!istype(caster) || !caster.mind)
		return null
	if(!length(GLOB.bending_combo_rules))
		init_bending_combo_rules()

	// Get or create the tracker on the mind
	if(!caster.mind.bending_combo_tracker)
		caster.mind.bending_combo_tracker = new /datum/bending_combo_tracker()
	var/datum/bending_combo_tracker/tracker = caster.mind.bending_combo_tracker

	// If the combo window has expired, reset history
	if(world.time - tracker.last_cast_time > BENDING_COMBO_WINDOW)
		tracker.history = list()
		tracker.current_element = null

	// If element changed, reset history
	if(tracker.current_element && tracker.current_element != element)
		tracker.history = list()

	tracker.current_element = element
	tracker.last_cast_time = world.time
	tracker.history += form_label

	// Trim history to max length
	if(length(tracker.history) > BENDING_COMBO_MAX_HISTORY)
		tracker.history = tracker.history.Copy(length(tracker.history) - BENDING_COMBO_MAX_HISTORY + 1)

	// Check for combo matches
	var/list/rules = GLOB.bending_combo_rules[element]
	if(!length(rules))
		return null

	// Check each rule — longest sequence first (so 3-length matches before 2-length)
	var/datum/bending_combo_rule/best_match = null
	var/best_length = 0
	for(var/datum/bending_combo_rule/rule in rules)
		if(length(rule.sequence) > length(tracker.history))
			continue
		// Check if the end of history matches the sequence
		var/start_idx = length(tracker.history) - length(rule.sequence) + 1
		var/matched = TRUE
		for(var/i in 1 to length(rule.sequence))
			if(tracker.history[start_idx + i - 1] != rule.sequence[i])
				matched = FALSE
				break
		if(matched && length(rule.sequence) > best_length)
			best_match = rule
			best_length = length(rule.sequence)

	if(best_match)
		// Consume the matched forms from history
		tracker.history = tracker.history.Copy(1, length(tracker.history) - best_length + 1)
		// Grant flow bonus
		add_bending_flow(caster, element, best_match.flow_bonus)
		// Notify the player
		to_chat(caster, span_boldnotice("<b>COMBO: [best_match.name]!</b> — [best_match.desc]"))
		playsound(get_turf(caster), 'sound/magic/charged.ogg', 60, TRUE)
		// Visual effect on caster
		var/color = get_bending_element_color(element)
		create_bending_cast_burst(get_turf(caster), color)
		create_bending_impact_ring(get_turf(caster), color, 2.0)

	return best_match

/// Get the element color for VFX
/proc/get_bending_element_color(element)
	switch(element)
		if(BENDING_ELEMENT_FIRE)
			return GLOW_COLOR_FIRE
		if(BENDING_ELEMENT_WATER)
			return GLOW_COLOR_ICE
		if(BENDING_ELEMENT_EARTH)
			return GLOW_COLOR_EARTHEN
		if(BENDING_ELEMENT_AIR)
			return GLOW_COLOR_KINESIS
	return GLOW_COLOR_ARCANE
