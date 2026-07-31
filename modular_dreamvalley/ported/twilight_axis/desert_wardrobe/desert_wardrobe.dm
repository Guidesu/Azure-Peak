// Ported from Twilight-Axis. Source:
//   - modular_deserttown/desertclothing.dm (Desert/Sultanate wardrobe: sirwal, thawb, bisht/merchantbisht,
//     jafar set, sultan/sultana dress set, turban, tagelmust, Agha Scale armor)
//   - modular_twilight_axis/code/modules/jobs/job_types/roguetown/sidefolk/mercenary/miragefen.dm
//     (hooded/desert_hood, split out of a cloak-and-hood pair - only the hood is ported here, per
//     the requested port list)
//
// Adaptation notes:
// - Icons already existed pre-copied at modular_dreamvalley/icons/twilight_desert/ (armor.dmi,
//   armor_onmob.dmi, belts.dmi, belts_onmob.dmi, cloaks.dmi, cloaks_onmob.dmi, easternclothes.dmi,
//   easternclothes_onmob.dmi, head.dmi, head_onmob.dmi, head32x48.dmi, head32x48_onmob.dmi,
//   pants.dmi, pants_onmob.dmi, shirts.dmi, shirts_onmob.dmi) - confirmed via zTXt icon_state
//   metadata that these contain every icon_state referenced below (sirwal, thong, thawb, thawbgold,
//   dprince, sultan, sultana, jafar, turban, purple_hood, blue_hood, greythawb/bluethawb/purplethawb,
//   merbisht, huus is NOT in these sheets - see Agha Scale note below).
// - desert_hood's icon isn't in the twilight_desert set (it's from the base TA roguetown clothing
//   icons, not the desert-town module). Copied modular_twilight_axis/icons/roguetown/clothing/head.dmi
//   and onmob/head_48.dmi are NOT present in this tree either; rather than pull in a whole new icon
//   sheet for a single hood, reused this repo's own generic hood icon infrastructure: points at
//   modular_dreamvalley/icons/twilight_desert/head.dmi with icon_state "dprince" is wrong (that's
//   amira's dress hood-colored reuse) - instead the hood is wired to reuse the /obj/item/clothing/
//   head/hooded base icon defaults so it renders with the base hood sprite rather than dangle on a
//   missing icon_state. Mechanically identical (HEAD coverage, HIDEEARS|HIDEHAIR), just without a
//   unique desert sprite since that specific sheet wasn't part of the pre-copied icon set.
// - Agha Scale armor's icon_state "huus" is not present in any of the pre-copied twilight_desert
//   .dmi sheets (checked armor.dmi/armor_onmob.dmi contents - only openvest/cataphract/mamaluke/
//   merbisht exist there). Rather than dangle a missing icon_state, Agha Scale is pointed at the
//   already-verified "mamaluke" state (janissary chainmail) on the same armor.dmi/armor_onmob.dmi
//   sheet as a stand-in sprite, since both are scale/chain medium armors from the same set.
// - "sultan"/"sultana" here are Twilight-Axis's generic Zybantine noble-rank titles (not a proper
//   noun tied to a TA-specific god/faction), kept as-is like the sibling kazengun/branding ports do
//   for their own setting-flavor names.
// - Crafting recipes from the source (sewing bisht/thawb/turban/tagelmust/sirwal) were NOT ported -
//   task scope is the item definitions only.

//====================================================================
// Sirwal (baggy desert trousers)
//====================================================================

/obj/item/clothing/under/roguetown/sirwal
	name = "sirwal"
	desc = "Long, baggy trousers from Zybantium."
	color = null
	icon = 'modular_dreamvalley/icons/twilight_desert/pants.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/pants_onmob.dmi'
	icon_state = "sirwal"
	item_state = "sirwal"

/obj/item/clothing/under/roguetown/sirwal/beige
	color = "#edc6a5"

/obj/item/clothing/under/roguetown/sirwal/brown
	color = "#927351"

/obj/item/clothing/under/roguetown/sirwal/black
	color = CLOTHING_BLACK

/obj/item/clothing/under/roguetown/sirwal/plainrandom

/obj/item/clothing/under/roguetown/sirwal/plainrandom/Initialize()
	color = pick("#FFFFFF", "#edc6a5", "#927351", CLOTHING_BLACK)
	..()

/obj/item/clothing/under/roguetown/sirwal/fancy
	color = null
	name = "fancy sirwal"
	desc = "Long, baggy trousers from Zybantine dyed in expensive, exotic colours."

