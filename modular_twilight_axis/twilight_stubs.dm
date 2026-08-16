// Twilight-Axis compatibility stubs for DreamValley
// This file provides stub definitions for types/vars/procs that Twilight
// code references but that don't exist in DreamValley's codebase.
// Defines are in twilight_defines.dm (included before Twilight code).

GLOBAL_VAR_INIT(cold_breath_overlay, null)

// ============================================================================
// MISSING STRESS EVENTS
// ============================================================================
/datum/stressevent/cumself
/datum/stressevent/cummid
/datum/stressevent/cumgood
/datum/stressevent/cumlove
/datum/stressevent/cumpaingood
/datum/stressevent/hatezizo
/datum/stressevent/lovezizo
/datum/stressevent/thrillsex
/datum/stressevent/soulchurnerpsydon

// ============================================================================
// MISSING JOB TYPES (Twilight-specific jobs)
// ============================================================================
/datum/job/roguetown/sultan
/datum/job/roguetown/vizier
/datum/job/roguetown/sheikh
/datum/job/roguetown/cataphract
/datum/job/roguetown/janissarysergeant
/datum/job/roguetown/janissary
/datum/job/roguetown/azebagha
/datum/job/roguetown/azeb
/datum/job/roguetown/slavemaster
/datum/job/roguetown/headslave
/datum/job/roguetown/slave
/datum/job/roguetown/freeman

// ============================================================================
// MISSING CLOTHING TYPES
// ============================================================================
/obj/item/clothing/neck/roguetown/psicross/xylix
/obj/item/clothing/neck/roguetown/psicross/silver/noc
/obj/item/clothing/neck/roguetown/psicross/silver/naledi
/obj/item/clothing/neck/roguetown/psicross/dendor
/obj/item/clothing/neck/roguetown/psicross/abyssor
/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar
/obj/item/clothing/neck/roguetown/psicross/inhumen/baotha
/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios
/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios/gilded
/obj/item/clothing/neck/roguetown/psicross/inhumen/matthios/gronn
/obj/item/clothing/neck/roguetown/psicross/inhumen/gronn
/obj/item/clothing/neck/roguetown/psicross/inhumen/gronn/special
/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar/gronn
/obj/item/clothing/neck/roguetown/psicross/inhumen/baothagronn
/obj/item/clothing/neck/roguetown/psicross/inhumen/iron
/obj/item/clothing/neck/roguetown/psicross/dendor/gronn
/obj/item/clothing/neck/roguetown/psicross/abyssor/gronn

/obj/item/clothing/cloak/tabard/devotee
/obj/item/clothing/cloak/tabard/devotee/dendor
/obj/item/clothing/cloak/tabard/devotee/ravox
/obj/item/clothing/cloak/tabard/devotee/astrata
/obj/item/clothing/cloak/tabard/devotee/psydon
/obj/item/clothing/cloak/tabard/crusader
/obj/item/clothing/cloak/tabard/crusader/dendor
/obj/item/clothing/cloak/tabard/crusader/astrata
/obj/item/clothing/cloak/tabard/psydontabard

/obj/item/clothing/head/roguetown/roguehood/astrata
/obj/item/clothing/head/roguetown/roguehood/psydon
/obj/item/clothing/head/roguetown/roguehood/psydon/confessor
/obj/item/clothing/head/roguetown/roguehood/psydon/black

/obj/item/clothing/shoes/roguetown/boots/psydonboots

// ============================================================================
// MISSING STATUS EFFECTS
// ============================================================================
/datum/status_effect/buff/ravox_provocation
/datum/status_effect/astrata_favor
/datum/status_effect/eora_favor
/datum/status_effect/ravox_favor
/datum/status_effect/malum_favor
/datum/status_effect/noc_favor
/datum/status_effect/buff/astrata_gaze
/datum/status_effect/xylix_blessed_luck

// ============================================================================
// MISSING DATUM TYPES
// ============================================================================
/datum/storyteller/zizo
/datum/asset/spritesheet_batched/loadout_icons
	name = "loadout-icons"

/datum/asset/spritesheet_batched/loadout_icons/create_spritesheets()
	return

// ============================================================================
// MISSING OBJ TYPES
// ============================================================================
/obj/structure/fluff/ravox
/obj/structure/ritualcircle/ravox
/obj/structure/ritualcircle/astrata
/obj/structure/ritualcircle/dendor
/obj/structure/deadbodyrandom/low
/obj/effect/temp_visual/trap

