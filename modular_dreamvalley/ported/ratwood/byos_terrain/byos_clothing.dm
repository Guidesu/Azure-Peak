// Clothing items used by byos.dmm. Most are "ancient" (Zizo-era gilbranze)
// armor variants matching the pattern already used for weapons — cosmetic
// leaves on parents that already exist in this codebase, using icon_states
// that already exist in this repo's shared clothing icon sheets unless noted.
// A few items needed dedicated icon copies (see icons/byos_armor*.dmi etc,
// copied from Ratwood-2.0 since specific icon_states were missing from this
// repo's own armor.dmi/masks.dmi/shirts.dmi).

/obj/item/clothing/armor/leather/jacket/leathercoat/duelcoat
	name = "leather coat"
	desc = "A stylish coat worn by Duelists of Valoria. Light and flexible, it does not impede the complex movements they are known for. Well padded."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_armor.dmi'
	mob_overlay_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_armor_onmob.dmi'
	icon_state = "bwleathercoat"
	item_state = "bwleathercoat"
	boobed = TRUE
	slot_flags = ITEM_SLOT_ARMOR
	armor = ARMOR_LEATHER
	body_parts_covered = COVERAGE_ALL_BUT_LEGS
	detail_tag = "_detail"
	detail_color = "#FFFFFF"

/obj/item/clothing/armor/leather/jacket/leathercoat/duelcoat/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/armor/leather/jacket/leathercoat/duelcoat/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
			add_overlay(pic)

/obj/item/clothing/cloak/cape/inquisitor
	name = "arbiter cloak"
	desc = "The cloak of an Otavii arbiter, a class of warrior-priests within the Inquisition. Just as with the owner, the cloak has likely weathered some horrid sights."
	icon_state = "inquisitor_cloak"
	icon = 'icons/roguetown/clothing/cloaks.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'

/obj/item/clothing/cloak/stabard/guard
	name = "guard tabard"
	desc = "A tabard with the lord's heraldic colors."
	color = CLOTHING_AZURE
	detail_tag = "_spl"
	detail_color = CLOTHING_WHITE
	// This repo's own /obj/item/clothing/cloak/stabard base dropped the
	// heraldry-picker feature (no /picked var), so it's declared locally here
	// to keep the design-choice attack_right below working as in Ratwood.
	var/picked = FALSE

/obj/item/clothing/cloak/stabard/guard/attack_right(mob/user)
	if(picked)
		return
	var/the_time = world.time
	var/chosen = input(user, "Select a design.","Tabard Design") as null|anything in list("Split", "Quadrants", "Boxes", "Diamonds")
	if(world.time > (the_time + 10 SECONDS))
		return
	if(!chosen)
		return
	switch(chosen)
		if("Split")
			detail_tag = "_spl"
		if("Quadrants")
			detail_tag = "_quad"
		if("Boxes")
			detail_tag = "_box"
		if("Diamonds")
			detail_tag = "_dim"
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()
	if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
		detail_tag = initial(detail_tag)
		update_icon()
		if(ismob(loc))
			var/mob/L = loc
			L.update_inv_cloak()
		return
	picked = TRUE

/obj/item/clothing/cloak/stabard/guard/Initialize(mapload)
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/item/clothing/cloak/stabard/guard/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/cloak/stabard/guard/lordcolor(primary,secondary)
	color = primary
	detail_color = secondary
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()

/obj/item/clothing/cloak/stabard/guard/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/item/clothing/cloak/stabard/surcoat/guard
	desc = "A surcoat with the lord's heraldic colors."
	color = CLOTHING_AZURE
	detail_tag = "_quad"
	detail_color = CLOTHING_WHITE
	var/picked = FALSE

/obj/item/clothing/cloak/stabard/surcoat/guard/attack_right(mob/user)
	if(picked)
		return
	var/the_time = world.time
	var/chosen = input(user, "Select a design.","Tabard Design") as null|anything in list("Split", "Quadrants", "Boxes", "Diamonds")
	if(world.time > (the_time + 10 SECONDS))
		return
	if(!chosen)
		return
	switch(chosen)
		if("Split")
			detail_tag = "_spl"
		if("Quadrants")
			detail_tag = "_quad"
		if("Boxes")
			detail_tag = "_box"
		if("Diamonds")
			detail_tag = "_dim"
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()
	if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
		detail_tag = initial(detail_tag)
		update_icon()
		if(ismob(loc))
			var/mob/L = loc
			L.update_inv_cloak()
		return
	picked = TRUE

/obj/item/clothing/cloak/stabard/surcoat/guard/Initialize(mapload)
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/item/clothing/cloak/stabard/surcoat/guard/lordcolor(primary,secondary)
	color = primary
	detail_color = secondary
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()

/obj/item/clothing/cloak/stabard/surcoat/guard/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/item/clothing/cloak/stabard/guardhood
	name = "guard hood"
	desc = "A hood with the lord's heraldic colors."
	color = CLOTHING_AZURE
	detail_tag = "_spl"
	detail_color = CLOTHING_WHITE
	icon_state = "guard_hood"
	item_state = "guard_hood"
	body_parts_covered = CHEST
	var/picked = FALSE

