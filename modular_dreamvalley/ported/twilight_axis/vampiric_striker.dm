// Ported from Twilight-Axis: the "vampiric striker" on-hit loop for Gnolls.
// On a successful melee hit, the wielder starts tracking the victim's next
// armor-integrity loss; enough accumulated damage drops a "dream shard" that,
// when the gnoll walks over it, repairs their own skin/armor and stacks a
// "vampiric fury" buff (small STR/CON gain, SPD/INT drawback, movement slow
// and pain immunity at high stacks).
//
// Adaptations to this fork:
// - Twilight-Axis's armor used its own dedicated /armor/vampiric base type.
// This fork's gnoll skin armor already exists as its own port under
// /obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor
// (a separate, already-established passive time-based regen system). Rather
// than forking a second parallel armor hierarchy, vampiric_striker's
// target_armor_path here just points at the existing gnoll_armor base, so
// shard pickups top off the same armor object gnolls already wear; the two
// repair mechanisms (passive regen-over-time, and shard-triggered on hit)
// simply stack.
// - COMSIG_MOB_ARMOR_INTEGRITY_DAMAGED did not exist in this fork; it has
// been added (mirroring Twilight-Axis's checkarmor() plumbing exactly) to
// code/__DEFINES/components.dm and code/modules/mob/living/carbon/human/human_defense.dm
// so this component has something to listen to.
// - All flavor text referencing Twilight-Axis's patron god "Graggar" was
// replaced with generic bloodlust/primal-hunt phrasing; this fork's gnolls
// are not tied to that pantheon (see code/modules/jobs/.../gnoll.dm, which
// already uses /datum/patron/oldkin/volkovoi instead).
// - The "toggle pelt repair" verb was folded directly into this component's
// callers instead of adding a second global verb registration, since this
// fork's gnoll_inspect_skin verb already covers the "check my armor" case.

#define FURY_TIER_1_THRESHOLD 1
#define FURY_TIER_2_THRESHOLD 20
#define FURY_TIER_3_THRESHOLD 40
#define FURY_TIER_4_THRESHOLD 100
#define FURY_FILTER "fury_filter"
#define FURY_GRACE_TIMER 20 SECONDS
#define MOVESPEED_ID_FURY_SLOW "movespeed_fury_slow"

/datum/component/vampiric_striker
	/// List of our specific target armor items being tracked for repairs
	var/list/repairing_items = list()
	/// How much armor damage we have stripped from targets
	var/accumulated_armor_damage = 0
	/// How much armor damage we must deal to drop a shard
	var/shard_threshold = 50
	/// The value of the spawned shard
	var/shard_repair_value = 20
	/// Type of shard to spawn
	var/obj/effect/temp_visual/dream_shard/shard_type = /obj/effect/temp_visual/dream_shard/vampiric
	/// The specific path type of armor we want to check for and repair
	var/target_armor_path = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor
	/// Weakref to the victim whose armor we're tracking, triggered in a single tick.
	var/datum/weakref/current_victim_ref
	/// Whether shards are allowed to actively repair tracked items when picked up
	var/repairs_enabled = TRUE
	/// How high the fury can build from picking up shards.
	var/fury_cap = 100

/datum/component/vampiric_striker/Initialize(threshold, repair_value, custom_fury_cap)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isnull(threshold))
		shard_threshold = threshold
	if(!isnull(repair_value))
		shard_repair_value = repair_value
	if(!isnull(custom_fury_cap))
		fury_cap = custom_fury_cap

	to_chat(parent, span_userdanger("Your strikes look to splinter the defenses of your foes."))

	var/mob/living/carbon/human/H = parent

	for(var/obj/item/I in H.contents)
		if(istype(I, target_armor_path))
			add_item(I)

	RegisterSignal(H, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_item_equipped))
	RegisterSignal(H, COMSIG_MOB_DROPITEM, PROC_REF(on_item_dropped))
	RegisterSignal(H, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_successful_strike))
	RegisterSignal(H, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(on_attack_finished))

/datum/component/vampiric_striker/proc/on_item_equipped(mob/user, obj/item/source, slot)
	SIGNAL_HANDLER
	if(istype(source, target_armor_path))
		add_item(source)

