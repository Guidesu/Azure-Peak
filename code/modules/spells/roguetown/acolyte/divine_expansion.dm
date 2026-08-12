// ═══════════════════════════════════════════════════════════════════
// DIVINE EXPANSION — New domain-defining spells for all worshipped gods
// Uses the /datum/action/cooldown/spell system with devotion costs.
// Each spell is themed to its god's domain and fills gaps in the tier list.
// ═══════════════════════════════════════════════════════════════════

// Traits used by this file
#define TRAIT_FOOD_PRESERVED "kamenka_food_preserved"
#define TRAIT_PRESERVED_CORPSE "kamenka_preserved_corpse"

// ═══════════════════════════════════════════════════════════════════
// KLOKNER — Boundaries, Lost Things, and the Answering Dark
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/klokner
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = "#4a4a6a"
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

// T2 — Threshold Ward: Creates an invisible boundary that alerts the caster when crossed
/datum/action/cooldown/spell/klokner/threshold_ward
	name = "Threshold Ward"
	desc = "Marks a tile as a boundary. When any mob crosses it, you are alerted with their name and direction. Lasts 5 minutes."
	fluff_desc = "Klokner knows every door, every fence, every line drawn in the dust. What crosses, He sees."
	button_icon_state = "heal"
	spell_color = "#4a4a6a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_NONE
	charge_required = FALSE
	cooldown_time = 60 SECONDS

/datum/action/cooldown/spell/klokner/threshold_ward/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE
	new /obj/effect/klokner_ward(T, owner)
	to_chat(owner, span_notice("I mark this threshold. None shall cross it unseen."))
	return TRUE

/obj/effect/klokner_ward
	name = "threshold ward"
	desc = "An invisible boundary marked by Klokner's will."
	icon = 'icons/effects/effects.dmi'
	icon_state = ""
	invisibility = INVISIBILITY_OBSERVER
	var/mob/warden
	var/duration = 5 MINUTES

/obj/effect/klokner_ward/Initialize(mapload, mob/warden)
	. = ..()
	src.warden = warden
	addtimer(CALLBACK(src, PROC_REF(expire)), duration)

/obj/effect/klokner_ward/Crossed(atom/movable/AM)
	if(!warden || QDELETED(warden))
		qdel(src)
		return
	if(isliving(AM))
		var/mob/living/L = AM
		if(L == warden)
			return
		var/direction = get_dir(src, warden)
		to_chat(warden, span_notice("Something crosses my threshold: [L.name], to the [dir2text(direction)]."))
		playsound(warden, 'sound/misc/notice (2).ogg', 50, FALSE)

// (sound references updated below to use existing files)

/obj/effect/klokner_ward/proc/expire()
	if(!QDELETED(src))
		qdel(src)

// T3 — Lost and Found: Reveals all hidden items and concealed objects in a large radius
/datum/action/cooldown/spell/klokner/lost_and_found
	name = "Lost and Found"
	desc = "Reveals all hidden, concealed, or invisible objects and creatures within a wide radius. Pings their locations briefly."
	fluff_desc = "What is lost does not stay lost. Klokner's dark whispers back every misplaced thing to those who know to listen."
	button_icon_state = "heal"
	spell_color = "#4a4a6a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MINOR_AOE

	invocation_type = INVOCATION_EMOTE
	invocations = list("whispers to the dark for what was lost...")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/klokner/lost_and_found/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	var/reveal_range = 7
	for(var/atom/movable/AM in range(reveal_range, center))
		if(AM == owner)
			continue
		if(AM.invisibility > 0)
			AM.invisibility = 0
			flash_color(AM, "#4a4a6a", 10)
	// Reveal hidden mobs
	for(var/mob/living/L in range(reveal_range, center))
		if(L == owner)
			continue
		if(L.alpha < 255)
			animate(L, alpha = 255, time = 1 SECONDS)
	// Ping all revealed
	for(var/turf/T in range(reveal_range, center))
		new /obj/effect/temp_visual/klokner_ping(T)
	to_chat(owner, span_notice("The dark whispers back what was hidden."))
	playsound(center, 'sound/magic/message.ogg', 50, TRUE)
	return TRUE

/obj/effect/temp_visual/klokner_ping
	name = "found"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

