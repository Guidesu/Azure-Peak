// Ported from Vanderlin (OpenKeep): code/datums/components/enchanted_item.dm
// (/datum/component/enchanted_weapon). This is the OTHER half of Vanderlin's
// enchantment system alongside runewords: a temporary, decaying buff applied
// to a weapon (originally via an "enchant weapon" spell). This repo has no
// equivalent spell, and no /datum/attribute/skill/magic/arcane skill check
// hook, so the refresh-by-skill-check gate is dropped - refresh_count alone
// gates how many times the enchantment can be renewed (see try_decay()).
// This component is meant to be attached by whatever future spell/ritual
// wants to grant a temporary weapon enchantment; it is not itself wired to
// any caster ability in this port.
/datum/component/enchanted_weapon
	var/duration
	var/refresh_count
	var/enchant_type
	var/datum/weakref/current_user
	var/decay_timer

/datum/component/enchanted_weapon/Initialize(
	n_duration = DV_ENCHANT_DEFAULT_DURATION,
	n_refresh_count = 4,
	n_enchant_type = DV_ENCHANT_SEARING_BLADE,
	n_current_user,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	duration = n_duration
	refresh_count = n_refresh_count
	enchant_type = n_enchant_type
	if(n_current_user)
		current_user = WEAKREF(n_current_user)

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_qdel))

	var/obj/item/weapon = parent
	switch(enchant_type)
		if(DV_ENCHANT_FORCE_BLADE)
			weapon.force += DV_FORCE_BLADE_FORCE
			weapon.add_filter(DV_ENCHANT_FILTER_FORCE, 2, list("type" = "outline", "color" = "#9400D3", "size" = 1))
		if(DV_ENCHANT_SEARING_BLADE)
			weapon.add_filter(DV_ENCHANT_FILTER_SEARING, 2, list("type" = "outline", "color" = "#64af18", "size" = 1))
		if(DV_ENCHANT_DIVINE_FIRE)
			weapon.add_filter(DV_ENCHANT_FILTER_DIVINE, 2, list("type" = "outline", "color" = "#dddddd", "size" = 1))
		if(DV_ENCHANT_DURABILITY)
			weapon.modify_max_integrity(weapon.max_integrity + DV_DURABILITY_INCREASE)
			weapon.add_filter(DV_ENCHANT_FILTER_DURABILITY, 2, list("type" = "outline", "color" = "#808080", "size" = 1))

	decay_timer = addtimer(CALLBACK(src, PROC_REF(try_decay)), duration, TIMER_STOPPABLE)

/datum/component/enchanted_weapon/Destroy()
	clean_up()
	return ..()

/datum/component/enchanted_weapon/proc/on_parent_qdel()
	SIGNAL_HANDLER
	clean_up(TRUE)

/datum/component/enchanted_weapon/proc/try_decay()
	if(QDELETED(parent))
		clean_up(TRUE)
		return
	var/mob/holder = current_user?.resolve()
	if(QDELETED(holder))
		clean_up(TRUE)
		return
	if(refresh_count != -1 && refresh_count <= 0)
		clean_up(TRUE)
		return

	refresh_count--
	to_chat(holder, span_nicegreen("A faint glow emanates from [parent] - its enchantment is renewed!"))
	decay_timer = addtimer(CALLBACK(src, PROC_REF(try_decay)), duration, TIMER_STOPPABLE)

/datum/component/enchanted_weapon/proc/clean_up(delete = FALSE)
	current_user = null
	deltimer(decay_timer)
	decay_timer = null
	var/obj/item/weapon = parent
	if(weapon)
		switch(enchant_type)
			if(DV_ENCHANT_FORCE_BLADE)
				weapon.force -= DV_FORCE_BLADE_FORCE
				weapon.remove_filter(DV_ENCHANT_FILTER_FORCE)
			if(DV_ENCHANT_SEARING_BLADE)
				weapon.remove_filter(DV_ENCHANT_FILTER_SEARING)
			if(DV_ENCHANT_DIVINE_FIRE)
				weapon.remove_filter(DV_ENCHANT_FILTER_DIVINE)
			if(DV_ENCHANT_DURABILITY)
				weapon.modify_max_integrity(weapon.max_integrity - DV_DURABILITY_INCREASE, can_break = FALSE)
				weapon.remove_filter(DV_ENCHANT_FILTER_DURABILITY)
		weapon.visible_message(span_warning("The enchantment on [weapon] fades!"))

	if(delete)
		qdel(src)

/datum/component/enchanted_weapon/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	current_user = WEAKREF(user)

/datum/component/enchanted_weapon/proc/on_drop(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	current_user = null

/datum/component/enchanted_weapon/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	switch(enchant_type)
		if(DV_ENCHANT_SEARING_BLADE)
			examine_list += span_notice("This weapon is enchanted with green flame.")
		if(DV_ENCHANT_FORCE_BLADE)
			examine_list += span_notice("This weapon is enchanted with a force blade.")
		if(DV_ENCHANT_DURABILITY)
			examine_list += span_notice("This weapon is enchanted with lasting durability.")
		if(DV_ENCHANT_DIVINE_FIRE)
			examine_list += span_notice("This weapon is enchanted with divine flame.")
	examine_list += span_notice("It will last for [timeleft(decay_timer) / 10] more seconds.")

/datum/component/enchanted_weapon/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag || !isliving(target))
		return

	var/mob/living/target_mob = target
	if(enchant_type == DV_ENCHANT_SEARING_BLADE)
		target_mob.apply_damage(DV_SEARING_BLADE_DAMAGE, BURN)
		target_mob.visible_message(span_warning("Flames leap from [source], burning [target_mob]!"), span_warning("Flames leap from [source] and sear you!"))
	else if(enchant_type == DV_ENCHANT_DIVINE_FIRE)
		var/damage_amt = DV_DIVINE_FIRE_DAMAGE
		if(target_mob.mob_biotypes & MOB_UNDEAD)
			damage_amt *= 1.5
		target_mob.apply_damage(damage_amt, BURN)
		target_mob.visible_message(span_warning("Divine fire leaps from [source], burning [target_mob]!"), span_warning("Divine fire leaps from [source] and sears you!"))
