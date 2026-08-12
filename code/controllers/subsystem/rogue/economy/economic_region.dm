GLOBAL_LIST_INIT(economic_regions, init_economic_regions())

/proc/init_economic_regions()
	var/list/result = list()
	for(var/datum/economic_region/er as anything in subtypesof(/datum/economic_region))
		var/datum/economic_region/instance = new er()
		if(!instance.region_id)
			continue
		result[instance.region_id] = instance
	return result

/datum/economic_region
	var/region_id
	var/name
	/// Italicized one-liner shown beneath the region name in the Lore Primer's
	/// Trade Contacts section. The steward UI ignores it; only `description` shows there.
	var/subtitle = ""
	var/description = ""
	var/list/produces = list()
	var/list/demands = list()
	var/list/possible_standing_order_types = list()
	var/associated_marker_id
	var/is_region_blockaded = FALSE
	/// Null = this region cannot be blockaded.
	var/threat_region_id
	// Ensure this region won't replenish blockade. Used only for Kingsfield because Kingsfield blockade is devastating and shouldn't repeat mid round.
	var/blockade_replenish_eligible = TRUE

	var/list/produces_today = list()
	var/list/demands_today = list()

	var/list/produces_day_start = list()
	var/list/demands_day_start = list()

	/// -1 = never cleared. Otherwise the cooldown window runs from this day.
	var/day_last_cleared = -1

/datum/economic_region/New()
	. = ..()
	produces_today = produces.Copy()
	demands_today = demands.Copy()
	produces_day_start = produces.Copy()
	demands_day_start = demands.Copy()
	if(!associated_marker_id)
		associated_marker_id = "[region_id]_blockade"

/datum/economic_region/proc/get_day_capacity(good_id, importing)
	var/list/today = importing ? produces_today : demands_today
	return max(0, today[good_id] || 0)

/datum/economic_region/proc/get_day_capacity_total(good_id, importing)
	var/list/day_start = importing ? produces_day_start : demands_day_start
	return max(0, day_start[good_id] || 0)

/datum/economic_region/proc/get_batch_capacity(good_id, importing)
	var/pace = (importing ? produces[good_id] : demands[good_id]) || 0
	if(pace <= 0)
		return 0
	return clamp((importing ? produces_today[good_id] : demands_today[good_id]) || 0, 0, pace)

/datum/economic_region/kingsfield
	region_id = TRADE_REGION_KINGSFIELD
	name = "Kingsfield"
	subtitle = "The Farmlands, Grain and Orchard of the River"
	blockade_replenish_eligible = FALSE
	description = "A stretch of rich farmland along a river some ten miles across, home to scattered agricultural settlements, hamlets, and market towns with no crown or count over them - just farmers, orchardists, and herbalists who trade what they grow. It produces most of the grain, meat, dairy, fruit, and orchard herbs that reach the outpost's trade contacts, and takes back finished goods, ore, and salt in return. Kingsfield apple brandy has a modest but real reputation beyond its own hills."
	threat_region_id = THREAT_REGION_WHISPERING_GROVE
	produces = list(
		TRADE_GOOD_GRAIN = TG_SUPPLY_LOCAL_GRAIN,
		TRADE_GOOD_OATS = TG_SUPPLY_FOREIGN_GRAIN,
		TRADE_GOOD_RICE = TG_SUPPLY_FOREIGN_GRAIN,
		TRADE_GOOD_MAIZE = TG_SUPPLY_FOREIGN_GRAIN,
		TRADE_GOOD_MEAT = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_PORK = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_HAM = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_PORK_BELLY = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_POULTRY = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_RABBIT = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_EGG = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_BUTTER = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_CHEESE = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_FAT = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_TALLOW = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_CABBAGE = TG_SUPPLY_COMMON_VEG,
		TRADE_GOOD_POTATO = TG_SUPPLY_COMMON_VEG,
		TRADE_GOOD_ONION = TG_SUPPLY_COMMON_VEG,
		TRADE_GOOD_CARROT = TG_SUPPLY_COMMON_VEG,
		TRADE_GOOD_TURNIP = TG_SUPPLY_COMMON_VEG,
		TRADE_GOOD_PUMPKIN = 2, // literal: trickle supply, not a staple
		TRADE_GOOD_APPLE = TG_SUPPLY_LOCAL_FRUIT,
		TRADE_GOOD_PEAR = TG_SUPPLY_LOCAL_FRUIT,
		TRADE_GOOD_JACKSBERRY = TG_SUPPLY_LOCAL_FRUIT,
		TRADE_GOOD_CALENDULA = TG_SUPPLY_SPECIALTY_HERB,
		TRADE_GOOD_POPPY = TG_SUPPLY_SPECIALTY_HERB,
	)
	demands = list(
		TRADE_GOOD_PUMPKIN = 2, // literal: small local appetite for eating
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
		TRADE_GOOD_SALT = TG_DEMAND_SALT,
		TRADE_GOOD_IRON_ORE = TG_DEMAND_IRON,
		TRADE_GOOD_COPPER_ORE = TG_DEMAND_TIN_BRONZE,
		TRADE_GOOD_TIN_ORE = TG_DEMAND_TIN_BRONZE,
		TRADE_GOOD_COAL = TG_DEMAND_CHEAP_RAW_MAT,
		TRADE_GOOD_STONE = TG_DEMAND_CHEAP_RAW_MAT,
		TRADE_GOOD_CLAY = TG_DEMAND_CHEAP_RAW_MAT,
		TRADE_GOOD_CINNABAR = TG_DEMAND_IRON,
		TRADE_GOOD_SILVER_INGOT = TG_DEMAND_PRECIOUS_METAL,
		TRADE_GOOD_GOLD_ORE = TG_DEMAND_PRECIOUS_METAL,
		TRADE_GOOD_SILK = TG_DEMAND_SILK,
		TRADE_GOOD_GLASS_BATCH = TG_DEMAND_GLASS,
		TRADE_GOOD_FISH_FILET = TG_DEMAND_FISH_BULK,
		TRADE_GOOD_FISH_MINCE = TG_DEMAND_FISH_BULK,
		TRADE_GOOD_SALMON = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_COD = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_CRAB = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_BASS = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_CARP = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_SOLE = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_CLAM = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_LOBSTER = TG_DEMAND_FISH_SPECIALTY,
		TRADE_GOOD_SHRIMP = TG_DEMAND_FISH_SPECIALTY,
	)

