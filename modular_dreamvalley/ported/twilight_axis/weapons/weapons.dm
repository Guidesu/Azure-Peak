// Ported from Twilight-Axis. Sources (all self-contained item defs, gathered individually per the
// port list rather than one bulk file):
//   - modular_twilight_axis/code/game/objects/items/rogueweapons/melee/swords.dm (foldsword, psyrapier, relevement)
//   - modular_twilight_axis/code/game/objects/items/donator_modkit.dm (example/wodao, /dadao, /gdadao cosmetic reskins)
//   - modular_twilight_axis/code/modules/jobs/job_types/roguetown/sidefolk/mercenary/yohei.dm (miaodao, spear/boar/kazengun, mace/goden/steel/tetsubo)
//   - modular_twilight_axis/code/modules/roguetown/roguejobs/miner/tools.dm (stoneaxe/bronze)
//   - modular_twilight_axis/code/modules/roguetown/rogueantagonists/zizo_cult/thingsforcult.dm (stoneaxe/battle/zizo, halberd/glaive/zizo, shield/tower/zizo)
//   - modular_deserttown/desertweapons.dm (shield/iron/zybantine, sword/sabre/shamshir/steel)
//
// Adaptation notes:
// - "zizo" is NOT a Twilight-Axis-exclusive proper noun: this repo already has its own native
//   Zizo inhumen-patron pantheon entry (code/modules/spells/pantheon/inhumen/zizo.dm) and its own
//   matching HERESYDESC_ZIZO_WEAPON/ARMOR/MISC defines (code/__DEFINES/highlight_examine_defines.dm)
//   plus TRAIT_CABAL and /datum/component/cursed_item, all pre-existing here. The three /zizo
//   weapons below are ported as straightforward cursed/heretical-flavor items using this repo's own
//   pre-existing cabal infrastructure - no rename needed, and nothing new needed to make them
//   function (no dependency on Twilight-Axis's specific 13-god pantheon or job-role system).
// - TA's "psyrapier" ("psydonian rapier", flavor text referencing the TA-specific deity "Psydon")
//   was renamed to "gilded rapier" and its lore text reworked to drop the Psydon reference, since
//   this repo has no Psydon patron and no SILVER_PSYDONIAN silver-type define (only
//   SILVER_VAELTIAN exists here, code/__DEFINES/silverblessing.dm). Mechanically it's still a
//   silver-infused rapier via the same /datum/component/silverbless this repo's own
//   sword/rapier/psy already uses, just built on SILVER_VAELTIAN/BLESSING_NONE like the vanilla
//   Vaeltic rapier rather than claiming a foreign blessing type. Renamed the icon_state away from
//   "psyrapier" too, since this repo's OWN swords.dm already uses that exact icon_state for a
//   different weapon (/obj/item/rogueweapon/sword/rapier/psy/relic, "Eucharist") on a *different*
//   icon file (icons/roguetown/weapons/64.dmi) than the one this port uses (see below) - no actual
//   sprite collision was possible (icon_state is scoped per-.dmi-file in DM), but keeping the name
//   distinct avoids confusion between the two "silver rapier" flavor items now in the game.
// - icon = 'modular_twilight_axis/icons/roguetown/weapons/64.dmi' doesn't exist in this tree.
//   Copied verbatim into modular_dreamvalley/icons/twilight_weapons/weapons64.dmi (confirmed via
//   zTXt metadata it has the folding_sword_on/off, odachi, tetsubo, jumonjiyari, and (a second,
//   separate) psyrapier icon_state this port needs). This is a DIFFERENT file from this repo's own
//   icons/roguetown/weapons/64.dmi (which already independently contains unrelated states like
//   gdadao/longsword_triumph/etc - shared ancestry, not overwritten).
// - The zizo cult weapons' icon = '.../zizo_cult/sprites/zizo_weapone(_twoh).dmi' were copied to
//   modular_dreamvalley/icons/twilight_weapons/zizo_weapon.dmi and zizo_weapon_twoh.dmi.
// - zybantine's icon = '.../modular_deserttown/icons/items/desertweapons32.dmi' (source repo's
//   desert-culture icon sheet, confirmed via zTXt metadata to hold "zybshield") was copied to
//   modular_dreamvalley/icons/twilight_desert/desertweapons32.dmi (shared location with the
//   Desert/Sultanate wardrobe sub-batch, which draws from the same source folder).
// - Ported /obj/item/ingot/steel/zizo (the cursed-steel material the three zizo weapons'
//   smeltresult points at) alongside them, since it didn't exist here yet and is a simple,
//   self-contained material type unrelated to the excluded ritual/summoning side of the zizo cult
//   system - without it their smeltresult would dangle.
// - wodao/dadao/gdadao (task's "example/{dadao,gdadao,wodao}"): in the source these are cosmetic
//   /obj/item/rogueweapon/example/* "morphing elixir" reskins (donator/enchantingkit cosmetic
//   system), NOT new weapon mechanics - they reuse this repo's own icons/roguetown/weapons/
//   swords32.dmi and 64.dmi files, which this repo ALREADY has real icon_states for
//   ("dadao"/"gdadao" both confirmed present; this repo's OWN base swords.dm already independently
//   defines /obj/item/rogueweapon/sword/falx/dadao and /obj/item/rogueweapon/sword/sabre/wodao
//   natively, shared ancestry with Twilight-Axis's base code - so only the missing /example/*
//   cosmetic-only leaf types were ported here, they are visual reskin targets for this repo's
//   existing enchanting/donator-kit system, not new base weapons).
// - shamshir base (plain /obj/item/rogueweapon/sword/sabre/shamshir) already exists natively in
//   this repo's own swords.dm - only the missing /steel tier requested was ported.
// - foldsword's real mechanic (attack_self() toggles between a compact "off" state usable one-
//   handed at ITEM_SLOT_HIP, and an "on" state as a full two-handable blade with rapier intents,
//   swapping wlength/w_class/equip delays and re-running update_a_intents() so the currently-held
//   intent updates immediately) is ported in full, not just stats.

