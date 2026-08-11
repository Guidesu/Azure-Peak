/// Alchemy cauldron recipes for weapon modification oils and coatings.
/// These produce weapon mod items via the cauldron.

/datum/alch_cauldron_recipe/blade_oil_fire
	name = "Searing Blade Oil"
	smells_like = "burning iron"
	skill_required = SKILL_LEVEL_APPRENTICE
	output_items = list(/obj/item/weapon_mod/blade_oil_fire = 100)

/datum/alch_cauldron_recipe/blade_oil_poison
	name = "Venom Blade Oil"
	smells_like = "bitter herbs"
	skill_required = SKILL_LEVEL_JOURNEYMAN
	output_items = list(/obj/item/weapon_mod/blade_oil_poison = 100)

/datum/alch_cauldron_recipe/blade_oil_holy
	name = "Sanctified Blade Oil"
	smells_like = "incense"
	skill_required = SKILL_LEVEL_JOURNEYMAN
	output_items = list(/obj/item/weapon_mod/blade_oil_holy = 100)

/datum/alch_cauldron_recipe/blade_coating_rust
	name = "Rust Coating"
	smells_like = "corroded metal"
	skill_required = SKILL_LEVEL_APPRENTICE
	output_items = list(/obj/item/weapon_mod/blade_coating_rust = 100)

/datum/alch_cauldron_recipe/coating_holy
	name = "Sanctified Coating"
	smells_like = "holy water"
	skill_required = SKILL_LEVEL_JOURNEYMAN
	output_items = list(/obj/item/weapon_mod/coating_holy = 100)
