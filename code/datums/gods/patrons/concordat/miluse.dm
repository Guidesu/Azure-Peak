// Merge of the old Noc (moon, night, knowledge, arcyne) and Eora (love, life, beauty) - the moon and the tide together
// with the heart and the hearth.
/datum/patron/concordat/miluse
	name = "Miluše"
	domain = "Goddess of the Moon, Witchcraft, Tides, Fertility, and the Seasons"
	desc = "The Nite-Scholar and the Mother wound into one clustered figure: Miluše turns the moon, pulls the tide, and \
	rules the slow wheel of the seasons and the womb alike. Sailors read her as the fickle fortune of open water, witches \
	as the source of moonlit lore, and lovers as the patient warmth that outlasts a season's turning. Some say her tides \
	give as freely as they take, that her witchcraft heals as often as it curses, and that her seasons are a promise \
	renewed each year. Others say the moon shows no true face, that her tides drown as readily as they carry, and that \
	her fertility is owed a price like anything else worth having."
	worshippers = "Wizards, Alchemists, Scholars, Lovers, Sailors, and Doting Grandparents"
	mob_traits = list(TRAIT_NIGHT_OWL, TRAIT_EMPATH, TRAIT_EXTEROCEPTION, TRAIT_MARRIAGE_CAPABLE)
	traits_tier = list(TRAIT_DARKVISION = CLERIC_T1, TRAIT_EORAN_CALM = CLERIC_T0, TRAIT_EORAN_SERENE = CLERIC_T2)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/datum/action/cooldown/spell/noc/nitevision					= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/eora_blessing			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/datum/action/cooldown/spell/noc/enlightenment              = CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/bless_food            = CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/bud					= CLERIC_T1,
					/datum/action/cooldown/spell/summon_bed						= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/moonscorch     		= CLERIC_T2,
					/datum/action/cooldown/spell/noc/invisibility				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/heartweave			= CLERIC_T2,
					/datum/action/cooldown/spell/noc/spellpack					= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/eoracurse				= CLERIC_T3,
					/datum/action/cooldown/spell/noc/moonlight                  = CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/pomegranate			= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/noc			= CLERIC_T4,
	)
	confess_lines = list(
		"MILUŠE SEES ALL BY MOONLIGHT!",
		"I SEEK THE MYSTERIES OF THE MOON AND THE TIDE!",
		"MILUŠE BRINGS US TOGETHER!",
		"HER BEAUTY IS EVEN IN THIS TORMENT!",
	)
	storyteller = /datum/storyteller/miluse
	titles = list(
		"Nite-Scholar",
		"Moon", // should match a bunch of variant titles like Brother/Sister Moon
		"Mother", // have seen people call her this, or variants like 'Great Mother'
	)

// In moonlight, church, cross, ritual chalk, near her sacred tree, at her shrine, offering poppies, or wearing pacifism.
/datum/patron/concordat/miluse/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer near her sacred tree
	for(var/obj/structure/eoran_pomegranate_tree in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer at her shrine
	if(istype(get_area(follower), /area/rogue/outdoors/rtfield/miluse))
		return TRUE
	// Allows prayer during nightime if outside.
	if(istype(get_area(follower), /area/rogue/outdoors) && (GLOB.tod == "night" || GLOB.tod == "dusk"))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/noc in view(1, get_turf(follower)))
		return TRUE
	// Allows worshippers to pray using flowers
	var/obj/item/held_item = follower.get_active_held_item()
	if(istype(held_item, /obj/item/reagent_containers/food/snacks/grown/rogue/poppy))
		qdel(held_item)
		return TRUE
	// Allows player to pray while wearing her blessed flower.
	if(HAS_TRAIT(follower, TRAIT_PACIFISM))
		return TRUE
	to_chat(follower, span_danger("For Miluše to hear my prayer I must either be in her blessed moonlight, within the church, near a psycross, offering poppy flowers, or wearing one of her blessed flowers atop my head.."))
	return FALSE

/datum/patron/concordat/miluse/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A shroud of soft moonlight and quiet love falls upon [target]!")
	*message_self = span_notice("I'm shrouded in gentle moonlight!")

	var/list/flower_crowns = list(
		/obj/item/flowercrown/rosa,
		/obj/item/flowercrown/salvia,
		/obj/item/flowercrown/calendula,
		/obj/item/flowercrown/matricaria,
	)

	var/bonus = 0

	if(GLOB.tod == "night")
		bonus += 1

	if(HAS_TRAIT(target, TRAIT_PACIFISM))
		bonus += 2.5

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		bonus += 1.5

	var/target_head = target.get_item_by_slot(SLOT_HEAD)
	var/user_head = user.get_item_by_slot(SLOT_HEAD)

	for(var/crown in flower_crowns)
		if(istype(target_head, crown))
			bonus += 0.75
			to_chat(user, span_good("[target.name]'s flower crown's blessing amplifies the healing!"))
		if(istype(user_head, crown))
			bonus += 0.375
			to_chat(user, span_good("My flower crown's blessing amplifies the healing!"))

	if(!bonus)
		return

	*situational_bonus = bonus
	*conditional_buff = TRUE
