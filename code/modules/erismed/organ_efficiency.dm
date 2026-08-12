// ERISMED — Organ Efficiency System
// Lightweight adaptation of CEV-Eris's organ process system.
// Calculates organ efficiency based on damage and internal wounds,
// and applies effects when organs are functioning poorly.

/// Efficiency thresholds (percentage of max function)
#define ORGAN_EFFICIENCY_BRUISED 80
#define ORGAN_EFFICIENCY_BROKEN 50
#define ORGAN_EFFICIENCY_DEAD 0

/// Get the efficiency of an organ (0-100) based on damage and wounds
/obj/item/organ/proc/get_efficiency()
	if(organ_flags & ORGAN_FAILING)
		return ORGAN_EFFICIENCY_DEAD
	var/damage_ratio = damage / maxHealth
	var/efficiency = 100 * (1 - damage_ratio)
	// Internal wounds reduce efficiency further
	for(var/datum/internal_wound/IW in internal_wounds)
		if(IW.organ_efficiency_multiplier != null)
			efficiency *= (1 + IW.organ_efficiency_multiplier)
		// Each wound point reduces efficiency by 5%
		efficiency -= IW.severity * 5
	return max(0, efficiency)

/// Process organ efficiency effects on the owner
/mob/living/carbon/human/proc/process_organ_efficiency()
	// Eyes — low efficiency causes blurry vision / blindness
	var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
	if(E)
		var/eff = E.get_efficiency()
		if(eff < ORGAN_EFFICIENCY_BRUISED && !HAS_TRAIT(src, TRAIT_BLIND))
			eye_blurry = max(eye_blurry, 1)
		if(eff < ORGAN_EFFICIENCY_BROKEN && !HAS_TRAIT(src, TRAIT_BLIND))
			eye_blind = max(eye_blind, 1)

	// Liver — low efficiency causes toxin buildup
	var/obj/item/organ/liver/L = getorganslot(ORGAN_SLOT_LIVER)
	if(L)
		var/eff = L.get_efficiency()
		if(eff < ORGAN_EFFICIENCY_BROKEN && prob(10))
			adjustToxLoss(1)

	// Heart — low efficiency causes stamina loss and weakness
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(H)
		var/eff = H.get_efficiency()
		if(eff < ORGAN_EFFICIENCY_BROKEN)
			adjustStaminaLoss(5)

	// Lungs — low efficiency causes oxy loss
	var/obj/item/organ/lungs/LU = getorganslot(ORGAN_SLOT_LUNGS)
	if(LU)
		var/eff = LU.get_efficiency()
		if(eff < ORGAN_EFFICIENCY_BROKEN && !HAS_TRAIT(src, TRAIT_NOBREATH))
			adjustOxyLoss(2)

	// Stomach — low efficiency causes hunger/nutrition loss
	var/obj/item/organ/stomach/S = getorganslot(ORGAN_SLOT_STOMACH)
	if(S)
		var/eff = S.get_efficiency()
		if(eff < ORGAN_EFFICIENCY_BROKEN && prob(10))
			adjust_nutrition(-5)

/// Get the total efficiency of all organs (for diagnosis UI)
/mob/living/carbon/human/proc/get_total_organ_efficiency()
	var/total = 0
	var/count = 0
	for(var/obj/item/organ/O in internal_organs)
		total += O.get_efficiency()
		count++
	if(!count)
		return 100
	return total / count
