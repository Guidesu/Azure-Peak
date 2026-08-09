/datum/action/cooldown/spell/telegraphed_strike/dragons_breath/drakkyn
	name = "Dragon's Breath"
	desc = "Exhale a cone of flame."
	panel = null
	cooldown_time = 25 SECONDS
	npc_min_range = 0
	npc_max_range = 4
	use_chance = 45
	required_zones = list(BODY_ZONE_PRECISE_MOUTH)
	shared_cooldown = "mob_special"
	lockout_time = 5 SECONDS

	invocations = list()
	invocation_type = INVOCATION_NONE
	sound = null
	primary_resource_type = SPELL_COST_NONE
	spell_requirements = SPELL_REQUIRES_SAME_Z
	associated_stat = null
	has_visual_effects = FALSE
	glow_intensity = 0
	spell_impact_intensity = SPELL_IMPACT_NONE
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	blocked_by_antimagic = FALSE
	spare_allies = TRUE
	freeze_cast = TRUE
	track_target = TRUE
	damage_structures = FALSE

	telegraph_type = /obj/effect/temp_visual/trap/primordial/fire
	telegraph_message = "draws a deep breath, throat glowing red!"
	telegraph_sound = list('sound/magic/fireball.ogg')
	cast_effect_x_offset = 32
	cast_effect_y_offset = 32

	damage = 55
	push_dist = 0
	detonate_sound = list('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg')
	hit_sound = list('sound/items/firelight.ogg')

/datum/action/cooldown/spell/telegraphed_strike/dragons_breath/drakkyn/greater
	cooldown_time = 20 SECONDS
	damage = 60
	cone_range = 5
	npc_max_range = 5
	scorch_stacks = 2

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball
	name = "Fireball"
	desc = "Hurl a bolt of fire at a distant foe."
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	button_icon_state = "fireball"
	cooldown_time = 20 SECONDS
	npc_min_range = 4
	npc_max_range = 9

	telegraph_time = TELEGRAPH_HIGH_IMPACT
	telegraph_type = /obj/effect/temp_visual/trap/primordial/fire
	telegraph_message = "gathers a knot of fire!"
	telegraph_sound = 'sound/magic/fireball.ogg'
	whiff_message = "loses its mark."

	projectile_type = /obj/projectile/magic/aoe/fireball/rogue
	fire_sound = 'sound/magic/fireball.ogg'
	var/damage_mult = 1

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/ready_projectile(obj/projectile/P, atom/target)
	if(damage_mult == 1)
		return
	P.damage *= damage_mult
	var/obj/projectile/magic/aoe/fireball/rogue/bolt = P
	if(istype(bolt))
		bolt.arcyne_aoe_damage *= damage_mult

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/drakkyn
	name = "Drakkyn Fireball"
	use_chance = 15
	required_zones = list(BODY_ZONE_PRECISE_MOUTH)
	telegraph_message = "rears back, fire gathering behinds its teeth!"
	overhead_y_offset = 64
	overhead_x_offset = 32
	whiff_message = "closes its mouth, smoke billowing out."

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/drakkyn/greater
	cooldown_time = 15 SECONDS
	damage_mult = 1.5

/datum/action/cooldown/mob_cooldown/telegraphed/ranged/fireball/watcher
	name = "Eye of Fire"
	cooldown_time = 8 SECONDS
	npc_min_range = 2
	npc_max_range = 9
	use_chance = 70
	telegraph_message = "fixes its eye, glaring down its foe!"
	whiff_message = "'s eyes shut, the glow dimming."
