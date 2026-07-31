// Ported from Twilight-Axis: modular_twilight_axis/code/game/objects/items/rogueitems/metal_stuff.dm
// The /obj/item/craft_kit family (iron + steel tiers), steel_scrap, and metal_stake.
//
// Adaptation notes:
// - Source's icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi' doesn't exist in this
//   tree, so it was copied verbatim into
//   modular_dreamvalley/icons/twilight_craft_kits/misc.dmi (confirmed via the dmi's own zTXt
//   metadata that it contains the craft_kit_iron/craft_kit_steel/scrap_steel/m_stake icon states
//   used below - this repo's own pre-existing icons/roguetown/items/misc.dmi does NOT have these
//   states, so the copy was necessary rather than optional).
// - /obj/item/scrap and /obj/item/ingot/iron & /obj/item/ingot/steel already exist in this repo
//   (code/game/objects/items/rogueitems/repair_kits.dm, code/modules/roguetown/roguejobs/miner/rogueores.dm)
//   so only steel_scrap (the steel-tier counterpart to /obj/item/scrap) needed porting.
// - Did NOT port the source's /obj/item/ingot/attackby(...) override (breaking ingots into scrap by
//   attacking them directly with a stake/stake-tree-log). This repo already has an unrelated
//   /obj/item/ingot/attackby override (tongs-loading logic, in
//   code/modules/roguetown/roguejobs/miner/rogueores.dm) and DM does not allow redefining the same
//   proc twice on the same type across files. The equivalent recycling path is preserved via
//   /obj/item/metal_stake/attack_obj(), which already handles breaking /obj/item/ingot (iron or
//   steel) into scrap when the stake is used on the ingot as an object (not attackby-on-stake) —
//   this covers the intended "stake breaks steel down into steel_scrap for recycling" loop.
// - The associated GLOBAL_LIST_INIT(craft_iron, ...) / GLOBAL_LIST_INIT(craft_steel, ...) lists from
//   the source exist there only as reference/documentation lists (never read by any code in the
//   source repo's crafting recipe system — grepped and found no consumers) so they were not ported.
// - All 12 iron-tier and 8 steel-tier armor "result" pieces referenced by these kits are ported here
//   as well (see the "kit results" section below), because this repo's base armor files
//   (chainmail.dm, plate.dm, neck.dm, pants/chain.dm, feet.dm, wrists.dm) already define the base
//   steel-tier parent types and all the ARMOR_INT_*_IRON balance defines, but were missing the
//   specific /iron (and /handmade, /splint, /splintlegs) leaf subtypes that these craft kits produce.
//   Values, icon_states, and desc text are ported verbatim from Twilight-Axis so the results are
//   visually and mechanically identical to source.

/obj/item/craft_kit
	name = "iron craftkit"
	desc = "An empty metal box that is suitable for storing various pieces of hardware and other scrap. \
	Fill with reguired metal objects to create a various items."
	icon_state = "craft_kit_iron"
	icon = 'modular_dreamvalley/icons/twilight_craft_kits/misc.dmi'
	grid_width = 64
	grid_height = 32
	var/need_scrap = 3
	var/current_scrap = 0
	var/scrap = /obj/item/scrap
	var/material = /obj/item/ingot/iron
	var/result = null
	dropshrink = 0.7

/obj/item/craft_kit/Initialize(mapload)
	. = ..()
	var/obj/item/result_item = result
	if(result_item)
		name = "[initial(result_item.name)] craftkit"

/obj/item/craft_kit/attackby(obj/O, mob/living/user, params)
	if(!isitem(O))
		return
	if(!result)
		return
	var/obj/item/I = O
	if(I.anvilrepair || I.type == scrap)
		if(I.smeltresult == material || I.type == scrap)
			if(!do_after(user, 2 SECONDS, target = I))
				return
			user.visible_message(span_notice("[user] salvages [I] into usable materials."))
			qdel(I)
			current_scrap++
			if(current_scrap < need_scrap)
				var/visible_scrap = need_scrap - current_scrap
				to_chat(user, span_info("To fill [name], you need [visible_scrap] more..."))
			if(current_scrap >= need_scrap)
				var/quality = (user.get_skill_level(/datum/skill/craft/crafting) - 6) + (user.get_skill_level(/datum/skill/craft/blacksmithing) - 6) + (user.get_stat(STAT_INTELLIGENCE) - 10)
				if(prob(50 - ((10 - user.get_stat(STAT_FORTUNE))*10)))
					quality -= rand(1,5)
				var/obj/item/item_result = new result(get_turf(src))
				if(quality < 0)
					quality = quality * 5
					item_result.max_integrity += quality
					item_result.obj_integrity += quality + rand(-10, -100)
				qdel(src)
			return
		return
	return

