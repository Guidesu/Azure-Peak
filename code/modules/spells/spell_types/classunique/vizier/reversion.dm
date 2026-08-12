// Reversion - Origin Magic (Vizier)
// Close range channeled healing spell that requires proximity.
// Rewinds them through time and does a big heal.

/datum/action/cooldown/spell/vizier/reversion
	button_icon = 'icons/mob/actions/classuniquespells/vizier.dmi'
	name = "Reversion"
	desc = "A demanding and difficult to execute spell that reverts a target to a prior state in their timestream before they were injured, instantaneously healing a large amount of damage and stopping bleeding. It does not restore blood, due to the nature of how it flows."
	fluff_desc = "Among the most demanding applications of Origin Magick, this art reaches into the timestream of a person, allowing the Vizier to pluck through it and find a point in time where their injuries were not as severe. Then, as if plucking an apple from a tree, it is flung to the present and collapsed into their current timestream."
	button_icon_state = "reversion"
	sound = 'sound/magic/timeforward.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	cast_range = 2
	self_cast_possible = TRUE
	aim_assist = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = 60

	invocations = list("Irji'!")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = 15 SECONDS
	charge_swingdelay_type = SWINGDELAY_CANCEL
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 4 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	cost = 3

/datum/action/cooldown/spell/vizier/reversion/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/target = cast_on
	if(!istype(target))
		return FALSE

	target.visible_message(span_purple("[target]'s body begins to flicker, slipping out of the present moment, before violently shuddering back into normal time!"))
	target.adjust_fire_stacks(-100)
	target.adjust_fire_stacks(-100, /datum/status_effect/fire_handler/fire_stacks/sunder)
	target.adjust_fire_stacks(-100, /datum/status_effect/fire_handler/fire_stacks/divine)
	target.adjustBruteLoss(-300)
	target.adjustFireLoss(-300)
	target.adjustOxyLoss(-300)
	target.adjustToxLoss(-300)
	target.stamina_add(-200)
	target.energy_add(-600)

	var/list/wCount = target.get_wounds()

	if(wCount.len > 0)
		target.heal_wounds(100)
		target.update_damage_overlays()

	var/datum/status_effect/fire_handler/fire_stacks/divine/divine_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/divine)
	trigger.divinefirestacks = divine_status?.stacks

	var/datum/status_effect/fire_handler/fire_stacks/vheslyn/vheslyn_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/vheslyn)
	trigger.divinefirestacks = vheslyn_status?.stacks

	// Snapshot current wounds so we can remove new ones on revert
	trigger.snapshot_wounds = target.get_wounds()

	// Grant the self-revert trigger to the marked target
	trigger.Grant(target)

	if(target != H && shares_fellowship(H, target))
		var/datum/action/cooldown/spell/vizier/reversion_pull/pull = new
		pull.linked_trigger = trigger
		trigger.linked_pull = pull
		pull.Grant(H)

	// Audio + visual feedback on the target
	playsound(target.loc, 'sound/magic/timeforward.ogg', 50, FALSE)
	target.apply_status_effect(/datum/status_effect/buff/reversion)
	target.balloon_alert(target, "marked for reversion")
	if(target != H)
		target.balloon_alert(H, "marked for reversion")

	// Feedback
	if(target == H)
		to_chat(H, span_purple("I mark myself for reversion. I can revert to this moment at will."))
	else if(shares_fellowship(H, target))
		to_chat(target, span_purple("I feel a part of me anchored to this place... I may revert myself at will."))
		to_chat(H, span_purple("I mark [target] for reversion. As my fellow, I may also pull them back myself, without asking."))
	else
		to_chat(target, span_purple("I feel a part of me anchored to this place... I may revert myself at will."))
		to_chat(H, span_purple("I mark [target] for reversion. They may revert themselves at will."))

	return TRUE