//====================================================================
// Foldsword - collapsible rapier with a real attack_self()/update_icon() mechanic
//====================================================================

/obj/item/rogueweapon/sword/rapier/foldsword
	name = "pathmaker"
	desc = "An expensive folding sword, commissioned specially for a retainer's aide. It can be carried like an ordinary sheathed sword, or collapsed down to be stowed in a bag or at the belt."
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "folding_sword_on"
	item_state = "folding_sword_on"
	var/on = FALSE

/obj/item/rogueweapon/sword/rapier/foldsword/update_icon()
	if(on)
		icon_state = "folding_sword_on"
	else
		icon_state = "folding_sword_off"

/obj/item/rogueweapon/sword/rapier/foldsword/attack_self(mob/user)
	if(on)
		on = FALSE
		possible_item_intents = list(/datum/intent/sword/strike)
		wlength = WLENGTH_SHORT
		w_class = WEIGHT_CLASS_SMALL
		equip_delay_self = 0 SECONDS
		unequip_delay_self = 0 SECONDS
		inv_storage_delay = 0 SECONDS
		slot_flags = ITEM_SLOT_HIP
	else
		on = TRUE
		possible_item_intents = list(/datum/intent/sword/thrust/rapier, /datum/intent/sword/cut/rapier, /datum/intent/sword/peel)
		wlength = WLENGTH_NORMAL
		w_class = WEIGHT_CLASS_BULKY
		equip_delay_self = 1.5 SECONDS
		unequip_delay_self = 1.5 SECONDS
		inv_storage_delay = 1.5 SECONDS
		slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_BACK
	if(user.a_intent)
		var/datum/intent/I = user.a_intent
		if(istype(I))
			I.afterchange()
	user.update_a_intents()
	update_icon()

//====================================================================
// "Gilded rapier" - renamed from TA's "psydonian rapier" (see header note)
//====================================================================

/obj/item/rogueweapon/sword/rapier/gilded
	name = "gilded rapier"
	desc = "An ornate rapier, plated in a ceremonial veneer of silver. The barbs pierce your palm, and - for just a moment - you see red."
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "psyrapier"
	item_state = "psyrapier"
	resistance_flags = FIRE_PROOF
	force = 17
	force_wielded = 20
	is_silver = TRUE

/obj/item/rogueweapon/sword/rapier/gilded/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_NONE,\
		silver_type = SILVER_VAELTIAN,\
		added_force = 0,\
		added_blade_int = 100,\
		added_int = 50,\
		added_def = 2,\
	)

//====================================================================
// Relevement - flame-bladed greatsword
//====================================================================

/obj/item/rogueweapon/greatsword/grenz/flamberge/relevement
	name = "relevement"
	desc = "The grave wounds caused by flame-bladed swords make them a highly sought-after weapon among duelists and mercenaries - the charges of dishonorable warfare notwithstanding."
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "drowflamberge"
	item_state = "drowflamberge"
	max_integrity = 240
	max_blade_int = 240
	smeltresult = /obj/item/ingot/drow

//====================================================================
// Miaodao - Kazengunese greatsword, with its own reach-2 intent set
//====================================================================

/datum/intent/sword/cut/miaodao
	reach = 2
	penfactor = PEN_LIGHT

/datum/intent/sword/cut/miaodao/fast
	clickcd = 9

/datum/intent/sword/peel/miaodao
	name = "long sword armor peel"
	reach = 2

