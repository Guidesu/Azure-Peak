/obj/item/roguekey/chastity
	name = "chastity key"
	desc = "A key cut for one chastity device."
	icon_state = "mazekey"

/obj/item/roguekey/chastity/attack_self(mob/user)
	if(!ishuman(user))
		return ..()
	return attack(user, user, user.zone_selected)

/obj/item/roguekey/chastity/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target == user && ishuman(user))
		return attack(user, user, user.zone_selected)
	return ..()

/obj/item/roguekey/chastity/attack(mob/M, mob/user, def_zone)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
		to_chat(user, span_warning("[H]'s groin is covered. I can't reach the lock."))
		return TRUE
	var/obj/item/chastity/device = H.chastity_device
	if(!device)
		to_chat(user, span_warning("[H] is not wearing a chastity device."))
		return TRUE
	if(!device.lockable)
		to_chat(user, span_warning(device.get_lock_denial_string()))
		playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
		return TRUE
	if(device.lockhash != lockhash)
		to_chat(user, span_warning("This key does not fit [H]'s chastity device."))
		playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
		return TRUE

	var/new_locked_state = !device.locked
	if(SEND_SIGNAL(H, COMSIG_CARBON_CHASTITY_LOCK_INTERACT, user, src, new_locked_state, "key") & COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK)
		to_chat(user, span_warning(device.get_lock_denial_string()))
		return TRUE
	device.set_chastity_locked_state(H, new_locked_state, user, src, "key")
	to_chat(user, span_notice(new_locked_state ? "The chastity device locks." : "The chastity device unlocks."))
	playsound(src, 'sound/foley/doors/lock.ogg', 100)
	return TRUE
