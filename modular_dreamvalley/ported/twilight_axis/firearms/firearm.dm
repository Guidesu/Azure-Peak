// Ported from Twilight-Axis's modular_twilight_axis/firearms module. All
// player-facing text translated from Russian into English. This is the core
// black-powder weapon line (arquebus/handgonne/flintgonne/pistol/barker/mortar
// family) built on top of this repo's existing /obj/item/gun/ballistic base.
//
// Unlike the base ballistic class's magazine/bolt system, these guns are
// single-shot muzzleloaders: gunpowder is poured in, a ball is rammed down
// with a ramrod (or a fuse is attached), and the whole thing is consumed on
// firing. internal_magazine + BOLT_TYPE_NO_BOLT are used to represent the
// single chamber; process_fire()/attackby() are heavily overridden to
// implement the powder+ball+ramrod loading loop instead of the base
// class's magazine reload loop.
//
// The 9 class-specific job files (afreet, blackpowder_hunter, conquistador,
// corsair, guildmaster, guildsman, gunslinger, inquisitor, lord,
// manatarms_grenadier, marshal, orthodoxist, prince) are NOT included in
// this pass — flagged as a follow-up port once their job/outfit dependencies
// are separately verified against this repo's job framework.

/obj/effect/particle_effect/smoke/arquebus
	name = "smoke"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	pixel_x = -32
	pixel_y = -32
	opacity = FALSE
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = 0
	amount = 4
	lifetime = 4
	opaque = FALSE

/obj/effect/particle_effect/smoke/arquebus/fyre
	color = "#A66945"

/obj/effect/particle_effect/smoke/arquebus/thunder
	color = "#5C355C"

/obj/effect/particle_effect/smoke/arquebus/terror
	color = "#423030"

/obj/effect/particle_effect/smoke/arquebus/corrosive
	color = "#7D905E"

/obj/effect/particle_effect/smoke/arquebus/arcyne
	color = "#C487C8"

/obj/item/twilight_ramrod
	name = "ramrod"
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus_items.dmi'
	desc = "A ramrod used for reloading a firearm."
	icon_state = "ramrod"
	item_state = "ramrod"
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_SMALL

/obj/item/twilight_powderflask_empty
	name = "powderflask"
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus_items.dmi'
	desc = "A powderflask meant for conveniently reloading a firearm. Currently holds no powder."
	icon_state = "powderflask"
	item_state = "powderflask"
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_SMALL
	grid_width = 64
	grid_height = 32

/obj/item/twilight_powderflask
	name = "powderflask"
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus_items.dmi'
	desc = "A powderflask meant for conveniently reloading a firearm. Holds ordinary black gunpowder."
	var/gunpowder = "black gunpowder"
	var/charges = 30
	icon_state = "powderflask_black"
	item_state = "powderflask"
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_SMALL
	grid_width = 64
	grid_height = 32

/obj/item/twilight_powderflask/examine(mob/user)
	. = ..()
	switch(gunpowder)
		if("fyrepowder")
			. += span_bold("Ignites the target on impact.")
		if("holy fyrepowder")
			. += span_bold("Ignites the target with holy fire on impact. The effect is amplified against the undead.")
		if("thunderpowder")
			. += span_bold("Slows the target on impact and briefly stuns them.")
		if("corrosive gunpowder")
			. += span_bold("Coats the target in acid, dealing periodic damage to armor and health.")
		if("arcyne gunpowder")
			. += span_bold("Numbs the target on impact. If the target has a magical barrier, it will be instantly destroyed.")
		if("terrorpowder")
			. += span_bold("Deals double damage to any creature not controlled by a player.")
		if("psypowder")
			. += span_bold("Weakens and blinds the target with toxic vapors for several seconds.")
	. += span_bold("There is enough powder left for [charges] reloads.")

/obj/item/twilight_powderflask/fyre
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds fyrepowder, imbuing bullets with an incendiary effect."
	icon_state = "powderflask_fyre"
	gunpowder = "fyrepowder"
	charges = 16

/obj/item/twilight_powderflask/thunder
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds thunderpowder, imbuing bullets with a stunning effect."
	icon_state = "powderflask_thunder"
	gunpowder = "thunderpowder"
	charges = 16

/obj/item/twilight_powderflask/terror
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds powder of nightmares, making bullets deadlier against those of weak will."
	icon_state = "powderflask_terror"
	gunpowder = "terrorpowder"
	charges = 20

/obj/item/twilight_powderflask/corrosive
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds corrosive gunpowder, letting bullets eat through the target's armor."
	icon_state = "powderflask_corrosive"
	gunpowder = "corrosive gunpowder"
	charges = 10

/obj/item/twilight_powderflask/arcyne
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds arcane powder, making the weapon significantly more effective against mages."
	icon_state = "powderflask_arcyne"
	gunpowder = "arcyne gunpowder"
	charges = 10

/obj/item/twilight_powderflask/holyfyre
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds powder of holy fire, blessed with a shard of the comet Syon, to mercilessly strike down the enemies of the Allfather."
	icon_state = "powderflask_holyfyre"
	gunpowder = "holy fyrepowder"
	charges = 16