/datum/action/cooldown/spell/vizier/reversion_trigger
	button_icon = 'icons/mob/actions/classuniquespells/vizier.dmi'
	name = "Revert"
	desc = "Activate to snap back to my marked position and restore my state."
	button_icon_state = "reversion"
	sound = 'sound/magic/timereverse.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE

	primary_resource_type = SPELL_COST_NONE
	primary_resource_cost = 0

	invocations = null
	invocation_type = INVOCATION_NONE

	charge_required = TRUE
	charge_time = 0 // Instant cuz do after already exists
	hold_drain = 0
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 0

	associated_skill = null
	associated_stat = null
	spell_tier = 0
	spell_impact_intensity = SPELL_IMPACT_NONE

	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	/// The Vizier's optional pull action, granted only when the target is a fellowship ally.
	var/datum/action/cooldown/spell/vizier/reversion_pull/linked_pull
	/// Snapshot data - set by the Reversion caster spell before granting.
	var/turf/origin
	var/brute = 0
	var/burn = 0
	var/oxy = 0
	var/toxin = 0
	var/firestacks = 0
	var/divinefirestacks = 0
	var/sunderfirestacks = 0
	var/blood = 0
	/// Wounds that existed at mark time - anything not in this list gets removed on revert.
	var/list/datum/wound/snapshot_wounds
	/// Timer for auto-expiry.
	var/expiry_timer
	/// Ground marker effect at the origin point.
	var/obj/effect/reversion_marker/ground_marker
	/// TRUE while the revert channel is running - blocks re-entry and marks us as committed.
	var/reverting = FALSE

/datum/action/cooldown/spell/vizier/reversion_trigger/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return
	// Set a timer to auto-remove this spell when the mark expires
	expiry_timer = addtimer(CALLBACK(src, PROC_REF(expire)), REVERSION_MARK_DURATION, TIMER_STOPPABLE)
	// Place a ground marker at the return point
	if(origin)
		ground_marker = new(origin)

// The marked target activating their own Revert spell.
/datum/action/cooldown/spell/vizier/reversion_trigger/cast(atom/cast_on)
	. = ..()
	return perform_revert(owner)

/datum/action/cooldown/spell/vizier/reversion_trigger/proc/perform_revert(mob/living/reverter)
	var/mob/living/carbon/target = owner
	if(!istype(target) || QDELETED(target))
		return FALSE
	if(!istype(reverter) || QDELETED(reverter))
		return FALSE
	if(reverting)
		return FALSE
	reverting = TRUE

	if(expiry_timer)
		deltimer(expiry_timer)
		expiry_timer = null


	reverter.balloon_alert(reverter, "reverting...")
	target.visible_message(span_purple("[target]'s body begins to flicker, slipping out of the present moment..."))
	var/datum/progressbar/progbar = new(reverter, 2 SECONDS, reverter)
	var/endtime = world.time + 2 SECONDS
	var/starttime = world.time
	while(world.time < endtime)
		stoplag(1)
		if(QDELETED(src) || QDELETED(target) || QDELETED(reverter))
			break
		progbar.update(world.time - starttime)
	qdel(progbar)


	if(QDELETED(src))
		return FALSE

	if(QDELETED(target) || QDELETED(reverter) || owner != target)
		cleanup()
		return FALSE

	var/turf/departure = get_turf(target)
	target.visible_message(span_purple("[target] flickers and warps away, snapping backwards through time!"), span_purple("Time reverses - my body snaps back!"))
	if(departure)
		departure.balloon_alert_to_viewers("warps away!")
		playsound(departure, 'sound/magic/timereverse.ogg', 100, FALSE)

	// Teleport back
	do_teleport(target, origin, no_effects = TRUE)

	// Restore snapshot state
	var/brutenew = target.getBruteLoss()
	var/burnnew = target.getFireLoss()
	var/oxynew = target.getOxyLoss()
	target.adjust_fire_stacks(firestacks)
	target.adjust_fire_stacks(sunderfirestacks, /datum/status_effect/fire_handler/fire_stacks/sunder)
	target.adjust_fire_stacks(divinefirestacks, /datum/status_effect/fire_handler/fire_stacks/divine)
	target.adjustBruteLoss(brutenew * -1 + brute)
	target.adjustFireLoss(burnnew * -1 + burn)
	target.adjustOxyLoss(oxynew * -1 + oxy)
	target.adjustToxLoss(target.getToxLoss() * -1 + toxin)
	target.blood_volume = blood

	// Remove any wounds gained after the mark
	for(var/datum/wound/wound as anything in target.get_wounds())
		if(wound in snapshot_wounds)
			continue
		if(wound.bodypart_owner)
			wound.bodypart_owner.remove_wound(wound)
		else
			target.simple_remove_wound(wound)

	// Announce the arrival at the return point
	playsound(target.loc, 'sound/magic/timereverse.ogg', 100, FALSE)
	target.balloon_alert_to_viewers("snaps into place!", "I snap back!")
	if(reverter != target)
		to_chat(reverter, span_purple("I pull [target] back to their mark."))

	// Remove the status effect and clean up
	target.remove_status_effect(/datum/status_effect/buff/reversion)
	cleanup()
	return TRUE

