/*
	Predator Hunting Behavior

	AI subtree that makes predatory mobs (wolves, foxes, bears) hunt
	non-hostile animals (chickens, cows, goats, saiga, etc.) for food.

	The behavior:
	1. If the predator has no current target, look for nearby animals
	2. If an animal is found within vision range, set it as the attack target
	3. The existing melee attack subtree will then handle killing it
	4. After killing, the eat_dead_body subtree handles consumption
*/

/// Blackboard key for whether the mob is currently hunting prey
#define BB_HUNTING_PREY "hunting_prey"

/datum/ai_planning_subtree/find_prey
	/// How often to re-scan for prey (deciseconds)
	var/rescan_interval = 5 SECONDS

/datum/ai_planning_subtree/find_prey/SelectBehaviors(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn || living_pawn.stat != CONSCIOUS)
		return

	// Don't hunt if we already have a target
	var/datum/weakref/existing_target = controller.blackboard[BB_ATTACK_TARGET]
	if(existing_target && existing_target.resolve())
		return

	// Throttle prey scanning
	var/last_scan = controller.blackboard["last_prey_scan"] || 0
	if(world.time < last_scan + rescan_interval)
		return

	controller.blackboard["last_prey_scan"] = world.time

	// Find nearby prey
	var/mob/living/prey = find_nearest_prey(living_pawn, controller.blackboard[BB_VISION_RANGE] || 7)
	if(prey)
		controller.blackboard[BB_ATTACK_TARGET] = WEAKREF(prey)
		controller.blackboard[BB_HUNTING_PREY] = TRUE

/// Finds the nearest valid prey animal within the given range
/datum/ai_planning_subtree/find_prey/proc/find_nearest_prey(mob/living/predator, range)
	var/closest_dist = range + 1
	var/mob/living/closest_prey = null

	for(var/mob/living/L in range(range, predator))
		if(L == predator)
			continue
		if(L.stat == DEAD)
			continue
		if(!is_valid_prey(L))
			continue
		var/dist = get_dist(predator, L)
		if(dist < closest_dist)
			closest_dist = dist
			closest_prey = L

	return closest_prey

/// Returns TRUE if the mob is valid prey for predators
/datum/ai_planning_subtree/find_prey/proc/is_valid_prey(mob/living/L)
	// Only hunt simple animals
	if(!isanimal(L))
		return FALSE
	// Don't hunt other large predators
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf))
		return FALSE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/werewolf_npc))
		return FALSE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc))
		return FALSE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/troll))
		return FALSE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/direbear))
		return FALSE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar))
		return FALSE // Boars are too tough to be prey
	// Hunt domestic animals
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/chicken))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/cow))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/bull))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/goat))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/goatmale))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/swine))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/cat))
		return TRUE
	// Hunt wild herd animals
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/saiga))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/fogbeast))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/camel))
		return TRUE
	// Hunt small animals (easy prey for wolves)
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/fox))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/raccoon))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/badger))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/bobcat))
		return TRUE
	if(istype(L, /mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat))
		return TRUE
	return FALSE
