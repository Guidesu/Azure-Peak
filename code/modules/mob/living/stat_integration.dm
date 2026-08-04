/// Stat integration system — makes stats matter outside of combat.
/// Ported and adapted from CEV-Eris stat_holder design.
///
/// DreamValley already has 7 stats (STR/PER/INT/CON/WIL/SPD/LCK) with
/// buffers, statpacks, and combat hooks. This file adds:
/// 1. Utility procs for reading/modifying stats in non-combat contexts
/// 2. A universal action-time multiplier (get_stat_mult)
/// 3. Compound stat checks (min/max/sum/avg of multiple stats)
/// 4. A quality-tier stat check (stat_check) returning success + quality
/// 5. Convenience procs for common action categories


// ---------------------------------------------------------------------------
// Compound stat checks — read multiple stats at once
// ---------------------------------------------------------------------------

/// Returns the lowest value among the given list of stat keys.
/// Useful for checks that require multiple stats to all be sufficient.
/mob/living/proc/get_min_stat(list/stat_keys)
	if(!islist(stat_keys) || !length(stat_keys))
		return 0
	var/lowest = INFINITY
	for(var/key in stat_keys)
		var/val = get_stat(key)
		if(val < lowest)
			lowest = val
	return lowest

/// Returns the highest value among the given list of stat keys.
/// Useful for checks where any one strong stat is enough.
/mob/living/proc/get_max_stat(list/stat_keys)
	if(!islist(stat_keys) || !length(stat_keys))
		return 0
	var/highest = -INFINITY
	for(var/key in stat_keys)
		var/val = get_stat(key)
		if(val > highest)
			highest = val
	return highest

/// Returns the sum of the given stats.
/// Useful for broad competency checks.
/mob/living/proc/get_sum_stat(list/stat_keys)
	if(!islist(stat_keys) || !length(stat_keys))
		return 0
	var/sum = 0
	for(var/key in stat_keys)
		sum += get_stat(key)
	return sum

/// Returns the average (mean) of the given stats.
/// Useful for overall competency checks.
/mob/living/proc/get_avg_stat(list/stat_keys)
	if(!islist(stat_keys) || !length(stat_keys))
		return 0
	return get_sum_stat(stat_keys) / length(stat_keys)


// ---------------------------------------------------------------------------
// Universal action-time multiplier (ported from Eris getMult)
// ---------------------------------------------------------------------------

/// Returns a multiplier in the range [0, 1] based on how high the stat is
/// relative to stat_cap. A stat at STAT_BASELINE returns ~0.5, a stat at
/// stat_cap returns 0, and a stat at 0 returns 1.
///
/// Use this to reduce action delays based on stat:
///   delay = base_delay * get_stat_mult(STATKEY_INT, STAT_CEILING)
///
/// A character with 10 INT gets full delay, 15 INT gets 75% delay,
/// 20 INT gets 0% delay (instant for the stat-gated portion).
/mob/living/proc/get_stat_mult(stat_key, stat_cap = STAT_CEILING)
	var/val = get_stat(stat_key)
	if(!val)
		return 1
	return 1 - clamp(val / stat_cap, 0, 1)

/// Returns a speed multiplier > 1.0 for high stats, < 1.0 for low stats.
/// At STAT_BASELINE (10), returns 1.0 (no change).
/// Each point above baseline gives +5% speed, each below gives -5%.
/// Capped at 2.0x speed and 0.5x speed.
///
/// Use this when you want a smooth scaling rather than a hard gate:
///   crafting_time = base_time / get_stat_speed(STATKEY_INT)
/mob/living/proc/get_stat_speed(stat_key)
	var/val = get_stat(stat_key)
	var/diff = val - STAT_BASELINE
	return clamp(1.0 + (diff * 0.05), 0.5, 2.0)


// ---------------------------------------------------------------------------
// Quality-tier stat check
// ---------------------------------------------------------------------------

/// Performs a stat check and returns a quality tier (0-5).
///
/// Arguments:
///   stat_key - The stat to check (e.g. STATKEY_INT)
///   difficulty - The DC. At STAT_BASELINE (10), an equal DC gives ~50% success.
///   chance_per_point - % chance per stat point above difficulty (default 10%)
///
/// Returns STAT_QUALITY_FAILURE (0) on failure, or a quality tier 1-5 on success.
/// Higher stat margins produce higher quality results.
///
/// Example:
///   var/quality = stat_check(STATKEY_INT, 10)
///   if(quality >= STAT_QUALITY_GOOD)
///       // produce a high-quality item
/mob/living/proc/stat_check(stat_key, difficulty = STAT_BASELINE, chance_per_point = 10)
	var/val = get_stat(stat_key)
	var/margin = val - difficulty
	if(margin < 0)
		// Below difficulty — small chance to barely succeed
		if(prob(clamp(abs(margin) * chance_per_point / 2, 0, 30)))
			return STAT_QUALITY_POOR
		return STAT_QUALITY_FAILURE
	// At or above difficulty
	var/success_chance = clamp(50 + (margin * chance_per_point), 50, 95)
	if(!prob(success_chance))
		return STAT_QUALITY_FAILURE
	// Determine quality tier based on margin
	switch(margin)
		if(0 to 1)
			return STAT_QUALITY_AVERAGE
		if(2 to 3)
			return STAT_QUALITY_GOOD
		if(4 to 5)
			return STAT_QUALITY_EXCELLENT
		else
			return STAT_QUALITY_MASTERWORK

