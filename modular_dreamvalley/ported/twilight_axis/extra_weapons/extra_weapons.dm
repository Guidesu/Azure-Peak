// Ported from Twilight-Axis. This file ports missing weapons that were not already
// present in DreamValley. Sources:
//   - modular_deserttown/desertweapons.dm (serpent staff, zybantine kriegmesser)
//   - modular_twilight_axis/church_classes/martyr/weapons.dm (divine scythe)
//   - modular_twilight_axis/code/game/objects/items/rogueweapons/melee/polearms.dm (equipoise, saccharine swordspear)
//   - modular_twilight_axis/code/game/objects/items/rogueweapons/melee/knives.dm (snake's sting)
//   - modular_twilight_axis/code/game/objects/items/rogueweapons/melee/swords.dm (her verdict)
//   - modular_twilight_axis/firearms/code/jobs/orthodoxist.dm (psydonic claws - already ported as vaeltic claws, skipped)
//
// Adaptation notes:
// - Icon paths remapped to DreamValley equivalents (see icon path mapping below).
// - Deity names remapped: Astrata->Auxentius, Noc->Miluse, Psydon->Vaeltian,
//   Eora->Trnava, Baotha->Hausvette, Necra->Morwenna.
// - The divine scythe's /datum/special_intent/martyr_dendor_vine_reap does not exist
//   in DreamValley; that reference was removed but weapon stats and the martyrweapon
//   component are retained. Custom martyr intent subtypes (martyr fire variants) are
//   defined here for the scythe, mirroring the pattern used by DreamValley's own
//   martyr longsword and trident in code/modules/jobs/.../church/martyr.dm.
// - The snake's sting (baotha dagger) references /datum/reagent/neurotoxin which does
//   not exist in DreamValley; a local neurotoxin reagent is defined here to preserve
//   the weapon's on-hit drug effect.
// - The snake's sting's attack_self() proc creates a /obj/item/clothing/ring/baotha
//   which does not exist in DreamValley; that proc is omitted to avoid a dangling
//   type reference. The cursed_item component and on-hit hallucination/toxin effects
//   are retained.
// - Her verdict (donat_astrata kriegmesser) uses DreamValley's native
//   icons/obj/items/donor_weapons_64.dmi (shared ancestry with TA's donor icon file).
// - Psydonic claws were already ported as "vaeltic claws" in
//   ported/twilight_axis/firearms/jobs/orthodoxist.dm — skipped here.
// - The saccharine swordspear's icon in TA uses 'icons/roguetown/weapons/polearms64.dmi'
//   (a vanilla path); remapped to modular_dreamvalley/icons/twilight_weapons_new/polearms64.dmi.
// - HERESYDESC_BAOTHA_WEAPON is used as-is (DreamValley's define uses the Baotha name
//   in the define constant, matching the existing heresy examine system).

//====================================================================
// Staff of the Serpent (desertweapons.dm)
//====================================================================

/obj/item/rogueweapon/woodstaff/riddle_of_steel/serpent
	name = "\improper Staff of the Serpent"
	desc = "A mysterious golden staff shaped like a snake. You could swear its staring at you"
	icon = 'modular_dreamvalley/icons/twilight_desert/desertweapons64.dmi'
	icon_state = "snakestaff"

//====================================================================
// Heavy Scimitar / Zybantine Kriegmesser (desertweapons.dm)
//====================================================================

/obj/item/rogueweapon/sword/long/kriegmesser/zybantine
	name = "heavy scimitar"
	desc = "A large zybantine sword with a single-edged blade, a crossguard and a knife-like hilt."
	icon = 'modular_dreamvalley/icons/twilight_desert/desertweapons64.dmi'
	icon_state = "Kmesser"

//====================================================================
// Divine Scythe (martyr/weapons.dm)
// - /datum/special_intent/martyr_dendor_vine_reap removed (does not exist in DV)
// - Custom martyr intent subtypes defined here for fire-typed attacks
//====================================================================

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr
	force = 22
	force_wielded = 37
	possible_item_intents = list(/datum/intent/spear/thrust/bad, /datum/intent/spear/bash)
	gripped_intents = list(/datum/intent/spear/cut/bardiche, /datum/intent/spear/cut/bardiche/cleave, /datum/intent/spear/cut/glaive/sweep, /datum/intent/axe/chop/scythe)
	icon_state = "martyrscyth"
	icon = 'modular_dreamvalley/icons/twilight_church/martyr_weapons64.dmi'
	item_state = "martyrscyth"
	name = "divine scythe"
	desc = "A relic from the Holy See's own vaults; a blessed silver scythe, marked with the ten-pointed sigil of Auxentius's undivided might. </br>It simmers with godly energies, and will only yield to the hands of those who have taken the Oath."
	max_blade_int = 250
	max_integrity = 9999
	bigboy = 1
	wlength = WLENGTH_LONG
	associated_skill = /datum/skill/combat/polearms
	smeltresult = null
	is_silver = TRUE
	is_important = TRUE

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_TENNITE,\
		silver_type = SILVER_TENNITE,\
		added_force = 0,\
		added_blade_int = 0,\
		added_int = 0,\
		added_def = 0,\
	)

