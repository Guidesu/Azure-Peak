// Ported from Twilight-Axis's church_classes/spellblade module. All
// player-facing text translated from Russian into English. These are the
// ephemeral "moonlight weapons" the Newmoon Spellblade conjures via
// spellblade_summon_weapon (see spells.dm) — they despell a few minutes
// after being drawn, or immediately if dropped.

/obj/item/rogueweapon/sword/sabre/moonlight_sabre
	name = "moonlight sabre"
	desc = "A sabre woven from Noc's light, seeming fragile, but keenly edged. An ideal slashing weapon."
	force = 25
	wdefense = 6
	icon_state = "moonlight_saber"
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/prismatic_weapons64.dmi'
	possible_item_intents = list(/datum/intent/sword/cut/sabre, /datum/intent/sword/thrust/sabre, /datum/intent/sword/strike)
	bigboy = TRUE
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	max_integrity = 50
	max_blade_int = 500
	smeltresult = null
	is_silver = TRUE
	minstr = 1
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null
	var/mob/living/carbon/human/owner

/obj/item/rogueweapon/sword/rapier/moonlight_rapier
	name = "moonlight rapier"
	desc = "A rapier woven from Noc's light, seeming fragile, but keenly edged. An ideal dueling weapon."
	icon_state = "moonlight_rapier"
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/prismatic_weapons64.dmi'
	sheathe_icon = "rapier"
	possible_item_intents = list(/datum/intent/sword/thrust/rapier, /datum/intent/sword/cut/rapier)
	special = /datum/special_intent/piercing_lunge
	max_integrity = 50
	max_blade_int = 500
	force = 25
	force_wielded = 20
	wdefense = 8
	smeltresult = null
	is_silver = TRUE
	minstr = 1
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null
	var/mob/living/carbon/human/owner

/obj/item/rogueweapon/spear/partizan/moonlight_spear
	name = "moonlight spear"
	desc = "A spear woven from Noc's light, seeming fragile, but keenly edged. An ideal weapon in tight spaces."
	force = 25
	force_wielded = 35
	max_blade_int = 250
	possible_item_intents = list(SPEAR_THRUST_1H, /datum/intent/spear/bash)
	gripped_intents = list(/datum/intent/spear/thrust, /datum/intent/rend/reach/partizan, /datum/intent/spear/bash)
	icon_state = "moonlight_spear"
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/prismatic_weapons64.dmi'
	max_integrity = 50
	bigboy = 1
	wlength = WLENGTH_LONG
	associated_skill = /datum/skill/combat/polearms
	smeltresult = null
	throwforce = 24
	is_silver = TRUE
	minstr = 1
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null
	var/mob/living/carbon/human/owner

/obj/item/rogueweapon/mace/maul/grand/moonlight_hammer
	name = "moonlight hammer"
	desc = "A hammer woven from Noc's light, seeming heavy, but light in the hand. An ideal weapon of brute force."
	icon_state = "moonlight_hammer"
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/prismatic_weapons64.dmi'
	force_wielded = 28
	max_integrity = 50
	smeltresult = null
	minstr = 1
	is_silver = TRUE
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null
	var/mob/living/carbon/human/owner

/obj/item/rogueweapon/shield/bronze/great/moonlight_shield
	name = "moonlight shield"
	desc = "A shield woven from Noc's light, seeming heavy, but light in the hand; its structure resembles crystal, and is likely just as fragile."
	icon_state = "moonlight_shield"
	icon = 'modular_dreamvalley/icons/newmoon_spellblade/prismatic_weapons64.dmi'
	max_integrity = 100
	possible_item_intents = list(/datum/intent/shield/block, /datum/intent/mace/smash/shield/metal/great, /datum/intent/effect/daze)
	force = 15
	minstr = 1
	bigboy = 1
	smeltresult = null
	is_silver = TRUE
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null
	var/mob/living/carbon/human/owner

/obj/item/rogueweapon/shield/bronze/great/moonlight_shield/Move()
	if(!istype(loc, /mob/living/carbon/human))
		qdel(src)
	return ..()

/obj/item/rogueweapon/mace/maul/grand/moonlight_hammer/Move()
	if(!istype(loc, /mob/living/carbon/human))
		qdel(src)
	return ..()

/obj/item/rogueweapon/spear/partizan/moonlight_spear/Move()
	if(!istype(loc, /mob/living/carbon/human))
		qdel(src)
	return ..()

/obj/item/rogueweapon/sword/rapier/moonlight_rapier/Move()
	if(!istype(loc, /mob/living/carbon/human))
		qdel(src)
	return ..()

/obj/item/rogueweapon/sword/sabre/moonlight_sabre/Move()
	if(!istype(loc, /mob/living/carbon/human))
		qdel(src)
	return ..()


/obj/item/rogueweapon/shield/bronze/great/moonlight_shield/Destroy()
	to_chat(owner, "[src] dissolves into the air. Noc takes the knowledge of it with her.")
	owner.adjust_skillrank_down_to(associated_skill, 0, TRUE)
	playsound(get_turf(owner), 'modular_dreamvalley/sound/newmoon_spellblade/despell_sfx.ogg', 100, FALSE)
	return ..()

/obj/item/rogueweapon/mace/maul/grand/moonlight_hammer/Destroy()
	to_chat(owner, "[src] dissolves into the air. Noc takes the knowledge of it with her.")
	owner.adjust_skillrank_down_to(associated_skill, 0, TRUE)
	playsound(get_turf(owner), 'modular_dreamvalley/sound/newmoon_spellblade/despell_sfx.ogg', 100, FALSE)
	return ..()

/obj/item/rogueweapon/spear/partizan/moonlight_spear/Destroy()
	to_chat(owner, "[src] dissolves into the air. Noc takes the knowledge of it with her.")
	owner.adjust_skillrank_down_to(associated_skill, 0, TRUE)
	playsound(get_turf(owner), 'modular_dreamvalley/sound/newmoon_spellblade/despell_sfx.ogg', 100, FALSE)
	return ..()

/obj/item/rogueweapon/sword/rapier/moonlight_rapier/Destroy()
	to_chat(owner, "[src] dissolves into the air. Noc takes the knowledge of it with her.")
	owner.adjust_skillrank_down_to(associated_skill, 0, TRUE)
	playsound(get_turf(owner), 'modular_dreamvalley/sound/newmoon_spellblade/despell_sfx.ogg', 100, FALSE)
	return ..()

/obj/item/rogueweapon/sword/sabre/moonlight_sabre/Destroy()
	to_chat(owner, "[src] dissolves into the air. Noc takes the knowledge of it with her.")
	owner.adjust_skillrank_down_to(associated_skill, 0, TRUE)
	playsound(get_turf(owner), 'modular_dreamvalley/sound/newmoon_spellblade/despell_sfx.ogg', 100, FALSE)
	return ..()