/obj/item/twilight_powderflask/volf
	name = "powderflask"
	desc = "A powderflask meant for conveniently reloading a firearm. Holds powder mixed with toxic dusts made specifically for hunting wolves. There is no blessing in it — its very existence is as vile as the runewolves it is meant to kill."
	icon_state = "powderflask_psy"
	gunpowder = "psypowder"
	charges = 30

/obj/item/gun/ballistic/twilight_firearm
	name = "Gunpowder weapon"
	desc = "IF YOU ARE SEEING THIS. REPORT THIS TO A DEV."
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebus.dmi'
	icon_state = "arquebus"
	item_state = "arquebus"
	force = 10
	force_wielded = 15
	possible_item_intents = list(/datum/intent/mace/strike/wood)
	gripped_intents = list(/datum/intent/shoot/twilight_firearm, /datum/intent/arc/twilight_firearm, INTENT_GENERIC)
	internal_magazine = TRUE
	mag_type = /obj/item/ammo_box/magazine/internal/twilight_firearm
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	bigboy = TRUE
	gripsprite = TRUE
	wlength = WLENGTH_LONG
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	randomspread = 1
	spread = 0
	wdefense = 3
	can_parry = TRUE
	minstr = 6
	walking_stick = TRUE
	experimental_onback = TRUE
	cartridge_wording = "bullet"
	load_sound = 'modular_dreamvalley/sound/twilight_firearms/musketload.ogg'
	fire_sound = 'modular_dreamvalley/sound/twilight_firearms/arquefire.ogg'
	anvilrepair = null
	smeltresult = /obj/item/ingot/steel
	bolt_type = BOLT_TYPE_NO_BOLT
	casing_ejector = FALSE
	associated_skill = /datum/skill/combat/staves
	var/spread_num = 10
	var/damfactor = 1
	var/critfactor = 1
	var/npcdamfactor = 2
	var/reloaded = FALSE
	var/silenced = FALSE
	var/load_time = 50
	var/gunpowder
	var/powder_per_reload = 1
	var/locktype = "Matchlock"
	var/match_delay = 10
	var/effective_range = 5
	var/obj/item/twilight_ramrod/myrod = null

	//Advanced icon stuff
	var/advanced_icon				//Default icon
	var/advanced_icon_r				//Cocked
	var/advanced_icon_s				//Fuse spent
	var/advanced_icon_f				//Fuse lit
	var/advanced_icon_norod			//Ramrod removed
	var/advanced_icon_r_norod		//Cocked and ramrod removed

/obj/item/gun/ballistic/twilight_firearm/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 6,"nx" = 7,"ny" = 6,"wx" = -2,"wy" = 3,"ex" = 1,"ey" = 3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -43,"sturn" = 43,"wturn" = 30,"eturn" = -30, "nflip" = 0, "sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = 2,"ex" = 8,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -45,"sturn" = 45,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = 70,"eturn" = 15,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/gun/ballistic/twilight_firearm/Initialize()
	. = ..()
	if(locktype == "Matchlock" || locktype == "Wheellock")
		myrod = new /obj/item/twilight_ramrod(src)

/obj/item/gun/ballistic/twilight_firearm/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	if(silenced)
		fire_sound = "modular_dreamvalley/sound/twilight_firearms/umbra_fire2.ogg"
	else
		switch(gunpowder)
			if("fyrepowder", "holy fyrepowder", "psypowder")
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/fyrepowder/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/fyrepowder/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/fyrepowder/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/fyrepowder/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/fyrepowder/arquefire5.ogg")
			if("thunderpowder")
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/thunderpowder/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/thunderpowder/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/thunderpowder/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/thunderpowder/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/thunderpowder/arquefire5.ogg")
			if("corrosive gunpowder")
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/corrpowder/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/corrpowder/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/corrpowder/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/corrpowder/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/corrpowder/arquefire5.ogg")
			if("arcyne gunpowder")
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/arcynepowder/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/arcynepowder/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/arcynepowder/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/arcynepowder/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/arcynepowder/arquefire5.ogg")
			if("terrorpowder")
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/terrorpowder/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/terrorpowder/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/terrorpowder/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/terrorpowder/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/terrorpowder/arquefire5.ogg")
			else
				fire_sound = pick("modular_dreamvalley/sound/twilight_firearms/arquefire.ogg", "modular_dreamvalley/sound/twilight_firearms/arquefire2.ogg", "modular_dreamvalley/sound/twilight_firearms/arquefire3.ogg",
							"modular_dreamvalley/sound/twilight_firearms/arquefire4.ogg", "modular_dreamvalley/sound/twilight_firearms/arquefire5.ogg")
	. = ..()

/obj/item/gun/ballistic/twilight_firearm/attack_right(mob/user)
	if(user.get_active_held_item())
		return
	else
		if(locktype == "Matchlock" || locktype == "Wheellock")
			if(myrod)
				playsound(src, "sound/items/sharpen_short1.ogg",  100, FALSE)
				to_chat(user, "<span class='warning'>I draw the ramrod from [src]!</span>")
				var/obj/item/twilight_ramrod/AM
				for(AM in src)
					user.put_in_hands(AM)
					myrod = null
				if(advanced_icon_norod)
					if(reloaded && advanced_icon_r_norod)
						icon = advanced_icon_r_norod
					else
						icon = advanced_icon_norod
			else
				to_chat(user, "<span class='warning'>There is no rod stowed in [src]!</span>")

