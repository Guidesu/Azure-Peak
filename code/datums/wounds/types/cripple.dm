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
	var/break_alert
	var/mob/struck_by
	var/attack_delay_mult = 1
	var/static/list/kill_verbs = list("ENDED", "SLAIN", "SLAUGHTERED", "MURDERED", "SNUFFED", "BUTCHERED", "FELLED", "FINISHED")

/datum/wound/cripple/on_mob_gain(mob/living/affected)
	. = ..()
	if(attack_delay_mult != 1)
		affected.next_move_modifier *= attack_delay_mult
	if(break_alert)
		affected.balloon_alert_to_viewers("<font color='#ff3b3b'>[break_alert]</font>")

/datum/wound/cripple/on_mob_loss(mob/living/affected)
	. = ..()
	if(attack_delay_mult != 1)
		affected.next_move_modifier /= attack_delay_mult
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
	break_alert = "leg crippled!"
	var/slowdown = CRIPPLE_SLOWDOWN
	var/move_penalty = CRIPPLE_MOVE_PENALTY_MINOR
	var/applied_penalty = 0

/datum/wound/cripple/limb/on_mob_gain(mob/living/affected)
	. = ..()
	affected.add_movespeed_modifier("cripple_[crippled_zone]", multiplicative_slowdown = slowdown)
	if(!applied_penalty && istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		if(animal.ai_controller)
			applied_penalty = move_penalty
			animal.ai_controller.movement_delay += applied_penalty

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
	break_alert = "jaw shattered!"
	attack_delay_mult = CRIPPLE_ATTACK_DELAY_MAJOR
	var/damage_penalty = CRIPPLE_DAMAGE_PENALTY_MAJOR
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
	break_alert = "arm mangled!"
	attack_delay_mult = CRIPPLE_ATTACK_DELAY_MINOR
	var/damage_penalty = CRIPPLE_DAMAGE_PENALTY_MINOR
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

/datum/wound/cripple/arm/on_mob_loss(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.melee_damage_lower += removed_lower
		animal.melee_damage_upper += removed_upper

/datum/wound/cripple/arm/foreleg
	name = "mangled foreleg"
	crit_message = list(
		"The foreleg buckles!",
		"The foreleg is torn apart!",
		"The paw is crushed!",
	)
	break_alert = "foreleg maimed!"

/datum/wound/cripple/skull
	name = "caved skull"
	crit_message = list(
		"The skull cracks!",
		"The head is caved in!",
		"The skull is battered inward!",
	)
	break_alert = "skull caved!"
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

/datum/wound/cripple/skull/on_mob_loss(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_affected = affected
		hostile_affected.vision_range += removed_vision
		hostile_affected.aggro_vision_range += removed_aggro
	if(mortal_break)
		REMOVE_TRAIT(affected, TRAIT_CRITICAL_WEAKNESS, "[type]")

/datum/wound/cripple/decapitate
	name = "destroyed head"
	break_alert = "HEAD DESTROYED!"

/datum/wound/cripple/decapitate/on_mob_gain(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.no_reanimate = TRUE
	affected.visible_message(span_danger("<B>[affected] is <span class='crit'>[pick(kill_verbs)]</span> as [affected.p_their()] ravaged neck <span class='crit'>BLOSSOMS</span> into petals of <span class='crit'>GORE and BONE!</span></B>"))
	new /obj/effect/gibspawner/generic(affected.drop_location(), affected)
	affected.death()

/datum/wound/cripple/decapitate/small

/datum/wound/cripple/guts
	name = "spilled guts"
	break_alert = "GUTS SPILLED!"

/datum/wound/cripple/guts/on_mob_gain(mob/living/affected)
	. = ..()
	if(istype(affected, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = affected
		animal.no_reanimate = TRUE
	affected.visible_message(span_danger("<B>[affected] is <span class='crit'>[pick(kill_verbs)]</span> as [affected.p_their()] split belly <span class='crit'>UNSPOOLS</span> into ropes of <span class='crit'>GORE and OFFAL!</span></B>"))
	new /obj/item/alch/viscera(affected.drop_location())
	new /obj/effect/gibspawner/generic(affected.drop_location(), affected)
	affected.death()

/datum/wound/cripple/limb/topple
	name = "shattered leg"
	crit_message = list(
		"The leg shatters - it crashes to the ground!",
		"The knee is blown out, and it falls flat!",
	)
	break_alert = "toppled!"
	move_penalty = CRIPPLE_MOVE_PENALTY_MAJOR

/datum/wound/cripple/limb/topple/on_mob_gain(mob/living/affected)
	. = ..()
	affected.Stun(20, ignore_canstun = TRUE)
	animate(affected, transform = turn(affected.transform, 90), time = 2)

/datum/wound/cripple/limb/topple/on_mob_loss(mob/living/affected)
	. = ..()
	animate(affected, transform = turn(affected.transform, -90), time = 2)

/datum/wound/cripple/limb/undead
	name = "dragging leg"
	crit_message = list(
		"The leg snaps, and starts to drag behind it!",
		"The rotten limb folds under its own weight!",
		"The joint bursts apart in a spray of foul ichor!",
	)
	break_alert = "leg broken!"
	attack_delay_mult = CRIPPLE_ATTACK_DELAY_MAJOR

/datum/wound/cripple/limb/core
	name = "ruptured core"
	crit_message = list(
		"The core is burst apart!",
		"The core is pierced!",
		"The mass is torn open!",
	)
	break_alert = "core ruptured!"

/datum/wound/cripple/maw/fangs
	name = "shattered fangs"
	crit_message = list(
		"The fangs are snapped off!",
		"The mouthparts are torn away!",
		"The fangs are sheared off!",
	)
	break_alert = "fangs broken!"

/datum/wound/cripple/spinneret
	name = "burst spinnerets"
	crit_message = list(
		"The spinnerets are torn open!",
		"The abdomen is split!",
		"The silk glands are burst!",
	)
	break_alert = "spinnerets burst!"
	var/removed_ranged = FALSE

/datum/wound/cripple/spinneret/on_mob_gain(mob/living/affected)
	. = ..()
	var/mob/living/simple_animal/hostile/beast = affected
	if(istype(beast) && beast.ranged)
		beast.ranged = FALSE
		removed_ranged = TRUE

/datum/wound/cripple/spinneret/on_mob_loss(mob/living/affected)
	. = ..()
	var/mob/living/simple_animal/hostile/beast = affected
	if(removed_ranged && istype(beast))
		beast.ranged = TRUE
	removed_ranged = FALSE

/datum/wound/cripple/arm/tentacle
	name = "severed tentacle"
	crit_message = list(
		"The tentacle is severed!",
		"The tentacle is cut!",
		"The tentacle flies off in an arc!",
	)
	break_alert = "tentacle severed!"

/datum/wound/cripple/maw/tongue
	name = "severed tongue"
	crit_message = list(
		"The tongue is cut!",
		"The tongue is severed!",
		"The tongue flies off in an arc!",
	)
	break_alert = "tongue severed!"
