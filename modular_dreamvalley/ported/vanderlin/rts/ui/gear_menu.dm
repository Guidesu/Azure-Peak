// Ported from Vanderlin (OpenKeep): code/datums/rts/ui/gear_menu.dm
//
// PHASE 5 (deferred from Phase 4 - see ui/building_menu.dm's Phase 4 header
// comment: gear_menu.dm/inventory_menu.dm depend on the gear system, which
// didn't exist until this phase). Screen-object panel a controller opens by
// right-clicking a building_node (building_node/building_nodes.dm's
// handle_right_click(), un-trimmed below to call this) to browse/retrieve
// gear stored in that node.
//
// ADAPTATION: upstream's get_node_gear_list() iterates
// `for(var/datum/worker_gear/gear in node.stored_gear)` - treating
// stored_gear as a flat list of /datum/worker_gear instances. This port's
// actual /obj/effect/building_node.stored_gear (building_node/building_nodes.dm,
// Phase 2/3) is a gear_key -> list("item"=item,"gear"=gear) map instead (see
// that file's store_gear()/get_all_stored_gear()) - get_node_gear_list()
// below is rewritten to iterate get_all_stored_gear() and key its return
// list by gear_key (not a fabricated "slot_name: item_name" display string)
// so gear_slot.handle_left_click() can look the exact stored entry back up
// by key when creating the retrieve_gear work order, matching
// work_orders/orders/retrieve_gear.dm's key-based New() (see that file's
// header comment for why - a display-string key can collide/go stale in a
// way a real gear_key can't).
//
// ADAPTATION: icons/hud/rts_ability_hud.dmi's icon_state "inventory_ui" and
// icons/hud/storage.dmi's "background" - both referenced unmodified here,
// matching ui/building_menu.dm's Phase 4 precedent (these .dmi files/states
// already exist in this repo, not copied specially for this port).
/atom/movable/screen/gear_menu_backdrop
	icon = 'modular_dreamvalley/icons/rts/rts_ability_hud.dmi'
	icon_state = "inventory_ui"
	screen_loc = "EAST:-16,SOUTH:96"
	var/list/gear_slots = list()
	var/atom/movable/screen/close_gear_menu/close
	var/obj/effect/building_node/linked_node
	var/max_x = 3
	var/max_y = 6
	var/current_x = 0
	var/current_y = 0

/atom/movable/screen/gear_menu_backdrop/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	close = new(null, hud_owner)

/atom/movable/screen/gear_menu_backdrop/proc/open_ui(mob/camera/strategy_controller/opener, obj/effect/building_node/node)
	close_uis(opener)
	linked_node = node

	var/list/available_gear = get_node_gear_list(node)

	for(var/gear_key in available_gear)
		var/atom/movable/screen/gear_slot/new_slot = new
		new_slot.gear_key = gear_key
		new_slot.linked_node = node
		new_slot.parent_menu = src

		var/list/gear_data = available_gear[gear_key]
		new_slot.set_gear_data(gear_data)

		new_slot.screen_loc = "EAST:[-(16 + (current_x*32))],SOUTH:[96 + (current_y*32)]"

		current_x++
		if(current_x >= max_x)
			current_x = 0
			current_y++

		opener.client.screen += new_slot
		gear_slots += new_slot

	opener.client.screen += src
	opener.client.screen += close

/atom/movable/screen/gear_menu_backdrop/proc/close_uis(mob/camera/strategy_controller/closer)
	for(var/atom/movable/screen/gear_slot/slot as anything in gear_slots)
		gear_slots -= slot
		closer.client.screen -= slot
		qdel(slot)
	closer.client.screen -= src
	closer.client.screen -= close
	current_x = 0
	current_y = 0
	linked_node = null

// See this file's header ADAPTATION comment: keyed on the node's real
// gear_key (building_node/building_nodes.dm's stored_gear map), not a
// synthesized display string.
/atom/movable/screen/gear_menu_backdrop/proc/get_node_gear_list(obj/effect/building_node/node)
	return node.get_all_stored_gear()

