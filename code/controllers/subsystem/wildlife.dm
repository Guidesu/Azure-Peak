/*
	Dynamic Wildlife Spawn/Despawn Subsystem (SSwildlife)

	Minecraft-style wildlife management:
	- Periodically spawns domestic/wild animals (chickens, pigs, cows, deer, goats) in outdoor areas
	- Each spawned mob gets a despawn timer: if no player has been within N tiles for M minutes, qdel()
	- Caps total wildlife per z-level to avoid buildup
	- Moon-gated spawning: full moon -> NPC werewolves, blood moon -> NPC gnolls
	- Despawns moon-spawned creatures at dawn

	Spawn logic:
	1. Every SSwildlife.wait interval, pick random safe outdoor turfs
	2. Check if there are already enough wildlife nearby (local cap)
	3. Spawn an appropriate animal for the area/season
	4. Tag the mob with a despawn tracker component

	Despawn logic:
	- Each wildlife mob checks in Life() if any player is within DESPAWN_PLAYER_RANGE
	- If no player has been near for DESPAWN_TIME, the mob vanishes
	- Moon-spawned mobs (werewolves/gnolls) despawn at dawn regardless
*/

SUBSYSTEM_DEF(wildlife)
	name = "Wildlife"
	flags = SS_BACKGROUND
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME

	/// Maximum wildlife mobs per z-level
	var/max_wildlife_per_z = 25

	/// Maximum moon-spawned mobs (werewolves/gnolls) per z-level
	var/max_moon_spawned_per_z = 5

	/// How far to look for players when checking despawn
	var/despawn_player_range = 12

	/// How long (in deciseconds) a mob must be player-less before despawning
	var/despawn_time = 10 MINUTES

	/// List of all tracked wildlife mobs
	var/list/tracked_wildlife = list()

	/// List of all moon-spawned mobs (werewolves/gnolls) that despawn at dawn
	var/list/moon_spawned = list()

	/// Wildlife spawn candidates by season — weighted lists (mob path = weight)
	/// Prey animals (saiga, cow, goat, chicken, swine, cat, fogbeast) spawn in safer outdoor areas
	/// Small predators (fox, raccoon, badger, bobcat, bigrat) spawn in wilderness
	/// Large predators (wolf, boar) spawn in deep wilderness, more in winter
	var/list/spring_wildlife = list(
		// Prey (common in spring - birthing season)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/saiga = 30,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goat = 20,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goatmale = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cow = 15,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bull = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/chicken = 20,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/swine = 15,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fogbeast = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cat = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/camel = 5,
		// Small predators
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fox = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/raccoon = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/badger = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bobcat = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/hyena = 3,
		// Large predators (rarer in spring)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf = 3,
	)
	var/list/summer_wildlife = list(
		// Prey (common)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/saiga = 25,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goat = 15,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goatmale = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cow = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bull = 4,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/chicken = 18,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/swine = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fogbeast = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cat = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/camel = 5,
		// Small predators (active in summer)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fox = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/raccoon = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/badger = 6,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bobcat = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/hyena = 5,
		// Large predators
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf = 5,
	)
	var/list/autumn_wildlife = list(
		// Prey (still common, fattening for winter)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/saiga = 20,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goat = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goatmale = 6,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cow = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bull = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/chicken = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/swine = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fogbeast = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cat = 3,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/camel = 3,
		// Small predators (stocking up)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fox = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/raccoon = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/badger = 6,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bobcat = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/hyena = 8,
		// Large predators (more active in autumn)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf = 10,
	)
	var/list/winter_wildlife = list(
		// Prey (scarce in winter)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/saiga = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goat = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/goatmale = 4,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/cow = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/swine = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fogbeast = 2,
		// Small predators (desperate, more visible)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/fox = 12,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/raccoon = 6,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/badger = 5,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bobcat = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/bigrat = 10,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/hyena = 10,
		// Large predators (very active — hungry wolves hunt in winter)
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar = 8,
		/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf = 20,
	)

/datum/controller/subsystem/wildlife/Initialize(start_timeofday)
	return ..()