/// Multi-stat version of stat_check. Uses the best (max) of the given stats.
/// Useful for actions where multiple stats could contribute (e.g. crafting
/// could use either INT for careful work or STR for forceful work).
/mob/living/proc/stat_check_best(list/stat_keys, difficulty = STAT_BASELINE, chance_per_point = 10)
	return stat_check(stat_keys, difficulty, chance_per_point)

/// Multi-stat version of stat_check. Uses the weakest (min) of the given stats.
/// Useful for actions where all stats must be sufficient (e.g. surgery needs
/// both INT for knowledge and PER for steady hands).
/mob/living/proc/stat_check_all(list/stat_keys, difficulty = STAT_BASELINE, chance_per_point = 10)
	var/lowest = get_min_stat(stat_keys)
	var/margin = lowest - difficulty
	if(margin < 0)
		if(prob(clamp(abs(margin) * chance_per_point / 2, 0, 30)))
			return STAT_QUALITY_POOR
		return STAT_QUALITY_FAILURE
	var/success_chance = clamp(50 + (margin * chance_per_point), 50, 95)
	if(!prob(success_chance))
		return STAT_QUALITY_FAILURE
	switch(margin)
		if(0 to 1)
			return STAT_QUALITY_AVERAGE
		if(2 to 3)
			return STAT_QUALITY_GOOD
		if(4 to 5)
			return STAT_QUALITY_EXCELLENT
		else
			return STAT_QUALITY_MASTERWORK


// ---------------------------------------------------------------------------
// Convenience procs for common action categories
// ---------------------------------------------------------------------------

/// Returns the crafting speed multiplier for this mob.
/// Crafting is gated by INT (primary) and PER (secondary).
/// High INT = faster crafting, high PER = fewer mistakes.
/mob/living/proc/get_crafting_speed_mult()
	var/int_mult = get_stat_speed(STATKEY_INT)
	var/per_bonus = (get_stat(STATKEY_PER) - STAT_BASELINE) * 0.02
	return clamp(int_mult + per_bonus, 0.5, 2.5)

/// Returns the crafting quality modifier for this mob.
/// Higher = better quality results. Range: -2 to +3.
/mob/living/proc/get_crafting_quality_mod()
	var/int_val = get_stat(STATKEY_INT)
	var/per_val = get_stat(STATKEY_PER)
	return round((int_val - STAT_BASELINE) * 0.3 + (per_val - STAT_BASELINE) * 0.2)

/// Returns the surgery success chance modifier (0.0 to 1.0).
/// Surgery is gated by INT (knowledge) and PER (steady hands).
/// At baseline stats, returns 0.0 (no modifier). High stats add up to +0.3.
/mob/living/proc/get_surgery_success_mod()
	var/int_val = get_stat(STATKEY_INT)
	var/per_val = get_stat(STATKEY_PER)
	var/bonus = ((int_val - STAT_BASELINE) * 0.02) + ((per_val - STAT_BASELINE) * 0.01)
	return clamp(bonus, -0.3, 0.3)

/// Returns the surgery speed multiplier.
/// Higher INT = faster surgery. Range: 0.5x to 2.0x.
/mob/living/proc/get_surgery_speed_mult()
	return get_stat_speed(STATKEY_INT)

/// Returns the mining speed multiplier.
/// Mining is gated by STR (primary) and CON (endurance).
/mob/living/proc/get_mining_speed_mult()
	var	str_mult = get_stat_speed(STATKEY_STR)
	var/con_bonus = (get_stat(STATKEY_CON) - STAT_BASELINE) * 0.02
	return clamp(str_mult + con_bonus, 0.5, 2.5)

/// Returns the mining yield modifier. Higher = more ore per swing.
/// Range: -1 to +2 (added to base yield).
/mob/living/proc/get_mining_yield_mod()
	var/str_val = get_stat(STATKEY_STR)
	return round((str_val - STAT_BASELINE) * 0.15)

/// Returns the lumberjacking speed multiplier.
/// Lumberjacking is gated by STR (primary) and SPD (secondary).
/mob/living/proc/get_lumber_speed_mult()
	var	str_mult = get_stat_speed(STATKEY_STR)
	var	spd_bonus = (get_stat(STATKEY_SPD) - STAT_BASELINE) * 0.02
	return clamp(str_mult + spd_bonus, 0.5, 2.5)

