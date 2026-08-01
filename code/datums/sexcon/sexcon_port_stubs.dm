// ==========================================================================================
// SEXCON PORT - stubs for Ratwood-specific paths that don't exist in this codebase.
//
// The sexcon code was ported from Ratwood-2.0 and references several datums/types that are
// named differently or don't exist in this codebase's god-rename scheme. Rather than silently
// deleting every reference (which would silently disable features and make the port harder
// to diff against upstream), we define minimal stubs here so the code compiles and the logic
// remains intact. Where a Ratwood god was renamed (Xylix->Viator, Baotha->Hausvette), the stub
// re-routes to the equivalent. Where a status effect or stress event doesn't exist
// at all, the stub is a no-op so the feature is inert but the code paths are preserved for
// future porting.
// ==========================================================================================

// --- Missing charflaws ---------------------------------------------------------

/// Ratwood had a "malodorous" (bad smell) character flaw; this codebase doesn't. Stub so
/// has_flaw() returns FALSE (the type exists but no mob will ever have it assigned).
/datum/charflaw/malodorous
	name = "Malodorous (stub)"

/// Ratwood had a "baothamarked" addiction flaw tied to the Baotha patron. this codebase
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
	name = "Aphrodisiac"
	desc = "The warmth is spreading through my body..."
	icon_state = "emberwine"

/datum/status_effect/buff/cum_consumed
	id = "cum_consumed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/cum_consumed
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/cum_consumed
	name = "Cumdrunk"
	desc = "I've swallowed someone's load..."
	icon_state = "drunk"

// --- Missing stress events -----------------------------------------------------

/datum/stressevent/cumok

/datum/stressevent/cummax

/datum/stressevent/unseemly_made_love
/datum/stressevent/unseemly_made_love/beautiful

// --- Missing confetti type (Xylix prank effect) --------------------------------

/obj/effect/decal/cleanable/confetti/xylix
	name = "confetti"
	desc = "A colorful scatter of confetti made of dyed parchment. It smells funny."
	icon = 'icons/effects/confetti.dmi'
	mouse_opacity = MOUSE_OPACITY_ICON
	random_icon_states = list("confetti1", "confetti2", "confetti3")

// --- Missing stress events (additional) ---------------------------------------

/datum/stressevent/thrill

// --- Missing proc: start_sex_session -------------------------------------------

/// Ported from Ratwood: opens the sex UI for the user targeting another mob.
/// this codebase's sexcon controller has show_ui() and start() procs; this wraps them.
/mob/living/proc/start_sex_session(mob/living/carbon/human/target)
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	if(!H.sexcon)
		return
	H.sexcon.target = target
	H.sexcon.show_ui()

// --- Cursed collar path alias and stub -----------------------------------------
// this codebase has the cursed collar at /obj/item/clothing/neck/roguetown/gorget/cursed_collar
// but chastity_helpers.dm references /obj/item/clothing/neck/roguetown/cursed_collar (without
// gorget). This alias ensures the reference resolves. Also adds the record_nonself_ejaculation
// proc that chastity_helpers.dm calls on the collar.

/obj/item/clothing/neck/roguetown/cursed_collar
	parent_type = /obj/item/clothing/neck/roguetown/gorget/cursed_collar

/obj/item/clothing/neck/roguetown/cursed_collar/proc/record_nonself_ejaculation(mob/living/carbon/human/source, mob/living/carbon/human/wearer)
	return

/// Ratwood tracks knotting stats separately for lupians vs non-lupians. this codebase doesn't
/// distinguish, so this just aliases the existing STATS_KNOTTED counter.
#define STATS_KNOTTED_NOT_LUPIANS STATS_KNOTTED

// --- Missing mob vars ----------------------------------------------------------

