
/*
 * Mob Affix System
 * Roguelike suffix/prefix modifiers that can spawn on any /mob/living.
 * Displayed in the mob's name and applied on spawn.
 */

GLOBAL_LIST_INIT(mob_affixes, list(
	/datum/mob_affix/berserker = 16,
	/datum/mob_affix/regenerative = 12,
	/datum/mob_affix/radioactive = 8,
	/datum/mob_affix/explosive = 8,
	/datum/mob_affix/venomous = 12,
	/datum/mob_affix/swift = 15,
	/datum/mob_affix/armored = 14,
	/datum/mob_affix/weak = 10,
	/datum/mob_affix/fiery = 10,
	/datum/mob_affix/frostbound = 9,
	/datum/mob_affix/shocking = 9,
	/datum/mob_affix/cursed = 8,
	/datum/mob_affix/blessed = 7,
	/datum/mob_affix/giant = 10,
	/datum/mob_affix/tiny = 8,
	/datum/mob_affix/vampiric = 10,
	/datum/mob_affix/reflective = 9,
	/datum/mob_affix/toxic = 11,
	/datum/mob_affix/undying = 6,
	/datum/mob_affix/frenzied = 11,
	/datum/mob_affix/steadfast = 9,
	/datum/mob_affix/keen = 10,
	/datum/mob_affix/clumsy = 8,
	/datum/mob_affix/invisible = 6,
	/datum/mob_affix/lucky = 7,
	/datum/mob_affix/unlucky = 6,
	/datum/mob_affix/wild = 12,
	/datum/mob_affix/diseased = 9,
	/datum/mob_affix/feral = 11,
	/datum/mob_affix/eldritch = 5,
))

/// Roll and apply weighted affixes to a mob.
/proc/roll_mob_affixes(mob/living/M, tier = 1, force = FALSE)
	if(!M || QDELETED(M) || M.client || M.ckey)
		return
	if(!force && !prob(MOB_AFFIX_BASE_CHANCE))
		return
	if(!M.affix_base_name)
		M.affix_base_name = M.real_name || M.name
	var/max_count = min(MAX_MOB_AFFIXES, 1 + tier)
	var/count = clamp(rand(0, max_count) + tier - 1, 0, max_count)
	if(count <= 0)
		return

	var/list/candidates = list()
	for(var/T in GLOB.mob_affixes)
		var/datum/mob_affix/A = new T
		if(A.can_apply(M))
			candidates[A] = A.weight
		else
			qdel(A)

	var/list/picked = list()
	while(count > 0 && candidates.len)
		var/datum/mob_affix/A = pickweight(candidates)
		candidates -= A
		var/ok = TRUE
		for(var/datum/mob_affix/B as anything in picked)
			if(B.type == A.type || (B.type in A.forbidden_affixes) || (A.type in B.forbidden_affixes))
				ok = FALSE
				break
		if(ok)
			picked += A
			count--
		else
			qdel(A)

	for(var/datum/mob_affix/A as anything in picked)
		A.apply(M, tier)
		M.mob_affixes += A
		A.parent_mob = M
	M.update_affix_name()

/// Base affix datum.
/datum/mob_affix
	var/name = ""
	var/description = ""
	var/affix_type = AFFIX_PREFIX_MOB
	var/alignment = AFFIX_ALIGNMENT_NEUTRAL
	var/weight = 10
	var/color = "#ffffff"
	var/list/forbidden_affixes = list()
	var/list/stat_mods = list()  // e.g. list(MA_STAT_STR = 2)
	var/list/traits = list()
	var/list/allowed_mob_types = list(/mob/living)
	var/mob/living/parent_mob
	var/next_process = 0
	var/process_interval = 3 SECONDS

/datum/mob_affix/proc/affix_process()
	return

/datum/mob_affix/proc/can_apply(mob/living/M)
	if(!M)
		return FALSE
	for(var/T in allowed_mob_types)
		if(istype(M, T))
			return TRUE
	return FALSE

/datum/mob_affix/proc/apply(mob/living/M, tier = 1)
	parent_mob = M
	RegisterSignal(parent_mob, COMSIG_LIVING_DEATH, PROC_REF(handle_parent_death))
	for(var/stat in stat_mods)
		if(stat in M.vars)
			M.vars[stat] += stat_mods[stat] * tier
	for(var/T in traits)
		ADD_TRAIT(M, T, TRAIT_GENERIC)
	on_apply(M, tier)

