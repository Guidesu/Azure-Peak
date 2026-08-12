// Ported from Twilight-Axis - clothing items that were truly missing from DreamValley.
// Most Twilight-Axis clothing was already ported in extra_wardrobe.dm and
// kazengun_wardrobe.dm. This file contains only the items that were NOT
// already present in any DreamValley file.
//
// Sources:
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/shirts/shirts.dm
//     (etrdress, etrdress2, etrshirt)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/rings.dm
//     (baotha snake ring)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/gloves/leather.dm
//     (elven rider gloves)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/headwear/hats.dm
//     (stewardtophat, twilight_elven_hat, twilight_hammerhold_hat, nunTA,
//      roguehood/bishop, flowercrown/rosa/resprite, soundbreakerhat, antlers,
//      burgerhood, hscarf, duelhat/etrhat)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/mask/mask.dm
//     (dendormask/armored, lordmask/naledi/steel)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/neck/neck.dm
//     (psicross/inhumen/matthios/moneta)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/wrists/wrists.dm
//     (bracers/twilight_elven)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/storage/storage.dm
//     (hammerhold_sash)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/chainmail.dm
//     (hauberk/grenzelhoft, iron/besilked)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/gambeson.dm
//     (steward tailcoat, baotha masquerade, padedetrshirt)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/leather.dm
//     (handjacket, raneshen/new_coat, etrjacket)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/unique.dm
//     (soundbreakerrobe)
//
// Icon paths remapped from modular_twilight_axis/icons/roguetown/clothing/
// to modular_dreamvalley/icons/twilight_clothing/

#define TA_SHIRT_ICON 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
#define TA_SHIRT_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/shirts.dmi'
#define TA_SLEEVES 'modular_dreamvalley/icons/twilight_clothing/onmob/helpers/sleeves_armor.dmi'
#define TA_RING_ICON 'modular_dreamvalley/icons/twilight_clothing/rings.dmi'
#define TA_RING_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/rings.dmi'
#define TA_HEAD_ICON 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
#define TA_HEAD_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/head.dmi'
#define TA_HEAD_48_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/head_48.dmi'
#define TA_HEAD64_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/64x64/head.dmi'
#define TA_GLOVES_ICON 'modular_dreamvalley/icons/twilight_clothing/gloves.dmi'
#define TA_GLOVES_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/gloves.dmi'
#define TA_MASK_ICON 'modular_dreamvalley/icons/twilight_clothing/masks.dmi'
#define TA_MASK_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/masks.dmi'
#define TA_NOBLE_ICON 'modular_dreamvalley/icons/twilight_clothing/special/noble.dmi'
#define TA_NOBLE_ONMOB 'modular_dreamvalley/icons/twilight_clothing/special/onmob/noble.dmi'
#define TA_ARMOR_ICON 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
#define TA_ARMOR_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/armor.dmi'
#define TA_ARMOR_32_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/32x48/armor.dmi'
#define TA_SLEEVES_32 'modular_dreamvalley/icons/twilight_clothing/onmob/helpers/32x48/sleeves_armor.dmi'
#define TA_MASQ_ICON 'modular_dreamvalley/icons/twilight_clothing/masquerade.dmi'
#define TA_MASQ_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/masquerade.dmi'
#define TA_KAZ_ICON 'modular_dreamvalley/icons/twilight_clothing/kazengun_n_burger.dmi'
#define TA_KAZ_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/kazengun_n_burger.dmi'
#define TA_BELT_ICON 'modular_dreamvalley/icons/twilight_clothing/belts.dmi'
#define TA_BELT_ONMOB 'modular_dreamvalley/icons/twilight_clothing/onmob/belts.dmi'

// ============ ETRUSCAN DRESSES & SHIRT ============

