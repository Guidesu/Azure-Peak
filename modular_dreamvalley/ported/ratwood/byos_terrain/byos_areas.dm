// Areas for byos.dmm ("New Kingsfield" / Build-Your-Own-Settlement island map).
// Ported from Ratwood-2.0 code/game/area/byos.dm (and small related pieces of
// actualcoast.dm, roguetownareas.dm, town/town.dm) — all parent area types
// (banditcamp, inq, town/warehouse, outdoors/beach, under/cave, under/cavewet)
// already exist in this codebase, only the byos-specific leaf areas were missing.

/area/rogue/outdoors/jungle
	name = "The Jungle of Dread"
	icon_state = "bog"
	ambientsounds = AMB_BOGDAY
	ambientnight = AMB_BOGNIGHT
	spookysounds = SPOOKY_FROG
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ambush_times = list("night","dawn","dusk","day")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/troll/bog = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/spider = 40,
				/mob/living/carbon/human/species/npc/deadite = 20,
				/mob/living/carbon/human/species/skeleton/npc/hardspread = 40,
				/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/axe = 15,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 30,
				new /datum/ambush_config/mirespiders_ambush = 110,
				new /datum/ambush_config/mirespiders_crawlers = 25,
				new /datum/ambush_config/mirespiders_aragn = 10,
				new /datum/ambush_config/mirespiders_unfair = 5)
	first_time_text = "THE DREAD JUNGLE"
	threat_region = THREAT_REGION_JUNGLE
	deathsight_message = "a wretched, sweltering jungle"

/area/rogue/outdoors/byos
	name = "New-Kingsfield wilderness"
	first_time_text = null
	town_area = TRUE
	icon_state = "rtfield"
	soundenv = 19
	ambush_times = list("night")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/bobcat = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30,
				/mob/living/simple_animal/hostile/retaliate/rogue/fox = 10,
				/mob/living/carbon/human/species/goblin/npc/ambush/sea = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/mossback = 10,
				/mob/living/simple_animal/hostile/retaliate/rogue/troll/bog = 5,
				/mob/living/carbon/human/species/npc/deadite = 5,
				/mob/living/carbon/human/species/skeleton/npc/supereasy = 10,
				/mob/living/carbon/human/species/skeleton/npc/pirate = 30)
	droning_sound = 'sound/music/area/field.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	deathsight_message = "the outskirts of the colony of New Kingsfield and all its bustling souls"
	threat_region = THREAT_REGION_ISLAND
	detail_text = THREAT_REGION_ISLAND

/area/rogue/outdoors/town/byos
	icon_state = "town"
	first_time_text = "The Colony of New Kingsfield"
	town_area = TRUE
	deathsight_message = "the colony of New Kingsfield and all its bustling souls"
	threat_region = THREAT_REGION_ISLAND
	detail_text = THREAT_REGION_ISLAND
	ambush_times = list("night")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/bobcat = 20,
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30,
				/mob/living/simple_animal/hostile/retaliate/rogue/fox = 30,
				/mob/living/carbon/human/species/skeleton/npc/supereasy = 30)

/area/rogue/indoors/banditcamp/byos
	name = "Pirate's Ship"
	deathsight_message = "a hidden cove of greedy secrets"

/area/rogue/indoors/banditcamp/hoardmaster
	name = "The Hoard"
	icon_state = "rogue"
	first_time_text = "A MISTAKE"
	deathsight_message = "a place of greed and excess"

/area/rogue/under/cavewet/byos/banditcove
	first_time_text = "A Gathering of Thieves"
	deathsight_message = "a hidden cove of greedy secrets"
	droning_sound = 'sound/music/area/banditcamp.ogg'
	droning_sound_dusk = 'sound/music/area/banditcamp.ogg'
	droning_sound_night = 'sound/music/area/banditcamp.ogg'
	ambush_times = null

/area/rogue/indoors/inq/boat
	name = "The Purity"
	icon_state = "chapel"
	first_time_text = "THE PURITY"
	ambientsounds = AMB_BOAT
	ambientnight = AMB_BOAT

/area/rogue/indoors/inq/boat/office
	name = "The Inquisitor's Office"
	icon_state = "chapel"
	ambientsounds = AMB_BOAT
	ambientnight = AMB_BOAT

/area/rogue/indoors/inq/boat/basement
	name = "The Inquisition's Basement"
	icon_state = "chapel"
	ceiling_protected = TRUE
	droning_sound = 'sound/music/area/catacombs.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ambientsounds = AMB_BOAT
	ambientnight = AMB_BOAT

/area/rogue/outdoors/beach/byos
	name = "Island Coast"
	icon_state = "beach"
	first_time_text = null
	deathsight_message = "a brackish shore"
	detail_text = null
	ambush_times = list("night","dawn","dusk","day")
	ambush_mobs = list(
		/mob/living/carbon/human/species/goblin/npc/ambush/sea = 20,
		/mob/living/simple_animal/hostile/retaliate/rogue/mossback = 30,
		new /datum/ambush_config/triple_deepone = 20,
		new /datum/ambush_config/deepone_party = 10,
	)

/area/rogue/outdoors/beach/harbor
	name = "harbor"
	icon_state = "harbor"
	droning_sound = 'sound/music/area/harbor.ogg'
	first_time_text = "Rockhill Harbor"
	deathsight_message = "a bustling, windswept harbor"
	town_area = TRUE

/area/rogue/under/cave/tribeden
	name = "tribal hideout"
	icon_state = "under"
	first_time_text = "Ancient Encampment"
	ambientsounds = AMB_BASEMENT
	ambientnight = AMB_BASEMENT
	droning_sound = 'sound/music/area/gobcamp.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ceiling_protected = TRUE
	deathsight_message = "A hidden fortress"

/area/rogue/indoors/town/warehouse/harbor
	droning_sound = 'sound/music/area/harbor.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
