/**
 * Ported from Ratwood-2.0's modular/code/game/objects/items/lewd/chastity/chastity_equip.dm — chastity_collar
 * port, Stage 1. Only the STANDARD (non-cursed) equip/unequip flow is ported; the cursed-device equip path
 * (collar-master binding, apply_cursed_state, etc.) is stubbed out below with a clear TODO, since the slave
 * collar system is an explicitly later stage.
 *
 * Also drops the werewolf-species check from can_cage_target() and the surrendering/collar-equip-speed logic
 * from the cursed branch — both were collar/species-adjacent branches this repo either doesn't have wired up
 * the same way (no /mob/living/carbon/human/species/werewolf transform-lock relevant here yet) or that belong
 * entirely to the cursed path this stage isn't porting.
 */

// Self-equip flow: validates wearer state, then applies standard chastity setup.
/obj/item/chastity/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.client?.prefs && !H.client.prefs.chastenable)
		to_chat(user, span_warning("I have chastity content disabled."))
		return
	// Spiked devices are extreme content — require the wearer's explicit opt-in.
	if((TRAIT_CHASTITY_SPIKED in GLOB.chastity_standard_traits[chastity_type + 1]) && (H.client?.prefs && !H.client.prefs.extreme_erp))
		to_chat(user, span_warning("Eora intervenes. I cannot equip a spiked device."))
		return
	if(!can_cage_target(H, user))
		return
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
		to_chat(user, span_warning("My groin is not accessible!"))
		return
	if(H.chastity_device)
		to_chat(user, span_warning("I am already wearing a chastity device!"))
		return
	if(!chastity_genital_check(H))
		to_chat(user, span_warning("I don't have the required genitalia for the [src]."))
		return
	if(chastity_cursed)
		// TODO Stage 2 (slave collar): cursed devices equip through the collar-master binding flow, not here.
		to_chat(user, span_warning("This device cannot be equipped yet."))
		return
	ensure_chastity_feature(H)
	user.visible_message(span_notice("I attempt to chasten my genitals with the [src]..."))
	if(do_after(user, 50, needhand = 1, target = H))
		equip_standard_chastity(H, user)
	..()

// Equip-other flow: handles standard devices. Cursed devices are stubbed — see TODO below.
/obj/item/chastity/attack(mob/M, mob/user, def_zone)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(H.client?.prefs && !H.client.prefs.chastenable)
		to_chat(user, span_warning("Eora intervenes. They have chastity content disabled."))
		return
	if(user?.client?.prefs && !user.client.prefs.chastenable)
		to_chat(user, span_warning("I have chastity content disabled."))
		return
	// Spiked devices are extreme content — the wearer must have explicitly opted in.
	if((TRAIT_CHASTITY_SPIKED in GLOB.chastity_standard_traits[chastity_type + 1]) && (H.client?.prefs && !H.client.prefs.extreme_erp))
		to_chat(user, span_warning("Eora intervenes. They cannot be fitted with a spiked device."))
		return
	if(!can_cage_target(H, user))
		return
	if(H.chastity_device == src)
		attack_self(user)
		return
	if(H.chastity_device)
		to_chat(user, span_warning("[H] is already wearing a chastity device!"))
		return
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN))
		to_chat(user, span_warning("The groin area is not accessible!"))
		return
	if(!chastity_genital_check(H))
		to_chat(user, span_warning("[H] does not have the required genitalia for the [src]."))
		return
	if(chastity_cursed)
		// TODO Stage 2 (slave collar): cursed devices equip through the collar-master binding flow
		// (chastity_master imprinting, /datum/component/collar_master, apply_cursed_state, etc.) — none of
		// that exists in this repo yet and is explicitly out of scope for Stage 1. Ratwood's full cursed
		// equip branch (do_after gated by surrendering status, collar-master pet binding, cursed_front_mode
		// setup) is intentionally NOT ported here.
		to_chat(user, span_warning("[H] cannot be fitted with this device yet."))
		return
	user.visible_message(span_notice("[user] tries to put the [src] on [H]..."))
	ensure_chastity_feature(H)
	if(do_after(user, 50, needhand = 1, target = H))
		equip_standard_chastity(H, user)
	..()

// Shared helper for standard equip path: visual attach, ownership setup, key spawn, and traits.
/obj/item/chastity/proc/equip_standard_chastity(mob/living/carbon/human/H, mob/user)
	playsound(loc, 'sound/foley/equip/equip_armor_plate.ogg', 30, TRUE, -2)
	if(!attach_chastity_feature(H))
		return FALSE
	finalize_chastity_equip(H)
	generate_chastity_key(user, H)
	apply_standard_chastity_traits(H)
	return TRUE

