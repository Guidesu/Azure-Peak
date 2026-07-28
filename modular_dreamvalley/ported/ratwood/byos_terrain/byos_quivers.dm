// Quiver/ammo-pouch variants used by byos.dmm.
// This repo's quiver.dm (code/game/objects/items/quiver.dm) already has a
// heavily reorganized, expanded quiver system (mechanized quivers, /bolt
// singular family, etc) compared to Ratwood's modular_azurepeak/quiver.dm.
// Only leaves genuinely absent from this repo's own quiver.dm are ported.

/obj/item/quiver/ancient
	name = "ancient quiver"
	desc = "A worn quiver of aged leather, still holding a handful of steel-tipped arrows from a bygone age."

/obj/item/quiver/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/steel/A = new()
		arrows += A
	update_icon()

// "quiver/bolts" (plural) is a stale/legacy type name only ever referenced by
// old map data (byos.dmm among others) — this repo (like current Ratwood)
// renamed the live type to /obj/item/quiver/bolt. Implemented as an empty
// bolt pouch so the map's placed item is a real, working quiver rather than
// a blank stub of the abstract /obj/item/quiver base.
/obj/item/quiver/bolts
	name = "bolt pouch"
	desc = "A leather canister that can be used to carry bolts."
	icon_state = "boltpouch0"
	item_state = "boltpouch"
	max_storage = 16
	allowed_ammo_type = /obj/item/ammo_casing/caseless/rogue/bolt

/obj/item/quiver/bolts/update_icon()
	if(arrows.len)
		icon_state = "boltpouch1"
	else
		icon_state = "boltpouch0"

/obj/item/quiver/javelin/ancient
	name = "ancient javelinbag"
	desc = "A weathered sleeve of stitched hide, holding a set of gilbranze-tipped javelins."

/obj/item/quiver/javelin/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 4)
		var/obj/item/ammo_casing/caseless/rogue/javelin/steel/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/sling/ancient
	name = "ancient sling pouch"
	desc = "A cracked leather pouch, still rattling with old sling bullets."

/obj/item/quiver/sling/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/sling_bullet/iron/A = new()
		arrows += A
	update_icon()
