// Ported from Twilight-Axis's firearms/code/jobs/orthodoxist.dm. The new
// "Blackpowder Legionnaire" advclass attaches automatically to the base
// Orthodoxist job via CTAG_ORTHODOXIST category roll. Also brings in the
// vaeltic claws weapon. The seizing garrote item this legionnaire's
// "Otavan Volf" archetype (and inquisitor.dm's Runed Volf) equips already
// exists natively in this repo (code/game/objects/items/rogueitems/
// inquisitionrelics.dm) — reused as-is, not redefined here.

/obj/item/rogueweapon/handclaw/gronn/silver/psy
	name = "vaeltic claws"
	desc = "A trinity of silver razor sharp claws, long anough to catch your prey in this silent war."
	icon = 'modular_dreamvalley/icons/twilight_firearms/weapons/32.dmi'
	icon_state = "psyclaws"
	item_state = "psyclaws"

/obj/item/rogueweapon/handclaw/gronn/silver/psy/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_NONE,\
		silver_type = SILVER_VAELTIAN,\
		added_force = 5,\
		added_blade_int = 100,\
		added_int = 50,\
		added_def = 3,\
	)

/datum/advclass/blackpowder_legionnaire
	name = "Blackpowder Legionnaire"
	tutorial = "In the Blackpowder Order, every fourth soldier is a sharpshooter, armed with advanced Otavan firearms. These Legionnaires are the very essence of the everchanging face of warfare, and when the Final War begins, it is with their power that the evil will be driven back."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/blackpowder_legionnaire
	subclass_languages = list(/datum/language/vergenmarkian)
	cmode_music = 'modular_dreamvalley/sound/twilight_firearms/music/combat_blackpowder.ogg'
	category_tags = list(CTAG_ORTHODOXIST)
	traits_applied = list(TRAIT_VAELTITE, TRAIT_ARTILLERY_EXPERT)
	classes = list("Legionnaire" = "Soldier of the Last War. Bring your deadly weapon of blackpowder to the battlefield",
	"Otavan Volf" = "No matter who you were before. Now you are a bloodhound of Inquisition enchanted with rune magyck. \
	No doors can stop you and no heretic can escape your silent bullet.")
	subclass_stats = list(
		STATKEY_PER = 3,
		STATKEY_WIL = 2,
		STATKEY_CON = 1,
		STATKEY_INT = 1,
		STATKEY_SPD = 1
	)
	subclass_skills = list(
		/datum/skill/combat/twilight_firearms = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/staves = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE
	)
	subclass_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy
	)
	extra_context = "This subclass can choose between two archetypes: Legionnaire and Otavan Volf. Legionnaire wield powerful blackpowder weapons and may select between light or medium armor, gaining Dodge Expert or Maille Training respectively. Otavan Volf specialize in stealth, rune magyck and silent firearms."

/datum/outfit/job/roguetown/blackpowder_legionnaire
	job_bitflag = BITFLAG_HOLY_WARRIOR

