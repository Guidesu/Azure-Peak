// Ported from Twilight-Axis - missing clothing items not already present in DreamValley.
// Sources:
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/plate.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/brigandine.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/pants/cloth.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/pants/chain.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/mask/mask.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/neck/neck.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/headwear/helmet/medium_helmet.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/headwear/helmet/heavy_helmet.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/cloaks/cloaks.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/feet/feet.dm
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/shirts/shirts.dm
//   - modular_deserttown/desertclothing.dm
//
// Adaptation notes:
// - Icon paths changed from modular_twilight_axis/icons/roguetown/clothing/ to
//   modular_dreamvalley/icons/twilight_clothing/ and special subdirs to
//   modular_dreamvalley/icons/twilight_special/.
// - Desert icon paths (modular_deserttown/icons/clothing/) mapped to
//   modular_dreamvalley/icons/twilight_clothing/ equivalents.
// - mob_overlay_icon lines referencing onmob directories that don't exist in
//   DreamValley have been removed; the icon file itself is used as fallback.
// - sleeved paths referencing modular_twilight_axis helper dirs changed to
//   native DreamValley paths where they exist; otherwise removed.
// - Deity names updated to DreamValley equivalents:
//   Astrata->Auxentius, Noc->Miluse, Psydon->Vaeltian, Eora->Trnva,
//   Baotha->Hausvette, Ravox stays, Necra->Morwenna, Matthios stays.
// - Items already existing in DreamValley base code (shadowplate, xylixmask at
//   /rogue/xylixmask, yoruku_oni, yoruku_kitsune, bell_collar, cursed_collar,
//   townguard, sheriff, cataphract, sultan, baotha_ta plate) were skipped.
// - psicross/inhumen/matthios/moneta remapped to psicross/morwenna/matthios/moneta
//   to match DreamValley's psicross tree structure.

//====================================================================
// Armor - Plate
//====================================================================

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/fencer/twilight_elven
	name = "elven rider cuirass"
	desc = "An expertly smithed form-fitting steel cuirass that is much lighter and agile, but breaks with much more ease. Its sleek design marks it as a product of elven craftsmanship."
	icon_state = "elven_chestplate"
	item_state = "elven_chestplate"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'

/obj/item/clothing/suit/roguetown/armor/plate/raneshen_scale
	slot_flags = ITEM_SLOT_ARMOR
	name = "ranesheni scalemail"
	desc = "Armor used by the Empire's vanguard fighters. The plates are connected to each other with cord for mobility. The arms are protected by pauldrons, and the legs by a small chainmail skirt. The armor itself is decorated with bronze."
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
	icon_state = "medium_armour"
	item_state = "medium_armour"
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	allowed_sex = list(MALE, FEMALE)
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	equip_delay_self = 4 SECONDS
	armor_class = ARMOR_CLASS_MEDIUM
	smelt_bar_num = 2

/obj/item/clothing/suit/roguetown/armor/plate/full/raneshen_plated
	name = "ranesheni plate armor"
	desc = "Full-fledged armor with scales, a light chainmail skirt protects the lower legs, has bronze decorations and strong protective shoulder pads."
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
	icon_state = "heavy_armour"
	item_state = "heavy_armour"
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	equip_delay_self = 12 SECONDS
	unequip_delay_self = 12 SECONDS
	equip_delay_other = 3 SECONDS
	strip_delay = 6 SECONDS
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	smelt_bar_num = 4
	armor_class = ARMOR_CLASS_HEAVY

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/etrcuirass
	name = "etruscan cuirass"
	icon_state = "etrcuirass"
	desc = "A steel cuirass, fine fitted with tassets for additional coverage. Typically seen on Etruscan heavy infantry."
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
	body_parts_covered = CHEST | VITALS | LEGS | NECK
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	detail_color = "#FFFFFF"
	detail_tag = "_detail"
	boobed = FALSE
	detail_color = CLOTHING_WHITE
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/etrcuirass/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/armor/plate/twilight_shadowplate
	name = "scourge half-plate"
	desc = "As close as most Dark Elves are willing to get to actual plate armor. This set consists of an avantyne cuirass and pauldrons with an underlying layer of sturdy Drow-crafted leather."
	icon_state = "shadowplate"
	item_state = "shadowplate"
	allowed_race = NON_DWARVEN_RACE_TYPES
	smeltresult = /obj/item/ingot/drow
	smelt_bar_num = 2
	body_parts_covered = COVERAGE_ALL_BUT_HANDLEGS

//====================================================================
// Armor - Baotha_ta set (helmet, coif, gambeson, bracers, skirt, gauntlets, boots)
// The plate piece is already ported in kazengun_wardrobe.dm.
//====================================================================

/obj/item/clothing/head/roguetown/helmet/baotha_ta
	name = "saccharine sallet"
	desc = "Lo', the twins of beauty; Trnva and Belladoth, they sought a prize which but one may have.."
	icon_state = "baothahelm"
	item_state = "baothahelm"
	body_parts_covered = HEAD | HAIR | EARS | MOUTH | EYES
	armor_class = ARMOR_CLASS_LIGHT
	max_integrity = ARMOR_INT_HELMET_ANTAG - 250
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/head/roguetown/helmet/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "HELMET")

