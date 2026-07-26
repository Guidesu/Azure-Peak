/**
 * Ported from Ratwood-2.0's modular/code/game/objects/items/lewd/chastity/chastity_core.dm — chastity_collar
 * port, Stage 1 (base item + standard variants only; cursed/collar devices are a later stage).
 *
 * Adapted for this repo:
 *  - No /datum/sex_controller ("sexcon") exists here; anywhere Ratwood queried source.sexcon.has_chastity_*(),
 *    this port hosts those helper procs directly on /obj/item/chastity instead (has_chastity_penis/vagina/anal/cage
 *    below), reading the device's own chastity_type/TRAIT_CHASTITY_* state — there's no separate controller object
 *    to delegate to.
 *  - chastity_cursed/cursed_front_mode/cursed_anal_open/cursed_spikes_on/chastity_master/received_cum_count/
 *    collar-master binding are RETAINED as vars/stubs for forward compatibility with the later collar stage,
 *    but no cursed-device *behavior* is implemented here — see chastity_equip.dm for where the cursed equip
 *    path is stubbed out with a TODO rather than ported.
 *  - sprite_acc / datum/sprite_accessory/chastity (and subtypes) and datum/bodypart_feature/chastity are stubbed
 *    to minimal no-op-safe types (see chastity_visuals_stub.dm) since sprite/customizer integration is a later stage.
 */

/// Persistent physical key spawned for a non-cursed chastity device. Not linked to GLOB.lockids like most
/// roguekeys since each device generates its own random lockhash per-instance (see chastity_core.dm's
/// Initialize() and generate_chastity_key()) rather than sharing one hash per lockid.
/obj/item/roguekey/chastity
	name = "chastity key"
	desc = "A small key for a chastity device."
	icon_state = "iron"

GLOBAL_LIST_INIT(chastity_standard_traits, list(
	list(TRAIT_CHASTITY_FULL),                                                        // type 0 — intersex full device
	list(TRAIT_CHASTITY_CAGE),                                                        // type 1 — cock cage
	list(TRAIT_CHASTITY_CAGE, TRAIT_CHASTITY_ANAL),                                  // type 2 — cage + anal shield
	list(TRAIT_CHASTITY_CAGE, TRAIT_CHASTITY_SPIKED),                                // type 3 — spiked cage
	list(TRAIT_CHASTITY_CAGE, TRAIT_CHASTITY_ANAL, TRAIT_CHASTITY_SPIKED),           // type 4 — spiked cage + anal
	list(TRAIT_CHASTITY_VAGINA_BLOCKED),                                              // type 5 — insertable belt (vagina only, no anal shield)
	list(TRAIT_CHASTITY_VAGINA_BLOCKED, TRAIT_CHASTITY_ANAL),                        // type 6 — insertable + anal shield
	list(TRAIT_CHASTITY_VAGINA_BLOCKED, TRAIT_CHASTITY_SPIKED),                      // type 7 — spiked insertable
	list(TRAIT_CHASTITY_VAGINA_BLOCKED, TRAIT_CHASTITY_ANAL, TRAIT_CHASTITY_SPIKED), // type 8 — spiked insertable + anal
	list(TRAIT_CHASTITY_FULL, TRAIT_CHASTITY_SPIKED)                                 // type 9 — spiked intersex device
))

/obj/item/chastity
	var/cursed_front_mode = 0 // 0 = block all front access, 1 = penis open, 2 = vagina open, 3 = all front open — STAGE 1: unused, reserved for later collar stage.
	var/cursed_anal_open = FALSE // STAGE 1: unused, reserved for later collar stage.
	var/cursed_spikes_on = FALSE // STAGE 1: unused, reserved for later collar stage.
	var/chastity_flat = FALSE // is the cage flat-style (more restrictive) or standard?
	var/chastity_move_sound = SFX_JINGLE_BELLS
	var/chastity_move_delay = CHASTITY_MOVE_SOUND_DELAY
	var/chastity_move_volume = 55
	var/chastity_move_chance = 5
	var/chastity_high_pop_client_cap = CHASTITY_HIGH_POP_THRESHOLD
	var/chastity_high_pop_move_chance_mult = CHASTITY_HIGH_POP_SOUND_MULT
	var/tmp/chastity_move_counter = 0
