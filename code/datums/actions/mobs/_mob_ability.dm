/datum/action/cooldown/spell/telegraphed_strike/mob_ability
	abstract_type = /datum/action/cooldown/spell/telegraphed_strike/mob_ability
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "explosion"
	panel = null
	use_chance = 100
	click_to_activate = TRUE
	retrigger_after_cooldown = FALSE
	shared_cooldown = "mob_special"
	lockout_time = 5 SECONDS
	self_cast_possible = TRUE
	invocation_type = INVOCATION_NONE
	sound = null
	primary_resource_type = SPELL_COST_NONE
	spell_requirements = SPELL_REQUIRES_SAME_Z
	associated_stat = null
	has_visual_effects = FALSE
	blocked_by_antimagic = FALSE
	spare_allies = TRUE
	require_target_in_pattern = TRUE
	freeze_cast = TRUE
	track_target = TRUE
	damage_structures = FALSE

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/can_strike_victim(mob/living/H, mob/living/L)
	if(L.stat == DEAD)
		return FALSE
	if(spare_allies && H.faction_check_mob(L))
		return FALSE
	return TRUE

/// Blast anchored on a turf picked at cast time, rather than a pattern swept from the caster.
/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground
	abstract_type = /datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground
	lock_direction = FALSE
	sweep_step = 0
	require_target_in_pattern = FALSE // anchored on the quarry's turf, so it is always in the pattern
	var/blast_radius = 1
	var/turf/locked_turf

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/cast(atom/cast_on)
	locked_turf = get_turf(cast_on)
	if(!locked_turf)
		return FALSE
	return ..()

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/get_pattern_origin(mob/living/H)
	return locked_turf || ..()

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/get_pattern_offsets()
	. = list()
	for(var/x in -blast_radius to blast_radius)
		for(var/y in -blast_radius to blast_radius)
			. += list(list(x, y))

/datum/action/cooldown/spell/telegraphed_strike/mob_ability/ground/get_sweep_bands()
	return list(get_pattern_offsets())
