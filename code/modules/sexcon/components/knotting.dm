/**
 * Stub knotting component that delegates to Ratwood sex controller.
 */
/datum/component/knotting
	can_transfer = FALSE
	var/mob/living/carbon/human/user

/datum/component/knotting/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	user = parent
	return ..()

