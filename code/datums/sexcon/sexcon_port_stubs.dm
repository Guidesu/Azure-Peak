// ==========================================================================================
// SEXCON PORT - stubs for Ratwood-specific paths that don't exist in Azure Peak.
//
// The sexcon code was ported from Ratwood-2.0 and references several datums/types that are
// named differently or don't exist in Azure Peak's god-rename scheme. Rather than silently
// deleting every reference (which would silently disable features and make the port harder
// to diff against upstream), we define minimal stubs here so the code compiles and the logic
// remains intact. Where a Ratwood god was renamed (Xylix->Viator, Baotha->Hausvette), the stub
// re-routes to the Azure Peak equivalent. Where a status effect or stress event doesn't exist
// at all, the stub is a no-op so the feature is inert but the code paths are preserved for
// future porting.
// ==========================================================================================

// --- Missing charflaws ---------------------------------------------------------

/// Ratwood had a "malodorous" (bad smell) character flaw; Azure Peak doesn't. Stub so
/// has_flaw() returns FALSE (the type exists but no mob will ever have it assigned).
/datum/charflaw/malodorous
	name = "Malodorous (stub)"

/// Ratwood had a "baothamarked" addiction flaw tied to the Baotha patron. Azure Peak
/// renamed Baotha to Hausvette; the addiction flaw wasn't ported. Stub for compile.
/datum/charflaw/addiction/baothamarked
	name = "Baotha-Marked (stub)"

// --- Missing status effects ----------------------------------------------------

/datum/status_effect/debuff/stinky_contact
	id = "stinky_contact"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/stinky_contact
	duration = 2 MINUTES

/atom/movable/screen/alert/status_effect/debuff/stinky_contact
	name = "Stinky Contact"
	desc = "Someone stinky touched you."
	icon_state = "debuff"

/datum/status_effect/debuff/emberwine
	id = "emberwine"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/emberwine

/atom/movable/screen/alert/status_effect/debuff/emberwine
	name = "Emberwine"
	desc = "Warmed by emberwine."
	icon_state = "debuff"

/datum/status_effect/buff/cum_consumed
	id = "cum_consumed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/cum_consumed

/atom/movable/screen/alert/status_effect/buff/cum_consumed
	name = "Satiated"
	desc = "You feel sated."
	icon_state = "buff"

// --- Missing stress events -----------------------------------------------------

/datum/stressevent/cumok

/datum/stressevent/cummax

/datum/stressevent/unseemly_made_love
/datum/stressevent/unseemly_made_love/beautiful

// --- Missing confetti type (Xylix prank effect) --------------------------------

/obj/effect/decal/cleanable/confetti/xylix
	name = "confetti"
	desc = "Colorful confetti scattered about."
	icon_state = "confetti"

// --- Missing stress events (additional) ---------------------------------------

/datum/stressevent/thrill

// --- Missing proc: start_sex_session -------------------------------------------

/// Ported from Ratwood: opens the sex UI for the user targeting another mob.
/// Azure Peak's sexcon controller has show_ui() and start() procs; this wraps them.
/mob/living/proc/start_sex_session(mob/living/carbon/human/target)
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	if(!H.sexcon)
		return
	H.sexcon.target = target
	H.sexcon.show_ui()

// --- Missing /obj/item/chastity stub -------------------------------------------
// Azure Peak doesn't have the full chastity system ported from Ratwood/PR #1107.
// The chastity object files (chastity_core.dm, chastity_equip.dm, chastity_variants.dm,
// chastity_cursed.dm) have many Ratwood-specific dependencies (status effects, collar
// system, bodypart features, etc.) that aren't ported yet. This stub provides the minimal
// type, vars, and procs needed by the chastityplay sex actions and helpers so the code
// compiles. The actions will be inert (no chastity devices exist to interact with) but
// the code structure is preserved for future porting.

/obj/item/chastity
	name = "chastity belt"
	desc = "A unisex metal device designed to prevent penetrative sex. (Stub - full system not ported.)"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE
	/// Movement-sound vars (from chastity_core.dm)
	var/chastity_move_sound = null
	var/chastity_move_delay = 0
	var/chastity_move_volume = 55
	var/chastity_move_chance = 5
	var/chastity_high_pop_client_cap = 0
	var/chastity_high_pop_move_chance_mult = 1
	var/tmp/chastity_move_counter = 0
	/// Feature vars
	var/chastity_type = 0
	var/chastity_organtype = 0
	var/lockable = TRUE
	var/locked = FALSE
	var/chastity_cursed = FALSE
	var/cursed_front_mode = 0
	var/cursed_anal_open = FALSE
	var/cursed_spikes_on = FALSE
	var/chastity_flat = FALSE
	var/mob/living/carbon/human/chastity_victim = null
	var/datum/mind/chastity_master = null
	var/received_cum_count = 0
	var/obj/item/dildo/attached_toy = null
	var/datum/bodypart_feature/chastity/chastity_feature = null
	var/obj/item/roguekey/chastity/generated_key = null

/obj/item/chastity/proc/attach_toy(obj/item/dildo/new_toy, mob/user)
	return FALSE