/obj/item/clothing/suit/roguetown/shirt/dress/etrdress
	name = "low-cut dress"
	desc = "Despite not actually being made of silk, the legendary expertise needed to sew this puts the quality on par."
	body_parts_covered = CHEST|GROIN|ARMS|VITALS
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	icon_state = "etrdress1"
	item_state = "etrdress1"
	icon = TA_SHIRT_ICON
	mob_overlay_icon = TA_SHIRT_ONMOB
	sleevetype = null
	sleeved = null
	flags_inv = HIDECROTCH|HIDEBOOB
	allowed_sex = list(FEMALE)
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/suit/roguetown/shirt/dress/etrdress2
	name = "embroidered dress"
	desc = "Despite not actually being made of silk, the legendary expertise needed to sew this puts the quality on par."
	body_parts_covered = CHEST|GROIN|ARMS|VITALS
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	icon_state = "etrdress2"
	item_state = "etrdress2"
	icon = TA_SHIRT_ICON
	mob_overlay_icon = TA_SHIRT_ONMOB
	sleeved = TA_SLEEVES
	flags_inv = HIDECROTCH|HIDEBOOB
	allowed_sex = list(FEMALE)
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/suit/roguetown/shirt/undershirt/etrshirt
	name = "low-cut shirt"
	desc = "A tunic exposing much of the neck and shoulders. How scandalous..."
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	icon_state = "etrshirt"
	icon = TA_SHIRT_ICON
	mob_overlay_icon = TA_SHIRT_ONMOB
	sleeved = TA_SLEEVES

// ============ BAOTHA SNAKE RING ============

/obj/item/clothing/ring/baotha
	name = "snake ring"
	desc = "The ring is made of steel with gilding, and it is artfully recreated as a snake. The quality of the work is so high that it feels as if the snake's gem-filled eyes are watching you."
	icon_state = "baotha_knife"
	icon = TA_RING_ICON
	mob_overlay_icon = TA_RING_ONMOB
	max_integrity = 300
	var/realname
	var/realdesc
	var/realstate
	var/realicon
	var/baotha_disguised = FALSE
	var/disguise_state

	grid_width = 32
	grid_height = 32

/obj/item/clothing/ring/baotha/Initialize()
	. = ..()
	realname = name
	realdesc = desc
	realstate = icon_state
	realicon = icon

/obj/item/clothing/ring/baotha/examine(var/mob/living/carbon/human/user)
	. = ..()
	if(iscarbon(user))
		if(user.patron?.type == /datum/patron/inhumen/baotha)
			. += ("This creature is a small gift from my patron, and I can make it take any form I desire.")

/obj/item/clothing/ring/baotha/attack_right(var/mob/living/carbon/human/user)
	if(user.patron?.type == /datum/patron/inhumen/baotha)
		var/mimicry = list("gold ring", "silver ring", "bronze ring", "Undo")
		var/mimicry_choise = input("Variants:", "camouflage") as anything in mimicry
		switch(mimicry_choise)
			if("gold ring")
				name = "gold ring"
				desc = "A ring of golden beauty."
				disguise_state = "ring_g"
				icon_state = disguise_state
				baotha_disguised = TRUE
			if("silver ring")
				name = "silver ring"
				desc = "A ring of silvered glimmerance."
				disguise_state = "ring_s"
				icon_state = disguise_state
				baotha_disguised = TRUE
			if("bronze ring")
				name = "bronze ring"
				desc = "A ring of bronzen resilience."
				disguise_state = "ring_b"
				icon_state = disguise_state
				baotha_disguised = TRUE
			if("Undo")
				name = realname
				desc = realdesc
				icon = realicon
				icon_state = realstate
				disguise_state = null
				baotha_disguised = FALSE
		update_icon()
		user.update_inv_wear_id()

