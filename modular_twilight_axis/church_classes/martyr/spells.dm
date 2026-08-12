/obj/effect/martyr_weapon_manifest
	name = ""
	anchored = TRUE
	density = FALSE
	mouse_opacity = FALSE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER

/obj/effect/proc_holder/spell/targeted/martyr_select_weapon
	name = "Choose divine weapon"
	desc = "Choose the weapon that the Ten will send down to you from the heavens when you offer your prayer."
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	recharge_time = 0.5 SECONDS
	chargedloop = /datum/looping_sound/invokegen
	action_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	action_icon_state = "martyr_summon"
	overlay_state = "martyr_summon"
	overlay_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	invocation_type = "none"
	spell_tier = 2
	cost = 1

	var/selected_weapon = /obj/item/rogueweapon/sword/long/martyr
	var/list/selected_invocations = list("Astrata, place the sword of your judgment in my hand!")
	var/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/summon_weapon

/obj/effect/proc_holder/spell/targeted/martyr_select_weapon/proc/apply_manifest_sprite(obj/effect/martyr_weapon_manifest/manifest)
	if(!manifest)
		return

	switch(selected_weapon)
		if(/obj/item/rogueweapon/sword/long/martyr)
			manifest.icon = 'icons/roguetown/weapons/swords64.dmi'
			manifest.icon_state = "martyrsword"

		if(/obj/item/rogueweapon/greataxe/steel/doublehead/martyr)
			manifest.icon = 'icons/roguetown/weapons/axes64.dmi'
			manifest.icon_state = "martyraxe"

		if(/obj/item/rogueweapon/mace/goden/martyr)
			manifest.icon = 'icons/roguetown/weapons/blunt64.dmi'
			manifest.icon_state = "martyrmace"

		if(/obj/item/rogueweapon/spear/partizan/martyr)
			manifest.icon = 'icons/roguetown/weapons/polearms64.dmi'
			manifest.icon_state = "martyrtrident"

		if(/obj/item/rogueweapon/halberd/bardiche/scythe/martyr)
			manifest.icon = 'modular_twilight_axis/icons/roguetown/weapons/polearms64.dmi'
			manifest.icon_state = "martyrscyth"

		else
			manifest.icon = 'modular_twilight_axis/icons/roguetown/weapons/polearms64.dmi'
			manifest.icon_state = "martyrscyth"

/obj/effect/proc_holder/spell/targeted/martyr_select_weapon/cast(list/targets, mob/user)
	. = ..()

	var/list/weapons_of_choice = list(
		"Divine Sword",
		"Divine Axe",
		"Divine Mace",
		"Divine Trident",
		"Divine Scythe",
	)

	var/chosen_weapon = tgui_input_list(user, "Which relic will answer your oath?", "MARTYR'S WEAPON", weapons_of_choice)
	if(!chosen_weapon)
		return FALSE

	switch(chosen_weapon)
		if("Divine Sword")
			selected_weapon = /obj/item/rogueweapon/sword/long/martyr
			selected_invocations = list("Astrata, place the sword of your judgment in my hand!")

		if("Divine Axe")
			selected_weapon = /obj/item/rogueweapon/greataxe/steel/doublehead/martyr
			selected_invocations = list("Ravox, bless me with a weapon of strength!")

		if("Divine Mace")
			selected_weapon = /obj/item/rogueweapon/mace/goden/martyr
			selected_invocations = list("Malum, forge me a mace of unyielding will!")

		if("Divine Trident")
			selected_weapon = /obj/item/rogueweapon/spear/partizan/martyr
			selected_invocations = list("Abyssor, grant me a trident from the depths of the abyss!")

		if("Divine Scythe")
			selected_weapon = /obj/item/rogueweapon/halberd/bardiche/scythe/martyr
			selected_invocations = list("From roots and vine, Dendor, weave me a weapon!")

	if(summon_weapon)
		summon_weapon.invocations = selected_invocations
		summon_weapon.sync_weapon_button(user)

	return TRUE

