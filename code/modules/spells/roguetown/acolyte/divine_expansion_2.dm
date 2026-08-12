// ═══════════════════════════════════════════════════════════════════
// DIVINE EXPANSION II — Additional domain-defining spells for remaining gods
// Uses the /datum/action/cooldown/spell system with devotion costs.
// Each spell is themed to its god's domain and fills gaps in the tier list.
// ═══════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════
// VIATOR — Trade, Travel, Borders, and the Luck of the Road
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/viator_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_BARDIC
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T2 — Roadwarden's Step: Short-range teleport to a visible location
/datum/action/cooldown/spell/viator_expansion/roadwardens_step
	name = "Roadwarden's Step"
	desc = "Steps through the road between places. Teleports you to a visible tile within 7 tiles. The road is always shorter for Viator's faithful."
	fluff_desc = "Every border Viator walked, every road he traveled — he knows the shortcuts that aren't on any map. His faithful learn to step between places as he did."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_BARDIC

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_TELEPORT

	invocation_type = INVOCATION_WHISPER
	invocations = list("the road is short...")
	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/viator_expansion/roadwardens_step/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE
	var/mob/living/caster = owner
	caster.visible_message(span_notice("[caster] steps through a gap in the road and vanishes!"), span_notice("I step through the road between places."))
	playsound(get_turf(caster), 'sound/magic/teleport_diss.ogg', 50, TRUE)
	new /obj/effect/temp_visual/viator_step(get_turf(caster))
	do_teleport(caster, T, no_effects = TRUE)
	playsound(T, 'sound/magic/teleport_diss.ogg', 50, TRUE)
	new /obj/effect/temp_visual/viator_step(T)
	return TRUE

/obj/effect/temp_visual/viator_step
	name = "road step"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

// T3 — Fortune's Favor: Grant a luck buff to a target
/datum/action/cooldown/spell/viator_expansion/fortunes_favor
	name = "Fortune's Favor"
	desc = "Grants a target Viator's luck: +3 LCK for 5 minutes. The road rewards those the Wayward God blesses."
	fluff_desc = "Viator's luck is the luck of the open road — the dice that fall right, the deal that closes fair, the storm that breaks around you. His favor follows the blessed."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_BARDIC

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocation_type = INVOCATION_EMOTE
	invocations = list("invokes the luck of the road.")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/viator_expansion/fortunes_favor/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_status_effect(/datum/status_effect/buff/viator_fortune)
	to_chat(L, span_notice("You feel the luck of the road settle over you. Fortune favors your steps."))
	playsound(get_turf(L), 'sound/magic/bless.ogg', 50, TRUE)
	return TRUE

/datum/status_effect/buff/viator_fortune
	id = "viator_fortune"
	alert_type = /atom/movable/screen/alert/status_effect/buff/viator_fortune
	duration = 5 MINUTES
	effectedstats = list(STATKEY_LCK = 3)

/atom/movable/screen/alert/status_effect/buff/viator_fortune
	name = "Fortune's Favor"
	desc = "Viator's luck guides your steps. +3 Fortune."
	icon_state = "buff"

