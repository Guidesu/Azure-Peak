// ==========================================================================================
// VANDERLIN MANA PORT - atom_movable/mob wiring
// Ported and simplified from OpenKeep/Vanderlin's code/datums/mana/living_mana.dm.
//
// Wires a lazily-initialized /datum/mana_pool onto any /atom/movable, and gives
// /mob/living carbon-equivalents (in this codebase, that's /mob/living/carbon/human and other
// carbons) an innate mana pool that scales with the /datum/skill/magic/arcane skill.
//
// This does NOT touch or replace this repo's existing spell recharge_time/stamina/devotion
// gating - it is a parallel, optional resource. Only mobs/items that explicitly get a
// /datum/component/uses_mana component (see use_mana_component.dm) will ever have their
// actions gated by mana.
//
// PUBLIC API added to /atom/movable:
//   var/datum/mana_pool/mana_pool                          -> null until initialized.
//   proc/get_mana_pool_lazy()                               -> returns mana_pool, creating it via get_initial_mana_pool_type() if allowed and missing.
//   proc/get_initial_mana_pool_type()                       -> override to change what /datum/mana_pool subtype an atom gets. Returns null = "does not have a mana pool by default."
//   proc/can_have_mana_pool()                                -> override to forbid mana pools on a type.
//   proc/set_mana_pool(datum/mana_pool/new_pool)             -> replaces (and qdels the old) mana pool.
// ==========================================================================================

/atom/movable
	/// This atom's mana pool, if it has one. Null until lazily initialized - use get_mana_pool_lazy() to force creation.
	var/datum/mana_pool/mana_pool = null
	/// If TRUE, a mana pool is created automatically on Initialize() rather than lazily on first access.
	var/has_initial_mana_pool = FALSE

/atom/movable/Initialize(mapload)
	. = ..()
	if(has_initial_mana_pool)
		initialize_mana_pool_if_possible()

/atom/movable/Destroy(force)
	if(mana_pool)
		QDEL_NULL(mana_pool)
	return ..()

/// Returns what type of mana_pool this atom should get. Override per-type. Return null to mean "no mana pool."
/atom/movable/proc/get_initial_mana_pool_type()
	RETURN_TYPE(/datum/mana_pool)
	return /datum/mana_pool

/// Override and return FALSE to forbid this atom from ever holding a mana pool.
/atom/movable/proc/can_have_mana_pool()
	SHOULD_BE_PURE(TRUE)
	return TRUE

/// Creates the mana pool if we don't have one and are allowed to.
/atom/movable/proc/initialize_mana_pool_if_possible()
	if(isnull(mana_pool) && can_have_mana_pool())
		var/pool_type = get_initial_mana_pool_type()
		if(pool_type)
			set_mana_pool(new pool_type(src))

/// Retrieves this atom's mana pool, lazily creating it if missing and allowed. Returns null if this atom cannot have one.
/atom/movable/proc/get_mana_pool_lazy()
	RETURN_TYPE(/datum/mana_pool)
	if(!can_have_mana_pool())
		return null
	initialize_mana_pool_if_possible()
	return mana_pool

/// Replaces (and cleans up) this atom's mana pool. Pass null to just remove the existing pool.
/atom/movable/proc/set_mana_pool(datum/mana_pool/new_pool)
	if(new_pool && !can_have_mana_pool())
		return FALSE
	var/datum/mana_pool/old_pool = mana_pool
	SEND_SIGNAL(src, COMSIG_ATOM_MANA_POOL_CHANGED, old_pool, new_pool)
	if(old_pool && old_pool != new_pool)
		QDEL_NULL(old_pool)
	mana_pool = new_pool
	return TRUE