/datum/controller/subsystem/wildlife/fire(resumed)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return

	// Don't spawn during round setup
	if(GLOB.tod == "night" && (is_full_moon() || GLOB.is_blood_moon))
		try_spawn_moon_creatures()

	// Normal wildlife spawning during day/dawn/dusk
	if(GLOB.tod != "night")
		try_spawn_wildlife()

	// Check despawn for all tracked wildlife
	check_despawns()

	// Despawn moon creatures at dawn
	if(GLOB.tod == "dawn")
		despawn_moon_creatures()

/// Attempts to spawn wildlife in outdoor areas
/datum/controller/subsystem/wildlife/proc/try_spawn_wildlife()
	var/list/parts = resolve_ic_date_parts(GLOB.dayspassed)
	var/season = get_season_from_month(parts[2])
	var/list/candidates

	switch(season)
		if("Spring")
			candidates = spring_wildlife
		if("Summer")
			candidates = summer_wildlife
		if("Autumn")
			candidates = autumn_wildlife
		if("Winter")
			candidates = winter_wildlife

	if(!candidates || !length(candidates))
		return

	// Pick a random outdoor turf on the main z-level
	var/turf/spawn_turf = get_random_outdoor_turf()
	if(!spawn_turf)
		return

	// Check local wildlife count
	var/local_count = 0
	for(var/mob/living/L in range(15, spawn_turf))
		if(L in tracked_wildlife)
			local_count++
	if(local_count >= 5)
		return

	// Check z-level cap
	var/z_count = 0
	for(var/mob/M in tracked_wildlife)
		if(M.z == spawn_turf.z)
			z_count++
	if(z_count >= max_wildlife_per_z)
		return

	// Spawn the wildlife (weighted pick)
	var/mob_type = pickweight(candidates)
	var/mob/living/spawned = new mob_type(spawn_turf)
	if(spawned)
		tracked_wildlife += spawned
		RegisterSignal(spawned, COMSIG_PARENT_QDELETING, PROC_REF(on_wildlife_deleted))
		spawned.AddComponent(/datum/component/wildlife_tracker)

/// Attempts to spawn moon-gated creatures (werewolves on full moon, gnolls on blood moon)
/datum/controller/subsystem/wildlife/proc/try_spawn_moon_creatures()
	if(!is_full_moon() && !GLOB.is_blood_moon)
		return

	var/turf/spawn_turf = get_random_wilderness_turf()
	if(!spawn_turf)
		return

	// Check moon-spawned cap
	var/z_count = 0
	for(var/mob/M in moon_spawned)
		if(M.z == spawn_turf.z)
			z_count++
	if(z_count >= max_moon_spawned_per_z)
		return

	if(GLOB.is_blood_moon)
		// Blood moon: spawn gnolls
		var/mob/living/carbon/simple_animal/hostile/retaliate/rogue/gnoll_npc/spawned = new(spawn_turf)
		if(spawned)
			moon_spawned += spawned
			RegisterSignal(spawned, COMSIG_PARENT_QDELETING, PROC_REF(on_moon_spawn_deleted))
	else if(is_full_moon())
		// Regular full moon: spawn werewolves (less frequently)
		if(prob(40))
			var/mob/living/carbon/simple_animal/hostile/retaliate/rogue/werewolf_npc/spawned = new(spawn_turf)
			if(spawned)
				moon_spawned += spawned
				RegisterSignal(spawned, COMSIG_PARENT_QDELETING, PROC_REF(on_moon_spawn_deleted))

/// Called when a blood moon begins
/datum/controller/subsystem/wildlife/proc/on_blood_moon()
	// Immediately try to spawn some gnolls
	for(var/i in 1 to 3)
		try_spawn_moon_creatures()

/// Despawns all moon-spawned creatures (called at dawn)
/datum/controller/subsystem/wildlife/proc/despawn_moon_creatures()
	if(!length(moon_spawned))
		return
	for(var/mob/M in moon_spawned)
		if(QDELETED(M))
			continue
		if(istype(M, /mob/living))
			var/mob/living/L = M
			if(L.stat != DEAD)
				// Fade out and delete
				animate(L, alpha = 0, time = 3 SECONDS)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), L), 3 SECONDS)
	moon_spawned.Cut()