// ═══════════════════════════════════════════════════════════════════
// WULFRIC — War-as-Protection, Sacrifice, and the Hearth
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/wulfric_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_HEARTH
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T2 — Hearthfire Aura: Buff nearby allies with STR and stamina regen
/datum/action/cooldown/spell/wulfric_expansion/hearthfire_aura
	name = "Hearthfire Aura"
	desc = "Channels the warmth of the hearth into an aura. Allies within 5 tiles gain +2 STR and regenerate stamina faster for 2 minutes."
	fluff_desc = "The hearth is Wulfric's altar — the fire that warms, the fire that protects. His aura carries that warmth into battle, turning allies into hearth-guardians."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_HEARTH

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("THE HEARTHFIRE BURNS IN OUR VEINS!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/wulfric_expansion/hearthfire_aura/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/holycharging.ogg', 80, TRUE)
	for(var/mob/living/carbon/human/H in range(5, center))
		if(H == owner)
			continue
		H.apply_status_effect(/datum/status_effect/buff/wulfric_hearthfire)
		to_chat(H, span_notice("Wulfric's hearthfire burns in your veins!"))
	var/mob/living/caster = owner
	caster.apply_status_effect(/datum/status_effect/buff/wulfric_hearthfire)
	to_chat(caster, span_notice("The hearthfire surges through me!"))
	return TRUE

/datum/status_effect/buff/wulfric_hearthfire
	id = "wulfric_hearthfire"
	alert_type = /atom/movable/screen/alert/status_effect/buff/wulfric_hearthfire
	duration = 2 MINUTES
	effectedstats = list(STATKEY_STR = 2)

/datum/status_effect/buff/wulfric_hearthfire/tick()
	if(HAS_TRAIT(owner, TRAIT_NOREGEN))
		return
	owner.stamina_add(3)

/atom/movable/screen/alert/status_effect/buff/wulfric_hearthfire
	name = "Hearthfire Aura"
	desc = "Wulfric's hearthfire burns in you. +2 Strength and stamina regeneration."
	icon_state = "buff"

// T3 — Sacrificial Strike: Deal damage to yourself to deal massive damage to a target
/datum/action/cooldown/spell/wulfric_expansion/sacrificial_strike
	name = "Sacrificial Strike"
	desc = "Channels Wulfric's sacrifice: you take 20 brute damage, and in return your next melee attack within 10 seconds deals double damage."
	fluff_desc = "Wulfric's war is not conquest — it is sacrifice. The father who bleeds so his children don't, the guard who falls so the gate holds. His faithful learn to pay the same price."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_HEARTH

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_SHOUT
	invocations = list("MY BLOOD FOR THE HEARTH!")
	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/wulfric_expansion/sacrificial_strike/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner
	caster.apply_damage(20, BRUTE)
	caster.apply_status_effect(/datum/status_effect/buff/wulfric_sacrifice)
	caster.visible_message(span_warning("[caster] draws blood from their own palm, eyes blazing with sacrificial fury!"), span_notice("I offer my blood to Wulfric. My next strike shall be devastating!"))
	playsound(get_turf(caster), 'sound/magic/bloodheal.ogg', 60, TRUE)
	return TRUE

/datum/status_effect/buff/wulfric_sacrifice
	id = "wulfric_sacrifice"
	alert_type = /atom/movable/screen/alert/status_effect/buff/wulfric_sacrifice
	duration = 10 SECONDS

/atom/movable/screen/alert/status_effect/buff/wulfric_sacrifice
	name = "Sacrificial Strike"
	desc = "Your next melee attack will deal double damage. Wulfric accepts your sacrifice."
	icon_state = "buff"

// ═══════════════════════════════════════════════════════════════════
// RAVOX — Justice, Glory, Battle
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/ravox_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_RAVOX
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T0 — Warrior's Resolve: Self-buff that grants STR and reduces stamina drain briefly
/datum/action/cooldown/spell/ravox_expansion/warriors_resolve
	name = "Warrior's Resolve"
	desc = "Steels yourself with Ravox's resolve: +2 STR for 1 minute. The justicar's strength flows through you."
	fluff_desc = "Ravox does not grant strength to the cruel — he grants it to those who fight with purpose. His resolve turns a soldier into a champion, a champion into a legend."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_RAVOX

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MINOR
	mana_cost = MANACOST_MIRACLE_MINOR
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_EMOTE
	invocations = list("steels themselves with righteous resolve.")
	charge_required = FALSE
	cooldown_time = 2 MINUTES

/datum/action/cooldown/spell/ravox_expansion/warriors_resolve/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner
	caster.apply_status_effect(/datum/status_effect/buff/ravox_resolve)
	to_chat(caster, span_notice("Ravox's resolve steels my arm!"))
	playsound(get_turf(caster), 'sound/magic/battle_cry.ogg', 50, TRUE)
	return TRUE

/datum/status_effect/buff/ravox_resolve
	id = "ravox_resolve"
	alert_type = /atom/movable/screen/alert/status_effect/buff/ravox_resolve
	duration = 1 MINUTES
	effectedstats = list(STATKEY_STR = 2)

/atom/movable/screen/alert/status_effect/buff/ravox_resolve
	name = "Warrior's Resolve"
	desc = "Ravox's strength flows through you. +2 Strength."
	icon_state = "buff"

// T4 — Glorious Judgment: AOE divine damage centered on caster
/datum/action/cooldown/spell/ravox_expansion/glorious_judgment
	name = "Glorious Judgment"
	desc = "Calls down Ravox's judgment in a 5-tile radius around you. All enemies take 40 brute damage and are knocked down. You are unaffected."
	fluff_desc = "When the battle is at its thickest, when the justicar's patience is spent, Ravox delivers his judgment — not with a whisper, but with a thunderclap that lays the wicked low."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_RAVOX

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("RAVOX! RENDER YOUR GLORIOUS JUDGMENT!")
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/ravox_expansion/glorious_judgment/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/PSY.ogg', 100, TRUE)
	for(var/mob/living/L in range(5, center))
		if(L == owner)
			continue
		L.apply_damage(40, BRUTE)
		L.Knockdown(20)
		L.visible_message(span_warning("[L] is struck down by Ravox's judgment!"), span_danger("Divine judgment crashes down upon you!"))
		new /obj/effect/temp_visual/ravox_judgment(get_turf(L))
	return TRUE

/obj/effect/temp_visual/ravox_judgment
	name = "judgment"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 4 SECONDS
	layer = ABOVE_MOB_LAYER

// ═══════════════════════════════════════════════════════════════════
// MATTHIOS — Exchange, Alchemy, Theft, and Greed
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/matthios_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_MATTHIOS
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T0 — Pilfer's Eye: Reveal the value of all items in a target's inventory
/datum/action/cooldown/spell/matthios_expansion/pilfers_eye
	name = "Pilfer's Eye"
	desc = "Examines a target and reveals the total value of all items they carry. Matthios sees the worth in everything — and everyone."
	fluff_desc = "The Fire-Thief's first lesson: know the value of what you take. Matthios's eye appraises all things, and his faithful see gold where others see only rags."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_MATTHIOS

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MINOR
	mana_cost = MANACOST_MIRACLE_MINOR
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_NONE
	charge_required = FALSE
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/matthios_expansion/pilfers_eye/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	var/total_value = 0
	var/item_count = 0
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		for(var/obj/item/I in H.get_equipped_items() + H.held_items)
			total_value += I.get_real_price()
			item_count++
	to_chat(owner, span_notice("[L] carries [item_count] items worth approximately [total_value] mammon total."))
	playsound(get_turf(owner), 'sound/magic/message.ogg', 30, TRUE)
	return TRUE

// T3 — Shadow Exchange: Swap positions with a target
/datum/action/cooldown/spell/matthios_expansion/shadow_exchange
	name = "Shadow Exchange"
	desc = "Swaps your position with a target's. The ultimate theft — taking their very place in the world."
	fluff_desc = "Matthios stole fire from the sun. His faithful learn a lesser theft: stealing another's place, leaving them where you stood, confused and displaced."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_MATTHIOS

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_TELEPORT

	invocation_type = INVOCATION_WHISPER
	invocations = list("what's yours is mine...")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 2 MINUTES

/datum/action/cooldown/spell/matthios_expansion/shadow_exchange/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	var/turf/caster_turf = get_turf(owner)
	var/turf/target_turf = get_turf(L)
	playsound(caster_turf, 'sound/magic/teleport_diss.ogg', 60, TRUE)
	playsound(target_turf, 'sound/magic/teleport_diss.ogg', 60, TRUE)
	do_teleport(owner, target_turf, no_effects = TRUE)
	do_teleport(L, caster_turf, no_effects = TRUE)
	owner.visible_message(span_warning("[owner] and [L] swap places in the blink of an eye!"), span_notice("I take [L]'s place."))
	to_chat(L, span_danger("You suddenly find yourself somewhere else!"))
	return TRUE

// ═══════════════════════════════════════════════════════════════════
// HAUSVETTE — Harvest, Hearth-Luck, and Community Debt
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/hausvette_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_BAOTHA
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T2 — Harvest Blessing: Bless a target with CON and faster nutrition recovery
/datum/action/cooldown/spell/hausvette_expansion/harvest_blessing
	name = "Harvest Blessing"
	desc = "Blesses a target with the bounty of the harvest: +3 CON and reduced hunger for 5 minutes."
	fluff_desc = "Hausvette's harvest feeds the village through the winter. Her blessing carries that same fullness — the strength of a well-fed body, the endurance of a community that shares."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_BAOTHA

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocation_type = INVOCATION_EMOTE
	invocations = list("invokes the bounty of the harvest.")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/hausvette_expansion/harvest_blessing/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_status_effect(/datum/status_effect/buff/hausvette_harvest)
	to_chat(L, span_notice("Hausvette's harvest blessing fills you with warmth and plenty!"))
	playsound(get_turf(L), 'sound/magic/bless.ogg', 50, TRUE)
	return TRUE

/datum/status_effect/buff/hausvette_harvest
	id = "hausvette_harvest"
	alert_type = /atom/movable/screen/alert/status_effect/buff/hausvette_harvest
	duration = 5 MINUTES
	effectedstats = list(STATKEY_CON = 3)

/atom/movable/screen/alert/status_effect/buff/hausvette_harvest
	name = "Harvest Blessing"
	desc = "Hausvette's bounty sustains you. +3 Constitution and reduced hunger."
	icon_state = "buff"

// T3 — Community's Shield: Grant damage reduction to all nearby allies
/datum/action/cooldown/spell/hausvette_expansion/communitys_shield
	name = "Community's Shield"
	desc = "Channels the strength of community: all allies within 5 tiles gain 25% damage reduction for 30 seconds. The hearth protects its own."
	fluff_desc = "A village survives what a single hut cannot. Hausvette's shield is the shield of neighbors who stand together — the debt of mutual protection made manifest."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_BAOTHA

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("THE HEARTH SHIELDS ITS OWN!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/hausvette_expansion/communitys_shield/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/holyshield.ogg', 80, TRUE)
	for(var/mob/living/carbon/human/H in range(5, center))
		H.apply_status_effect(/datum/status_effect/buff/hausvette_community)
		to_chat(H, span_notice("The community's shield settles over you! Damage reduced!"))
	return TRUE

/datum/status_effect/buff/hausvette_community
	id = "hausvette_community"
	alert_type = /atom/movable/screen/alert/status_effect/buff/hausvette_community
	duration = 30 SECONDS

/datum/status_effect/buff/hausvette_community/on_apply()
	. = ..()
	if(!.)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 0.75
		H.physiology.burn_mod *= 0.75

/datum/status_effect/buff/hausvette_community/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod /= 0.75
		H.physiology.burn_mod /= 0.75

/atom/movable/screen/alert/status_effect/buff/hausvette_community
	name = "Community's Shield"
	desc = "The hearth shields you. Damage reduced by 25%."
	icon_state = "buff"

// ═══════════════════════════════════════════════════════════════════
// VOLKOVOI — Winter, Hunger, and the Cull
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/volkovoi_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_GRAGGAR
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T2 — Winter's Bite: Deal cold damage and slow a target
/datum/action/cooldown/spell/volkovoi_expansion/winters_bite
	name = "Winter's Bite"
	desc = "Bites a target with the cold of winter: deals 30 burn damage (cold) and slows them for 5 seconds."
	fluff_desc = "Volkovoi's winter does not negotiate. It bites, and the bitten grow slow, and the slow are culled. His faithful bring that same winter to the battlefield."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_GRAGGAR

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("WINTER TAKES YOU!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/volkovoi_expansion/winters_bite/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_damage(30, BURN)
	L.apply_status_effect(/datum/status_effect/debuff/volkovoi_winter)
	L.visible_message(span_warning("[L] is struck by biting cold!"), span_danger("Winter's cold bites into your bones!"))
	playsound(get_turf(L), 'sound/magic/fleshtostone.ogg', 60, TRUE)
	return TRUE

/datum/status_effect/debuff/volkovoi_winter
	id = "volkovoi_winter"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/volkovoi_winter
	duration = 5 SECONDS
	effectedstats = list(STATKEY_SPD = -3)

/datum/status_effect/debuff/volkovoi_winter/on_apply()
	. = ..()
	if(!.)
		return
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier("volkovoi_winter", update=TRUE, priority=100, multiplicative_slowdown=2)

/datum/status_effect/debuff/volkovoi_winter/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier("volkovoi_winter")

/atom/movable/screen/alert/status_effect/debuff/volkovoi_winter
	name = "Winter's Bite"
	desc = "Winter's cold slows your limbs. -3 Speed."
	icon_state = "debuff"

// T3 — Hunger's Call: Force a target to become ravenously hungry, draining nutrition
/datum/action/cooldown/spell/volkovoi_expansion/hungers_call
	name = "Hunger's Call"
	desc = "Calls the winter-hunger into a target's belly, draining their nutrition severely. They become weak and desperate."
	fluff_desc = "The cull begins with hunger. Volkovoi's call empties the belly, weakens the limbs, and makes the strong as desperate as the starving. The winter asks its question: who survives?"
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_GRAGGAR

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("HUNGER COMES FOR YOU!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 2 MINUTES

/datum/action/cooldown/spell/volkovoi_expansion/hungers_call/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	// Drain nutrition
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.nutrition = max(0, C.nutrition - 200)
	L.apply_status_effect(/datum/status_effect/debuff/volkovoi_hunger)
	L.visible_message(span_warning("[L] doubles over, gripped by sudden ravenous hunger!"), span_danger("A terrible hunger gnaws at your belly! You feel weak and desperate!"))
	playsound(get_turf(L), 'sound/magic/heartbeat.ogg', 60, TRUE)
	return TRUE

/datum/status_effect/debuff/volkovoi_hunger
	id = "volkovoi_hunger"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/volkovoi_hunger
	duration = 30 SECONDS
	effectedstats = list(STATKEY_STR = -3, STATKEY_CON = -2)

/atom/movable/screen/alert/status_effect/debuff/volkovoi_hunger
	name = "Hunger's Call"
	desc = "Ravenous hunger drains your strength. -3 Strength, -2 Constitution."
	icon_state = "debuff"

// ═══════════════════════════════════════════════════════════════════
// IGNATIUS — Growth, Change, Risk, and Fire
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/ignatius_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T1 — Ember Touch: Ignite a target with a small flame
/datum/action/cooldown/spell/ignatius_expansion/ember_touch
	name = "Ember Touch"
	desc = "Touches a target with Ignatius's ember: deals 15 burn damage and ignites them briefly. The fire that clears old growth."
	fluff_desc = "Ignatius's fire is not destruction — it is renewal. The ember that burns away the deadwood so new growth can take root. But the deadwood feels it all the same."
	button_icon_state = "ignite"
	spell_color = GLOW_COLOR_FIRE

	click_to_activate = TRUE
	cast_range = 2
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MINOR
	mana_cost = MANACOST_MIRACLE_MINOR
	secondary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_EMOTE
	invocations = list("ignites a small ember in their palm.")
	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/ignatius_expansion/ember_touch/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_damage(15, BURN)
	L.adjust_fire_stacks(2)
	L.ignite_mob()
	L.visible_message(span_warning("[L] is struck by a searing ember!"), span_danger("An ember sears your flesh and ignites you!"))
	playsound(get_turf(L), 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

// T3 — Wild Growth: Cause plants to erupt in an area, healing allies and entangling enemies
/datum/action/cooldown/spell/ignatius_expansion/wild_growth
	name = "Wild Growth"
	desc = "Causes wild plants to erupt in a 5-tile radius. Allies are healed for 30 brute. Enemies are entangled and slowed for 5 seconds."
	fluff_desc = "The forest does not ask permission to grow. Ignatius's wild growth surges through the earth, mending his faithful and grasping at those who would harm them."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_FIRE

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("RISE, WILD GROWTH! MEND AND BIND!")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/ignatius_expansion/wild_growth/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/churn.ogg', 80, TRUE)
	for(var/mob/living/L in range(5, center))
		if(L == owner)
			continue
		if(L.patron && (istype(L.patron, /datum/patron/severance/ignatius) || istype(L.patron, /datum/patron/oldkin/trnava)))
			L.adjustBruteLoss(-30)
			to_chat(L, span_notice("Wild growth mends your wounds!"))
		else
			L.apply_status_effect(/datum/status_effect/debuff/ignatius_entangle)
			to_chat(L, span_warning("Vines erupt from the ground and entangle you!"))
		new /obj/effect/temp_visual/ignatius_growth(get_turf(L))
	return TRUE

/datum/status_effect/debuff/ignatius_entangle
	id = "ignatius_entangle"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/ignatius_entangle
	duration = 5 SECONDS

/datum/status_effect/debuff/ignatius_entangle/on_apply()
	. = ..()
	if(!.)
		return
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier("ignatius_entangle", update=TRUE, priority=100, multiplicative_slowdown=3)

/datum/status_effect/debuff/ignatius_entangle/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier("ignatius_entangle")

/atom/movable/screen/alert/status_effect/debuff/ignatius_entangle
	name = "Entangled"
	desc = "Wild vines grip your legs, slowing you drastically."
	icon_state = "debuff"

/obj/effect/temp_visual/ignatius_growth
	name = "wild growth"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 4 SECONDS
	layer = ABOVE_MOB_LAYER

// ═══════════════════════════════════════════════════════════════════
// CUSTODIUS — Enforcement, Oathbinding, and Correction
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/custodius_expansion
	background_icon = 'icons/mob/actions/undividedmiracles.dmi'
	button_icon = 'icons/mob/actions/undividedmiracles.dmi'
	spell_color = GLOW_COLOR_UNDIVIDED
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	required_items = list(/obj/item/clothing/neck/roguetown/psicross/custodius, /obj/item/clothing/neck/roguetown/psicross/silver/custodius)

// T2 — Oathbind: Prevent a target from moving for 3 seconds
/datum/action/cooldown/spell/custodius_expansion/oathbind
	name = "Oathbind"
	desc = "Speaks an oath of binding that roots a target in place for 3 seconds. They cannot move but can still act."
	fluff_desc = "Custodius's oath is not a request — it is a chain. The bound hand does not let go, and those he binds do not walk away until the oath is fulfilled."
	button_icon_state = "calming_respite"
	spell_color = GLOW_COLOR_UNDIVIDED

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("BY CUSTODIUS'S OATH: HOLD!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/custodius_expansion/oathbind/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.Immobilize(30)
	L.visible_message(span_warning("[L] is rooted in place by a glowing oath-chain!"), span_danger("An oath binds your legs — you cannot move!"))
	playsound(get_turf(L), 'sound/magic/holyshield.ogg', 60, TRUE)
	return TRUE

// T3 — Corrective Strike: Deal damage that scales inversely with the target's health
/datum/action/cooldown/spell/custodius_expansion/corrective_strike
	name = "Corrective Strike"
	desc = "Delivers Custodius's correction: deals damage that is higher the healthier the target is. A full-health target takes 50 damage; a near-dead target takes almost none."
	fluff_desc = "Correction is measured. Custodius does not strike to kill — he strikes to correct. The healthy need more correction; the broken have already learned their lesson."
	button_icon_state = "calming_respite"
	spell_color = GLOW_COLOR_UNDIVIDED

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("CORRECTION IS DELIVERED!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/custodius_expansion/corrective_strike/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	var/health_percent = L.health / L.maxHealth
	health_percent = clamp(health_percent, 0, 1)
	var/damage = 50 * health_percent
	damage = max(damage, 5) // minimum 5 damage
	L.apply_damage(damage, BRUTE)
	L.visible_message(span_warning("[L] is struck by corrective force!"), span_danger("Custodius's correction strikes you!"))
	playsound(get_turf(L), 'sound/magic/PSY.ogg', 60, TRUE)
	to_chat(owner, span_notice("Correction delivered: [damage] damage."))
	return TRUE

// ═══════════════════════════════════════════════════════════════════
// AURELIAN — Progress, Undeath, Hubris, and Left-Hand Magic
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/aurelian_expansion
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_ZIZO
	glow_intensity = GLOW_INTENSITY_LOW

	ignore_armor_penalty = TRUE
	attunement_school = null
	primary_resource_type = SPELL_COST_DEVOTION
	secondary_resource_type = SPELL_COST_STAMINA
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0
	point_cost = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

// T2 — Grave Bolt: Fire a projectile of necrotic energy
/datum/action/cooldown/spell/aurelian_expansion/grave_bolt
	name = "Grave Bolt"
	desc = "Fires a bolt of necrotic energy at a target. Deals 25 brute damage and drains 10 blood from the target."
	fluff_desc = "Aurelian's left-hand magic draws from the grave itself. Her bolts carry the cold of the tomb and the hunger of the dead — flesh withers, blood drains."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_ZIZO

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_PROJECTILE
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_WHISPER
	invocations = list("from the grave, I call...")
	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/aurelian_expansion/grave_bolt/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_damage(25, BRUTE)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.blood_volume = max(0, C.blood_volume - 10)
	L.visible_message(span_warning("[L] is struck by a bolt of necrotic energy!"), span_danger("A grave bolt strikes you — your flesh withers and blood drains!"))
	playsound(get_turf(L), 'sound/magic/soulshot.ogg', 60, TRUE)
	return TRUE

// T4 — Unmake: Strip a target of their magical buffs
/datum/action/cooldown/spell/aurelian_expansion/unmake
	name = "Unmake"
	desc = "Strips all magical buffs and status effects from a target. The ultimate expression of Aurelian's philosophy: what was made can be unmade."
	fluff_desc = "Aurelian claims no priesthood should stand between a soul and the divine. Her unmake extends that claim to magic itself: no enchantment is sacred, no buff is permanent, no protection cannot be stripped away."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_ZIZO

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("UNMAKE WHAT WAS MADE! STRIP WHAT WAS GIVEN!")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/aurelian_expansion/unmake/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	// Remove all buff status effects
	if(L.status_effects)
		for(var/datum/status_effect/buff/B in L.status_effects)
			qdel(B)
	L.visible_message(span_warning("[L]'s magical protections are stripped away!"), span_danger("Your enchantments and buffs are unmade!"))
	playsound(get_turf(L), 'sound/magic/antimagic.ogg', 80, TRUE)
	to_chat(owner, span_notice("I unmake [L]'s magical protections."))
	return TRUE
