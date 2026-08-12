/datum/faith
	var/translated_name

/datum/patron
	var/translated_name
	var/list/rusgodnames = list()

/datum/faith/divine
	name = "Divine Pantheon"
	translated_name = "Pantheon of the Ten"
	desc = "The most widespread religion in Grimoria, centered around <b>Ten</b> deities who inherited the world from the <b>Allfather</b>, slain at the hands of the <b>Arch-Enemy</b>. \n\
		The hordes of the Arch-Enemy, may her name be forgotten, draw ever closer; the <b>Despised</b> pantheon threatens to destroy our world; and even the Architect of the Universe himself can no longer help us. Only sincere, absolute faith in the Pantheon can save us from the <b>End of Times</b>."
	worshippers = "The majority of inhabitants of the Grand Duchy of Azuria and many other states of Psydonia."

/datum/patron/divine
	profane_words = list(
		"zizo", "zizo", "zizo", "zizo", "zizo", "zizo",
		"matthios", "matthios", "matthios", "matthios", "matthios", "matthios",
		"graggar", "graggar", "graggar", "graggar", "graggar", "graggar",
		"baotha", "baotha", "baotha", "baotha", "baotha", "baotha",
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

/datum/patron/divine/undivided
	translated_name = "The Undivided Pantheon"
	rusgodnames = list("Pantheon", "Pantheon", "Pantheon", "Pantheon", "Pantheon",
		"Pantheon", "Ten", "Ten", "Ten", "Ten", "Ten", "Ten"
	)
	domain = "All is subject to the Ten."
	desc = "The Ten, united under the aegis of the Divine Order. The teaching of the Undivided Pantheon is central to the Valorian Holy See and prioritizes the understanding of each of the Ten's domains as integral elements of the cycle of life, as intended by the Architect of the Universe."
	worshippers = "Clergy of the Valorian confession, Knights of the Oath, pragmatists of the Church of the Ten."
	confess_lines = list(
		"THE SACRED DECAGRAM SHALL PROTECT MY SOUL!",
		"I SERVE THE DIVINE PANTHEON!",
		"THE TEN ETERNAL, FOREVER AND EVER!",
	)

/datum/patron/divine/astrata
	name = "Astrata"
	translated_name = "Astrata"
	rusgodnames = list(
		"Astrata", "Astrata", "Astrata", "Astrata", "Astrata", "Astrata",
		"Sun-Faced", "Sun-Faced", "Sun-Faced", "Sun-Faced", "Sun-Faced", "Sun-Faced",
		"The Radiant", "The Radiant", "The Radiant", "The Radiant", "The Radiant", "The Radiant",
		"Primordial Daughter", "Primordial Daughter", "Primordial Daughter", "Primordial Daughter",
		"Primordial Daughter", "Primordial Daughter"
	)
	miracles = list(/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/TAignition						= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/TAastrata_gaze						= CLERIC_T0,
					/obj/effect/proc_holder/spell/targeted/touch/summonrogueweapon/TAastratagrasp = CLERIC_T0,
					/obj/effect/proc_holder/spell/self/TAastrata_fireresist					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/TAsacred_flame			= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/TAastrata_sword						= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/TAastrataspark					= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/fortify/astrata					= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TArevive							= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/immolation						= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/TAsunstrike						= CLERIC_T4,
	)

	domain = "Sun, order, justice, faith, tactics and strategy, fertility."
	desc = "The Radiant Goddess of the Sun, His loving daughter, and the one who took upon herself the heavy burden of watching over Grimoria in the Father's absence, fighting against the forces that seek to plunge the world into darkness and chaos."
	worshippers = "Priests of the Grenzelhoft confession, nobles, zealots, officers, peasants and farmers."
	confess_lines = list(
		"ASTRATA - MY LIGHT!",
		"ASTRATA BRINGS ORDER!",
		"I SERVE IN THE NAME OF THE SUN!",
	)

/datum/patron/divine/noc
	name = "Noc"
	translated_name = "Noc"
	rusgodnames = list(
		"Noc",
		"Moon Maiden", "Moon Maiden", "Moon Maiden", "Moon Maiden",
		"Moon Maiden", "Moon Maiden",
		"The Knowing", "The Knowing", "The Knowing", "The Knowing", "The Knowing", "The Knowing"
	)

	domain = "Moon, knowledge, twilight, arcana, control, dreams."
	desc = "Goddess of knowledge, night, the Moon, and secrets. The first mistress of Arcana. Noc is the twin sister of the firstborn Astrata. Upon first seeing the Moon, she claimed it as her domain, and each time she raises it above Grimoria to illuminate the dark night for those who follow her."
	worshippers = "Priests of the Dvergayl Patriarchate, mages, scholars, scribes, ambitious individuals, researchers."
/*	miracles = list(/datum/action/cooldown/spell/touch/orison				= CLERIC_ORI,
					/datum/action/cooldown/spell/noc/sight					= CLERIC_T0,
					/datum/action/cooldown/spell/darkvision/miracle			= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal				= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle		= CLERIC_T1,
					/datum/action/cooldown/spell/noc/enlightenment			= CLERIC_T1,
					/datum/action/cooldown/spell/noc/inspiration			= CLERIC_T1,
					/datum/action/cooldown/spell/noc/invisibility			= CLERIC_T2,
					/datum/action/cooldown/spell/noc/blindness				= CLERIC_T2,
					/datum/action/cooldown/spell/noc/moonscorch				= CLERIC_T3,
					/datum/action/cooldown/spell/noc/spellpack				= CLERIC_T3,
					/datum/action/cooldown/spell/noc/grimoire				= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/noc		= CLERIC_T4,
	)*/
	confess_lines = list(
		"NOC - IS THE NIGHT!",
		"NOC SEES ALL!",
		"I SEEK THE SECRETS OF THE MOON!",
	)

/datum/patron/divine/dendor
	name = "Dendor"
	translated_name = "Dendor"
	rusgodnames = list(
		"Dendor", "Dendor", "Dendor", "Dendor", "Dendor", "Dendor",
		"First Beast", "First Beast", "First Beast", "First Beast",
		"First Beast", "First Beast",
		"Loving Father", "Loving Father", "Loving Father", "Loving Father",
		"Loving Father", "Loving Father",
		"Keeper of Groves", "Keeper of Groves", "Keeper of Groves", "Keeper of Groves",
		"Keeper of Groves", "Keeper of Groves"
	)

	domain = "Nature, beasts, hunting, fertility, madness, transformation."
	desc = "The youngest son of Psydon, the one to whom the loving Father allotted the green thickets, mighty beasts, and oak groves as his domain. Over time he went mad from the cruelty of this world and his influence waned, and yet... the farther from civilization, in forests black with undergrowth, in humid jungles and mountains... you will understand how great his influence truly is."
	worshippers = "Druids, shamans, beasts, madmen, hunters, herders, gatherers."
	confess_lines = list(
		"DENDOR PROVIDES SUSTENANCE!",
		"FATHER OF TREES BRINGS BOUNTY!",
		"I ANSWER THE CALL OF THE WILD!",
	)

/datum/patron/divine/abyssor
	name = "Abyssor"
	translated_name = "Abyssor"
	rusgodnames = list(
		"Abyssor", "Abyssor", "Abyssor", "Abyssor", "Abyssor", "Abyssor",
		"Father of Oceans", "Father of Oceans", "Father of Oceans", "Father of Oceans",
		"Father of Oceans", "Father of Oceans",
		"Sovereign of the Elements", "Sovereign of the Elements", "Sovereign of the Elements", "Sovereign of the Elements",
		"Sovereign of the Elements", "Sovereign of the Elements",
		"Sea Lord", "Sea Lord", "Sea Lord", "Sea Lord",
		"Sea Lord", "Sea Lord",
		"The Drowned God", "The Drowned God", "The Drowned God", "The Drowned God",
		"The Drowned God", "The Drowned God"
	)

	domain = "Sea, wind, elements, trade, voyages, natural magic, nightmares, secrets."
	desc = "The wrathful sea god, the raging sea element that sends storms into the seas and winds upon the lands. Son of Psydon, who failed to inherit his father's throne, and yet people fear and respect his untamed element."
	worshippers = "Seafarers, pirates, fishermen, merchants."
	confess_lines = list(
		"ABYSSOR COMMANDS THE WAVES!",
		"THE WRATH OF THE OCEAN - IS THE WILL OF ABYSSOR!",
		"THE TIDE PULLS ME!",
	)

/datum/patron/divine/ravox
	name = "Ravox"
	translated_name = "Ravox"
	rusgodnames = list(
		"Ravox", "Ravox", "Ravox", "Ravox", "Ravox", "Ravox",
		"The Strongest", "The Strongest", "The Strongest", "The Strongest",
		"The Strongest", "The Strongest",
		"The Most Worthy", "The Most Worthy", "The Most Worthy", "The Most Worthy",
		"The Most Worthy", "The Most Worthy"
	)

	domain = "War, courage, justice, strength, pride."
	desc = "A mortal who, by his unyielding will, determination, honest word, and courage, rightfully earned his place in the Pantheon. Hero of the divine war and the one who rose to defend mortals in their hour of need."
	worshippers = "Warriors, soldiers, mercenaries, wandering knights, judges."
	miracles = list(/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
					/obj/effect/proc_holder/spell/targeted/touch/summonrogueweapon/TAravoxgrasp = CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/TAtug_of_war					= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/TAprovocation						= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/TAdivine_strike						= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/TAbalance_immune					= CLERIC_T2,
					/obj/effect/proc_holder/spell/self/TAcall_to_arms						= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TAchallenge						= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TApersistence					= CLERIC_T3,
					/datum/action/cooldown/spell/ravox/TAraise_warrior_spirits			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/ravox					= CLERIC_T4,
	)
	confess_lines = list(
		"RAVOX - IS JUSTICE!",
		"THROUGH STRIFE - TO GRACE!",
		"THROUGH PERSEVERANCE AND COURAGE - WE SHALL ACHIEVE GLORY!",
	)

/datum/patron/divine/necra
	name = "Necra"
	translated_name = "Necra"
	rusgodnames = list(
		"Necra", "Necra", "Necra", "Necra", "Necra", "Necra",
		"Lady of the Veil", "Lady of the Veil", "Lady of the Veil", "Lady of the Veil",
		"Lady of the Veil", "Lady of the Veil",
		"The Faceless", "The Faceless", "The Faceless", "The Faceless",
		"The Faceless", "The Faceless"
	)
	domain = "Death, life, cycle, fate."
	desc = "Mistress of the underworld, the one-who-knows-all that was and all that is to come, the middle daughter of Psydon, who always remained in the shadows, tirelessly bearing the burden placed upon her by her father."
	worshippers = "The grieving, gravediggers, the dead, philosophers."
	miracles = list(/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/necras_sight				= CLERIC_T0,
					/datum/action/cooldown/spell/touch/shroud_of_tranquility = CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 						= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/avert						= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/locate_dead 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/fog_ward					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance	= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/necra_consecrate			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/bless_cross				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/deaths_door				= CLERIC_T4
	)
	confess_lines = list(
		"ALL SOULS GO TO NECRA!",
		"THE LADY OF THE VEIL - OUR FINAL REST!",
		"I DO NOT FEAR DEATH, MY LADY AWAITS ME!",
	)

/datum/patron/divine/xylix
	name = "Xylix"
	translated_name = "Xylix"
	rusgodnames = list(
		"Xylix", "Xylix", "Xylix", "Xylix", "Xylix", "Xylix",
		"Master of Masks", "Master of Masks", "Master of Masks", "Master of Masks",
		"Master of Masks", "Master of Masks",
		"The Many-Faced", "The Many-Faced", "The Many-Faced", "The Many-Faced",
		"The Many-Faced", "The Many-Faced",
		"The Jester", "The Jester", "The Jester", "The Jester", "The Jester", "The Jester"
	)

	domain = "Cunning, motion, laughter, mischief, eloquence, luck."
	desc = "The many-faced god of cunning and mischief, the only one of the Ten who obtained his divinity purely through his own tricks. Many legends and rumors surround him, and just as many of them are true as are false."
	worshippers = "Jesters, actors, minstrels, cardsharps, rogues, thieves, lucky ones."
	confess_lines = list(
		"I SERVE THE DIVINE PANTHEON!",
		"ASTRATA - MY LIGHT!",
		"NOC - IS THE NIGHT!",
		"DENDOR PROVIDES SUSTENANCE!",
		"ABYSSOR COMMANDS THE WAVES!",
		"RAVOX - IS JUSTICE!",
		"ALL SOULS GO TO NECRA!",
		"HAHAHAHA! AHAHAHA! HAHAHAHA!",
		"PESTRA SOOTHES ALL AFFLICTIONS!",
		"MALUM - MY MUSE!",
		"EORA UNITES US!",
		"LONG LIVE ZIZO!",
		"GRAGGAR - THE BEAST I WORSHIP!",
		"MATTHIOS - MY LORD!",
		"BAOTHA - MY JOY!",
		"JUDGE THE HERETICS - PSAYDON STANDS FIRM!",
	)

/datum/patron/divine/pestra
	name = "Pestra"
	translated_name = "Pestra"
	rusgodnames = list(
		"Pestra", "Pestra", "Pestra", "Pestra", "Pestra", "Pestra",
		"Maiden Martyr", "Maiden Martyr", "Maiden Martyr", "Maiden Martyr",
		"Maiden Martyr", "Maiden Martyr",
		"Merciful Sister", "Merciful Sister", "Merciful Sister", "Merciful Sister",
		"Merciful Sister", "Merciful Sister"
	)

	domain = "Disease, suffering, healing, mercy, endurance, purification, rest."
	desc = "Patroness of diseases, medicine, and the needy, whose merciful hand strives to rid the world of the spawn of darkness, infection, and suffering."
	worshippers = "Doctors, surgeons, the sick, martyrs, witches, apothecaries."
	confess_lines = list(
		"PESTRA HEALS ALL AFFLICTIONS!",
		"DECAY - IS THE CONTINUATION OF LIFE!",
		"MY AFFLICTION - IS MY TESTAMENT!",
	)

/datum/patron/divine/malum
	name = "Malum"
	translated_name = "Malum"
	rusgodnames = list(
		"Malum", "Malum", "Malum", "Malum", "Malum", "Malum",
		"Fire God", "Fire God", "Fire God", "Fire God",
		"Fire God", "Fire God",
		"God-Smith", "God-Smith", "God-Smith", "God-Smith",
		"God-Smith", "God-Smith"
	)
	domain = "Fire, steel, labor, craft, patience, perseverance."
	desc = "The Fire God-Smith, the first of the ascended mortals, patron of the working folk, the one who bears craft and creation alongside the forging of his soul. \"Labor is its own reward.\" Malum is known both for his indifference and his strictness toward followers; their creations please him far more."
	worshippers = "Blacksmiths, builders, architects, stonemasons, laborers."
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/TArestoration		= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/TArepair				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/TArework				= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/datum/action/cooldown/spell/arcyne_forge/miracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/TAvigorousexchange	= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/TAheatmetal			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/TAhammerfall			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/TAcraftercovenant		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/malum		= CLERIC_T4,
	)
	confess_lines = list(
		"MALUM - MY MUSE!",
		"TRUE VALUE - IS IN LABOR!",
		"I - AM THE INSTRUMENT OF CREATION!",
	)

/datum/patron/divine/eora
	name = "Eora"
	translated_name = "Eora"
	rusgodnames = list(
		"Eora", "Eora", "Eora", "Eora", "Eora", "Eora",
		"Loving Mother", "Loving Mother", "Loving Mother", "Loving Mother",
		"Loving Mother", "Loving Mother",
		"The Blooming", "The Blooming", "The Blooming", "The Blooming",
		"The Blooming", "The Blooming"
	)

	domain = "Life, family, peace, beauty, compassion."
	desc = "The youngest of the gods, the one who brought an end to the strife between gods and between mortals, uniting them under the sign of love."
	worshippers = "Artists, sculptors, writers, diplomats, orators, spouses and lovers."
	confess_lines = list(
		"EORA UNITES US!",
		"HER BEAUTY EVEN IN THIS SUFFERING!",
		"I LOVE YOU, EVEN WHEN YOU ASSAULT ME!",
	)