// Ratwood tracks whether a mob was scented by a gnoll this round. this codebase has no gnolls,
// so this is a no-op var that lives on /mob/living/carbon/human and is always FALSE.
/mob/living/carbon/human
	/// Ported from Ratwood: tracks gnoll scent exposure for sexcon stinky_contact logic. Always FALSE here (no gnolls).
	var/has_gnoll_scent_this_round = FALSE

// --- Missing item var ---------------------------------------------------------

// Ratwood has a bellsound var on /obj/item for jingle-bell collars. this codebase's bell collar
// uses a movement rustle component instead, but sexcon checks collar.bellsound. Stub it here.
/obj/item
	/// Ported from Ratwood: TRUE if this item jingles when moved (bell collar). Always FALSE in this codebase.
	var/bellsound = FALSE

// --- Missing procs -------------------------------------------------------------

/// Ported from Ratwood's /mob/proc/check_handholding. this codebase has no handholding mechanic,
/// so this always returns FALSE (no handholding to check).
/mob/proc/check_handholding()
	return FALSE

/// Ported from Ratwood's /datum/sex_controller/proc/eora_register_consensual_pair.
/// this codebase has no Eora consensual-pair tracking, so this is a no-op.
/datum/sex_controller/proc/eora_register_consensual_pair(mob/living/carbon/human/a, mob/living/carbon/human/b)
	return

// --- Patron path aliases -------------------------------------------------------
// this codebase renamed Xylix -> Viator (under /datum/patron/concordat/) and Baotha -> Hausvette.
// The sexcon code references the old paths directly. Rather than editing every call site
// (and breaking the diff against upstream), we define type aliases that point to the new patrons.

/// this codebase's Viator patron is the renamed Xylix. This alias lets sexcon's Xylix-specific
/// prank logic compile and resolve to the right patron.
/datum/patron/divine/xylix
	parent_type = /datum/patron/concordat/viator

/// this codebase's Hausvette patron is the renamed Baotha. This alias lets sexcon's
/// Baotha-specific emberwine/knotting logic compile and resolve to the right patron.
/datum/patron/inhumen/baotha
	parent_type = /datum/patron/oldkin/hausvette

/datum/patron/divine/eora
	parent_type = /datum/patron/concordat/miluse

/datum/status_effect/surrender/collar

/datum/stressevent/chastity_devout
	timer = 999 MINUTES
	stressadd = -1
	desc = span_green("This restraint steadies my spirit.")

/datum/stressevent/chastity_masochist
	timer = 999 MINUTES
	stressadd = -1
	desc = span_green("The spikes keep me pleasantly focused.")

/datum/stressevent/chastity_church
	timer = 999 MINUTES
	stressadd = -1
	desc = span_green("My vows feel stronger in this restraint.")

/datum/stressevent/chastity_frustration
	timer = 999 MINUTES
	stressadd = 1
	desc = span_red("This restraint is maddening.")

/datum/stressevent/chastity_flat_cramped
	timer = 999 MINUTES
	stressadd = 1
	desc = span_red("This cage is too cramped for me.")

/datum/component/collar_master
	var/list/registered_pets = list()
	var/list/my_pets = list()

/datum/component/collar_master/proc/add_pet(mob/living/carbon/human/pet)
	if(!pet)
		return FALSE
	if(!(pet in registered_pets))
		registered_pets += pet
	if(!(pet in my_pets))
		my_pets += pet
	return TRUE

/datum/component/collar_master/proc/remove_pet(mob/living/carbon/human/pet)
	registered_pets -= pet
	my_pets -= pet
	return TRUE

/datum/component/collar_master/proc/cleanup_pet(mob/living/carbon/human/pet)
	return remove_pet(pet)

/proc/log_chastity_command(mob/living/carbon/human/wearer, datum/mind/master, command, details = "", remote = FALSE)
	if(wearer)
		log_admin("Chastity command [command] on [key_name(wearer)] ([details])[remote ? " [remote]" : ""]")

#define COMSIG_CARBON_LOSE_CHASTITY "carbon_lose_chastity"