/datum/component/vampiric_striker/proc/on_item_dropped(mob/user, obj/item/source)
	SIGNAL_HANDLER
	if(istype(source, target_armor_path))
		remove_item(source)

/datum/component/vampiric_striker/proc/add_item(obj/item/I)
	if(I in repairing_items)
		return
	repairing_items += I

/datum/component/vampiric_striker/proc/remove_item(obj/item/I)
	repairing_items -= I

/datum/component/vampiric_striker/proc/on_successful_strike(mob/living/carbon/human/source, mob/living/target, obj/item/weapon)
	SIGNAL_HANDLER

	var/datum/component/vampiric_striker/vamp_comp = target.GetComponent(/datum/component/vampiric_striker)
	// We don't really want gnolls to hit each other to pre-buff.
	if(vamp_comp)
		return
	if(!istype(target, /mob/living/carbon/human))
		return
	if(target.stat == DEAD || !target.mind)
		return
	current_victim_ref = WEAKREF(target)
	RegisterSignal(target, COMSIG_MOB_ARMOR_INTEGRITY_DAMAGED, PROC_REF(handle_target_armor_shred))

/datum/component/vampiric_striker/proc/handle_target_armor_shred(mob/living/carbon/human/target, armor_damage_taken, obj/item/clothing/damaged_item, current_layer, total_layers)
	SIGNAL_HANDLER

	if(armor_damage_taken <= 0)
		return

	// If we are using blunt to damage multiple layers, there are diminishing returns.
	// Blunt damage already doesn't pierce through fully, but this is a further dampener, especially to prevent abuse when riposting.
	// Layer 2 only gives 33% the value anymore.
	// Layer 3 only gives 25% the value anymore. (Example, damaging MASK + COIF + HELM)
	// Layer 4 only gives 20% the value anymore.
	var/layer_modifier = 1
	if(current_layer > 1)
		layer_modifier = 1 / (current_layer + 1)
	var/effective_damage = armor_damage_taken * layer_modifier

	accumulated_armor_damage += effective_damage

	if(accumulated_armor_damage >= shard_threshold)
		while(accumulated_armor_damage >= shard_threshold)
			spawn_offensive_shard(target)
			accumulated_armor_damage -= shard_threshold

/datum/component/vampiric_striker/proc/on_attack_finished(mob/living/carbon/human/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!current_victim_ref)
		return

	var/mob/living/carbon/human/victim = current_victim_ref.resolve()
	if(victim)
		UnregisterSignal(victim, COMSIG_MOB_ARMOR_INTEGRITY_DAMAGED)

	current_victim_ref = null

/datum/component/vampiric_striker/proc/spawn_offensive_shard(mob/living/target)
	var/turf/spawn_location = get_turf(target)
	var/turf/attacker_turf = get_turf(parent)
	if(!spawn_location || !attacker_turf)
		return

	playsound(spawn_location, 'sound/combat/sharpness_loss1.ogg', 75, TRUE)
	target.visible_message(span_danger("Fragments of [target]'s armor are ripped away by the blow!"))

	var/turf/landing_turf
	var/attempts = 0
	while(attempts < 10)
		attempts++
		var/rand_x = attacker_turf.x + rand(-2, 2)
		var/rand_y = attacker_turf.y + rand(-2, 2)
		var/turf/picked_turf = locate(rand_x, rand_y, attacker_turf.z)
		if(picked_turf && !picked_turf.is_blocked_turf() && picked_turf != spawn_location)
			landing_turf = picked_turf
			break
	if(!landing_turf)
		landing_turf = locate(spawn_location.x + 1, spawn_location.y, spawn_location.z)
	var/obj/effect/temp_visual/dream_shard/vampiric/S = new shard_type(spawn_location, 10 SECONDS, shard_repair_value, landing_turf)
	S.creator_ref = WEAKREF(parent)

