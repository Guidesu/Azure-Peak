// Ported from Vanderlin (OpenKeep): code/game/objects/items/gems.dm
// (generate_socketing_properties / get_socketing_description / get_slot_type /
// create_rune_effect_for_slot procs), adapted onto this repo's EXISTING
// /obj/item/roguegem tree (code/game/objects/items/rogueitems/gems.dm)
// instead of introducing a parallel gem item hierarchy.
//
// This file only ADDS vars/procs to /obj/item/roguegem and assigns
// effect_template on its existing colored subtypes - it does not redefine
// or duplicate anything that file already declares.
/obj/item/roguegem
	/// Quality tier, see DV_GEM_* in _defines.dm. Regular by default; can be
	/// upgraded by a gem-cutter (see /datum/gem_cut usage, not ported as a
	/// full profession minigame - cutting is intentionally left manual/admin
	/// for now, this only wires the data model).
	var/quality = DV_GEM_REGULAR
	/// The gem_effect type (or instance) this gem grants when socketed.
	/// Null means "not socketable" - most roguegem subtypes (jade, oyster,
	/// onyxa, riddleofsteel, etc.) intentionally have no combat use.
	var/datum/gem_effect/effect_template = null
	var/is_cut = FALSE

/obj/item/roguegem/proc/get_socketing_description()
	if(!effect_template)
		return null
	var/datum/gem_effect/instance = create_gem_effect()
	if(!instance)
		return null
	. = "Socketing Effects:\n[instance.get_description()]"
	qdel(instance)

/obj/item/roguegem/proc/create_gem_effect()
	if(!effect_template)
		return null
	if(ispath(effect_template))
		return new effect_template(quality)
	return effect_template

/obj/item/roguegem/proc/get_slot_type(obj/item/target)
	if(istype(target, /obj/item/clothing))
		return DV_SOCKET_SLOT_ARMOR
	if(istype(target, /obj/item/rogueweapon/shield))
		return DV_SOCKET_SLOT_SHIELD
	return DV_SOCKET_SLOT_WEAPON

/obj/item/roguegem/proc/create_rune_effect_for_slot(slot_type)
	var/datum/gem_effect/instance = create_gem_effect()
	if(!instance)
		return null
	. = instance.create_effect_for_slot(slot_type)
	qdel(instance)

/obj/item/roguegem/examine(mob/user)
	. = ..()
	var/socket_desc = get_socketing_description()
	if(socket_desc)
		. += span_notice(socket_desc)

// ----- Wiring existing colored gems to the gem effects ported in gem_effects.dm -----
/obj/item/roguegem/green
	effect_template = /datum/gem_effect/gemerald

/obj/item/roguegem/blue
	effect_template = /datum/gem_effect/blortz

/obj/item/roguegem/yellow
	effect_template = /datum/gem_effect/toper

/obj/item/roguegem/violet
	effect_template = /datum/gem_effect/saffira

/obj/item/roguegem/diamond
	effect_template = /datum/gem_effect/dorpel

/obj/item/roguegem/ruby
	effect_template = /datum/gem_effect/rubor
