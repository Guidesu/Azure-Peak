// Direct successor to Zizo (progress, undeath, hubris, left-hand magicks). Re-themed per the Via Medulla origin_desc:
// "Aurelian's claim that no priesthood should stand between a soul and the divine." Mechanics carried over
// verbatim - the necromantic/undeath kit still fits a once-mortal figure who "unmade" her own limits to ascend.
/datum/patron/unveiled/aurelian
	name = "Aurelian"
	domain = "Progress, Undeath, Hubris, and Left Hand Magicks"
	desc = "A once-mortal figure who claims to be the visible edge of the Overgod itself - the closest thing to divinity a soul can \
	touch without a priest standing in the way. Aurelian's core claim is radical in its simplicity: no clergy, no Court of Six Seats, \
	no Tribunal magistrate stands between a person and the divine, and every old god's guarded domain is a lie told to keep the faithful \
	paying tithes. The gentle Plainfolk who follow this creed simply worship without hierarchy. The violent Stripping sect takes the \
	same claim further, actively unmaking the shrines of older gods to prove the point. Her critics call it exactly the hubris that \
	doomed her race the first time; her faithful call it the only honest religion left."
	worshippers = "Necromancers, Researchers, Warlocks, Free-City Heretics, and the Undead"
	mob_traits = list(TRAIT_CABAL, TRAIT_ZIZOSIGHT)
	miracles = list(/datum/action/cooldown/spell/touch/orison							= CLERIC_ORI,
					/datum/action/cooldown/spell/zizo/snuff_lights						= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 							= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/zizo/profane				= CLERIC_T1,
					/datum/action/cooldown/spell/conjure_summon/zizo/skeleton_swarm		= CLERIC_T2,
					/datum/action/cooldown/spell/zizo/bone_cataclysm					= CLERIC_T2,
					/datum/action/cooldown/spell/tame_undead/zizo						= CLERIC_T3,
					/datum/action/cooldown/spell/zizo/rituos 							= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/zizo				= CLERIC_T3,
					/datum/action/cooldown/spell/lacrima/zizo							= CLERIC_T4,
	)
	confess_lines = list(
		"NO PRIEST STANDS BETWEEN ME AND THE DIVINE!",
		"PRAISE AURELIAN!",
		"THE OLD GODS ARE UNMADE, ONE SHRINE AT A TIME!",
		"AURELIAN IS THE EDGE MADE VISIBLE!",
	)
	storyteller = /datum/storyteller/aurelian

	titles = list(
		"The Unveiled Edge",
		"Lady of Progress",
		"Lady of Secrets",
		"Arch Lych",
	)

/datum/patron/unveiled/aurelian/post_equip(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/human = pious
		var/datum/devotion/pious_devotion = human.devotion
		if(pious_devotion?.level >= CLERIC_T2)
			pious.grant_language(/datum/language/undead)

// When the sun is blotted out, near an unveiled shrine, or ritual chalk
/datum/patron/unveiled/aurelian/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the old zchurch
	if(istype(get_area(follower), /area/rogue/under/cave/inhumen))
		return TRUE
	// Allows prayer near her cross
	for(var/obj/structure/fluff/psycross/aurelian/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That consecrated cross interrupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer during the sun being blotted from the sky.
	if(hasomen(OMEN_SUNSTEAL))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/zizo in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Aurelian to hear my prayers I must either be near her unveiled shrine, atop a drawn sigil, or while the sun is blotted from the sky!"))
	return FALSE

/datum/patron/unveiled/aurelian/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus,
	is_inhumen
)
	*is_inhumen = TRUE
	*message_out = span_info("Vital energies are sapped towards [target]!")
	*message_self = span_notice("The life around me pales as I am restored!")

	var/bonus = 0

	for(var/obj/item/natural/bone/bone in oview(5, user))
		bonus += 0.5

	for(var/obj/item/natural/bundle/bone/bone in oview(5, user))
		bonus += (bone.amount * 0.5)

	if(!bonus)
		return

	*conditional_buff = TRUE
	*situational_bonus = min(bonus, 5)
