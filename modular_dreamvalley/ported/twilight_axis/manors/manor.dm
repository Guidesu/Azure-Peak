// Ported from Twilight-Axis: player-ownable manors with workstations that
// produce trade goods and money on an idle dawn/dusk cycle. Player-facing
// text (chat messages, mail letters) has been translated from the source's
// Russian into English; mechanics are otherwise a faithful port.
//
// Persistence: unlike the source (round-scoped only — a manor is rebuilt
// from scratch every round via on_creation()), this fork's characters
// persist indefinitely across Far Travel/parking/continuing, so manor
// ownership and workstation state are captured/restored by the campaign
// graph (see character_graph.dm's capture_character_manor/
// restore_character_manor) rather than reset every session.

/proc/process_manor_production_cycle(is_dawn = FALSE, is_dusk = FALSE)
	for(var/mob/living/carbon/human/player as anything in GLOB.player_list)
		if(!player?.mind)
			continue
		var/datum/manor/manor = player.mind.get_owned_manor()
		if(!manor)
			continue
		manor.produce_resources(player, is_dawn, is_dusk)

/datum/mind
	var/datum/manor/owned_manor = null
	var/list/manor_packages = list()

/mob/living/carbon/human
	var/check_manor_pref = TRUE

/datum/mind/proc/get_owned_manor()
	return owned_manor

/datum/mind/proc/set_owned_manor(datum/manor/manor)
	owned_manor = manor
	return owned_manor

/datum/manor
	var/manor_name = "Unknown Estate"
	var/manor_size = "small"
	var/manor_type = "manor"
	var/datum/virtue/origin/virtue_origin
	var/min_workers = 5
	var/total_workers = 5
	var/workers_limit = 5
	var/patron = /datum/patron/concordat/auxentius
	var/last_cycle_productivity = 0
	var/list/workstations = list()
	var/list/workstation_types = list(/datum/workstation/field)

/datum/manor/proc/get_owner_display_name(mob/living/carbon/human/owner)
	if(owner?.client?.prefs?.manor_name && length(owner.client.prefs.manor_name))
		return owner.client.prefs.manor_name
	return "Unknown Estate"

/datum/manor/proc/get_owner_manor_type(mob/living/carbon/human/owner)
	if(owner?.client?.prefs?.manor_type && length(owner.client.prefs.manor_type))
		return owner.client.prefs.manor_type
	return manor_type

/datum/manor/proc/is_foreign_estate(mob/living/carbon/human/owner)
	if(!owner)
		return FALSE
	return HAS_TRAIT(owner, TRAIT_NOBLE) && HAS_TRAIT(owner, TRAIT_OUTLANDER)

/datum/manor/proc/get_manor_size(mob/living/carbon/human/owner)
	if(owner)
		if(is_foreign_estate(owner))
			if(owner?.client?.prefs?.virtue_origin)
				virtue_origin = owner.client.prefs.virtue_origin
			else
				virtue_origin = new /datum/virtue/origin/unknown
			return "small"
		if(owner.advjob == "Knight Banneret" || (owner.mind?.assigned_role in list("Marshal", "Steward", "Hand")))
			return "big"
		if(owner.mind?.assigned_role in list("Councillor", "Knight", "Royal Knight"))
			return "medium"
	return "small"

/datum/manor/proc/set_up_patron_bonuses(max_workers)
	switch(patron)
		if(/datum/patron/tribunal/praecursor)
			var/datum/workstation/cathedral/new_cathedral = new /datum/workstation/cathedral()
			workstations += new_cathedral
			max_workers += new_cathedral.workstation_size
		if(/datum/patron/concordat/viator)
			var/has_trade_district = FALSE
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/trade))
					ws.workstation_size += 5
					max_workers += 5
					has_trade_district = TRUE
			if(!has_trade_district)
				var/datum/workstation/trade/new_trade = new /datum/workstation/trade()
				workstations += new_trade
				max_workers += new_trade.workstation_size
		if(/datum/patron/severance/ignatius)
			var/has_hunt_district = FALSE
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/hunt))
					ws.workstation_size += 5
					max_workers += 5
					has_hunt_district = TRUE
			if(!has_hunt_district)
				var/datum/workstation/hunt/new_hunt = new /datum/workstation/hunt()
				workstations += new_hunt
				max_workers += new_hunt.workstation_size
		if(/datum/patron/concordat/miluse)
			for(var/datum/workstation/ws in workstations)
				ws.production_modifier = 1.1
				if(istype(ws, /datum/workstation/field) || istype(ws, /datum/workstation/fruit))
					ws.production_modifier = 0.8
				else if(istype(ws, /datum/workstation/hunt))
					ws.production_modifier = 1.3
		if(/datum/patron/unveiled/aurelian)
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/trade))
					ws.production_modifier = 0.5
		if(/datum/patron/concordat/handwerra)
			var/has_mine_district = FALSE
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/mining))
					ws.workstation_size += 5
					max_workers += 5
					has_mine_district = TRUE
			if(!has_mine_district)
				var/datum/workstation/mining/new_mining = new /datum/workstation/mining()
				workstations += new_mining
				max_workers += new_mining.workstation_size
		if(/datum/patron/concordat/wulfric)
			var/has_fish_district = FALSE
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/fish))
					ws.workstation_size += 5
					max_workers += 5
					has_fish_district = TRUE
			if(!has_fish_district)
				var/datum/workstation/fish/new_fish = new /datum/workstation/fish()
				workstations += new_fish
				max_workers += new_fish.workstation_size
		if(/datum/patron/concordat/auxentius, /datum/patron/concordat/auxentius)
			var/has_outpost = FALSE
			for(var/datum/workstation/ws in workstations)
				if(istype(ws, /datum/workstation/outpost))
					has_outpost = TRUE
			if(!has_outpost)
				var/datum/workstation/outpost/new_outpost = new /datum/workstation/outpost()
				workstations += new_outpost
				max_workers += new_outpost.workstation_size
	return max_workers

