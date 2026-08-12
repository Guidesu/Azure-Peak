/obj/item/organ/testicles
	name = "testicles"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TESTICLES
	organ_dna_type = /datum/organ_dna/testicles
	accessory_type = /datum/sprite_accessory/testicles/pair
	var/ball_size = DEFAULT_TESTICLES_SIZE
	var/virility = TRUE

/obj/item/organ/testicles/get_cache_key()
	return "[..()]-[ball_size]"

/// Updates ball size and immediately refreshes the owner's bodypart icons.
/obj/item/organ/testicles/proc/set_ball_size(new_size)
	ball_size = new_size
	if(owner)
		owner.update_body_parts(TRUE)

/obj/item/organ/testicles/internal
	name = "internal testicles"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none
