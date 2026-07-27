/datum/job/roguetown/monster_hunter
	title = "Monster Hunter"
	flag = MONSTERHUNTER
	department_flag = ANTAGONIST
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	antag_job = TRUE

	tutorial = "This is a tutorial testing class please don't use it in prod."

	outfit = /datum/outfit/job/roguetown/monster_hunter
	display_order = JDO_MONSTERHUNTER
	selection_color = JCOLOR_ANTAGONIST

	min_pq = null
	max_pq = null
	plevel_req = 0
	can_random = FALSE
	show_in_credits = FALSE
	announce_latejoin = FALSE
	obsfuscated_job = TRUE
	wanderer_examine = TRUE

	job_traits = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_BLOOD_RESISTANCE, TRAIT_HEAVYARMOR)

/datum/job/roguetown/monster_hunter/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	for(var/stat in MOBSTATS)
		H.change_stat(stat, 20 - H.get_stat_level(stat))
	if(H.mind && !H.mind.has_antag_datum(/datum/antagonist/monster_hunter))
		H.mind.add_antag_datum(new /datum/antagonist/monster_hunter())

/datum/outfit/job/roguetown/monster_hunter
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet
	neck = /obj/item/clothing/neck/roguetown/bevor
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/chainlegs
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	beltr = /obj/item/rogueweapon/sword/rapier/monsterhunter
	beltl = /obj/item/gun/ballistic/revolver/monsterhunter

/datum/outfit/job/roguetown/monster_hunter/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/combat/swords, SKILL_LEVEL_LEGENDARY, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, SKILL_LEVEL_LEGENDARY, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, SKILL_LEVEL_MASTER, TRUE)

/obj/item/rogueweapon/sword/rapier/monsterhunter
	name = "hunter's rapier"
	desc = "A rapier of impossible temper, honed for things that do not die politely."
	force = 100
	max_blade_int = 1000
	max_integrity = 1000
	minstr = 0

/obj/item/gun/ballistic/revolver/monsterhunter
	name = ".357 revolver"
	desc = "A short iron tube with some artificed device. Ask yourself. Why is this allowed to exist? Why is this in prod? It is not funny, manne."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/monsterhunter357
	fire_sound = 'sound/combat/Ranged/crossbow_big_shot.ogg'
	fire_sound_volume = 100
	vary_fire_sound = FALSE
	slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	max_integrity = 1000
	resistance_flags = FIRE_PROOF

/obj/item/gun/ballistic/revolver/monsterhunter/chamber_round(spin_cylinder = TRUE)
	..()
	chambered?.newshot()

/obj/item/ammo_box/magazine/internal/monsterhunter357
	name = "cylinder"
	ammo_type = /obj/item/ammo_casing/monsterhunter357
	caliber = "357"
	max_ammo = 6

/obj/item/ammo_casing/monsterhunter357
	name = ".357 cartridge"
	desc = "Brass and lead, cast for a war nobody here has fought yet."
	caliber = "357"
	projectile_type = /obj/projectile/bullet/monsterhunter357
	heavy_metal = FALSE

/obj/projectile/bullet/monsterhunter357
	name = ".357 bullet"
	damage = 100
	armor_penetration = PEN_HEAVY
	woundclass = BCLASS_PIERCE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	speed = 0.3
	range = 20