/obj/item/clothing/ring/baotha/attack_self(var/mob/living/carbon/human/user)
	if(user.patron?.type == /datum/patron/inhumen/baotha)
		if(do_after(user, 10, target = src))
			var/obj/item/rogueweapon/huntingknife/idagger/steel/baotha/S = new/obj/item/rogueweapon/huntingknife/idagger/steel/baotha(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(S)
			qdel(src)
			playsound(user, pick('sound/magic/magic_nulled.ogg'), 20, TRUE)
		else
			to_chat(user, span_notice("I am losing concentration!"))

/obj/item/clothing/ring/baotha/update_icon()
	. = ..()
	if(baotha_disguised && disguise_state)
		icon_state = disguise_state
	else
		icon_state = realstate

/obj/item/clothing/ring/baotha/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/clothing/ring/baotha/equipped(mob/user, slot)
	. = ..()
	update_icon()

// ============ ELVEN RIDER GLOVES ============

/obj/item/clothing/gloves/roguetown/angle/twilight_elven
	name = "elven rider gloves"
	desc = "Comfortable leather gloves, reinforced with metal plates for extra protection. Crafted by elven masters, based on a design lost to ages."
	icon_state = "elven_gloves"
	item_state = "elven_gloves"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = TA_GLOVES_ICON
	mob_overlay_icon = TA_GLOVES_ONMOB
	color = null

// ============ ELVEN RIDER BRACERS ============

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven
	name = "elven rider bracers"
	desc = "Elegant steel bracers, meant to protect the wearer's wrists from cutting attacks. Their sleek design marks them as a product of elven craftsmanship."
	icon_state = "elven_armplates"
	item_state = "elven_armplates"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = TA_GLOVES_ICON
	mob_overlay_icon = TA_GLOVES_ONMOB
	sleeved = TA_GLOVES_ONMOB
	alternate_worn_layer = WRISTS_LAYER

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven/equipped(mob/user, slot)
	. = ..()
	user.update_inv_wrists()
	user.update_inv_gloves()
	user.update_inv_armor()
	user.update_inv_shirt()

// ============ HEADWEAR ============

/obj/item/clothing/head/roguetown/stewardtophat
	name = "top hat"
	icon_state = "stewardtophat"
	icon = TA_NOBLE_ICON
	mob_overlay_icon = TA_NOBLE_ONMOB
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/twilight_elven_hat
	name = "elven burka"
	desc = "A warm hat, designed to protect long elven ears from cold winds of the northern lands."
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_48_ONMOB
	icon_state = "elven_hat"
	flags_inv = HIDEEARS

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat
	name = "kokoshnik"
	desc = ""
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_48_ONMOB
	icon_state = "white_mage_headwear"
	flags_inv = HIDEEARS
	var/hammerhold_colors = list("white", "blue")
	var/hammerhold_variants = null
	var/picked = FALSE
	var/hammerhold_final_icon = null

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat/attack_right(mob/user)
	..()
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			icon_state = "white_mage_headwear"
		if(choiceC == "blue")
			icon_state = "blue_mage_headwear"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your kokoshnik?", "Kokoshnik", "Yes", "No") != "Yes")
			icon_state = "white_mage_headwear"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return
		picked = TRUE

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat/peasant
	name = "hammerhold hat"
	desc = ""
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_48_ONMOB
	icon_state = "headwear_a"
	flags_inv = HIDEEARS
	hammerhold_colors = null
	hammerhold_variants = list("a", "b")
	picked = FALSE

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat/peasant/attack_right(mob/user)
	if(!picked)
		var/choiceV = input(user, "Choose a variant.", "Hammerhold colors") as anything in hammerhold_variants
		if(choiceV == "a")
			icon_state = "headwear_a"
			hammerhold_final_icon = "headwear_a"
		if(choiceV == "b")
			icon_state = "headwear_b"
			hammerhold_final_icon = "headwear_b"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your hat?", "hat", "Yes", "No") != "Yes")
			icon_state = "headwear_a"
			hammerhold_final_icon = "headwear_a"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return
		picked = TRUE

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat/equipped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/head/roguetown/twilight_hammerhold_hat/dropped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/head/roguetown/nunTA
	name = "nun hood"
	desc = ""
	icon_state = "nun_hood"
	item_state = "nun_hood"
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_ONMOB
	slot_flags = ITEM_SLOT_HEAD
	flags_inv = HIDEEARS

/obj/item/clothing/head/roguetown/nunTA/MiddleClick(mob/user)
	if(!ishuman(user))
		return
	if(flags_inv & HIDE_HEADTOP)
		flags_inv &= ~HIDE_HEADTOP
	else
		flags_inv |= HIDE_HEADTOP
	user.update_inv_head()

/obj/item/clothing/head/roguetown/roguehood/bishop
	name = "bishop hood"
	desc = ""
	color = null
	icon_state = "bishop_hood"
	item_state = "bishop_hood"
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_ONMOB
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	max_integrity = 180
	resistance_flags = FIRE_PROOF
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1

/obj/item/clothing/head/roguetown/roguehood/bishop/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CHOSEN, "VISAGE")