// Unequips the device and removes all chastity-related state/traits from the wearer.
/obj/item/chastity/proc/remove_chastity(mob/living/carbon/human/H)
	if(H.chastity_device != src)
		return
	var/mob/living/carbon/human/old_wearer = H
	var/datum/component/intimate_action_guard/chastity/action_guard_component = GetComponent(/datum/component/intimate_action_guard/chastity)
	if(action_guard_component)
		action_guard_component.unbind_from_wearer(H)
	var/datum/component/intimate_reaction/chastity_receive_flavor/reaction_component = GetComponent(/datum/component/intimate_reaction/chastity_receive_flavor)
	if(reaction_component)
		reaction_component.unbind_from_wearer(H)
	clear_chastity_mood_effects(H)
	UnregisterSignal(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT)
	UnregisterSignal(H, COMSIG_CARBON_CHASTITY_STATE_CHANGED)
	chastity_move_counter = 0
	var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(chest && chastity_feature)
		chest.remove_bodypart_feature(chastity_feature)
	H.chastity_device = null
	chastity_feature = null
	chastity_victim = null
	REMOVE_TRAIT(H, TRAIT_CHASTITY_FULL, TRAIT_SOURCE_CHASTITY)
	REMOVE_TRAIT(H, TRAIT_CHASTITY_CAGE, TRAIT_SOURCE_CHASTITY)
	REMOVE_TRAIT(H, TRAIT_CHASTITY_PENIS_BLOCKED, TRAIT_SOURCE_CHASTITY)
	REMOVE_TRAIT(H, TRAIT_CHASTITY_VAGINA_BLOCKED, TRAIT_SOURCE_CHASTITY)
	REMOVE_TRAIT(H, TRAIT_CHASTITY_ANAL, TRAIT_SOURCE_CHASTITY)
	REMOVE_TRAIT(H, TRAIT_CHASTITY_SPIKED, TRAIT_SOURCE_CHASTITY)
	if(locked)
		REMOVE_TRAIT(H, TRAIT_CHASTITY_LOCKED, TRAIT_SOURCE_CHASTITY)
		locked = FALSE
	// STAGE 1: cursed-unbinding cleanup (cleanup_cursed_binding) intentionally not ported — chastity_cursed
	// devices don't equip in Stage 1 (see attack()/attack_self() above), so H is never in that state here.
	old_wearer.update_body_parts(TRUE)
	old_wearer.update_inv_belt()

/**
 * Emergency physical removal for locked devices using hammer & chisel.
 * Hard mode blocks this path via COMSIG_CARBON_CHASTITY_LOCK_INTERACT.
 */