/obj/effect/proc_holder/spell/targeted/martyr_select_weapon/proc/get_weapon_ui_state()
	switch(selected_weapon)
		if(/obj/item/rogueweapon/sword/long/martyr)
			return "martyrsword"
		if(/obj/item/rogueweapon/greataxe/steel/doublehead/martyr)
			return "martyraxe"
		if(/obj/item/rogueweapon/mace/goden/martyr)
			return "martyrmace"
		if(/obj/item/rogueweapon/spear/partizan/martyr)
			return "martyrtrident"
		if(/obj/item/rogueweapon/halberd/bardiche/scythe/martyr)
			return "martyrscyth"

	return "martyrsword"

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon
	name = "Summon divine weapon"
	desc = "Summons the chosen weapon from the heavens into your hands."
	clothes_req = FALSE
	recharge_time = 30 SECONDS
	chargedloop = /datum/looping_sound/invokegen

	action_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	action_icon_state = "spell0"
	action_background_icon_state = "bg_spell"

	overlay_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	overlay_state = "martyrsword"
	overlay_alpha = 255

	invocations = list("Astrata, place the sword of your judgment in my hand!")
	invocation_type = "shout"
	spell_tier = 2
	cost = 10

	var/obj/effect/proc_holder/spell/targeted/martyr_select_weapon/weapon_select

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/on_gain(mob/living/user)
	. = ..()
	sync_weapon_button(user)

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/proc/sync_weapon_button(mob/user)
	if(!weapon_select)
		return

	var/new_state = weapon_select.get_weapon_ui_state()

	action_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	action_icon_state = "spell0"
	action_background_icon_state = "bg_spell"
	overlay_icon = 'modular_twilight_axis/church_classes/icons/ui.dmi'
	overlay_state = new_state
	overlay_alpha = 255

	if(action)
		if(user?.hud_used && action.viewers && action.viewers[user.hud_used])
			refresh_one_weapon_button(action.viewers[user.hud_used])
		else
			for(var/datum/hud/H as anything in action.viewers)
				refresh_one_weapon_button(action.viewers[H])

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/proc/lightning_summon_fx(mob/living/carbon/human/user)
	for(var/mob/living/carbon/M in viewers(world.view, user))
		M.lightning_flashing = TRUE
		M.update_sight()
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, reset_lightning)), 2)

	var/turf/T = get_step(get_step(user, NORTH), NORTH)
	if(T)
		T.Beam(user, icon_state = "lightning[rand(1,12)]", time = 5)

	playsound(user, 'sound/magic/lightning.ogg', 100, FALSE)

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!user)
		return

	if(user.real_name in GLOB.excommunicated_players)
		to_chat(user, span_warning("The Ten have turned away from me. The relic will not answer me."))
		return

	if(!weapon_select || !weapon_select.selected_weapon)
		to_chat(user, span_warning("I cannot focus on the relic."))
		return

	if(martyr_ult_active(user))
		to_chat(user, span_warningbig("I cannot summon another relic right now!"))
		return

	var/datum/component/martyrweapon/current_component = get_martyr_component_for(user)
	if(current_component && current_component.is_active)
		return

	var/obj/item/current_relic = SSroguemachine.martyrweapon
	if(current_relic)
		var/datum/component/martyrweapon/old_component = current_relic.GetComponent(/datum/component/martyrweapon)
		if(old_component && old_component.is_active)
			to_chat(user, span_warning("The current relic is still active and cannot be recalled."))
			return
		if(hascall(current_relic, "anti_stall"))
			call(current_relic, "anti_stall")()

	. = ..()

	user.visible_message(
		span_warning("[user] raises a hand to the heavens, and lightning strikes down upon them!"),
		span_warning("I raise my hand to the heavens and call upon the relic of the Ten!")
	)

	lightning_summon_fx(user)

	var/obj/effect/martyr_weapon_manifest/manifest = new
	weapon_select.apply_manifest_sprite(manifest)
	manifest.pixel_x = (user.used_hand == 1) ? -10 : 10
	manifest.pixel_y = 96
	manifest.alpha = 0

	user.vis_contents += manifest

	animate(manifest, alpha = 255, pixel_y = 48, time = 3)
	animate(pixel_y = 6, time = 6)
	animate(alpha = 0, pixel_y = -2, time = 2)

	sleep(1.1 SECONDS)

	if(user && (manifest in user.vis_contents))
		user.vis_contents -= manifest
	qdel(manifest)

	var/obj/item/rogueweapon/spawned_weapon = new weapon_select.selected_weapon(user.loc)

	if(user.put_in_hands(spawned_weapon, del_on_fail = TRUE))
		to_chat(user, span_notice("The relic descends into my hand with a thunderous crash."))
	else
		to_chat(user, span_warning("My hands are full! The relic crashes to the ground."))

/obj/effect/proc_holder/spell/invoked/martyr_summon_weapon/proc/refresh_one_weapon_button(atom/movable/screen/movable/action_button/B)
	if(!B)
		return

	B.icon = 'icons/mob/actions/roguespells.dmi'
	B.icon_state = "bg_spell"

	B.cut_overlays(TRUE)

	if(overlay_state)
		var/mutable_appearance/weapon_overlay = mutable_appearance(
			'modular_twilight_axis/church_classes/icons/ui.dmi',
			overlay_state,
			layer = B.layer + 0.2
		)
		weapon_overlay.alpha = overlay_alpha
		B.add_overlay(weapon_overlay)

	B.active_overlay_icon_state = overlay_state
	B.active_underlay_icon_state = null
