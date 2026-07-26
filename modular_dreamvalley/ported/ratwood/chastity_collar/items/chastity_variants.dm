/**
 * Ported from Ratwood-2.0's modular/code/game/objects/items/lewd/chastity/chastity_variants.dm — chastity_collar
 * port, Stage 1. Only STANDARD (non-cursed) variants are ported per Stage 1 scope; /obj/item/chastity/cursed
 * is intentionally OMITTED — it's collar-adjacent (locked/unlocked exclusively via the collar master TGUI, which
 * doesn't exist in this repo yet) and belongs entirely to a later stage.
 */

/obj/item/chastity/chastity_cage
	name = "chastity cage"
	desc = "A secure metal cage for keeping a cock from getting hard."
	icon_state = "cage_standard"
	item_state = "cage_standard"
	mob_overlay_icon = "cage_standard"
	sprite_acc = /datum/sprite_accessory/chastity/cage
	chastity_type = 1
	chastity_organtype = 1
	suffix = null

/obj/item/chastity/chastity_cage/anal
	name = "chastity cage with anal shield"
	desc = "A secure cage with a rear shield to deny anal access too."
	chastity_type = 2
	icon_state = "cage_standard_shield"
	item_state = "cage_standard_shield"
	suffix = null

/obj/item/chastity/chastity_cage/spiked
	name = "spiked chastity cage"
	desc = "A punitive cage lined with inward spikes."
	chastity_type = 3
	icon_state = "cage_standard_spiked"
	item_state = "cage_standard_spiked"
	sprite_acc = /datum/sprite_accessory/chastity/spiked
	suffix = null

/obj/item/chastity/chastity_cage/spiked_anal
	name = "spiked chastity cage with anal shield"
	desc = "A cruel spiked cage with rear denial shielding."
	chastity_type = 4
	icon_state = "cage_standard_spikeshield"
	item_state = "cage_standard_spikeshield"
	sprite_acc = /datum/sprite_accessory/chastity/spiked_anal
	suffix = null

/obj/item/chastity/chastity_cage/flat
	name = "flat chastity cage"
	desc = "A flattened cage profile that presses close against the body."
	chastity_flat = TRUE
	icon_state = "cage_flat"
	item_state = "cage_flat"
	sprite_acc = /datum/sprite_accessory/chastity/flat
	suffix = null

/obj/item/chastity/chastity_cage/flat/anal
	name = "flat chastity cage with anal shield"
	desc = "A flat-profile cage with rear denial shielding."
	chastity_type = 2
	icon_state = "cage_flat_shield"
	item_state = "cage_flat_shield"
	suffix = null

/obj/item/chastity/chastity_cage/flat/spiked
	name = "spiked flat chastity cage"
	desc = "A flat-profile cage with inward punishment spikes."
	chastity_type = 3
	icon_state = "cage_flat_spiked"
	item_state = "cage_flat_spiked"
	suffix = null

/obj/item/chastity/chastity_cage/flat/spiked_anal
	name = "spiked flat chastity cage with anal shield"
	desc = "A flat, spiked cage with rear denial shielding."
	chastity_type = 4
	icon_state = "cage_flat_spikeshield"
	item_state = "cage_flat_spikeshield"
	suffix = null

/obj/item/chastity/chastity_belt
	name = "chastity insertable"
	desc = "A locked belt with an inward insertable shape for constant denial."
	icon_state = "cage_insert"
	item_state = "cage_insert"
	mob_overlay_icon = "cage_insert"
	sprite_acc = /datum/sprite_accessory/chastity/full
	chastity_type = 5
	chastity_organtype = 2
	suffix = null

/obj/item/chastity/chastity_belt/anal
	name = "chastity insertable with anal shield"
	desc = "An insertable belt with additional rear shielding."
	chastity_type = 6
	icon_state = "cage_insert_shield"
	item_state = "cage_insert_shield"
	sprite_acc = /datum/sprite_accessory/chastity/anal
	suffix = null

/obj/item/chastity/chastity_belt/spiked
	name = "spiked chastity insertable"
	desc = "An insertable belt fitted with cruel inward spikes."
	chastity_type = 7
	icon_state = "cage_insert_spiked"
	item_state = "cage_insert_spiked"
	sprite_acc = /datum/sprite_accessory/chastity/spiked_belt
	suffix = null

/obj/item/chastity/chastity_belt/spiked_anal
	name = "spiked chastity insertable with anal shield"
	desc = "A spiked insertable belt with rear denial shielding."
	chastity_type = 8
	icon_state = "cage_insert_spikeshield"
	item_state = "cage_insert_spikeshield"
	sprite_acc = /datum/sprite_accessory/chastity/spiked_belt_anal
	suffix = null

/obj/item/chastity/intersex
	name = "intersex chastity device"
	desc = "A broad frame combining a cage and a shield in one locked device."
	icon_state = "cage_belt"
	item_state = "cage_belt"
	mob_overlay_icon = "cage_belt"
	sprite_acc = /datum/sprite_accessory/chastity/intersex
	chastity_type = 0
	chastity_organtype = 3
	suffix = null

/obj/item/chastity/intersex/spiked
	name = "spiked intersex chastity device"
	desc = "An intersex device fitted with inward punishment spikes."
	chastity_type = 9
	icon_state = "cage_belt"
	item_state = "cage_belt"
	sprite_acc = /datum/sprite_accessory/chastity/spiked
	suffix = null

// /obj/item/chastity/cursed intentionally omitted — Stage 1 scope excludes cursed/collar-adjacent devices.
// See chastity_equip.dm's attack()/attack_self() for the explicit block on chastity_cursed = TRUE items.