/obj/item/clothing/under/roguetown/sirwal/fancy/red
	color = CLOTHING_RED

/obj/item/clothing/under/roguetown/sirwal/fancy/blue
	color = CLOTHING_BLUE

/obj/item/clothing/under/roguetown/sirwal/fancy/purple
	color = CLOTHING_PURPLE

/obj/item/clothing/under/roguetown/sirwal/fancy/random

/obj/item/clothing/under/roguetown/sirwal/fancy/random/Initialize()
	color = pick(CLOTHING_BLACK, CLOTHING_BLUE, CLOTHING_PURPLE, CLOTHING_RED)
	..()

//====================================================================
// Thawb (Zybantine dress robe)
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/dress/thawb
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	name = "thawb"
	desc = "A long, loose Zybantine robe."
	armor = ARMOR_CLOTHING
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	icon = 'modular_dreamvalley/icons/twilight_desert/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/shirts_onmob.dmi'
	icon_state = "thawb"
	item_state = "thawb"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/black
	color = CLOTHING_BLACK

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/blue
	color = "#2f51b8"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/red
	color = "#9c4744"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/beige
	color = "#e9c792"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/brown
	color = "#846145"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/grey
	color = "#989898"

/obj/item/clothing/suit/roguetown/shirt/dress/thawb/gold
	name = "gold-trimmed thawb"
	desc = "A long, loose Zybantine robe. This one is trimmed with gold-silk thread."
	icon_state = "thawbgold"
	item_state = "thawbgold"

//====================================================================
// Bisht / merchantbisht
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/robe/bisht
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	name = "bisht"
	desc = "A long robe typical in Zybantine."
	icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes_onmob.dmi'
	icon_state = "greythawb"
	item_state = "greythawb"
	color = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|VITALS
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/grey
	color = "#989898"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/red
	color = "#9c4744"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/blue
	color = "#2f51b8"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/brown
	color = "#846145"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/beige
	color = "#e9c792"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/black
	color = CLOTHING_BLACK

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/bluegrey
	name = "grey bisht"
	icon_state = "bluethawb"
	item_state = "bluethawb"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/purple
	name = "purple bisht"
	icon_state = "purplethawb"
	item_state = "purplethawb"

/obj/item/clothing/suit/roguetown/shirt/robe/bisht/merchantbisht
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	body_parts_covered = CHEST|VITALS
	icon = 'modular_dreamvalley/icons/twilight_desert/armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/armor_onmob.dmi'
	name = "guild bisht"
	desc = "An open robe, made from luxurious silks."
	armor = ARMOR_PADDED
	icon_state = "merbisht"
	item_state = "merbisht"
	color = null

//====================================================================
// Jafar set (Zybantine magos robes + hat + sash)
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/jafar
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	name = "zybantine magos robes"
	desc = "A Zybantine magos noble robes."
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	boobed = FALSE
	icon = 'modular_dreamvalley/icons/twilight_desert/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/shirts_onmob.dmi'
	icon_state = "jafar"
	item_state = "jafar"
	flags_inv = HIDECROTCH|HIDEBOOB
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor = ARMOR_PADDED

/obj/item/clothing/head/roguetown/jafar
	name = "zybantine magos hat"
	desc = "Bask in its noble size and granduer!"
	icon = 'modular_dreamvalley/icons/twilight_desert/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/head32x48_onmob.dmi'
	icon_state = "jafar"
	item_state = "jafar"
	dynamic_hair_suffix = "+generic"
	flags_inv = HIDEEARS|HIDEHAIR
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HEAD

/obj/item/storage/belt/rogue/leather/jafar
	name = "Zybantine magos sash"
	icon = 'modular_dreamvalley/icons/twilight_desert/belts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/belts_onmob.dmi'
	icon_state = "jafar"
	sellprice = 30

//====================================================================
// Sultan / sultana dress set
//====================================================================

/obj/item/clothing/suit/roguetown/shirt/sultan
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	name = "sultans robes"
	desc = "A Zybantine Sultans noble robes."
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	boobed = FALSE
	icon = 'modular_dreamvalley/icons/twilight_desert/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "sultan"
	item_state = "sultan"
	flags_inv = HIDECROTCH|HIDEBOOB
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor = ARMOR_PADDED

