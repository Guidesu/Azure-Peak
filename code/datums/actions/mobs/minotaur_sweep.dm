/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep
	name = "Great Sweep"
	desc = "Sweeps your weapon forward in a committed arc that leaves yourself wide open, inflicting heavy damage to anything and anyone in the way."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 14 SECONDS
	max_range = 2
	use_chance = 55
	overhead_y_offset = 48
	overhead_x_offset = 16
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	telegraph_time = TELEGRAPH_AREA_DENIAL
	telegraph_message = "shoulders its weapon, readying for a wide swing!"
	telegraph_sound = 'sound/combat/rend_start.ogg'
	band_delay = 7
	band_damage_mult = list(1, 1.5, 2)
	final_band_bonus = 0.8
	victim_slowdown = 2
	recovery_time = 6 SECONDS
	recovery_slowdown = 3
	recovery_message = "is wide open!"

	damage = 60
	blade_class = BCLASS_CUT
	armor_flag = "slash"
	armor_pen = PEN_HEAVY
	impact_sound = list('sound/combat/wooshes/blunt/wooshhuge (1).ogg','sound/combat/wooshes/blunt/wooshhuge (2).ogg','sound/combat/wooshes/blunt/wooshhuge (3).ogg')
	hit_sound = 'sound/combat/sidesweep_hit.ogg'

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/telegraph_offsets(atom/target)
	var/list/flat = list()
	for(var/list/band in telegraph_bands(target))
		for(var/list/off in band)
			flat |= list(off)
	return flat

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/on_impact_turf(turf/T, mob/living/user)
	var/obj/effect/temp_visual/special_intent/fx = new (T, 0.5 SECONDS)
	fx.icon = 'icons/effects/effects.dmi'
	fx.icon_state = "sweep_fx"

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/hit_mob(mob/living/victim, mob/living/user)
	. = ..()
	if(.)
		victim.visible_message(span_userdanger("[user]'s swing catches [victim]!"))

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/axe
	name = "Great Swipe"
	desc = "A wide axe arc that travels out and back across its whole front."
	impact_sound = list('sound/combat/sp_axe_swing1.ogg','sound/combat/sp_axe_swing2.ogg','sound/combat/sp_axe_swing3.ogg')
	hit_sound = 'sound/combat/sp_gsword_hit.ogg'

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/axe/telegraph_bands(atom/target)
	var/list/inner = list(list(-1, 0), list(-1, 1), list(0, 1), list(1, 1), list(1, 0))
	var/list/outer = list(list(-2, 0), list(-2, 1), list(-1, 2), list(0, 2), list(1, 2), list(2, 1), list(2, 0))
	return list(inner, outer, inner)

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/slam
	name = "Ground Slam"
	desc = "Smashes your feet forward into the ground, sending shockwave to damage everyone in the area."
	blade_class = BCLASS_BLUNT
	armor_flag = "blunt"
	damage = 60
	telegraph_sound = 'sound/combat/ground_smash_start.ogg'
	impact_sound = list('sound/combat/ground_smash1.ogg','sound/combat/ground_smash2.ogg','sound/combat/ground_smash3.ogg')
	hit_sound = list('sound/combat/hits/smashlimb (1).ogg','sound/combat/hits/smashlimb (2).ogg','sound/combat/hits/smashlimb (3).ogg')
	max_range = 3
	self_targetable = TRUE
	lock_facing = FALSE
	track_target = TRUE
	freeze_windup = FALSE
	charging_slowdown = 3

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/slam/telegraph_bands(atom/target)
	var/list/front = list(list(-1, 1), list(0, 1), list(1, 1))
	var/list/around = list(list(-1, 0), list(1, 0), list(-1, -1), list(0, -1), list(1, -1))
	return list(front, around, front)

/datum/action/cooldown/mob_cooldown/telegraphed/area/minotaur_sweep/slam/on_impact_turf(turf/T, mob/living/user)
	. = ..()
	for(var/obj/structure/S in T)
		S.take_damage(damage, BRUTE, "blunt", TRUE)