/obj/item/clothing/cloak/stabard/guardhood/attack_right(mob/user)
	if(picked)
		return
	var/the_time = world.time
	var/chosen = input(user, "Select a design.","Tabard Design") as null|anything in list("Split")
	if(world.time > (the_time + 10 SECONDS))
		return
	if(!chosen)
		return
	switch(chosen)
		if("Split")
			detail_tag = "_spl"
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()
	if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
		detail_tag = initial(detail_tag)
		update_icon()
		if(ismob(loc))
			var/mob/L = loc
			L.update_inv_cloak()
		return
	picked = TRUE

/obj/item/clothing/cloak/stabard/guardhood/Initialize(mapload)
	. = ..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	GLOB.lordcolor += src

/obj/item/clothing/cloak/stabard/guardhood/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/cloak/stabard/guardhood/lordcolor(primary,secondary)
	color = primary
	detail_color = secondary
	update_icon()
	if(ismob(loc))
		var/mob/L = loc
		L.update_inv_cloak()

/obj/item/clothing/cloak/stabard/guardhood/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/item/clothing/gloves/roguetown/chain/ancient
	name = "ancient chain gauntlets"
	desc = "Polished gilbranze rings, delicately daisy-chained together into mittens. The filament is ruptured, and it will never heal; Zizo's ascension made sure of that. By the hands of Her disciples, the final obstacle preventing this world's salvation shall be dismantled - lyfe."
	icon_state = "acgloves"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/head/roguetown/helmet/heavy/ancient
	name = "ancient barbute"
	desc = "Polished gilbranze plates, pounded to form a visored helmet. Zizo commands ambition, and ambition commands sacrifice; let these sundered legionnaires rise again, to spill the blood of unenlightened fools. A coiled pocket is perched atop the rim, awaiting to be plumed."
	icon_state = "ancientbarbute"
	smeltresult = /obj/item/ingot/aaslag

// Note: source's attackby() let players add a colored feather plume via a
// GLOB.colorlist chooser dropdown. That global color-picker list doesn't
// exist in this repo's clothing system (dropped along with the tabard
// heraldry-picker feature, see /stabard/guard above), so the plume-adding
// interaction is left out rather than referencing a missing global — the
// helmet is otherwise fully functional armor.
/obj/item/clothing/head/roguetown/helmet/heavy/ancient/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/head/roguetown/helmet/heavy/guard/ancient
	name = "ancient savoyard"
	desc = "Polished gilbranze plates, molded into a bulwark's greathelm. The Comet Syon's glare has been forever burnt into the alloy; a decayed glimpse into the world that was, before Praecursor's slumber and Zizo's awakening."
	icon_state = "ancientsavoyard"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/mask/rogue/exoticsilkmask
	name = "exotic silk mask"
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_masks.dmi'
	mob_overlay_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_masks_onmob.dmi'
	icon_state = "exoticsilkmask"
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HIP
	sewrepair = TRUE
	adjustable = CAN_CADJUST
	toggle_icon_state = FALSE
	salvage_result = /obj/item/natural/silk
	salvage_amount = 2

/obj/item/clothing/mask/rogue/exoticsilkmask/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, NECK, null, null, 'sound/foley/equip/rummaging-03.ogg', null, (UPD_HEAD|UPD_MASK))

/obj/item/clothing/mask/rogue/facemask/ancient
	name = "ancient mask"
	desc = "Polished gilbranze, molded into an intimidating visage. Touch the cheek; it is warm, like flesh. But it is not flesh. Not yet."
	max_integrity = 200
	icon_state = "ancientmask"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/neck/roguetown/chaincoif/ancient
	name = "ancient coif"
	desc = "Polished gilbranze rings, linked together to form a billowing hood. Let it not be a crown of thorns that saves this dying world, but a crown of ambition; of fettered metal and stained bone, rejuvenated by Zizo's will to herald Her greatest works yet."
	icon_state = "achaincoif"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/neck/roguetown/collar/catbell
	name = "catbell collar"
	desc = "A leather collar with a jingling catbell attached."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_leashes_collars.dmi'
	icon_state = "catbellcollar"
	item_state = "catbellcollar"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/roguetown/collar/leather
	name = "leather collar"
	desc = "A sturdy leather collar."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_leashes_collars.dmi'
	icon_state = "leathercollar"
	item_state = "leathercollar"
	resistance_flags = FIRE_PROOF

// Judgment call: the map hardcodes this exact old type path directly (not
// under /gorget/), and Ratwood's real cursed_collar (modular/code/modules/
// slave_collar/cursed_collar.dm) is a full pet/master control feature this
// codebase never merged (no collar_master component, no COMSIG_CARBON_COLLAR_*
// signals, no cursed_collarable preference) — same situation as /obj/item/leash
// above. Ported using the self-contained "lesser cursed collar" flavor/behavior
// from Ratwood's /obj/item/clothing/neck/roguetown/gorget/cursed_collar
// instead, which is a real armor item with a real curse (can't self-unequip)
// and doesn't require the pet-control subsystem.
/obj/item/clothing/neck/roguetown/cursed_collar
	name = "cursed collar"
	desc = "A metal collar that seems to radiate an ominous aura. Looks like you'd need someone else's help to take it off."
	icon_state = "cursed_collar"
	item_state = "cursed_collar"
	armor = ARMOR_CLOTHING
	smeltresult = /obj/item/ingot/iron
	anvilrepair = /datum/skill/craft/armorsmithing
	max_integrity = ARMOR_INT_SIDE_DECREPIT
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	blocksound = PLATEHIT

