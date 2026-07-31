// Ported from Twilight-Axis - the Kazengun/samurai cultural clothing line, ported as a cohesive
// set per the port request. Sources:
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/armor/plate.dm (plate/scale/townguard
//     + /sheriff, plate/fluted/baotha_ta)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/headwear/hats.dm (duelhat/etrusca,
//     gasa + /ronin, roningasa, sandogasa, torioigasa, tengai, eaststrawhat)
//   - modular_twilight_axis/code/modules/jobs/job_types/roguetown/sidefolk/mercenary/yohei.dm
//     (helmet/heavy/kabuto/zunari, brigandine/harayoroi)
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/shirts/shirts.dm (kimono + /kimono2,
//     haori, kamishimo + /ronin, yoroihitatare, kazengun_jacket)
//   - modular_deserttown/desertclothing.dm (chainmail/hauberk/janissary, plate/cataphract + /sultan
//     - listed in the port request under Kazengun despite living in the desert-culture source file)
//
// Adaptation notes:
// - icon/mob_overlay_icon paths under modular_twilight_axis/icons/... and modular_deserttown/icons/...
//   don't exist in this tree. Copied verbatim into modular_dreamvalley/icons/twilight_kazengun/
//   (kazengun_n_burger.dmi, head.dmi, shirts.dmi, citywatch_armor.dmi, armor.dmi, and their onmob/
//   sleeve counterparts). icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi was NOT copied -
//   it already exists natively in this repo at that exact path and is referenced as-is.
// - helmet/heavy/kabuto (the parent /zunari extends) is NOT new - this repo's own base
//   code/modules/clothing/rogueclothes/headwear/helmet/heavy_helmet.dm already defines it
//   byte-for-byte identically to Twilight-Axis's version (shared ancestry), so only the /zunari
//   leaf was ported here.
// - plate/fluted/baotha_ta: "baotha" is not a Twilight-Axis-exclusive proper noun - this repo
//   already has /obj/item/ingot/component/baotha (code/game/objects/items.dm), the
//   HERESYDESC_BAOTHA_ARMOR define, and TRAIT_DEPRAVED / /datum/component/cursed_item, all used
//   identically here. The flavor text references Eora/Ravox/Belladoth, all of whom already have
//   dedicated native content in this repo (code/modules/spells/roguetown/acolyte/eora.dm,
//   .../ravox.dm) - so this is compatible native lore, not a foreign pantheon reference. Ported
//   as-is with no rename. Note only /obj/item/clothing/suit/roguetown/armor/plate/fluted/baotha_ta
//   itself was in the requested port list; the source file also defines a matching baotha_ta
//   helmet/veil/gambeson/bracers/skirt/gloves/boots set forming one "Ascendant"-tier cursed outfit
//   - those siblings were intentionally left out since only the plate piece was requested, but can
//   be pulled in later using the same pattern if the rest of the set is wanted.
// - janissary/cataphract were requested under the Kazengun heading even though their source file
//   is modular_deserttown/desertclothing.dm; ported here to match the request's grouping rather
//   than splitting them into the Desert wardrobe file.

//====================================================================
// Armor
//====================================================================

/obj/item/clothing/suit/roguetown/armor/brigandine/harayoroi
	name = "hara-yoroi cuirass"
	desc = "A practical lightweight cuirass favored by disciplined mercenaries and provincial retainers. Layered blacksteel-coated steel plates, dulled to mute their shine, offer reliable protection without the burden of full battle harness."
	icon = 'modular_dreamvalley/icons/twilight_kazengun/armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/armor_onmob.dmi'
	icon_state = "kazengunlight"
	boobed = TRUE
	item_state = "kazengunlight"
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE + 25
	var/picked = FALSE

/obj/item/clothing/suit/roguetown/armor/brigandine/harayoroi/attack_right(mob/user)
	..()
	if(!picked)
		var/choice = input(user, "Choose a color.", "Uniform colors") as anything in COLOR_MAP
		var/playerchoice = COLOR_MAP[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_armor()
			H.update_icon()

/obj/item/clothing/suit/roguetown/armor/brigandine/harayoroi/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/janissary
	slot_flags = ITEM_SLOT_ARMOR
	name = "janissary chainmail"
	desc = "A longer steel maille that protects the legs."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'
	icon = 'modular_dreamvalley/icons/twilight_desert/armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/armor_onmob.dmi'
	icon_state = "mamaluke"
	item_state = "mamaluke"
	max_integrity = 350

/obj/item/clothing/suit/roguetown/armor/plate/scale/townguard
	name = "watchman's armor"
	desc = "Heavy armor, issued to the city watch."
	icon = 'modular_dreamvalley/icons/twilight_kazengun/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/citywatch_armor_onmob.dmi'
	sleeved = 'modular_dreamvalley/icons/twilight_kazengun/citywatch_sleeves_armor.dmi'
	icon_state = "citywatch"
	item_state = "citywatch"

/obj/item/clothing/suit/roguetown/armor/plate/scale/townguard/sheriff
	name = "sheriff's armor"
	desc = "Heavy armor, belonging to the Sheriff of the watch."
	icon_state = "sheriffarmor"
	item_state = "sheriffarmor"

/obj/item/clothing/suit/roguetown/armor/plate/cataphract
	slot_flags = ITEM_SLOT_ARMOR
	name = "cataphract armor"
	desc = "Metal scales interwoven intricately to form flexible protection!"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/armor_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "cataphract"
	item_state = "cataphract"
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET | NECK
	equip_delay_self = 12 SECONDS
	unequip_delay_self = 12 SECONDS
	equip_delay_other = 3 SECONDS
	strip_delay = 6 SECONDS
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	smelt_bar_num = 4
	armor_class = ARMOR_CLASS_HEAVY
	armor = ARMOR_PLATE

/obj/item/clothing/suit/roguetown/armor/plate/cataphract/sultan
	name = "sultan scale"
	desc = "Impenetrable scales, like an ancient black dragon."
	color = "#5e5d5d"
	armor = ARMOR_PLATE_BSTEEL
	max_integrity = ARMOR_INT_CHEST_PLATE_BLACKSTEEL
	smeltresult = /obj/item/ingot/blacksteel

/obj/item/clothing/suit/roguetown/armor/plate/fluted/baotha_ta
	name = "saccharine plate armor"
	desc = "Is it not obvious what Ravox would've chosen? Yet upon the dae of His choice, She refused to gift any chance to Her sister.."
	icon_state = "baothaplate"
	item_state = "baothaplate"
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG - 250
	armor_class = ARMOR_CLASS_LIGHT
	color = null
	chunkcolor = "#dd2166"
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	smeltresult = /obj/item/ingot/component/baotha

/obj/item/clothing/suit/roguetown/armor/plate/fluted/baotha_ta/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_DEPRAVED, "ARMOR")
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/plate/fluted/baotha_ta/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/plate/fluted/baotha_ta/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_BAOTHA_ARMOR)

//====================================================================
// Headwear
//====================================================================

/obj/item/clothing/head/roguetown/helmet/heavy/kabuto/zunari
	name = "zunari-kabuto"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head_onmob.dmi'
	desc = "A battle-forged helm, constructed from layered steel plates and reinforced along the head. Darkened to mute its shine, it is built for endurance rather than ceremony."
	icon_state = "kazengunmediumhelm"

/obj/item/clothing/head/roguetown/duelhat/etrusca
	name = "etruscian duelist hat"
	desc = "A dainty looking feathered hat that is actually quite heavy and thick. Duelists are known to value winning fights without dirtying the white feather on top."
	icon = 'modular_dreamvalley/icons/twilight_kazengun/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head_onmob.dmi'
	icon_state = "duelisthat"
	item_state = "duelisthat"
	color = null

/obj/item/clothing/head/roguetown/gasa
	name = "gasa"
	flags_inv = HIDEEARS
	icon_state = "gasa"
	item_state = "gasa"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head64_onmob.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/gasa/ronin
	name = "ronin gasa"
	desc = "An oddly shaped hat of wandering ronin."
	color = CLOTHING_BLUE

/obj/item/clothing/head/roguetown/roningasa
	name = "roningasa"
	flags_inv = HIDEEARS
	icon_state = "roningasa"
	item_state = "roningasa"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head64_onmob.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/sandogasa
	name = "sandogasa"
	flags_inv = HIDEEARS
	icon_state = "sandogasa"
	item_state = "sandogasa"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head64_onmob.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/torioigasa
	name = "torioigasa"
	flags_inv = HIDEEARS
	icon_state = "torioigasa"
	item_state = "torioigasa"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head64_onmob.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/tengai
	name = "tengai"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	flags_inv = HIDEEARS
	icon_state = "tengai"
	item_state = "tengai"
	icon = 'modular_dreamvalley/icons/twilight_kazengun/kazengun_n_burger.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head64_onmob.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/roguetown/eaststrawhat
	name = "worn rice hat"
	desc = "A wicker rice hat."
	icon = 'modular_dreamvalley/icons/twilight_kazengun/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/head_onmob.dmi'
	icon_state = "eaststrawhat"
	flags_inv = HIDEEARS
	sewrepair = TRUE
	var/hides_ears = TRUE

/obj/item/clothing/head/roguetown/eaststrawhat/MiddleClick(mob/user, params)
	. = ..()
	hides_ears = !hides_ears
	flags_inv = hides_ears ? HIDEEARS : null

//====================================================================
// Clothing
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/kimono
	name = "kimono"
	desc = "A traditional wrapped robe, fastened with a wide sash."
	icon_state = "white_kimono"
	item_state = "white_kimono"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	allowed_race = NON_DWARVEN_RACE_TYPES
	allowed_sex = list(FEMALE)
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	var/kimono_colors = list("white", "blue", "black")
	var/picked = FALSE
	var/kimono_final_icon = null

/obj/item/clothing/suit/roguetown/shirt/kimono/attack_right(mob/user)
	..()
	if(!picked)
		var/iconH = icon_state
		var/choiceC = input(user, "Choose a color.", "Kimono colors") as anything in kimono_colors
		if(choiceC == "white")
			iconH = "white_kimono"
		if(choiceC == "black")
			iconH = "black_kimono"
		if(choiceC == "blue")
			iconH = "blue_kimono"
		icon_state = iconH
		item_state = iconH
		kimono_final_icon = iconH
		update_icon()
		if(alert("Are you pleased with your kimono?", "Kimono", "Yes", "No") != "Yes")
			icon_state = "white_kimono"
			item_state = "white_kimono"
			kimono_final_icon = "white_kimono"
			update_icon()
			return
		picked = TRUE
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()

/obj/item/clothing/suit/roguetown/shirt/kimono/equipped(mob/user, slot)
	. = ..()
	if(kimono_final_icon)
		icon_state = kimono_final_icon
		item_state = kimono_final_icon
		update_icon()

/obj/item/clothing/suit/roguetown/shirt/kimono/dropped(mob/user, slot)
	. = ..()
	if(kimono_final_icon)
		icon_state = kimono_final_icon
		item_state = kimono_final_icon
		update_icon()

/obj/item/clothing/suit/roguetown/shirt/kimono2
	name = "long sleeved kimono"
	desc = "Classic kimono from the eastern isles."
	icon_state = "kimono"
	item_state = "kimono"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	boobed = TRUE
	flags_inv = HIDEBOOB|HIDECROTCH
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/clothing/suit/roguetown/shirt/haori
	name = "haori"
	desc = "A traditional outer garment in the form of a short, straight jacket with wide sleeves and side slits."
	icon_state = "haori"
	item_state = "haori"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	flags_inv = HIDEBOOB
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|VITALS
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/clothing/suit/roguetown/shirt/yoroihitatare
	name = "yoroihitatare"
	desc = "Traditional samurai ceremonial attire, worn under armor or for official ceremonies."
	icon_state = "yoroihitatare"
	item_state = "yoroihitatare"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	boobed = TRUE
	flags_inv = HIDEBOOB|HIDECROTCH
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/clothing/suit/roguetown/shirt/kamishimo
	name = "kamishimo"
	desc = "A sleeveless vest-jacket with wide shoulders, worn over a kimono."
	icon_state = "kamishimo"
	item_state = "kamishimo"
	flags_inv = HIDEBOOB
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|VITALS
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/clothing/suit/roguetown/shirt/kamishimo/ronin
	name = "ronin kamishimo"
	desc = "An oddly shaped sleeveless vest-jacket of wandering ronin."
	color = CLOTHING_BLUE

/obj/item/clothing/suit/roguetown/shirt/kazengun_jacket
	name = "kazengun jacket"
	desc = "A classical Kazengun jacket."
	icon_state = "kazengun_jacket"
	item_state = "kazengun_jacket"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	boobed = TRUE
	flags_inv = HIDEBOOB
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|VITALS
	icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_kazengun/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'