/datum/intent/shoot/twilight_firearm
	chargedrain = 0

/datum/intent/shoot/twilight_firearm/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 95
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 20)
		//per block
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 0.1
	return chargetime

/datum/intent/arc/twilight_firearm
	chargetime = 1
	chargedrain = 0

/datum/intent/arc/twilight_firearm/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 90
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 20)
		//per block
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime

/obj/item/gun/ballistic/twilight_firearm/shoot_with_empty_chamber()
	playsound(src.loc, 'modular_dreamvalley/sound/twilight_firearms/musketcock.ogg', 100, FALSE)
	update_icon()

/obj/item/gun/ballistic/twilight_firearm/attack_self(mob/living/user)
	if(twohands_required)
		return
	if(altgripped || wielded) //Trying to unwield it
		ungrip(user)
		return
	if(alt_grips)
		altgrip(user)
	if(gripped_intents)
		wield(user)
	update_icon()

/obj/item/gun/ballistic/twilight_firearm/attackby(obj/item/A, mob/user, params)
	var/firearm_skill = (user?.mind ? user.get_skill_level(/datum/skill/combat/twilight_firearms) : 1)
	var/load_time_skill = load_time - (firearm_skill*5)

	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/V = A
		if(chambered)
			to_chat(user, "<span class='warning'>There is already a [chambered.name] in [src]!</span>")
			return
		if(!gunpowder)
			to_chat(user, "<span class='warning'>You must fill [src] with gunpowder first!</span>")
			return
		if(V.caliber != magazine.caliber)
			to_chat(user, "<span class='warning'>The [V.name] doesn't fit into [src]!</span>")
			return
		if((loc == user) && (user.get_inactive_held_item() != src))
			return
		if (bolt_type == BOLT_TYPE_NO_BOLT || internal_magazine)
			if (chambered && !chambered.BB)
				chambered.forceMove(drop_location())
				chambered = null
			var/num_loaded = magazine.attackby(A, user, params, TRUE)
			if (num_loaded)
				playsound(src, "modular_dreamvalley/sound/twilight_firearms/insert.ogg",  100, FALSE)
				user.visible_message("<span class='notice'>[user] forces a [V.name] down the barrel of [src].</span>")
				if(advanced_icon)
					if(!myrod && advanced_icon_norod)
						icon = advanced_icon_norod
					else
						icon = advanced_icon
				if (chambered == null && bolt_type == BOLT_TYPE_NO_BOLT)
					chamber_round()
				A.update_icon()
				update_icon()
			return
		user.update_inv_hands()
		return
	else if(istype(A, /obj/item/twilight_powderflask))
		var/obj/item/twilight_powderflask/W = A
		if(gunpowder)
			user.visible_message("<span class='notice'>The [name] is already filled with gunpowder!</span>")
			return
		else if(W.charges < powder_per_reload)
			user.visible_message("<span class='notice'>The [W.name] doesn't contain enough gunpowder to reload [src]!</span>")
			return
		else
			switch(W.gunpowder)
				if("fyrepowder", "holy fyrepowder", "psypowder")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/fyrepowder/pour_powder.ogg",  100, FALSE)
				if("thunderpowder")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/thunderpowder/pour_powder.ogg",  100, FALSE)
				if("corrosive gunpowder")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/corrpowder/pour_powder.ogg",  100, FALSE)
				if("arcyne gunpowder")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/arcynepowder/pour_powder.ogg",  100, FALSE)
				if("terrorpowder")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/terrorpowder/pour_powder.ogg",  100, FALSE)
				else
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/pour_powder.ogg",  100, FALSE)
			if(do_after(user, load_time_skill, src))
				user.visible_message("<span class='notice'>[user] fills [src] with [W.gunpowder].</span>")
				gunpowder = W.gunpowder
				W.charges = W.charges - powder_per_reload
				if(W.charges <= 0)
					qdel(W)
					var/obj/item/twilight_powderflask_empty/E = new /obj/item/twilight_powderflask_empty(get_turf(user))
					user.put_in_hands(E)
			return
	else if(istype(A, /obj/item/twilight_ramrod))
		if(locktype == "Matchlock" || locktype == "Wheellock")
			var/obj/item/twilight_ramrod/R=A
			if(!reloaded)
				if(chambered)
					user.visible_message("<span class='notice'>[user] begins ramming the [R.name] down the barrel of [src].</span>")
					playsound(src, "modular_dreamvalley/sound/twilight_firearms/ramrod.ogg",  100, FALSE)
					if(do_after(user, load_time_skill, src))
						user.visible_message("<span class='notice'>[user] has finished reloading [src].</span>")
						reloaded = TRUE
						if(advanced_icon_r_norod)
							icon = advanced_icon_r_norod
					return
			if(reloaded && !myrod)
				user.transferItemToLoc(R, src)
				myrod = R
				playsound(src, "modular_dreamvalley/sound/twilight_firearms/musketload.ogg",  100, FALSE)
				user.visible_message("<span class='notice'>[user] stows the [R.name] under the barrel of [src].</span>")
				if(advanced_icon)
					if(reloaded && advanced_icon_r)
						icon = advanced_icon_r
					else
						icon = advanced_icon
			if(!chambered && !myrod)
				user.transferItemToLoc(R, src)
				myrod = R
				playsound(src, "modular_dreamvalley/sound/twilight_firearms/musketload.ogg",  100, FALSE)
				user.visible_message("<span class='notice'>[user] stows the [R.name] under the barrel of [src] without chambering it.</span>")
				if(advanced_icon)
					if(reloaded && advanced_icon_r)
						icon = advanced_icon_r
					else
						icon = advanced_icon
			if(!myrod == null)
				to_chat(user, span_warning("There's already a [R.name] inside of the [name]."))
				return
	else if(istype(A, /obj/item/natural/bundle/fibers))
		var/obj/item/natural/bundle/fibers/W = A
		if(locktype == "Fuse")
			if(!reloaded)
				if(chambered)
					user.visible_message("<span class='notice'>[user] begins attaching the fuse to [src].</span>")
					playsound(src, "sound/foley/bandage.ogg",  100, FALSE)
					if(do_after(user, (load_time_skill * 0.8), src))
						user.visible_message("<span class='notice'>[user] has finished reloading [src].</span>")
						W.amount = W.amount - 1
						if(W.amount == 1)
							new /obj/item/natural/fibers(get_turf(user))
							qdel(W)
						reloaded = TRUE
						if(advanced_icon_r)
							icon = advanced_icon_r
					return
	else if(istype(A, /obj/item/natural/fibers))
		if(locktype == "Fuse")
			if(!reloaded)
				if(chambered)
					user.visible_message("<span class='notice'>[user] begins attaching the fuse to [src].</span>")
					playsound(src, "sound/foley/bandage.ogg",  100, FALSE)
					if(do_after(user, (load_time_skill * 0.8), src))
						user.visible_message("<span class='notice'>[user] has finished reloading [src].</span>")
						qdel(A)
						reloaded = TRUE
						if(advanced_icon_r)
							icon = advanced_icon_r
					return
	else if(istype(A, /obj/item/rogueweapon/hammer))
		var/repair_percent = 0.025 // 2.5% Repairing per hammer smack
		if(locate(/obj/machinery/anvil) in src.loc)
			repair_percent *= 2 // Double the repair amount if we're using an anvil
		var/exp_gained = 0
		var/repair_skill = (user?.mind ? user.get_skill_level(/datum/skill/craft/engineering) : 1)
		if((obj_integrity >= max_integrity) || !isturf(src.loc))
			return

		if(!src.ontable())
			to_chat(user, span_warning("I should put this on a table or an anvil first."))
			return

		if(repair_skill <= 0)
			if(HAS_TRAIT(user, TRAIT_SQUIRE_REPAIR))
				if(locate(/obj/machinery/anvil) in src.loc)
					repair_percent = 0.035
				//Squires can repair on tables, but less efficiently
				else if(src.ontable())
					repair_percent = 0.015
			else if(prob(30))
				repair_percent = 0.01
			else
				repair_percent = 0
		else
			repair_percent *= repair_skill

		playsound(src,'modular_dreamvalley/sound/twilight_firearms/arq_repair.ogg', 40, FALSE)
		if(repair_percent)
			repair_percent *= max_integrity
			exp_gained = min(obj_integrity + repair_percent, max_integrity) - obj_integrity
			obj_integrity = min(obj_integrity + repair_percent, max_integrity)
			if(repair_percent == 0.01) // If an inexperienced repair attempt has been successful
				to_chat(user, span_warning("You fumble your way into slightly repairing [src]."))
			else
				user.visible_message(span_info("[user] repairs [src]!"))
			if(obj_broken && obj_integrity == max_integrity)
				src.obj_fix()
			adjust_experience(user, /datum/skill/craft/engineering, exp_gained/2) //We gain as much exp as we fix divided by 2
			return
		else
			user.visible_message(span_warning("[user] fumbles trying to repair [src]!"))
			if(do_after(user, CLICK_CD_MELEE, target = src))
				attack_obj(src, user)
			return
	else
		. = ..()

