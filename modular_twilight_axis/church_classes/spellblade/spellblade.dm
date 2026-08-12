/datum/advclass/noctite_spellblade
	name = "Newmoon Spellblade"
	tutorial = "Newmoon Spellblades are known in radical Nocite circles as the most devoted monks of Noc, most often hailing from Zibantia. \
		For some reason you have left your monastery and arrived here. Is it a pilgrimage or a mission to spread the word of Noc?... \
		Only you can say for certain. Though you are a rather fanatical Nocite, you came here in peace and are therefore quite tolerant of the other gods and the established Order,\
		perhaps harboring distrust toward Astrata according to the radical teachings of Noc... \
		Despite the teachings of the local clergy of the Ten, you know and are firmly convinced that Noc does not require worship — she has gifted you with something more unique:\
		for your faithful service and mastery of the arcane, you have gained access to arcane weaponry. Miracles are beyond your reach, but in exchange you have gained access to the arcane, and no matter what weapon the light of Noc forges for you, you are an expert in its use."
	outfit = /datum/outfit/job/roguetown/spellblade
	category_tags = list(CTAG_TEMPLAR)
	subclass_languages = list(/datum/language/raneshi)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_NIGHT_OWL, TRAIT_ARCYNE, TRAIT_NOC_LIGHT_BLESSING)
	subclass_mage_aspects = list("mastery" = FALSE, "major" = FALSE, "minor" = 2, "utilities" = 6)
	maximum_possible_slots = 1
	subclass_stats = list(
		STATKEY_WIL = 1,
		STATKEY_INT = 5,
	)
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_JOURNEYMAN
	)

	subclass_stashed_items = list(
		"Newmoon Cloak" = /obj/item/clothing/cloak/half/newmoon,
	)

	allowed_patrons = list(/datum/patron/divine/noc)

/datum/outfit/job/roguetown/spellblade
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/noc
	head = /obj/item/clothing/head/roguetown/roguehood/newmoon
	armor = /obj/item/clothing/suit/roguetown/armor/leather/newmoon_jacket
	id = /obj/item/clothing/ring/gold
	backl = /obj/item/storage/backpack/rogue/satchel
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/newmoon
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	mask = /obj/item/clothing/mask/rogue/ragmask/newmoon
	backpack_contents = list(
		/obj/item/lockpickring/mundane = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/acolyte = 1,
		/obj/item/rogueweapon/spellbook = 1
		)

/datum/outfit/job/roguetown/spellblade/pre_equip(mob/living/carbon/human/H)
	..()

	H.cmode_music = 'modular_twilight_axis/church_classes/sound/cmode_spellblade.ogg'
	ADD_TRAIT(H, TRAIT_CLERGY_TA, TRAIT_GENERIC)
	REMOVE_TRAIT(H, TRAIT_RITUALIST, JOB_TRAIT)

	if(H.mind)
		SStreasury.give_money_account(ECONOMIC_LOWER_MIDDLE_CLASS, H, "Church Funding.")

	var/obj/effect/proc_holder/spell/targeted/spellblade_select_weapon/select_weapon 
	select_weapon = new /obj/effect/proc_holder/spell/targeted/spellblade_select_weapon

	var/obj/effect/proc_holder/spell/invoked/spellblade_summon_weapon/summon_weapon
	summon_weapon = new /obj/effect/proc_holder/spell/invoked/spellblade_summon_weapon
	summon_weapon.weapon_select = select_weapon
	select_weapon.summon_weapon = summon_weapon
	
	H.AddSpell(select_weapon)
	H.AddSpell(summon_weapon)
	H.AddSpell(new /obj/effect/proc_holder/spell/self/noctite_fortify)