/datum/manor/proc/update_workstation_types(type = "manor", manor_size = "big")
	if(!type)
		type = manor_type
	switch(manor_size)
		if("big")
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field/big,
						/datum/workstation/farm,
						/datum/workstation/trade
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt/big,
						/datum/workstation/fruit,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish/medium,
						/datum/workstation/field/medium,
						/datum/workstation/trade/medium
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining/big,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/fruit/medium,
						/datum/workstation/hunt/medium,
					)
			min_workers = 15
		if("medium")
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/trade,
						/datum/workstation/farm
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt/medium,
						/datum/workstation/fruit,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish/medium,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining/medium,
						/datum/workstation/field,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field/medium,
						/datum/workstation/fruit,
						/datum/workstation/hunt,
					)
			min_workers = 10
		else
			switch(type)
				if("village")
					workstation_types = list(
						/datum/workstation/field,
						/datum/workstation/farm
					)
				if("hunter_mansion")
					workstation_types = list(
						/datum/workstation/hunt,
						/datum/workstation/forest
					)
				if("fisher_hamlet")
					workstation_types = list(
						/datum/workstation/fish,
						/datum/workstation/field
					)
				if("mining_settlement")
					workstation_types = list(
						/datum/workstation/mining,
						/datum/workstation/trade
					)
				else
					workstation_types = list(
						/datum/workstation/field,
						/datum/workstation/fruit,
					)

/datum/manor/proc/get_owner_patron(mob/living/carbon/human/owner)
	if(!owner || !owner.mind)
		return null
	if(owner.patron)
		return owner.patron.type
	return null

/datum/manor/proc/on_creation(mob/living/carbon/human/owner)
	workers_limit = 0

	manor_name = get_owner_display_name(owner)
	manor_type = get_owner_manor_type(owner)
	manor_size = get_manor_size(owner)
	update_workstation_types(manor_type, manor_size)

	var/owner_patron = get_owner_patron(owner)
	if(owner_patron)
		patron = owner_patron

	workstations = list()
	for(var/workstation_type in workstation_types)
		var/datum/workstation/new_workstation = new workstation_type()
		workstations += new_workstation
		workers_limit += new_workstation.workstation_size

	workers_limit = set_up_patron_bonuses(workers_limit)

	if(workers_limit < min_workers)
		workers_limit = min_workers
	if(patron == /datum/patron/oldkin/volkovoi)
		total_workers = min_workers
	else
		total_workers = rand(min_workers, workers_limit)

/datum/manor/proc/ensure_initialized(mob/living/carbon/human/owner)
	if(!length(workstations))
		on_creation(owner)
	if(total_workers < min_workers)
		total_workers = min_workers
	return src

/datum/manor/proc/get_assigned_workers()
	. = 0
	for(var/datum/workstation/workstation in workstations)
		. += workstation.workers_employed

/datum/manor/proc/get_free_workers()
	return max(total_workers - get_assigned_workers(), 0)

/datum/manor/proc/get_outpost_workers()
	var/list/total = list("workers" = 0, "production_modifier" = 1)
	for(var/datum/workstation/ws in workstations)
		if(istype(ws, /datum/workstation/outpost))
			total["workers"] += ws.workers_employed
			total["production_modifier"] = ws.production_modifier
	return total

