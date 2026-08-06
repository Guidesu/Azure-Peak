// Shared lightweight mob cooldown system for any kind of mob abilities to enforce a shared cooldown
/datum/action/cooldown/mob_cooldown
	shared_cooldown = "mob_special"
	var/lockout_time = 5 SECONDS
	var/min_range = 0
	var/max_range = 1
	var/requires_los = TRUE
	var/blocked_by_exposure = TRUE
	var/use_chance = 100
	var/list/required_zones

/datum/action/cooldown/mob_cooldown/IsAvailable()
	if(!..())
		return FALSE
	var/mob/living/user = owner
	if(!isliving(user))
		return FALSE
	if(user.stat != CONSCIOUS || user.incapacitated())
		return FALSE
	if(blocked_by_exposure && user.has_status_effect(/datum/status_effect/debuff/exposed))
		return FALSE
	return !crippled()

/datum/action/cooldown/mob_cooldown/proc/crippled()
	if(!length(required_zones))
		return FALSE
	var/mob/living/simple_animal/beast = owner
	if(!istype(beast) || !length(beast.broken_parts))
		return FALSE
	for(var/zone in required_zones)
		if(zone in beast.broken_parts)
			return TRUE
	return FALSE

/datum/action/cooldown/mob_cooldown/StartCooldown(override_cooldown_time)
	if(owner && shared_cooldown && lockout_time)
		for(var/datum/action/cooldown/mob_cooldown/other in (owner.actions - src))
			if(other.shared_cooldown != shared_cooldown)
				continue
			if(other.next_use_time >= world.time + lockout_time)
				continue
			other.StartCooldownSelf(lockout_time)
	StartCooldownSelf(override_cooldown_time)

/datum/action/cooldown/mob_cooldown/proc/can_use(atom/target)
	if(QDELETED(target) || target == owner)
		return FALSE
	var/dist = get_dist(owner, target)
	if(dist < min_range || dist > max_range)
		return FALSE
	if(requires_los && !can_see(owner, target, max_range))
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/proc/npc_use_chance(atom/target)
	return use_chance

/datum/action/cooldown/mob_cooldown/Activate(atom/target)
	if(!can_use(target))
		return FALSE
	StartCooldown()
	return use_special(target)

/datum/action/cooldown/mob_cooldown/proc/use_special(atom/target)
	return TRUE