// ============================================================================
// MISSING SPELL TYPES
// ============================================================================
/datum/action/cooldown/spell/miracle/fortify/astrata
/datum/action/cooldown/spell/psydon/respite
/datum/action/cooldown/spell/psydon/persist
/datum/action/cooldown/spell/projectile/azurean_pilum
/datum/action/cooldown/spell/azurean_phalanx
/obj/effect/proc_holder/spell/invoked/psydonlux_tamper
/obj/effect/proc_holder/spell/invoked/resurrect/ravox
/obj/effect/proc_holder/spell/self/convertrole/slave

// ============================================================================
// MISSING TURF TYPES
// ============================================================================
/turf/open/floor/rogue/AzureSand

// ============================================================================
// MISSING AREA TYPES
// ============================================================================
/area/rogue/indoors/ravoxarena
/area/rogue/outdoors/woodsrat
/area/rogue/indoors/town/grove

/area/rogue/indoors/ravoxarena/proc/cleanthearena()
	return

// ============================================================================
// MISSING HELPER PROCS
// ============================================================================
/proc/cmp_num_string_asc(a, b)
	return sorttext(b, a)

/proc/span_reallybigredtext(text)
	return "<span class='reallybigredtext'>[text]</span>"

// ============================================================================
// MISSING MOB PROCS (stubs - only procs that don't exist in DV)
// ============================================================================
/mob/living/proc/is_zizocultist()
	return FALSE

/mob/living/proc/is_zizolackey()
	return FALSE

/atom/proc/get_all_contents_ignoring()
	return contents

/atom/proc/get_all_contents()
	return contents

/proc/do_thrust_animate()
	return

// ============================================================================
// MISSING MIND PROCS
// ============================================================================
/datum/mind/proc/get_job_prefs()
	return list()

// ============================================================================
// MISSING CLIENT PROCS
// ============================================================================
/datum/admin_help_tickets/proc/IsAdminInHideCharname()
	return FALSE

/proc/can_adjust_playerquality_by_admin_ckey()
	return FALSE

// ============================================================================
// MISSING PREFERENCES PROCS
// ============================================================================
/datum/preferences/proc/get_loadout_lock_reason()
	return null

/datum/preferences/proc/validate_prefs_for_job()
	return TRUE

/datum/preferences/proc/get_job_prefs()
	return list()

/datum/job/proc/validate_prefs_for_job()
	return TRUE

/datum/loadout_item/proc/get_loadout_lock_reason()
	return null

// ============================================================================
// MISSING ITEM PROCS
// ============================================================================

// ============================================================================
// MISSING GLOBAL PROCS
// ============================================================================
/proc/is_type_on_turf()
	return FALSE

/proc/log_telepathy()
	return

/proc/get_zlevel_turf_lists()
	return list()

/proc/resident_manuscripts_enabled()
	return FALSE

/proc/grant_roundstart_faction_manuscript()
	return

/proc/resident_manuscript_uses_dun_world_tavern_filter()
	return FALSE

/proc/resident_manuscript_uses_resident_tavern_spawn()
	return FALSE

/proc/capture_character_manor()
	return

/proc/restore_character_manor()
	return

/proc/get_donator_triumph_discount()
	return 0

/proc/is_zizocultist(datum/mind/M)
	return FALSE

/proc/is_zizolackey(datum/mind/M)
	return FALSE

// ============================================================================
// MISSING VARS ON EXISTING TYPES
// ============================================================================
/mob/living
	var/aphrodisiac = 0
	var/arousal_multiplier = 1
	var/arousal_frozen = FALSE
	var/no_runechat_animation = FALSE
	var/defiant = 0

/mob/living/simple_animal
	var/speed = 0
	var/obj/item/natural/saddle/ssaddle = null
	var/can_saddle = FALSE
	var/simple_detect_bonus = 0
	var/dodge_fatigue = 0
	var/dodge_fatigue_updated = 0
	var/winded_until = 0
	var/natural_armor_default = list()
	var/natural_armor = list()

/mob/living/carbon/human/species/human/northern/ravox_spirit
	parent_type = /mob/living/carbon/human
	var/buffed_r = FALSE

/datum/species
	var/fur_insulation = 0
	var/vaeltic = 0

/datum/world_trait/zizo_pet_cementery

/obj/item
	var/persistence_path = ""
	var/icon_loadout = null
	var/donatitem = FALSE
	var/donat_tier = 0
	var/bell = FALSE
	var/leashable = FALSE
	var/is_being_thrown_by_special = FALSE

/obj/item/clothing
	var/base_icon_state = null

/obj/item/gun/ballistic/revolver/grenadelauncher/bow
	var/special = null

/obj/item/canvas
	var/painting_id = ""

/datum/component/arousal
	var/arousal_multiplier = 1
	var/last_moan = 0
	var/last_arousal_increase_time = 0
	var/arousal_frozen = FALSE

/datum/advclass
	var/origin_limits = list()

/datum/loadout_item
	var/donatitem = FALSE
	var/donat_tier = 0