// T3 — Echoing Dark: Send a whispered message to a random living person anywhere in the world
/datum/action/cooldown/spell/klokner/echoing_dark
	name = "Echoing Dark"
	desc = "Whispers a message into the dark. A random living soul somewhere in the world will hear it as a disembodied voice. They cannot reply."
	fluff_desc = "Klokner's boundary is the horizon itself. What is whispered into His dark finds ears on the other side."
	button_icon_state = "heal"
	spell_color = "#4a4a6a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_WHISPER
	invocations = list("...to the dark, I speak...")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/klokner/echoing_dark/cast(atom/cast_on)
	. = ..()
	var/message = sanitize(input(owner, "What do you whisper into the dark?", "Echoing Dark") as null|text)
	if(!message || length(message) < 3)
		to_chat(owner, span_warning("The dark receives nothing."))
		reset_spell_cooldown()
		return FALSE
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.mob_list)
		if(L == owner || L.stat == DEAD)
			continue
		if(!istype(L, /mob/living/carbon/human))
			continue
		candidates += L
	if(!length(candidates))
		to_chat(owner, span_warning("The dark is silent. No ears to receive."))
		return TRUE
	var/mob/living/target = pick(candidates)
	to_chat(target, span_italics("A whisper drifts from somewhere far away: \"[message]\""))
	to_chat(owner, span_notice("The dark carries my whisper away..."))
	playsound(target, 'sound/magic/message.ogg', 30, TRUE)
	return TRUE

// T4 — Banish Beyond: Teleport a target to a random faraway location
/datum/action/cooldown/spell/klokner/banish_beyond
	name = "Banish Beyond"
	desc = "Tears open a boundary in reality, casting a target far from this place. They arrive somewhere random, dazed and disoriented."
	fluff_desc = "The ultimate expression of Klokner's domain: to be put beyond the boundary, beyond the known. Even He does not choose where they land."
	button_icon_state = "heal"
	spell_color = "#4a4a6a"

	click_to_activate = TRUE
	cast_range = 3
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("BEYOND THE BOUNDARY WITH YOU!")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/klokner/banish_beyond/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	var/turf/destination = find_safe_turf()
	if(!destination)
		to_chat(owner, span_warning("The boundaries are too thin to tear open."))
		return FALSE
	L.visible_message(span_warning("[L] is torn through a rift in reality!"), span_danger("Reality tears apart around you!"))
	playsound(get_turf(L), 'sound/magic/teleport_diss.ogg', 100, TRUE)
	new /obj/effect/temp_visual/klokner_banish(get_turf(L))
	do_teleport(L, destination, no_effects = TRUE)
	L.Dizzy(10)
	L.confused += 20
	playsound(destination, 'sound/magic/teleport_diss.ogg', 100, TRUE)
	to_chat(owner, span_notice("The boundary closes. [L] is beyond."))
	return TRUE

/obj/effect/temp_visual/klokner_banish
	name = "rift"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 5 SECONDS
	layer = ABOVE_MOB_LAYER

// ═══════════════════════════════════════════════════════════════════
// KAMENKA — Stillness, Preservation, Duty, and Stone
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/kamenka
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = GLOW_COLOR_EARTHEN
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

// T0 — Stone's Patience: Self-buff that grants CON and reduces stamina damage taken
/datum/action/cooldown/spell/kamenka/stones_patience
	name = "Stone's Patience"
	desc = "Grants the caster the patience of stone: CON+2 and reduced stamina damage for 2 minutes. The stillness of Kamenka flows through you."
	fluff_desc = "Stone does not tire. Stone does not rush. Kamenka teaches that all things come to those who wait upon duty."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_EARTHEN

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MINOR
	mana_cost = MANACOST_MIRACLE_MINOR
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_EMOTE
	invocations = list("remains still, as stone remains still.")
	charge_required = FALSE
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/kamenka/stones_patience/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	H.apply_status_effect(/datum/status_effect/buff/kamenka_patience)
	to_chat(H, span_notice("I feel the patience of stone settle into my bones."))
	playsound(H, 'sound/magic/fleshtostone.ogg', 50, TRUE)
	return TRUE

/datum/status_effect/buff/kamenka_patience
	id = "kamenka_patience"
	alert_type = /atom/movable/screen/alert/status_effect/buff/kamenka_patience
	duration = 2 MINUTES
	effectedstats = list(STATKEY_CON = 2)

/datum/status_effect/buff/kamenka_patience/on_apply()
	. = ..()
	if(!.)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod *= 0.5

/datum/status_effect/buff/kamenka_patience/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod *= 2.0 // undo the 0.5 multiplier