/obj/item/gun/ballistic/twilight_firearm/examine(mob/user)
	. = ..()
	switch(locktype)
		if("Wheellock")
			. += span_info("This weapon is fitted with a wheellock mechanism. Before firing, it must be loaded with powder, a ball, and packed down with a ramrod.")
		if("Matchlock")
			. += span_info("This weapon is fitted with a matchlock mechanism. Before firing, it must be loaded with powder, a ball, and packed down with a ramrod.")
		if("Fuse")
			. += span_info("This weapon is fired by a lit fuse. Before firing, it must be loaded with powder, a ball, and the fuse itself.")
	. += span_info("Effective range: [effective_range]0 meters.")
	if(gunpowder)
		if(chambered)
			if(reloaded)
				. += span_bold("Cocked and ready to fire.")
			else
				. += span_bold("A ball is visible inside the weapon, but it is not yet cocked.")
		else
			. += span_bold("A powder charge is visible through the touch-hole, but no ball is loaded.")
	else
		. += span_bold("Unloaded.")

/obj/item/gun/ballistic/twilight_firearm/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)

	var/accident_chance = 0
	var/firearm_skill = (user?.mind ? user.get_skill_level(/datum/skill/combat/twilight_firearms) : 1)
	var/turf/knockback = get_ranged_target_turf(user, turn(user.dir, 180), rand(1,2))
	spread = (spread_num - firearm_skill)
	switch(firearm_skill)
		if(0)
			accident_chance = 80
		if(1)
			accident_chance = 50
		if(2)
			accident_chance = 30
		if(3)
			accident_chance = 10
		if(4)
			accident_chance = 10
		else
			accident_chance = 0
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/bullet/BB = CB.BB
		BB.gunpowder = gunpowder
	reloaded = FALSE
	if(advanced_icon)
		if(!myrod && advanced_icon_norod)
			icon = advanced_icon_norod
		else
			icon = advanced_icon
	spark_act()
	if(locktype == "Matchlock" || locktype == "Wheellock")
		..()
		if(!silenced)
			switch(gunpowder)
				if("fyrepowder", "holy fyrepowder")
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 1))
				if("thunderpowder", "psypowder")
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 1))
				if("corrosive gunpowder")
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 1))
				if("arcyne gunpowder")
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 1))
				if("terrorpowder")
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 1))
				else
					spawn (5)
						new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
					spawn (10)
						new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 2))
					spawn (16)
						new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
		for(var/mob/M in range(5, user))
			if(!M.stat)
				shake_camera(M, 3, 1)

		gunpowder = null
		if(prob(accident_chance) && bigboy)
			user.flash_fullscreen("whiteflash")
			user.apply_damage(rand(5,15), BURN, pick(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
			user.visible_message("<span class='danger'>[user] accidentally burnt themselves while firing the [src].</span>")
			user.emote("painscream")
			if(prob(60) && firearm_skill < 4)
				user.dropItemToGround(src)
				user.Knockdown(rand(15,30))
				user.Immobilize(30)
		if(prob(accident_chance) && bigboy)
			user.visible_message("<span class='danger'>[user] is knocked back by the recoil!</span>")
			user.throw_at(knockback, rand(1,2), 7)
			if(prob(accident_chance) && firearm_skill < 4)
				user.dropItemToGround(src)
				user.Knockdown(rand(15,30))
				user.Immobilize(30)
				if(firearm_skill < 3 && prob(50))
					var/def_zone = "[(user.active_hand_index == 2) ? "r" : "l" ]_arm"
					var/obj/item/bodypart/BP = user.get_bodypart(def_zone)
					BP.add_wound(/datum/wound/dislocation)
	else if(locktype == "Fuse")
		if(advanced_icon_f)
			icon = advanced_icon_f
		playsound(src, "modular_dreamvalley/sound/twilight_firearms/fuse.ogg", 100, FALSE)
		spawn(match_delay)
			..()
			if(advanced_icon_s)
				icon = advanced_icon_s
			if(!silenced)
				switch(gunpowder)
					if("fyrepowder", "holy fyrepowder")
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus/fyre(get_ranged_target_turf(user, user.dir, 1))
					if("thunderpowder", "psypowder")
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus/thunder(get_ranged_target_turf(user, user.dir, 1))
					if("corrosive gunpowder")
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus/corrosive(get_ranged_target_turf(user, user.dir, 1))
					if("arcyne gunpowder")
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus/arcyne(get_ranged_target_turf(user, user.dir, 1))
					if("terrorpowder")
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus/terror(get_ranged_target_turf(user, user.dir, 1))
					else
						spawn (1)
							new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
						spawn (5)
							new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 2))
						spawn (12)
							new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
			gunpowder = null
			for(var/mob/M in range(5, user))
				if(!M.stat)
					shake_camera(M, 3, 1)
			if(prob(accident_chance) && bigboy)
				user.flash_fullscreen("whiteflash")
				user.apply_damage(rand(5,15), BURN, pick(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
				user.visible_message(span_danger("[user] accidentally burnt themselves while firing the [src]."))
				user.emote("painscream")
				if(prob(60) && firearm_skill < 4)
					user.dropItemToGround(src)
					user.Knockdown(rand(15,30))
					user.Immobilize(30)
			if(prob(accident_chance) && bigboy)
				user.visible_message(span_danger("[user] is knocked back by the recoil!"))
				user.throw_at(knockback, rand(1,2), 7)
				if(prob(accident_chance) && firearm_skill < 4)
					user.dropItemToGround(src)
					user.Knockdown(rand(15,30))
					user.Immobilize(30)
					if(firearm_skill <= 2 && prob(50))
						var/def_zone = "[(user.active_hand_index == 2) ? "r" : "l" ]_arm"
						var/obj/item/bodypart/BP = user.get_bodypart(def_zone)
						BP.add_wound(/datum/wound/dislocation)

/obj/item/gun/ballistic/twilight_firearm/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()

/obj/item/gun/ballistic/twilight_firearm/can_shoot()
	if (!reloaded)
		return FALSE
	return ..()

/obj/item/ammo_box/magazine/internal/twilight_firearm
	name = "firearm internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/twilight_lead
	caliber = "lead_sphere"
	max_ammo = 1
	start_empty = TRUE

/obj/item/gun/ballistic/twilight_firearm/arquebus
	name = "arquebus rifle"
	desc = "A second-generation gunpowder weapon, firing armor-piercing lead balls."
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebus.dmi'
	icon_state = "arquebus"
	item_state = "arquebus"
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebus.dmi'
	advanced_icon_norod = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebus_norod.dmi'
	effective_range = 7

/obj/item/gun/ballistic/twilight_firearm/arquebus/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/huntingknife))
		user.visible_message(span_warning("[user] starts attaching a bayonet to [src]."))
		if(do_after(user, 6 SECONDS))
			var/obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet/P = new /obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(P)
			P.obj_integrity = src.obj_integrity
			qdel(src)
			qdel(I)
		else
			user.visible_message(span_warning("[user] stops attaching the bayonet to [src]."))
		return TRUE
	return ..()

/obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet
	name = "arquebus rifle"
	desc = "A second-generation gunpowder weapon, firing armor-piercing lead balls. Fitted with a bayonet for use in melee."
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebusbaoynet.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebusbaoynet.dmi'
	advanced_icon_norod = 'modular_dreamvalley/icons/twilight_firearms/arquebus/arquebusbayonet_norod.dmi'
	gripped_intents = list(/datum/intent/shoot/twilight_firearm, /datum/intent/arc/twilight_firearm, INTENT_GENERIC, /datum/intent/spear/thrust/militia)
	wdefense = 5

/obj/item/gun/ballistic/twilight_firearm/arquebus/decorated
	name = "decorated arquebus rifle"
	desc = "A true work of art disguised as a firearm. The stock and forend of this arquebus are adorned with gold plating and an inlaid ruby, and the barrel bears the inscription: \"Behold my works and tremble.\""
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/decorated_arquebus.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/decorated_arquebus.dmi'
	advanced_icon_norod = 'modular_dreamvalley/icons/twilight_firearms/arquebus/decorated_arquebus_norod.dmi'

/obj/item/gun/ballistic/twilight_firearm/arquebus/jagerrifle
	name = "jägerbüchse"
	desc = "A rare variant of the wheellock arquebus, produced by Grenzelhoft craftsmen for Freikorps jägers who distinguished themselves in battle. Lighter and less prone to wear than mass-produced models."
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerrifle.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerrifle.dmi'
	advanced_icon_norod = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerrifle_norod.dmi'
	locktype = "Wheellock"

