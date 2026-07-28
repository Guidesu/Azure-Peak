// Ported from Vanderlin (OpenKeep): code/datums/rts/attacking_strategy/_base.dm
//
// PHASE 6 (Combat layer). /datum/worker_attack_strategy: per-worker target
// acquisition/engagement, held on work_mind.dm's new attack_mode var (see
// that file's Phase 6 un-defer notes). This is the last file of the whole
// RTS port - see this repo's rts/ folder for the four prior phases.
//
// COMPATIBILITY CHECK (done before porting this file, per the plan's
// explicit request to verify proc names rather than assume the earlier
// compatibility pass was exhaustive):
//   - /mob/living/simple_animal/hostile/proc/AttackingTarget() (hostile.dm)
//     EXISTS but with a different signature than Vanderlin expects: it takes
//     NO arguments and reads its own `target`/`targets_from` vars instead of
//     an explicit target parameter. Vanderlin's source calls
//     `worker.AttackingTarget(current_target)`. ADAPTATION: can_attack_target()
//     below sets `worker.target = current_target` (and `targets_from` if the
//     mob doesn't already have one set) immediately before calling
//     `worker.AttackingTarget()` with no arguments, so the melee swing lands
//     on our chosen target through the hostile mob's own existing attack
//     path. This is safe because this port's worker_type default
//     (/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite, see
//     controller_mob.dm) is itself a /mob/living/simple_animal/hostile
//     subtype, so `target`/`targets_from`/AttackingTarget() all resolve.
//     Any future worker_type swapped in that ISN'T a simple_animal/hostile
//     subtype won't have AttackingTarget() at all - can_attack_target() below
//     guards this with istype() and just skips the melee swing (still counts
//     as "engaged" for chase-timer/patience purposes) rather than runtime.
//   - Ranged path (fire_projectile()): CONFIRMED 1:1 compatible. This repo's
//     /obj/projectile/proc/preparePixelProjectile(atom/target, atom/source,
//     params, spread) (code/modules/projectiles/projectile.dm) and
//     /obj/projectile/proc/fire(angle, direct_target) (same file) match
//     Vanderlin's expected calls exactly - confirmed against this repo's own
//     /mob/living/simple_animal/hostile/proc/Shoot() (hostile.dm), which
//     builds and fires a projectile with the identical
//     starting/firer/fired_from/yo/xo/original/preparePixelProjectile/fire()
//     sequence used below. No adaptation needed for fire_projectile().
//   - npc_detect_sneak(mob/living/target, extra_prob) EXISTS on /mob/living
//     (code/modules/mob/living/carbon/human/npc/_npc.dm:10) - not
//     human-specific despite living in a human/npc/ file, it's declared on
//     the /mob/living base type, so worker.npc_detect_sneak() resolves fine
//     for any worker_type. No adaptation needed.
//   - rogue_sneaking (living_defines.dm:200) and alpha both exist on
//     /mob/living as expected. No adaptation needed.
//   - mob.health and mob.stat: health is declared on living_defines.dm;
//     stat is the BYOND builtin /mob/stat var (DEAD/CONSCIOUS/UNCONSCIOUS
//     constants, code/__DEFINES/status_effects.dm & friends) - both resolve
//     with the exact semantics Vanderlin expects (stat >= DEAD for death
//     checks). No adaptation needed.
//   - status_flags & GODMODE: GODMODE is defined in code/__DEFINES/combat.dm.
//     No adaptation needed.
//   - hearers()/oview()/typecache_filter_list()/can_see()/get_dist()/pick():
//     all standard BYOND/this-repo global procs (__HELPERS), confirmed
//     present with matching signatures. No adaptation needed.
//   - worker.controller_mind.master and worker.controller_mind.stop_chase()/
//     apply_attack_strategy(): both already exist on work_mind.dm (master
//     since Phase 1; stop_chase()/apply_attack_strategy() added this phase,
//     see that file). emote("aggro") resolves via the generic
//     /mob/proc/emote() (code/modules/mob/emote.dm) - confirmed the "aggro"
//     act string is handled broadly across this repo's simple_animal mobs,
//     including the fae/sprite default worker_type.
//
// Everything else below is a direct, unmodified port of the source's target-
// acquisition (list_targets/find_targets/pick_target), engagement (give_target/
// reset_patience/lose_target), can_attack()/can_attack_target(), ranged firing,
// and threat assessment/call_for_backup() logic.
/datum/worker_attack_strategy
	var/search_objects = FALSE

	var/mob/living/current_target
	var/vision_range = 8
	var/mob/living/worker
	var/simple_detect_bonus = 0

	var/end_current_chase_id
	var/chase_timer = 30 SECONDS

	var/attack_range = 1
	var/obj/projectile/spawning_projectile

/datum/worker_attack_strategy/New(mob/living/incoming_worker)
	. = ..()
	if(!incoming_worker)
		return INITIALIZE_HINT_QDEL
	worker = incoming_worker

/datum/worker_attack_strategy/Destroy(force)
	deltimer(end_current_chase_id)
	current_target = null
	worker = null
	return ..()