/obj/item/clothing/neck/roguetown/cursed_collar/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/neck/roguetown/gorget/steel/ancient
	name = "ancient gorget"
	desc = "Polished gilbranze plates, layered atop one-another to guard the neck. The spine; a sacred leyline between spirit and sinew. It must remain unsevered, lest Her blessings be lost."
	icon_state = "ancientgorget"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/shoes/roguetown/sandals/ancient/decrepit
	name = "decrepit armored sandals"
	desc = "Frayed bronze platforms, curled about to cradle the feet. The beaches that these sandals once treaded are no more; pearly sands, long since turnt to glass from the Comet Syon's impact."
	max_integrity = 50
	color = "#bb9696"
	anvilrepair = null

/obj/item/clothing/suit/roguetown/armor/gambeson/fur
	name = "fur underarmor"
	desc = "A heavy set of hardened robes, lined with fur. The leather is composed of several creatures that were notably difficult to fell by arrow. A proof or rangership among many."
	icon_state = "hatanga"
	item_state = "hatanga"

/obj/item/clothing/suit/roguetown/armor/plate/ancient
	name = "ancient half-plate"
	desc = "Polished gilbranze layers, magewelded into plate armor. Let none impede the march of ambition, and let Her champions bring the unenlightened masses to kneel."
	icon_state = "ancientplate"
	item_state = "ancientplate"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/suit/roguetown/armor/plate/ancient/artificer
	name = "artificed half-plate"
	desc = "Polished gilbranze layers, magewelded into lightweight plate armor. It holds a slot for an arcyne meld to power it."
	icon_state = "artificerplate"
	item_state = "artificerplate"
	armor_class = ARMOR_CLASS_LIGHT
	var/powered = FALSE
	var/mode = 1
	var/active_item = FALSE
	var/legendaryarcane = FALSE
	var/legendaryathletics = FALSE

/obj/item/clothing/suit/roguetown/armor/plate/half
	slot_flags = ITEM_SLOT_ARMOR
	name = "steel cuirass"
	desc = "A basic cuirass of steel. Lightweight and durable. A crossbow bolt will probably go right through this, but not an arrow."
	body_parts_covered = COVERAGE_VEST
	icon_state = "cuirass"
	item_state = "cuirass"
	armor = ARMOR_PLATE
	allowed_race = CLOTHED_RACES_TYPES
	nodismemsleeves = TRUE
	blocking_behavior = null
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	armor_class = ARMOR_CLASS_MEDIUM
	smelt_bar_num = 2

/obj/item/clothing/suit/roguetown/armor/plate/half/ancient
	name = "ancient cuirass"
	desc = "Polished gilbranze, curved into a breastplate. It is not for the heart that beats no more, but for the spirit that flows through luxless marrow; one of Her many gifts."
	icon_state = "ancientcuirass"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	name = "exotic silk bra"
	desc = "An exquisite bra crafted from the finest silk and adorned with gold rings. It leaves little to the imagination."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_shirts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_shirts_onmob.dmi'
	icon_state = "exoticsilkbra"
	item_state = "exoticsilkbra"
	body_parts_covered = CHEST
	flags_inv = null

/obj/item/clothing/suit/roguetown/shirt/robe/mage
	color = "#4756d8"

/obj/item/clothing/suit/roguetown/shirt/robe/mage/Initialize(mapload)
	color = pick("#4756d8", "#759259", "#bf6f39", "#c1b144", "#b8252c")
	. = ..()

/obj/item/clothing/under/roguetown/chainlegs/kilt/ancient
	name = "ancient chain kilt"
	desc = "Polished gilbranze rings, linked together with bindings of silk to form a waist's vestment. These undying legionnaires once marched for Vheslyn, and again for Zizo; but now, they are utterly beholden to the whims of their resurrector."
	icon_state = "achainkilt"
	sleevetype = "achainkilt"
	smeltresult = /obj/item/ingot/aaslag
	anvilrepair = /datum/skill/craft/armorsmithing

/obj/item/clothing/wrists/roguetown/bracers/ancient
	name = "ancient bracers"
	desc = "Polished gilbranze cuffings, clasped around the wrists. Through ascension, the chains of mortality are broken; and only through death will the spirit be ready to embrace divinity."
	icon_state = "ancientbracers"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/storage/belt/rogue/leather/exoticsilkbelt
	name = "exotic silk belt"
	desc = "A gold adorned belt with the softest of silks barely concealing one's bits."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_belts.dmi'
	mob_overlay_icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_belts_onmob.dmi'
	icon_state = "exoticsilkbelt"
	var/max_storage = 5
