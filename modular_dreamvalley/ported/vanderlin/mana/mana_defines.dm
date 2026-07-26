// ==========================================================================================
// VANDERLIN MANA PORT - Defines
// Ported (in simplified form) from OpenKeep/Vanderlin's code/__DEFINES/magic.dm and
// code/datums/mana/*.
//
// This repo (Roguetown/DreamValley) has NO existing numeric mana-pool resource: its spell
// framework (code/modules/spells/spell.dm) gates casting purely via recharge_time cooldowns,
// stamina (releasedrain) and devotion (miracle/devotion_cost). This mana system is added as a
// completely OPTIONAL, ADDITIONAL resource that specific spells/items can opt into by adding
// the /datum/component/uses_mana component. Nothing about the existing cooldown system is
// touched, removed, or overridden.
//
// Simplifications versus Vanderlin (documented, deliberate - the omitted systems do not exist
// in this codebase and porting them would be large unrelated scope creep):
// - No attunements/elemental alignment system (Vanderlin's /datum/attunement, patrons-as-mana-
//   alignment). This repo's patron/god system is unrelated to spell resource costs.
// - No leylines/pylons/mana fountains/mana network transfer graph. Regen here is simple
//   time-based (with an optional "in a sanctified/ley-adjacent area" bonus hook left for later
//   content to use, see /datum/mana_pool/proc/get_environment_regen_mult()).
// - No mana "backlash" organ damage tied to attunement composition (attunements don't exist
//   here) - backlash is a simple flat brute-damage-on-overload effect instead, same spirit.
// ==========================================================================================

/// Base mana pool capacity for a generic mana_pool holder (used for batteries/misc atoms).
#define BASE_MANA_CAPACITY 1000

/// Base mana capacity for a living mob's own innate mana pool.
#define CARBON_BASE_MANA_CAPACITY 100

/// The soft cap fraction of maximum_mana_capacity: above this, mana begins decaying back down.
#define BASE_MANA_SOFTCAP_MULT 0.2

/// Base overload threshold fraction of maximum_mana_capacity - going over this starts hurting the holder.
#define BASE_MANA_OVERLOAD_THRESHOLD_MULT 0.9

/// Base natural (ethereal) mana regeneration, in mana/second, for a mob's innate pool.
#define BASE_MANA_REGEN_PER_SECOND 0.2

/// Extra mana/second regen granted per skill level in /datum/skill/magic/arcane.
#define MANA_REGEN_PER_ARCANE_SKILL_LEVEL 0.1

/// Extra max mana granted per skill level in /datum/skill/magic/arcane.
#define MANA_CAPACITY_PER_ARCANE_SKILL_LEVEL 15

/// Divisor used for exponential decay above softcap. Lower = steeper decay.
#define BASE_MANA_EXPONENTIAL_DIVISOR 30

/// Minimum interval, in seconds, between mana_pool process() ticks (this repo's SSfastprocess runs every 2 ticks / 0.2s already).
#define MANA_POOL_PROCESS_INTERVAL (2 SECONDS)

/// How much brute damage per point of overload effect intensity mana backlash deals.
#define MANA_OVERLOAD_DAMAGE_COEFFICIENT 0.5

// ---- Battery / item mana capacities ----

/// Base capacity of a standard mana crystal battery item.
#define MANA_CRYSTAL_BASE_MANA_CAPACITY (BASE_MANA_CAPACITY * 0.2)

/// Maximum distance (tiles) a mana battery can transfer mana to/from a pool that isn't in the same location.
#define MANA_BATTERY_MAX_TRANSFER_DISTANCE 3

/// Maximum mana transferable per second, generic default.
#define BASE_MANA_DONATION_RATE (BASE_MANA_CAPACITY * 0.5)

// ---- Signals ----

/// Sent from /datum/mana_pool/proc/adjust_mana() to the mana_pool's parent atom: (amount_changed, datum/mana_pool/pool)
#define COMSIG_MANA_POOL_ADJUSTED "mana_pool_adjusted"

/// Sent to an atom/movable when its mana_pool var is replaced: (datum/mana_pool/old_pool, datum/mana_pool/new_pool)
#define COMSIG_ATOM_MANA_POOL_CHANGED "atom_mana_pool_changed"

/// Sent to a mob when it takes mana backlash damage: (amount)
#define COMSIG_LIVING_MANA_BACKLASH "living_mana_backlash"

// ---- Trait ----

/// Give this to an atom/movable holding a mana_pool to declare that its pool can be drawn from during spellcasting by whoever is holding/wearing it (e.g. a focus item).
#define TRAIT_POOL_AVAILABLE_FOR_CAST "pool_available_for_cast"