/datum/mob_affix/proc/on_apply(mob/living/M, tier = 1)
	return

/datum/mob_affix/proc/remove(mob/living/M)
	for(var/stat in stat_mods)
		if(stat in M.vars)
			M.vars[stat] -= stat_mods[stat]
	for(var/T in traits)
		REMOVE_TRAIT(M, T, TRAIT_GENERIC)
	on_remove(M)
	UnregisterSignal(parent_mob, COMSIG_LIVING_DEATH)
	parent_mob = null

/datum/mob_affix/proc/on_remove(mob/living/M)
	return

/datum/mob_affix/proc/on_death(mob/living/M)
	return

/datum/mob_affix/proc/handle_parent_death(datum/source, gibbed)
	SIGNAL_HANDLER
	on_death(parent_mob)

/datum/mob_affix/Destroy()
	parent_mob = null
	return ..()

/// Helpers for periodic auras.
/datum/mob_affix/proc/aura_damage(range, brute = 0, fire = 0, tox = 0)
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(range, parent_mob))
		if(L == parent_mob)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		if(brute)
			L.adjustBruteLoss(brute)
		if(fire)
			L.adjustFireLoss(fire)
		if(tox)
			L.adjustToxLoss(tox)

/// Helpers for leeching life from a nearby target.
/datum/mob_affix/proc/leech_nearby(range, damage = 3, heal = 3)
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	var/list/targets = list()
	for(var/mob/living/L in view(range, parent_mob))
		if(L == parent_mob)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		if(L.stat == DEAD)
			continue
		targets += L
	if(!targets.len)
		return
	var/mob/living/T = pick(targets)
	T.adjustBruteLoss(damage)
	parent_mob.adjustBruteLoss(-heal)
	parent_mob.adjustFireLoss(-heal)

// =================== AFFIX SUBTYPES ===================

/datum/mob_affix/berserker
	name = "Berserker"
	description = "Deals more damage and moves faster, but is less resilient."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 16
	color = "#ff4444"
	stat_mods = list(MA_STAT_STR = 4, MA_STAT_SPD = 3, MA_STAT_CON = -2)
	forbidden_affixes = list(/datum/mob_affix/steadfast, /datum/mob_affix/clumsy, /datum/mob_affix/weak)

/datum/mob_affix/berserker/on_apply(mob/living/M, tier = 1)
	if(istype(M, /mob/living/carbon/simple_animal/hostile))
		var/mob/living/carbon/simple_animal/hostile/H = M
		H.melee_damage_lower += 5 * tier
		H.melee_damage_upper += 5 * tier
		H.move_to_delay = max(1, H.move_to_delay - (2 * tier))

/datum/mob_affix/berserker/on_remove(mob/living/M)
	if(istype(M, /mob/living/carbon/simple_animal/hostile))
		var/mob/living/carbon/simple_animal/hostile/H = M
		H.melee_damage_lower -= 5
		H.melee_damage_upper -= 5
		H.move_to_delay += 2

/datum/mob_affix/regenerative
	name = "Regenerative"
	description = "Slowly heals over time."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 12
	color = "#44ff44"
	stat_mods = list(MA_STAT_CON = 3)
	forbidden_affixes = list(/datum/mob_affix/toxic, /datum/mob_affix/diseased)

/datum/mob_affix/regenerative/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	parent_mob.adjustBruteLoss(-3)
	parent_mob.adjustFireLoss(-2)

/datum/mob_affix/radioactive
	name = "Radioactive"
	description = "Pulses toxin and clone damage to nearby enemies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 8
	color = "#88ff00"
	forbidden_affixes = list(/datum/mob_affix/fiery, /datum/mob_affix/toxic)
	process_interval = 4 SECONDS

/datum/mob_affix/radioactive/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(3, parent_mob))
		if(L == parent_mob)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		L.adjustToxLoss(5)
		if(prob(20))
			L.adjustCloneLoss(1)

/datum/mob_affix/explosive
	name = "Explosive"
	description = "Detonates on death."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 8
	color = "#ff8800"
	forbidden_affixes = list(/datum/mob_affix/fiery)