/obj/item/craft_kit/steel
	name = "steel craftkit"
	icon_state = "craft_kit_steel"
	scrap = /obj/item/steel_scrap
	material = /obj/item/ingot/steel
	result = null

/obj/item/steel_scrap
	name = "steel scrap"
	desc = "Shingles and scrap, borne from violence upon steel. There may yet still be a use for these pieces. Steel scrap can be crafted into various craft kits."
	icon_state = "scrap_steel"
	icon = 'modular_dreamvalley/icons/twilight_craft_kits/misc.dmi'
	grid_width = 32
	grid_height = 32
	dropshrink = 0.7
	anvilrepair = /datum/skill/craft/blacksmithing

/obj/item/metal_stake
	name = "metal stake"
	icon_state = "m_stake"
	icon = 'modular_dreamvalley/icons/twilight_craft_kits/misc.dmi'
	desc = "A heavy, sharp, iron-reinforced stake. It can break steel items to scrap piles."
	grid_width = 32
	grid_height = 64
	force = 18
	throwforce = 5
	possible_item_intents = list(/datum/intent/stab, /datum/intent/pick)
	max_blade_int = 200
	max_integrity = 100
	static_debris = null
	tool_behaviour = TOOL_IMPROVISED_RETRACTOR
	obj_flags = null
	w_class = WEIGHT_CLASS_SMALL
	twohands_required = FALSE
	gripped_intents = null
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP

/obj/item/metal_stake/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = 0,"nx" = 11,"ny" = 0,"wx" = -4,"wy" = 0,"ex" = 2,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/metal_stake/attack_obj(obj/O, mob/living/user)
	. = ..()
	if(isitem(O))
		var/obj/item/I = O
		var/check_cout = 0
		if(istype(I, /obj/item/ingot))
			if(!do_after(user, 4 SECONDS, target = I))
				return
			to_chat(user, span_warning("The [user] breaks an [I] using stake into small parts!"))
			var/scrap_type = null
			if(istype(I, /obj/item/ingot/iron))
				scrap_type = /obj/item/scrap
			if(istype(I, /obj/item/ingot/steel))
				scrap_type = /obj/item/steel_scrap
			for(var/i in 1 to 3)
				new scrap_type(get_turf(I))
			qdel(I)
			return
		if(I.anvilrepair)
			if(!I.smeltresult || I.smeltresult == /obj/item/ash)
				return
			if(!do_after(user, 2 SECONDS, target = I))
				return
			if(I.smeltresult == /obj/item/ingot/iron)
				new /obj/item/scrap(get_turf(I))
				check_cout++
			if(I.smeltresult == /obj/item/ingot/steel)
				new /obj/item/steel_scrap(get_turf(I))
				check_cout++
			if(check_cout == 0)
				return
			to_chat(user, span_warning("The [user] breaks an [I] using stake into small parts!"))
			qdel(I)
			return

/obj/item/storage/belt/rogue/pouch/i_scrap
	populate_contents = list(
	/obj/item/ingot/iron,
	/obj/item/ingot/iron
	)

/obj/item/storage/belt/rogue/pouch/s_scrap
	populate_contents = list(
	/obj/item/ingot/steel,
	/obj/item/ingot/steel
	)

//======================================================================
// KIT RESULTS — the /iron (and related) leaf armor pieces these kits
// produce, ported from Twilight-Axis's base armor files since this
// repo's parent chains existed but these specific subtypes did not.
//======================================================================

// -- neck (chaincoif) --
/obj/item/clothing/neck/roguetown/chaincoif/iron
	name = "iron chain coif"
	desc = "A maille-hood, fashioned from interlinked iron rings. Levymen oft-wear these atop a padded coif or beneath a kettle, depending on the nature of their rally; be it to defend their hearth-and-home from beastes or Bandits."
	icon_state = "ichaincoif"
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_SIDE_IRON