/obj/item/clothing/head/roguetown/helmet/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/neck/roguetown/coif/baotha_ta
	name = "saccharine veil"
	desc = "And yet, their methods differed; Belladoth proposed with Her lust and temptation, Trnva with Her love and warmth.."
	icon_state = "baothacoif"
	item_state = "baothacoif"
	armor = ARMOR_MAILLE
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	body_parts_covered = NECK | HAIR | EARS | HEAD | NOSE
	armor_class = ARMOR_CLASS_LIGHT
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	resistance_flags = FIRE_PROOF
	blocksound = SOFTHIT
	color = null
	chunkcolor = "#645567"
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/neck/roguetown/coif/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "VEIL")
	AddComponent(/datum/component/adjustable_clothing, NECK, null, null, 'sound/foley/cloth_wipe (1).ogg', null, (UPD_HEAD|UPD_MASK|UPD_NECK))
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/neck/roguetown/coif/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/neck/roguetown/coif/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/suit/roguetown/armor/gambeson/baotha_ta
	name = "saccharine vestments"
	desc = "A gemmed chalice, Trnva's own, swilled with Vaeltian's most noxious venoms - and but a simple sip was enough to bring Her to death's door.."
	icon_state = "baothagamb"
	armor_class = ARMOR_CLASS_LIGHT
	armor = ARMOR_BRIGANDINE
	color = null
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	resistance_flags = FIRE_PROOF
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	icon = 'icons/roguetown/clothing/shirts.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_shirts.dmi'
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/suit/roguetown/armor/gambeson/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "VESTMENTS")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/gambeson/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/gambeson/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/wrists/roguetown/bracers/leather/baotha_ta
	name = "saccharine cuffs"
	desc = "A betrayal without compare, and a sin without redemption; or so, She believed.."
	icon_state = "baothabracers"
	chunkcolor = "#6d1c87"
	armor = ARMOR_MAILLE
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/wrists/roguetown/bracers/leather/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "BRACERS")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/wrists/roguetown/bracers/leather/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/wrists/roguetown/bracers/leather/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/under/roguetown/skirt/baotha_ta
	name = "saccharine fauldcoat"
	desc = "Only did Belladona's haze clear, once She heard Trnva's gasps and Ravox's fright; what else could She've done besides fleeing the heavens?"
	armor = ARMOR_MAILLE
	icon_state = "baothaskirt"
	chunkcolor = "#6d1c87"
	resistance_flags = FIRE_PROOF
	armor_class = ARMOR_CLASS_LIGHT
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	body_parts_covered = GROIN | LEGS
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/under/roguetown/skirt/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "SKIRT")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/under/roguetown/skirt/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/under/roguetown/skirt/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/gloves/roguetown/plate/baotha_ta
	name = "saccharine gauntlets"
	desc = "Belladonna's ego died on that dae, and Hausvette's venomous id rose in Her stead; for it was better to numb the regret than to face the guilt.."
	icon_state = "baothagloves"
	item_state = "baothagloves"
	chunkcolor = "#6d1c87"
	max_integrity = ARMOR_INT_SIDE_ANTAG - 250
	armor_class = ARMOR_CLASS_LIGHT
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/gloves/roguetown/plate/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "GLOVES")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/gloves/roguetown/plate/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/gloves/roguetown/plate/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

/obj/item/clothing/shoes/roguetown/boots/armor/baotha_ta
	name = "saccharine heels"
	desc = "..yet, even as She indulges and mourns beneath the stars, one must wonder; is She truly damned by the Pantheon, or by Herself alone?"
	icon_state = "baothaboots"
	item_state = "baothaboots"
	chunkcolor = "#6d1c87"
	max_integrity = ARMOR_INT_SIDE_ANTAG - 200
	armor_class = ARMOR_CLASS_LIGHT
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/shoes/roguetown/boots/armor/baotha_ta/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_HEELS, 2)
	stepnoise_flag = STEPNOISE_HEELS

/obj/item/clothing/shoes/roguetown/boots/armor/baotha_ta/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "BOOTS")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/roguetown/boots/armor/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/shoes/roguetown/boots/armor/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

//====================================================================
// Armor - Brigandine
//====================================================================

/obj/item/clothing/suit/roguetown/armor/brigandine/light/handmade
	slot_flags = ITEM_SLOT_ARMOR
	name = "\"Jack-Of-Plate\" brigandine"
	desc = "This brigandine is an example of the painstaking work of a skilled, and very poor, craftsman. The gambeson, lined with metal parts and scraps of chain mail, is impossible to ruin even with such artistry."
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
	icon_state = "light_brigandine"
	blocksound = SOFTHIT
	body_parts_covered = COVERAGE_TORSO
	armor = ARMOR_PLATE
	max_integrity = ARMOR_INT_CHEST_LIGHT_IRON + ARMOR_INT_CHEST_PLATE_BRIGANDINE_WEIGHT_MODIFIER
	smeltresult = /obj/item/ingot/iron
	equip_delay_self = 40
	armor_class = ARMOR_CLASS_LIGHT
	w_class = WEIGHT_CLASS_BULKY

//====================================================================
// Pants - Cloth
//====================================================================

/obj/item/clothing/under/roguetown/gambeson
	name = "gamboised cuisses"
	desc = "A heavy fabric trousers, stuffed with padding. Protect the legs from blows and weather. Worn under armor or alone."
	icon_state = "gambeson"
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	body_parts_covered = GROIN|LEGS|FEET
	slot_flags = ITEM_SLOT_PANTS
	armor = ARMOR_PADDED
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	color = "#ad977d"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor_class = ARMOR_CLASS_LIGHT
	chunkcolor = "#978151"
	material_category = ARMOR_MAT_LEATHER
	cold_protection = 10

/obj/item/clothing/under/roguetown/gambeson/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/positive, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)

/obj/item/clothing/under/roguetown/gambeson/heavy
	name = "padded gamboised cuisses"
	desc = "A thick, padded cloth trousers, worn beneath armor. A warriors first defense - simple, humble, but vital against bruises and cold."
	icon_state = "gambesonp"
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	color = "#976E6B"

/obj/item/clothing/under/roguetown/trou/leather/etrpants
	name = "wanderer's pants"
	desc = "A pair of comfortable black trousers, a style often found in Etrusca."
	icon_state = "etrpants"
	item_state = "etrpants"
	salvage_result = /obj/item/natural/hide/cured
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	armor_class = ARMOR_CLASS_LIGHT
	armor = ARMOR_LEATHER
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/under/roguetown/trou/leather/etrpants/donat
	armor_class = null

//====================================================================
// Pants - Chain
//====================================================================

/obj/item/clothing/under/roguetown/chainlegs/grenzelhoft
	name = "grenzelhoftian paumpers w/chain chausses"
	desc = "A set of mail chausses forged from interlinked steel rings, worn over vibrant Grenzelhoftian padded paumpers."
	icon_state = "grenzelchain_legs"
	item_state = "grenzelchain_legs"
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	detail_color = "#1d1d22"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_LEG_STEEL_CHAIN + 10

/obj/item/clothing/under/roguetown/chainlegs/grenzelhoft/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/under/roguetown/chainlegs/grenzelhoft/update_icon()
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

/obj/item/clothing/under/roguetown/trou/leather/hakama
	name = "hakama"
	desc = ""
	icon_state = "hakama"
	item_state = "hakama"
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	salvage_result = null

