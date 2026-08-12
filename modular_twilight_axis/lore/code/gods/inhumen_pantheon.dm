//Graggarite shrine
/datum/crafting_recipe/roguetown/structure/zizo_shrine/graggar
	name = "Shrine of Blood"
	always_availible = FALSE	//Has unique assign for certain roles.

/obj/structure/fluff/psycross/matthios
	name = "cross of scales"
	desc = "An unholy stone cross bearing the likeness of scales, perfectly balanced in their equality."

/obj/structure/fluff/psycross/matthios/decorated
	name = "ornate cross"
	desc = "Golden scales dangle from rags and balance the scales. A monument to equality."

/datum/crafting_recipe/roguetown/structure/matthios_cross_stone
	name = "stone scales cross"

/datum/crafting_recipe/roguetown/structure/matthios_cross_meat
	name = "ornate scales cross"

/datum/faith/inhumen
	preference_accessible = FALSE
	name = "Ascendents"
	translated_name = "The Ascended"
	desc = "The <b>Holy Ecclesiarchy</b>, also known among the followers of the Ten as the <b>Despised Pantheon</b> — a conglomeration of three religious currents centered around the ideologies of those called <b>the Ascended</b>. Once mortal, the Ascended seized divine powers by stealing shards of the fallen <b>Allfather</b> in the chaos of the <b>War in the Heavens</b>.\n\
		The ideologies of the Despised are diverse and contradictory, and though they were comrades in mortal life, the followers of the Three may act together or against one another — they are united only by their hatred for the world order maintained by the Ten."
	worshippers = "Those rejected by the Church of the Ten, radicals, nonconformists."
	godhead = /datum/patron/inhumen/baotha

/datum/patron/inhumen
	preference_accessible = FALSE
	profane_words = list(
		"damn", "damn", "damn", "damn", "damn",
		"bastard", "bastard", "bastard", "bastard", "bastard",
		"crud", "crud", "crud", "crud", "crud",
		"whore", "whore", "whore", "whore", "whore", "whore",
		"cunt", "cunt", "cunt", "cunt", "cunt", "cunt",
		"ass", "ass", "ass", "ass", "ass",
		"bitch", "bitch", "bitch", "bitch", "bitch", "bitch",
		"moron", "moron", "moron", "moron", "moron", "moron",
		"faggot", "faggot", "faggot", "faggot", "faggot",
		"slut", "slut", "slut", "slut", "slut", "slut",
		"douche", "douche", "douche", "douche", "douche", "douche",
		"shithead", "shithead", "shithead", "shithead", "shithead", "shithead",
		"asshole", "asshole", "asshole", "asshole", "asshole", "asshole",
		"cocksucker", "cocksucker", "cocksucker", "cocksucker", "cocksucker", "cocksucker",
		"harlot", "harlot", "harlot", "harlot", "harlot", "harlot",
		"bitch", "bitch", "bitch", "bitch", "bitch", "bitch",
		"fuck", "fucked", "fuck", "fuck", "fucking", "fuck",
		"bellend", "bellend", "bellend", "bellend", "bellend", "bellend",
		"turd", "turd", "turd", "turd", "turd", "turd"
	)