/datum/manor/proc/get_stockpile_entry_for_good(good_path)
	if(!good_path)
		return null
	var/datum/roguestock/stockpile/stockpile = new good_path()
	if(!stockpile)
		return null
	var/trade_good_id = stockpile.trade_good_id
	qdel(stockpile)
	if(!trade_good_id)
		return null
	return SSeconomy.find_stockpile_by_trade_good(trade_good_id)

/datum/manor/proc/send_foreign_estate_income_mail(mob/living/carbon/human/owner, total_profit_money, estate_levy, import_tariff)
	if(!owner)
		return
	if(!SSroguemachine.hermailermaster)
		if(owner.client)
			to_chat(owner, span_warning("Your foreign income could not be delivered - the HERMES mail terminal is unavailable."))
		return

	var/obj/item/paper/P = new()
	P.mailer = manor_name
	P.mailedto = owner.real_name
	var/title_greeting = (owner.titles_pref == TITLES_F) ? "My Lady" : "My Lord"
	if(patron == /datum/patron/concordat/morwenna)
		title_greeting = "Comrade"
	P.info = "[title_greeting],<BR>"
	if(patron == /datum/patron/concordat/morwenna)
		P.info += "We are sending you a share of the proceeds from the goods produced this cycle."
	else
		P.info += "We are sending you the funds raised from the sale of goods produced by your peasants and workers this cycle."
	P.info += "<BR>Net profit: [total_profit_money] mammon."
	if(estate_levy)
		P.info += "<BR>Peasant levy: [estate_levy] mammon."
	if(import_tariff)
		P.info += "<BR>Import tariff: [import_tariff] mammon."
	P.update_icon()
	var/obj/item/manor_delivery/delivery = new()
	delivery.manor_note = P
	delivery.manor_income = total_profit_money

	if(owner.mind)
		owner.mind.manor_packages += delivery
	else
		qdel(delivery)

	if(owner.client)
		owner.apply_status_effect(/datum/status_effect/ugotmail)

/datum/manor/proc/get_readable_good_name(good_path, fallback = "Resource")
	if(!good_path)
		return fallback
	var/as_text = "[good_path]"
	var/last_slash = findlasttext(as_text, "/")
	if(last_slash)
		as_text = copytext(as_text, last_slash + 1)
	as_text = replacetext(as_text, "_", " ")
	if(!length(as_text))
		return fallback
	return uppertext(copytext(as_text, 1, 2)) + copytext(as_text, 2)

/datum/manor/proc/process_goods_sold_to_market(datum/roguestock/stockpile_entry, units_sold)
	var/list/region_info = SSeconomy.get_best_import_region(stockpile_entry.trade_good_id)
	var/datum/trade_good/tg = GLOB.trade_goods[stockpile_entry.trade_good_id]
	var/unit_price = region_info ? region_info["unit_price"] : (tg ? tg.base_price : 1)
	return unit_price * units_sold

