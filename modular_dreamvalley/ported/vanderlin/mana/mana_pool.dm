// ==========================================================================================
// VANDERLIN MANA PORT - Core mana_pool datum
// Ported and simplified from OpenKeep/Vanderlin's code/datums/mana/mana_pool.dm.
//
// A mana_pool is an abstract reservoir of magical energy that can live on any atom/movable
// (a mob, an item/battery, etc). It is a self-contained numeric resource, entirely separate
// from and additive to this repo's existing spell recharge_time/stamina/devotion costs.
//
// PUBLIC API (for other systems, e.g. the enchantment/runeword port, to call):
//   /datum/mana_pool/proc/adjust_mana(amount)                  -> adjusts amount, clamped to [0, maximum_mana_capacity]. Returns the amount actually applied.
//   /datum/mana_pool/proc/get_amount()                         -> current stored mana.
//   /datum/mana_pool/proc/get_max_mana()                       -> maximum_mana_capacity.
//   /datum/mana_pool/proc/get_softcap()                        -> current softcap (baseline, not stat-scaled by default; mob pools override this).
//   /datum/mana_pool/proc/has_mana(amount)                     -> TRUE if amount <= current amount.
//   /datum/mana_pool/proc/set_max_mana(new_max, change_amount) -> changes maximum_mana_capacity (and softcap proportionally). Used by mana_capacity-type enchantments.
//   /datum/mana_pool/proc/set_regen_rate(new_rate)              -> sets ethereal_recharge_rate (mana/second passive regen). Used by mana_regeneration-type enchantments.
//   /datum/mana_pool/proc/get_regen_rate()                      -> current ethereal_recharge_rate.
//   /datum/mana_pool/proc/get_percent_to_max()                  -> 0-100.
// Signals sent:
//   COMSIG_MANA_POOL_ADJUSTED (amount_changed, src)   - sent to parent atom whenever amount changes.
// ==========================================================================================

/// An abstract representation of a reservoir of mana. Lives on an atom/movable via that atom's `mana_pool` var.
/datum/mana_pool
	/// The atom/movable that owns this pool (a mob, a battery item, etc).
	var/atom/movable/parent = null

	/// The absolute maximum amount of mana this pool can ever hold.
	var/maximum_mana_capacity = BASE_MANA_CAPACITY
	/// Current stored mana. Never goes below 0 or above maximum_mana_capacity.
	var/amount = 0
	/// The threshold above which mana begins exponentially decaying back down every process tick.
	var/softcap = 0
	/// Divisor for the exponential decay curve above softcap. Lower = steeper/faster decay.
	var/exponential_decay_divisor = BASE_MANA_EXPONENTIAL_DIVISOR

	/// Passive ("ethereal") mana regen per second. Comes from nowhere - simple time-based regen. Set via set_regen_rate().
	var/ethereal_recharge_rate = 0

	/// The overload threshold (absolute value). Above this, the holder starts taking mana backlash each tick.
	var/mana_overload_threshold = 0
	/// Whether we are currently in an overloaded state (used to only send the backlash message/effect once per overload).
	var/mana_overloaded = FALSE

	/// World time of the next allowed "feeling tingly" overload warning message, to avoid spam.
	var/next_overload_message = 0

	VAR_PRIVATE/is_processing = FALSE

/datum/mana_pool/New(atom/movable/new_parent = null)
	. = ..()
	if(!softcap)
		softcap = maximum_mana_capacity * BASE_MANA_SOFTCAP_MULT
	if(!mana_overload_threshold)
		mana_overload_threshold = maximum_mana_capacity * BASE_MANA_OVERLOAD_THRESHOLD_MULT
	set_parent(new_parent)
	update_processing_state()

/datum/mana_pool/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	if(parent)
		if(parent.mana_pool == src)
			parent.mana_pool = null
		parent = null
	return ..()

/datum/mana_pool/proc/set_parent(atom/movable/new_parent)
	parent = new_parent

/// Returns TRUE if this pool needs to keep processing (has passive regen headroom, or is over softcap and needs to decay).
/datum/mana_pool/proc/needs_processing()
	if(ethereal_recharge_rate != 0 && amount < get_softcap())
		return TRUE
	if(amount > get_softcap())
		return TRUE
	return FALSE

/datum/mana_pool/proc/update_processing_state()
	var/should_process = needs_processing()
	if(should_process && !is_processing)
		is_processing = TRUE
		START_PROCESSING(SSfastprocess, src)
	else if(!should_process && is_processing)
		is_processing = FALSE
		STOP_PROCESSING(SSfastprocess, src)