/obj/item/clothing/neck/roguetown/chaincoif/iron/full
	name = "full iron chain coif"
	icon_state = "ifullchaincoif"
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	resistance_flags = FIRE_PROOF
	body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
	adjustable = CAN_CADJUST
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/neck/roguetown/chaincoif/iron/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "ichaincoif"
			flags_inv = HIDEEARS|HIDEHAIR
			body_parts_covered = NECK|HAIR|EARS|HEAD
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()
		else if(adjustable == CADJUSTED)
			adjustable = CAN_CADJUST
			if(toggle_icon_state)
				icon_state = "ifullchaincoif"
			flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
			body_parts_covered = NECK|MOUTH|NOSE|HAIR|EARS|HEAD
			body_parts_covered_dynamic = body_parts_covered
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_neck()
				H.update_inv_head()

// -- chainmail (haubergeon / hauberk) --
/obj/item/clothing/suit/roguetown/armor/chainmail/iron
	icon_state = "ihaubergeon"
	name = "iron haubergeon"
	desc = "A maille shirt fashioned from hundreds of interlinked iron rings. The humble combination of a haubergeon and gambeson \
	is favored amongst Vaeltis's levymen, alongside a sharpened spear and a cooled pint of ale."
	max_integrity = ARMOR_INT_CHEST_MEDIUM_IRON
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	name = "iron hauberk"
	desc = "A maille-aketon of iron, sleeved to cover both the arms and legs. Amongst the levymen, these robes of iron - while heftier \
	than gambesons - are coveted when facing the monsters who claw-and-bite at nite."
	icon_state = "ihauberk"
	item_state = "ihauberk"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_CHEST_MEDIUM_IRON

// -- plate (half-plate / full plate / cuirass) --
/obj/item/clothing/suit/roguetown/armor/plate/iron
	name = "iron half-plate"
	desc = "A padded iron cuirass, bottomed with segmented tassets. It is inexpensive yet robust; a desirable combination, which \
	has long-since led to its proliferation amongst most of Vaeltis's standing garrisons."
	body_parts_covered = CHEST | VITALS | LEGS //Reflects the sprite, which lacks pauldrons.
	icon_state = "ihalfplate"
	item_state = "ihalfplate"
	boobed = FALSE	//the armor just looks better with this, makes sense and is 8 sprites less
	max_integrity = ARMOR_INT_CHEST_PLATE_IRON
	armor_class = ARMOR_CLASS_MEDIUM
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/suit/roguetown/armor/plate/full/iron
	name = "iron plate armor"
	icon_state = "ironplate"
	desc = "A 'munition'-grade set of iron plate armor, fitted with pauldrons and tassets for additional coverage. Most \
	of these sets, produced within the last century, can trace their origins to an edict from Hammerhold's former King: one \
	which demanded a munitions run, but forgot to specify its tailoring towards the dwarven physique. </br>‎  </br>'Slow \
	to don-and-doff, without a trusted Levyman's aid..'"
	smeltresult = /obj/item/ingot/iron
	max_integrity = ARMOR_INT_CHEST_PLATE_IRON

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron
	name = "iron breastplate"
	desc = "An iron cuirass. While most would sneer at the idea of wearing 'lesser alloys', many-a-levyman can attest to its robustness."
	icon_state = "ibreastplate"
	boobed = FALSE	//the armor just looks better with this, makes sense and is 8 sprites less
	max_integrity = ARMOR_INT_CHEST_MEDIUM_IRON
	smeltresult = /obj/item/ingot/iron
	smelt_bar_num = 2

// -- brigandine (handmade "Jack-Of-Plate") --
/obj/item/clothing/suit/roguetown/armor/brigandine/light/handmade
	slot_flags = ITEM_SLOT_ARMOR
	name = "\"Jack-Of-Plate\" brigandine"
	desc = "This brigandine is an example of the painstaking work of a skilled, and very poor, craftsman. The gambeson, lined with metal parts and scraps of chain mail, is impossible to ruin even with such artistry."
	icon_state = "light_brigandine"
	blocksound = SOFTHIT
	body_parts_covered = COVERAGE_TORSO
	armor = ARMOR_PLATE
	max_integrity = ARMOR_INT_CHEST_LIGHT_IRON
	smeltresult = /obj/item/ingot/iron
	equip_delay_self = 40
	armor_class = ARMOR_CLASS_LIGHT
	w_class = WEIGHT_CLASS_BULKY

// -- wrists (splint bracers) --
/obj/item/clothing/wrists/roguetown/bracers/splint
	name = "splint bracers"
	desc = "A pair of leather sleeves backed with iron splints, couters, and shoulderpieces that protect your arms and remain decently light."
	body_parts_covered = ARMS
	icon_state = "ironsplintarms"
	item_state = "ironsplintarms"
	armor = ARMOR_BRIGANDINE //not plate armor, is leather + iron bits
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_SIDE_IRON
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	sewrepair = FALSE

