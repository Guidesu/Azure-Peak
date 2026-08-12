/datum/job/roguetown/sheriff
	title = "Town Sheriff"
	flag = SHERIFF
	department_flag = CITYWATCH
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = JCOLOR_CITYWATCH
	forbidden_races = list(RACES_DESPISED)
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD)
	display_order = JDO_SHERIFF
	tutorial = "Crime has always been a constant in your life, and you have always chosen the side of justice. \
	You rose through the ranks of the guards, and now you lead them - ensuring they uphold the laws of this land. \
	It has been 12 years since you began serving the King, who declared Rockhill his seat, right after the DISAPPEARANCE of Baron Eric RavenCroft. \
	On sleepless nights, a troubling thought keeps coming to you - that the King may settle here not just temporarily as he promised, but permanently... \
	Is this a blessing for Rockhill? Did the Baron truly vanish without the King's involvement?.."
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/sheriff
	advclass_cat_rolls = list(CTAG_SHERIFF = 2)
	give_bank_account = TRUE
	min_pq = 10
	max_pq = null
	round_contrib_points = 3
	same_job_respawn_delay = 30 MINUTES

	cmode_music = 'modular_twilight_axis/sound/music/combat/combat_watchman.ogg'
	job_subclasses = list(
		/datum/advclass/sheriff,
	)

/datum/job/roguetown/sheriff/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.wear_armor, /obj/item/clothing/suit/roguetown/armor/plate/scale/townguard/sheriff))
			var/obj/item/clothing/S = H.wear_armor
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "sheriff ([index]) armor"

/datum/advclass/sheriff
	name = "Town Sheriff"
	tutorial = "      ,      . \
	    ,     -   ,      . \
	  12 ,     ,     ,     . \
	  ,     ,   ,          ,  ... \
	    ?       ?.."

	category_tags = list(CTAG_SHERIFF)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_GUARDSMAN, TRAIT_STEELHEARTED)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_PER = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/twilight_firearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/roguetown/sheriff
	job_bitflag = BITFLAG_CITYWATCH
	head = /obj/item/clothing/head/roguetown/helmet/heavy/citywatch/sheriff
	pants = /obj/item/clothing/under/roguetown/chainlegs
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale/townguard/sheriff
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	backr = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	beltl = /obj/item/rogueweapon/scabbard/sword
	beltr = /obj/item/rogueweapon/mace/stunmace
	cloak = /obj/item/clothing/cloak/sheriff
	r_hand = /obj/item/rogueweapon/sword/sabre
	backpack_contents = list(/obj/item/storage/keyring/sheriff = 1, /obj/item/rogueweapon/scabbard/sheath = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 1)

/datum/outfit/job/roguetown/sheriff/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		SStreasury.give_money_account(ECONOMIC_UPPER_MIDDLE_CLASS, H, "Savings.")
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/movemovemove)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/takeaim)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/hold)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/onfeet)
	H.verbs |= list(/mob/living/carbon/human/proc/request_outlaw, /mob/proc/haltyell, /mob/living/carbon/human/mind/proc/setorders)