/datum/component/vampiric_striker/proc/repair_from_shard(amount)
	if(!repairs_enabled)
		return

	var/remaining_repair = amount
	while(remaining_repair > 0)
		var/obj/item/most_broken = null
		var/lowest_percent = 1

		for(var/obj/item/I in repairing_items)
			var/integrity_ratio = I.obj_integrity / I.max_integrity
			if(integrity_ratio < lowest_percent)
				lowest_percent = integrity_ratio
				most_broken = I

		if(!most_broken)
			break

		var/needed = most_broken.max_integrity - most_broken.obj_integrity
		var/applied = min(remaining_repair, needed)
		most_broken.obj_integrity += applied

		if(most_broken.max_blade_int && most_broken.blade_int < most_broken.max_blade_int)
			most_broken.blade_int = most_broken.max_blade_int
		remaining_repair -= applied

		if(most_broken.obj_broken && most_broken.obj_integrity > 0)
			most_broken.obj_fix(null, FALSE)

		most_broken.update_icon()

		if(needed > applied)
			break

/datum/component/vampiric_striker/Destroy()
	repairing_items = null
	return ..()

/obj/effect/temp_visual/dream_shard/vampiric
	name = "twisted armor shard"
	desc = "A piece of someone's armor, twisted to invigorate someone else instead. Looks fragile and easily destructible as a result."
	icon_state = "dream_shards"
	/// Weak reference to the player mob who spawned this shard
	var/datum/weakref/creator_ref
	effect_color = "#440101"

/obj/effect/temp_visual/dream_shard/vampiric/Crossed(atom/movable/AM)
	if(!creator_ref)
		return
	var/mob/living/carbon/human/creator = creator_ref.resolve()
	if(!creator)
		qdel(src)
		return
	if(AM != creator)
		if(isliving(AM))
			if(prob(40))
				AM.visible_message(span_notice("[AM] crushes the [src] underfoot!"))
			qdel(src)
		return
	if(!pickuppable || QDELETED(src))
		return
	var/datum/component/vampiric_striker/vamp_comp = creator.GetComponent(/datum/component/vampiric_striker)
	if(!vamp_comp)
		return
	if(!vamp_comp.repairs_enabled)
		return
	vamp_comp.repair_from_shard(repair_value)
	var/datum/status_effect/vampiric_fury/F = creator.has_status_effect(/datum/status_effect/vampiric_fury)
	if(F)
		F.add_stack(11)
	else
		creator.apply_status_effect(/datum/status_effect/vampiric_fury, 11, vamp_comp.fury_cap)
	var/obj/effect/temp_visual/heal/E = new /obj/effect/temp_visual/heal_rogue/campfire(get_turf(creator))
	E.color = effect_color
	playsound(creator, 'sound/magic/magic_nulled.ogg', 70, TRUE)
	qdel(src)

/mob/living/carbon/human/proc/gnoll_toggle_pelt_repair()
	set name = "Toggle Pelt Repair From Shards"
	set category = "RoleUnique.Gnoll"
	set desc = "Toggle whether vampiric shard consumption repairs your skin armor."

	var/datum/component/vampiric_striker/vamp_comp = GetComponent(/datum/component/vampiric_striker)
	if(!vamp_comp)
		to_chat(src, span_warning("You don't possess the ability required to attune your pelt!"))
		return

	vamp_comp.repairs_enabled = !vamp_comp.repairs_enabled

	if(vamp_comp.repairs_enabled)
		to_chat(src, span_notice("Armor shards will now repair your pelt."))
	else
		to_chat(src, span_warning("Armor shards will no longer repair your pelt. Warning, this prevents gaining buffs from picking up shards."))

// VAMPIRIC FURY STATUS EFFECT

/datum/status_effect/vampiric_fury
	id = "vampiric_fury"
	alert_type = /atom/movable/screen/alert/status_effect/vampiric_fury
	duration = -1 // Managed by stack decay
	tick_interval = 1 SECONDS

	var/stacks = 0
	var/max_stacks = 100
	var/tier = 1
	/// Time world when we can next decay a stack
	var/decay_grace_timestamp = 0
	var/outline_colour = "#860202"
	var/movespeed_modifier_applied = FALSE

/datum/status_effect/vampiric_fury/on_creation(mob/living/new_owner, initial_stacks = 15, custom_max_stacks = 100)
	max_stacks = custom_max_stacks
	stacks = clamp(initial_stacks, 1, max_stacks)
	decay_grace_timestamp = world.time + FURY_GRACE_TIMER
	. = ..()