/// Called when the mark expires without being used.
/datum/action/cooldown/spell/vizier/reversion_trigger/proc/expire()
	// A revert is already committed and channeling - let it finish, don't tear down under it.
	if(reverting)
		return
	var/mob/living/carbon/target = owner
	if(istype(target))
		target.remove_status_effect(/datum/status_effect/buff/reversion)
		to_chat(target, span_purple("The reversion mark fades."))
	cleanup()

/// Remove this spell (and the Vizier's pull, if any) and delete it.
/datum/action/cooldown/spell/vizier/reversion_trigger/proc/cleanup()
	if(linked_pull)
		linked_pull.linked_trigger = null
		QDEL_NULL(linked_pull)
	if(expiry_timer)
		deltimer(expiry_timer)
		expiry_timer = null
	QDEL_NULL(ground_marker)
	if(owner)
		Remove(owner)
	qdel(src)

/datum/action/cooldown/spell/vizier/reversion_trigger/Destroy()
	if(linked_pull)
		linked_pull.linked_trigger = null
		QDEL_NULL(linked_pull)
	if(expiry_timer)
		deltimer(expiry_timer)
		expiry_timer = null
	QDEL_NULL(ground_marker)
	snapshot_wounds = null
	origin = null
	return ..()

/datum/action/cooldown/spell/vizier/reversion_pull
	button_icon = 'icons/mob/actions/classuniquespells/vizier.dmi'
	name = "Pull Reversion"
	desc = "Pull the fellow I have marked back to their marked position and state, without asking. Works only while we share a fellowship."
	button_icon_state = "reversion"
	sound = 'sound/magic/timereverse.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE

	primary_resource_type = SPELL_COST_NONE
	primary_resource_cost = 0

	invocations = null
	invocation_type = INVOCATION_NONE

	charge_required = TRUE
	charge_time = 0
	hold_drain = 0
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 0

	associated_skill = null
	associated_stat = null
	spell_tier = 0
	spell_impact_intensity = SPELL_IMPACT_NONE

	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/datum/action/cooldown/spell/vizier/reversion_trigger/linked_trigger

/datum/action/cooldown/spell/vizier/reversion_pull/cast(atom/cast_on)
	. = ..()
	if(QDELETED(linked_trigger))
		if(owner)
			to_chat(owner, span_warning("The mark I anchored has faded."))
		qdel(src)
		return FALSE

	var/mob/living/carbon/caster = owner
	if(!istype(caster))
		return FALSE

	var/mob/living/carbon/target = linked_trigger.owner
	if(!istype(target) || QDELETED(target))
		to_chat(caster, span_warning("There is nothing left to pull back."))
		return FALSE

	if(!shares_fellowship(caster, target))
		to_chat(caster, span_warning("[target] no longer shares my fellowship - I cannot pull them back."))
		return FALSE

	return linked_trigger.perform_revert(caster)

/datum/action/cooldown/spell/vizier/reversion_pull/Destroy()
	if(linked_trigger && !QDELETED(linked_trigger) && linked_trigger.linked_pull == src)
		linked_trigger.linked_pull = null
	linked_trigger = null
	return ..()

// -------------------------------------------------------------------
// Ground marker effect placed at the reversion return point.
// -------------------------------------------------------------------

/obj/effect/reversion_marker
	name = "temporal mark"
	desc = "A shimmering imprint of origin bending lingers here."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	density = FALSE
	alpha = 128
	color = GLOW_COLOR_ARCANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

#undef REVERSION_MARK_DURATION