/datum/worker_attack_strategy/proc/list_targets()
	if(!search_objects)
		. = hearers(vision_range, worker) - worker //Remove self, so we don't suicide

		var/static/hostile_machines = typecacheof(list())

		for(var/HM in typecache_filter_list(range(vision_range, worker), list()))
			if(can_see(worker, HM, vision_range))
				. += HM
	else
		. = oview(vision_range, worker)

/datum/worker_attack_strategy/proc/find_targets(list/targets = list())
	. = list()
	if(!length(targets))
		targets = list_targets()

	for(var/atom/target in targets)
		if(on_target_selection(target))
			. = list(target)
			break
		if(can_attack(target))
			. += target
			continue
	var/atom/picked_target = pick_target(.)
	if(picked_target)
		give_target(picked_target)
	return picked_target

/datum/worker_attack_strategy/proc/on_target_selection(mob/living/target)
	if(!isliving(target))
		return
	if(target.alpha == 0 && target.rogue_sneaking)
		return worker.npc_detect_sneak(target, simple_detect_bonus)

/datum/worker_attack_strategy/proc/pick_target(list/possible_targets)
	if(current_target)
		var/target_dist = get_dist(worker, current_target)
		for(var/atom/target in possible_targets)
			var/possible_target_distance = get_dist(worker, target)
			if(target_dist < possible_target_distance)
				possible_targets -= target
	if(!length(possible_targets))
		return
	var/chosen_target = pick(possible_targets)
	return chosen_target

/datum/worker_attack_strategy/proc/reset_patience()
	deltimer(end_current_chase_id)
	end_current_chase_id = addtimer(CALLBACK(src, PROC_REF(lose_target)), chase_timer, TIMER_STOPPABLE)

/datum/worker_attack_strategy/proc/give_target(atom/new_target)
	current_target = new_target
	if(current_target)
		reset_patience()
		worker.emote("aggro")
		return TRUE
	deltimer(end_current_chase_id)

/datum/worker_attack_strategy/proc/lose_target()
	current_target = null
	worker.controller_mind.stop_chase()
	deltimer(end_current_chase_id)

/datum/worker_attack_strategy/proc/can_attack(mob/living/possible_target)
	if(!isliving(possible_target))
		return FALSE

	if(possible_target.controller_mind)
		if(possible_target.controller_mind.master != worker.controller_mind.master)
			return TRUE

	if(possible_target.status_flags & GODMODE)
		return FALSE

	if(worker.see_invisible < possible_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	return TRUE

// ADAPTATION (see this file's header comment): the melee branch below sets
// worker.target/targets_from and calls worker.AttackingTarget() with no
// arguments, instead of Vanderlin's worker.AttackingTarget(current_target) -
// this repo's AttackingTarget() (only declared on
// /mob/living/simple_animal/hostile) takes no target parameter and swings at
// whatever its own `target` var already points to. Guarded with
// hascall()/istype() so a non-hostile worker_type just skips the swing
// instead of runtiming on a missing proc.
/datum/worker_attack_strategy/proc/can_attack_target()
	var/distance = get_dist(worker, current_target)
	if(distance > attack_range)
		return FALSE

	if(current_target.stat >= DEAD)
		lose_target()
		return FALSE

	if(assess_threat_level() > 3)
		call_for_backup()

	reset_patience()
	if(!spawning_projectile)
		if(istype(worker, /mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/hostile_worker = worker
			hostile_worker.target = current_target
			if(!hostile_worker.targets_from)
				hostile_worker.targets_from = hostile_worker
			hostile_worker.AttackingTarget()
	else
		fire_projectile()
	after_attack()
	return TRUE

/datum/worker_attack_strategy/proc/fire_projectile()
	if( QDELETED(current_target) || current_target == worker.loc || current_target == worker )
		return
	var/turf/startloc = get_turf(worker)
	var/obj/projectile/P = new spawning_projectile(startloc)
	P.starting = startloc
	P.firer = worker
	P.fired_from = worker
	P.yo = current_target.y - startloc.y
	P.xo = current_target.x - startloc.x
	P.original = current_target
	P.preparePixelProjectile(current_target, src)
	P.fire()
	return P

/datum/worker_attack_strategy/proc/after_attack()
	return

/datum/worker_attack_strategy/proc/assess_threat_level()
	if(!current_target)
		return 0

	var/threat = 1
	if(isliving(current_target))
		var/mob/living/L = current_target
		threat = L.health / 10 // Basic threat assessment

	return threat

/datum/worker_attack_strategy/proc/call_for_backup()
	// Alert nearby workers if facing strong enemy
	var/threat = assess_threat_level()
	if(threat > 5)
		for(var/mob/living/ally in view(8, worker))
			if(ally.controller_mind && ally.controller_mind.master == worker.controller_mind.master)
				ally.controller_mind.apply_attack_strategy(/datum/worker_attack_strategy)
				ally.controller_mind.attack_mode.give_target(current_target)
				ally.visible_message("[ally] rushes to help [worker]!")
