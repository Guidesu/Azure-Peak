// Inspiration component assignments — attaches inspiration to existing objects
// This file hooks the inspiration component onto existing DreamValley objects
// without modifying their original files.

// ============== PAINTINGS (art inspiration) ==============

/obj/item/rogue/painting/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inspiration/art, 10, 10 MINUTES, TRUE, "The artistry moves you. You feel a surge of inspiration.")

/obj/structure/fluff/walldeco/painting/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inspiration/art, 10, 10 MINUTES, TRUE, "The artistry moves you. You feel a surge of inspiration.")

// ============== BOOKS (literature inspiration) ==============

/obj/item/book/rogue/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inspiration/literature, 8, 15 MINUTES, TRUE, "The words stir something within you. You feel enlightened.")

// ============== INSTRUMENTS (art inspiration) ==============

/obj/item/rogue/instrument/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/inspiration/art, 5, 10 MINUTES, TRUE, "The craftsmanship of this instrument inspires you.")

// ============== ODDITIES (already have their own inspiration via attack_self) ==============
// Oddities don't need the component — they use attack_self for meditation.

// ============== CHURCH AREAS — holy objects ==============
// The church area itself provides sanity restoration via sanity_hazard.
// Individual holy objects in the church can provide inspiration.
