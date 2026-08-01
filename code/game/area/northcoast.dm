//  Coast - the northern part of the map - may not be actually coast
/area/rogue/outdoors/beach/forest
	name = "Coast"
	loot_budget = LOOT_BUDGET_SUNKEN_COAST
	loot_pool_key = "sunken_coast"
	icon_state = "beach"
	icon_state = "woods"
	ambientsounds = AMB_FORESTDAY
	ambientnight = AMB_FORESTNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_FOREST
	droning_sound = 'sound/music/area/forest.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	soundenv = 15
	ambush_times = list("night","dusk")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30,
				/mob/living/simple_animal/hostile/retaliate/rogue/mole = 10,
				/mob/living/simple_animal/hostile/retaliate/rogue/bobcat = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/direbear = 15,
				/mob/living/carbon/human/species/human/northern/searaider/ambush = 10,
				/mob/living/carbon/human/species/human/northern/searaider/archer/ambush = 3,
				/mob/living/carbon/human/species/human/northern/highwayman/ambush = 30,
				/mob/living/carbon/human/species/orc/npc/footsoldier = 10,
				/mob/living/carbon/human/species/orc/npc/archer = 3,
				/mob/living/carbon/human/species/orc/npc/berserker = 10,
				/mob/living/carbon/human/species/orc/npc/marauder = 10,
				/mob/living/carbon/human/species/goblin/npc/ambush/sea = 40,
				/mob/living/carbon/human/species/hobgoblin/npc/ambush = 12,
				/mob/living/carbon/human/species/goblin/npc/archer/sea = 10)
	first_time_text = "THE COAST"
	converted_type = /area/rogue/indoors/shelter/woods
	deathsight_message = "somewhere betwixt Abyssor's realm and Ignatius's bounty"
	threat_region = THREAT_REGION_SUNKEN_COAST
	detail_text = DETAIL_TEXT_NORTH_COAST

/area/rogue/outdoors/beach/forest/hamlet
	name = "The Coast - Hamlet"
	first_time_text = "THE HAMLET"
	ambush_mobs = null // We don't want actual ambushes in Hamlet but we also don't want to misuse outdoors/beach lol
	threat_region = THREAT_REGION_SUNKEN_COAST
	detail_text = DETAIL_TEXT_NORTH_COAST_HAMLET

/area/rogue/outdoors/beach/forest/north
	name = "The Coast - North"
	threat_region = THREAT_REGION_SUNKEN_COAST

/area/rogue/outdoors/beach/forest/south
	name = "The Coast - South"
	threat_region = THREAT_REGION_SUNKEN_COAST

/area/rogue/under/cave/dukecourt
	name = "Mad Duke's Manor"
	loot_budget = LOOT_BUDGET_DUKE_COURT
	icon_state = "duke"
	first_time_text = "MAD DUKE'S MANOR"
	droning_sound = 'sound/music/area/dungeon2.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "somewhere betwixt Abyssor's realm and Ignatius's bounty"
	threat_region = THREAT_REGION_SUNKEN_COAST
	detail_text = DETAIL_TEXT_MAD_DUKE_COURT
