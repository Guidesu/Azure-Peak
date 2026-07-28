// Miscellaneous items used by byos.dmm that aren't clothing/weapons/food.
// See per-item notes for scope decisions made during porting.

// ---------------------------------------------------------------------------
// Arquebus pistol (obj/item/gun/ballistic/firearm/arquebus_pistol)
// Source: Ratwood-2.0 code/game/objects/items/rogueweapons/ranged/firearms/*
// Ratwood's firearms live entirely in a sibling module (modular_helmsguard)
// that this codebase never merged: a whole new combat skill
// (/datum/skill/combat/firearms), a new player trait (TRAIT_FUSILIER), and a
// dedicated caseless-bullet ammo family, plus its own icon/sound assets.
// Porting all of that for one map-placed pistol would mean importing an
// entire unrelated weapon-class feature. Scoped-down but real port: a working
// ballistic pistol built on this repo's existing /obj/item/gun/ballistic
// plumbing, firing a new minimal bullet casing/projectile, using the existing
// crossbows combat skill for accuracy scaling (closest existing "aimed
// ranged weapon" skill) instead of a new firearms skill tree entry.
/obj/item/ammo_casing/caseless/bullet
	name = "lead ball"
	desc = "A small lead ball for a firearm."
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt"
	projectile_type = /obj/projectile/bullet/lead_ball

/obj/projectile/bullet/lead_ball
	name = "lead ball"
	damage = 45

/obj/item/ammo_box/magazine/internal/arquebus
	name = "arquebus internal chamber"
	ammo_type = /obj/item/ammo_casing/caseless/bullet
	caliber = "lead_sphere"
	max_ammo = 1
	start_empty = TRUE

/obj/item/gun/ballistic/firearm
	name = "arquebus"
	desc = "A crude smokepowder weapon that shoots a heavy lead ball."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_arquebus.dmi'
	icon_state = "arquebus"
	item_state = "arquebus"
	force = 10
	force_wielded = 15
	internal_magazine = TRUE
	mag_type = /obj/item/ammo_box/magazine/internal/arquebus
	bolt_type = BOLT_TYPE_NO_BOLT
	casing_ejector = FALSE
	w_class = WEIGHT_CLASS_BULKY
	anvilrepair = /datum/skill/craft/engineering
	smeltresult = /obj/item/ingot/steel
	fire_sound = 'sound/blank.ogg'
	load_sound = 'sound/blank.ogg'
	eject_sound = 'sound/blank.ogg'

/obj/item/gun/ballistic/firearm/arquebus_pistol
	name = "arquebus pistol"
	desc = "A small smokepowder weapon, balanced for use in a single hand. A rare find this far from a proper armory."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_arquebus.dmi'
	icon_state = "arquebus"
	item_state = "arquebus"
	force = 10
	wlength = WLENGTH_SHORT
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	cartridge_wording = "lead ball"

/obj/item/quiver/bullet
	name = "lead ball pouch"
	desc = "This pouch can hold a handful of lead musket balls."
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "slingpouch"
	item_state = "slingpouch"
	slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_NECK
	max_storage = 8
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 64
	grid_width = 32
	allowed_ammo_type = /obj/item/ammo_casing/caseless/bullet

/obj/item/quiver/bullet/lead/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/bullet/B = new()
		arrows += B
	update_icon()

// ---------------------------------------------------------------------------
// Leash items (obj/item/leash, /leather, /chain)
// Source: Ratwood-2.0 code/game/objects/items/rogueitems/leash.dm
// The source leash is a full pet/master control system (status effects,
// movement redirection, a MOVESPEED_ID_LEASH multiplier, mutual grab/escape
// verbs). Nothing in this codebase's collar items (leashable = TRUE is set
// on several neck items but never read anywhere) currently hooks into any
// such system, confirming this whole feature was cut when this repo
// diverged from Ratwood. Porting the full pet-control mechanic here would
// resurrect an entire unused gameplay system for one set-dressing item.
// Ported as plain physical items (name/desc/icon/handling stats) instead —
// they still exist, are pickup-able, and look/feel correct on the map.
/obj/item/leash
	name = "rope leash"
	desc = "A simple rope with a knot at the end for easy attachment onto bindings."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_leashes_collars.dmi'
	icon_state = "leash"
	equip_sound = 'sound/foley/equip/rummaging-01.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	throw_range = 4
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_POCKET
	force = 1
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	grid_height = 32
	grid_width = 64
	dropshrink = 0.9

/obj/item/leash/leather
	name = "leather leash"
	desc = "A strip of treated leather with a metal clasp on the end for easy clipping onto bindings."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_leashes_collars.dmi'
	icon_state = "leatherleash"
	item_state = "leatherleash"

/obj/item/leash/chain
	name = "chain leash"
	desc = "A durable metal chain with a metal clasp on the end for easy clipping onto bindings."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_leashes_collars.dmi'
	icon_state = "chainleash"
	item_state = "chainleash"
	resistance_flags = FIRE_PROOF
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'