/obj/item/flowercrown/rosa/resprite
	name = "crown of eora flowers"
	desc = ""
	item_state = "flower_crown_eora"
	icon_state = "flower_crown_eora"
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_ONMOB

/obj/item/clothing/head/roguetown/bardhat/soundbreakerhat
	name = "soundbreaker hat"
	desc = "An oddly shaped hat made of tightly-sewn leather, commonly worn by soundbreakers."
	color = CLOTHING_RED

/obj/item/clothing/head/roguetown/antlers
	name = "old antlers"
	desc = "Old antlers which you can wear on helmet, hood....or straight on your head!"
	icon_state = "antlers"
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_48_ONMOB
	alternate_worn_layer = 8.9
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_NECK
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	var/rogavid = list("halo", "knighty")
	var/antlers_final_icon = null

/obj/item/clothing/head/roguetown/antlers/attack_right(mob/user)
	..()
	if(!picked)
		var/chooseA = input(user, "What will you choose?", "Where you got it?") as anything in rogavid
		if(chooseA == "halo")
			icon_state = "antlers"
			antlers_final_icon = "antlers"
		if(chooseA == "knighty")
			icon_state = "antlers_knighty"
			antlers_final_icon = "antlers_knighty"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your antlers?", "Antlers", "Yes", "No") != "Yes")
			icon_state = "antlers"
			antlers_final_icon = "antlers"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return
		picked = TRUE

/obj/item/clothing/head/roguetown/antlers/equipped(mob/user, slot)
	. = ..()
	if(antlers_final_icon)
		icon_state = antlers_final_icon
		item_state = antlers_final_icon
		update_icon()

/obj/item/clothing/head/roguetown/antlers/dropped(mob/user, slot)
	. = ..()
	if(antlers_final_icon)
		icon_state = antlers_final_icon
		item_state = antlers_final_icon
		update_icon()

/obj/item/clothing/head/roguetown/roguehood/burgerhood
	name = "noble hood"
	desc = "A silken hood denoting the high status of its wearer."
	color = null
	icon_state = "burgerhood"
	item_state = "burgerhood"
	icon = TA_KAZ_ICON
	mob_overlay_icon = TA_KAZ_ONMOB
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	detail_tag = "_detail"
	dynamic_hair_suffix = ""
	edelay_type = 1
	adjustable = CAN_CADJUST
	color = "#de5013"
	detail_color = "#e3ab12"
	toggle_icon_state = TRUE
	max_integrity = 180
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1

/datum/crafting_recipe/roguetown/sewing/burgerhood
	name = "noble hood"
	category = "Hoods"
	result = list(/obj/item/clothing/head/roguetown/roguehood/burgerhood)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 3

/obj/item/clothing/head/roguetown/hscarf
	desc = "A silken headband often found on the heads of sailors and pirates."
	name = "head scarf"
	icon_state = "headscarf"
	item_state = "headscarf"
	icon = TA_KAZ_ICON
	mob_overlay_icon = TA_KAZ_ONMOB
	salvage_result = /obj/item/natural/silk

/datum/crafting_recipe/roguetown/sewing/hscarf
	name = "head scarf"
	category = "Hoods"
	result = list(/obj/item/clothing/head/roguetown/hscarf)
	reqs = list(/obj/item/natural/silk = 4)
	tools = list(/obj/item/needle)
	craftdiff = 2