/atom/movable/screen/gear_menu_backdrop/proc/get_slot_display_name_static(slot_type)
	switch(slot_type)
		if(WORKER_SLOT_HEAD)
			return "Head Gear"
		if(WORKER_SLOT_SHIRT)
			return "Shirts"
		if(WORKER_SLOT_PANTS)
			return "Pants"
		if(WORKER_SLOT_SHOES)
			return "Footwear"
		if(WORKER_SLOT_HANDS)
			return "Tools"
		else
			return "Unknown"

/atom/movable/screen/close_gear_menu
	icon = 'modular_dreamvalley/icons/rts/rts_ability_hud.dmi'
	icon_state = "inventory_close"
	screen_loc = "EAST:-16,SOUTH:96"

/atom/movable/screen/close_gear_menu/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/clicker = usr
	if(!istype(clicker))
		return
	clicker.close_gear_ui()

/atom/movable/screen/gear_slot
	icon = 'icons/hud/storage.dmi'
	icon_state = "background"
	screen_loc = "EAST:-16,SOUTH:96"
	var/gear_key
	var/obj/item/stored_item
	var/datum/worker_gear/stored_gear_datum
	var/obj/effect/building_node/linked_node
	var/atom/movable/screen/gear_menu_backdrop/parent_menu

// ADAPTATION: takes the full gear_data list("item"=item,"gear"=gear) this
// port's get_all_stored_gear()/get_stored_gear() actually return, rather
// than upstream's bare /obj/item argument - see this file's header comment.
/atom/movable/screen/gear_slot/proc/set_gear_data(list/gear_data)
	cut_overlays()

	if(!gear_data)
		stored_item = null
		stored_gear_datum = null
		name = "(Empty)"
		return

	stored_item = gear_data["item"]
	stored_gear_datum = gear_data["gear"]

	var/slot_name = parent_menu.get_slot_display_name_static(stored_gear_datum?.slot)
	if(stored_item)
		var/mutable_appearance/MA = mutable_appearance(stored_item.icon, stored_item.icon_state, layer + 0.1, plane)
		add_overlay(MA)
		name = "[slot_name]: [stored_item.name]"
	else
		name = "[slot_name]: Empty"

/atom/movable/screen/gear_slot/Click(location, control, params)
	. = ..()
	var/mob/camera/strategy_controller/clicker = usr
	if(!istype(clicker))
		return

	var/list/modifiers = params2list(params)
	if(modifiers["left"])
		handle_left_click(clicker)
	else if(modifiers["right"])
		handle_right_click(clicker)

/atom/movable/screen/gear_slot/proc/handle_left_click(mob/camera/strategy_controller/user)
	if(!stored_item)
		to_chat(user, span_warning("No item stored in this slot."))
		return

	var/datum/worker_mind/selected_worker = user.displayed_mob_ui?.worker_mind
	if(!selected_worker)
		to_chat(user, span_warning("No worker selected. Select a worker first."))
		return

	create_retrieve_gear_task(user, selected_worker)

/atom/movable/screen/gear_slot/proc/handle_right_click(mob/camera/strategy_controller/user)
	if(!stored_item)
		to_chat(user, span_warning("No item stored in this slot."))
		return

	display_stored_item_stats(user)

/atom/movable/screen/gear_slot/proc/create_retrieve_gear_task(mob/camera/strategy_controller/user, datum/worker_mind/worker_mind)
	if(!worker_mind || !stored_item || !linked_node || !gear_key)
		return

	worker_mind.set_current_task(/datum/work_order/retrieve_gear, linked_node, gear_key)

	to_chat(user, span_notice("[worker_mind.worker_name] assigned to retrieve [stored_item.name] from [linked_node.name]."))

/atom/movable/screen/gear_slot/proc/display_stored_item_stats(mob/camera/strategy_controller/user)
	var/stats_text = "<b>[stored_item.name] (Stored)</b><br>"
	stats_text += "<b>Location:</b> [linked_node.name]<br>"

	if(stored_item.desc)
		stats_text += "<b>Description:</b><br>"
		stats_text += "[stored_item.desc]<br><br>"

	stats_text += "<i>Left-click to assign retrieval task<br>"
	stats_text += "Right-click to view details</i>"

	var/datum/browser/popup = new(user, "stored_gear_stats", "[stored_item.name] Info", 350, 250)
	popup.set_content(stats_text)
	popup.open()
