// ═══════════════════════════════════════════════════════════════════
// FAITH FLOW SYSTEM — Devotion momentum for miracle casters
//
// Reuses the bending_flow infrastructure but with patron-based tracking.
// Each miracle cast builds Faith Flow stacks. Flow decays if you stop
// casting miracles. At high Flow, miracles get empowered.
//
// Flow tiers (same as bending flow):
//   0-2: No bonus
//   3-5: +15% damage/healing, -10% cost (Devoted)
//   6-8: +30% damage/healing, -20% cost (Blessed)
//   9+:  +50% damage/healing, -30% cost (Anointed)
//
// Flow is lost on: knockdown, stun, 8s of no miracles, switching patron.
// ═══════════════════════════════════════════════════════════════════

// Patron identifiers for flow tracking (reuse BENDING_ELEMENT_* as base,
// but add patron-specific ones for the faith system)
#define FAITH_PATRON_AUXENTIUS "faith_auxentius"
#define FAITH_PATRON_ABYSSOR "faith_abyssor"
#define FAITH_PATRON_MALUM "faith_malum"
#define FAITH_PATRON_NECRA "faith_necra"
#define FAITH_PATRON_NOC "faith_noc"
#define FAITH_PATRON_DENDOR "faith_dendor"
#define FAITH_PATRON_EORA "faith_eora"
#define FAITH_PATRON_PESTRA "faith_pestra"
#define FAITH_PATRON_XYLIX "faith_xylix"
#define FAITH_PATRON_UNDIVIDED "faith_undivided"
#define FAITH_PATRON_GENERIC "faith_generic"

// Map patron type paths to flow identifiers and glow colors
GLOBAL_LIST_INIT(faith_patron_map, list(
	/datum/patron/concordat/auxentius = list(FAITH_PATRON_AUXENTIUS, GLOW_COLOR_AUXENTIUS_SUN),
	/datum/patron/concordat/wulfric = list(FAITH_PATRON_ABYSSOR, GLOW_COLOR_ICE),
	/datum/patron/concordat/handwerra = list(FAITH_PATRON_MALUM, GLOW_COLOR_MALUM),
	/datum/patron/concordat/morwenna = list(FAITH_PATRON_NECRA, GLOW_COLOR_DISPLACEMENT),
	/datum/patron/concordat/miluse = list(FAITH_PATRON_NOC, GLOW_COLOR_NOC),
	/datum/patron/concordat/viator = list(FAITH_PATRON_DENDOR, GLOW_COLOR_EARTHEN),
	/datum/patron/severance/ignatius = list(FAITH_PATRON_DENDOR, GLOW_COLOR_EARTHEN),
	/datum/patron/tribunal/custodius = list(FAITH_PATRON_UNDIVIDED, GLOW_COLOR_UNDIVIDED),
	/datum/patron/tribunal/praecursor = list(FAITH_PATRON_UNDIVIDED, GLOW_COLOR_UNDIVIDED),
	/datum/patron/oldkin/hausvette = list(FAITH_PATRON_PESTRA, GLOW_COLOR_VAMPIRIC),
	/datum/patron/oldkin/volkovoi = list(FAITH_PATRON_PESTRA, GLOW_COLOR_VAMPIRIC),
	/datum/patron/unveiled/aurelian = list(FAITH_PATRON_NECRA, GLOW_COLOR_DISPLACEMENT),
))

/// Get the faith flow identifier and glow color for a mob based on their patron
/proc/get_faith_patron_info(mob/living/L)
	if(!istype(L) || !ishuman(L))
		return list(FAITH_PATRON_GENERIC, GLOW_COLOR_WARD)
	var/mob/living/carbon/human/H = L
	if(!H.patron)
		return list(FAITH_PATRON_GENERIC, GLOW_COLOR_WARD)
	var/patron_type = H.patron.type
	for(var/key in GLOB.faith_patron_map)
		if(ispath(patron_type, key))
			return GLOB.faith_patron_map[key]
	// Fallback: use patron name for color
	return list(FAITH_PATRON_GENERIC, GLOW_COLOR_WARD)

/// Add faith flow to a mob from a miracle cast. Returns stacks gained.
/proc/add_faith_flow(mob/living/L, amount = 1)
	if(!istype(L))
		return 0
	var/list/info = get_faith_patron_info(L)
	var/patron_id = info[1]
	return add_bending_flow(L, patron_id, amount)

/// Get the faith flow damage multiplier for a mob (1.0 if no flow)
/proc/get_faith_flow_damage_mult(mob/living/L)
	return get_bending_flow_damage_mult(L)

/// Get the faith flow healing multiplier for a mob (1.0 if no flow)
/proc/get_faith_flow_heal_mult(mob/living/L)
	return get_bending_flow_damage_mult(L) // Same multiplier applies to healing

/// Get the faith flow cost multiplier for a mob (1.0 if no flow)
/proc/get_faith_flow_cost_mult(mob/living/L)
	return get_bending_flow_cost_mult(L)

/// Get current faith flow tier for a mob (0-3)
/proc/get_faith_flow_tier(mob/living/L)
	return get_bending_flow_tier(L)

/// Consume faith flow stacks from a mob. Returns amount consumed.
/proc/consume_faith_flow(mob/living/L, amount)
	return consume_bending_flow(L, amount)

// ═══════════════════════════════════════════════════════════════════
// MIRACLE VFX — Procedural visual effects for miracles
//
// Reuses the bending VFX framework but with patron-specific colors.
// Adds divine-themed effects: halo rings, blessing auras, holy impacts.
// ═══════════════════════════════════════════════════════════════════

/// Create a miracle cast burst on a turf (patron-colored)
/proc/create_miracle_cast_burst(turf/T, mob/living/caster)
	if(!T || !caster)
		return
	var/list/info = get_faith_patron_info(caster)
	create_bending_cast_burst(T, info[2])