/// Checks all tracked wildlife for despawn conditions
/datum/controller/subsystem/wildlife/proc/check_despawns()
	for(var/mob/living/L in tracked_wildlife)
		if(QDELETED(L))
			continue
		var/datum/component/wildlife_tracker/tracker = L.GetComponent(/datum/component/wildlife_tracker)
		if(!tracker)
			continue
		tracker.check_despawn()

/// Signal handler for wildlife deletion
/datum/controller/subsystem/wildlife/proc/on_wildlife_deleted(datum/source)
	SIGNAL_HANDLER
	tracked_wildlife -= source

/// Signal handler for moon-spawned deletion
/datum/controller/subsystem/wildlife/proc/on_moon_spawn_deleted(datum/source)
	SIGNAL_HANDLER
	moon_spawned -= source

/// Gets a random outdoor turf suitable for wildlife spawning
/datum/controller/subsystem/wildlife/proc/get_random_outdoor_turf()
	var/list/candidates = list()
	for(var/area/A in GLOB.areas)
		if(!A.outdoors)
			continue
		// Skip dangerous/indoor areas
		if(istype(A, /area/rogue/outdoors))
			for(var/turf/T in A)
				if(isopenturf(T) && !is_blocked_turf(T))
					candidates += T
					if(candidates.len >= 100)
						break
		if(candidates.len >= 100)
			break

	if(!length(candidates))
		return null
	return pick(candidates)

/// Gets a random wilderness turf suitable for moon-spawned creatures
/datum/controller/subsystem/wildlife/proc/get_random_wilderness_turf()
	var/list/candidates = list()
	for(var/area/A in GLOB.areas)
		if(!A.outdoors)
			continue
		// Prefer forest/wilderness areas
		if(istype(A, /area/rogue/outdoors/woods) || istype(A, /area/rogue/outdoors))
			for(var/turf/T in A)
				if(isopenturf(T) && !is_blocked_turf(T))
					// Check it's far from players
					var/has_player_nearby = FALSE
					for(var/mob/living/carbon/human/H in GLOB.player_list)
						if(get_dist(T, H) < 15)
							has_player_nearby = TRUE
							break
					if(!has_player_nearby)
						candidates += T
						if(candidates.len >= 50)
							break
		if(candidates.len >= 50)
			break

	if(!length(candidates))
		return null
	return pick(candidates)

/// Checks if a turf is blocked (walls, dense objects, etc)
/datum/controller/subsystem/wildlife/proc/is_blocked_turf(turf/T)
	if(!T)
		return TRUE
	if(T.density)
		return TRUE
	for(var/atom/movable/AM in T)
		if(AM.density)
			return TRUE
	return FALSE

// ============================================================================
// Wildlife Tracker Component
// ============================================================================

/datum/component/wildlife_tracker
	var/last_player_near_time = 0
	var/despawn_range = 12
	var/despawn_delay = 10 MINUTES

/datum/component/wildlife_tracker/Initialize()
	. = ..()
	last_player_near_time = world.time

/datum/component/wildlife_tracker/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/wildlife_tracker/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)

/datum/component/wildlife_tracker/proc/on_life(mob/living/source)
	SIGNAL_HANDLER
	if(!SSwildlife || SSwildlife.flags & SS_NO_FIRE)
		return
	check_despawn()

/datum/component/wildlife_tracker/proc/check_despawn()
	var/mob/living/L = parent
	if(!istype(L) || QDELETED(L))
		return
	if(L.stat == DEAD)
		return

	var/player_nearby = FALSE
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		if(get_dist(L, H) <= despawn_range)
			player_nearby = TRUE
			break

	if(player_nearby)
		last_player_near_time = world.time
	else if(world.time - last_player_near_time > despawn_delay)
		// Despawn: fade out and delete
		animate(L, alpha = 0, time = 2 SECONDS)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), L), 2 SECONDS)