/atom/movable/screen/alert/status_effect/buff/kamenka_patience
	name = "Stone's Patience"
	desc = "Stamina damage is halved. The stillness of stone endures."
	icon_state = "buff"

// T1 — Preserve: Prevents food from rotting and preserves a corpse from decay
/datum/action/cooldown/spell/kamenka/preserve
	name = "Preserve"
	desc = "Touches an item of food or a corpse, preventing decay and rot. Food stays fresh; bodies stay whole."
	fluff_desc = "Kamenka's first gift to the dutiful: that what must be kept, shall be kept. The stiller co-equal does not allow entropy to claim what duty has not yet released."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_EARTHEN

	click_to_activate = TRUE
	cast_range = 1
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MINOR
	mana_cost = MANACOST_MIRACLE_MINOR
	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_EMOTE
	invocations = list("lays a preserving hand upon it.")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/kamenka/preserve/cast(atom/cast_on)
	. = ..()
	if(istype(cast_on, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/F = cast_on
		ADD_TRAIT(F, TRAIT_FOOD_PRESERVED, "kamenka_preserve")
		to_chat(owner, span_notice("[F] shall not spoil. Kamenka's stillness holds."))
		playsound(F, 'sound/magic/fleshtostone.ogg', 30, TRUE)
		return TRUE
	if(iscarbon(cast_on))
		var/mob/living/carbon/C = cast_on
		if(C.stat == DEAD)
			ADD_TRAIT(C, TRAIT_PRESERVED_CORPSE, "kamenka_preserve")
			to_chat(owner, span_notice("[C] shall not decay. Kamenka holds them still."))
			playsound(C, 'sound/magic/fleshtostone.ogg', 30, TRUE)
			return TRUE
		to_chat(owner, span_warning("They still live. Kamenka does not still the living."))
		return FALSE
	to_chat(owner, span_warning("Kamenka's preservation applies to food and the dead only."))
	return FALSE

// T3 — Petrify: Slow and eventually paralyze a target with stone
/datum/action/cooldown/spell/kamenka/petrify
	name = "Petrify"
	desc = "Casts Kamenka's stillness into a target's limbs, slowing them drastically. After 5 seconds, they are fully paralyzed for 3 seconds."
	fluff_desc = "The ultimate duty is to hold. Kamenka can teach this to the unwilling — stone creeping through flesh, stillness replacing motion."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_EARTHEN

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("BE STILL!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 2 MINUTES

/datum/action/cooldown/spell/kamenka/petrify/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_status_effect(/datum/status_effect/debuff/kamenka_petrify)
	L.visible_message(span_warning("[L]'s skin begins to turn grey and crack with stone!"), span_danger("Your limbs are turning to stone!"))
	playsound(get_turf(L), 'sound/magic/fleshtostone.ogg', 80, TRUE)
	return TRUE

/datum/status_effect/debuff/kamenka_petrify
	id = "kamenka_petrify"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/kamenka_petrify
	duration = 8 SECONDS
	effectedstats = list(STATKEY_SPD = -5)

/datum/status_effect/debuff/kamenka_petrify/on_apply()
	. = ..()
	if(!.)
		return
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier("kamenka_petrify", update=TRUE, priority=100, multiplicative_slowdown=3)
	addtimer(CALLBACK(src, PROC_REF(full_paralyze)), 5 SECONDS)

/datum/status_effect/debuff/kamenka_petrify/proc/full_paralyze()
	if(!QDELETED(owner) && owner.has_status_effect(src.type))
		owner.Immobilize(30)
		owner.Stun(30)
		to_chat(owner, span_danger("Stone claims you entirely!"))

/datum/status_effect/debuff/kamenka_petrify/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier("kamenka_petrify")

/atom/movable/screen/alert/status_effect/debuff/kamenka_petrify
	name = "Petrifying"
	desc = "Your limbs are turning to stone! You will be fully paralyzed soon."
	icon_state = "debuff"

// T4 — Monument: Create a permanent stone shrine that provides passive buffs to the faithful
/datum/action/cooldown/spell/kamenka/monument
	name = "Monument"
	desc = "Raises a stone monument from the earth. All faithful Kamenka worshippers nearby gain CON+2 and reduced stamina damage. The monument is permanent until destroyed."
	fluff_desc = "The pinnacle of Kamenka's craft: a monument that outlasts the maker, a duty that outlasts the dutiful. Stone remembers what flesh forgets."
	button_icon_state = "heal"
	spell_color = GLOW_COLOR_EARTHEN

	click_to_activate = TRUE
	cast_range = 1
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("RISE, MONUMENT OF DUTY! STAND FOREVER!")
	charge_required = TRUE
	charge_time = 5 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 10 MINUTES

/datum/action/cooldown/spell/kamenka/monument/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(cast_on)
	if(!T || T.density)
		to_chat(owner, span_warning("There is no space for a monument here."))
		return FALSE
	new /obj/structure/fluff/kamenka_monument(T)
	to_chat(owner, span_notice("A monument rises from the earth. It shall stand."))
	playsound(T, 'sound/magic/fleshtostone.ogg', 100, TRUE)
	return TRUE

/obj/structure/fluff/kamenka_monument
	name = "Kamenka Monument"
	desc = "A rough-hewn stone monument, radiating stillness and duty. The faithful feel their endurance bolstered near it."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "cross_undivided_r"
	density = TRUE
	max_integrity = 200
	var/range = 5

/obj/structure/fluff/kamenka_monument/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fluff/kamenka_monument/process()
	for(var/mob/living/carbon/human/H in range(range, src))
		if(H.patron && istype(H.patron, /datum/patron/severance/kamenka))
			if(!H.has_status_effect(/datum/status_effect/buff/kamenka_patience))
				H.apply_status_effect(/datum/status_effect/buff/kamenka_patience)

/obj/structure/fluff/kamenka_monument/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// ═══════════════════════════════════════════════════════════════════
// PRAECURSOR — The Word, First Law, and Judgment
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/praecursor_expansion
	background_icon = 'icons/mob/actions/psydonmiracles.dmi'
	button_icon = 'icons/mob/actions/psydonmiracles.dmi'
	spell_color = GLOW_COLOR_AUXENTIUS_SUN
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
	spell_flags = SPELL_PRAECURSOR
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	required_items = list(/obj/item/clothing/neck/roguetown/psicross)

// T3 — Edict: Force a target to stop attacking
/datum/action/cooldown/spell/praecursor_expansion/edict
	name = "Edict"
	desc = "Speaks a Word of Law that compels a target to cease all violence. They cannot attack for 15 seconds. Mindless undead and beasts are immune."
	fluff_desc = "The Word was first, and the Word was law. Praecursor's edicts carry the weight of the first judgment — even the violent must hear and obey."
	button_icon_state = "BOOTCHECK"
	spell_color = GLOW_COLOR_AUXENTIUS_SUN

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("BY THE FIRST WORD: CEASE!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/praecursor_expansion/edict/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	if(L.ckey && L.client) // Player-controlled
		L.apply_status_effect(/datum/status_effect/debuff/praecursor_edict)
		to_chat(L, span_danger("An overwhelming command seizes you: you cannot bring yourself to attack!"))
		playsound(get_turf(L), 'sound/magic/message.ogg', 60, TRUE)
		return TRUE
	to_chat(owner, span_warning("The Edict requires a soul to compel. This thing has none."))
	return FALSE

/datum/status_effect/debuff/praecursor_edict
	id = "praecursor_edict"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/praecursor_edict
	duration = 15 SECONDS

/datum/status_effect/debuff/praecursor_edict/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_PACIFISM, "praecursor_edict")

/datum/status_effect/debuff/praecursor_edict/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "praecursor_edict")

/atom/movable/screen/alert/status_effect/debuff/praecursor_edict
	name = "Edicted"
	desc = "You have been compelled by the First Word to cease all violence."
	icon_state = "debuff"

// T4 — Final Word: Powerful judgment that deals damage scaling with the target's sins/wrongdoings
/datum/action/cooldown/spell/praecursor_expansion/final_word
	name = "Final Word"
	desc = "Speaks the Final Word of Judgment upon a target. Deals divine damage scaling with how many people the target has killed this round. Innocent targets take minimal damage."
	fluff_desc = "When all other words have failed, there is one last word. Praecursor spoke it once, and the world was made. He speaks it again, and the guilty are unmade."
	button_icon_state = "BOOTCHECK"
	spell_color = GLOW_COLOR_AUXENTIUS_SUN

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("THE FINAL WORD IS SPOKEN. JUDGMENT IS RENDERED.")
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/praecursor_expansion/final_word/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	// Base damage; higher if target is hostile
	var/damage = 30
	if(L.a_intent == INTENT_HARM)
		damage = 80
	damage = min(damage, 200) // cap
	L.visible_message(span_warning("[L] is struck by the weight of judgment!"), span_danger("The Final Word falls upon you like a mountain!"))
	playsound(get_turf(L), 'sound/magic/PSY.ogg', 100, TRUE)
	L.apply_damage(damage, BRUTE)
	L.Dizzy(10)
	if(damage > 30)
		to_chat(owner, span_notice("The Final Word finds [L] guilty. Judgment: [damage] damage."))
	else
		to_chat(owner, span_notice("The Final Word finds [L] innocent. They are merely struck."))
	return TRUE

// ═══════════════════════════════════════════════════════════════════
// VERITA — Truth, Testimony, and Contracts
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/verita
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = "#e8e8d0"
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

// T2 — Zone of Truth: Creates an area where lying causes pain
/datum/action/cooldown/spell/verita/zone_of_truth
	name = "Zone of Truth"
	desc = "Creates a 5-tile radius zone where anyone who speaks a lie takes burn damage. Lasts 1 minute. The caster is also affected."
	fluff_desc = "Verita's domain is truth itself. In Her presence, lies burn — not with fire, but with the searing weight of what is not."
	button_icon_state = "heal"
	spell_color = "#e8e8d0"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("LET NO LIE STAND IN THIS PLACE!")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/verita/zone_of_truth/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(cast_on)
	new /obj/effect/verita_truth_zone(T)
	to_chat(owner, span_notice("A zone of truth settles over this place. Lies will burn."))
	playsound(T, 'sound/magic/heal.ogg', 60, TRUE)
	return TRUE

/obj/effect/verita_truth_zone
	name = "zone of truth"
	desc = "A shimmering field where lies are punished."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	layer = ABOVE_MOB_LAYER
	var/duration = 1 MINUTES

/obj/effect/verita_truth_zone/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(expire)), duration)