/datum/manor/proc/produce_resources(mob/living/carbon/human/owner, is_dawn = FALSE, is_dusk = FALSE)
	if(!owner || !owner.mind || owner.mind.get_owned_manor() != src)
		return null
	if(!length(workstations))
		return null

	var/list/produced_summary = list()
	var/total_units = 0
	var/total_profit_money = 0

	var/is_foreign = virtue_origin ? TRUE : FALSE
	for(var/datum/workstation/workstation in workstations)
		if(workstation.workers_employed <= 0 || !length(workstation.produce))
			continue
		if(is_dawn && !(patron == /datum/patron/concordat/miluse || patron == /datum/patron/unveiled/aurelian))
			continue
		if(is_dusk && patron == /datum/patron/concordat/miluse)
			continue

		var/list/available_produce = workstation.produce.Copy()
		var/selected_count = min(length(available_produce), rand(2, 6))
		var/list/selected_produce = list()
		while(length(selected_produce) < selected_count)
			var/choice = pick(available_produce)
			selected_produce += choice
			available_produce -= choice

		var/this_workstation_units = 0
		for(var/i = 1; i <= workstation.workers_employed; i++)
			var/selected_good = pick(selected_produce)
			var/min_units = 0
			var/max_units = 2
			var/units = rand(min_units, max_units)
			if(units <= 0)
				continue

			units = ceil(units * workstation.production_modifier)

			var/datum/roguestock/stockpile_entry = get_stockpile_entry_for_good(selected_good)
			if(!stockpile_entry)
				continue

			if(patron == /datum/patron/oldkin/hausvette)
				var/resources_multiplier = pick(0.5, 1.0, 1.5)
				units = ceil(units * resources_multiplier)
			if(!is_foreign)
				stockpile_entry.stockpile_amount += units
				total_profit_money += max(process_goods_sold_to_market(stockpile_entry, units)/3, 1)
			else
				total_profit_money += max(process_goods_sold_to_market(stockpile_entry, units), 1)

			produced_summary[selected_good] = produced_summary[selected_good] ? produced_summary[selected_good] + units : units
			this_workstation_units += units

		total_units += this_workstation_units
		if(workstation.type_of_produce == "Profit")
			total_profit_money += workstation.workers_employed * 2 * workstation.production_modifier

	last_cycle_productivity = max(total_units, 0)

	if(patron == /datum/patron/oldkin/volkovoi && total_workers <= workers_limit)
		var/new_slaves = rand(2, 5)
		total_workers = min(total_workers + new_slaves, workers_limit)
		if(owner.client)
			to_chat(owner, span_notice("Your raiders have captured [new_slaves] slaves. Total workers: [total_workers]."))

	if(!total_units && !total_profit_money)
		return null

	var/estate_levy = 0
	var/import_tariff = 0
	if(patron == /datum/patron/concordat/morwenna && total_profit_money > 0)
		var/voluntary_multiplier = rand(50, 150) / 100
		total_profit_money *= voluntary_multiplier

	if(patron == /datum/patron/oldkin/hausvette)
		if(prob(30))
			total_profit_money = 0
		if(prob(30))
			total_profit_money *= 2
	if(total_profit_money > 0)
		total_profit_money = ceil(total_profit_money)
		if(is_foreign)
			if(patron != /datum/patron/concordat/morwenna) //FREEDOM OF TRANSACTION
				var/datum/fund/foreign_estate_fund = new("Foreign Estate Income for [owner.real_name]", owner, total_profit_money, CURRENCY_MAMMON)
				estate_levy = SStreasury.apply_tax(foreign_estate_fund, total_profit_money, TAX_CATEGORY_ESTATE_LEVY, "Foreign estate levy income")
				import_tariff = SStreasury.apply_tax(foreign_estate_fund, foreign_estate_fund.balance, TAX_CATEGORY_IMPORT_TARIFF, "Foreign estate import tariff")
				total_profit_money = ceil(foreign_estate_fund.balance)
				qdel(foreign_estate_fund)
			send_foreign_estate_income_mail(owner, total_profit_money, estate_levy, import_tariff)
		else
			var/datum/fund/owner_account = SStreasury.get_account(owner)
			if(owner_account)
				if(patron != /datum/patron/concordat/morwenna) //FREEDOM OF TRANSACTION
					estate_levy = SStreasury.apply_tax(owner_account, total_profit_money, TAX_CATEGORY_ESTATE_LEVY, "Estate levy income")
					total_profit_money = ceil(total_profit_money - estate_levy)
				SStreasury.generate_money_account(total_profit_money, owner)

	var/message = "This cycle your estate delivered to the Crown: "
	if(is_foreign)
		message = "This cycle your estate sold on the market: "
	for(var/good in produced_summary)
		message += "[produced_summary[good]]x [get_readable_good_name(good)]; "

	if(total_profit_money)
		if(patron == /datum/patron/concordat/morwenna)
			message += "your comrades voluntarily sent you [total_profit_money] mammon"
		else
			message += "net profit came to [total_profit_money] mammon"
		if(estate_levy)
			message += ", after a peasant levy of [estate_levy] mammon"
		if(import_tariff)
			message += (estate_levy ? " and " : ", after ") + "an import tariff of [import_tariff] mammon"
		if(is_foreign)
			message += ". Funds were sent to you via HERMES mail"
		message += "."
	else
		if(patron == /datum/patron/oldkin/hausvette)
			message += "your treasurer seems to be too absorbed in idle revelry, and no profit from the estate arrived."
		else if(patron == /datum/patron/concordat/morwenna)
			message += "your comrades chose not to send you any mammon this time."
		else
			message += "there was no net profit from the estate."
	if(owner.client)
		to_chat(owner, span_notice(message))

	return list(
		"products" = produced_summary,
		"money" = total_profit_money
	)

/obj/structure/roguemachine/mail/proc/can_open_manor_panel(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE

	var/datum/manor_panel/access_probe = new(user)
	var/allowed = access_probe.can_have_manor(user)
	qdel(access_probe)
	return allowed

/obj/structure/roguemachine/mail/proc/open_manor_panel(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!Adjacent(H))
		return

	var/datum/manor_panel/panel = new(H)
	var/datum/manor/manor = panel.get_manor_for_user(H)
	if(!manor)
		qdel(panel)
		to_chat(H, span_warning("This character doesn't have an estate available yet."))
		return

	H.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/keyboard_enter.ogg', 50, FALSE, -1)
	panel.ui_interact(H)

/obj/structure/roguemachine/mail/AltClick(mob/user)
	. = ..()
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	open_manor_panel(user)