/datum/patron/inhumen/zizo
	name = "Zizo"
	translated_name = "Zizo"
	rusgodnames = list(
		"Zizo", "Zizo", "Zizo", "Zizo", "Zizo", "Zizo",
		"Bearer of Salvation", "Bearer of Salvation", "Bearer of Salvation", "Bearer of Salvation",
		"Bearer of Salvation", "Bearer of Salvation",
		"Lady of Darkness", "Lady of Darkness", "Lady of Darkness", "Lady of Darkness",
		"Lady of Darkness", "Lady of Darkness",
		"Maiden of Night", "Maiden of Night", "Maiden of Night", "Maiden of Night",
		"Maiden of Night", "Maiden of Night",
		"Dame of Progress", "Dame of Progress", "Dame of Progress", "Dame of Progress",
		"Dame of Progress", "Dame of Progress",
		"Spider Lady", "Spider Lady", "Spider Lady", "Spider Lady",
		"Spider Lady", "Spider Lady",
		"The Weaver", "The Weaver", "The Weaver", "The Weaver",
		"The Weaver", "The Weaver",
		"The Spinster", "The Spinster", "The Spinster", "The Spinster",
		"The Spinster", "The Spinster"
)
	domain = "Immortality, progress, blood, darkness, forbidden knowledge, ambition."
	desc = "Goddess of unlife, retribution, metamorphosis, and darkness. The slayer of Psydon, the Arch-Enemy of the Pantheon of the Ten, despised by all save her followers — Zizo herself does not see mortals as the object of her hatred. This is perfectly demonstrated by her chief commandment, which often sounds in the prayers of her cultists: \"The last enemy to be destroyed is death.\""
	associated_faith = /datum/faith/cult_of_salvation
	worshippers = "Drow loyalists, necromancers, sorcerers, researchers and practitioners of the dark aspects of magic, some high vampire clans, the undead."
	confess_lines = list(
		"PRAISE ZIZO!",
		"LONG LIVE ZIZO!",
		"ZIZO WILL SAVE US FROM SUFFERING!",
	)

/datum/patron/inhumen/zizo/post_equip(mob/living/pious)
	. = ..()
	if(ishuman(pious))
		var/mob/living/carbon/human/human = pious
		if(human.mind)
			human.mind.special_items["Lexicon of Her Truth"] = /obj/item/book/rogue/bibble/zizo
			human.mind.special_items["Ritual's guide book"] = /obj/item/recipe_book/zizo

/datum/patron/inhumen/graggar
	name = "Graggar"
	translated_name = "Graggar"
	rusgodnames = list(
		"Graggar", "Graggar", "Graggar", "Graggar", "Graggar", "Graggar",
		"God of Blood", "God of Blood", "God of Blood", "God of Blood",
		"God of Blood", "God of Blood",
		"The Beast", "The Beast", "The Beast", "The Beast", "The Beast", "The Beast",
		"Black Sun", "Black Sun", "Black Sun", "Black Sun",
		"Black Sun", "Black Sun",
		"Cursed Star", "Cursed Star", "Cursed Star", "Cursed Star",
		"Cursed Star", "Cursed Star",
		"Black Wheel", "Black Wheel", "Black Wheel", "Black Wheel",
		"Black Wheel", "Black Wheel"
	)

	domain = "Power, strength, supremacy, conquest."
	desc = "God of strength and the power that comes with it. While other deities condemn their flock to a miserable existence in a world where power comes through their blessing and by right of birth, Graggar proclaims that anyone strong enough to take what they desire may rule. \"The weak shall inherit only dirt,\" he warns, reminding of the fate of those who do not strive to become stronger."
	undead_hater = TRUE
	worshippers = "Tribal peoples, madmen, maniacs, the cruel."
	miracles = list(/datum/action/cooldown/spell/touch/orison					        = CLERIC_ORI,
					/datum/action/cooldown/spell/graggar/rush							= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/heavy_stomp 		       			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_call 		       		= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/graggar_regenerate 		       	= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/heal 				        	= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
					/datum/action/cooldown/spell/graggar/hamstring						= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/graggar_net					= CLERIC_T2,
					/datum/action/cooldown/spell/graggar/graggar_battlecry		 		= CLERIC_T2,
					/datum/action/cooldown/spell/graggar/exsanguinate					= CLERIC_T3,
					/datum/action/cooldown/spell/graggar/avatar							= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/graggar				= CLERIC_T4,
	)
	confess_lines = list(
		"GRAGGAR - THE BEAST I WORSHIP!",
		"THROUGH SUPREMACY - TO DIVINITY!",
		"THE BLACK SUN DEMANDS BLOOD!",
	)