/datum/economic_region/rosawood
	region_id = TRADE_REGION_ROSAWOOD
	name = "Rosawood"
	subtitle = "The Wildwood Enclave, Timber and Bog-Craft of the Coast"
	description = "A close-knit enclave on a cold coastal peninsula, its people mostly kin to an old elven lineage. Access is largely by sea, and its growing season is short, but its wilds are generous in other ways: timber, hide, and fiber from its forests, and stranger goods - silk, viscera, and rare bog-essence - traded up from the marsh at its edge. No lord answers for it to anyone; it trades on its own terms, at its own pace, wary of outsiders but not unwelcoming to those who deal fairly."
	threat_region_id = THREAT_REGION_WHISPERING_GROVE
	produces = list(
		TRADE_GOOD_WOOD = TG_SUPPLY_CHEAP_RAW_MAT,
		TRADE_GOOD_FIBERS = TG_SUPPLY_FIBERS,
		TRADE_GOOD_CLOTH = 4,
		TRADE_GOOD_HIDE = TG_SUPPLY_LEATHER,
		TRADE_GOOD_FUR = TG_SUPPLY_LEATHER,
		TRADE_GOOD_CURED_LEATHER = TG_SUPPLY_LEATHER,
		TRADE_GOOD_SILK = TG_SUPPLY_SILK,
		TRADE_GOOD_VISCERA = TG_SUPPLY_SPECIALTY_HERB,
		TRADE_GOOD_SINEW = TG_SUPPLY_SPECIALTY_HERB,
		TRADE_GOOD_IGNATIUS_ESSENCE = 1, // literal: deliberately scarce, not category-bound
		TRADE_GOOD_CALENDULA = TG_SUPPLY_SPECIALTY_HERB,
	)
	demands = list(
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
		TRADE_GOOD_GRAIN = TG_DEMAND_LOCAL_GRAIN,
		TRADE_GOOD_SALT = TG_DEMAND_SALT,
		TRADE_GOOD_GLASS_BATCH = TG_DEMAND_GLASS,
		TRADE_GOOD_CLOTH = TG_DEMAND_CLOTH,
		TRADE_GOOD_CLAY = TG_DEMAND_CHEAP_RAW_MAT,
	)