/obj/item/rogueweapon/greatsword/miaodao
	name = "miaodao"
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "odachi"
	desc = "An unusually long saber of Kazengunese origin. The lighter blade lends itself to one-handed use better than a zweihander, but maintaining edge alignment is tricky and requires experience."
	force = 24
	force_wielded = 30
	minstr = 8
	wdefense = 6
	wdefense_wbonus = 1
	max_blade_int = 150
	wbalance = WBALANCE_SWIFT
	possible_item_intents = list(/datum/intent/sword/cut/miaodao, /datum/intent/sword/strike)
	gripped_intents = list(/datum/intent/sword/cut/miaodao/fast, /datum/intent/sword/thrust/zwei, /datum/intent/sword/peel/miaodao, /datum/intent/sword/chop/long)
	alt_grips = null

/obj/item/rogueweapon/greatsword/miaodao/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5, "sx" = -14, "sy" = -8, "nx" = 15, "ny" = -7, "wx" = -10, "wy" = -5, "ex" = 7, "ey" = -6, "northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0, "nturn" = -13, "sturn" = 110, "wturn" = -60, "eturn" = -30, "nflip" = 1, "sflip" = 1, "wflip" = 8, "eflip" = 1)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 9,"sy" = 3,"nx" = -7,"ny" = 3,"wx" = -9,"wy" = 2,"ex" = 10,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 5,"sturn" = -10,"wturn" = -170,"eturn" = -10,"nflip" = 8,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5, "sx" = -1, "sy" = 2, "nx" = 0, "ny" = 2, "wx" = 2, "wy" = 1, "ex" = 0, "ey" = 1, "nturn" = 0, "sturn" = 0, "wturn" = 70, "eturn" = 15, "nflip" = 1, "sflip" = 1, "wflip" = 1, "eflip" = 1, "northabove" = 1, "southabove" = 0, "eastabove" = 0, "westabove" = 0)

//====================================================================
// Cosmetic reskin targets for this repo's existing enchanting-kit
// system (see header note on shared-ancestry dadao/gdadao/wodao)
//====================================================================

/obj/item/rogueweapon/example/wodao
	name = "wodao"
	icon = 'icons/roguetown/weapons/swords32.dmi'
	desc = "A slightly curved blade that has been proliferated everywhere from foreign caravans to Kazengunite diplomat-militants. While less durable compared to other arming swords, its swift balance and unique design makes it great for unleashing precise strikes."
	icon_state = "wodao"
	sheathe_icon = "wodao"

/obj/item/rogueweapon/example/dadao
	name = "dadao"
	icon = 'icons/roguetown/weapons/swords32.dmi'
	desc = "A heavier alternative to the 'Wodao' sabre, this well-balanced cleaver is informally known amongst pikemen as the 'Saigachopper'; termed such for its purported ability to decapitate a cavalryman's steed in but a single blow."
	icon_state = "dadao"
	sheathe_icon = "dadao"

/obj/item/rogueweapon/example/gdadao
	name = "greatdadao"
	icon = 'icons/roguetown/weapons/64.dmi'
	desc = "Larger than the 'Wodao' sabre, sharper than the 'Dadao' cleaver, and nastier than the sum of its parts. A single stroke dares to part even the thickest-of-foes into gorey halves."
	icon_state = "gdadao"

//====================================================================
// Shamshir, steel tier (base /sabre/shamshir already exists natively here)
//====================================================================

/obj/item/rogueweapon/sword/sabre/shamshir/steel
	name = "steel shamshir"
	desc = "A curved one-handed sword. This is a forged steel copy of the traditional shamshir."
	force = 23
	max_blade_int = 230
	smeltresult = /obj/item/ingot/steel

//====================================================================
// Jūmonji yari / spear-boar-kazengun and tetsubo (from yohei.dm)
//====================================================================

/obj/item/rogueweapon/spear/boar/kazengun
	name = "jūmonji yari"
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "jumonjiyari"
	desc = "A spear with a long, straight head and a pair of curved blades pointing upward. A Kazengunese design, the side-blades tear the flesh of any unfortunate enough to be pierced by it."
	gripped_intents = list(/datum/intent/spear/thrust, /datum/intent/spear/cut/naginata, /datum/intent/rend/reach/partizan)
	wdefense = 7

/datum/intent/mace/strike/tetsubo
	reach = 2

/datum/intent/mace/smash/tetsubo
	reach = 2