/obj/item/chastity/proc/attempt_forced_removal(mob/living/carbon/human/H, mob/user)
	if(!H || !user)
		return FALSE
	if(H.chastity_device != src)
		return FALSE
	if(!locked)
		to_chat(user, span_notice("The device is already unlocked."))
		return FALSE
	if(!lockable)
		to_chat(user, span_warning("This chastity device cannot be forced open this way."))
		return FALSE
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
		to_chat(user, span_warning("I can't reach the lock while [H]'s groin is covered."))
		return FALSE
	if(SEND_SIGNAL(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT, user, null, FALSE, "forced_removal") & COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK)
		to_chat(user, span_warning(get_lock_denial_string()))
		playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
		return TRUE

	var/success_chance = 25
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		success_chance += (U.STALUC - 10) * 4
	success_chance = clamp(success_chance, 5, 80)

	user.visible_message(span_warning("[user] braces a chisel against [H]'s chastity lock and starts hammering!"), span_warning("I brace a chisel against [H]'s chastity lock and start hammering!"))
	while(H.chastity_device == src && locked)
		if(!do_after(user, 60, needhand = 1, target = H))
			return TRUE
		if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
			to_chat(user, span_warning("I lose access to the lock and have to stop."))
			return TRUE
		if(SEND_SIGNAL(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT, user, null, FALSE, "forced_removal") & COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK)
			to_chat(user, span_warning(get_lock_denial_string()))
			playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
			return TRUE

		playsound(get_turf(H), 'sound/combat/hits/bladed/genstab (1).ogg', 45, TRUE)
		H.apply_damage(rand(8,16), BRUTE, BODY_ZONE_PRECISE_GROIN)

		if(prob(35) && ishuman(user))
			var/mob/living/carbon/human/U = user
			U.apply_damage(rand(2,6), BRUTE, pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND))
			to_chat(user, span_warning("The chisel slips and nicks my hand."))

		if(prob(success_chance))
			user.visible_message(span_notice("[user] finally pries [H]'s chastity device open."), span_notice("I finally pry the chastity device open."))
			locked = FALSE
			REMOVE_TRAIT(H, TRAIT_CHASTITY_LOCKED, TRAIT_SOURCE_CHASTITY)
			remove_chastity(H)
			if(!user.put_in_hands(src))
				forceMove(get_turf(H))

			// Luck-scaled chisel-slip: when the lock finally gives, the sudden release can drag
			// the blade edge through whatever is still trapped beneath it.
			var/slip_chance = clamp(10 + (10 - H.STALUC) * 2, 2, 22)
			if(prob(slip_chance))
				var/obj/item/organ/penis_organ = H.getorganslot(ORGAN_SLOT_PENIS)
				var/obj/item/organ/vagina_organ = H.getorganslot(ORGAN_SLOT_VAGINA)
				var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
				var/turf/drop_turf = get_turf(H)

				if(penis_organ)
	// STAGE 1: Ratwood's dedicated modular/sound/masomoans/agony/CBTScream*.ogg files don't exist in this repo;
					// substituted with this repo's generic gendered pain-scream banks (sound/vo/*/gen/painscream *.ogg).
					if(prob(20) && H.client?.prefs?.extreme_erp)
						H.visible_message(span_userdanger("As the lock finally gives, [user]'s chisel catches [H.p_their()] trapped prick on the way out — the edge tears through flesh and root, ripping it free alongside the falling device."))
						playsound(drop_turf, pick('sound/vo/male/gen/painscream (1).ogg', 'sound/vo/male/gen/painscream (2).ogg'), 85, FALSE, 2)
						H.add_splatter_floor(drop_turf)
						penis_organ.Remove(H)
						penis_organ.forceMove(drop_turf)
					else if(chest && !chest.has_wound(/datum/wound/cbt))
						H.visible_message(span_userdanger("As the lock gives, [user]'s chisel bites into [H.p_their()] stones — the sudden jolt of metal twisting through [H.p_their()] groin as the device drops free."))
						playsound(drop_turf, pick('sound/vo/male/gen/painscream (1).ogg', 'sound/vo/male/gen/painscream (2).ogg'), 85, FALSE, 2)
						H.add_splatter_floor(drop_turf)
						chest.add_wound(/datum/wound/cbt)
				else if(vagina_organ && chest && !chest.has_wound(/datum/wound/cbt))
					H.visible_message(span_userdanger("As the lock gives, the chisel catches [H.p_their()] exposed slit — the device's sudden release dragging the edge through tender flesh and leaving a ragged wound."))
					playsound(drop_turf, pick('sound/vo/female/gen/painscream (1).ogg', 'sound/vo/female/gen/painscream (2).ogg'), 85, FALSE, 2)
					H.add_splatter_floor(drop_turf)
					chest.add_wound(/datum/wound/cbt)

			return TRUE
		else
			to_chat(user, span_warning("The lock holds. I need another strike."))

	return TRUE

// Hooks wearer state signals; movement sound and messaging are handled by the intimate reaction component.
/obj/item/chastity/proc/register_wearer_jingle(mob/living/carbon/human/H)
	if(!H)
		return
	UnregisterSignal(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT)
	RegisterSignal(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT, PROC_REF(on_chastity_lock_interact))
	UnregisterSignal(H, COMSIG_CARBON_CHASTITY_STATE_CHANGED)
	RegisterSignal(H, COMSIG_CARBON_CHASTITY_STATE_CHANGED, PROC_REF(on_chastity_state_changed))
	chastity_move_counter = 0

// Shared state-change signal callback for all chastity trait toggles and mode switches.
/obj/item/chastity/proc/on_chastity_state_changed(datum/source, obj/item/chastity/device, reason)
	SIGNAL_HANDLER
	if(device != src || source != chastity_victim)
		return
	refresh_chastity_mood_effects(chastity_victim)
	// STAGE 1: update_cursed_visual() intentionally not ported — cursed devices don't equip in this stage.

// Failsafe cleanup: if item is deleted while worn, forcibly unapply all wearer state.
/obj/item/chastity/Destroy()
	detach_toy()
	if(chastity_victim)
		remove_chastity(chastity_victim)
	return ..()