/obj/item/clothing/under/roguetown/chainlegs/twilight_drow
	name = "scourge chain chausses"
	desc = "The Dark Elves rarely don chainmail, preferring much more comfortable leathers and spider silk. Still, it is not unheard of, especially among the shock troops embedded with the raiding parties that venture into the surface world."
	icon_state = "shadowchains"
	item_state = "shadowchains"
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	smeltresult = /obj/item/ingot/drow
	smelt_bar_num = 2

//====================================================================
// Masks
//====================================================================

/obj/item/clothing/mask/rogue/facemask/xylixmask
	name = "xylixian mask"
	desc = "A ceramic mask, forever stuck with the joyful smile its patron god favors. While it will shatter easily from blows, its smug countenance shall taunt its foes."
	max_integrity = 50
	armor = null
	drop_sound = 'sound/foley/brickdrop.ogg'
	pickup_sound = 'sound/foley/brickdrop.ogg'
	icon = 'modular_dreamvalley/icons/twilight_clothing/masks.dmi'
	icon_state = "xylixmask"
	item_state = "xylixmask"
	detail_tag = "_l"
	altdetail_tag = "_r"
	color = "#FFFFFF"
	detail_color = "#4756d8"
	altdetail_color = "#b8252c"
	anvilrepair = /datum/skill/craft/ceramics
	smeltresult = null

/obj/item/clothing/mask/rogue/facemask/xylixmask/Initialize()
	..()
	update_icon()

/obj/item/clothing/mask/rogue/facemask/xylixmask/update_icon()
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

/obj/item/clothing/mask/rogue/facemask/xylixmask/armored
	max_integrity = 200
	armor = ARMOR_PLATE

/obj/item/clothing/mask/rogue/facemask/xylixmask/armored/Initialize()
	..()
	update_icon()

/obj/item/clothing/mask/rogue/facemask/xylixmask/armored/update_icon()
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

/obj/item/clothing/mask/rogue/eyepatch/fake
	desc = "An eyepatch, fitted for the right eye. It has an almost imperceptible gap so that you can see something."
	block2add = null

/obj/item/clothing/mask/rogue/eyepatch/left/fake
	desc = "An eyepatch, fitted for the left eye. It has an almost imperceptible gap so that you can see something."
	block2add = null

/obj/item/clothing/mask/rogue/ragmask/bishop
	name = "bishop mask"
	icon_state = "bishop_mask"
	icon = 'modular_dreamvalley/icons/twilight_clothing/masks.dmi'
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HIP|ITEM_SLOT_HEAD
	experimental_onhip = TRUE
	sewrepair = TRUE
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/rogue/ragmask/bishop/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CHOSEN, "VISAGE")

/obj/item/clothing/mask/rogue/facemask/steel/psythorns
	name = "mask of vaeltian thorns"
	desc = "Expressionless steel mask, decorated with a set of blacksteel thorns. Never forget you are why Vaeltian wept."
	icon = 'modular_dreamvalley/icons/twilight_clothing/masks.dmi'
	icon_state = "psybarbsmask"
	item_state = "psybarbsmask"
	smeltresult = /obj/item/ingot/blacksteel
	armor = ARMOR_PLATE_BSTEEL
	blocksound = PLATEHIT
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	body_parts_covered = FACE|HAIR|HEAD

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_HIP|ITEM_SLOT_MASK
	name = "accursed mask"
	desc = "Mask made from the skull of Volf, detailed with blood of animals and heretics, enchanted with their souls."
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	icon_state = "norswolf"
	item_state = "norswolf"
	var/on = FALSE
	light_color = LIGHT_COLOR_ORANGE
	light_system = MOVABLE_LIGHT
	light_outer_range = 3
	light_power = 1
	toggle_icon_state = TRUE

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch/Initialize(mapload)
	. = ..()
	set_light_on(FALSE)

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch/MiddleClick(mob/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	toggle_helmet_light(user)
	to_chat(user, span_info("I spark [src] [on ? "on" : "off"]."))

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch/proc/toggle_helmet_light(mob/living/user)
	on = !on
	set_light_on(on)
	if(on)
		playsound(loc, 'sound/effects/hood_ignite.ogg', 100, TRUE)
		do_sparks(2, FALSE, user)
	else
		playsound(loc, 'sound/misc/toggle_lamp.ogg', 100)
	update_icon()

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch/update_icon()
	if(on)
		icon_state = "norswolf_lit"
		item_state = "norswolf_lit"
	else
		icon_state = "norswolf"
		item_state = "norswolf"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()
		H.update_inv_wear_mask()
	..()

/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf/wretch/ResetAdjust(mob/user)
	. = ..()
	if(on)
		set_light_on(FALSE)
	update_icon()

/obj/item/clothing/mask/rogue/facemask/etrmask
	name = "conquistador mask"
	desc = "A steel mask replicating the face of a famous Etruscan captain."
	icon_state = "etrmask"
	max_integrity = 200
	smeltresult = /obj/item/ingot/steel
	icon = 'modular_dreamvalley/icons/twilight_clothing/masks.dmi'

//====================================================================
// Neck
//====================================================================

/obj/item/clothing/neck/roguetown/loveamulet
	name = "tears of love amulet"
	desc = "This amulet is made in the southern county of the Black Empire called Sudstal. Faceted with black diamonds, this piece of jewelry symbolizes the pain and sadness that lies beneath the surface of happiness and tranquility."
	icon_state = "loveamulet"
	item_state = "loveamulet"
	icon = 'modular_dreamvalley/icons/twilight_clothing/neck.dmi'

/obj/item/clothing/neck/roguetown/psicross/morwenna/matthios/moneta
	name = "pierced coin amulet"
	desc = "A simple luck charm - a zenny, pierced by a blade and hanging on a thin iron chain. A tiny inscription upon the amulet's edge reads: \u00ABAll tyrants will die alone.\u00BB"
	icon_state = "matthios"
	item_state = "matthios"
	icon = 'modular_dreamvalley/icons/twilight_clothing/neck.dmi'

/obj/item/clothing/neck/roguetown/psicross/morwenna/matthios/moneta/examine(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.patron, /datum/patron/inhumen/matthios))
			desc = "A recognizible charm of Matthios' own - a coin shattered, a symbol the pure rejection of wealth by those who would be oppressed with it. The amulet contains no power of its own, yet as you hold it in the palm of your hand, you can feel the promise of freedom empowering you. A tiny inscription upon the amulet's edge reads: \u00ABAll tyrants will die alone.\u00BB"
		else
			desc = "A simple luck charm - a zenny, pierced by a blade and hanging on a thin iron chain. A tiny inscription upon the amulet's edge reads: \u00ABAll tyrants will die alone.\u00BB"
	. = ..()