/obj/item/chastity/proc/detach_toy(mob/user)
	return

/obj/item/chastity/proc/refresh_wearer_overlays()
	return

/obj/item/chastity/proc/can_cage_target(mob/living/carbon/human/H, mob/user)
	return TRUE

/obj/item/chastity/proc/chastity_genital_check(mob/living/carbon/human/H)
	return TRUE

/obj/item/chastity/proc/ensure_chastity_feature(mob/living/carbon/human/H)
	return

/obj/item/chastity/proc/attach_chastity_feature(mob/living/carbon/human/H)
	return

/obj/item/chastity/proc/finalize_chastity_equip(mob/living/carbon/human/H)
	return

/obj/item/chastity/proc/is_hardmode_active()
	return FALSE

/obj/item/chastity/proc/get_lock_denial_string()
	return "The lock holds fast."

/obj/item/chastity/proc/is_generated_unlock_key(obj/item/interaction_item)
	return FALSE

/obj/item/chastity/proc/on_chastity_lock_interact(datum/source, mob/user, obj/item/interaction_item, new_locked_state, method)
	return

/obj/item/chastity/proc/sync_generated_key_metadata(mob/living/carbon/human/H, mob/user = null)
	return

/obj/item/chastity/proc/remove_chastity(mob/living/carbon/human/H)
	if(H?.chastity_device == src)
		H.chastity_device = null
	if(chastity_victim == H)
		chastity_victim = null

/obj/item/chastity/proc/record_nonself_ejaculation(mob/living/carbon/human/source, mob/living/carbon/human/wearer)
	return

/obj/item/chastity/proc/break_on_werewolf_transform(mob/living/carbon/human/H)
	remove_chastity(H)

// Subtype referenced by chastity_helpers.dm
/obj/item/chastity/chastity_cage
/obj/item/chastity/chastity_cage/flat

// --- Cursed collar path alias and stub -----------------------------------------
// Azure Peak has the cursed collar at /obj/item/clothing/neck/roguetown/gorget/cursed_collar
// but chastity_helpers.dm references /obj/item/clothing/neck/roguetown/cursed_collar (without
// gorget). This alias ensures the reference resolves. Also adds the record_nonself_ejaculation
// proc that chastity_helpers.dm calls on the collar.

/obj/item/clothing/neck/roguetown/cursed_collar
	parent_type = /obj/item/clothing/neck/roguetown/gorget/cursed_collar

/obj/item/clothing/neck/roguetown/cursed_collar/proc/record_nonself_ejaculation(mob/living/carbon/human/source, mob/living/carbon/human/wearer)
	return

/// Ratwood tracks knotting stats separately for lupians vs non-lupians. Azure Peak doesn't
/// distinguish, so this just aliases the existing STATS_KNOTTED counter.
#define STATS_KNOTTED_NOT_LUPIANS STATS_KNOTTED

// --- Missing mob vars ----------------------------------------------------------

// Ratwood tracks whether a mob was scented by a gnoll this round. Azure Peak has no gnolls,
// so this is a no-op var that lives on /mob/living/carbon/human and is always FALSE.
/mob/living/carbon/human
	/// Ported from Ratwood: tracks gnoll scent exposure for sexcon stinky_contact logic. Always FALSE here (no gnolls).
	var/has_gnoll_scent_this_round = FALSE

// --- Missing item var ---------------------------------------------------------

// Ratwood has a bellsound var on /obj/item for jingle-bell collars. Azure Peak's bell collar
// uses a movement rustle component instead, but sexcon checks collar.bellsound. Stub it here.
/obj/item
	/// Ported from Ratwood: TRUE if this item jingles when moved (bell collar). Always FALSE in Azure Peak.
	var/bellsound = FALSE

// --- Missing procs -------------------------------------------------------------

/// Ported from Ratwood's /mob/proc/check_handholding. Azure Peak has no handholding mechanic,
/// so this always returns FALSE (no handholding to check).
/mob/proc/check_handholding()
	return FALSE

/// Ported from Ratwood's /datum/sex_controller/proc/eora_register_consensual_pair.
/// Azure Peak has no Eora consensual-pair tracking, so this is a no-op.
/datum/sex_controller/proc/eora_register_consensual_pair(mob/living/carbon/human/a, mob/living/carbon/human/b)
	return

// --- Patron path aliases -------------------------------------------------------
// Azure Peak renamed Xylix -> Viator (under /datum/patron/concordat/) and Baotha -> Hausvette.
// The sexcon code references the old paths directly. Rather than editing every call site
// (and breaking the diff against upstream), we define type aliases that point to the new patrons.

/// Azure Peak's Viator patron is the renamed Xylix. This alias lets sexcon's Xylix-specific
/// prank logic compile and resolve to the right patron.
/datum/patron/divine/xylix
	parent_type = /datum/patron/concordat/viator

/// Azure Peak's Hausvette patron is the renamed Baotha. This alias lets sexcon's
/// Baotha-specific emberwine/knotting logic compile and resolve to the right patron.
/datum/patron/inhumen/baotha
	parent_type = /datum/patron/oldkin/hausvette