// -- legs (chainlegs / splintlegs / kilt) --
/obj/item/clothing/under/roguetown/chainlegs/iron
	name = "iron chain chausses"
	icon_state = "ichain_legs"
	desc = "A set of maille-armored trousers, composed from interlinked iron rings."
	max_integrity = ARMOR_INT_LEG_IRON_CHAIN
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/under/roguetown/chainlegs/iron/kilt
	name = "iron chain kilt"
	desc = "An ankle-length iron maille skirt, warding cuts against the thighs without slowing the feet."
	icon_state = "ichainkilt"
	item_state = "ichainkilt"
	sleevetype = "ichainkilt"

/obj/item/clothing/under/roguetown/splintlegs
	name = "splinted leggings"
	desc = "A pair of leather pants backed with iron splints, offering superior protection while remaining lightweight."
	icon_state = "ironsplintlegs"
	item_state = "ironsplintlegs"
	max_integrity = ARMOR_INT_LEG_IRON_CHAIN
	armor = ARMOR_BRIGANDINE
	blocksound = SOFTHIT
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	armor_class = ARMOR_CLASS_LIGHT//splint leggings
	w_class = WEIGHT_CLASS_NORMAL
	sewrepair = FALSE

// -- feet (maille boots) --
/obj/item/clothing/shoes/roguetown/boots/maille/iron
	name = "iron maille boots"
	desc = "A pair of leather boots, reinforced with smaller iron plates along the feet and ankles. A thick layer of chainmail has been woven across \
	the cuffs of each boot, and tastefully riveted into place. Colloquially known as 'soldier's boots', due to its widespread usage amongst Vaeltis's \
	oft-conscripted levies."
	icon_state = "soldierboots"
	item_state = "soldierboots"
	max_integrity = ARMOR_INT_SIDE_IRON
	smeltresult = /obj/item/ingot/iron

//======================================================================
// CRAFT KIT SUBTYPES — iron tier
//======================================================================

/obj/item/craft_kit/full_chaincoif
	result = /obj/item/clothing/neck/roguetown/chaincoif/iron/full

/obj/item/craft_kit/haubergeon
	result = /obj/item/clothing/suit/roguetown/armor/chainmail/iron

/obj/item/craft_kit/hauberk
	result = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron

/obj/item/craft_kit/cuirass
	result = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron

/obj/item/craft_kit/halfplate
	result = /obj/item/clothing/suit/roguetown/armor/plate/iron

/obj/item/craft_kit/plate
	result = /obj/item/clothing/suit/roguetown/armor/plate/full/iron

/obj/item/craft_kit/brigandine_light
	result = /obj/item/clothing/suit/roguetown/armor/brigandine/light/handmade

/obj/item/craft_kit/splintarms
	result = /obj/item/clothing/wrists/roguetown/bracers/splint

/obj/item/craft_kit/chainlegs
	result = /obj/item/clothing/under/roguetown/chainlegs/iron

/obj/item/craft_kit/splintlegs
	result = /obj/item/clothing/under/roguetown/splintlegs

/obj/item/craft_kit/kilt
	result = /obj/item/clothing/under/roguetown/chainlegs/iron/kilt

/obj/item/craft_kit/lplateboots
	result = /obj/item/clothing/shoes/roguetown/boots/maille/iron

//======================================================================
// CRAFT KIT SUBTYPES — steel tier
//======================================================================

/obj/item/craft_kit/steel/full_chaincoif
	result = /obj/item/clothing/neck/roguetown/chaincoif/full

/obj/item/craft_kit/steel/haubergeon
	result = /obj/item/clothing/suit/roguetown/armor/chainmail

/obj/item/craft_kit/steel/hauberk
	result = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk

/obj/item/craft_kit/steel/cuirass
	result = /obj/item/clothing/suit/roguetown/armor/plate/cuirass

/obj/item/craft_kit/steel/halfplate
	result = /obj/item/clothing/suit/roguetown/armor/plate

/obj/item/craft_kit/steel/plate
	result = /obj/item/clothing/suit/roguetown/armor/plate/full

/obj/item/craft_kit/steel/chainlegs
	result = /obj/item/clothing/under/roguetown/chainlegs

/obj/item/craft_kit/steel/kilt
	result = /obj/item/clothing/under/roguetown/chainlegs/kilt
