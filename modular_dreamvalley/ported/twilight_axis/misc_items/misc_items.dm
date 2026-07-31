// Ported from Twilight-Axis. Sources:
//   - modular_twilight_axis/code/modules/clothing/rogueclothes/rings/event_rings.dm (event_ring)
//   - modular_twilight_axis/code/game/objects/items/rogueitems/keys.dm (roguekey/watcharmory)
//
// Adaptation notes:
// - event_ring is a fully generic, self-contained VV-editable admin/event item (no TA-specific
//   lore, gods, or factions) - ported verbatim. Icon_state "g_newring_emerald" already exists in
//   this repo's own native icons/roguetown/clothing/rings.dmi (base /obj/item/clothing/ring icon
//   file), confirmed via grep - no new icon needed.
// - watcharmory is a plain lockid-keyed key with no TA-specific dependencies. icon_state "spikekey"
//   already exists in this repo's base roguekey icon set (shared by other native roguekey/* types),
//   confirmed no new icon file needed. Not added to any keyring list - task scope is the key item
//   itself only, not the sheriff/watchman keyring wiring from the source's keyrings.dm.

//====================================================================
// Event ring - admin/event customizable ring (stat_mods/traits editable via VV)
//====================================================================

/obj/item/clothing/ring/event_ring
	name = "event ring"
	desc = "A customizable ring for events; editable via VV (stat_mods, traits)."
	icon_state = "g_newring_emerald"
	sellprice = 0
	// Example defaults: applies +1 to all primary stats; change the second value to adjust
	var/list/stat_mods = list(
		list(STATKEY_STR, 1),
		list(STATKEY_WIL, 1),
		list(STATKEY_CON, 1),
		list(STATKEY_PER, 1),
		list(STATKEY_INT, 1),
		list(STATKEY_LCK, 1),
		list(STATKEY_SPD, 1)
	)
	// Example default traits: admins can edit/remove these via VV
	var/list/traits = list(TRAIT_NOBLE)
	// Customizable message shown when ring is equipped; editable via VV
	var/equip_message = "You feel the ring's power settle upon you."
	var/active_item = FALSE

/obj/item/clothing/ring/event_ring/equipped(mob/living/user, slot)
	. = ..()
	if(active_item)
		return
	else if(slot == SLOT_RING)
		active_item = TRUE
		if(stat_mods && stat_mods.len)
			for(var/mod in stat_mods)
				if(islist(mod) && length(mod) >= 2)
					user.change_stat(mod[1], mod[2])
		if(traits && traits.len)
			for(var/t in traits)
				ADD_TRAIT(user, t, TRAIT_GENERIC)
		if(equip_message)
			to_chat(user, span_green(equip_message))
	return

/obj/item/clothing/ring/event_ring/dropped(mob/living/user)
	..()
	if(active_item)
		if(stat_mods && stat_mods.len)
			for(var/mod in stat_mods)
				if(islist(mod) && length(mod) >= 2)
					user.change_stat(mod[1], -mod[2])
		if(traits && traits.len)
			for(var/t in traits)
				REMOVE_TRAIT(user, t, TRAIT_GENERIC)
		active_item = FALSE
	return

/obj/item/clothing/ring/event_ring/proc/clear_stat_mods()
	stat_mods = list()

/obj/item/clothing/ring/event_ring/proc/clear_traits()
	traits = list()

//====================================================================
// Town Watch armory key
//====================================================================

/obj/item/roguekey/watcharmory
	name = "Town Watch armory key"
	desc = "This key opens the Town Watch armory."
	icon_state = "spikekey"
	lockid = "watcharmory"
