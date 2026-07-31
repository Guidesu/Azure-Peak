// ==========================================================================================
// VANDERLIN MANA PORT - uses_mana component
// Ported and simplified from OpenKeep/Vanderlin's code/datums/components/use_mana.dm.
//
// Attaching this component to a spell action (/datum/action/cooldown/spell/...) or an item
// declares that thing as gated by mana IN ADDITION TO whatever recharge_time/stamina/devotion
// cost it already has. This is purely opt-in: nothing in this repo's existing spell/item base
// classes references this component, so nothing is gated by mana unless a specific spell/item
// explicitly adds it.
//
// Mana source resolution order when draining: any equipped/held item with
// TRAIT_POOL_AVAILABLE_FOR_CAST on the caster is drained from FIRST (e.g. a focus item), and
// only once those are exhausted does it fall back to the caster's own personal mana_pool.
//
// PUBLIC API:
//   AddComponent(/datum/component/uses_mana,
//       pre_use_check_with_feedback_comsig = COMSIG_SPELL_BEFORE_CAST,  // signal to hook for the pre-use mana check (must fire BEFORE the effect happens)
//       post_use_comsig = COMSIG_SPELL_AFTER_CAST,                     // signal to hook for post-use mana drain (fires AFTER the effect resolves)
//       mana_required = 10,                                            // flat number, OR a /datum/callback returning a number (for variable-cost spells/items)
//       get_user_callback = CALLBACK(src, PROC_REF(get_owner)),        // callback returning the mob/atom whose mana pools should be checked/drained
//       activate_check_failure_callback = CALLBACK(src, PROC_REF(on_insufficient_mana)), // optional; called (and should return truthy on success at cancelling) when there isn't enough mana
//   )
//
// Convenience subtype for spells (pre-fills the two COMSIG args to match this repo's existing
// spell action signal names from code/__DEFINES/dcs/signals/signals_spell.dm):
//   AddComponent(/datum/component/uses_mana/spell,
//       get_user_callback = CALLBACK(src, PROC_REF(get_owner)),
//       mana_required = 10,
//   )
//
// Procs other code can call directly on the component:
//   /datum/component/uses_mana/proc/is_mana_sufficient(atom/movable/user, ...)  -> TRUE/FALSE, does NOT drain.
//   /datum/component/uses_mana/proc/drain_mana(...)                             -> actually subtracts the mana. Idempotent misuse-safe (won't go below 0 across pools).
//   /datum/component/uses_mana/proc/get_mana_required(atom/caster, ...)          -> resolves the (possibly dynamic) mana cost.
// ==========================================================================================

/// Designates the parent (spell action or item) as something that consumes mana from whoever/whatever is using it.
/datum/component/uses_mana
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Callback: () -> atom/movable. Returns whoever's mana pools should be checked/drained.
	var/datum/callback/get_user_callback
	/// Callback: (...) -> any. Called on insufficient mana so the parent can give feedback/cancel. Optional.
	var/datum/callback/activate_check_failure_callback
	/// Callback: (atom/caster, ...) -> num. Used if mana_required was given as a callback instead of a flat number.
	var/datum/callback/get_mana_required_callback

	/// Flat mana cost, used if get_mana_required_callback is null.
	var/mana_required

	/// Signal (on parent) to hook for the pre-use check. Must be a signal that supports a bitflag return to cancel (see SPELL_CANCEL_CAST-style flags).
	var/pre_use_check_with_feedback_comsig
	/// Signal (on parent) to hook for post-use draining.
	var/post_use_comsig

/datum/component/uses_mana/Initialize(
	datum/callback/get_user_callback,
	datum/callback/activate_check_failure_callback,
	pre_use_check_with_feedback_comsig,
	post_use_comsig,
	mana_required,
)
	. = ..()
	if(isnull(pre_use_check_with_feedback_comsig))
		stack_trace("uses_mana component created without pre_use_check_with_feedback_comsig!")
		return COMPONENT_INCOMPATIBLE
	if(isnull(post_use_comsig))
		stack_trace("uses_mana component created without post_use_comsig!")
		return COMPONENT_INCOMPATIBLE
	if(isnull(get_user_callback))
		stack_trace("uses_mana component created without get_user_callback!")
		return COMPONENT_INCOMPATIBLE

	src.get_user_callback = get_user_callback
	src.activate_check_failure_callback = activate_check_failure_callback

	if(istype(mana_required, /datum/callback))
		src.get_mana_required_callback = mana_required
	else if(isnum(mana_required))
		src.mana_required = mana_required
	else
		stack_trace("uses_mana component created without a valid mana_required (num or callback)!")
		return COMPONENT_INCOMPATIBLE

	src.pre_use_check_with_feedback_comsig = pre_use_check_with_feedback_comsig
	src.post_use_comsig = post_use_comsig

/datum/component/uses_mana/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, pre_use_check_with_feedback_comsig, PROC_REF(can_activate_with_feedback))
	RegisterSignal(parent, post_use_comsig, PROC_REF(react_to_successful_use))

/datum/component/uses_mana/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, pre_use_check_with_feedback_comsig)
	UnregisterSignal(parent, post_use_comsig)

