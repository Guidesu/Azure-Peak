// The Old Kin - everyday folk religion: hearth-shrines, wood-shrines, and the barely-a-god you leave an offering for
// at a crossroads. Looked down upon by the high orthodoxy of the Concordat and Tribunal, but preference_accessible
// stays TRUE on the faith itself - this is common belief, not a fringe cult, unlike the old Inhumen/Ascendants.
//
// Mechanically this plays the role the old /datum/patron/inhumen abstract parent did: its own profane_words list
// (permitting its own figures' names, which the Concordat/Tribunal master list now treats as profanity) and the
// crafting_recipes var carried over from Graggar/Matthios/Baotha's holy-symbol crafting recipes.
/datum/patron/oldkin
	name = null
	associated_faith = /datum/faith/oldkin
	undead_hater = FALSE
	var/list/crafting_recipes = list() //Allows construction of unique crosses/shrines.
	profane_words = list("cock","dick","fuck","shit","pussy","cuck","cunt","asshole","pintle") //Old Kin folk don't blaspheme their own kin's names.

/datum/patron/oldkin/post_equip(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/human = pious
		if(human.mind && length(crafting_recipes))
			for(var/recipe_path in crafting_recipes)
				human.mind.teach_crafting_recipe(recipe_path)
