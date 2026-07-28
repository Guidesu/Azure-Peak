// Old-pantheon psicross amulets (astrata, dendor, eora, malum, necra, noc,
// pestra, ravox) placed directly by byos.dmm's raw map data.
//
// PANTHEON JUDGMENT CALL (see task instructions, point 1):
// This repo replaced the old roguetown pantheon with a new one (Concordat /
// Severance / Old Kin / Tribunal / Unveiled). Every god in the new pantheon
// that has a real domain overlap already has ITS OWN dedicated psicross in
// code/modules/clothing/rogueclothes/neck.dm: Auxentius, Handwerra, Miluse,
// Morwenna, Viator, Wulfric (Concordat), Hausvette, Volkovoi (Old Kin),
// Custodius (Tribunal), Ignatius (Severance) all already have amulets there.
// So these 8 old names are not "the same god under an old name" duplicates —
// they're stale leftovers from the pre-rename pantheon that the map's raw
// tile data still references by literal type path (which can't be edited
// without touching the 225k-line .dmm). Per the task's guidance, the safest
// fix is to make the exact path exist, reflavored as antique/heretical relics
// from before the current pantheon took hold — fitting for byos, an ancient
// ruins/bandit-cove map. All 8 icon_states (astrata, dendor, eora, malum,
// necra, noc, pestra, ravox) already exist in this repo's own neck.dmi as
// unused leftover art, so no new icon assets were needed.

/obj/item/clothing/neck/roguetown/psicross/astrata
	name = "sunworn amulet"
	desc = "A tarnished amulet bearing the sunburst sigil of a queen-goddess no longer named in any living creed. Some old-timers say it predates even the Concordat's Court of Six Seats — a relic of whichever god watched the sun before Auxentius did."

/obj/item/clothing/neck/roguetown/psicross/dendor
	name = "verdant amulet"
	desc = "A weathered amulet etched with crawling vines and root-shapes. Whatever life-cult once wore this has long since been absorbed or forgotten; these days, Trnava's folk keep to the deep wood instead."

/obj/item/clothing/neck/roguetown/psicross/eora
	name = "kinship amulet"
	desc = "A plain, well-worn amulet, its only ornament a ring of clasped hands. An old symbol of shared hardship, from a faith long since folded into quieter household customs like Hausvette's hearth-offerings."

/obj/item/clothing/neck/roguetown/psicross/malum
	name = "ashen amulet"
	desc = "A blackened amulet, warm to the touch despite its age. 'From the ashes, creation' reads the pitted inscription — a scorched-earth creed that these days sounds more like Ignatius's fire than any god still prayed to by name."

/obj/item/clothing/neck/roguetown/psicross/necra
	name = "gravebound amulet"
	desc = "A somber amulet shaped like a closing eye. Its old creed — that death's certainty should be a reminder to live — has outlived whatever god it was first sworn to; these days it's Morwenna's ledgers that keep the dead's accounts."

/obj/item/clothing/neck/roguetown/psicross/noc
	name = "scholar's amulet"
	desc = "A tarnished amulet stamped with an open book. Once worn by seekers of some forgotten god of knowledge — a creed with no obvious heir in the current pantheon, though old Verita's truth-oaths carry a whisper of its spirit."

/obj/item/clothing/neck/roguetown/psicross/pestra
	name = "plaguebearer's amulet"
	desc = "A sickly-colored amulet, its surface pitted like old scars. 'The healthy wear a crown only the sick can see,' reads the faded inscription — a grim little creed from a god whose name has fallen out of every prayerbook still in print."

/obj/item/clothing/neck/roguetown/psicross/ravox
	name = "warbound amulet"
	desc = "A battered amulet, dented as if it took the blow meant for its wearer. Whatever war-god it once swore fealty to has no seat among the current pantheon — soldiers who find these tend to wear them anyway, for luck."

// /psicross/inhumen and /inhumen/ancient are separate old-path leaves from
// the same "inverted psycross" heretical Zizo lore this repo already keeps
// under /psicross/aurelian (see HERESYDESC_ZIZO_ICON in
// code/__DEFINES/highlight_examine_defines.dm — the Zizo/zcross terminology
// itself was NOT renamed in this repo's pantheon rewrite, only the "regular"
// gods were). Ported verbatim from Ratwood-2.0's neck.dm, using the same
// zcross_iron/zcross_a icon_states already present in this repo's neck.dmi.
/obj/item/clothing/neck/roguetown/psicross/inhumen
	name = "inverted psycross"
	desc = "A symbol of ambition from an era that had reason to believe in it."
	icon_state = "zcross_iron"

/obj/item/clothing/neck/roguetown/psicross/inhumen/ancient
	name = "ancient zcross"
	desc = "'Ambition. Destiny. Ascension. A mandate, commanded by God, to be fulfilled by Man. She called us forth from the edge of reality - and with Her dying breath, rasped out the final truth; the fire is gone, and the world will soon follow.'"
	icon_state = "zcross_a"
	color = "#bb9696"
