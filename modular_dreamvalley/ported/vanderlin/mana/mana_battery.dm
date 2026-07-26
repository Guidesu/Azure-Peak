// ==========================================================================================
// VANDERLIN MANA PORT - Mana battery item
// Ported and simplified from OpenKeep/Vanderlin's code/datums/mana/mana_battery.dm.
//
// A mana battery is an item with its OWN independent mana_pool (separate from any caster's
// personal pool). A holder can manually draw mana from it into their own pool, or push mana
// into it, via left/right click self-interaction. Batteries can also be granted
// TRAIT_POOL_AVAILABLE_FOR_CAST so that /datum/component/uses_mana will treat them as a valid
// mana source to draw from automatically during spellcasting (see use_mana_component.dm).
//
// No leyline/pylon network, no attunements, no gem-network-attunement crafting - those systems
// don't exist in this codebase. This is the "battery as a discrete portable mana reservoir"
// piece of Vanderlin's mana system, kept intentionally self-contained.
//
// Vanderlin's actual sprite/icon assets for mana crystals were not available to copy (this
// port only had access to the .dm source, not the Vanderlin icons/ tree from this task's
// environment) - a generic placeholder icon from this repo's existing icon set is used instead.
// Whoever adds real art can just change icon/icon_state below.
// ==========================================================================================

/obj/item/mana_battery
	name = "mana battery"
	desc = "A crystalline vessel that can store raw magical energy, drawn from or fed into by anyone attuned to such things."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	w_class = WEIGHT_CLASS_SMALL
	has_initial_mana_pool = TRUE
	/// Maximum distance (tiles) this battery can transfer mana to/from another pool that isn't co-located with it.
	var/max_allowed_transfer_distance = MANA_BATTERY_MAX_TRANSFER_DISTANCE

/obj/item/mana_battery/get_initial_mana_pool_type()
	return /datum/mana_pool/mana_battery

/obj/item/mana_battery/examine(mob/user)
	. = ..()
	if(mana_pool)
		. += span_notice("It holds [round(mana_pool.get_amount())] / [round(mana_pool.get_max_mana())] mana.")

/// Left-click self-interaction: draw mana FROM the battery, INTO the user's own pool.
/obj/item/mana_battery/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	if(!istype(user) || !user.is_holding(src))
		return FALSE
	var/datum/mana_pool/user_pool = user.get_mana_pool_lazy()
	if(!user_pool)
		to_chat(user, span_warning("I have no way to hold mana myself."))
		return FALSE
	if(!mana_pool || !mana_pool.get_amount())
		to_chat(user, span_warning("[src] is empty."))
		return FALSE

	var/max_draw = min(mana_pool.get_amount(), user_pool.get_max_mana() - user_pool.get_amount())
	if(max_draw <= 0)
		to_chat(user, span_warning("I can't hold any more mana."))
		return FALSE

	var/mana_to_draw = input(user, "How much mana do you want to draw from [src]? (Max: [round(max_draw)])", "Draw Mana") as num|null
	if(!mana_to_draw || QDELETED(user) || QDELETED(src) || !user.is_holding(src))
		return FALSE
	mana_to_draw = clamp(mana_to_draw, 0, max_draw)
	if(mana_to_draw <= 0)
		return FALSE

	var/drawn = mana_pool.adjust_mana(-mana_to_draw)
	user_pool.adjust_mana(-drawn)
	to_chat(user, span_notice("I draw [abs(drawn)] mana from [src]."))
	return TRUE

/// Alt-click interaction: send mana FROM the user's own pool, INTO the battery.
/obj/item/mana_battery/AltClick(mob/user)
	. = ..()
	if(!istype(user) || !user.Adjacent(src) || !user.is_holding(src))
		return
	var/datum/mana_pool/user_pool = user.mana_pool
	if(!user_pool || !user_pool.get_amount())
		to_chat(user, span_warning("I have no mana to give."))
		return
	if(!mana_pool)
		return

	var/max_send = min(user_pool.get_amount(), mana_pool.get_max_mana() - mana_pool.get_amount())
	if(max_send <= 0)
		to_chat(user, span_warning("[src] can't hold any more mana."))
		return

	var/mana_to_send = input(user, "How much mana do you want to send to [src]? (Max: [round(max_send)])", "Send Mana") as num|null
	if(!mana_to_send || QDELETED(user) || QDELETED(src) || !user.is_holding(src))
		return
	mana_to_send = clamp(mana_to_send, 0, max_send)
	if(mana_to_send <= 0)
		return

	var/sent = user_pool.adjust_mana(-mana_to_send)
	mana_pool.adjust_mana(-sent)
	to_chat(user, span_notice("I send [abs(sent)] mana into [src]."))

/// The mana_pool subtype used by battery items - has no passive regen of its own, only holds what's put into it.
/datum/mana_pool/mana_battery
	maximum_mana_capacity = MANA_CRYSTAL_BASE_MANA_CAPACITY
	amount = 0
	ethereal_recharge_rate = 0

/datum/mana_pool/mana_battery/New(atom/movable/new_parent)
	. = ..()
	softcap = maximum_mana_capacity // batteries don't decay - they're meant to hold a full charge indefinitely.

/**
 * A wearable focus that grants TRAIT_POOL_AVAILABLE_FOR_CAST, allowing /datum/component/uses_mana
 * to automatically draw from its pool (in addition to the wearer's own) when the wearer casts a
 * mana-gated spell/uses a mana-gated item. Comes pre-charged.
 */
/obj/item/mana_battery/focus
	name = "focusing mana crystal"
	desc = "A crystal cut and set for easy channeling. Spells will draw from this before touching my own reserves."
	icon_state = "soulstone2"

/obj/item/mana_battery/focus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_POOL_AVAILABLE_FOR_CAST, INNATE_TRAIT)
	if(mana_pool)
		mana_pool.amount = mana_pool.maximum_mana_capacity