/obj/item/clothing/neck/roguetown/psicross/morwenna/matthios/moneta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ODD, "Strange luck charm")

//====================================================================
// Helmets - Medium
//====================================================================

/obj/item/clothing/head/roguetown/helmet/sallet/visored/grenzelhoft
	name = "visored sallet w/plume hat"
	desc = "A Grenzelhoftian plume hat placed atop a steel sallet with an adjustable visor, staying fashionable while guarding the wearer's head with refined practicality. Away with you, vile beggar!"
	icon_state = "grenzelsallet_visor"
	item_state = "grenzelsallet_visor"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	detail_color = "#262927"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_STEEL + 15

/obj/item/clothing/head/roguetown/helmet/sallet/visored/grenzelhoft/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/roguetown/helmet/sallet/visored/grenzelhoft/update_icon()
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

/obj/item/clothing/head/roguetown/helmet/raneshi_jarhelmet
	name = "raneshi jar helmet"
	desc = "a jar-shaped helmet used by Empire light warriors."
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	icon_state = "jar_helmet"
	item_state = "jar_helmet"
	adjustable = CAN_CADJUST
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES
	block2add = FOV_BEHIND
	armor = ARMOR_PLATE
	stack_fovs = TRUE
	smeltresult = /obj/item/ingot/steel
	max_integrity = ARMOR_INT_HELMET_STEEL + 20

/obj/item/clothing/head/roguetown/helmet/raneshi_jarhelmet/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/raneshi_jarhelmet/attackby(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/natural/cloth) && !detail_tag)
		var/choice = input(user, "Choose a color.", "Orle") as anything in COLOR_MAP
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = COLOR_MAP[choice]
		detail_tag = "_detail"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/roguetown/helmet/raneshi_jarhelmet/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/head/roguetown/helmet/sallet/morion
	name = "etruscan morion"
	desc = "The famous Etruscan morion, which can often be seen on sailors and ordinary infantry."
	icon_state = "morion"
	item_state = "morion"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_STEEL + 15
	worn_y_dimension = 30

/obj/item/clothing/head/roguetown/helmet/sallet/morion/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/positive, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/positive, TRAIT_HONORBOUND)

/obj/item/clothing/head/roguetown/helmet/sallet/morion/attackby(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/natural/feather) && !detail_tag)
		var/choice = input(user, "Choose a color.", "Plume") as anything in COLOR_MAP
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = COLOR_MAP[choice]
		detail_tag = "_detailalt"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/roguetown/helmet/sallet/morion/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

//====================================================================
// Helmets - Heavy
//====================================================================

/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle/grenzelhoft
	name = "slitted kettle helm w/plume hat"
	desc = "A Grenzelhoftian plume hat placed atop a reinforced Eisenhut extended downwards to cover the face, staying fashionable while fully protecting the wearer at the cost of his field of view. Pairs well with a bevor."
	icon_state = "grenzelskettle"
	item_state = "grenzelskettle"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	detail_color = "#262927"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + 10

/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle/grenzelhoft/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle/grenzelhoft/update_icon()
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

/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet/grenzelhoft
	name = "armet w/plume hat"
	desc = "A Grenzelhoftian plume hat placed atop a steel armet, staying fashionable while protecting the wearer's head to a better degree. Will you endure alongside Him, as a knight of humenity, or crumble before temptation?"
	icon_state = "grenzelarmet"
	item_state = "grenzelarmet"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	detail_tag = "_detail"
	altdetail_tag = "_detailalt"
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	color = "#FFFFFF"
	detail_color = "#262927"
	altdetail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL - ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY + 10

/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet/grenzelhoft/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet/grenzelhoft/update_icon()
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

/obj/item/clothing/head/roguetown/helmet/heavy/knight/raneshi_hmamluk
	name = "masked mamluk helmet"
	desc = "Helmet of a heavy rider from Empire with a face-shaped visor."
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	icon_state = "face_helmet"
	item_state = "face_helmet"
	max_integrity = ARMOR_INT_HELMET_HEAVY_STEEL + 20

/obj/item/clothing/head/roguetown/helmet/heavy/knight/raneshi_hmamluk/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/knight/raneshi_hmamluk/attackby(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/natural/cloth) && !detail_tag)
		var/choice = input(user, "Choose a color.", "Orle") as anything in COLOR_MAP
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = COLOR_MAP[choice]
		detail_tag = "_detail"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/roguetown/helmet/heavy/knight/raneshi_hmamluk/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/head/roguetown/helmet/heavy/knight/raneshi_hmamluk/raneshi_vmamluk
	name = "hound masked mamluk helmet"
	desc = "Helmet of a heavy rider from Empire with a face-shaped visor."
	icon_state = "hound_helmet"
	item_state = "hound_helmet"

/obj/item/clothing/head/roguetown/helmet/heavy/ravoxhelm/oldrw
	name = "plumed ravox helmet"
	desc = "A helmet with a great, red plume. They will know, in time, that you are the true justiciar of the Vale."
	icon_state = "ravoxhelm"
	item_state = "ravoxhelm"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDESNOUT
	block2add = FOV_BEHIND
	smeltresult = /obj/item/ingot/steel
	smelt_bar_num = 2
	adjustable = CAN_CADJUST

/obj/item/clothing/head/roguetown/helmet/heavy/ravoxhelm/oldrw/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/necran/oldrw
	name = "hooded morwenna helmet"
	desc = "Grim as the faces who wear it. For their duty is sacred, as they know the one truth of this lyfe. They're to perish, just as you are."
	icon_state = "necrahelm_hooded"
	item_state = "necrahelm_hooded"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/roguetown/helmet/heavy/necran/oldrw/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/astratan/oldrw
	name = "plumed auxentius helmet"
	desc = "A helmet with a great, black plume. Order shall guide your hand. Strike sure. Strike true. For none may question your intent."
	icon_state = "astratahelm_plume"
	item_state = "astratahelm_plume"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/roguetown/helmet/heavy/astratan/oldrw/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/eoran/resprite
	name = "trnvan helmet"
	desc = "A visage of beauty, this helm made in soft pink and beige reminds one of the grace of Trnva."
	icon_state = "helmet_eora"
	item_state = "helmet_eora"
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	adjustable = CAN_CADJUST