/datum/mob_affix/explosive/on_death(mob/living/M)
	explosion(M.loc, 0, 1, 2, 0, TRUE, FALSE, 0, FALSE, TRUE, 'sound/misc/explode/bomb.ogg')

/datum/mob_affix/venomous
	name = "Venomous"
	description = "Poisons nearby living things."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 12
	color = "#00ff88"
	stat_mods = list(MA_STAT_PER = 2)
	forbidden_affixes = list(/datum/mob_affix/toxic)

/datum/mob_affix/venomous/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(2, 0, 0, 4)

/datum/mob_affix/swift
	name = "Swift"
	description = "Moves faster."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 15
	color = "#00ffff"
	stat_mods = list(MA_STAT_SPD = 4)
	forbidden_affixes = list(/datum/mob_affix/clumsy, /datum/mob_affix/giant)

/datum/mob_affix/swift/on_apply(mob/living/M, tier = 1)
	if(istype(M, /mob/living/carbon/simple_animal/hostile))
		var/mob/living/carbon/simple_animal/hostile/H = M
		H.move_to_delay = max(1, H.move_to_delay - tier)

/datum/mob_affix/swift/on_remove(mob/living/M)
	if(istype(M, /mob/living/carbon/simple_animal/hostile))
		var/mob/living/carbon/simple_animal/hostile/H = M
		H.move_to_delay += 1

/datum/mob_affix/armored
	name = "Armored"
	description = "Tough and resilient."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 14
	color = "#8888ff"
	stat_mods = list(MA_STAT_CON = 4, MA_STAT_SPD = -1)
	traits = list(TRAIT_TOUGH_COOKIE)
	forbidden_affixes = list(/datum/mob_affix/weak, /datum/mob_affix/tiny)

/datum/mob_affix/armored/on_apply(mob/living/M, tier = 1)
	M.maxHealth += 20 * tier
	M.health += 20 * tier

/datum/mob_affix/armored/on_remove(mob/living/M)
	M.maxHealth = max(1, M.maxHealth - 20)
	M.health = min(M.health, M.maxHealth)

/datum/mob_affix/weak
	name = "Weak"
	description = "Lesser in every way."
	alignment = AFFIX_ALIGNMENT_GOOD
	weight = 10
	color = "#888888"
	stat_mods = list(MA_STAT_STR = -3, MA_STAT_CON = -3, MA_STAT_SPD = -1)
	forbidden_affixes = list(/datum/mob_affix/berserker, /datum/mob_affix/armored, /datum/mob_affix/giant)

/datum/mob_affix/weak/on_apply(mob/living/M, tier = 1)
	M.maxHealth = max(1, M.maxHealth - 15 * tier)
	M.health = min(M.health, M.maxHealth)

/datum/mob_affix/weak/on_remove(mob/living/M)
	M.maxHealth += 15

/datum/mob_affix/fiery
	name = "Fiery"
	description = "Burns nearby enemies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 10
	color = "#ff4400"
	forbidden_affixes = list(/datum/mob_affix/frostbound, /datum/mob_affix/radioactive, /datum/mob_affix/explosive)

/datum/mob_affix/fiery/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(2, 0, 4, 0)

/datum/mob_affix/frostbound
	name = "Frostbound"
	description = "Chills and bruises nearby enemies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 9
	color = "#00aaff"
	forbidden_affixes = list(/datum/mob_affix/fiery, /datum/mob_affix/shocking)
	process_interval = 4 SECONDS

/datum/mob_affix/frostbound/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(2, 3, -2, 0)

/datum/mob_affix/shocking
	name = "Shocking"
	description = "Zaps nearby enemies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 9
	color = "#ffff00"
	forbidden_affixes = list(/datum/mob_affix/fiery, /datum/mob_affix/frostbound)

/datum/mob_affix/shocking/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(2, parent_mob))
		if(L == parent_mob)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		L.electrocute_act(5, parent_mob)

/datum/mob_affix/cursed
	name = "Cursed"
	description = "Harbors unholy energies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 8
	color = "#aa00ff"
	stat_mods = list(MA_STAT_WIL = 3, MA_STAT_INT = -1)
	traits = list(TRAIT_ANTIMAGIC)
	forbidden_affixes = list(/datum/mob_affix/blessed, /datum/mob_affix/regenerative)

