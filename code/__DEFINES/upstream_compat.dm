// Upstream compatibility stubs — maps upstream Azure-Peak type names to our DreamValley types.
// This file allows upstream code to compile without modifying every reference.
// Our god/pantheon system uses different names and structure than upstream.
// NOTE: Do NOT add vars to existing types here — add them to the actual type definition files.
//       Duplicate var definitions cause DM to silently fail on this entire file.

// ============== DIVINE PATRON STUBS ==============
// These stubs provide the type paths and vars that upstream code expects.

/datum/patron/divine/abyssor
	var/list/paint_miracles = list()
/datum/patron/divine/astrata
/datum/patron/divine/dendor
/datum/patron/divine/malum
/datum/patron/divine/necra
/datum/patron/divine/noc
/datum/patron/divine/pestra
/datum/patron/divine/ravox
/datum/patron/divine/undivided

// ============== INHUMEN PATRON STUBS ==============

/datum/patron/inhumen/graggar
/datum/patron/inhumen/matthios
/datum/patron/inhumen/zizo

// ============== FAMILIAR TYPE STUBS (old simple_animal path) ==============
// Upstream moved familiars to /mob/living/carbon/human/species/familiar
// but some code still references the old simple_animal path.
// These stubs provide the vars/procs that old code expects.

/datum/familiar_voice_pack
	proc/get_sound(key)
		return null

/mob/living/carbon/simple_animal/pet/familiar
	var/tier = 0
	var/mob/living/carbon/familiar_summoner = null
	var/inherent_spell = null
	var/list/t1_spell = list()
	var/tutorial_message = null
	var/list/tierup_messages = list()
	var/list/t2_spell = list()
	var/summoning_emote = null
	var/list/valid_healing_items = list()
	var/planar_origin = "void"
	var/datum/familiar_voice_pack/voice_pack = null
	var/voice_color = null
	proc/is_aligned_leyline(obj/structure/leyline/ley)
		return FALSE

/mob/living/carbon/simple_animal/pet/familiar/elemental
/mob/living/carbon/simple_animal/pet/familiar/fae
/mob/living/carbon/simple_animal/pet/familiar/infernal
/mob/living/carbon/simple_animal/pet/familiar/void

// ============== VIRTUE STUBS ==============

/datum/virtue/origin/familiar
/datum/virtue/origin/familiar/elemental
/datum/virtue/origin/familiar/fae
/datum/virtue/origin/familiar/infernal
/datum/virtue/origin/familiar/void

// ============== SPELL TYPE STUBS ==============

/obj/effect/proc_holder/spell/invoked/projectile/divineblast
/obj/effect/proc_holder/spell/invoked/projectile/unholyblast
/obj/effect/proc_holder/spell/self/ragebad
/obj/effect/proc_holder/spell/invoked/chokeslam
/obj/effect/proc_holder/spell/invoked/dropkick
/obj/effect/proc_holder/spell/invoked/headbutt
/obj/effect/proc_holder/spell/invoked/stunner

// Upstream cooldown spell stubs
/datum/action/cooldown/spell/ravox/trial/glory
/datum/action/cooldown/spell/ravox/trial/wits

// ============== CLOTHING STUBS ==============

/obj/item/clothing/mask/rogue/padded
/obj/item/clothing/mask/rogue/leather
/obj/item/clothing/mask/rogue/mailleiron
/obj/item/clothing/mask/rogue/flutedmailleiron
/obj/item/clothing/mask/rogue/spectacles/inq/spawnpair

// Psicross stubs for upstream god names
/obj/item/clothing/neck/roguetown/psicross/abyssor
/obj/item/clothing/neck/roguetown/psicross/undivided
/obj/item/clothing/neck/roguetown/psicross/silver/undivided

// Armor stubs
/obj/item/clothing/suit/roguetown/armor/manual/resting/monk/chest
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/disciple/gladiator
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor/impure
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor/knight

// ============== MOB STUBS ==============

// Old simple_animal path stubs (our code uses /mob/living/carbon/simple_animal)
/mob/living/simple_animal/hostile/rogue/deepone
/mob/living/simple_animal/hostile/rogue/deepone/arm
/mob/living/simple_animal/hostile/rogue/deepone/spit
/mob/living/simple_animal/hostile/rogue/deepone/wiz
/mob/living/simple_animal/hostile/retaliate/rogue/troll
	proc/ambush()
		return
/mob/living/simple_animal/hostile/retaliate/rogue/mimic
	proc/undisguise()
		return
	proc/disguise()
		return

// ============== LANGUAGE STUBS ==============

/datum/language/oldazurian
/datum/language/raneshi
/datum/language/grenzelhoftian
/datum/language/kazengunese
/datum/language/lingyuese
/datum/language/etruscan
/datum/language/gronnic
/datum/language/otavan
/datum/language/aavnic

// ============== STATUS EFFECT STUBS ==============

/datum/status_effect/buff/ragebad

// ============== AREA STUBS ==============

/area/rogue/indoors/ravoxarena

// ============== SPELL SUBTYPE STUBS ==============

/datum/action/cooldown/spell/projectile/blade_storm

// ============== MISSING PROCS ==============

// Mimic proc stub — called on /mob/living/carbon targets
/mob/living/carbon/proc/freak_out_mimic(mob/mimic)
	return

// Faith stubs
/datum/faith/old_god

// Projectile var stub
/obj/projectile
	var/blocked = 0

// ============== MISSING VARS ON EXISTING TYPES ==============
// These vars are added here (early in compile order) so files that
// reference them before the base type's file is included can find them.
// DO NOT duplicate these in the base type's actual definition file.

// Spell vars on old spell system — already defined in spell.dm
// (removed from here to avoid duplicate definition errors)

// charge_complete proc stub on spell cooldown
/datum/action/cooldown/spell/proc/charge_complete()
	return TRUE

// Simple animal vars — all needed vars are already defined in
// simple_animal.dm, hostile.dm, retaliate.dm, or primordial.dm.
// No additional vars needed here.

// Intent vars (upstream added ready_sound to intents)
/datum/intent
	var/ready_sound = null

// FETCH_YEET_RANGE define from upstream
#define FETCH_YEET_RANGE 8

// Missing armor defines
#define ARMOR_DRAGONSKIN list("blunt" = 100, "slash" = 100, "stab" = 100, "fire" = 100, "magic" = 50)

// Missing rebel throne defines
#define REBEL_THRONE_SPEEDUP_PER_PERSON 5
#define REBEL_THRONE_TIME 600