/datum/status_effect/vampiric_fury/on_apply()
	to_chat(owner, span_userdanger("Primal bloodlust surges through your blood!"))
	update_effects()
	check_thresholds()
	update_alert()
	return TRUE

/datum/status_effect/vampiric_fury/tick()
	if(!owner || owner.stat == DEAD)
		return

	if(world.time < decay_grace_timestamp)
		return

	remove_stack(1)

/datum/status_effect/vampiric_fury/proc/add_stack(amount = 15)
	var/old_stacks = stacks
	stacks = clamp(stacks + amount, 1, max_stacks)
	decay_grace_timestamp = world.time + FURY_GRACE_TIMER

	if(stacks != old_stacks)
		update_effects()
		check_thresholds()
		update_alert()

/datum/status_effect/vampiric_fury/proc/remove_stack(amount = 1)
	stacks -= amount
	if(stacks <= 0)
		qdel(src)
		return

	update_effects()
	check_thresholds()
	update_alert()

/datum/status_effect/vampiric_fury/proc/update_alert()
	if(!linked_alert)
		return

	switch(tier)
		if(1)
			linked_alert.name = "Blood Fury (Stirring) \[[stacks] Stacks\]"
			linked_alert.desc = "My claws desire flesh, away with their armor!"
			linked_alert.icon_state = "fury1"
		if(2)
			linked_alert.name = "Blood Fury (Swelling) \[[stacks] Stacks\]"
			linked_alert.desc = "My energy is boundless, theirs is not."
			linked_alert.icon_state = "fury2"
		if(3)
			linked_alert.name = "Blood Fury (Angry) \[[stacks] Stacks\]"
			linked_alert.desc = "My legs swell with muscle, the weight distracting. It matters little."
			linked_alert.icon_state = "fury3"
		if(4)
			linked_alert.name = "Blood Fury (Raging) \[[stacks] Stacks\]"
			linked_alert.desc = "SO... ANGRY..."
			linked_alert.icon_state = "fury4"

/datum/status_effect/vampiric_fury/proc/update_effects()
	var/list/old_stats = effectedstats.Copy()
	effectedstats = list()

	// Stat boosts are capped, some classes can overcap just to have it decay more slowly
	var/effective_stacks = min(stacks, 100)

	var/spd_loss = round(effective_stacks / 50)
	var/str_gain = round(effective_stacks / 25)
	var/con_gain = round(effective_stacks / 25)
	var/int_loss = round(effective_stacks / 50)

	if(spd_loss)
		effectedstats[STATKEY_SPD] = -spd_loss
	if(str_gain)
		effectedstats[STATKEY_STR] = str_gain
	if(con_gain)
		effectedstats[STATKEY_CON] = con_gain
	if(int_loss)
		effectedstats[STATKEY_INT] = -int_loss

	reapply_effect(old_stats)
	update_movespeed()

/datum/status_effect/vampiric_fury/proc/update_movespeed()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner
	var/effective_stacks = min(stacks, 100)
	var/slow_stacks = round(effective_stacks / 33) // 0, 1, 2, or 3
	var/slow_amount = SPEED_MOVSPD_MOD * slow_stacks

	if(slow_amount > 0)
		H.add_movespeed_modifier(MOVESPEED_ID_FURY_SLOW, update=TRUE, priority=10, multiplicative_slowdown=slow_amount)
		movespeed_modifier_applied = TRUE
	else if(movespeed_modifier_applied)
		H.remove_movespeed_modifier(MOVESPEED_ID_FURY_SLOW)
		movespeed_modifier_applied = FALSE