/// Returns the mob/atom whose mana should be checked - i.e. the caster/user.
/datum/component/uses_mana/proc/get_parent_user()
	return get_user_callback?.Invoke()

/// Resolves the (possibly dynamic) mana cost for this use.
/datum/component/uses_mana/proc/get_mana_required(atom/caster, ...)
	if(!isnull(get_mana_required_callback))
		return get_mana_required_callback.Invoke(arglist(args))
	return mana_required || 0

/**
 * Returns the ordered list of mana_pools that should be drawn from for this cast: any
 * TRAIT_POOL_AVAILABLE_FOR_CAST-flagged item the user is holding/wearing, THEN the user's own pool.
 */
/datum/component/uses_mana/proc/get_mana_sources()
	var/atom/movable/caster = get_parent_user()
	var/list/datum/mana_pool/usable_pools = list()
	if(!istype(caster))
		return usable_pools

	if(isliving(caster))
		var/mob/living/living_caster = caster
		var/list/atom/movable/carried = list()
		carried += living_caster.held_items
		carried += living_caster.get_equipped_items(include_pockets = TRUE)
		for(var/atom/movable/held as anything in carried)
			if(held?.mana_pool && HAS_TRAIT(held, TRAIT_POOL_AVAILABLE_FOR_CAST))
				usable_pools += held.mana_pool

	if(caster.mana_pool)
		usable_pools += caster.mana_pool // caster's own pool drained last

	return usable_pools

/// TRUE if the combined available mana across all sources is enough to cover the cost. Does NOT drain anything.
/datum/component/uses_mana/proc/is_mana_sufficient(atom/movable/user, ...)
	var/required = get_mana_required(arglist(args))
	if(required <= 0)
		return TRUE

	var/total_available = 0
	for(var/datum/mana_pool/pool as anything in get_mana_sources())
		total_available += pool.get_amount()
		if(total_available >= required)
			return TRUE
	return total_available >= required

/// The raw activation check. Override point for subtypes if extra conditions are ever needed.
/datum/component/uses_mana/proc/can_activate(...)
	return is_mana_sufficient(arglist(list(get_parent_user()) + args))

/// Signal handler wrapper - returns a cancel bitflag (via activate_check_failure_callback) on insufficient mana, NONE otherwise.
/datum/component/uses_mana/proc/can_activate_with_feedback(...)
	SIGNAL_HANDLER
	if(can_activate(arglist(args.Copy())))
		return NONE
	var/atom/movable/user = get_parent_user()
	if(ismob(user))
		to_chat(user, span_warning("I don't have enough mana!"))
	return activate_check_failure_callback?.Invoke(arglist(args)) || NONE

/**
 * Drains mana required for this use across all available sources (focus items first, then the
 * caster's own pool), in proportion to how much each source can provide. Never drains more than
 * required in total, and never drains a given pool below 0.
 */
/datum/component/uses_mana/proc/drain_mana(...)
	var/required = get_mana_required(arglist(list(get_parent_user()) + args))
	if(required <= 0)
		return 0

	var/remaining = required
	for(var/datum/mana_pool/pool as anything in get_mana_sources())
		if(remaining <= 0)
			break
		var/take = min(remaining, pool.get_amount())
		if(take <= 0)
			continue
		pool.adjust_mana(-take)
		remaining -= take

	return required - remaining // amount actually drained

/// Signal handler - drains mana after a successful use.
/datum/component/uses_mana/proc/react_to_successful_use(...)
	SIGNAL_HANDLER
	drain_mana(arglist(list(get_parent_user()) + args))

// ---------------------------------------------------------------------------------------
// Convenience subtype pre-wired for this repo's spell action signals
// (COMSIG_SPELL_BEFORE_CAST / COMSIG_SPELL_AFTER_CAST, see code/__DEFINES/dcs/signals/signals_spell.dm).
//
// Usage from within a /datum/action/cooldown/spell/mySpell/New():
//   AddComponent(/datum/component/uses_mana/spell,
//       get_user_callback = CALLBACK(src, PROC_REF(get_owner)),
//       mana_required = 15,
//   )
// ---------------------------------------------------------------------------------------
/datum/component/uses_mana/spell/Initialize(
	datum/callback/get_user_callback,
	datum/callback/activate_check_failure_callback,
	pre_use_check_with_feedback_comsig = COMSIG_SPELL_BEFORE_CAST,
	post_use_comsig = COMSIG_SPELL_AFTER_CAST,
	mana_required,
)
	return ..()

/// The pre-cast signal handler must return the SPELL_CANCEL_CAST bitflag (not just any truthy value) to actually stop the spell.
/datum/component/uses_mana/spell/can_activate_with_feedback(...)
	SIGNAL_HANDLER
	if(can_activate(arglist(args.Copy())))
		return NONE
	var/atom/movable/user = get_parent_user()
	if(ismob(user))
		to_chat(user, span_warning("I don't have enough mana to cast this!"))
	if(!isnull(activate_check_failure_callback))
		return activate_check_failure_callback.Invoke(arglist(args))
	return SPELL_CANCEL_CAST
