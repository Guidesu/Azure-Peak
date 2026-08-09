/datum/action/cooldown/spell/telegraphed_strike/mob_ability/bear_swipe
	name = "bear swipe"
	desc = "Swipes at someone with a huge paw"
	cooldown_time = 10 SECONDS
	npc_max_range = 1
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	windup_time = 1 SECONDS
	telegraph_message = "rears up to swipe!"
	strike_sound = 'sound/combat/shieldraise.ogg'
	detonate_sound = null
	hit_sound = list('sound/combat/hits/punch/punch (1).ogg')

	damage = 40
	blade_class = BCLASS_STAB
	strike_armor_pen = PEN_MEDIUM

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/bear_swipe/get_pattern_offsets()
	return list(list(0, 1))

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/bear_swipe/on_hit_target(mob/living/H, mob/living/L, facing)
	L.apply_status_effect(/datum/status_effect/debuff/staggered)
	new /obj/effect/temp_visual/paw_swipe(get_turf(L))
	to_chat(L, span_userdanger("You're hit by a powerful swipe!"))

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/bear_swipe/on_strike_complete(mob/living/H, hit_count, deflected)
	. = ..()
	if(!hit_count)
		H.visible_message(span_alert("[H] roars in frustration as its swipe finds nothing."))

/obj/effect/temp_visual/paw_swipe
	icon = 'icons/effects/effects.dmi'
	icon_state = "claw"
	name = "bear paw"
	desc = "It's huge"
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	randomdir = FALSE
