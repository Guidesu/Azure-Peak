// Human sanity integration — hooks the sanity datum into human mobs

/mob/living/carbon/human
	/// Sanity datum — handles long-term mental health, breakdowns, and insight
	var/datum/sanity/sanity

/mob/living/carbon/human/Initialize()
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_NOMOOD))
		sanity = new(src)

/mob/living/carbon/human/Destroy()
	QDEL_NULL(sanity)
	return ..()

/// Take sanity damage from witnessing death
/mob/living/carbon/human/proc/onWitnessDeath()
	if(sanity)
		sanity.onWitnessDeath()

/// Take sanity damage from psychic/magical sources
/mob/living/carbon/human/proc/onPsyDamage(damage)
	if(sanity)
		sanity.onPsyDamage(damage)

/// Take sanity damage from body injury
/mob/living/carbon/human/proc/onHurt(damage)
	if(sanity)
		sanity.onHurt(damage)

/// Get current sanity level (0-100)
/mob/living/carbon/human/proc/get_sanity()
	if(sanity)
		return sanity.get_level()
	return 100

/// Get current insight
/mob/living/carbon/human/proc/get_insight()
	if(sanity)
		return sanity.get_insight()
	return 0

/// Hook into apply_damage to trigger sanity loss from injuries
/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, forced = FALSE, spread_damage = FALSE)
	. = ..()
	if(. && sanity && damage > 5)
		sanity.onHurt(damage)

/// Hook into death to trigger witness sanity damage for nearby humans
/mob/living/carbon/human/death(gibbed, nocutscene = FALSE)
	. = ..()
	// Nearby humans witness the death and take sanity damage
	for(var/mob/living/carbon/human/H in viewers(7, src))
		if(H == src || H.stat == DEAD)
			continue
		if(H.sanity)
			H.sanity.onWitnessDeath()