/obj/item/clothing/head/roguetown/duelhat/etrhat
	name = "wanderer's hat"
	desc = "A comfortable hat that will make you look elegant and protect you from the weather."
	icon = TA_HEAD_ICON
	mob_overlay_icon = TA_HEAD_ONMOB
	icon_state = "etrhat"
	item_state = "etrhat"
	color = null

/obj/item/clothing/head/roguetown/grenzelhofthat/decorated
	armor = null

// ============ MASK SUBTYPES ============

/obj/item/clothing/head/roguetown/dendormask/armored
	max_integrity = 200
	armor = ARMOR_PLATE

/obj/item/clothing/mask/rogue/lordmask/naledi/steel
	max_integrity = 200
	sellprice = 0

// ============ NECK: MATTHIOS MONETA AMULET ============
// Already ported in extra_wardrobe.dm as psicross/morwenna/matthios/moneta
// (DreamValley remaps inhumen/matthios to morwenna/matthios)

// ============ STORAGE: HAMMERHOLD SASH ============

/obj/item/storage/belt/rogue/leather/hammerhold_sash
	name = "hammerhold sash"
	icon = TA_BELT_ICON
	mob_overlay_icon = TA_BELT_ONMOB
	icon_state = "hammerhold_sash"
	detail_tag = "_belt"

// ============ ARMOR: GRENZELHOFT HAUBERK ============

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft
	name = "grenzelhoftian hip-shirt w/hauberk"
	desc = "A maille-aketon of steel layered atop a vividly adorned Grenzelhoftian padded hip-shirt, uniting bold fashion with steadfast protection."
	icon_state = "grenzelhauberk"
	item_state = "grenzelhauberk"
	icon = TA_ARMOR_ICON
	mob_overlay_icon = TA_ARMOR_ONMOB
	sleeved = TA_SLEEVES
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	detail_color = "#1d1d22"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL + 10

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

	if(get_altdetail_tag())
		var/mutable_appearance/pic2 = mutable_appearance(icon(icon, "[icon_state][altdetail_tag]"))
		pic2.appearance_flags = RESET_COLOR
		if(get_altdetail_color())
			pic2.color = get_altdetail_color()
		add_overlay(pic2)

// ============ ARMOR: IRON BESILKED HAUBERGEON ============

/obj/item/clothing/suit/roguetown/armor/chainmail/iron/besilked
	name = "iron besilked haubergeon"
	desc = "A maille shirt fashioned from hundreds of interlinked iron rings."
	armor_class = ARMOR_CLASS_LIGHT

/obj/item/clothing/suit/roguetown/armor/chainmail/iron/besilked/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)

// ============ ARMOR: STEWARD TAILCOAT ============

/obj/item/clothing/suit/roguetown/armor/gambeson/steward
	name = "steward tailcoat"
	desc = "A thick, pristine leather tailcoat adorned with polished bronze buttons."
	sleeved = TA_NOBLE_ONMOB
	icon_state = "stewardtailcoat"
	item_state = "stewardtailcoat"
	icon = TA_NOBLE_ICON
	mob_overlay_icon = TA_NOBLE_ONMOB

// ============ ARMOR: BAOTHA MASQUERADE ============

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha
	name = "masquerade"
	desc = "writhing rags, woven from mutilated human faces, in constant agony intertwined with narcotic ecstasy. They say the previous owner of this item has gone missing, but where?.. And whos saying that?.."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon = TA_MASQ_ICON
	mob_overlay_icon = TA_MASQ_ONMOB
	icon_state = "skinrobe"
	item_state = "skinrobe"
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	salvage_result = /obj/item/reagent_containers/lux
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE + 200
	armor = ARMOR_BRIGANDINE
	auto_repair_mode = TRUE
	relative_repair_interval = 15 SECONDS
	interrupt_damount = 15
	var/realname
	var/realdesc
	var/realstate
	var/active_item = FALSE

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha/Initialize()
	.=..()
	realname = name
	realdesc = desc
	realstate = icon_state
	AddComponent(/datum/component/cursed_item, TRAIT_CRACKHEAD, "CLOTH")

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha/examine(var/mob/living/carbon/human/user)
	. = ..()
	if(iscarbon(user))
		if(user.patron?.type == /datum/patron/inhumen/baotha)
			. += ("This creature is a small gift from my patron, and I can make it take any form I desire.")

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha/equipped(mob/living/user, slot)
	. = ..()
	if(active_item)
		return
	if(slot == SLOT_SHIRT || slot == SLOT_ARMOR)
		active_item = TRUE
		ADD_TRAIT(user, TRAIT_BITERHELM, TRAIT_GENERIC)

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha/dropped(mob/living/user)
	..()
	if(!active_item)
		return
	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_BITERHELM, TRAIT_GENERIC)

