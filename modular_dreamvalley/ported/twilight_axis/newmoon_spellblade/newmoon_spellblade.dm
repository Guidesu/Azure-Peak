// Ported from Twilight-Axis's church_classes/spellblade module. All
// player-facing text translated from Russian into English.
//
// NAMING NOTE: this fork already has an unrelated, more developed
// "Spellblade" identity (the Azurcaephan chant-kit used by
// templar_spellblade.dm and the unbound_spellblade antagonist — momentum
// stacks, permanent bound weapons). The source's class is a different,
// day/night-gated caster built around ephemeral dream-conjured weapons, so
// per user decision it's kept under its own in-fiction name, "Newmoon
// Spellblade" (a Zybantine radical-Noctite monk archetype), rather than
// colliding with the existing Spellblade branding. It sits alongside the
// existing templar subclass roster under CTAG_TEMPLAR.

/datum/advclass/noctite_spellblade
	name = "Newmoon Spellblade"
	tutorial = "Newmoon Conjurers are known in radical Noctite circles as the most devoted of Noc's monks, most often hailing from Zybantia. \
		For some reason you left your monastery and came here. Is it a pilgrimage, or a mission to spread Noc's word?... \
		Only you could really say. Though you are a fairly fanatical Noctite, you came here in peace, and so you're fairly tolerant of the other gods and the established Order, \
		though perhaps you harbor some distrust of Astrata, per the radical Noctite teaching... \
		Despite the local Church of the Ten's teachings, you know - and are firmly convinced - that Noc does not demand worship; she has granted you something more unique: \
		for your faithful service and mastery of the arcane, you've been given access to arcane weaponry. Miracles are closed to you, but in exchange you've gained access to the arcane, and no matter what weapon Noc's light might conjure for you, you are an expert with it."
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

	allowed_patrons = list(/datum/patron/concordat/miluse)

/datum/outfit/job/roguetown/spellblade
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/miluse
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

	H.cmode_music = 'modular_dreamvalley/sound/newmoon_spellblade/cmode_spellblade.ogg'
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