/obj/item/clothing/head/roguetown/helmet/heavy/eoran/resprite/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/citywatch
	name = "citywatch's helmet"
	desc = "A heavy helmet, incredibly resilient to all types of damage. Used by the city watch."
	icon_state = "citywatch_helmet"
	item_state = "citywatch_helmet"
	icon = 'modular_dreamvalley/icons/twilight_special/citywatch_armor.dmi'
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/roguetown/helmet/heavy/citywatch/sheriff
	name = "sheriff's helmet"
	desc = "A heavy helmet, incredibly resilient to all types of damage. Painted a different color to distinguish the sheriff from other watch helmets."
	icon_state = "sheriff_helm"
	item_state = "sheriff_helm"

/obj/item/clothing/head/roguetown/helmet/heavy/twilight_drow
	name = "scourge barbute"
	desc = "This helmet is a reluctant concession to the reality of modern warfare. No self-respecting Dark Elf would ever wear this into battle unless absolutely necessary. Naturally, it is usually donned by Drow males."
	icon = 'modular_dreamvalley/icons/twilight_clothing/head.dmi'
	icon_state = "shadowbarbute"
	item_state = "shadowbarbute"
	smeltresult = /obj/item/ingot/drow
	adjustable = CAN_CADJUST
	material_category = ARMOR_MAT_PLATE
	toggle_icon_state = TRUE
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/roguetown/helmet/heavy/twilight_drow/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/adjustable_clothing, (HEAD|EARS|HAIR), (HIDEEARS|HIDEHAIR), null, 'sound/items/visor.ogg', null, UPD_HEAD)

/obj/item/clothing/head/roguetown/helmet/heavy/twilight_drow/volf
	name = "razormaw helm"
	desc = "As if facing a Dark Elf raider was not intimidating enough by itself, this helmet, designed to resemble the head of a giant lizard hailing from the Underdark, is meant to invoke primal terror in men and creechers alike."
	icon_state = "shadowvolf"
	item_state = "shadowvolf"

//====================================================================
// Cloaks
//====================================================================

/obj/item/clothing/cloak/half/knight
	name = "champion's halfcloak"
	desc = "A halfcloak of the Grand Duke's most loyal champion."
	color = CLOTHING_BLUE

/obj/item/clothing/cloak/half/knight/Initialize(mob/living/L)
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/item/clothing/cloak/half/knight/lordcolor(primary,secondary)
	color = primary
	detail_color = secondary
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()

/obj/item/clothing/cloak/half/knight/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/item/clothing/cloak/raincloak/furcloak/knight
	name = "champion's cloak"
	desc = "A cloak of the Grand Duke's most loyal champion."
	color = CLOTHING_BLUE

/obj/item/clothing/cloak/raincloak/furcloak/knight/Initialize()
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/item/clothing/cloak/raincloak/furcloak/knight/lordcolor(primary,secondary)
	color = primary
	detail_color = secondary
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()

/obj/item/clothing/cloak/raincloak/furcloak/knight/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/item/clothing/cloak/twilight_elven
	name = "elven cloak"
	desc = "It is said that this design might predate the War in Heaven and the consequient fall of the ancient Elven Empire."
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "cape"
	item_state = "cape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = TRUE
	var/elven_colors = list("Blue Cloak", "Red Cloak", "Blue Furcloak", "Red Furcloak")
	var/picked = FALSE

/obj/item/clothing/cloak/twilight_elven/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete/roguetown/cloak)

/obj/item/clothing/cloak/twilight_elven/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a style.", "Elven styles") as anything in elven_colors
		picked = TRUE
		switch(choice)
			if("Blue Cloak")
				detail_tag = "_blue"
			if("Red Cloak")
				detail_tag = "_red"
			if("Blue Furcloak")
				detail_tag = "_blue_alt"
			if("Red Furcloak")
				detail_tag = "_red_alt"
			if("Blue Short Cloak")
				detail_tag = "_blue"
			if("Red Short Cloak")
				detail_tag = "_red"
			if("Blue Short Furcloak")
				detail_tag = "_blue_alt"
			if("Red Short Furcloak")
				detail_tag = "_red_alt"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			update_icon()

/obj/item/clothing/cloak/twilight_elven/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/cloak/twilight_elven/short
	name = "elven shortcloak"
	icon_state = "cape_short"
	item_state = "cape_short"
	elven_colors = list("Blue Short Cloak", "Red Short Cloak", "Blue Short Furcloak", "Red Short Furcloak")

/obj/item/clothing/cloak/twilight_scarf
	name = "scarf"
	desc = "A long piece of cloth, meant to be worn around one's neck, Keeps you warm even under colder winds."
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "scarf"
	item_state = "scarf"
	inhand_mod = TRUE
	var/elven_colors = list("blue", "black", "green", "beige", "brown", "white")
	var/picked = FALSE

/obj/item/clothing/cloak/twilight_scarf/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a color.", "Elven colors") as anything in elven_colors
		picked = TRUE
		detail_tag = "_[choice]"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
			update_icon()

/obj/item/clothing/cloak/twilight_scarf/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/cloak/twilight_cape
	name = "hammerhold cape"
	desc = ""
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "white_mage_neckwear"
	item_state = "white_mage_neckwear"
	inhand_mod = TRUE
	var/hammerhold_colors = list("white", "blue")
	var/picked = FALSE
	var/hammerhold_final_icon = null

/obj/item/clothing/cloak/twilight_cape/attack_right(mob/user)
	..()
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			icon_state = "white_mage_neckwear"
			item_state = "white_mage_neckwear"
			hammerhold_final_icon = "white_mage_neckwear"
		if(choiceC == "blue")
			icon_state = "blue_mage_neckwear"
			item_state = "blue_mage_neckwear"
			hammerhold_final_icon = "blue_mage_neckwear"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
		if(alert("Are you pleased with your cape?", "Cape", "Yes", "No") != "Yes")
			icon_state = "white_mage_neckwear"
			item_state = "white_mage_neckwear"
			hammerhold_final_icon = "white_mage_neckwear"
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_cloak()
			update_icon()
			return
		picked = TRUE