/obj/item/clothing/suit/roguetown/shirt/sultana
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	name = "sultanas dress"
	desc = "A Zybantine Sultanas noble Dress."
	body_parts_covered = CHEST|GROIN|VITALS|LEGS|ARMS
	boobed = FALSE
	icon = 'modular_dreamvalley/icons/twilight_desert/shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/shirts_onmob.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "sultana"
	item_state = "sultana"
	flags_inv = HIDECROTCH|HIDEBOOB
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor = ARMOR_PADDED

/obj/item/clothing/head/roguetown/sultan
	name = "sultan's turban"
	desc = "Bask in its noble size and granduer!."
	icon = 'modular_dreamvalley/icons/twilight_desert/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/head32x48_onmob.dmi'
	icon_state = "sultan"
	item_state = "sultan"
	dynamic_hair_suffix = "+generic"
	flags_inv = HIDEEARS
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HEAD

/obj/item/clothing/head/roguetown/sultan/merchant
	name = "merchant's turban"
	desc = "A turban, large and elaborate, made of the finest silk money can buy."
	icon_state = "merchant"
	item_state = "merchant"

/obj/item/clothing/head/roguetown/sultan/amir
	name = "amir's turban"
	desc = "Soft, decadent, grandiouse, but above all - princely."
	icon_state = "amir"
	item_state = "amir"

/obj/item/clothing/head/roguetown/sultana
	name = "sultana's headdress"
	desc = "Silky smooth Zybantine silk headress!"
	icon = 'modular_dreamvalley/icons/twilight_desert/head.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/head_onmob.dmi'
	icon_state = "sultana"
	item_state = "sultana"
	dynamic_hair_suffix = "+generic"
	flags_inv = HIDEEARS|HIDEHAIR
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HEAD

/obj/item/storage/belt/rogue/leather/sultbelt
	name = "Zybantine Sultans sash"
	icon = 'modular_dreamvalley/icons/twilight_desert/belts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/belts_onmob.dmi'
	icon_state = "sultbelt"
	sellprice = 30

//====================================================================
// Turban / Tagelmust
//====================================================================

/obj/item/clothing/head/roguetown/turban
	name = "turban"
	desc = "A long cloth, wound around the head."
	color = null
	body_parts_covered = HEAD|HAIR|EARS|NECK
	flags_inv = HIDEHAIR|HIDEEARS
	icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes_onmob.dmi'
	icon_state = "turban"
	item_state = "turban"

/obj/item/clothing/head/roguetown/turban/tan
	color = "#93714b"

/obj/item/clothing/head/roguetown/turban/brown
	color = "#684f41"

/obj/item/clothing/head/roguetown/turban/dark
	color = "#414141"

/obj/item/clothing/head/roguetown/turban/grey
	color = "#848484"

/obj/item/clothing/head/roguetown/turban/red
	color = CLOTHING_RED

/obj/item/clothing/head/roguetown/turban/random

/obj/item/clothing/head/roguetown/turban/random/Initialize()
	color = pick("#414141", "#684f41", "#93714b", "#FFFFFF", "#848484")
	..()

/obj/item/clothing/head/roguetown/turban/fancypurple
	name = "fancy purple turban"
	desc = "A long, luxurious cloth, wound around the head."
	icon_state = "purple_hood"
	item_state = "purple_hood"

/obj/item/clothing/head/roguetown/tagelmust
	name = "tagelmust"
	desc = "A long cloth, wound around the head, and a veil."
	body_parts_covered = HEAD|EARS|HAIR|NECK|NOSE|MOUTH
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/easternclothes_onmob.dmi'
	icon_state = "blue_hood"
	item_state = "blue_hood"

//====================================================================
// Desert hood (from the desert cloak pairing; hood only, per port list)
//====================================================================

/obj/item/clothing/head/hooded/desert_hood
	name = "desert cloak hood"
	desc = "This one will shelter me from the sand."
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	edelay_type = 1
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEHAIR

//====================================================================
// Agha Scale armor
//====================================================================

/obj/item/clothing/suit/roguetown/armor/brigandine/agha
	name = "Agha Scale"
	desc = "Fine armor made of treated animal scales, denoting an esteemed career in the dunes."
	icon = 'modular_dreamvalley/icons/twilight_desert/armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/icons/twilight_desert/armor_onmob.dmi'
	icon_state = "mamaluke"
	item_state = "mamaluke"
	blocksound = SOFTHIT
	slot_flags = ITEM_SLOT_ARMOR
	blade_dulling = DULLING_BASHCHOP
	body_parts_covered = CHEST|GROIN|LEGS|VITALS|ARMS
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	armor_class = ARMOR_CLASS_MEDIUM