/datum/intent/spear/cut/bardiche/martyr
	item_d_type = "fire"
	blade_class = BCLASS_CUT

/datum/intent/spear/cut/bardiche/cleave/martyr
	item_d_type = "fire"
	blade_class = BCLASS_CUT

/datum/intent/spear/cut/glaive/sweep/martyr
	item_d_type = "fire"
	blade_class = BCLASS_CHOP

/datum/intent/axe/chop/scythe/martyr
	item_d_type = "fire"
	blade_class = BCLASS_CHOP
	swingdelay = 5

/datum/intent/spear/thrust/bad/martyr
	item_d_type = "fire"
	blade_class = BCLASS_PICK

/datum/intent/spear/bash/martyr_scythe
	item_d_type = "fire"

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr/Initialize()
	. = ..()
	if(SSroguemachine.martyrweapon)
		qdel(src)
	else
		SSroguemachine.martyrweapon = src
	if(!gc_destroyed)
		var/list/active_intents = list(/datum/intent/spear/thrust/bad/martyr, /datum/intent/spear/bash/martyr_scythe)
		var/list/active_intents_wielded = list(/datum/intent/spear/cut/bardiche/martyr, /datum/intent/spear/cut/bardiche/cleave/martyr, /datum/intent/spear/cut/glaive/sweep/martyr, /datum/intent/axe/chop/scythe/martyr)
		var/safe_damage = 15
		var/safe_damage_wielded = 35
		AddComponent(/datum/component/martyrweapon, active_intents, active_intents_wielded, safe_damage, safe_damage_wielded)

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr/proc/anti_stall()
	src.visible_message(span_danger("The Martyr's scythe dissolved into sparkling dust, which instantly rose up and was carried away by the wind."))
	SSroguemachine.martyrweapon = null
	qdel(src)

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr/attack_hand(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if((H.job in GLOB.church_positions))
		return ..()
	if(istype(H.patron, /datum/patron/unveiled))
		var/datum/component/martyrweapon/marty = GetComponent(/datum/component/martyrweapon)
		to_chat(user, span_warning("YOU FOOL! IT IS ANATHEMA TO YOU! GET AWAY!"))
		H.Stun(40)
		H.Knockdown(40)
		if(marty.is_active)
			visible_message(span_warning("[H] lets out a painful shriek as the scythe lashes out at them!"))
			H.emote("agony")
			H.adjust_fire_stacks(5)
			H.ignite_mob()
		return FALSE
	to_chat(user, span_warning("A painful jolt across your entire body sends you to the ground. You cannot touch this thing."))
	H.emote("groan", forced = TRUE)
	H.Stun(10)
	return FALSE

/obj/item/rogueweapon/halberd/bardiche/scythe/martyr/Destroy()
	var/datum/component/martyr = GetComponent(/datum/component/martyrweapon)
	if(martyr)
		martyr.ClearFromParent()
	return ..()

//====================================================================
// Equipoise / Twilight Necrascythe (polearms.dm)
//====================================================================

/obj/item/rogueweapon/halberd/bardiche/twilight_necrascythe
	name = "equipoise"
	desc = "Often wielded by the Morwennan Immortals, this silver scythe is claimed to be capable of bypassing all protection, striking directly at the enemy's soul."
	icon = 'modular_dreamvalley/icons/twilight_weapons_new/64.dmi'
	icon_state = "necrascythe"
	possible_item_intents = list(/datum/intent/spear/cut/oneh, SPEAR_BASH)
	gripped_intents = list(/datum/intent/spear/cut/bardiche, /datum/intent/rend/reach, /datum/intent/axe/chop/scythe, SPEAR_BASH)
	force_wielded = 35
	max_integrity = 300
	wdefense = 4
	is_silver = TRUE

/obj/item/rogueweapon/halberd/bardiche/twilight_necrascythe/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_NONE,\
		silver_type = SILVER_TENNITE,\
		added_force = 0,\
		added_blade_int = 50,\
		added_int = 50,\
		added_def = 2,\
	)

