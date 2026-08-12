// ERISMED — Organ Integration
// Hooks the internal wound system into DreamValley's existing organ system

/obj/item/organ
	/// List of active internal wounds on this organ
	var/list/datum/internal_wound/internal_wounds = list()

/// Add an internal wound to this organ
/obj/item/organ/proc/add_internal_wound(wound_type)
	if(!ispath(wound_type, /datum/internal_wound))
		return
	// Check if this wound type already exists
	for(var/datum/internal_wound/IW in internal_wounds)
		if(IW.type == wound_type)
			// Already have this wound — increase severity instead
			if(IW.severity < IW.severity_max)
				IW.severity++
			return
	var/datum/internal_wound/IW = new wound_type(src)
	internal_wounds += IW
	// Notify the owner
	if(owner && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		to_chat(H, span_warning("You feel a sharp pain in your [name]!"))

/// Remove an internal wound from this organ
/obj/item/organ/proc/remove_internal_wound(datum/internal_wound/IW)
	internal_wounds -= IW
	qdel(IW)

/// Get all internal wounds of a specific type
/obj/item/organ/proc/get_internal_wounds(wound_type)
	. = list()
	for(var/datum/internal_wound/IW in internal_wounds)
		if(!wound_type || istype(IW, wound_type))
			. += IW

/// Check if organ has any critical wounds
/obj/item/organ/proc/has_critical_wounds()
	for(var/datum/internal_wound/IW in internal_wounds)
		if(IW.is_critical())
			return TRUE
	return FALSE

/// Apply damage to organ — chance to create internal wounds
/obj/item/organ/proc/take_internal_damage(amount, damage_type = BRUTE)
	applyOrganDamage(amount)
	// Chance to create internal wound based on damage
	if(amount > 5 && prob(amount * 2))
		var/wound_type
		switch(damage_type)
			if(BRUTE)
				wound_type = pick(list(
					/datum/internal_wound/organic/blunt/contusion,
					/datum/internal_wound/organic/blunt/rupture,
					/datum/internal_wound/organic/edge/laceration,
				))
			if(BURN)
				wound_type = pick(list(
					/datum/internal_wound/organic/burn/scorch,
					/datum/internal_wound/organic/burn/char,
				))
			if(TOX)
				wound_type = pick(list(
					/datum/internal_wound/organic/poisoning/poisoning,
					/datum/internal_wound/organic/poisoning/accumulation,
				))
		if(wound_type)
			add_internal_wound(wound_type)

/// Clean up wounds when organ is removed
/obj/item/organ/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	// Remove all internal wounds when organ is removed
	for(var/datum/internal_wound/IW in internal_wounds)
		internal_wounds -= IW
		qdel(IW)

/// Extended examine to show internal wounds (for medics)
/obj/item/organ/examine(mob/user)
	. = ..()
	if(!length(internal_wounds))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		// Diagnosis requires INT check
		var/diagnosis_result = H.stat_check(STAT_INTELLIGENCE, STAT_BASELINE + 5)
		if(diagnosis_result >= STAT_QUALITY_AVERAGE)
			for(var/datum/internal_wound/IW in internal_wounds)
				. += span_warning("[IW.name] (severity: [IW.severity]/[IW.severity_max])")
		else
			. += span_notice("You can tell something is wrong with this organ, but you're not sure what.")