/datum/preferences
	var/no_runechat_animation = FALSE
	var/donor_priority_last_round_index = 0
	var/list/selected_loadout_items = list()

/area
	var/ticket_ping = null
	var/ticket_ping_stop = null

// ============================================================================
// MISSING ERP PROCS (stubs for arousal component)
// ============================================================================
/datum/component/arousal/proc/is_spent()
	return FALSE

/datum/component/arousal/proc/set_arousal()
	return

/datum/component/arousal/proc/adjust_arousal()
	return

/datum/component/arousal/proc/check_processing()
	return TRUE

/datum/component/arousal/proc/handle_charge()
	return

/datum/component/arousal/proc/can_lose_arousal()
	return TRUE

/datum/component/arousal/proc/get_force_pleasure_multiplier()
	return 1

/datum/component/arousal/proc/get_force_pain_multiplier()
	return 1

/datum/component/arousal/proc/get_speed_pain_multiplier()
	return 1

/datum/component/arousal/proc/damage_from_pain()
	return

/datum/component/arousal/proc/try_do_moan()
	return

/datum/component/arousal/proc/try_do_pain_effect()
	return

/datum/component/arousal/proc/ejaculate()
	return

/datum/component/arousal/proc/handle_climax()
	return

/datum/component/arousal/proc/after_ejaculation()
	return

/datum/component/arousal/proc/try_ejaculate()
	return

/datum/component/arousal/proc/receive_sex_action()
	return

// ============================================================================
// MISSING FAMILY TREE PROCS
// ============================================================================
/proc/give_sultan_surname()
	return

// ============================================================================
// MISSING GRANTER PARENT TYPE
// ============================================================================
/obj/item/book/granter/resident_manuscript
	parent_type = /obj/item/book/granter
/obj/item/book/granter/resident_manuscript/fake
	parent_type = /obj/item/book/granter/resident_manuscript
/obj/item/book/granter/resident_manuscript/roundstart
	parent_type = /obj/item/book/granter/resident_manuscript
/obj/item/book/granter/resident_manuscript/blank
	parent_type = /obj/item/book/granter/resident_manuscript

// ============================================================================
// MISSING KEYRING TYPES
// ============================================================================
/obj/item/storage/keyring/bailiff
/obj/item/storage/keyring/mayor
/obj/item/storage/keyring/courtphysician
/obj/item/storage/keyring/sheriff
/obj/item/storage/keyring/vanguard_enigma
/obj/item/storage/keyring/warden_enigma
/obj/item/storage/keyring/watchman
/obj/item/storage/keyring/dungeoneer
/obj/item/storage/keyring/knightenigma

// ============================================================================
// MISSING SPELL VARS
// ============================================================================
/datum/magic_aspect
	var/binding_chants = list()
	var/unbinding_chants = list()

// ============================================================================
// MISSING ZIZOCULT VARS
// ============================================================================
/obj/effect/decal/cleanable
	var/clean_type = 0

// ============================================================================
// MISSING BOOK TYPES
// ============================================================================
/obj/item/book/rogue/ronin_codex
/obj/item/book/rogue/soundbreaker_codex

// ============================================================================
// MISSING ADVCLASS TYPES
// ============================================================================
/datum/advclass/blackpowder_legionnaire
/datum/advclass/otavan_volf

// ============================================================================
// MISSING ITEM TYPES
// ============================================================================
/obj/item/natural/clay/xylixmask

// ============================================================================
// MISSING PSYCROSS TYPES
// ============================================================================
/obj/structure/fluff/psycross/graggar
/obj/structure/fluff/psycross/baotha

// ============================================================================
// MISSING AREA PROCS
// ============================================================================
/area/proc/get_zlevel_turf_lists()
	return list()

// ============================================================================
// MISSING STRUCTURE PROCS
// ============================================================================
/obj/structure/fluff/ravox/proc/spawnprotection()
	return

// ============================================================================
// MISSING SSmapping.retainer stubs
// ============================================================================
/datum/antag_retainer
	var/list/cultists = list()
	var/cultist_number = 0
	var/cult_ascended = FALSE
	var/cult_ascension_required_cultists = 5

// ============================================================================
// MISSING ADMIN TICKET PROCS
// ============================================================================
/datum/admin_help
	var/handler = null
	var/ticket_ping = null
	var/ticket_ping_stop = null

/datum/admin_help/proc/mentorissue()
	return

/datum/admin_help/proc/handle_issue()
	return

// ============================================================================
// MISSING VARS ON EXISTING TYPES (additional)
// ============================================================================
/mob/living/carbon/human
	var/selected_loadout_items = list()

/client
	var/donor_priority_last_round_index = 0

// GLOB stubs for Twilight loadout system
GLOBAL_LIST_EMPTY(loadout_items_by_category)
