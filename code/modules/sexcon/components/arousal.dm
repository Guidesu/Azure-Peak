/**
 * Stub arousal component that delegates to Ratwood sex controller.
 * Keeps the /datum/component/arousal type path alive for all AP callers
 * while forwarding real work to the Ratwood sexcon system.
 */
/datum/component/arousal
	can_transfer = FALSE
	var/mob/living/carbon/human/user
	var/arousal = 0
	var/charge = SEX_MAX_CHARGE
	var/frozen = FALSE
	var/spent = FALSE

/datum/component/arousal/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	user = parent
	return ..()

/datum/component/arousal/proc/set_charge(amount)
	charge = clamp(amount, 0, SEX_MAX_CHARGE)

/datum/component/arousal/proc/adjust_charge(amount)
	charge = clamp(charge + amount, 0, SEX_MAX_CHARGE)

/datum/component/arousal/proc/adjust_arousal_special(datum/source, amount, forced = FALSE)
	if(user.sexcon)
		user.sexcon.adjust_arousal(amount)
	else
		arousal = clamp(arousal + amount, 0, MAX_AROUSAL)

/datum/component/arousal/proc/ejaculate_special()
	if(user.sexcon)
		user.sexcon.ejaculate()

