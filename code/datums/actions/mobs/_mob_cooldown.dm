// Shared lightweight mob cooldown system for any kind of mob abilities to enforce a shared cooldown
/datum/action/cooldown/mob_cooldown
	shared_cooldown = "mob_special"
	click_to_activate = TRUE
	retrigger_after_cooldown = FALSE
	use_chance = 100
	lockout_time = 5 SECONDS
	var/blocked_by_exposure = TRUE

/datum/action/cooldown/mob_cooldown/InterceptClickOn(mob/living/clicker, list/modifiers, atom/target)
	if(!isnull(modifiers))
		return ..()
	if(QDELETED(target))
		return FALSE
	return PreActivate(target)

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
	return TRUE

/datum/action/cooldown/mob_cooldown/Activate(atom/target)
	if(!can_use(target))
		return FALSE
	StartCooldown()
	return use_special(target)

/datum/action/cooldown/mob_cooldown/proc/use_special(atom/target)
	return TRUE
