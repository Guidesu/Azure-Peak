/datum/wound/cripple
	name = "crippling wound"
	check_name = span_bone("<B>CRIPPLED</B>")
	severity = WOUND_SEVERITY_SEVERE
	whp = 70
	woundpain = 30
	mob_overlay = null
	sound_effect = "wetbreak"
	can_sew = FALSE
	can_cauterize = TRUE
	bleed_rate = 0
	sleep_healing = 0
	critical = TRUE
	var/crippled_zone

/datum/wound/cripple/on_mob_loss(mob/living/affected)
	. = ..()
	if(crippled_zone && istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.clear_part_damage(crippled_zone)

/datum/wound/cripple/limb
	name = "crippled limb"
	crit_message = list(
		"The leg gives out!",
		"The limb buckles and folds!",
		"The joint is smashed apart!",
	)
	var/slowdown = 1
	var/move_penalty = 0.15 SECONDS
	var/applied_penalty = 0

/datum/wound/cripple/limb/on_mob_gain(mob/living/affected)
	. = ..()
	affected.add_movespeed_modifier("cripple_[crippled_zone]", multiplicative_slowdown = slowdown)
	if(!applied_penalty && istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		if(animal.ai_controller)
			applied_penalty = move_penalty
			animal.ai_controller.movement_delay += applied_penalty
	affected.balloon_alert_to_viewers("<font color='#ff3b3b'>leg crippled!</font>")

/datum/wound/cripple/limb/on_mob_loss(mob/living/affected)
	. = ..()
	affected.remove_movespeed_modifier("cripple_[crippled_zone]")
	if(applied_penalty && istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		if(animal.ai_controller)
			animal.ai_controller.movement_delay -= applied_penalty
	applied_penalty = 0

/datum/wound/cripple/maw
	name = "shattered maw"
	crit_message = list(
		"The jaw is smashed!",
		"The maw is torn asunder!",
		"The fangs are broken loose!",
	)
	var/damage_penalty = 0.5
	var/removed_lower = 0
	var/removed_upper = 0

/datum/wound/cripple/maw/on_mob_gain(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		removed_lower = round(animal.melee_damage_lower * damage_penalty, 1)
		removed_upper = round(animal.melee_damage_upper * damage_penalty, 1)
		animal.melee_damage_lower = max(0, animal.melee_damage_lower - removed_lower)
		animal.melee_damage_upper = max(0, animal.melee_damage_upper - removed_upper)
	ADD_TRAIT(affected, TRAIT_NO_BITE, "[type]")
	affected.balloon_alert_to_viewers("<font color='#ff3b3b'>jaw shattered!</font>")

/datum/wound/cripple/maw/on_mob_loss(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.melee_damage_lower += removed_lower
		animal.melee_damage_upper += removed_upper
	REMOVE_TRAIT(affected, TRAIT_NO_BITE, "[type]")

/datum/wound/cripple/arm
	name = "mangled arm"
	crit_message = list(
		"The arm is mangled!",
		"The shoulder is wrenched apart!",
		"The arm is left hanging useless!",
	)
	var/damage_penalty = 0.35
	var/removed_lower = 0
	var/removed_upper = 0

/datum/wound/cripple/arm/on_mob_gain(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		removed_lower = round(animal.melee_damage_lower * damage_penalty, 1)
		removed_upper = round(animal.melee_damage_upper * damage_penalty, 1)
		animal.melee_damage_lower = max(0, animal.melee_damage_lower - removed_lower)
		animal.melee_damage_upper = max(0, animal.melee_damage_upper - removed_upper)
	affected.balloon_alert_to_viewers("<font color='#ff3b3b'>arm mangled!</font>")

/datum/wound/cripple/arm/on_mob_loss(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.melee_damage_lower += removed_lower
		animal.melee_damage_upper += removed_upper

/datum/wound/cripple/skull
	name = "caved skull"
	crit_message = list(
		"The skull cracks!",
		"The head is caved in!",
		"The skull is battered inward!",
	)
	whp = 85
	var/vision_penalty = 3
	var/removed_vision = 0
	var/removed_aggro = 0
	var/mortal_break = FALSE

/datum/wound/cripple/skull/on_mob_gain(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_affected = affected
		removed_vision = min(vision_penalty, max(0, hostile_affected.vision_range - 1))
		removed_aggro = min(vision_penalty, max(0, hostile_affected.aggro_vision_range - 1))
		hostile_affected.vision_range = max(1, hostile_affected.vision_range - removed_vision)
		hostile_affected.aggro_vision_range = max(1, hostile_affected.aggro_vision_range - removed_aggro)
	affected.Knockdown(10)
	if(mortal_break)
		ADD_TRAIT(affected, TRAIT_CRITICAL_WEAKNESS, "[type]")
	affected.balloon_alert_to_viewers("<font color='#ff3b3b'>skull caved!</font>")

/datum/wound/cripple/skull/on_mob_loss(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_affected = affected
		hostile_affected.vision_range += removed_vision
		hostile_affected.aggro_vision_range += removed_aggro
	if(mortal_break)
		REMOVE_TRAIT(affected, TRAIT_CRITICAL_WEAKNESS, "[type]")
