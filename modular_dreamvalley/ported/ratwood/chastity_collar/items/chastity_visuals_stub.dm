/**
 * Stage 1 stubs for the visual-layering types /obj/item/chastity references (chastity_feature, sprite_acc).
 * TODO Stage 3: sprite accessory integration — full customizer/sprite_accessory rendering support.
 *
 * Until then, these exist purely so the item compiles and can be equipped/locked/unlocked/apply traits
 * correctly; they render no visible sprite overlay (get_bodypart_overlay returns null via the base
 * /datum/bodypart_feature stub in code/modules/surgery/bodyparts/bodypart_features/_bodypart_feature.dm,
 * and these /datum/sprite_accessory/chastity subtypes have no icon/icon_state set so they resolve empty).
 */

/datum/bodypart_feature/chastity
	name = "Chastity Device"
	body_zone = BODY_ZONE_CHEST
	feature_slot = "chastity"
	/// Back-reference to the /obj/item/chastity that owns this feature, set by ensure_chastity_feature().
	var/obj/item/chastity/chastity_item

// STAGE 1: no icon/icon_state set on any of these — see chastity_core.dm's ensure_chastity_feature() /
// attach_chastity_feature() for how this stub is wired in, and chastity_variants.dm for which subtype
// each concrete device variant references via its sprite_acc var.
/datum/sprite_accessory/chastity
	name = "Chastity Device"
	color_keys = 0

/datum/sprite_accessory/chastity/full
	name = "Chastity Device - Full"

/datum/sprite_accessory/chastity/cage
	name = "Chastity Device - Cage"

/datum/sprite_accessory/chastity/anal
	name = "Chastity Device - Anal Shield"

/datum/sprite_accessory/chastity/flat
	name = "Chastity Device - Flat Cage"

/datum/sprite_accessory/chastity/spiked
	name = "Chastity Device - Spiked"

/datum/sprite_accessory/chastity/spiked_anal
	name = "Chastity Device - Spiked Anal Shield"

/datum/sprite_accessory/chastity/spiked_belt
	name = "Chastity Device - Spiked Belt"

/datum/sprite_accessory/chastity/spiked_belt_anal
	name = "Chastity Device - Spiked Belt Anal Shield"

/datum/sprite_accessory/chastity/intersex
	name = "Chastity Device - Intersex"
