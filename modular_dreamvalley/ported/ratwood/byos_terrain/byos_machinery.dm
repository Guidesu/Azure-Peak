// Vendor/trading machines used by byos.dmm.
//
// This repo's own code/modules/roguetown/roguemachine/merchant/navigator.dm
// already has a fully rewritten, much richer navigator/trade-economy system
// (SSmerchant_trade pools, duty/levy taxation, market saturation, etc) that
// replaced Ratwood's simple version entirely — including its own
// /obj/item/roguemachine/navigator/smuggler as the "black market" variant.
// So /obj/item/roguemachine/navigator/blackmarket is NOT ported as a
// duplicate base navigator (that would conflict with the existing one) —
// only the missing leaf itself, built on top of this repo's own navigator
// exactly the way /smuggler already is, so it gets full real economy
// behavior (duty evasion, market pools, etc) instead of a stub.
/obj/item/roguemachine/navigator/blackmarket
	name = "suspicious navigator"
	desc = "Freedom has a price."
	motto = "NA?!G@#OR - ████ ██████ █████████ - FREEDOM OF TRANSACTION."
	fixed_tax = 0.5
	pay_taxes = FALSE
	pay_merchant_share = FALSE
	grants_passive_favor = FALSE
	accepts_unmintable = TRUE
	is_bm_export = TRUE

/obj/item/roguemachine/navigator/blackmarket/get_market_saturation(category)
	if(!SSmerchant_trade || !category)
		return 1
	return SSmerchant_trade.get_bm_saturation_factor(category)

/obj/item/roguemachine/navigator/blackmarket/get_market_demand(category)
	if(!SSmerchant_trade || !category)
		return 1
	return SSmerchant_trade.get_bm_demand_multiplier(category)

/obj/item/roguemachine/navigator/blackmarket/credit_pool(category, base_price)
	if(!SSmerchant_trade || !category || base_price <= 0)
		return
	SSmerchant_trade.bm_pool_consumed[category] = (SSmerchant_trade.bm_pool_consumed[category] || 0) + base_price
	SSmerchant_trade.lifetime_bm_pool_credited[category] = (SSmerchant_trade.lifetime_bm_pool_credited[category] || 0) + base_price

// ---------------------------------------------------------------------------
// COPPERFACE — black market vendor structure (distinct from the navigator
// item above). Ported verbatim from Ratwood-2.0's
// code/modules/roguetown/roguemachine/blackmarket.dm — this repo has no
// equivalent /obj/structure/roguemachine/blackmarket at all. Its own
// budget/supply_pack economy (SSmerchant.supply_packs, get_real_price(),
// budget2change()) is intentionally kept separate from the navigator's
// SSmerchant_trade pool system above, matching how upstream Ratwood keeps
// them as two independent vendor mechanics.
// DESIGN NOTE (from source): the copperface exists once in the forest ruins
// near the bandit exit. Prices are steeper so as not to compete with the
// town merchant. Intended customers are wretches, bandits and other outlaws.

/obj/structure/roguemachine/blackmarket
	name = "COPPERFACE"
	desc = "Never gets tired, does not ask questions, only minor signs of tampering. Alas, fashioned with copper of low quality."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "copperface"
	density = TRUE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/held_items = list()
	var/budget = 0
	var/upgrade_flags
	var/current_cat = "1"
	var/list/categories = list(
		"General Labour",
		"Beverages",
		"Health and Hygiene"
	)
	var/list/categories_gamer = list(
		"Self Defense",
		"Diplomacy and Persuasion",
		"Exotic Import"
	)

/obj/structure/roguemachine/blackmarket/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/roguemachine/blackmarket/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	set_light(1, 1, 1, l_color = "#1b7bf1")
	add_overlay(mutable_appearance(icon, "vendor-merch"))

/obj/structure/roguemachine/blackmarket/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		return attack_hand(user)
	..()

/obj/structure/roguemachine/blackmarket/Topic(href, href_list)
	. = ..()
	if(!ishuman(usr))
		return
	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	if(href_list["buy"])
		var/mob/M = usr
		var/path = text2path(href_list["buy"])
		if(!ispath(path, /datum/supply_pack))
			message_admins("[usr.key] IS TRYING TO BUY A [path] WITH THE COPPERFACE. THIS SHOULDN'T BE POSSIBLE.")
			return
		var/datum/supply_pack/PA = SSmerchant.supply_packs[path]
		var/cost = PA.cost
		if(budget >= cost)
			budget -= cost
		else
			say("Not enough!")
			return
		var/shoplength = PA.contains.len
		var/l
		for(l=1,l<=shoplength,l++)
			var/pathi = pick(PA.contains)
			new pathi(get_turf(M))
	if(href_list["change"])
		if(budget > 0)
			budget2change(budget, usr)
			budget = 0
	if(href_list["changecat"])
		current_cat = href_list["changecat"]
	return attack_hand(usr)