/obj/item/clothing/cloak/twilight_cape/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/cloak/twilight_cape/equipped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/cloak/twilight_cape/dropped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/cloak/bishop
	name = "bishop cape"
	desc = ""
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "bishop_cape"
	item_state = "bishop_cape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = TRUE

/obj/item/clothing/cloak/bishop/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete/roguetown/cloak)

/obj/item/clothing/cloak/templar/eoran/alt
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "tabard_blue"
	item_state = "tabard_blue"
	var/eora_colors = list("Blue Tabard", "Pink Tabard")
	var/picked = FALSE
	var/eora_final_icon = null

/obj/item/clothing/cloak/templar/eoran/alt/attack_right(mob/user)
	..()
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Trnva colors") as anything in eora_colors
		if(choiceC == "Blue Tabard")
			icon_state = "tabard_blue"
			item_state = "tabard_blue"
			eora_final_icon = "tabard_blue"
		if(choiceC == "Pink Tabard")
			icon_state = "tabard_pink"
			item_state = "tabard_pink"
			eora_final_icon = "tabard_pink"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_cloak()
		if(alert("Are you pleased with your tabard?", "Tabard", "Yes", "No") != "Yes")
			icon_state = "tabard_blue"
			item_state = "tabard_blue"
			eora_final_icon = "tabard_blue"
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_cloak()
			update_icon()
			return
		picked = TRUE

/obj/item/clothing/cloak/templar/eoran/alt/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/cloak/templar/eoran/alt/equipped(mob/user, slot)
	. = ..()
	if(eora_final_icon)
		icon_state = eora_final_icon
		item_state = eora_final_icon
		update_icon()

/obj/item/clothing/cloak/templar/eoran/alt/dropped(mob/user, slot)
	. = ..()
	if(eora_final_icon)
		icon_state = eora_final_icon
		item_state = eora_final_icon
		update_icon()

/obj/item/clothing/cloak/sheriff
	name = "sheriff's cloak"
	desc = "A cloak with embroidered silver heraldry of the watch."
	icon = 'modular_dreamvalley/icons/twilight_special/citywatch_armor.dmi'
	icon_state = "sheriffcloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER

/obj/item/clothing/cloak/duelcape
	name = "duelist cape"
	desc = "A cape designed for mercenary bands hailing from far away."
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	icon_state = "duelistcape"
	item_state = "duelistcape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = FALSE
	color = null

/obj/item/clothing/cloak/etrcape
	name = "wanderer's cape"
	desc = "A stylish raincoat that protects you from the rain and makes you look great"
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	icon_state = "etrcape"
	item_state = "etrcape"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	inhand_mod = FALSE
	color = null
	allowed_race = NON_DWARVEN_RACE_TYPES

//====================================================================
// Boots
//====================================================================

/obj/item/clothing/shoes/roguetown/boots/armor/iron/twilight_elven
	name = "elven rider boots"
	desc = "Comfortable leather boots, reinforced with metal plates for extra protection. Crafted by elven masters, based on a design lost to ages."
	icon_state = "elven_boots"
	item_state = "elven_boots"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'

/obj/item/clothing/shoes/roguetown/boots/hammerhold_boots
	name = "hammerhold boots"
	desc = ""
	icon_state = "boots"
	item_state = "boots"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'

/obj/item/clothing/shoes/roguetown/hammerhold_shoes
	name = "hammerhold shoes"
	desc = ""
	icon_state = "shoes"
	item_state = "shoes"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'

/obj/item/clothing/shoes/roguetown/boots/leather/twilight_etruscan_boots
	name = "etruscan jackboots"
	desc = "High boots that are both beautiful and comfortable."
	icon_state = "etrboots"
	item_state = "etrboots"
	sewrepair = TRUE
	armor = ARMOR_CLOTHING
	salvage_amount = 1
	salvage_result = /obj/item/natural/hide/cured
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'
	allowed_sex = list(FEMALE)
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/shoes/roguetown/boots/leather/twilight_etruscan_boots/heavy
	max_integrity = 100
	armor = ARMOR_LEATHER
	color = null
	allowed_sex = list(FEMALE)
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/shoes/roguetown/boots/leather/etrbootsm
	name = "wanderer's boots"
	desc = "A comfortable pair of boots for traveling and attending court events."
	icon_state = "etrbootsm"
	item_state = "etrbootsm"
	sewrepair = TRUE
	armor = ARMOR_LEATHER
	salvage_amount = 1
	salvage_result = /obj/item/natural/hide/cured
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'
	allowed_sex = list(MALE)
	allowed_race = NON_DWARVEN_RACE_TYPES

/obj/item/clothing/shoes/roguetown/boots/armor/twilight_drow
	name = "scourge plated boots"
	desc = "Sabatons forged of blessed avantyne, to be donned by those who would be Her vanguard in the End of Times. Whether they actually are is another matter entirely."
	icon = 'modular_dreamvalley/icons/twilight_clothing/boots.dmi'
	icon_state = "shadowboots"
	item_state = "shadowboots"
	allowed_race = NON_DWARVEN_RACE_TYPES
	smeltresult = /obj/item/ingot/drow

//====================================================================
// Shirts
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/dress/stewarddress
	name = "steward's dress"
	desc = "A victorian-styled black dress with shining bronze buttons."
	icon = 'modular_dreamvalley/icons/twilight_special/noble.dmi'
	icon_state = "stewarddress"
	sleeved = FALSE
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT

/obj/item/clothing/suit/roguetown/shirt/twilight_elven
	name = "elven suit"
	desc = "A common garnament for Etruscan countryside, each of these suits is woven in adherence to tradition."
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'
	icon_state = "suit"
	item_state = "suit"
	allowed_race = NON_DWARVEN_RACE_TYPES
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|VITALS
	var/elven_colors = list("blue", "red", "beige", "black", "green")
	var/picked = FALSE

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a color.", "Elven colors") as anything in elven_colors
		picked = TRUE
		detail_tag = "_[choice]"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat
	name = "elven coat"
	desc = "A common garnament for Etruscan countryside, each of these durable coats is woven in adherence to tradition."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	icon_state = "coat"
	item_state = "coat"
	flags_inv = HIDEBOOB|HIDECROTCH
	body_parts_covered = CHEST|GROIN|ARMS|VITALS
	elven_colors = list("blue", "red", "beige", "white", "green", "gray")

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a color.", "Elven colors") as anything in elven_colors
		picked = TRUE
		detail_tag = "_[choice]"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat/alt
	name = "elven furcoat"
	desc = "A common garnament for Etruscan countryside, each of these durable coats is woven in adherence to tradition. Luxurious leovarg fur makes it fit for colder regions as well as self-entitled nobility."
	icon_state = "coat_alt"
	item_state = "coat_alt"
	elven_colors = list("blue", "red", "beige", "white")

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat/alt/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a color.", "Elven colors") as anything in elven_colors
		picked = TRUE
		detail_tag = "_[choice]"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()