// ---------------------------------------------------------------------------------------
// Living mobs: innate mana pool that scales with arcane skill.
//
// DISABLED: has_initial_mana_pool left FALSE (the /atom/movable default) so no living mob
// ever gets a pool constructed - no HUD bar, no regen, no overload/backlash. The mana
// system had real, never-fully-diagnosed bugs (softcap/overload inconsistencies, reported
// regen not working) and no live content actually depends on it (uses_mana component has
// zero callers anywhere in this codebase - see use_mana_component.dm's own header). Left
// in place rather than deleted in case a later pass wants to revisit it properly.
// ---------------------------------------------------------------------------------------

/mob/living/get_initial_mana_pool_type()
	return /datum/mana_pool/mob

/mob/living/Initialize(mapload)
	. = ..()
	var/datum/mana_pool/mob/pool = get_mana_pool_lazy()
	if(istype(pool))
		pool.recalculate_from_skill()
		log_world("MANA_DEBUG: [type] post-recalc amount=[pool.amount] max=[pool.maximum_mana_capacity] overload_threshold=[pool.mana_overload_threshold]")

/// A mana pool belonging to a living mob. Scales its max capacity and regen rate with the mob's /datum/skill/magic/arcane level.
/datum/mana_pool/mob
	maximum_mana_capacity = CARBON_BASE_MANA_CAPACITY
	ethereal_recharge_rate = BASE_MANA_REGEN_PER_SECOND

/**
 * Previously returned maximum_mana_capacity directly ("mobs use their full capacity as their
 * effective softcap"), which diverged from the real `softcap` var (set in New() to
 * maximum_mana_capacity * BASE_MANA_SOFTCAP_MULT, 20% of max) that set_max_mana() still reads
 * and rescales on every recalculate_from_skill() call. That divergence meant needs_processing()/
 * process()'s softcap-decay branch (amount > get_softcap()) could never trigger below 100% of
 * max for a mob, while mana_overload_threshold (90% of max) sat far below that - a mob could
 * accumulate mana all the way up past the overload threshold with the decay-back-down mechanism
 * never engaging to stop it. Returning the real softcap here instead restores the intended
 * shape: passive regen fills up to the softcap normally, decay pulls anything above that back
 * down, and only sustained pressure past the (higher) overload threshold actually backlashes.
 */
/datum/mana_pool/mob/get_softcap()
	var/mob/living/holder = parent
	if(!istype(holder))
		return ..()
	return softcap

/**
 * Recalculates maximum_mana_capacity and ethereal_recharge_rate from the parent mob's arcane skill level.
 * Call this whenever the mob's arcane skill changes (skill-up code elsewhere is NOT modified by this port;
 * this proc is exposed publicly so skill-training code can call it, e.g. `mob.mana_pool.recalculate_from_skill()`).
 */
/datum/mana_pool/mob/proc/recalculate_from_skill()
	var/mob/living/holder = parent
	if(!istype(holder))
		return
	var/skill_level = holder.get_skill_level(/datum/skill/magic/arcane)
	set_max_mana(CARBON_BASE_MANA_CAPACITY + (skill_level * MANA_CAPACITY_PER_ARCANE_SKILL_LEVEL))
	set_regen_rate(BASE_MANA_REGEN_PER_SECOND + (skill_level * MANA_REGEN_PER_ARCANE_SKILL_LEVEL))

/**
 * Safely adjusts a living mob's own mana. Convenience wrapper others can call instead of reaching into mana_pool directly.
 * Returns the amount actually applied (0 if the mob has no mana pool).
 */
/mob/living/proc/adjust_personal_mana(delta)
	var/datum/mana_pool/pool = get_mana_pool_lazy()
	if(!pool)
		return 0
	return pool.adjust_mana(delta)

/// Returns this mob's current mana, or 0 if it has no mana pool.
/mob/living/proc/get_personal_mana()
	if(!mana_pool)
		return 0
	return mana_pool.get_amount()

/// Returns this mob's maximum mana, or 0 if it has no mana pool.
/mob/living/proc/get_max_personal_mana()
	if(!mana_pool)
		return 0
	return mana_pool.get_max_mana()