/obj/item/clothing/suit/roguetown/armor/regenerating/baotha/attack_right(var/mob/living/carbon/human/user)
	if(user.patron?.type == /datum/patron/inhumen/baotha)
		var/mimicry = list("shirt", "formal silks", "rags", "tunic", "dress", "silky dress", "undervestments", "royal gown", "white foreign shirt", "silk shirt", "fancy coat", "low cut tunic", "pristine dress", "gilded dress shirt", "Undo")
		var/mimicry_choise = input("Variants:", "camouflage") as anything in mimicry
		switch(mimicry_choise)
			if("shirt")
				name = "shirt"
				desc = "Modest and humble. It lets you walk around in public with your dignity intact."
				icon_state = "undershirt"
			if("formal silks")
				name = "formal silks"
				desc = "Modest and humble. It lets you walk around in public with your dignity intact."
				icon_state = "puritan_shirt"
			if("rags")
				name = "rags"
				desc = "From rags to... nope, still rags."
				icon_state = "rags"
			if("tunic")
				name = "tunic"
				desc = "Modest and fashionable, with the right colors."
				icon_state = "tunic"
			if("dress")
				name = "dress"
				desc = "A simple dress worn by women and the bold."
				icon_state = "dress"
			if("silky dress")
				name = "silky dress"
				desc = "Despite not actually being made of silk, the legendary expertise needed to sew this puts the quality on par."
				icon_state = "silkydress"
			if("undervestments")
				name = "undervestments"
				desc = "A soft garment designed to prevent chafing from wearing heavy robes all day and night."
				icon_state = "priestunder"
			if("royal gown")
				name = "royal gown"
				desc = "An elaborate ball gown, a favoured fashion of queens and elevated nobility."
				icon_state = "royaldress"
			if("white foreign shirt")
				name = "white foreign shirt"
				desc = "A shirt typically used by foreign gangs."
				icon_state = "eastshirt2"
			if("silk shirt")
				name = "silk shirt"
				desc = "A sleeveless shirt woven from glossy material."
				icon_state = "webs"
			if("fancy coat")
				name = "fancy coat"
				desc = "A fancy tunic and coat combo. How elegant."
				icon_state = "noblecoat"
			if("low cut tunic")
				name = "low cut tunic"
				desc = "A tunic exposing much of the neck and... shoulders?! How scandalous..."
				icon_state = "lowcut"
			if("pristine dress")
				name = "pristine dress"
				desc = "A flowy, intricate dress made by the finest tailors in the land for the monarch's children."
				icon_state = "princess"
			if("gilded dress shirt")
				name = "gilded dress shirt"
				desc = "A gold-embroidered dress shirt specially tailored for the monarch's children."
				icon_state = "prince"
			if("Undo")
				name = realname
				desc = realdesc
				icon_state = realstate

		if(loc == user)
			user.update_inv_armor()
			user.update_inv_shirt()

		playsound(user, pick('sound/magic/magic_nulled.ogg'), 20, TRUE)

// ============ ARMOR: PADDED ETRUSCAN SHIRT ============

