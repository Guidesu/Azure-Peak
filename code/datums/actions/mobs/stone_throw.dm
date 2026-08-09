/datum/action/cooldown/mob_cooldown/telegraphed/ground/stone_throw
	name = "Stone Throw"
	desc = "Rips a stone from the earth and hurls it at a distant foe."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	cooldown_time = 20 SECONDS
	npc_min_range = 2
	npc_max_range = 7
	use_chance = 45
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	telegraph_time = TELEGRAPH_AREA_DENIAL
	telegraph_message = "digs into the ground and heaves up a massive rock!"
	telegraph_sound = 'sound/items/dig_shovel.ogg'
	recovery_time = 5 SECONDS
	recovery_slowdown = 2
	recovery_status = /datum/status_effect/debuff/vulnerable
	recovery_message = "is left off balance by the throw."

	blast_radius = 1
	damage = 40
	armor_pen = PEN_NONE
	impact_sound = 'sound/foley/smash_rock.ogg'
	hit_sound = list('sound/combat/hits/smashlimb (1).ogg','sound/combat/hits/smashlimb (2).ogg','sound/combat/hits/smashlimb (3).ogg')

	var/stone_type = /obj/effect/temp_visual/stone_throw
	var/travel_time = 4

/datum/action/cooldown/mob_cooldown/telegraphed/ground/stone_throw/resolve(atom/target, facing)
	var/mob/living/thrower = owner
	if(QDELETED(thrower) || !locked_turf)
		return
	thrower.visible_message(span_boldwarning("<b>[thrower]</b> chucks a huge rock!"))
	ability_sound(get_turf(thrower), 'sound/combat/shieldraise.ogg')
	var/obj/effect/temp_visual/stone = new stone_type(get_turf(thrower))
	animate(stone, pixel_x = (locked_turf.x - thrower.x) * 32, pixel_y = (locked_turf.y - thrower.y) * 32, time = travel_time)
	sleep(travel_time)
	if(!QDELETED(stone))
		stone.forceMove(locked_turf)
		stone.pixel_x = 0
		stone.pixel_y = 0
	return ..()

/obj/effect/temp_visual/stone_throw
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "stonebig1"
	name = "stone"
	desc = "You should scram..."
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	randomdir = FALSE