/datum/mana_pool/process(seconds_per_tick)
	if(ethereal_recharge_rate != 0 && amount < get_softcap())
		adjust_mana(ethereal_recharge_rate * seconds_per_tick * get_environment_regen_mult())

	if(amount > get_softcap())
		// Exponential decay back toward softcap - the higher over softcap we are, the faster we bleed off.
		var/overflow = amount - get_softcap()
		var/decay = min(overflow, max(1, overflow / exponential_decay_divisor) * seconds_per_tick * 10)
		adjust_mana(-decay)
		if(ismob(parent) && world.time > next_overload_message)
			next_overload_message = world.time + 1.5 MINUTES
			to_chat(parent, span_boldwarning("I feel a tingling surge of excess magic bleeding away from me."))

	if(parent)
		if(amount > mana_overload_threshold)
			if(!mana_overloaded)
				mana_overloaded = TRUE
			var/effect_mult = (amount - mana_overload_threshold) / max(1, maximum_mana_capacity - mana_overload_threshold)
			mana_backlash(effect_mult * MANA_OVERLOAD_DAMAGE_COEFFICIENT * 10)
		else if(mana_overloaded)
			mana_overloaded = FALSE

	update_processing_state()

// ---------------------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------------------

/// Adjusts the pool's stored mana by `delta`, clamped to [0, maximum_mana_capacity]. Returns the amount actually applied (can be less than requested if clamped).
/datum/mana_pool/proc/adjust_mana(delta)
	if(!delta)
		return 0
	var/result = clamp(amount + delta, 0, maximum_mana_capacity)
	var/applied = result - amount
	amount = result
	if(applied && parent)
		SEND_SIGNAL(parent, COMSIG_MANA_POOL_ADJUSTED, applied, src)
	update_processing_state()
	return applied

/// Returns the current stored mana.
/datum/mana_pool/proc/get_amount()
	return amount

/// Returns the maximum mana this pool can hold.
/datum/mana_pool/proc/get_max_mana()
	return maximum_mana_capacity

/// Returns TRUE if this pool currently has at least `required_amount` mana available.
/datum/mana_pool/proc/has_mana(required_amount)
	return amount >= required_amount

/// Returns the current softcap. Overridden by mob pools to scale with skill.
/datum/mana_pool/proc/get_softcap()
	return softcap

/// Returns 0-100, how full we are relative to maximum_mana_capacity.
/datum/mana_pool/proc/get_percent_to_max()
	if(!maximum_mana_capacity)
		return 0
	return (amount / maximum_mana_capacity) * 100

/// Returns 0-100, how full we are relative to our current softcap.
/datum/mana_pool/proc/get_percent_to_softcap()
	var/sc = get_softcap()
	if(!sc)
		return 0
	return (amount / sc) * 100

/**
 * Changes the maximum mana capacity of this pool.
 * Also proportionally adjusts softcap and overload threshold, since they're normally fractions of max.
 * Used by mana_capacity-type enchantments (e.g. /datum/enchantment/mana_capacity).
 *
 * * new_max - the new maximum_mana_capacity.
 * * change_amount - if TRUE, keeps the current fill PERCENTAGE the same (scaling `amount` up/down with the new max). If FALSE, `amount` is left untouched (and re-clamped to the new max).
 */
/datum/mana_pool/proc/set_max_mana(new_max, change_amount = FALSE)
	if(new_max <= 0)
		return
	var/old_max = maximum_mana_capacity
	var/percent = get_percent_to_max()

	var/softcap_ratio = old_max ? (softcap / old_max) : BASE_MANA_SOFTCAP_MULT
	var/overload_ratio = old_max ? (mana_overload_threshold / old_max) : BASE_MANA_OVERLOAD_THRESHOLD_MULT

	maximum_mana_capacity = new_max
	softcap = new_max * softcap_ratio
	mana_overload_threshold = new_max * overload_ratio

	if(change_amount)
		amount = new_max * (percent / 100)
	else
		amount = clamp(amount, 0, maximum_mana_capacity)

	update_processing_state()

/**
 * Sets the passive per-second mana regeneration rate of this pool.
 * Used by mana_regeneration-type enchantments (e.g. /datum/enchantment/mana_regeneration).
 */
/datum/mana_pool/proc/set_regen_rate(new_rate)
	ethereal_recharge_rate = new_rate
	update_processing_state()

/// Returns the current passive regen rate (mana/second).
/datum/mana_pool/proc/get_regen_rate()
	return ethereal_recharge_rate

/**
 * Multiplier applied to passive regen based on the parent's environment.
 * Hook left for future content (e.g. standing near a shrine/altar/ley-line-flavored tile could return > 1).
 * Vanderlin's leyline/pylon network is NOT ported here (no equivalent structures exist in this codebase);
 * this is a clean extension point instead of a half-ported network.
 */
/datum/mana_pool/proc/get_environment_regen_mult()
	return 1

/// How this pool reacts to mana overload - by default, deals brute damage to a mob parent.
/datum/mana_pool/proc/mana_backlash(intensity)
	if(!intensity || !ismob(parent))
		return
	var/mob/living/holder = parent
	if(!istype(holder))
		return
	SEND_SIGNAL(holder, COMSIG_LIVING_MANA_BACKLASH, intensity)
	switch(intensity)
		if(0 to 5)
			to_chat(holder, span_warning("I feel woozy from the strain of holding so much power."))
		if(5 to 15)
			to_chat(holder, span_danger("Sharp pain courses through my body as the excess magic burns me!"))
		else
			holder.visible_message(span_danger("[holder] shudders as excess magic burns through them!"), span_danger("Magic sears through me from the inside!"))
	holder.apply_damage(intensity, BRUTE)