// ---------------------------------------------------------------------------
// Raw egg (obj/item/reagent_containers/food/snacks/egg). This repo replaced
// the vanilla roguetown food module with Neu_Food (modular/Neu_Food), which
// has a cooked friedegg but never ported a standalone raw egg item. Written
// fresh, following Neu_Food's own raw-food conventions (list_reagents,
// cooked_type transform on cooking), transforming into the friedegg already
// present at modular/Neu_Food/code/cooked/cooked_egg.dm.
/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "A raw egg, still in its shell."
	icon = 'modular/Neu_Food/icons/cooked/cooked_egg.dmi'
	icon_state = "rawegg"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	eat_effect = /datum/status_effect/debuff/uncookedfood
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	w_class = WEIGHT_CLASS_TINY

// ---------------------------------------------------------------------------
/obj/item/lovepotion
	name = "love potion"
	desc = "A pink potion with a faintly sweet and fruity aroma emanating from the bottle. The label reads \"Love Potion\" and says it will make nearly anyone desire you."
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "lovebottle"
	grid_width = 64
	grid_height = 64
	dropshrink = 0.8

/obj/item/lovepotion/attack(mob/living/carbon/human/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, span_warning("A love potion can only be metabolized by living beings. I'd best not waste it!"))
		return ..()
	if(user == M)
		to_chat(user, span_warning("It's too risky to consume this potion myself. Instead, I should feed it to someone I desire!"))
		return ..()
	if(M.has_status_effect(STATUS_EFFECT_INLOVE))
		to_chat(user, span_warning("[M] is already consumed by obsession for someone else!"))
		return ..()

	M.visible_message(span_danger("[user] starts to feed [M] a love potion!"),
		span_danger("[user] starts to feed you a love potion!"))

	if(!do_after(user, 50, target = M))
		return
	to_chat(user, span_notice("I feed [M] the love potion!"))
	to_chat(M, span_notice("I taste strawberries as the potion pours down my throat. My heart pounds against my chest as my mind becomes clouded with thoughts of [user]. Be this true love or be this obsession, it matters not. For I will have [user]."))
	if(M.mind)
		M.mind.store_memory("You are obsessed with [user].")
	M.faction |= "[REF(user)]"
	M.apply_status_effect(STATUS_EFFECT_INLOVE, user)
	qdel(src)

// ---------------------------------------------------------------------------
// Bottled wine. /obj/item/reagent_containers/glass/bottle/rogue base already
// exists implicitly in this codebase (parent /glass/bottle is fully defined,
// list_reagents is declared on the shared /obj/item/reagent_containers base)
// — only the emberwine leaf itself was missing.
//
// Source's /datum/reagent/consumable/ethanol/beer/emberwine (code/datums/
// sexcon/sexcon_reagents.dm) is a full aphrodisiac reagent wired into
// Ratwood's sexcon addiction/overdose/charflaw system. This repo has its own
// separate, already-ported sexcon feature set (modular_dreamvalley/ported/
// ratwood/sexcon_features) that doesn't include this reagent, and bolting
// the source version on wholesale would mean pulling in unrelated charflaw/
// patron-check code for a single bottle prop. Ported as a normal beer-tier
// alcoholic reagent instead — still a real, drinkable, intoxicating brew,
// just without the aphrodisiac/addiction side mechanic.
/datum/reagent/consumable/ethanol/beer/emberwine
	name = "Emberwine"
	description = "A searingly sweet, deep red wine."
	taste_description = "searing sweetness"
	boozepwr = 20
	color = "#721a46"

/obj/item/reagent_containers/glass/bottle/rogue/emberwine
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 24)
	desc = "A bottle with an unmarked, tannin-tinted cork-seal. Cheap wine, in all likelihood."

// ---------------------------------------------------------------------------
/obj/item/powderflask
	name = "powderflask"
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_arquebus_items.dmi'
	icon_state = "powderflask"
	item_state = "powderflask"
	desc = "A flask meant to carry fine smokepowder for a firearm."
	slot_flags = SLOT_BELT_L | SLOT_BELT_R | ITEM_SLOT_NECK | ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_SMALL
	grid_height = 64
	grid_width = 32
	dropshrink = 0.6

// ---------------------------------------------------------------------------
// Unfinished spellbook (obj/item/spellbook_unfinished/pre_arcyne)
// Source: Ratwood-2.0 modular_azurepeak/code/game/objects/items/spellbooks.dm
// The full source chain (blank scroll -> bound tome -> pre_arcyne -> finished
// /obj/item/book/spellbook via arcyne-gem crafting) belongs to a
// modular_azurepeak crafting feature that isn't present in this codebase at
// all (no /obj/item/book/spellbook, no modular_azurepeak folder). The map
// only places a single static pre_arcyne tome as set dressing (byos.dmm line
// 3457), so only the appearance is needed here — the interactive crafting
// attackby() chain is left out rather than resurrecting an unrelated
// crafting feature and its missing end-product type.
/obj/item/spellbook_unfinished
	name = "bound scrollpaper"
	desc = "Thick scroll paper bound at the spine. It lacks pages."
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "basic_book_0"
	dropshrink = 0.6
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "whacked", "educated")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'
	pickup_sound = 'sound/blank.ogg'

/obj/item/spellbook_unfinished/pre_arcyne
	name = "tome in waiting"
	icon_state = "spellbook_unfinished"
	desc = "A fully bound tome of scroll paper. It's lacking a certain arcyne energy."
	grid_width = 32
	grid_height = 64