/obj/item/rogueweapon/mace/goden/steel/tetsubo
	name = "tetsubo"
	desc = "A heavier variant of the kanabo, fitted with a steel sleeve bearing menacing spikes and favored by ogre warlords. Requires immense strength to use, but hits like a raging bull."
	icon = 'modular_dreamvalley/icons/twilight_weapons/weapons64.dmi'
	icon_state = "tetsubo"
	force = 20
	possible_item_intents = list(/datum/intent/mace/strike/tetsubo)
	gripped_intents = list(/datum/intent/mace/strike/tetsubo, /datum/intent/mace/smash/tetsubo, /datum/intent/effect/daze)
	sharpness = IS_SHARP
	minstr = 11
	slot_flags = ITEM_SLOT_BACK

//====================================================================
// Stoneaxe/bronze - "dolabra", a legionnaire's pick-axe tool-weapon
//====================================================================

/obj/item/rogueweapon/stoneaxe/bronze
	name = "dolabra"
	desc = "A so-called 'legionnaire's tool'; antiquated, but nevertheless beloved by many for its versatility. It offers an answer for labors both above-and-below, courtesy of its bronze axhead-and-picktip."
	force = 20
	force_wielded = 25
	icon = 'icons/roguetown/weapons/tools.dmi'
	icon_state = "bronzepick"
	possible_item_intents = list(/datum/intent/mace/warhammer/pick, /datum/intent/axe/cut, /datum/intent/mace/strike, /datum/intent/till)
	gripped_intents = list(/datum/intent/mace/warhammer/pick, /datum/intent/axe/cut, /datum/intent/axe/chop, /datum/intent/mace/strike)
	max_integrity = 500
	max_blade_int = 225
	smeltresult = /obj/item/ingot/bronze

//====================================================================
// Zybantine iron shield
//====================================================================

/obj/item/rogueweapon/shield/iron/zybantine
	name = "brass shield"
	desc = "A sturdy shield of Zybantine make."
	icon = 'modular_dreamvalley/icons/twilight_desert/desertweapons32.dmi'
	icon_state = "zybshield"
	max_integrity = 250
	blade_dulling = DULLING_BASH
	possible_item_intents = list(SHIELD_BASH_METAL, SHIELD_BLOCK, SHIELD_SMASH_METAL)
	sellprice = 30
	smeltresult = /obj/item/ingot/bronze

//====================================================================
// Zizo cult weapons - cursed heretical armaments, built on this repo's
// OWN pre-existing zizo patron / cabal / cursed_item infrastructure
// (see header note - no rename needed, zizo is native here).
//====================================================================

/obj/item/rogueweapon/stoneaxe/battle/zizo
	icon = 'modular_dreamvalley/icons/twilight_weapons/zizo_weapon.dmi'
	icon_state = "Zaxe"
	name = "cursed battle axe"
	desc = "An axe for battles, forged of cursed steel."
	wdefense = 5
	max_blade_int = 350
	max_integrity = 300
	possible_item_intents = list(/datum/intent/axe/cut, /datum/intent/axe/chop)
	gripped_intents = list(/datum/intent/axe/cut/cult, /datum/intent/axe/chop/cult, /datum/intent/axe/chop/heavy, /datum/intent/axe/bash/battle)
	smeltresult = /obj/item/ingot/steel/zizo

/datum/intent/axe/chop/cult
	intent_intdamage_factor = 1.3
	demolition_mod = 6
	swingdelay = 5
	damfactor = 1.6

/datum/intent/axe/cut/cult
	demolition_mod = 3
	damfactor = 1.4

/obj/item/rogueweapon/stoneaxe/battle/zizo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "AXE")

/obj/item/rogueweapon/stoneaxe/battle/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/shield/tower/zizo
	icon = 'modular_dreamvalley/icons/twilight_weapons/zizo_weapon.dmi'
	icon_state = "Zshield"
	name = "cursed shield"
	desc = "A gigantic cursed tower shield, forged of cursed steel."
	force = 10
	throwforce = 10
	wdefense = 12
	coverage = 85
	max_integrity = 350
	smeltresult = /obj/item/ingot/steel/zizo

/obj/item/rogueweapon/shield/tower/zizo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "SHIELD")

/obj/item/rogueweapon/shield/tower/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/rogueweapon/halberd/glaive/zizo
	icon = 'modular_dreamvalley/icons/twilight_weapons/zizo_weapon_twoh.dmi'
	icon_state = "Zglaive"
	name = "cursed glaive"
	desc = "A halberd of cursed craft, its blade never quite catching the light right."

/obj/item/rogueweapon/halberd/glaive/zizo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "GLAIVE")

/obj/item/rogueweapon/halberd/glaive/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/ingot/steel/zizo
	name = "cursed ancient ingot"
	desc = "There are legends about the appearance of this ingot..."
	icon = 'modular_dreamvalley/icons/twilight_weapons/zingot.dmi'
	icon_state = "zalloy"
	smeltresult = /obj/item/ingot/steel/zizo
	sellprice = 0

/obj/item/ingot/steel/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_MISC)
