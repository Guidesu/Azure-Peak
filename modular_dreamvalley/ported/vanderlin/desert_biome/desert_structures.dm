// Ported from Vanderlin (E:\GitHub\Vanderlin\code\game\objects\fluff.dm).
//
// See desert_turfs.dm for the "Desert Town" scope investigation note. These are the
// decorative/fluff structure objects that accompany the desert delve tileset: an
// elevator prop, wooden boards, a window frame prop, and two decorative flora/rubble
// pieces. No jobs, factions, or NPCs are included.
//
// Adaptation notes:
// - Vanderlin's /obj/structure/desert_elevator, /obj/structure/boards, and
//   /obj/structure/desert_window all inherited directly from bare /obj/structure. This
//   codebase has an established /obj/structure/fluff base ("Fluff structures serve no
//   purpose and exist only for enriching the environment") used for exactly this kind of
//   decor-only prop (see code/game/objects/structures/fluff.dm), so these were rebased
//   onto /obj/structure/fluff instead for consistency with local convention.
// - /obj/structure/flora/astrata is decorative dressing named after Vanderlin's light
//   deity. This codebase happens to independently have its own "Astrata" patron in its
//   pantheon (code/modules/spells/roguetown/acolyte/astrata.dm etc.) - this port does NOT
//   connect to or reference that system in any way; it is kept purely as a cosmetic flora
//   sprite with a religion-neutral description to avoid implying a tie to this repo's own
//   pantheon content.
// - /obj/structure/flora/sandbrick (loose sandstone brick rubble) ported as-is under this
//   repo's /obj/structure/flora base.

/obj/structure/fluff/desert_elevator
	name = "elevator"
	desc = "A heavy lifting platform, worked by some manner of forgotten mechanism."
	icon = 'icons/delver/desert_elevator.dmi'
	icon_state = "elevator"
	density = FALSE

/obj/structure/fluff/desert_boards
	name = "boards"
	desc = "A stack of weathered wooden boards."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "boards"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fluff/desert_boards, 32)

/obj/structure/fluff/desert_window
	name = "desert window"
	desc = "A window frame, its shutters long since worn away."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "window_brass"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fluff/desert_window, 32)

/obj/structure/fluff/desert_window/open
	name = "open desert window"
	desc = "A window frame, thrown open to the heat."
	icon_state = "window_open"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fluff/desert_window/open, 32)

/obj/structure/flora/desert_flowering_shrub
	name = "flowering desert shrub"
	desc = "A hardy shrub, somehow still flowering in the heat."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "astrata1"
	resistance_flags = FIRE_PROOF
	density = TRUE

/obj/structure/flora/desert_flowering_shrub/two
	icon_state = "astrata2"

/obj/structure/flora/desert_flowering_shrub/three
	icon_state = "astrata3"

/obj/structure/flora/sandbrick
	name = "sandstone brick"
	desc = "A loose brick of sandstone, worn smooth."
	icon = 'icons/delver/desert_objects.dmi'
	icon_state = "sandstone_brick"
	resistance_flags = FIRE_PROOF