/obj/item/clothing/suit/roguetown/shirt/twilight_elven/coat/alt/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold
	name = "hammerhold shirt"
	desc = ""
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'
	icon_state = "white_shirt_a"
	item_state = "white_shirt_a"
	allowed_race = NON_DWARVEN_RACE_TYPES
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	var/hammerhold_colors = list("white", "black", "red")
	var/hammerhold_variants = list("a", "b", "c", "d")
	var/picked = FALSE
	var/hammerhold_final_icon = null

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/attack_right(mob/user)
	..()
	if(!picked)
		var/iconH = icon_state
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			iconH = "white_shirt"
			hammerhold_variants += list("e", "g")
		if(choiceC == "black")
			iconH = "black_shirt"
			hammerhold_variants += list("e", "g")
		if(choiceC == "red")
			iconH = "red_shirt"
		var/choiceV = input(user, "Choose a variant.", "Hammerhold variants") as anything in hammerhold_variants
		iconH = iconH + "_[choiceV]"
		icon_state = iconH
		item_state = iconH
		hammerhold_final_icon = iconH
		update_icon()
		if(alert("Are you pleased with your shirt?", "Shirt", "Yes", "No") != "Yes")
			icon_state = "white_shirt_a"
			item_state = "white_shirt_a"
			hammerhold_final_icon = "white_shirt_a"
			update_icon()
			return
		picked = TRUE
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/equipped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dropped(mob/user, slot)
	. = ..()
	if(hammerhold_final_icon)
		icon_state = hammerhold_final_icon
		item_state = hammerhold_final_icon
		update_icon()

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/coat
	name = "boyar coat"
	desc = "A boyar coat inspired by elven culture, worn by noble representatives of Hammerhold."
	icon_state = "coat_a"
	item_state = "coat_a"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("red", "beige")
	hammerhold_variants = null

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/coat/attack_right(mob/user)
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "beige")
			icon_state = "coat_a"
			item_state = "coat_a"
			hammerhold_final_icon = "coat_a"
		if(choiceC == "red")
			icon_state = "coat_b"
			item_state = "coat_b"
			hammerhold_final_icon = "coat_b"
		update_icon()
		if(alert("Are you pleased with your coat?", "Coat", "Yes", "No") != "Yes")
			icon_state = "coat_a"
			item_state = "coat_a"
			hammerhold_final_icon = "coat_a"
			update_icon()
			return
		picked = TRUE
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress
	name = "hammerhold dress"
	desc = ""
	icon_state = "white_dress_a"
	item_state = "white_dress_a"
	allowed_race = NON_DWARVEN_RACE_TYPES
	allowed_sex = list(FEMALE)
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	body_parts_covered = CHEST|GROIN|VITALS
	hammerhold_colors = list("white", "black", "blue", "red")
	hammerhold_variants = list("a", "b")

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/attack_right(mob/user)
	if(!picked)
		var/iconH = icon_state
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			iconH = "white_dress"
			hammerhold_variants += list("c")
		if(choiceC == "black")
			iconH = "black_dress"
			hammerhold_variants += list("c")
		if(choiceC == "blue")
			iconH = "blue_dress"
		if(choiceC == "red")
			iconH = "red_dress"
		var/choiceV = input(user, "Choose a variant.", "Hammerhold variants") as anything in hammerhold_variants
		iconH = iconH + "_[choiceV]"
		icon_state = iconH
		item_state = iconH
		hammerhold_final_icon = iconH
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
		if(alert("Are you pleased with your dress?", "Dress", "Yes", "No") != "Yes")
			icon_state = "white_dress_a"
			item_state = "white_dress_a"
			hammerhold_final_icon = "white_dress_a"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
			return
		picked = TRUE

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/furcoat
	name = "hammerhold mage coat"
	desc = ""
	icon_state = "white_mage_coat"
	item_state = "white_mage_coat"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("white", "blue")
	hammerhold_variants = null

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/furcoat/heavy
	body_parts_covered = COVERAGE_ALL_BUT_ARMS
	armor = ARMOR_LEATHER
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = TRUE
	sellprice = 25
	slot_flags = ITEM_SLOT_ARMOR
	material_category = ARMOR_MAT_LEATHER
	salvage_result = /obj/item/natural/hide/cured
	chunkcolor = "#7e5d17"

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/furcoat/attack_right(mob/user)
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			icon_state = "white_mage_coat"
			item_state = "white_mage_coat"
			hammerhold_final_icon = "white_mage_coat"
		if(choiceC == "blue")
			icon_state = "blue_mage_coat"
			item_state = "blue_mage_coat"
			hammerhold_final_icon = "blue_mage_coat"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
		if(alert("Are you pleased with your furcoat?", "Furcoat", "Yes", "No") != "Yes")
			icon_state = "white_mage_coat"
			item_state = "white_mage_coat"
			hammerhold_final_icon = "white_mage_coat"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
			return
		picked = TRUE

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/robe
	name = "hammerhold robe"
	desc = ""
	icon_state = "white_mage_robe"
	item_state = "white_mage_robe"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	hammerhold_colors = list("white", "blue")
	hammerhold_variants = null

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/robe/heavy
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	armor_class = ARMOR_CLASS_LIGHT
	material_category = ARMOR_MAT_LEATHER
	sellprice = 25
	cold_protection = 10

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/robe/light
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	armor = ARMOR_PADDED
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	chunkcolor = "#978151"
	material_category = ARMOR_MAT_LEATHER
	cold_protection = 10