/obj/item/rogueweapon/halberd/bardiche/twilight_necrascythe/preblessed/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_TENNITE,\
		silver_type = SILVER_TENNITE,\
		added_force = 0,\
		added_blade_int = 50,\
		added_int = 50,\
		added_def = 2,\
	)

//====================================================================
// Saccharine Swordspear / Baotha Ta (polearms.dm)
//====================================================================

/obj/item/rogueweapon/spear/partizan/baotha_ta
	name = "saccharine swordspear"
	desc = "Keep the rest at arm's length, lest you're burdened with the pain of rememberance."
	force = 25
	force_wielded = 35
	possible_item_intents = list(/datum/intent/sword/thrust/long, /datum/intent/sword/cut/long, /datum/intent/sword/strike, /datum/intent/sword/thrust/heavy)
	gripped_intents = list(SPEAR_THRUST, /datum/intent/spear/cut, PARTIZAN_REND, /datum/intent/spear/cut/glaive/sweep)
	icon_state = "swordstaff"
	icon = 'modular_dreamvalley/icons/twilight_weapons_new/polearms64.dmi'
	parrysound = list(
	'sound/combat/parry/bladed/bladedmedium (1).ogg',
	'sound/combat/parry/bladed/bladedmedium (2).ogg',
	'sound/combat/parry/bladed/bladedmedium (3).ogg',
	)
	pickup_sound = 'sound/foley/equip/swordlarge1.ogg'
	minstr = 4
	thrown_bclass = BCLASS_PIERCE
	max_blade_int = 400
	max_integrity = 400
	throwforce = 45 //Pierce the heavens!
	wdefense = 4
	wdefense_wbonus = 5
	smeltresult = /obj/item/ingot/component/baotha
	slot_flags = ITEM_SLOT_BACK
	equip_delay_self = 2 SECONDS
	unequip_delay_self = 2 SECONDS
	inv_storage_delay = 1 SECONDS
	icon_angle_wielded = null

/obj/item/rogueweapon/spear/partizan/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "SWORDSPEAR")

/obj/item/rogueweapon/spear/partizan/baotha_ta/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen") return list("shrink" = 0.7, "sx" = -14, "sy" = -8, "nx" = 9, "ny" = -6, "wx" = -6, "wy" = -6, "ex" = -1, "ey" = -4, "northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0, "nturn" = -10, "sturn" = 108, "wturn" = -72, "eturn" = -10, "nflip" = 1, "sflip" = 1, "wflip" = 8, "eflip" = 1)
			if("wielded") return list("shrink" = 0.75, "sx" = 5, "sy" = -3, "nx" = -5, "ny" = -3, "wx" = -5, "wy" = -3, "ex" = 3, "ey" = -4, "northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0, "nturn" = 6, "sturn" = -8, "wturn" = 10, "eturn"= -10, "nflip" = 8, "sflip" = 0, "wflip" = 8, "eflip" = 0)

/obj/item/rogueweapon/spear/partizan/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_WEAPON)

//====================================================================
// Snake's Sting / Baotha Dagger (knives.dm)
// - attack_self() ring creation proc omitted (ring type does not exist in DV)
// - Local /datum/reagent/neurotoxin defined here for on-hit drug effect
//====================================================================

/obj/item/rogueweapon/huntingknife/idagger/steel/baotha
	name = "snake's sting"
	desc = "The blade is skillfully crafted and appears to be designed for stealthy assassinations. There are visible streaks of a bubbling substance on its blade."
	icon = 'modular_dreamvalley/icons/twilight_weapons_new/32.dmi'
	icon_state = "baotha_knife1"
	max_blade_int = 300
	throwforce = 40
	force = 25
	wdefense = 4
	var/last_cut = 0
	var/last_drug = 0

/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_WEAPON)

/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/Initialize()
	. = ..()
	icon_state = "baotha_knife1"
	addtimer(CALLBACK(src, PROC_REF(icon_proc)), 1 SECONDS)
	AddComponent(/datum/component/cursed_item, TRAIT_CRACKHEAD, "KNIFE")
	RegisterSignal(src, COMSIG_ITEM_ATTACK_EFFECT_SELF, PROC_REF(on_hit_effects))