/datum/patron/inhumen/matthios
	name = "Matthios"
	translated_name = "Matthios"
	rusgodnames = list(
		"Matthios", "Matthios", "Matthios", "Matthios", "Matthios", "Matthios",
		"The Free", "The Free", "The Free", "The Free",
		"The Free", "The Free",
		"The Chain-Breaker", "The Chain-Breaker", "The Chain-Breaker",
		"The Chain-Breaker", "The Chain-Breaker", "The Chain-Breaker",
		"Father of Freedom", "Father of Freedom", "Father of Freedom", "Father of Freedom",
		"Father of Freedom", "Father of Freedom",
		"Father", "Father", "Father", "Father", "Father", "Father",
		"Papa", "Papa", "Papa", "Papa", "Papa", "Papa",
		"Lord of Nothing", "Lord of Nothing", "Lord of Nothing",
		"Lord of Nothing", "Lord of Nothing", "Lord of Nothing",
		"The Guide", "The Guide", "The Guide", "The Guide", "The Guide", "The Guide",
		"The Torch", "The Torch", "The Torch", "The Torch", "The Torch", "The Torch",
		"Bearer of Light", "Bearer of Light", "Bearer of Light", "Bearer of Light",
		"Bearer of Light", "Bearer of Light",
		"Breaker of Chains", "Breaker of Chains", "Breaker of Chains",
		"Breaker of Chains", "Breaker of Chains", "Breaker of Chains"
	)

	domain = "Anarchy, freedom, revolution, equality and brotherhood."
	desc = "God of absolute freedom, anarchy, and rebellion. \"Through discord to prosperity,\" promises his chief commandment, and his followers will do anything to bring it to reality, destroying the world order as we know it."
	undead_hater = TRUE
	worshippers = "Bandits, mercenaries, revolutionaries, freedom-loving folk."
	miracles = list(/datum/action/cooldown/spell/touch/orison									        = CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/twilight_shacklebreaker							= CLERIC_T0,
					/datum/action/cooldown/spell/matthios/freemans_tools								= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/twilight_weightofchains						= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/twilight_transact								= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/twilight_equalize								= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/heal 								        	= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle									= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/twilight_churnwealthy							= CLERIC_T2,
					/obj/effect/proc_holder/spell/self/twilight_amongus									= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/projectile/twilight_crownfortheking			= CLERIC_T2,
					/datum/action/cooldown/spell/matthios/barter										= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/twilight_commieflag							= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/twilight_matthios					= CLERIC_T3,
					/obj/effect/proc_holder/spell/self/wildshape_twilight_wingsoffreedom				= CLERIC_T4,
	)
	confess_lines = list(
		"ALL TYRANTS SHALL DIE ALONE!",
		"THE PATH TO PROSPERITY LIES THROUGH DISCORD!",
		"WE SHALL LEVEL CHURCHES AND PRISONS TO THE GROUND!",
	)

/datum/objective/hoard_mammons/update_explanation_text()
	explanation_text = "Accumulate at least [target_mammons] mammons in your possession to be used for Freedom's unstoppable march."

/datum/patron/inhumen/baotha
	name = "Baotha"
	translated_name = "Baotha"
	rusgodnames = list(
		"Baotha", "Baotha", "Baotha", "Baotha", "Baotha", "Baotha",
		"The Reveler", "The Reveler", "The Reveler", "The Reveler",
		"The Reveler", "The Reveler",
		"Bestower of Pleasure", "Bestower of Pleasure", "Bestower of Pleasure",
		"Bestower of Pleasure", "Bestower of Pleasure", "Bestower of Pleasure",
		"The Yearning", "The Yearning", "The Yearning", "The Yearning",
		"The Yearning", "The Yearning",
		"The Comforter", "The Comforter", "The Comforter", "The Comforter",
		"The Comforter", "The Comforter"
	)

	domain = "Hedonism, worldly pleasures, individualism."
	desc = "Baotha is the goddess of hedonism, worldly pleasures, and passions. \"Live, love, laugh!\" she said, gazing at the bustle around her and the efforts of those striving to move the world somewhere."
	worshippers = "Spoiled rich folk, marginals, escapists."
	undead_hater = TRUE
	miracles = list(/datum/action/cooldown/spell/touch/orison					        = CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/TAbaothavice					= CLERIC_T0,
					//obj/effect/proc_holder/spell/self/TAbless_drink					= CLERIC_T0,
					/obj/effect/proc_holder/spell/targeted/touch/TAloversruin			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/TAbaothablessings				= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/TAinsufflation					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/heal 						  	= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/griefflower					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/TAblowingdust		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TAlasthigh					= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TAjoyride						= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/TApainkiller					= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/lux_steal                     = CLERIC_T3,
					/obj/effect/proc_holder/spell/self/mirage                           = CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/baotha				= CLERIC_T4,
	)
	confess_lines = list(
		"BAOTHA DEMANDS PLEASURE!",
		"LIVE, LAUGH, LOVE!",
		"BAOTHA - MY JOY!",
	)