/obj/item/clothing/suit/roguetown/shirt/twilight_hammerhold/dress/robe/attack_right(mob/user)
	if(!picked)
		var/choiceC = input(user, "Choose a color.", "Hammerhold colors") as anything in hammerhold_colors
		if(choiceC == "white")
			icon_state = "white_mage_robe"
			item_state = "white_mage_robe"
			hammerhold_final_icon = "white_mage_robe"
		if(choiceC == "blue")
			icon_state = "blue_mage_robe"
			item_state = "blue_mage_robe"
			hammerhold_final_icon = "blue_mage_robe"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_inv_armor()
		if(alert("Are you pleased with your furcoat?", "Furcoat", "Yes", "No") != "Yes")
			icon_state = "white_mage_robe"
			item_state = "white_mage_robe"
			hammerhold_final_icon = "white_mage_robe"
			update_icon()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_shirt()
				H.update_inv_armor()
			return
		picked = TRUE

/obj/item/clothing/suit/roguetown/shirt/robe/bishop
	name = "bishop robe"
	desc = ""
	icon_state = "bishop_robe"
	item_state = "bishop_robe"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	resistance_flags = FIRE_PROOF
	armor = ARMOR_PADDED
	color = null
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'

/obj/item/clothing/suit/roguetown/shirt/robe/bishop/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CHOSEN, "VESTMENTS")

/obj/item/clothing/suit/roguetown/shirt/robe/bishop/equipped(mob/living/user, slot)
	..()
	if(slot != SLOT_ARMOR|SLOT_SHIRT)
		return
	if(!HAS_TRAIT(user, TRAIT_CHOSEN))
		return
	ADD_TRAIT(user, TRAIT_MONK_ROBE, TRAIT_GENERIC)
	to_chat(user, span_notice("With my vows to poverty and my vestments, I feel vigorous - empowered by my God!"))

/obj/item/clothing/suit/roguetown/shirt/robe/bishop/dropped(mob/living/user)
	..()
	REMOVE_TRAIT(user, TRAIT_MONK_ROBE, TRAIT_GENERIC)
	to_chat(user, span_notice("I must lay down my robes and rest; even God's chosen must rest.."))

/obj/item/clothing/suit/roguetown/shirt/robe/nunTA
	name = "nun dress"
	desc = ""
	icon_state = "nun_dress"
	item_state = "nun_dress"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	allowed_race = NON_DWARVEN_RACE_TYPES
	allowed_sex = list(FEMALE)
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'

/obj/item/clothing/suit/roguetown/shirt/robe/eora/resprite
	name = "trnvan robe"
	desc = "Holy robes, intended for use by followers of Trnva"
	icon_state = "robe_blue"
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'

/obj/item/clothing/suit/roguetown/shirt/robe/eora/resprite/attack_right(mob/user)
	switch(fanatic_wear)
		if(FALSE)
			name = "open trnvan robe"
			desc = "Used by more radical followers of the Trnvan Church"
			body_parts_covered = null
			icon_state = "straps_blue"
			fanatic_wear = TRUE
			flags_inv = HIDEBOOB
			to_chat(usr, span_warning("Now wearing radically!"))
		if(TRUE)
			name = "trnvan robe"
			desc = "Holy robes, intended for use by followers of Trnva"
			body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
			icon_state = "robe_blue"
			fanatic_wear = FALSE
			flags_inv = HIDEBOOB|HIDECROTCH
			to_chat(usr, span_warning("Now wearing normally!"))
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_armor()

/obj/item/clothing/suit/roguetown/shirt/robe/eora/resprite/pink
	name = "trnvan robe"
	desc = "Holy robes, intended for use by followers of Trnva"
	icon_state = "robe_pink"
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/shirts.dmi'

/obj/item/clothing/suit/roguetown/shirt/robe/eora/resprite/pink/attack_right(mob/user)
	switch(fanatic_wear)
		if(FALSE)
			name = "open trnvan robe"
			desc = "Used by more radical followers of the Trnvan Church"
			body_parts_covered = null
			icon_state = "straps_pink"
			fanatic_wear = TRUE
			flags_inv = HIDEBOOB
			to_chat(usr, span_warning("Now wearing radically!"))
		if(TRUE)
			name = "trnvan robe"
			desc = "Holy robes, intended for use by followers of Trnva"
			body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
			icon_state = "robe_pink"
			fanatic_wear = FALSE
			flags_inv = HIDEBOOB|HIDECROTCH
			to_chat(usr, span_warning("Now wearing normally!"))
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_armor()

//====================================================================
// Desert Clothing
//====================================================================

/obj/item/clothing/suit/roguetown/armor/leather/vest/open
	name = "open vest"
	desc = "A leather vest. Not very protective when worn like this."
	icon = 'modular_dreamvalley/icons/twilight_clothing/armor.dmi'
	icon_state = "openvest"
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'
	body_parts_covered = CHEST|VITALS

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/purple
	color = CLOTHING_PURPLE

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/blue
	color = "#2f51b8"

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/red
	color = CLOTHING_RED

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/orange
	color = CLOTHING_ORANGE

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/green
	color = CLOTHING_GREEN

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/brown
	color = "#514339"

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/random

/obj/item/clothing/suit/roguetown/armor/leather/vest/open/random/Initialize()
	color = pick("#2f51b8", CLOTHING_RED, CLOTHING_ORANGE, CLOTHING_GREEN, CLOTHING_PURPLE)
	..()

/obj/item/clothing/suit/roguetown/shirt/dress/amiradress
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	name = "amira's dress"
	desc = "A red skirt and binder, embroidened with infinitely intricate gold-thread patterns, and made of silk as light as air. Fit for a princess of Zybantine."
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	icon = 'modular_dreamvalley/icons/twilight_clothing/shirts.dmi'
	icon_state = "dprince"
	item_state = "dprince"

/obj/item/clothing/under/roguetown/thong
	name = "thong"
	desc = "Underwear so thin it barely covers ones bits. Barely."
	gender = PLURAL
	icon = 'modular_dreamvalley/icons/twilight_clothing/pants.dmi'
	icon_state = "thong"
	item_state = "thong"
	body_parts_covered = GROIN

/obj/item/clothing/cloak/catcloak
	name = "cataphracts cloak"
	desc = "Noble red cloak of a Zybantine Cataphract"
	icon = 'modular_dreamvalley/icons/twilight_clothing/cloaks.dmi'
	icon_state = "catcloak"
	body_parts_covered = CHEST|GROIN|VITALS|ARMS
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	sleevetype = "shirt"
	slot_flags = ITEM_SLOT_CLOAK
	sellprice = 50
	nodismemsleeves = TRUE