/obj/structure/roguemachine/blackmarket/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/gold_menu.ogg', 100, FALSE, -1)
	var/canread = user.can_read(src, TRUE)
	var/contents = "<center>COPPERFACE - What's Yours.<BR>"
	contents += "<a href='?src=[REF(src)];change=1'>CURRENT BUDGET:</a> [budget]<BR>"
	contents += "</center><BR>"
	if(current_cat == "1")
		contents += "<table style='width: 100%' line-height: 20px;'>"
		for(var/i = 1, i <= categories.len, i++)
			contents += "<tr>"
			contents += "<td style='width: 50%; text-align: center;'>\
				<a href='?src=[REF(src)];changecat=[categories[i]]'>[categories[i]]</a>\
				</td>"
			if(i <= categories_gamer.len)
				contents += "<td style='width: 50%; text-align: center;'>\
					<a href='?src=[REF(src)];changecat=[categories_gamer[i]]'>[categories_gamer[i]]</a>\
				</td>"
			contents += "</tr>"
		contents += "</table>"
	else
		contents += "<center>[current_cat]<BR></center>"
		contents += "<center><a href='?src=[REF(src)];changecat=1'>\[RETURN\]</a><BR><BR></center>"
		var/list/pax = list()
		for(var/pack in SSmerchant.supply_packs)
			var/datum/supply_pack/PA = SSmerchant.supply_packs[pack]
			if(PA.group == current_cat)
				pax += PA
		for(var/datum/supply_pack/PA in sortNames(pax))
			var/costy = PA.cost
			contents += "[PA.name] - ([costy])<a href='?src=[REF(src)];buy=[PA.type]'>BUY</a><BR>"

	if(!canread)
		contents = stars(contents)

	var/datum/browser/popup = new(user, "VENDORTHING", "", 500, 800)
	popup.set_content(contents)
	popup.open()

/obj/structure/roguemachine/blackmarket/obj_break(damage_flag)
	..()
	budget2change(budget)
	set_light(0)
	update_icon()

/obj/structure/roguemachine/blackmarket/Destroy()
	set_light(0)
	return ..()

// ---------------------------------------------------------------------------
/obj/item/roguegear/bronze
	name = "cog"
	desc = "A cog with teeth meticulously crafted for tight interlocking."
	smeltresult = /obj/item/ingot/bronze

// ---------------------------------------------------------------------------
// Street/wall lamps. Parents (/obj/machinery/light/rogue/firebowl/standing,
// /obj/machinery/light/roguestreet) already exist in this codebase; icon
// files (lighting.dmi, tallstructure.dmi) already exist too, just missing
// a couple of specific animation frames for these variants — cosmetic only,
// doesn't affect compilation (icon_state/base_state are runtime string
// lookups, not compile-time validated against the .dmi's contents).

/obj/machinery/light/rogue/firebowl/standing/green
	icon_state = "standingg1"
	base_state = "standingg"
	bulb_colour = "#8ee2a7"
	desc = "Soft and green like... well, nothing you can really think of right now."

/obj/machinery/light/roguestreet/walllamp
	name = "wall lamp" // Crafted through metalizing sconce.
	desc = "An eerily glowing lamp attached to the wall via a caste iron frame. A promise of new technology at the dawn of a new age."
	icon_state = "wlamp1"
	base_state = "wlamp"
	brightness = 7.8
	max_integrity = 125
	density = FALSE

/obj/machinery/light/roguestreet/orange
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "o_slamp1"
	base_state = "o_slamp"
	brightness = 10.9
	bulb_colour = "#da8c45"
	bulb_power = 1
	resistance_flags = null // This one is craftable.

/obj/machinery/light/roguestreet/orange/walllamp
	name = "wall lamp"
	desc = "An eerily glowing lamp attached to the wall via a caste iron frame. A promise of new technology at the dawn of a new age."
	icon_state = "o_wlamp1"
	base_state = "o_wlamp"
	brightness = 7.8
	max_integrity = 125
	density = FALSE
	resistance_flags = null // This one is craftable.