// Core type definition — base name, icon, sizing, and feature-slot vars.
// always_show_examine_link, nudist_approved, locked, lockid, and lockhash don't exist on the base /obj/item
// in this repo (they're Ratwood-only additions except lockid/lockhash, which Ratwood declares on
// /obj/item/roguekey — chastity devices aren't roguekeys, so they need their own copies here).
/obj/item/chastity
	name = "chastity belt"
	desc = "A unisex metal device designed to prevent penetrative sex. It has a lock on the front, and encloses the groin area behind robust iron bars. For the devout."
	icon = 'modular_dreamvalley/icons/ratwood_chastity/chastity.dmi'
	icon_state = "cage_belt"
	mob_overlay_icon = "cage_belt"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE
	dropshrink = 0.9
	/// STAGE 1: this repo's base /obj/item has no always_show_examine_link hook to opt into; retained as a
	/// no-op var for parity with Ratwood's source and in case a later stage wires up the equivalent behavior.
	var/always_show_examine_link = TRUE
	var/datum/bodypart_feature/chastity/chastity_feature // snowflake slot for chastity items, belt's dont work as clothing equippables
	var/chastity_type = 0 // 0 = full, 1 = cage, 2 = cage with anal, 3 = spiked cage, 4 = spiked cage with anal, 5 = insertable, 6 = insertable with anal, 7 = spiked insertable, 8 = spiked insertable with anal, 9 = spiked intersex device
	var/chastity_organtype = 0 // 0 = neuter, 1 = penis required, 2 = vagina required, 3 = both required
	var/obj/item/roguekey/chastity/generated_key = null
	var/lockable = TRUE // if the device can be traditionally locked with a key or lockpick, should be true for everything but cursed devices which are locked via the collar master menu (later stage)
	var/locked = FALSE
	var/lockhash = 0 // matched against the generated key's lockhash to verify it's the right key for this specific device
	var/chastity_cursed = FALSE // STAGE 1: no cursed-device behavior is implemented; see chastity_equip.dm.
	var/mob/living/carbon/human/chastity_victim = null
	var/datum/mind/chastity_master = null // STAGE 1: unused, reserved for later collar stage.
	var/received_cum_count = 0 // STAGE 1: unused, reserved for later collar stage.
	var/obj/item/dildo/attached_toy = null
	var/lockid = null
	grid_height = 32
	grid_width = 32
	throw_speed = 0.5
	var/sprite_acc = /datum/sprite_accessory/chastity/full // STAGE 1: stub type, see chastity_visuals_stub.dm — TODO Stage 3: sprite accessory integration
	lefthand_file = 'modular/icons/mob/inhands/lewd/items_lefthand.dmi'
	righthand_file = 'modular/icons/mob/inhands/lewd/items_righthand.dmi'
	/// STAGE 1: this repo's base /obj/item has no nudist_approved var/hook; retained as a no-op var for
	/// parity with Ratwood's source in case a later stage wires up the equivalent nudity-content check.
	var/nudist_approved = TRUE

// Ensure each chastity item has a unique lockhash used by matching keys.
/obj/item/chastity/Initialize()
	. = ..()
	if(!lockhash)
		lockhash = rand(100000,999999)
		while(lockhash in GLOB.lockhashes)
			lockhash = rand(100000,999999)
		GLOB.lockhashes += lockhash

/obj/item/chastity/examine(mob/user)
	. = ..()
	if(attached_toy)
		. += "[span_notice("\An [attached_toy] appears attached to \the [initial(name)]. Alt+RMB to remove it.")]"
	if(chastity_cursed)
		if(received_cum_count == 1)
			. += span_notice("1 tally mark is etched into the chastity device's metal surface.")
		else if(received_cum_count > 1)
			. += span_notice("[received_cum_count] tally marks are etched into the chastity device's metal surface.")

/obj/item/chastity/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/dildo))
		return ..()
	var/obj/item/dildo/held_dildo = I
	if(held_dildo.is_attached_to_belt)
		return
	if(attached_toy)
		to_chat(user, span_info("\The [initial(name)] already has a toy attached! Remove it first."))
		return
	if(!user.transferItemToLoc(held_dildo, null))
		to_chat(user, span_warning("\The [held_dildo] is stuck to my hand!"))
		return
	if(attach_toy(held_dildo, user))
		user.visible_message(span_warning("[user] equips \the [held_dildo] onto \the [initial(name)]."))

/obj/item/chastity/AltRightClick(mob/user)
	if(!attached_toy)
		return
	if(!isliving(user) || !user.TurfAdjacent(src))
		return
	if(user.get_active_held_item())
		to_chat(user, span_info("I can't do that with my hand full!"))
		return
	user.visible_message(span_warning("[user] removes \the [attached_toy] from \the [initial(name)]."))
	detach_toy(user)