/datum/economic_region/daftsmarch
	region_id = TRADE_REGION_DAFTSMARCH
	name = "Daftsmarch"
	subtitle = "The Mining March, Ores of the Mount"
	description = "A long strip of mining country hugging the southern end of a mountain range, producing most of the raw ore, coal, and salt that moves through this stretch of trade. The veins are plentiful and the work pays well, but the March sits uncomfortably close to old ruins and the Underdark below - a constant, quiet danger for anyone working the deep shafts."
	threat_region_id = THREAT_REGION_UNDERDARK
	produces = list(
		TRADE_GOOD_IRON_ORE = TG_SUPPLY_IRON,
		TRADE_GOOD_COPPER_ORE = TG_SUPPLY_TIN_BRONZE,
		TRADE_GOOD_TIN_ORE = TG_SUPPLY_TIN_BRONZE,
		TRADE_GOOD_STONE = TG_SUPPLY_CHEAP_RAW_MAT,
		TRADE_GOOD_COAL = TG_SUPPLY_IRON,
		TRADE_GOOD_CINNABAR = TG_SUPPLY_PRECIOUS_METAL,
		TRADE_GOOD_GOLD_ORE = TG_SUPPLY_PRECIOUS_METAL,
		TRADE_GOOD_SALT = TG_SUPPLY_SALT,
		TRADE_GOOD_GLASS_BATCH = TG_SUPPLY_GLASS,
		TRADE_GOOD_IRON_INGOT = TG_SUPPLY_REFINED_INGOTS,
		TRADE_GOOD_STEEL_INGOT = TG_SUPPLY_REFINED_INGOTS,
		TRADE_GOOD_COPPER_INGOT = TG_SUPPLY_REFINED_INGOTS,
		TRADE_GOOD_TIN_INGOT = TG_SUPPLY_REFINED_INGOTS,
	)
	demands = list(
		TRADE_GOOD_GRAIN = TG_DEMAND_LOCAL_GRAIN,
		TRADE_GOOD_MEAT = TG_DEMAND_MEAT_BULK,
		TRADE_GOOD_CLOTH = TG_DEMAND_CLOTH,
		TRADE_GOOD_WOOD = TG_DEMAND_CHEAP_RAW_MAT * 2, // wood draws 2x raw-mat baseline: building, firewood, charring
		TRADE_GOOD_SILVER_ORE = TG_DEMAND_PRECIOUS_METAL,
		TRADE_GOOD_SILK = TG_DEMAND_SILK,
	)

/datum/economic_region/saltwick
	region_id = TRADE_REGION_SALTWICK
	name = "Saltwick"
	subtitle = "The Coastal Town, Fisheries of the Free Coast"
	description = "A small coastal town built around curing houses and salt farms, its harbor worked by fishing families whose boats range the shallows for whatever the season offers. Salt comes in from Daftsmarch to preserve the day's catch, and both leave together on whatever ship or cart is heading out. It answers to no one but its own harbormaster, and asks the same of anyone it trades with."
	threat_region_id = THREAT_REGION_SUNKEN_COAST
	produces = list(
		TRADE_GOOD_FISH_FILET = TG_SUPPLY_FISH_BULK,
		TRADE_GOOD_FISH_MINCE = TG_SUPPLY_FISH_MINCE,
		TRADE_GOOD_SALMON = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_COD = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_CRAB = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_BASS = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_CARP = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_SOLE = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_CLAM = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_LOBSTER = TG_SUPPLY_FISH_SPECIALTY,
		TRADE_GOOD_SHRIMP = TG_SUPPLY_FISH_SPECIALTY,
	)
	demands = list(
		TRADE_GOOD_SALT = TG_DEMAND_SALT,
		TRADE_GOOD_FIBERS = TG_DEMAND_CLOTH,
		TRADE_GOOD_CLOTH = TG_DEMAND_CLOTH,
		TRADE_GOOD_WOOD = TG_DEMAND_CHEAP_RAW_MAT * 2, // wood draws 2x raw-mat baseline: building, firewood, charring
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
		TRADE_GOOD_PUMPKIN = 2, // literal: small local appetite for eating
	)

/// Builds the TRADE CONTACTS section of the Lore Primer from the economic_region datums,
/// so steward UI prose and primer prose stay in sync from a single source.
/proc/build_regions_primer_html()
	var/list/parts = list()
	parts += "<details>"
	parts += "<summary><strong><span style='font-size:130%'> THE OUTSIDE WORLD </span></strong></summary>"
	parts += "<strong><span style='font-size:115%'> TRADE CONTACTS </span></strong>"
	parts += "<br><br>"
	for(var/region_id in GLOB.economic_regions)
		var/datum/economic_region/region = GLOB.economic_regions[region_id]
		if(!region)
			continue
		parts += "<details>"
		parts += "<summary><strong> [uppertext(region.name)] </strong></summary>"
		parts += "<br>"
		if(region.subtitle)
			parts += "<em>[region.subtitle]</em>"
			parts += "<br><br>"
		parts += region.description
		parts += "<br>"
		parts += "</details>"
	parts += "<br><br>"
	parts += "</details>"
	return jointext(parts, "\n")