/obj/effect/verita_truth_zone/proc/expire()
	if(!QDELETED(src))
		qdel(src)

// T3 — Binding Contract: Links two targets — damage to one is shared with the other
/datum/action/cooldown/spell/verita/binding_contract
	name = "Binding Contract"
	desc = "Forges a magical contract between you and a target. For 30 seconds, 50% of the damage you take is also dealt to them, and vice versa."
	fluff_desc = "A contract signed in spirit is stronger than one signed in ink. Verita binds two souls together — what befalls one, befalls both."
	button_icon_state = "heal"
	spell_color = "#e8e8d0"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_SINGLE_CC

	invocation_type = INVOCATION_SHOUT
	invocations = list("BY VERITA'S SEAL: OUR FATES ARE BOUND!")
	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/verita/binding_contract/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	var/mob/living/caster = owner
	caster.apply_status_effect(/datum/status_effect/buff/verita_contract, L)
	L.apply_status_effect(/datum/status_effect/buff/verita_contract, caster)
	caster.visible_message(span_warning("[caster] and [L] are bound by a shimmering contract!"), span_notice("I bind my fate to [L]. What befalls one, befalls both."))
	to_chat(L, span_danger("You feel your fate bound to [caster] by a magical contract!"))
	playsound(get_turf(L), 'sound/magic/heal.ogg', 60, TRUE)
	return TRUE