/datum/status_effect/vampiric_fury/proc/check_thresholds()
	var/new_tier = 0
	if(stacks >= FURY_TIER_4_THRESHOLD)
		new_tier = 4
	else if(stacks >= FURY_TIER_3_THRESHOLD)
		new_tier = 3
	else if(stacks >= FURY_TIER_2_THRESHOLD)
		new_tier = 2
	else if(stacks >= FURY_TIER_1_THRESHOLD)
		new_tier = 1

	if(new_tier == tier)
		return

	// Handle TIER ASCENDING
	if(new_tier > tier)
		owner.visible_message(span_boldwarning("[owner]'s eyes flare with an intense, predatory hunger!"))
		switch(new_tier)
			if(2)
				to_chat(owner, span_userdanger("The metallic taste of stolen armor thickens. A heavy resilience hardens your frame!"))
				if(ishuman(owner))
					REMOVE_TRAIT(owner, TRAIT_LONGSTRIDER, SPECIES_TRAIT)
			if(3)
				to_chat(owner, span_boldwarning("Your muscles swell! The excess bulk hampers your long strides!"))
				if(ishuman(owner))
					ADD_TRAIT(owner, TRAIT_BREADY, SPECIES_TRAIT)
			if(4)
				to_chat(owner, span_danger("YOU ARE ANGRY... SO... DAMN... ANGRY!!!"))
				if(ishuman(owner))
					ADD_TRAIT(owner, TRAIT_NOPAINSTUN, SPECIES_TRAIT)
				var/filter = owner.get_filter(FURY_FILTER)
				if(!filter)
					owner.add_filter(FURY_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 100, "size" = 1))

	// Handle TIER DESCENDING
	else if(new_tier < tier)
		owner.visible_message(span_notice("[owner]'s manic frenzy seems to subside slightly."))
		switch(new_tier)
			if(1)
				to_chat(owner, span_notice("The oppressive mass leaves your skin. Your posture returns to normal."))
				if(ishuman(owner))
					ADD_TRAIT(owner, TRAIT_LONGSTRIDER, SPECIES_TRAIT)
			if(2)
				to_chat(owner, span_notice("The swelling muscles in your legs settle down, freeing your long nimble strides."))
				if(ishuman(owner))
					REMOVE_TRAIT(owner, TRAIT_BREADY, SPECIES_TRAIT)
			if(3)
				to_chat(owner, span_info("The pure blinding rush of the apex hunt passes, giving way back to conscious thought."))
				owner.remove_filter(FURY_FILTER)
				if(ishuman(owner))
					REMOVE_TRAIT(owner, TRAIT_NOPAINSTUN, SPECIES_TRAIT)

	tier = new_tier

/datum/status_effect/vampiric_fury/proc/reapply_effect(list/old_stats)
	for(var/S in old_stats)
		owner.change_stat(S, -(old_stats[S]))

	for(var/S in effectedstats)
		if(effectedstats[S] < 0)
			if((owner.get_stat(S) + effectedstats[S]) < 1)
				for(var/i in 1 to abs(effectedstats[S]))
					if((owner.get_stat(S) + (effectedstats[S] + i)) == 1)
						effectedstats[S] = (effectedstats[S] + i)
						break
		else
			if((owner.get_stat(S) + effectedstats[S]) > 20)
				effectedstats[S] = max(((owner.get_stat(S) + effectedstats[S]) - 20), 0)
		owner.change_stat(S, effectedstats[S])

/datum/status_effect/vampiric_fury/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		REMOVE_TRAIT(H, TRAIT_BREADY, SPECIES_TRAIT)
		REMOVE_TRAIT(H, TRAIT_NOPAINSTUN, SPECIES_TRAIT)
		if(!HAS_TRAIT(H, TRAIT_LONGSTRIDER))
			ADD_TRAIT(H, TRAIT_LONGSTRIDER, SPECIES_TRAIT)

	owner.remove_movespeed_modifier(MOVESPEED_ID_FURY_SLOW)

	to_chat(owner, span_notice("The bloodlust leaves your body completely, your senses return."))
	return ..()

/atom/movable/screen/alert/status_effect/vampiric_fury
	name = "Blood Fury"
	desc = "Primal bloodlust powers your muscles."
	icon_state = "fury1"
	icon = 'icons/mob/screenalerts/gnoll_alerts.dmi'

#undef FURY_TIER_1_THRESHOLD
#undef FURY_TIER_2_THRESHOLD
#undef FURY_TIER_3_THRESHOLD
#undef FURY_TIER_4_THRESHOLD
#undef FURY_FILTER
#undef FURY_GRACE_TIMER
#undef MOVESPEED_ID_FURY_SLOW