/// Create a miracle impact ring on a turf (patron-colored)
/proc/create_miracle_impact_ring(turf/T, mob/living/caster, scale = 1.0)
	if(!T || !caster)
		return
	var/list/info = get_faith_patron_info(caster)
	create_bending_impact_ring(T, info[2], scale)

/// Create a miracle healing aura on a target (patron-colored)
/proc/create_miracle_heal_aura(turf/T, mob/living/caster)
	if(!T || !caster)
		return
	var/list/info = get_faith_patron_info(caster)
	var/color = info[2]
	// Use the existing heal temp_visual but with patron color
	new /obj/effect/temp_visual/heal(T, color)
	// Add an expanding ring for extra visual punch
	create_bending_impact_ring(T, color, 0.8)

// ═══════════════════════════════════════════════════════════════════
// HOOKS — Automatic flow + VFX for all miracle spells
//
// These override after_cast() on the base miracle spell types so that
// EVERY miracle spell automatically gets flow gain + VFX without needing
// to edit each individual spell file.
// ═══════════════════════════════════════════════════════════════════

// ─── New-style spells: /datum/action/cooldown/spell/miracle ────────

/// Base miracle type — all generic miracles (heal, fortify, intervention, etc.)
/datum/action/cooldown/spell/miracle/after_cast(atom/cast_on)
	. = ..()
	if(!owner || !isliving(owner))
		return
	var/mob/living/L = owner
	// Add faith flow
	add_faith_flow(L, 1)
	// VFX: cast burst on caster
	create_miracle_cast_burst(get_turf(L), L)
	// VFX: impact ring on target if it's a turf or mob
	if(cast_on && cast_on != L)
		var/turf/T = get_turf(cast_on)
		if(T)
			create_miracle_impact_ring(T, L, 0.8)

/// Auxentius spell base — all Auxentius spells
/datum/action/cooldown/spell/auxentius/after_cast(atom/cast_on)
	. = ..()
	if(!owner || !isliving(owner))
		return
	var/mob/living/L = owner
	add_faith_flow(L, 1)
	create_miracle_cast_burst(get_turf(L), L)
	if(cast_on && cast_on != L)
		var/turf/T = get_turf(cast_on)
		if(T)
			create_miracle_impact_ring(T, L, 0.8)

/// Malum spell base — all Malum spells
/datum/action/cooldown/spell/malum/after_cast(atom/cast_on)
	. = ..()
	if(!owner || !isliving(owner))
		return
	var/mob/living/L = owner
	add_faith_flow(L, 1)
	create_miracle_cast_burst(get_turf(L), L)
	if(cast_on && cast_on != L)
		var/turf/T = get_turf(cast_on)
		if(T)
			create_miracle_impact_ring(T, L, 0.8)

/// Noc spell base — all Noc spells
/datum/action/cooldown/spell/noc/after_cast(atom/cast_on)
	. = ..()
	if(!owner || !isliving(owner))
		return
	var/mob/living/L = owner
	add_faith_flow(L, 1)
	create_miracle_cast_burst(get_turf(L), L)
	if(cast_on && cast_on != L)
		var/turf/T = get_turf(cast_on)
		if(T)
			create_miracle_impact_ring(T, L, 0.8)

/// Projectile spells that use devotion (e.g. Sacred Flame, Moonscorch)
/// These don't inherit from /datum/action/cooldown/spell/miracle, so we
/// hook into the projectile base and check if it's a miracle spell.
/datum/action/cooldown/spell/projectile/after_cast(atom/cast_on)
	. = ..()
	if(!owner || !isliving(owner))
		return
	if(primary_resource_type != SPELL_COST_DEVOTION)
		return
	var/mob/living/L = owner
	add_faith_flow(L, 1)
	create_miracle_cast_burst(get_turf(L), L)
	if(cast_on && cast_on != L)
		var/turf/T = get_turf(cast_on)
		if(T)
			create_miracle_impact_ring(T, L, 0.8)

/// Apply faith flow damage multiplier to projectile miracle spells
/datum/action/cooldown/spell/projectile/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(primary_resource_type == SPELL_COST_DEVOTION && isliving(user))
		var/flow_mult = get_faith_flow_damage_mult(user)
		if(flow_mult != 1.0)
			to_fire.damage = round(to_fire.damage * flow_mult)

// ─── Old-style spells: /obj/effect/proc_holder/spell/invoked ───────
// For old-style invoked spells, we can't override after_cast() on the
// base type because it would affect ALL invoked spells (including
// non-miracle ones like wizard spells). Instead, we check if the caster
// has a patron and devotion in the after_cast() of the base invoked type.

/// Helper proc: check if a spell is a miracle (caster has patron + devotion)
/proc/is_miracle_spell(mob/user)
	if(!user || !ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!H.patron)
		return FALSE
	if(!H.devotion)
		return FALSE
	return TRUE

/// Hook into the base invoked spell's after_cast to add flow + VFX for miracles.
/// We add this as a wrapper that checks if the caster is a miracle caster.
/obj/effect/proc_holder/spell/invoked/after_cast(list/targets, mob/user = usr)
	. = ..()
	if(!is_miracle_spell(user))
		return
	var/mob/living/L = user
	if(!isliving(L))
		return
	// Add faith flow
	add_faith_flow(L, 1)
	// VFX: cast burst on caster
	create_miracle_cast_burst(get_turf(L), L)
	// VFX: impact ring on first target
	if(length(targets))
		var/atom/T = targets[1]
		if(T && T != L)
			var/turf/target_turf = get_turf(T)
			if(target_turf)
				create_miracle_impact_ring(target_turf, L, 0.8)