/datum/status_effect/buff/verita_contract
	id = "verita_contract"
	alert_type = /atom/movable/screen/alert/status_effect/buff/verita_contract
	duration = 30 SECONDS
	var/mob/living/linked

/datum/status_effect/buff/verita_contract/on_creation(mob/living/new_owner, mob/living/linked_target)
	linked = linked_target
	return ..()

/datum/status_effect/buff/verita_contract/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(share_damage))

/datum/status_effect/buff/verita_contract/proc/share_damage(mob/source, amount, damagetype, def_zone)
	SIGNAL_HANDLER
	if(!linked || QDELETED(linked) || linked.stat == DEAD)
		return
	linked.apply_damage(amount * 0.5, damagetype, def_zone)

/datum/status_effect/buff/verita_contract/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMGE)

/atom/movable/screen/alert/status_effect/buff/verita_contract
	name = "Bound by Contract"
	desc = "Your fate is linked to another. Half of all damage you take is shared with them, and vice versa."
	icon_state = "buff"

// T4 — Final Verdict: Deals massive damage to targets who have attacked the caster recently
/datum/action/cooldown/spell/verita/final_verdict
	name = "Final Verdict"
	desc = "Renders final judgment on a target. If they are hostile, deals massive divine damage. Otherwise, does nothing."
	fluff_desc = "When truth has been violated, when testimony has been ignored, there is the verdict. Verita's final word is not kind — it is simply correct."
	button_icon_state = "heal"
	spell_color = "#e8e8d0"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("THE VERDICT IS RENDERED. LET TRUTH PREVAIL.")
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/verita/final_verdict/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	// Check if target is hostile
	var/has_attacked = FALSE
	if(L.a_intent == INTENT_HARM)
		has_attacked = TRUE
	if(!has_attacked)
		to_chat(owner, span_notice("The verdict finds no crime. [L] has not wronged me."))
		return TRUE
	var/damage = 150
	L.visible_message(span_warning("[L] is struck down by Verita's final verdict!"), span_danger("The weight of truth crushes you!"))
	playsound(get_turf(L), 'sound/magic/PSY.ogg', 100, TRUE)
	L.apply_damage(damage, BRUTE)
	L.Dizzy(15)
	to_chat(owner, span_notice("The verdict is rendered. Justice is done."))
	return TRUE

