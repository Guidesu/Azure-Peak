// Ported from Vanderlin (OpenKeep): code/datums/runeword/runes.dm
// Literal Diablo-2-style named runes, socketed one at a time into an item's
// sockets in a specific sequence to trigger a /datum/runeword (see
// runeword_base.dm). Distinct from this repo's /obj/item/roguegem (which
// grant a single effect on socketing rather than needing to be sequenced).
//
// NOTE: no per-rune sprites exist in this repo's icon files, so all rune
// subtypes below intentionally share the base icon_state rather than
// referencing icon_states that don't exist on disk.
/obj/item/rune
	name = "rune"
	desc = "A mystical rune etched with ancient power. It can be socketed into equipment with open sockets."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "seraphinapainting"
	w_class = WEIGHT_CLASS_TINY
	sellprice = 0
	static_price = FALSE
	/// Lowercase keyword used to match against /datum/runeword/runes sequences.
	var/rune_type = ""

/obj/item/rune/examine(mob/user)
	. = ..()
	. += span_notice("Socket this into an item with open sockets. Combining the right sequence of runes completes a runeword.")

/obj/item/rune/tir
	name = "Tir rune"
	desc = "A rune associated with restoration."
	rune_type = "tir"

/obj/item/rune/el
	name = "El rune"
	desc = "A rune of light and accuracy."
	rune_type = "el"

/obj/item/rune/ral
	name = "Ral rune"
	desc = "A rune of fire."
	rune_type = "ral"

/obj/item/rune/ort
	name = "Ort rune"
	desc = "A rune of lightning."
	rune_type = "ort"

/obj/item/rune/eth
	name = "Eth rune"
	desc = "A rune that weakens defenses."
	rune_type = "eth"

/obj/item/rune/amn
	name = "Amn rune"
	desc = "A rune of life stealing."
	rune_type = "amn"

/obj/item/rune/dol
	name = "Dol rune"
	desc = "A rune of fear."
	rune_type = "dol"

/obj/item/rune/io
	name = "Io rune"
	desc = "A rune of vitality."
	rune_type = "io"

/obj/item/rune/sur
	name = "Sur rune"
	desc = "A rune of blindness."
	rune_type = "sur"

/obj/item/rune/shael
	name = "Shael rune"
	desc = "A rune of speed."
	rune_type = "shael"

/obj/item/rune/eld
	name = "Eld rune"
	desc = "A rune effective against the undead."
	rune_type = "eld"

/obj/item/rune/nef
	name = "Nef rune"
	desc = "A rune of knockback."
	rune_type = "nef"

/obj/item/rune/thul
	name = "Thul rune"
	desc = "A rune of cold."
	rune_type = "thul"

/obj/item/rune/mal
	name = "Mal rune"
	desc = "A rune that resists healing."
	rune_type = "mal"

/obj/item/rune/tal
	name = "Tal rune"
	desc = "A rune of poison."
	rune_type = "tal"
