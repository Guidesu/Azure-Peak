/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/stone_throw
	name = "Stone Throw"
	desc = "Rips a stone from the earth and hurls it at a distant foe."
	cooldown_time = 20 SECONDS
	npc_min_range = 2
	npc_max_range = 7
	use_chance = 45
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	windup_time = TELEGRAPH_AREA_DENIAL
	telegraph_message = "digs into the ground and heaves up a massive rock!"
	telegraph_sound = list('sound/items/dig_shovel.ogg')
	recovery_time = 5 SECONDS
	recovery_slowdown = CHARGING_SLOWDOWN_MEDIUM
	recovery_status = /datum/status_effect/debuff/vulnerable
	recovery_message = "is left off balance by the throw."

	blast_radius = 1
	damage = 40
	blade_class = BCLASS_BLUNT
	strike_armor_pen = PEN_NONE
	impact_delay = 4
	strike_sound = 'sound/combat/shieldraise.ogg'
	detonate_sound = null
	hit_sound = list('sound/combat/hits/smashlimb (1).ogg','sound/combat/hits/smashlimb (2).ogg','sound/combat/hits/smashlimb (3).ogg')

	var/stone_type = /obj/effect/temp_visual/stone_throw

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/stone_throw/do_blade_animation(mob/living/H, facing)
	H.visible_message(span_boldwarning("<b>[H]</b> chucks a huge rock!"))
	var/obj/effect/temp_visual/stone = new stone_type(get_turf(H))
	animate(stone, pixel_x = (locked_turf.x - H.x) * 32, pixel_y = (locked_turf.y - H.y) * 32, time = impact_delay)
	return stone

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/stone_throw/on_impact(mob/living/H, facing, atom/movable/visual)
	if(!QDELETED(visual))
		visual.forceMove(locked_turf)
		visual.pixel_x = 0
		visual.pixel_y = 0
	playsound(locked_turf, 'sound/foley/smash_rock.ogg', 100, TRUE)

/obj/effect/temp_visual/stone_throw
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "stonebig1"
	name = "stone"
	desc = "You should scram..."
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	randomdir = FALSE