/obj/item/clothing/suit/roguetown/shirt/padedetrshirt
	name = "padded etruscan shirt"
	desc = "A strong loosely worn quilted shirt that places little weight on the arms."
	icon = TA_SHIRT_ICON
	mob_overlay_icon = TA_SHIRT_ONMOB
	sleeved = TA_SLEEVES
	allowed_race = NON_DWARVEN_RACE_TYPES
	boobed = FALSE
	body_parts_covered = COVERAGE_ALL_BUT_HANDLEGS
	icon_state = "etrrubaha"
	color = "#FFFFFF"
	var/shiftable = FALSE
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 35
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	detail_tag = "_detail"
	detail_color = CLOTHING_WHITE

/obj/item/clothing/suit/roguetown/shirt/padedetrshirt/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/shirt/padedetrshirt/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/positive, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)

// ============ ARMOR: NOBLE JACKET (handjacket) ============

/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket/handjacket
	name = "noble jacket"
	icon_state = "handcoat"
	icon = TA_NOBLE_ICON
	mob_overlay_icon = TA_NOBLE_ONMOB
	sleeved = TA_NOBLE_ONMOB
	detail_tag = "_detail"
	detail_color = CLOTHING_BLACK
	body_parts_covered = COVERAGE_SHIRT

/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket/handjacket/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket/handjacket/lordcolor(primary,secondary)
	detail_color = primary
	update_icon()

/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket/handjacket/Initialize()
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	else
		GLOB.lordcolor += src

/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket/handjacket/Destroy()
	GLOB.lordcolor -= src
	return ..()

// ============ ARMOR: RANESHENI SCALE COAT ============

/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/raneshen/new_coat
	name = "ranesheni scale coat"
	desc = "A lightweight armor made from the scales of the Ranesheni \"megarmach\", an armored reptilian creature that ambushes prey by the riverside, and drags them deep into Abyssor's domain."
	icon = TA_ARMOR_ICON
	mob_overlay_icon = TA_ARMOR_32_ONMOB
	sleeved = TA_SLEEVES_32
	icon_state = "light_armour"
	item_state = "light_armour"
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET

// ============ ARMOR: WANDERER'S JACKET ============

/obj/item/clothing/suit/roguetown/armor/leather/etrjacket
	name = "wanderer's jacket"
	desc = "A comfortable jacket, more suitable for court receptions than for hiking in the swamps."
	sleeved = TA_NOBLE_ONMOB
	icon_state = "etrjacket"
	item_state = "etrjacket"
	icon = TA_SHIRT_ICON
	mob_overlay_icon = TA_SHIRT_ONMOB
	allowed_race = NON_DWARVEN_RACE_TYPES
	armor = null

// ============ ARMOR: SOUNDBREAKER ROBES ============

/obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe/soundbreakerrobe
	slot_flags = ITEM_SLOT_ARMOR
	name = "soundbreaker robes"
	desc = "A set of reinforced, leather-padded robes worn by soundbreakers."
	color = CLOTHING_RED
	icon_state = "soundbreaker"
	icon = TA_ARMOR_ICON
	mob_overlay_icon = TA_ARMOR_ONMOB
	body_parts_covered = CHEST | GROIN | LEGS | ARMS

#undef TA_SHIRT_ICON
#undef TA_SHIRT_ONMOB
#undef TA_SLEEVES
#undef TA_RING_ICON
#undef TA_RING_ONMOB
#undef TA_HEAD_ICON
#undef TA_HEAD_ONMOB
#undef TA_HEAD_48_ONMOB
#undef TA_HEAD64_ONMOB
#undef TA_GLOVES_ICON
#undef TA_GLOVES_ONMOB
#undef TA_MASK_ICON
#undef TA_MASK_ONMOB
#undef TA_NOBLE_ICON
#undef TA_NOBLE_ONMOB
#undef TA_ARMOR_ICON
#undef TA_ARMOR_ONMOB
#undef TA_ARMOR_32_ONMOB
#undef TA_SLEEVES_32
#undef TA_MASQ_ICON
#undef TA_MASQ_ONMOB
#undef TA_KAZ_ICON
#undef TA_KAZ_ONMOB
#undef TA_BELT_ICON
#undef TA_BELT_ONMOB
