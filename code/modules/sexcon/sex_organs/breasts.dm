/obj/item/organ/breasts
	name = "breasts"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BREASTS
	organ_dna_type = /datum/organ_dna/breasts
	accessory_type = /datum/sprite_accessory/breasts/pair
	var/breast_size = DEFAULT_BREASTS_SIZE
	var/lactating = FALSE
	var/milk_stored = 0
	var/milk_max = 75

/obj/item/organ/breasts/get_cache_key()
	return "[..()]-[breast_size]"

/obj/item/organ/breasts/New()
	..()
	milk_max = max(75, breast_size * 100)

/obj/item/organ/breasts/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()

/obj/item/organ/breasts/Remove(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()

/// Updates breast size and immediately refreshes the owner's bodypart icons.
/obj/item/organ/breasts/proc/set_breast_size(new_size)
	breast_size = new_size
	milk_max = max(75, breast_size * 100)
	if(owner)
		owner.update_body_parts(TRUE)