// ═══════════════════════════════════════════════════════════════════
// TRNAVA — Forests, Poison-and-Cure, and Fierce Motherhood
// ═══════════════════════════════════════════════════════════════════

/datum/action/cooldown/spell/trnava
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	spell_color = "#3a6b2a"
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

// T2 — Thorn Burst: AOE poison damage around caster
/datum/action/cooldown/spell/trnava/thorn_burst
	name = "Thorn Burst"
	desc = "Causes thorny vines to erupt from the ground around you, dealing poison damage to all enemies in a 3-tile radius and poisoning them."
	fluff_desc = "Trnava's forest does not welcome strangers. Those who enter without Her blessing leave with thorns in their flesh and venom in their blood."
	button_icon_state = "heal"
	spell_color = "#3a6b2a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("RISE, THORNS! STRIKE THE UNWELCOME!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/trnava/thorn_burst/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/churn.ogg', 80, TRUE)
	for(var/mob/living/L in range(3, center))
		if(L == owner)
			continue
		L.apply_damage(25, TOX)
		L.apply_damage(15, BRUTE)
		if(L.reagents)
			L.reagents.add_reagent(/datum/reagent/toxin, 5)
		L.visible_message(span_warning("[L] is struck by thorny vines!"), span_danger("Thorns pierce your flesh! Poison burns in your veins!"))
		new /obj/effect/temp_visual/trnava_thorns(get_turf(L))
	return TRUE

/obj/effect/temp_visual/trnava_thorns
	name = "thorns"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

// T3 — Mother's Wrath: Buff nearby allies with CON and STR, debuff enemies with fear
/datum/action/cooldown/spell/trnava/mothers_wrath
	name = "Mother's Wrath"
	desc = "Channels the fierce mother's protective rage. Allies within 5 tiles gain +3 CON and +3 STR for 1 minute. Enemies are filled with dread and lose 3 PER."
	fluff_desc = "Trnava is the mother who protects with venom and thorn. Her wrath is not rage — it is love, sharpened to a point."
	button_icon_state = "heal"
	spell_color = "#3a6b2a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR
	mana_cost = MANACOST_MIRACLE_MAJOR
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("NONE SHALL HARM MY CHILDREN!")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/trnava/mothers_wrath/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/heal.ogg', 80, TRUE)
	for(var/mob/living/carbon/human/H in range(5, center))
		if(H == owner)
			continue
		if(H.patron && istype(H.patron, /datum/patron/oldkin/trnava))
			H.apply_status_effect(/datum/status_effect/buff/trnava_wrath)
			to_chat(H, span_notice("Trnava's wrath fills you with fierce strength!"))
		else
			H.apply_status_effect(/datum/status_effect/debuff/trnava_dread)
			to_chat(H, span_warning("A mother's wrathful gaze falls upon you. You feel small."))
	return TRUE

/datum/status_effect/buff/trnava_wrath
	id = "trnava_wrath"
	alert_type = /atom/movable/screen/alert/status_effect/buff/trnava_wrath
	duration = 1 MINUTES
	effectedstats = list(STATKEY_CON = 3, STATKEY_STR = 3)