/// Returns the alchemy quality modifier.
/// Alchemy is gated by INT (knowledge) and WIL (focus).
/// Range: -2 to +3.
/mob/living/proc/get_alchemy_quality_mod()
	var	int_val = get_stat(STATKEY_INT)
	var	wil_val = get_stat(STATKEY_WIL)
	return round((int_val - STAT_BASELINE) * 0.2 + (wil_val - STAT_BASELINE) * 0.15)

/// Returns the cooking quality modifier.
/// Cooking is gated by INT (technique) and PER (senses).
/// Range: -2 to +3.
/mob/living/proc/get_cooking_quality_mod()
	var	int_val = get_stat(STATKEY_INT)
	var	per_val = get_stat(STATKEY_PER)
	return round((int_val - STAT_BASELINE) * 0.15 + (per_val - STAT_BASELINE) * 0.2)

/// Returns the lockpicking success chance modifier.
/// Lockpicking is gated by PER (primary) and SPD (secondary).
/// Range: -0.3 to +0.3.
/mob/living/proc/get_lockpick_success_mod()
	var	per_val = get_stat(STATKEY_PER)
	var	spd_val = get_stat(STATKEY_SPD)
	var	bonus = ((per_val - STAT_BASELINE) * 0.02) + ((spd_val - STAT_BASELINE) * 0.01)
	return clamp(bonus, -0.3, 0.3)

/// Returns the lockpicking speed multiplier.
/// Range: 0.5x to 2.0x.
/mob/living/proc/get_lockpick_speed_mult()
	return get_stat_speed(STATKEY_SPD)

/// Returns the fishing success chance modifier.
/// Fishing is gated by PER (patience/observation) and LCK (luck).
/// Range: -0.2 to +0.2.
/mob/living/proc/get_fishing_success_mod()
	var	per_val = get_stat(STATKEY_PER)
	var	lck_val = get_stat(STATKEY_LCK)
	var	bonus = ((per_val - STAT_BASELINE) * 0.015) + ((lck_val - STAT_BASELINE) * 0.01)
	return clamp(bonus, -0.2, 0.2)

/// Returns the foraging success chance modifier.
/// Foraging is gated by PER (spotting) and INT (knowledge of plants).
/// Range: -0.2 to +0.2.
/mob/living/proc/get_foraging_success_mod()
	var	per_val = get_stat(STATKEY_PER)
	var	int_val = get_stat(STATKEY_INT)
	var	bonus = ((per_val - STAT_BASELINE) * 0.015) + ((int_val - STAT_BASELINE) * 0.01)
	return clamp(bonus, -0.2, 0.2)


// ---------------------------------------------------------------------------
// Temporary stat modifiers (timed buffs/debuffs)
// ---------------------------------------------------------------------------

/// Applies a temporary stat modifier that expires after a set duration.
/// Uses the existing change_stat system with a unique index.
/// Call remove_temp_stat with the same id to remove early.
///
/// Arguments:
///   stat_key - Which stat to modify
///   amount - How much to add (positive = buff, negative = debuff)
///   duration - How long in deciseconds (e.g. 30 SECONDS)
///   id - Unique identifier for this modifier
///
/// Example:
///   add_temp_stat(STATKEY_STR, 2, 60 SECONDS, "potion_strength")
/mob/living/proc/add_temp_stat(stat_key, amount, duration, id)
	if(!stat_key || !amount || !id)
		return
	// Remove any existing modifier with this id first
	remove_temp_stat(stat_key, id)
	// Apply the stat change
	change_stat(stat_key, amount, id)
	// Schedule removal
	addtimer(CALLBACK(src, PROC_REF(remove_temp_stat), stat_key, id), duration)

/// Removes a temporary stat modifier by id.
/mob/living/proc/remove_temp_stat(stat_key, id)
	if(!stat_key || !id)
		return
	// change_stat with amt=0 and index removes the indexed modifier
	change_stat(stat_key, 0, id)


// ---------------------------------------------------------------------------
// Stat display helpers
// ---------------------------------------------------------------------------

/// Returns a text description of a stat value for UI display.
/proc/stat_to_descriptor(val)
	switch(val)
		if(-INFINITY to 3)
			return "Abysmal"
		if(4 to 6)
			return "Poor"
		if(7 to 9)
			return "Below Average"
		if(10 to 11)
			return "Average"
		if(12 to 14)
			return "Above Average"
		if(15 to 17)
			return "Exceptional"
		if(18 to 20)
			return "Mythic"
		else
			return "Uncharted"

/// Returns a text description of a quality tier.
/proc/quality_to_text(quality)
	switch(quality)
		if(STAT_QUALITY_FAILURE)
			return "Failed"
		if(STAT_QUALITY_POOR)
			return "Poor"
		if(STAT_QUALITY_AVERAGE)
			return "Average"
		if(STAT_QUALITY_GOOD)
			return "Good"
		if(STAT_QUALITY_EXCELLENT)
			return "Excellent"
		if(STAT_QUALITY_MASTERWORK)
			return "Masterwork"
		else
			return "Unknown"
