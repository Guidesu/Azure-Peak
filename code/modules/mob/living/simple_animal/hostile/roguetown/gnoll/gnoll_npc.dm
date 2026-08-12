/*
	NPC Gnoll — Blood Moon spawned hostile mob

	Gnolls are hyena-like beastmen that hunt in packs during blood moons.
	They use the werewolf icon set with a brownish tint.
	Stronger than wolves but weaker than werewolves.
	They despawn at dawn (handled by SSwildlife).
*/

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc
	name = "gnoll"
	desc = "A hunched, hyena-like beastman with matted fur and gleaming eyes. Its laugh chills the blood."
	icon = 'icons/roguetown/mob/monster/werewolf.dmi'
	icon_state = "wwolf_m"
	icon_living = "wwolf_m"
	icon_dead = "wwolf_dead"
	gender = MALE
	emote_hear = list("cackles", "giggles menacingly", "whoops")
	emote_see = null
	speak_chance = 2
	turns_per_move = 5
	see_in_dark = 7
	move_to_delay = 5
	base_intents = list(/datum/intent/simple/claw/simplewwnpc)
	head_butcher = /obj/item/natural/head/volf
	faction = list("gnoll")
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	health = 250
	maxHealth = 250
	melee_damage_lower = 18
	melee_damage_upper = 28
	obj_damage = 15
	vision_range = 8
	aggro_vision_range = 10
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = list('sound/vo/mobs/vw/attack (1).ogg','sound/vo/mobs/vw/attack (2).ogg','sound/vo/mobs/vw/attack (3).ogg')
	retreat_distance = 0
	minimum_distance = 0
	robust_searching = TRUE
	food_type = list(/obj/item/reagent_containers/food/snacks,
					/obj/item/natural/bone,
					/obj/item/natural/hide)
	footstep_type = FOOTSTEP_MOB_HEAVY
	STACON = 16
	STASTR = 16
	STAWIL = 12
	STASPD = 16
	simple_detect_bonus = 15
	food = 0
	dodgetime = 20
	aggressive = 1
	eat_forever = TRUE
	ai_controller = /datum/ai_controller/gnoll_npc
	move_base_delay = MOVEMENT_DELAY_SPD_3
	melee_cooldown = WOLF_ATTACK_SPEED
	ambush_faction = "gnoll"
	threat_point = THREAT_MODERATE

	botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/humanoid = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/wolf = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 1, /obj/item/natural/bone = 2)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/wolf = 2,
						/obj/item/reagent_containers/food/snacks/rogue/meat/humanoid = 1,
						/obj/item/natural/hide = 2,
						/obj/item/alch/sinew = 2,
						/obj/item/alch/bone = 1,
						/obj/item/alch/viscera = 1,
						/obj/item/natural/fur/wolf = 1,
						/obj/item/natural/bone = 3)
	perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/wolf = 2,
						/obj/item/reagent_containers/food/snacks/rogue/meat/humanoid = 2,
						/obj/item/natural/hide = 2,
						/obj/item/alch/sinew = 2,
						/obj/item/alch/bone = 1,
						/obj/item/alch/viscera = 1,
						/obj/item/natural/fur/wolf = 2,
						/obj/item/natural/bone = 4)

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_aggro_system)
	regenerate_icons()
	ADD_TRAIT(src, TRAIT_SIMPLE_WOUNDS, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	update_icon()
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, food_type)
	// Color tint to distinguish from werewolves
	add_atom_colour("#8B7355", ADMIN_COLOUR_PRIORITY)

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc/death(gibbed)
	..()
	if(gibbed)
		return
	update_icon()

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc/update_icon()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = icon_living

// ============================================================================
// Gnoll NPC AI Controller
// Pack-oriented: calls for help, hunts in groups
// ============================================================================

/datum/ai_controller/gnoll_npc
	ai_movement = /datum/ai_movement/hybrid_pathing

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_BASIC_MOB_TAMED = FALSE,
		BB_VISION_RANGE = 10,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/find_prey,
		/datum/ai_planning_subtree/call_reinforcements, // Pack behavior
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/circler,
		/datum/ai_planning_subtree/find_dead_bodies,
		/datum/ai_planning_subtree/eat_dead_body,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/eat_food,
	)
