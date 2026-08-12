// ERISMED — Internal Wound System
// Ported from CEV-Eris, adapted for DreamValley's medieval fantasy setting.
// Internal wounds are injuries that affect organs, progress over time, and
// can be treated with surgery, items, or alchemy.

// Internal wound damage levels
#define IWOUND_LIGHT_DAMAGE 1
#define IWOUND_MEDIUM_DAMAGE 2
#define IWOUND_HEAVY_DAMAGE 3

// Wound stability states
#define WOUND_UNSTABLE 0
#define WOUND_STABLE 1
#define WOUND_TREATED 2

/datum/internal_wound
	/// Display name
	var/name = "internal injury"
	/// The organ this wound is attached to
	var/obj/item/organ/parent

	/// Items that can treat this wound: list(/obj/item/path = amount_needed)
	var/list/treatments_item = list()
	/// Tool qualities that can treat this wound: list(quality = failchance)
	var/list/treatments_tool = list()
	/// Reagents that can treat this wound: list(reagent_type = strength_needed)
	var/list/treatments_chem = list()
	/// Reagents that stabilize (don't cure) this wound
	var/list/stabilizers_chem = list()
	/// First aid treatments: list(treatment_type = result_state)
	var/list/firstaid_type = list()
	/// If defined, applies this wound type when successfully treated (scar)
	var/datum/internal_wound/scar

	/// Diagnosis stat — which stat is used to diagnose (INT for herbalists, PER for surgeons)
	var/diagnosis_stat = STAT_INTELLIGENCE
	/// Diagnosis difficulty — base difficulty
	var/diagnosis_difficulty = STAT_BASELINE

	/// Wound characteristic flags (IWOUND_* defines)
	var/characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_PROGRESS

	/// Current severity (0 = none, severity_max = maximum)
	var/severity = 0
	/// Maximum severity
	var/severity_max = 3

	/// If defined, applies a wound of this type when severity reaches max
	var/datum/internal_wound/next_wound
	/// Ticks until wound progresses
	var/progression_threshold = IWOUND_4_MINUTES
	/// Current progression tick count
	var/current_progression_tick

	/// Severity at which wound spreads to another organ
	var/spread_threshold = 0

	/// Wound nature (organic, robotic, both)
	var/wound_nature = WOUND_NATURE_ORGANIC

	/// Damage applied to mob each process tick
	var/hal_damage
	/// Psychic damage (affects sanity)
	var/psy_damage

	/// Hallucination frequency
	var/ticks_per_hallucination = IWOUND_1_MINUTE
	var/current_hallucination_tick

	/// Organ efficiency modifications
	var/list/organ_efficiency_mod = list()
	var/organ_efficiency_multiplier = null

	/// Whether the wound is stabilized
	var/stabilized = FALSE

	/// Status flag on parent organ
	var/status_flag

/datum/internal_wound/New(obj/item/organ/O)
	if(!O)
		qdel(src)
		return
	parent = O
	START_PROCESSING(SSerismed, src)

/datum/internal_wound/Destroy()
	STOP_PROCESSING(SSerismed, src)
	parent = null
	return ..()

/datum/internal_wound/proc/process_wound()
	if(!parent)
		return PROCESS_KILL

	var/mob/living/carbon/human/H = parent.owner

	// Don't process on dead organs unless flagged
	if(parent.organ_flags & ORGAN_FAILING)
		if(!(characteristic_flag & IWOUND_PROGRESS_DEATH))
			return

	// Progress the wound
	if(characteristic_flag & IWOUND_RECOVER)
		treatment_slow()
	else if(characteristic_flag & IWOUND_PROGRESS && H && H.stat != DEAD)
		current_progression_tick++
		if(current_progression_tick >= progression_threshold)
			current_progression_tick = 0
			progress()

	// Apply damage to organ
	if((characteristic_flag & IWOUND_CAN_DAMAGE) && H)
		parent.applyOrganDamage(severity * 0.5)

	// Apply sanity damage from psy_damage
	if(psy_damage && H?.sanity)
		H.sanity.onPsyDamage(psy_damage * severity)

	// Chemical treatment check
	if(H)
		check_chem_treatment(H)

	// Spread to other organs
	if((characteristic_flag & IWOUND_SPREAD) && severity == spread_threshold && H)
		spread(H)

	// Hallucinations
	if((characteristic_flag & IWOUND_HALLUCINATE) && H?.sanity)
		current_hallucination_tick++
		if(current_hallucination_tick >= ticks_per_hallucination)
			current_hallucination_tick = 0
			var/num = rand(1,4)
			switch(num)
				if(1)
					H.sanity.effect_emote()
				if(2)
					H.sanity.effect_quote()
				if(3)
					H.sanity.effect_sound()
				if(4)
					H.sanity.effect_hallucination()

/// Progress the wound — increase severity or transform
/datum/internal_wound/proc/progress()
	if(severity < severity_max)
		severity++
		var/mob/living/carbon/human/H = parent?.owner
		if(H && (characteristic_flag & IWOUND_CAN_DAMAGE))
			to_chat(H, span_warning("Something inside your [parent?.name] hurts a lot."))
	else
		// At max severity — stop progressing, maybe transform
		characteristic_flag &= ~(IWOUND_PROGRESS|IWOUND_PROGRESS_DEATH)
		if(next_wound)
			parent?.add_internal_wound(next_wound)

/// Check if any reagents in the owner can treat this wound
/datum/internal_wound/proc/check_chem_treatment(mob/living/carbon/human/H)
	if(!H.reagents || !length(treatments_chem))
		return
	for(var/reagent_type in treatments_chem)
		var/datum/reagent/R = H.reagents.has_reagent(reagent_type)
		if(R && R.volume >= treatments_chem[reagent_type])
			treatment()
			return
	// Check stabilizers
	stabilized = FALSE
	for(var/reagent_type in stabilizers_chem)
		var/datum/reagent/R = H.reagents.has_reagent(reagent_type)
		if(R && R.volume >= stabilizers_chem[reagent_type])
			stabilized = TRUE
			break

/// Spread to another organ
/datum/internal_wound/proc/spread(mob/living/carbon/human/H)
	if(!H?.internal_organs)
		return
	var/list/other_organs = H.internal_organs.Copy() - parent
	if(!length(other_organs))
		return
	var/obj/item/organ/target = pick(other_organs)
	target.add_internal_wound(type)

/// Treat the wound — reduce severity
/datum/internal_wound/proc/treatment()
	if(severity > 0)
		severity--
		if(severity <= 0)
			qdel(src)
			return TRUE
	return FALSE

/// Slow recovery over time
/datum/internal_wound/proc/treatment_slow()
	if(prob(10))
		treatment()

/// Apply an item to treat the wound
/datum/internal_wound/proc/apply_item(obj/item/I, mob/user)
	for(var/path in treatments_item)
		if(istype(I, path))
			treatment()
			return TRUE
	return FALSE

/// Get the wound's description for diagnosis
/datum/internal_wound/proc/get_description()
	return name

/// Check if the wound is critical
/datum/internal_wound/proc/is_critical()
	return severity >= severity_max