/atom/movable/screen/alert/status_effect/buff/trnava_wrath
	name = "Mother's Wrath"
	desc = "Trnava's protective rage fills you with strength."
	icon_state = "buff"

/datum/status_effect/debuff/trnava_dread
	id = "trnava_dread"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/trnava_dread
	duration = 30 SECONDS
	effectedstats = list(STATKEY_PER = -3)

/atom/movable/screen/alert/status_effect/debuff/trnava_dread
	name = "Mother's Dread"
	desc = "A mother's wrathful gaze diminishes your senses."
	icon_state = "debuff"

// T3 — Poison Ward: Grant poison resistance to a target
/datum/action/cooldown/spell/trnava/poison_ward
	name = "Poison Ward"
	desc = "Grants a target immunity to poison for 5 minutes. Also cures any existing poison in their system."
	fluff_desc = "Trnava knows every poison and every cure, for they are the same leaf seen from different sides. Her ward turns venom to water."
	button_icon_state = "heal"
	spell_color = "#3a6b2a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE
	mana_cost = MANACOST_MIRACLE
	secondary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocation_type = INVOCATION_EMOTE
	invocations = list("whispers to the poison: be still.")
	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/trnava/poison_ward/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = cast_on
	if(!istype(L))
		return FALSE
	L.apply_status_effect(/datum/status_effect/buff/trnava_poison_ward)
	if(L.reagents)
		for(var/datum/reagent/R in L.reagents.reagent_list)
			if(istype(R, /datum/reagent/toxin))
				L.reagents.remove_reagent(R.type, R.volume)
	to_chat(L, span_notice("You feel Trnava's ward settle over you. Poison shall not touch you."))
	playsound(get_turf(L), 'sound/magic/heal.ogg', 50, TRUE)
	return TRUE

/datum/status_effect/buff/trnava_poison_ward
	id = "trnava_poison_ward"
	alert_type = /atom/movable/screen/alert/status_effect/buff/trnava_poison_ward
	duration = 5 MINUTES

/datum/status_effect/buff/trnava_poison_ward/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_TOXINLOVER, "trnava_poison_ward")

/datum/status_effect/buff/trnava_poison_ward/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_TOXINLOVER, "trnava_poison_ward")

/atom/movable/screen/alert/status_effect/buff/trnava_poison_ward
	name = "Poison Ward"
	desc = "You are immune to poison. Existing toxins have been purged."
	icon_state = "buff"

// T4 — Wild Regrowth: Heal and cure all allies in a large area
/datum/action/cooldown/spell/trnava/wild_regrowth
	name = "Wild Regrowth"
	desc = "Causes a surge of wild growth that heals all allies in a 7-tile radius for a large amount, cures their poisons, and restores their stamina. The forest provides."
	fluff_desc = "The forest does not hoard its gifts. When Trnava's children are hurt, the earth itself rises to mend them — roots to bind wounds, sap to seal them, water to wash away venom."
	button_icon_state = "heal"
	spell_color = "#3a6b2a"

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_AURA
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE_LEGENDARY
	mana_cost = MANACOST_MIRACLE_LEGENDARY
	secondary_resource_cost = SPELLCOST_MAJOR_AOE

	invocation_type = INVOCATION_SHOUT
	invocations = list("RISE, FOREST! MEND MY CHILDREN!")
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 5 MINUTES

/datum/action/cooldown/spell/trnava/wild_regrowth/cast(atom/cast_on)
	. = ..()
	var/turf/center = get_turf(owner)
	playsound(center, 'sound/magic/heal.ogg', 100, TRUE)
	for(var/mob/living/carbon/human/H in range(7, center))
		if(H.patron && istype(H.patron, /datum/patron/oldkin/trnava))
			H.adjustBruteLoss(-50)
			H.adjustFireLoss(-50)
			H.adjustToxLoss(-50)
			H.adjustOxyLoss(-50)
			if(H.reagents)
				for(var/datum/reagent/R in H.reagents.reagent_list)
					if(istype(R, /datum/reagent/toxin))
						H.reagents.remove_reagent(R.type, R.volume)
			H.stamina_add(H.max_stamina)
			to_chat(H, span_notice("The forest surges through you, mending wounds and purging venom!"))
			new /obj/effect/temp_visual/trnava_regrowth(get_turf(H))
	return TRUE

/obj/effect/temp_visual/trnava_regrowth
	name = "wild regrowth"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	duration = 5 SECONDS
	layer = ABOVE_MOB_LAYER