/obj/item/gun/ballistic/twilight_firearm/arquebus/jagerrifle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/huntingknife))
		user.visible_message(span_warning("[user] starts attaching a bayonet to [src]."))
		if(do_after(user, 6 SECONDS))
			var/obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet/jagerrifle/P = new /obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet/jagerrifle(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(P)
			P.obj_integrity = src.obj_integrity
			qdel(src)
			qdel(I)
		else
			user.visible_message(span_warning("[user] stops attaching the bayonet to [src]."))
		return TRUE
	return ..()

/obj/item/gun/ballistic/twilight_firearm/arquebus/bayonet/jagerrifle
	name = "jägerbüchse"
	desc = "A rare variant of the wheellock arquebus, produced by Grenzelhoft craftsmen for Freikorps jägers who distinguished themselves in battle. Lighter and less prone to wear than mass-produced models. Fitted with a bayonet for use in melee."
	icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerriflebayonet.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerriflebayonet.dmi'
	advanced_icon_norod = 'modular_dreamvalley/icons/twilight_firearms/arquebus/jagerrifle_bayonet_norod.dmi'
	locktype = "Wheellock"

/obj/item/gun/ballistic/twilight_firearm/arquebus_pistol
	name = "arquebus pistol"
	desc = "A compact gunpowder weapon, firing armor-piercing lead balls. Its shorter barrel hurts its firepower, but the pistol's compact design lets it be worn on the hip."
	icon = 'modular_dreamvalley/icons/twilight_firearms/pistol/pistol.dmi'
	icon_state = "pistol"
	item_state = "pistol"
	pixel_y = 0
	pixel_x = 0
	force = 10
	possible_item_intents = list(/datum/intent/shoot/twilight_firearm, /datum/intent/arc/twilight_firearm, /datum/intent/mace/strike/wood)
	associated_skill = /datum/skill/combat/maces
	gripped_intents = null
	wlength = WLENGTH_SHORT
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	walking_stick = FALSE
	bigboy = FALSE
	gripsprite = FALSE
	cartridge_wording = "bullet"
	effective_range = 3
	wdefense = 0
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/pistol/pistol.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/pistol/pistol_r.dmi'
	advanced_icon_norod	= 'modular_dreamvalley/icons/twilight_firearms/pistol/pistol_norod.dmi'
	advanced_icon_r_norod = 'modular_dreamvalley/icons/twilight_firearms/pistol/pistol_r_norod.dmi'
	locktype = "Wheellock"
	inv_storage_delay = 1 SECONDS

/obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = -4,"nx" = 10,"ny" = -4,"wx" = -4,"wy" = -4,"ex" = 2,"ey" = -4, "northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 30,"sturn" = -30,"wturn" = -30,"eturn" = 30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.4,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/umbra
	name = "\"Umbra\""
	desc = "A compact, Otavan-made firearm. Its barrel is forged from blackened steel etched with a handful of simple runes. Thanks to its unusual construction and runic magic, the Umbra fires nearly silently, making it an ideal choice for Inquisition agents."
	silenced = TRUE
	critfactor = 1
	icon = 'modular_dreamvalley/icons/twilight_firearms/umbra/pistol.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/umbra/pistol.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/umbra/pistol_r.dmi'
	advanced_icon_norod	= 'modular_dreamvalley/icons/twilight_firearms/umbra/pistol_norod.dmi'
	advanced_icon_r_norod = 'modular_dreamvalley/icons/twilight_firearms/umbra/pistol_r_norod.dmi'
	effective_range = 5

/obj/item/gun/ballistic/twilight_firearm/handgonne
	name = "culverin"
	desc = "A heavy gunpowder weapon, firing large lead balls. It is not the size of the barrel that matters, but the size of the hole it makes in your enemy."
	icon = 'modular_dreamvalley/icons/twilight_firearms/handgonne/handgonne.dmi'
	icon_state = "handgonne"
	item_state = "handgonne"
	mag_type = /obj/item/ammo_box/magazine/internal/twilight_firearm/handgonne
	cartridge_wording = "cannonball"
	locktype = "Fuse"
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/handgonne/handgonne.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/handgonne/handgonne_r.dmi'
	advanced_icon_f	= 'modular_dreamvalley/icons/twilight_firearms/handgonne/handgonne_f.dmi'
	advanced_icon_s = 'modular_dreamvalley/icons/twilight_firearms/handgonne/handgonne_s.dmi'
	npcdamfactor = 3

/obj/item/ammo_box/magazine/internal/twilight_firearm/handgonne
	name = "handgonne internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball
	caliber = "cannonball"
	max_ammo = 1
	start_empty = TRUE

/obj/item/gun/ballistic/twilight_firearm/flintgonne
	name = "hakenbüchse"
	desc = "A first-generation gunpowder weapon, mass-produced by Grenzelhoft. Made from cheap, quickly-worn materials, which hurts its stopping power."
	icon = 'modular_dreamvalley/icons/twilight_firearms/flintgonne.dmi'
	icon_state = "flintgonne"
	item_state = "flintgonne"
	gripped_intents = list(/datum/intent/shoot/twilight_firearm/flintgonne, /datum/intent/arc/twilight_firearm/flintgonne, INTENT_GENERIC)
	smeltresult = /obj/item/ingot/iron
	damfactor = 0.9
	effective_range = 5

/obj/item/gun/ballistic/twilight_firearm/axtgonne
	name = "axtbüchse"
	desc = "A homemade first-generation firearm, which grew popular among Grenzelhoft jägers during the Twilight War. An axe blade is bolted to the weapon's barrel."
	icon = 'modular_dreamvalley/icons/twilight_firearms/axtbuchse/axtbuchse.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/axtbuchse/axtbuchse.dmi'
	advanced_icon_norod	= 'modular_dreamvalley/icons/twilight_firearms/axtbuchse/axtbuchse_norod.dmi'
	icon_state = "axegun"
	item_state = "axegun"
	damfactor = 0.9
	possible_item_intents = list(/datum/intent/axe/cut, /datum/intent/axe/chop)
	gripped_intents = list(/datum/intent/shoot/twilight_firearm, /datum/intent/arc/twilight_firearm, /datum/intent/axe/cut/long, /datum/intent/axe/chop/long)
	associated_skill = /datum/skill/combat/axes

/obj/item/gun/ballistic/twilight_firearm/axtgonne/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 0,"nx" = 7,"ny" = 0,"wx" = -2,"wy" = 0,"ex" = 1,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -93,"sturn" = -93,"wturn" = 90,"eturn" = 90, "nflip" = 0, "sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = -2,"ex" = 8,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -15,"sturn" = 15,"wturn" = -15,"eturn" = 15,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = -1,"sy" = 0,"nx" = 0,"ny" = 0,"wx" = 2,"wy" = 0,"ex" = 0,"ey" = 0,"nturn" = 45,"sturn" = -45,"wturn" = 45,"eturn" = -45,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/datum/intent/shoot/twilight_firearm/flintgonne/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		newtime = newtime + 105
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 20)
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 5
	return chargetime