/obj/item/chastity/update_icon()
	. = ..()
	if(attached_toy)
		var/matrix/M = new
		M.Scale(-0.8, -0.8)
		attached_toy.transform = M
		attached_toy.pixel_y = -6
		attached_toy.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

/// Mounts a dildo onto this device. Fails if a toy is already present on the device.
/// STAGE 1: Ratwood's cross-check against a belt-mounted toy (obj/item/storage/belt/rogue/attached_toy) is
/// dropped — that var doesn't exist on this repo's belt/rogue and adding it is a separate belt-feature port
/// outside this stage's scope. Only this device's own attached_toy slot is guarded here.
/obj/item/chastity/proc/attach_toy(obj/item/dildo/new_toy, mob/user)
	if(!new_toy || attached_toy || new_toy.is_attached_to_belt)
		return FALSE
	new_toy.is_attached_to_belt = TRUE
	attached_toy = new_toy
	vis_contents += attached_toy
	playsound(get_turf(user ? user : src), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
	update_icon()
	refresh_wearer_overlays()
	return TRUE

/// Removes the mounted dildo.
/obj/item/chastity/proc/detach_toy(mob/user)
	if(!attached_toy)
		return FALSE
	var/obj/item/dildo/dildo = attached_toy
	vis_contents -= dildo
	dildo.update_icon()
	dildo.is_attached_to_belt = FALSE
	attached_toy = null
	if(user && isliving(user) && !user.get_active_held_item() && user.put_in_hands(dildo))
		// moved to user hand above
	else
		dildo.forceMove(drop_location())
	update_icon()
	refresh_wearer_overlays()
	return TRUE

/obj/item/chastity/proc/refresh_wearer_overlays()
	if(!chastity_victim)
		return
	chastity_victim.update_body_parts(TRUE)
	chastity_victim.update_inv_belt()

// Restricts caging to valid player-controlled humans.
/obj/item/chastity/proc/can_cage_target(mob/living/carbon/human/H, mob/user)
	if(!H)
		return FALSE
	if(!H.mind)
		to_chat(user, span_warning("[H] cannot be fitted with a chastity device right now."))
		return FALSE
	return TRUE

// Verifies that the target has the genital configuration required by this device type.
/obj/item/chastity/proc/chastity_genital_check(mob/living/carbon/human/H)
	if(chastity_organtype == 1 && !H.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(chastity_organtype == 2 && !H.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(chastity_organtype == 3 && (!H.getorganslot(ORGAN_SLOT_PENIS) || !H.getorganslot(ORGAN_SLOT_VAGINA)))
		return FALSE
	return TRUE

// Creates and caches the bodypart feature object used to render/track equipped chastity.
// STAGE 1: chastity_feature is a stub type (see chastity_visuals_stub.dm) — no visible sprite overlay yet.
/obj/item/chastity/proc/ensure_chastity_feature(mob/living/carbon/human/H)
	if(chastity_feature)
		return TRUE
	var/datum/bodypart_feature/chastity/chastity_new = new /datum/bodypart_feature/chastity()
	chastity_new.chastity_item = src
	chastity_feature = chastity_new
	return TRUE

// Attaches the prepared chastity bodypart feature to the chest bodypart.
/obj/item/chastity/proc/attach_chastity_feature(mob/living/carbon/human/H)
	var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return FALSE
	if(!chastity_feature)
		ensure_chastity_feature(H)
	chest.add_bodypart_feature(chastity_feature)
	return TRUE

// Finalizes equip bookkeeping by moving the item, assigning wearer refs, and binding the reaction/guard components.
/obj/item/chastity/proc/finalize_chastity_equip(mob/living/carbon/human/H)
	forceMove(H)
	H.chastity_device = src
	chastity_victim = H
	var/datum/component/intimate_action_guard/chastity/action_guard_component = LoadComponent(/datum/component/intimate_action_guard/chastity)
	if(action_guard_component)
		action_guard_component.bind_to_wearer(H)
	var/datum/component/intimate_reaction/chastity_receive_flavor/reaction_component = LoadComponent(/datum/component/intimate_reaction/chastity_receive_flavor)
	if(reaction_component)
		reaction_component.bind_to_wearer(H)
	register_wearer_jingle(H)
	refresh_chastity_mood_effects(H)
	refresh_wearer_overlays()

/// Returns TRUE if the wearer has hard mode enabled in their preferences.
/obj/item/chastity/proc/is_hardmode_active()
	return chastity_victim?.client?.prefs?.chastity_hardmode == CHASTITY_HARDMODE_ENABLED

/// Returns the appropriate lock-denial flavor string for this device.
/obj/item/chastity/proc/get_lock_denial_string()
	return pick_chastity_string("chastity_lock_messages.json", chastity_cursed ? "chastity_cursed_lock" : "chastity_lock_denial")

/// Returns TRUE only if interaction_item is the exact persistent key object spawned for this device.
/obj/item/chastity/proc/is_generated_unlock_key(obj/item/interaction_item)
	if(!interaction_item || !generated_key || QDELETED(generated_key))
		return FALSE
	return interaction_item == generated_key

/// Signal handler for COMSIG_CARBON_CHASTITY_LOCK_INTERACT.
/obj/item/chastity/proc/on_chastity_lock_interact(datum/source, mob/user, obj/item/interaction_item, new_locked_state, method)
	SIGNAL_HANDLER
	if(source != chastity_victim)
		return
	if(!is_hardmode_active())
		return
	if(new_locked_state)
		return
	if(is_generated_unlock_key(interaction_item))
		return
	return COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK

/// Syncs the generated key's name/desc/hardmode flag to the current wearer and hard mode state.
/obj/item/chastity/proc/sync_generated_key_metadata(mob/living/carbon/human/H, mob/user = null)
	if(!H || !generated_key || QDELETED(generated_key))
		return

	var/obj/item/roguekey/chastity/new_key = generated_key
	var/was_hardmode_key = new_key.hardmode_indestructible
	new_key.name = "[H]'s chastity key"
	new_key.desc = "A small key for [H]'s chastity device."
	new_key.hardmode_indestructible = FALSE

	if(is_hardmode_active())
		new_key.hardmode_indestructible = TRUE
		new_key.name = "[H]'s binding key"
		new_key.desc = "A small key bearing the mark of a permanent binding. [H]'s freedom rests in this metal."
		if(user && !was_hardmode_key)
			to_chat(user, span_warning("The key feels heavier than it should. [H]'s fate now rests in your hands."))

// Spawns a matching physical key at the equipping user's turf (non-cursed devices only).
/obj/item/chastity/proc/generate_chastity_key(mob/user, mob/living/carbon/human/H)
	if(!user || !H)
		return
	var/obj/item/roguekey/chastity/new_key = generated_key
	if(!new_key || QDELETED(new_key))
		new_key = new(get_turf(user))
		new_key.lockhash = src.lockhash
		generated_key = new_key
	sync_generated_key_metadata(H, user)

// Applies baseline chastity traits according to configured chastity_type for standard devices.
/obj/item/chastity/proc/apply_standard_chastity_traits(mob/living/carbon/human/H)
	var/list/traits_to_apply = GLOB.chastity_standard_traits[chastity_type + 1]
	if(!islist(traits_to_apply))
		notify_chastity_state_change(H, "standard_traits_invalid")
		return

	for(var/trait_id in traits_to_apply)
		ADD_TRAIT(H, trait_id, TRAIT_SOURCE_CHASTITY)

	notify_chastity_state_change(H, "standard_traits_applied")

// Shared physical lock-state mutation path for keys and lockpicks.
/obj/item/chastity/proc/set_chastity_locked_state(mob/living/carbon/human/H, should_lock, mob/user = null, obj/item/interaction_item = null, interaction_source = "manual", state_change_reason = "")
	if(!H || H.chastity_device != src)
		return FALSE

	var/new_locked_state = !!should_lock
	var/old_locked_state = locked
	locked = new_locked_state

	if(new_locked_state)
		ADD_TRAIT(H, TRAIT_CHASTITY_LOCKED, TRAIT_SOURCE_CHASTITY)
	else
		REMOVE_TRAIT(H, TRAIT_CHASTITY_LOCKED, TRAIT_SOURCE_CHASTITY)

	if(old_locked_state == new_locked_state)
		return FALSE

	if(!length(state_change_reason))
		state_change_reason = "lock_changed_[interaction_source]"

	SEND_SIGNAL(H, COMSIG_CARBON_CHASTITY_LOCK_CHANGED, user, interaction_item, new_locked_state, interaction_source)
	notify_chastity_state_change(H, state_change_reason)
	to_chat(H, new_locked_state ? span_warning(pick_chastity_string("chastity_lock_messages.json", "chastity_lock_click")) : span_notice(pick_chastity_string("chastity_lock_messages.json", "chastity_unlock_click")))
	return TRUE

/// Fires COMSIG_CARBON_CHASTITY_STATE_CHANGED on the wearer so mood effects stay in sync after any trait/mode change.
/obj/item/chastity/proc/notify_chastity_state_change(mob/living/carbon/human/H, reason = "")
	if(!H)
		return
	if(H.chastity_device == src)
		SEND_SIGNAL(H, COMSIG_CARBON_CHASTITY_STATE_CHANGED, src, reason)
		return
	refresh_chastity_mood_effects(H)

/// Returns TRUE if H has the Devotee virtue in either virtue slot.
/obj/item/chastity/proc/has_devotee_virtue(mob/living/carbon/human/H)
	if(!H?.client?.prefs)
		return FALSE
	if(istype(H.client.prefs.virtue, /datum/virtue/combat/devotee))
		return TRUE
	if(istype(H.client.prefs.virtuetwo, /datum/virtue/combat/devotee))
		return TRUE
	return FALSE

/// Returns TRUE if H's patron would consider chastity virtuous. Inhumen patrons and Eora do not.
/obj/item/chastity/proc/patron_approves_chastity(mob/living/carbon/human/H)
	if(!H?.patron)
		return FALSE
	if(istype(H.patron, /datum/patron/unveiled))
		return FALSE
	if(istype(H.patron, /datum/patron/concordat/miluse))
		return FALSE
	return TRUE

/**
 * STAGE 1 helper procs: this repo has no /datum/sex_controller ("sexcon") to host has_chastity_*() on, so
 * these live directly on the item and are queried by the reaction/guard components via source.chastity_device.
 * "penis"/"vagina" chastity means that specific organ is blocked; "cage"/"anal" specifically distinguish
 * a physically restrictive cage (vs. a purely insertable belt) and an anal shield, matching the semantics
 * Ratwood's TRAIT_CHASTITY_* list comment in chastity_standard_traits documents at the top of this file.
 */
/obj/item/chastity/proc/has_chastity_penis(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	return HAS_TRAIT(H, TRAIT_CHASTITY_FULL) || HAS_TRAIT(H, TRAIT_CHASTITY_CAGE) || HAS_TRAIT(H, TRAIT_CHASTITY_PENIS_BLOCKED)

/obj/item/chastity/proc/has_chastity_vagina(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	return HAS_TRAIT(H, TRAIT_CHASTITY_FULL) || HAS_TRAIT(H, TRAIT_CHASTITY_VAGINA_BLOCKED)

/obj/item/chastity/proc/has_chastity_anal(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	return HAS_TRAIT(H, TRAIT_CHASTITY_FULL) || HAS_TRAIT(H, TRAIT_CHASTITY_ANAL)

/// Specifically: is the wearer's penis under a restrictive cage (as opposed to just "blocked")? Used to gate
/// cage-fit flavor text (large-cock cage banks, etc.) that doesn't make sense for a non-cage device.
/obj/item/chastity/proc/has_chastity_cage(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	return HAS_TRAIT(H, TRAIT_CHASTITY_FULL) || HAS_TRAIT(H, TRAIT_CHASTITY_CAGE)

/// Strips all chastity-related mood stresses from H.
/obj/item/chastity/proc/clear_chastity_mood_effects(mob/living/carbon/human/H)
	if(!H)
		return
	H.remove_stress(/datum/stressevent/chastity_devout)
	H.remove_stress(/datum/stressevent/chastity_masochist)
	H.remove_stress(/datum/stressevent/chastity_church)
	H.remove_stress(/datum/stressevent/chastity_frustration)
	H.remove_stress(/datum/stressevent/chastity_flat_cramped)

// Controls chastity mood events based on traits, flaws, and other character conditions.
/obj/item/chastity/proc/refresh_chastity_mood_effects(mob/living/carbon/human/H)
	if(!H)
		return

	clear_chastity_mood_effects(H)

	if(H.chastity_device != src)
		return

	if((H.has_flaw(/datum/charflaw/addiction/godfearing) || has_devotee_virtue(H)) && patron_approves_chastity(H))
		H.add_stress(/datum/stressevent/chastity_devout)

	if(H.has_flaw(/datum/charflaw/addiction/masochist) && HAS_TRAIT(H, TRAIT_CHASTITY_SPIKED))
		H.add_stress(/datum/stressevent/chastity_masochist)

	if(H.mind?.assigned_role in GLOB.church_positions)
		H.add_stress(/datum/stressevent/chastity_church)

	if(H.has_flaw(/datum/charflaw/addiction/lovefiend) || istype(H.patron, /datum/patron/oldkin/hausvette))
		H.add_stress(/datum/stressevent/chastity_frustration)

	if(chastity_flat)
		var/obj/item/organ/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
		if(penis?.penis_size >= DEFAULT_PENIS_SIZE && penis?.sheath_type == SHEATH_TYPE_NONE)
			H.add_stress(/datum/stressevent/chastity_flat_cramped)