/datum/mob_affix/blessed
	name = "Blessed"
	description = "Protected by holy favor."
	alignment = AFFIX_ALIGNMENT_GOOD
	weight = 7
	color = "#ffff88"
	stat_mods = list(MA_STAT_WIL = 3, MA_STAT_CON = 2)
	traits = list(TRAIT_BLOOD_RESISTANCE)
	forbidden_affixes = list(/datum/mob_affix/cursed, /datum/mob_affix/undying)

/datum/mob_affix/giant
	name = "Giant"
	description = "Bigger, stronger, but slower."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 10
	color = "#ffaa00"
	stat_mods = list(MA_STAT_STR = 5, MA_STAT_CON = 4, MA_STAT_SPD = -2)
	forbidden_affixes = list(/datum/mob_affix/tiny, /datum/mob_affix/swift, /datum/mob_affix/weak)

/datum/mob_affix/giant/on_apply(mob/living/M, tier = 1)
	M.maxHealth += 30 * tier
	M.health += 30 * tier
	M.transform = M.transform.Scale(1.2 * tier)

/datum/mob_affix/giant/on_remove(mob/living/M)
	M.maxHealth = max(1, M.maxHealth - 30)
	M.health = min(M.health, M.maxHealth)
	M.transform = M.transform.Scale(1 / 1.2)

/datum/mob_affix/tiny
	name = "Tiny"
	description = "Smaller, faster, but fragile."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 8
	color = "#aaffaa"
	stat_mods = list(MA_STAT_SPD = 4, MA_STAT_CON = -3, MA_STAT_STR = -2)
	forbidden_affixes = list(/datum/mob_affix/giant, /datum/mob_affix/armored)

/datum/mob_affix/tiny/on_apply(mob/living/M, tier = 1)
	M.maxHealth = max(1, M.maxHealth - 15 * tier)
	M.health = min(M.health, M.maxHealth)
	M.transform = M.transform.Scale(1 / (1.2 * tier))

/datum/mob_affix/tiny/on_remove(mob/living/M)
	M.maxHealth += 15
	M.transform = M.transform.Scale(1.2)

/datum/mob_affix/vampiric
	name = "Vampiric"
	description = "Drains life from nearby enemies to heal."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 10
	color = "#aa0000"
	forbidden_affixes = list(/datum/mob_affix/undying, /datum/mob_affix/regenerative)
	process_interval = 4 SECONDS

/datum/mob_affix/vampiric/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	leech_nearby(2, 4, 4)

/datum/mob_affix/reflective
	name = "Reflective"
	description = "Hurts those who strike it with a magical pulse."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 9
	color = "#00aaaa"
	stat_mods = list(MA_STAT_WIL = 2, MA_STAT_CON = 2)
	forbidden_affixes = list(/datum/mob_affix/undying)
	process_interval = 4 SECONDS

/datum/mob_affix/reflective/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	leech_nearby(2, 3, 0)

/datum/mob_affix/toxic
	name = "Toxic"
	description = "Spreads toxin to nearby enemies."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 11
	color = "#44aa00"
	forbidden_affixes = list(/datum/mob_affix/venomous, /datum/mob_affix/regenerative)

/datum/mob_affix/toxic/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(3, 0, 0, 4)

/datum/mob_affix/undying
	name = "Undying"
	description = "Refuses to die easily."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 6
	color = "#444444"
	stat_mods = list(MA_STAT_CON = 5, MA_STAT_WIL = 3)
	traits = list(TRAIT_DEATHBARGAIN)
	forbidden_affixes = list(/datum/mob_affix/vampiric, /datum/mob_affix/blessed)

/datum/mob_affix/undying/on_apply(mob/living/M, tier = 1)
	M.maxHealth += 40 * tier
	M.health += 40 * tier

/datum/mob_affix/undying/on_remove(mob/living/M)
	M.maxHealth = max(1, M.maxHealth - 40)
	M.health = min(M.health, M.maxHealth)