/datum/intent/arc/twilight_firearm/flintgonne/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		newtime = newtime + 100
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 20)
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime

/obj/item/gun/ballistic/twilight_firearm/barker
	name = "barker"
	desc = "One of the first firearms produced by Otavan craftsmen at the start of the century before last. Due to its low power and accuracy, it is now used mostly by hunters."
	icon = 'modular_dreamvalley/icons/twilight_firearms/barker.dmi'
	icon_state = "barker"
	item_state = "barker"
	gripped_intents = list(/datum/intent/shoot/twilight_firearm/flintgonne, /datum/intent/arc/twilight_firearm/flintgonne, INTENT_GENERIC)
	locktype = "Fuse"
	smeltresult = /obj/item/ingot/iron
	damfactor = 0.7
	critfactor = 0.3
	npcdamfactor = 4
	effective_range = 3
	match_delay = 4

/obj/item/gun/ballistic/twilight_firearm/handgonne/purgatory
	name = "\"Purgatory\""
	desc = "An advanced firearm of the Otavan Order of the Black Powder, notorious on the battlefield for its destructive power. This hand cannon comes into play when a single argument against heresy simply isn't enough."
	icon = 'modular_dreamvalley/icons/twilight_firearms/purgatory/purgatory.dmi'
	icon_state = "purgatory"
	item_state = "purgatory"
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/purgatory/purgatory.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/purgatory/purgatory_r.dmi'
	advanced_icon_f	= 'modular_dreamvalley/icons/twilight_firearms/purgatory/purgatory_s.dmi'
	advanced_icon_s = 'modular_dreamvalley/icons/twilight_firearms/purgatory/purgatory_s.dmi'
	gripped_intents = list(/datum/intent/shoot/twilight_firearm, /datum/intent/arc/twilight_firearm, INTENT_GENERIC, /datum/intent/spear/thrust/militia)
	smeltresult = /obj/item/ingot/silver
	is_silver = TRUE
	force = 15
	force_wielded = 20
	wdefense = 5
	match_delay = 8

/obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/mortar
	name = "hand mortar"
	desc = "A hand-held mortar with a bronze barrel, further secured to its carriage with a sturdy leather strap. Fires grapeshot and balls at short range and with reduced force. Often used by privateers sailing under Grenzelhoft's flag."
	pixel_y = 0
	pixel_x = 0
	damfactor = 0.8
	npcdamfactor = 2
	mag_type = /obj/item/ammo_box/magazine/internal/twilight_firearm/mortar
	cartridge_wording = "cannonball"
	smeltresult = /obj/item/ingot/bronze
	icon_state = "mortar"
	item_state = "mortar"
	icon = 'modular_dreamvalley/icons/twilight_firearms/mortar/mortar.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/mortar/mortar.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/mortar/mortar_r.dmi'
	advanced_icon_norod	= 'modular_dreamvalley/icons/twilight_firearms/mortar/mortar_norod.dmi'
	advanced_icon_r_norod = 'modular_dreamvalley/icons/twilight_firearms/mortar/mortar_r_norod.dmi'

/obj/item/ammo_box/magazine/internal/twilight_firearm/mortar
	name = "mortar internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/twilight_cannonball/grapeshot
	caliber = "cannonball"
	max_ammo = 1
	start_empty = TRUE

/obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/mortar/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5,"sx" = -10,"sy" = -8,"nx" = 13,"ny" = -8,"wx" = -8,"wy" = -7,"ex" = 7,"ey" = -8,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 30,"sturn" = -30,"wturn" = -30,"eturn" = 30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.4,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/gun/ballistic/twilight_firearm/barker/barker_light
	name = "barker with lamptern"
	desc = "One of the first firearms produced by Otavan craftsmen at the start of the century before last. Due to its low power and accuracy, it is now used mostly by hunters. This one now comes with a lantern!"
	icon = 'modular_dreamvalley/icons/twilight_firearms/barker_light.dmi'
	icon_state = "barker_light"
	item_state = "barker_light"
	light_system = MOVABLE_LIGHT
	light_outer_range = 7
	light_power = 1
	light_color = "#f5a885"

/obj/item/gun/ballistic/twilight_firearm/barker/barker_light/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 6,"nx" = 7,"ny" = 6,"wx" = -2,"wy" = 3,"ex" = 1,"ey" = 3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -43,"sturn" = 43,"wturn" = 30,"eturn" = -30, "nflip" = 0, "sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = 2,"ex" = 8,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -45,"sturn" = 45,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = -15,"eturn" = -70,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 6,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/gun/ballistic/twilight_firearm/hunt_arquebus
	name = "hunter's arquebus"
	desc = "A fairly convenient variant of the wheellock arquebus with a bayonet, thin and long enough to double as a spear. Its lengthened barrel allows firing at greater distances, but costs a good deal of the ball's stopping power. A frequent choice among the nobility."
	damfactor = 0.7
	critfactor = 0.4
	npcdamfactor = 4
	effective_range = 4
	wdefense = 5
	walking_stick = FALSE
	gripped_intents = list(/datum/intent/shoot/twilight_firearm/flintgonne, /datum/intent/arc/twilight_firearm/flintgonne, /datum/intent/spear/thrust, INTENT_GENERIC)
	icon_state = "harquebus"
	item_state = "harquebus"
	icon = 'modular_dreamvalley/icons/twilight_firearms/harquebus/harquebus.dmi'
	advanced_icon = 'modular_dreamvalley/icons/twilight_firearms/harquebus/harquebus.dmi'
	advanced_icon_r = 'modular_dreamvalley/icons/twilight_firearms/harquebus/harquebus_r.dmi'
	advanced_icon_norod	= 'modular_dreamvalley/icons/twilight_firearms/harquebus/harquebus_norod.dmi'
