/datum/kink
	abstract_type = /datum/kink
	var/name = "Unknown Kink"
	var/description = "No description available."
	var/category = "General"

/datum/kink/proc/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	return FALSE

/datum/kink/bondage
	name = "Bondage"
	description = "Arousal from restricting the partner's or one's own freedom."
	category = "Dominance"

/datum/kink/bondage/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	if(!owner || !partner || !L)
		return FALSE

	if(owner.is_restrained() || partner.is_restrained())
		return TRUE

	if(owner.has_kink_tag(type) || partner.has_kink_tag(type))
		return TRUE

	return FALSE

/datum/kink/domination
	name = "Domination"
	description = "Arousal from control and the leading role."
	category = "Dominance"

/datum/kink/domination/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	if(!owner || !partner || !L)
		return FALSE

	if(!L.is_giving(owner))
		return FALSE

	if(partner.is_restrained())
		return TRUE

	if(partner.is_surrendering_to(owner))
		return TRUE

	if(owner.has_kink_tag(type))
		return TRUE

	return FALSE

/datum/kink/submissive
	name = "Submission"
	description = "Arousal from a submissive role."
	category = "Submission"

/datum/kink/submissive/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	if(!owner || !partner || !L)
		return FALSE

	if(L.is_giving(owner))
		return FALSE

	if(owner.is_restrained())
		return TRUE

	if(owner.is_surrendering_to(partner))
		return TRUE

	if(owner.has_kink_tag(type))
		return TRUE

	return FALSE

#define KINK_FORCE_GENTLE_MAX SEX_FORCE_LOW
#define KINK_FORCE_ROUGH_MIN  SEX_FORCE_HIGH

/datum/kink/gentle
	name = "Gentle"
	description = "Arousal from gentle sex."
	category = "General"

/datum/kink/gentle/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	return (L.force <= KINK_FORCE_GENTLE_MAX && L.speed <= SEX_SPEED_LOW)

/datum/kink/rough
	name = "Rough"
	description = "Arousal from rough and hard sex."
	category = "General"

/datum/kink/rough/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	return (L.force >= KINK_FORCE_ROUGH_MIN || L.speed >= SEX_SPEED_HIGH)

#undef KINK_FORCE_GENTLE_MAX
#undef KINK_FORCE_ROUGH_MIN

/datum/kink/public
	name = "Public"
	description = "Arousal from sex when seen by those not participating in the current session."
	category = "Fetishes"

/datum/kink/public/is_active_for(datum/erp_actor/owner, datum/erp_actor/partner, datum/erp_sex_link/L)
	var/mob/M = owner?.physical
	if(!M)
		return FALSE

	var/turf/T = get_turf(M)
	if(!T)
		return FALSE

	if(T.outdoor_effect?.weatherproof)
		return TRUE

	for(var/mob/living/kink_object in view(5, M))
		if(kink_object == owner.physical || kink_object == partner?.physical)
			continue
		if(kink_object.client)
			return TRUE

	return FALSE