/datum/outfit/job/roguetown/blackpowder_legionnaire/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	backl = /obj/item/storage/backpack/rogue/satchel/otavan
	shoes = /obj/item/clothing/shoes/roguetown/boots/praecursorboots
	cloak = /obj/item/clothing/cloak/bandolier
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	neck = /obj/item/clothing/neck/roguetown/leather/blackpowder
	gloves = /obj/item/clothing/gloves/roguetown/chain/psydon
	mask = /obj/item/clothing/mask/rogue/facemask/steel/confessor
	id = /obj/item/clothing/ring/signet/psy
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)
	var/classes = list("Legionnaire", "Otavan Volf")
	var/classchoice = input(H, "Choose your archetypes", "Available archetypes") as anything in classes

	if(H.mind)
		switch(classchoice)
			if("Legionnaire")
				var/weapons = list("Purgatory (Handcannon)", "Runelock Pistol")
				var/weapon_choice = input(H,"Choose your WEAPON.", "TAKE UP PSYDON'S ARMS.") as anything in weapons
				switch(weapon_choice)
					if("Purgatory (Handcannon)")
						belt = /obj/item/storage/belt/rogue/leather/black
						l_hand = /obj/item/gun/ballistic/twilight_firearm/handgonne/purgatory
						backpack_contents = list(/obj/item/roguekey/inquisitionmanor = 1,
						/obj/item/paper/inqslip/arrival/ortho = 1,
						/obj/item/twilight_powderflask/holyfyre = 1,
						/obj/item/natural/bundle/fibers/full = 1,
						/obj/item/storage/belt/rogue/pouch/coins/mid = 1)
						var/quivers = list("Grapeshot", "Cannonballs")
						var/ammochoice = input(H,"Choose your MUNITIONS.", "TAKE UP PSYDON'S MISSILES.") as anything in quivers
						switch(ammochoice)
							if("Grapeshot")
								beltr = /obj/item/quiver/twilight_bullet/cannonball/grapeshot
							if("Cannonballs")
								beltr = /obj/item/quiver/twilight_bullet/cannonball/lead
					if("Runelock Pistol")
						belt = /obj/item/storage/belt/rogue/leather/twilight_holsterbelt/blackpowder
						beltr = /obj/item/quiver/twilight_bullet/runicbag/runed
						l_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock
						backpack_contents = list(/obj/item/roguekey/inquisitionmanor = 1,
						/obj/item/paper/inqslip/arrival/ortho = 1,
						/obj/item/storage/belt/rogue/pouch/coins/mid = 1)
				var/armors = list("Medium Armor", "Light Armor")
				var/armor_choice = input(H, "Choose your ARMOR.", "TAKE UP PSYDON'S MANTLE.") as anything in armors
				switch(armor_choice)
					if("Medium Armor")
						armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fluted/ornate
						pants = /obj/item/clothing/under/roguetown/chainlegs
						ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
					if("Light Armor")
						armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fencer/praecursor
						pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
						ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
				head = /obj/item/clothing/head/roguetown/helmet/kettle
				wrists = /obj/item/clothing/neck/roguetown/psicross/silver
				beltl = /obj/item/rogueweapon/scabbard/sword
				r_hand = /obj/item/rogueweapon/sword/short/psy
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			if ("Otavan Volf")
				ADD_TRAIT(H, TRAIT_BLACKBAGGER, TRAIT_GENERIC)
				var/weapons = list("Dagger", "Claws")
				var/weapon_choice = input(H,"Choose your WEAPON.", "TAKE UP PSYDON'S ARMS.") as anything in weapons
				switch(weapon_choice)
					if("Dagger")
						r_hand = /obj/item/rogueweapon/huntingknife/idagger/silver/psydagger
						beltl = /obj/item/rogueweapon/scabbard/sheath
						H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE)
					if("Claws")
						r_hand = /obj/item/rogueweapon/handclaw/gronn/silver/psy
						H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
				wrists = /obj/item/clothing/neck/roguetown/psicross/silver
				armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/confessor
				l_hand = /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol/umbra
				head = /obj/item/clothing/head/roguetown/roguehood/praecursor/confessor
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
				belt = /obj/item/storage/belt/rogue/leather/twilight_holsterbelt/blackpowder
				beltr = /obj/item/quiver/twilight_bullet/lead
				backpack_contents = list(/obj/item/roguekey/inquisitionmanor = 1,
					/obj/item/paper/inqslip/arrival/ortho = 1,
					/obj/item/twilight_powderflask/volf = 1,
					/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
					/obj/item/inqarticles/garrote = 1,
					/obj/item/clothing/head/inqarticles/blackbag = 1)
				H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_APPRENTICE, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, SKILL_LEVEL_EXPERT, TRUE)
				H.mind?.AddSpell(new /datum/action/cooldown/spell/blink/shadowstep)
				H.mind?.AddSpell(new /datum/action/cooldown/spell/invisibility)
				H.mind?.RemoveSpell(H.mind.get_spell(/datum/action/cooldown/spell/touch/prestidigitation))
				var/arcane = list("Fetch", "Repulse", "Leap")
				var/arcane_choice = input("TAKE YOUR RUNE.", "PSYDON'S RUNE.") as anything in arcane
				switch(arcane_choice)
					if("Fetch")
						H.mind?.AddSpell(new /datum/action/cooldown/spell/projectile/fetch)
					if("Repulse")
						H.mind?.AddSpell(new /datum/action/cooldown/spell/repulse)
					if("Leap")
						H.mind?.AddSpell(new /datum/action/cooldown/spell/leap)