/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/proc/icon_proc()
	icon_state = "baotha_knife2"

/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/proc/on_hit_effects(obj/item/source, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/victim, selzone)
	SIGNAL_HANDLER

	if(!istype(victim, /mob/living/carbon))
		return

	var/mob/living/carbon/human/target = victim
	var/drug = /datum/reagent/neurotoxin/baotha
	var/selected_hallucination = pick(list(
		"Is this TRVE??", "IDDQD", "DAFUQ?", "I am NOT meant to see this.",
		"What... WHAT is this?", "This doesn't make SENSE.", "I don't UNDERSTAND.",
		"Why does it LOOK like that?", "Something is WRONG here.", "This isn't RIGHT.",
		"What am I looking at?", "None of THIS adds up.", "I shouldn't be SEEING this.",
		"This feels... INCORRECT.", "Why is everything like this?", "I CAN'T process this.",
		"This ISN'T how it should be.", "I don't get it.", "What is happening?",
		"This is all WRONG.", "I CAN'T tell what's REAL.", "Why does it feel off?",
		"I don't recognize this.", "This SHOULDN'T exist.", "What is THIS supposed to be?",
		"I can't FOLLOW this.", "This isn't making sense anymore.", "I think SOMETHING is broke.",
		"Why can't I understand THIS?", "This feels IMPOSSIBLE.", "I don't KNOW what I'm seeing."
	))

	if(!HAS_TRAIT(target, TRAIT_PSYCHOSIS))
		ADD_TRAIT(target, TRAIT_PSYCHOSIS, "baothaknife")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(baothapsychosis), target), 1 MINUTES)

	target.hallucination = rand(1,60)
	to_chat(target, span_warning(selected_hallucination))
	target.Jitter(5)

	if(prob(50))
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, emote), pick("giggle","laugh","chuckle")), 0)

	if(last_cut + 10 SECONDS >= world.time) return
	target.adjustToxLoss(9)
	last_cut = world.time
	if(last_drug + 8 SECONDS >= world.time) return
	target.reagents.add_reagent(drug, 1.6)
	last_drug = world.time

/proc/baothapsychosis(mob/living/carbon/target)
	if(QDELETED(target))
		return
	REMOVE_TRAIT(target, TRAIT_PSYCHOSIS, "baothaknife")

/datum/reagent/neurotoxin/baotha
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61"
	metabolization_rate = 0.05
	harmful = TRUE

/datum/reagent/neurotoxin/baotha/on_mob_life(mob/living/carbon/M)
	var/amt = volume

	if(amt >= 8)
		if(prob(30))
			to_chat(M, span_warning("WHAT THE-.. I CANT FEEL MY BODY!"))
		M.Paralyze(600, 0)
		M.emote("agony")

	else if(amt >= 7)
		if(prob(15))
			to_chat(M, span_warning("I'M SO WEAK NOW! STOP IT!!.."))
		M.apply_status_effect(/datum/status_effect/debuff/exposed)
		M.Slowdown(5)

	else if(amt >= 5)
		M.energy_add(-20)
		M.blur_eyes(4)
		if(prob(15))
			to_chat(M, span_warning("THIS ACID!! I.. Im really getting weaker a lot.. "))

	else if(amt >= 2.1)
		M.energy_add(-15)
		if(prob(15))
			to_chat(M, span_warning("I feel myself weaker.."))

	else if(amt >= 1.1)
		if(prob(12))
			to_chat(M, span_warning("Agh.. I feel weak in my body.."))

	return ..()

//====================================================================
// Her Verdict / Donat Astrata Kriegmesser (swords.dm)
// - Uses DreamValley's native donor_weapons_64.dmi (shared ancestry)
// - Deity reference Astrata->Auxentius
//====================================================================

/obj/item/rogueweapon/sword/long/kriegmesser/donat_astrata
	name = "her verdict"
	desc = "Wielded by the Paladins of the Punishing Light, these swords are forged from the same alloy of steel and silver used in the Eclipsum blades. While effective on the field of battle, this weapon is primarily known for it's use in public executions.</br>'In the light of your rays I stand before you..' </br>'..with my blade raised and my soul bare..' </br>'..let you judge my verdict, and find it true..' </br>'..and let you guide my hand, O Radiant One.'"
	icon = 'icons/obj/items/donor_weapons_64.dmi'
	icon_state = "ast_kriegmesser"
	sheathe_icon = "bs_swordregal"