/////////////////////////////////
// Does God Hear Your Prayer ? //
/////////////////////////////////

/datum/patron/proc/can_pray_inhumen(mob/living/follower)
	SHOULD_CALL_PARENT(TRUE)
	// Allows death-bed prayers
	if(follower.has_status_effect(STATUS_EFFECT_UNCONSCIOUS))
		if(follower.has_status_effect(STATUS_EFFECT_SLEEPING))
			to_chat(follower, span_danger("I mustn't be sleeping to pray!"))
			return FALSE	//Stops praying just by sleeping.
	. = TRUE

// Graggar - When bleeding, near blood on ground, zchurch, bad-cross, or ritual chalk
/datum/patron/inhumen/graggar/can_pray_inhumen(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
	for(var/obj/structure/fluff/psycross/graggar/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("This altar has been corrupted by the Ten! It blocks my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if actively bleeding.
	if(follower.bleed_rate > 0)
		return TRUE
	// Allows prayer near blood.
	for(var/obj/effect/decal/cleanable/blood in view(3, get_turf(follower)))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/graggar in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Graggar to hear my prayers I must either be in the church of the abandoned, near an altar dedicated to Him, near fresh blood or draw blood of my own!"))
	return FALSE

// Matthios - Basically any way you'd like really, so long as there are comrades with you
/datum/patron/inhumen/matthios/can_pray_inhumen(mob/living/follower)
	. = ..()
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
	for(var/obj/structure/fluff/psycross/matthios/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("This altar has been corrupted by the Ten! It blocks my prayers!"))
			return FALSE
		return TRUE
	for(var/mob/living/carbon/human/comrade in view(4, get_turf(follower)))
		if(istype(comrade.patron, /datum/patron/inhumen/matthios) && comrade != follower)
			return TRUE
	for(var/obj/structure/ritualcircle/matthios in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("Matthios will hear any prayer I offer, so long as I stand near one of my comrades or one of His altars!"))
	return FALSE

// Baotha
/datum/patron/inhumen/baotha/can_pray_inhumen(mob/living/follower)
	. = ..()
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
	for(var/obj/structure/fluff/psycross/baotha/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("This altar has been corrupted by the Ten! It blocks my prayers!"))
			return FALSE
		return TRUE
	// Allows prayers in the bath house - whore.
	if(istype(get_area(follower), /area/rogue/indoors/town/bath))
		return TRUE
	// Allows prayers if actively high on drugs.
	if(follower.has_status_effect(/datum/status_effect/buff/ozium) || follower.has_status_effect(/datum/status_effect/buff/moondust) || follower.has_status_effect(/datum/status_effect/buff/moondust_purest) || follower.has_status_effect(/datum/status_effect/buff/druqks) || follower.has_status_effect(/datum/status_effect/buff/starsugar))
		return TRUE
	// Allows prayers if the user is drunk.
	if(follower.has_status_effect(/datum/status_effect/buff/drunk))
		return TRUE
	// Allows prayers if the user is generally happy.
	if(follower.has_status_effect(/datum/status_effect/mood/vgood))
		return TRUE
	// Allows prayers during sex
	var/list/arousal_data = list()
	SEND_SIGNAL(follower, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] >= 10)
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/baotha in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Baotha to hear my prayers I must either be in the church of the abandoned, within the town's bathhouse, or actively enjoying myself, be that through drugs, sex, or whatever it is that gets my blood pumpin'!"))
	return FALSE
