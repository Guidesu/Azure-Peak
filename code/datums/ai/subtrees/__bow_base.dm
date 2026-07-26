/datum/ai_planning_subtree/archer_base/proc/validate_archer_equipment(datum/ai_controller/controller)
	var/mob/living/carbon/human/living_pawn = controller.pawn
	if(world.time < controller.blackboard[BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY])
		var/obj/item/gun/ballistic/revolver/grenadelauncher/cached_bow = controller.blackboard[BB_ARCHER_NPC_BOW]
		var/obj/item/quiver/cached_quiver = controller.blackboard[BB_ARCHER_NPC_QUIVER]
		if(QDELETED(cached_bow) || QDELETED(cached_quiver) || cached_bow.loc != living_pawn || cached_quiver.loc != living_pawn)
			_clear_equipment_cache(controller)
			return FALSE
		return TRUE

	_clear_equipment_cache(controller)

	var/datum/component/ai_inventory_manager/inv = controller.get_inventory()

	// Note: bow variable typed as /grenadelauncher (base) - matches bows, crossbows, and slings
	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow = _find_archer_bow(living_pawn)
	if(!bow)
		bow = inv?.get_item(AI_ITEM_GUN)
	if(!bow)
		return FALSE

	var/obj/item/quiver/quiver = null
	for(var/obj/item/quiver/worn in living_pawn.get_equipped_items())
		quiver = worn
		break
	if(!quiver)
		quiver = inv?.get_item(AI_ITEM_QUIVER)
	if(!quiver)
		return FALSE

	controller.set_blackboard_key(BB_ARCHER_NPC_BOW, bow)
	controller.set_blackboard_key(BB_ARCHER_NPC_QUIVER, quiver)
	controller.set_blackboard_key(BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY, world.time + ARCHER_NPC_EQUIPMENT_CACHE_TIME)
	return TRUE

/datum/ai_planning_subtree/archer_base/proc/_clear_equipment_cache(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ARCHER_NPC_BOW)
	controller.clear_blackboard_key(BB_ARCHER_NPC_QUIVER)
	controller.clear_blackboard_key(BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY)
