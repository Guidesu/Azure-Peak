// Clothing sanity protection — adapted from CEV-Eris
// Wearing certain clothing provides sanity protection
// Holy symbols, hoods, and comfortable clothing reduce sanity drain

/// Get total sanity protection from worn items
/datum/sanity/proc/get_clothing_protection()
	if(!owner || !ishuman(owner))
		return 0
	var/mob/living/carbon/human/H = owner
	var/protection = 0
	// Head slot — hoods and hats provide comfort
	if(H.head)
		protection += get_item_sanity_protection(H.head)
	// Armor slot — heavy armor provides security feeling
	if(H.wear_armor)
		protection += get_item_sanity_protection(H.wear_armor)
	// Shirt slot — comfortable clothing
	if(H.wear_shirt)
		protection += get_item_sanity_protection(H.wear_shirt)
	// Neck slot — holy symbols and amulets
	if(H.wear_neck)
		protection += get_item_sanity_protection(H.wear_neck)
	return protection

/// Get sanity protection value from a specific item
/datum/sanity/proc/get_item_sanity_protection(obj/item/I)
	if(!I)
		return 0
	// Holy items provide strong protection
	if(istype(I, /obj/item/clothing/neck/roguetown/psicross))
		return 2.0
	if(istype(I, /obj/item/clothing/neck/roguetown))
		return 0.5
	// Hoods provide mild protection (feeling hidden)
	if(istype(I, /obj/item/clothing/head/roguetown))
		return 0.3
	// Heavy armor provides security feeling
	if(istype(I, /obj/item/clothing/suit/roguetown/armor))
		return 0.5
	// Comfortable shirts
	if(istype(I, /obj/item/clothing/suit/roguetown/shirt))
		return 0.2
	return 0

/// Apply clothing protection to sanity damage
/datum/sanity/proc/apply_clothing_protection(damage)
	var/protection = get_clothing_protection()
	if(protection > 0)
		damage = max(0, damage - protection)
	return damage
