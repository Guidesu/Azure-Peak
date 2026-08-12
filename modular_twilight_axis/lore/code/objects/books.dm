/obj/item/book/rogue/bibble
	name = "The Verses and Acts of the Ten"
	desc = "'THE TEN guide us through the darkness. THE TEN GODS above all.' </br>The holy book of the Church of the Ten, distributed by the Holy Sees throughout Grimoria. Divided into three Covenants in chronological order.</br>LEVITICUS - The First Covenant, recounting the times of the Foundation and the Primordial Era. </br>DECANOMICON - The Second Covenant, recounting the War in the Heavens, which shook our world to its foundations. </br>NEW DAWN - The Third Covenant, recounting the establishment of the Divine Order and the Undivided Pantheon."
	icon_state = "bibble_0"
	base_icon_state = "bibble"
	title = "The Verses and Acts of the Ten"
	dat = "gott.json"
	possible_item_intents = list(
		/datum/intent/use,
		/datum/intent/bless,
	)

/obj/item/book/rogue/bibble/read(mob/user)
	if(!open)
		to_chat(user, span_info("Open me first."))
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		var/list/choices = list("Leviticus", "Decanomicon", "New Dawn")
		var/section_choice = tgui_input_list(user, "Which Covenant's wisdom shall I share?", "DIVINE ENLIGHTENMENT", choices)
		var/chosentxt
		switch(section_choice)
			if("Leviticus")
				chosentxt = 'modular_twilight_axis/lore/strings/visage.txt'
			if("Decanomicon")
				chosentxt = 'modular_twilight_axis/lore/strings/decanomicon.txt'
			if("New Dawn")
				chosentxt = 'modular_twilight_axis/lore/strings/newdawn.txt'
			else
				return
		var/list/verses = world.file2list(chosentxt)
		var/m = tgui_input_list(user, "Which verse shall I recite?", "DIVINE ENLIGHTENMENT", verses)
		if(m)
			user.say(m)
		else
			m = pick(verses)
			user.say(m)

/obj/item/book/rogue/bibble/psy
	desc = "'And He weeps. Not for you, not for Himself, but for all of us.' </br>A leather-bound tome containing the teachings of the Church of the Allfather. The book is divided into four Covenants, reflecting the beliefs of the largest and most significant denominations of the Psydonite faith. </br>THE COVENANT OF PSAYDON is the teaching of the Old Faith, which guided the righteous in the times before the Arch-Betrayal. </br>THE LIFE OF PSAYDON describes the creation of Psydonia as we know it. </br>THE COVENANT OF OTAVIK is the truth of the new age, revealed to us by the Grand Master of Otava. </br>THE COVENANT OF FATE is the teaching of the people of Naledi, allies in the struggle against the evil that has seized our sinful world. "

/obj/item/book/rogue/bibble/psy/read(mob/living/carbon/human/user)
	if(!open)
		to_chat(user, span_info("Open it first."))
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		if(sect)
			var/list/verses = world.file2list("modular_twilight_axis/lore/strings/psy[sect].txt")
			var/m = tgui_input_list(user, "Which verse shall I recite?", "DIVINE ENLIGHTENMENT", verses)
			if(m)
				if(prob(1) && sect == "sect1")
					user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
					user.say("PSAY 66:6... +_Allfather_+ spoke: \"I forgive you, for I love you as a father loves his daughter.\" And blood flowed down the blade and from the chest e- How did this get here?!")
				else
					user.say(m)
			else
				m = pick(verses)
				if(prob(1) && sect == "sect1")
					user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
					user.say("PSAY 66:6... +_Allfather_+ spoke: \"I forgive you, for I love you as a father loves his daughter.\" And blood flowed down the blade and from the chest e- How did this get here?!")
				else
					user.say(m)

/obj/item/book/rogue/bibble/psy/MiddleClick(mob/user, params)
	var/sects = list("Covenant of Psydon", "Life of Psydon", "Covenant of Otavik", "Covenant of Fate")
	var/sect_choice = input(user, "Choose a Covenant", "ON PSAYDONIA") as anything in sects
	switch(sect_choice)
		if("Covenant of Psydon")
			sect = "sect1"
		if("Life of Psydon")
			sect = "sect2"
		if("Covenant of Otavik")
			sect = "sect3"
		if("Covenant of Fate")
			sect = "sect4"
	return

/obj/item/book/rogue/bibble/zizo
	name = "Lexicon of Her Truth"
	desc = "'By knowing Her teaching, one day we shall walk in Her footsteps.'</br>A tome forbidden by the Holy See, containing an account of the mortal life and ascension of Zizo, the Lady of Darkness — or at least, the version of events adhered to by the cultists of Salvation. It suspiciously smells of dried blood."
	icon = 'modular_twilight_axis/lore/icons/books.dmi'
	icon_state = "zizoble_0"
	base_icon_state = "zizoble"
	title = "Lexicon of Her Truth"
	dat = "gott.json"

/obj/item/book/rogue/bibble/zizo/attack(mob/living/M, mob/user)
	return

/obj/item/book/rogue/bibble/zizo/MiddleClick(mob/user, params)
	return

/obj/item/book/rogue/bibble/zizo/read(mob/living/carbon/human/user)
	if(!open)
		to_chat(user, span_info("Open it first."))
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		var/list/verses = world.file2list("modular_twilight_axis/lore/strings/zizo.txt")
		var/m = tgui_input_list(user, "Which verse shall I recite?", "DIVINE ENLIGHTENMENT", verses)
		if(m)
			user.say(m)
		else
			m = pick(verses)
			user.say(m)