/datum/mob_affix/frenzied
	name = "Frenzied"
	description = "Attacks wildly and quickly."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 11
	color = "#ff0088"
	stat_mods = list(MA_STAT_SPD = 3, MA_STAT_STR = 2, MA_STAT_WIL = -2)
	traits = list(TRAIT_RAGE)
	forbidden_affixes = list(/datum/mob_affix/steadfast, /datum/mob_affix/berserker)

/datum/mob_affix/steadfast
	name = "Steadfast"
	description = "Resilient against harm."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 9
	color = "#888800"
	stat_mods = list(MA_STAT_CON = 3, MA_STAT_WIL = 2)
	traits = list(TRAIT_TOUGH_COOKIE, TRAIT_CRITICAL_RESISTANCE)
	forbidden_affixes = list(/datum/mob_affix/berserker, /datum/mob_affix/frenzied)

/datum/mob_affix/keen
	name = "Keen"
	description = "Accurate and perceptive."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 10
	color = "#00ffaa"
	stat_mods = list(MA_STAT_PER = 4, MA_STAT_INT = 2)
	forbidden_affixes = list(/datum/mob_affix/clumsy)

/datum/mob_affix/clumsy
	name = "Clumsy"
	description = "Slow and inaccurate."
	alignment = AFFIX_ALIGNMENT_GOOD
	weight = 8
	color = "#aaaaaa"
	stat_mods = list(MA_STAT_SPD = -2, MA_STAT_PER = -2, MA_STAT_INT = -1)
	forbidden_affixes = list(/datum/mob_affix/keen, /datum/mob_affix/swift, /datum/mob_affix/berserker)

/datum/mob_affix/invisible
	name = "Invisible"
	description = "Hard to see until it attacks."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 6
	color = "#aaddff"
	forbidden_affixes = list(/datum/mob_affix/giant)

/datum/mob_affix/invisible/on_apply(mob/living/M, tier = 1)
	M.alpha = 80
	ADD_TRAIT(M, TRAIT_ANTISCRYING, TRAIT_GENERIC)

/datum/mob_affix/invisible/on_remove(mob/living/M)
	M.alpha = 255
	REMOVE_TRAIT(M, TRAIT_ANTISCRYING, TRAIT_GENERIC)

/datum/mob_affix/lucky
	name = "Lucky"
	description = "Fortune smiles upon this one."
	alignment = AFFIX_ALIGNMENT_GOOD
	weight = 7
	color = "#ffff44"
	stat_mods = list(MA_STAT_LUC = 5)
	forbidden_affixes = list(/datum/mob_affix/unlucky)

/datum/mob_affix/unlucky
	name = "Unlucky"
	description = "Misfortune follows it."
	alignment = AFFIX_ALIGNMENT_NEUTRAL
	weight = 6
	color = "#888844"
	stat_mods = list(MA_STAT_LUC = -5)
	forbidden_affixes = list(/datum/mob_affix/lucky)

/datum/mob_affix/wild
	name = "Wild"
	description = "Unpredictable and aggressive."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 12
	color = "#ff44aa"
	stat_mods = list(MA_STAT_STR = 2, MA_STAT_SPD = 2, MA_STAT_INT = -2)
	traits = list(TRAIT_NOSLEEP)

/datum/mob_affix/diseased
	name = "Diseased"
	description = "Spreads sickness."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 9
	color = "#66aa00"
	forbidden_affixes = list(/datum/mob_affix/regenerative, /datum/mob_affix/blessed)
	process_interval = 5 SECONDS

/datum/mob_affix/diseased/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(2, 0, 0, 3)

/datum/mob_affix/feral
	name = "Feral"
	description = "A savage beast with sharp instincts."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 11
	color = "#aa4400"
	stat_mods = list(MA_STAT_STR = 3, MA_STAT_PER = 2, MA_STAT_INT = -3)
	traits = list(TRAIT_WILD_EATER)
	forbidden_affixes = list(/datum/mob_affix/clumsy)

/datum/mob_affix/eldritch
	name = "Eldritch"
	description = "Touched by otherworldly powers."
	alignment = AFFIX_ALIGNMENT_EVIL
	weight = 5
	color = "#aa00cc"
	stat_mods = list(MA_STAT_INT = 4, MA_STAT_WIL = 4, MA_STAT_CON = -2)
	traits = list(TRAIT_NIGHT_OWL, TRAIT_ANTIMAGIC)
