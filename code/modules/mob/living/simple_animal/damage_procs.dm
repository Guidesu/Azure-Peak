
/mob/living/carbon/simple_animal/proc/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	// Route through carbon's bodypart damage system
	if(amount > 0)
		take_overall_damage(amount, 0, 0, updating_health)
	else
		heal_overall_damage(abs(amount), 0, 0, null, updating_health)
	return amount

/mob/living/carbon/simple_animal/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	var/coeff = forced ? 1 : damage_coeff[BRUTE]
	if(!coeff)
		return
	amount *= coeff * CONFIG_GET(number/damage_multiplier)
	if(amount > 0)
		take_overall_damage(amount, 0, 0, updating_health)
	else
		heal_overall_damage(abs(amount), 0, 0, null, updating_health)
	return amount

/mob/living/carbon/simple_animal/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	var/coeff = forced ? 1 : damage_coeff[BURN]
	if(!coeff)
		return
	amount *= coeff * CONFIG_GET(number/damage_multiplier)
	if(amount > 0)
		take_overall_damage(0, amount, 0, updating_health)
	else
		heal_overall_damage(0, abs(amount), 0, null, updating_health)
	return amount

/mob/living/carbon/simple_animal/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && damage_coeff[OXY] == 0)
		return
	amount *= CONFIG_GET(number/damage_multiplier)
	if(!forced)
		amount *= damage_coeff[OXY]
	return ..(amount, updating_health, forced)

/mob/living/carbon/simple_animal/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && damage_coeff[TOX] == 0)
		return
	amount *= CONFIG_GET(number/damage_multiplier)
	if(!forced)
		amount *= damage_coeff[TOX]
	return ..(amount, updating_health, forced)

/mob/living/carbon/simple_animal/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && damage_coeff[CLONE] == 0)
		return
	amount *= CONFIG_GET(number/damage_multiplier)
	if(!forced)
		amount *= damage_coeff[CLONE]
	return ..(amount, updating_health, forced)

/mob/living/carbon/simple_animal/adjustStaminaLoss(amount, updating_health, forced = FALSE)
	if(damage_coeff[STAMINA] == 0)
		return
	return ..(amount, updating_health, forced)
