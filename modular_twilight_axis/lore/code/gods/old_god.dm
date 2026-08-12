/datum/faith/old_god
	preference_accessible = FALSE
	name = "Genesism"
	translated_name = "Church of the Allfather"
	desc = "The Church turned away from the <b>Architect of the Universe</b>, believing he fell at the hands of the <b>Arch-Enemy</b>. But we know the truth.\n\
		<b>PSAYDON LIVES. PSAYDON ENDURES.</b>\n\
		PSAYDON sent us the <b>COMET SION</b>, so that we would not doubt his eternal dominion over the world. The eyes of the blind shall be opened at the End of Times, when the ALLFATHER returns to us — until then, we shall be ready to answer HIS call."
	worshippers = "Giza, Otava, the Masters of the Church of Grenzelhoft, as well as orthodox diasporas throughout <b>Psydonia</b>."
	godhead = /datum/patron/old_god

/datum/patron/old_god
	preference_accessible = FALSE
	name = "Psydon"
	translated_name = "Psydon"
	rusgodnames = list(
		"Psydon", "Psydon", "Psydon", "Psydon", "Psydon", "Psydon",
		"Architect of the Universe", "Architect of the Universe", "Architect of the Universe",
		"Architect of the Universe", "Architect of the Universe", "Architect of the Universe",
		"Heavenly Father", "Heavenly Father", "Heavenly Father", "Heavenly Father",
		"Heavenly Father", "Heavenly Father",
		"Allfather", "Allfather", "Allfather", "Allfather",
		"Allfather", "Allfather"
	)
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
	miracles = list()
	traits_tier = list(TRAIT_PSYDONITE = CLERIC_T0, TRAIT_PSYDONITE_2 = CLERIC_T1, TRAIT_PSYDONIC_MEDICINE = CLERIC_T2, TRAIT_PSYDONITE_3 = CLERIC_T2, TRAIT_PSYDONITE_4 = CLERIC_T3)
	domain = "All is subject to the Architect of all that is."
	desc = "The Architect of the universe, the true lord of <b>Psydonia</b>. A martyr. \n\
\"....\" - Only an oppressive silence in the heavenly halls henceforth. The Architect of all that is no longer proclaims his edicts. \n\
Psydon is now known as a wounded god, a martyr god, but the true believers know — the Architect of all that is, the Allfather, lives. It was he who created the world according to his vision, creating it only for himself and his followers."
	worshippers = "Inhabitants of Giza, Otava, and the imperial territories of Grenzelhoft, inquisitors, zealots, masters of steam and gunpowder, martyrs and the doomed."
	associated_faith = /datum/faith/old_god
	confess_lines = list(
		"THERE IS ONLY ONE GOD!",
		"PSAYDON STILL LIVES! PSAYDON STILL ENDURES!!",
		"JUDGE THE HERETICS - PSAYDON STANDS FIRM!",
		"EXPOSE THE PAGAN, SLAY THE MONSTER!",
		"MY GOD - WITH EVERY BROKEN BONE I SWORE I WAS ALIVE!",
		"EVEN NOW THERE IS STILL HOPE FOR HUMANITY! GLORY TO PSAYDONIA!",
		"BEHOLD ME, PSAYDON; THE SACRIFICE HAS TAKEN FORM!"
	)
