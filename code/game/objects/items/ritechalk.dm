/obj/item/ritechalk
	name = "ritual chalk"
	icon_state = "chalk"
	desc = "Simple white chalk. A useful tool for rites."
	icon = 'icons/roguetown/misc/rituals.dmi'
	w_class = WEIGHT_CLASS_TINY
	experimental_inhand = TRUE
	dropshrink = 0.6

/obj/item/ritechalk/attack_self(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user, span_warning("I don't know what I'm doing with this..."))
		return

	var/ritechoices = list()
	switch (user.patron?.type)
		if(/datum/patron/oldkin/volkovoi)
			ritechoices+="Rune of Violence"
		if(/datum/patron/unveiled/aurelian)
			ritechoices+="Rune of Zizo" 
		if(/datum/patron/concordat/morwenna)
			ritechoices+="Rune of Transaction"
		if(/datum/patron/oldkin/hausvette)
			ritechoices+="Rune of Hedonism"
		if(/datum/patron/tribunal/custodius)
			ritechoices+= "Rune of Divinity"
		if(/datum/patron/concordat/auxentius)
			ritechoices+="Rune of Sun"
		if(/datum/patron/concordat/miluse)
			ritechoices+="Rune of Moon"
		if(/datum/patron/severance/ignatius)
			ritechoices+="Rune of Beasts"
		if(/datum/patron/concordat/handwerra)
			ritechoices+="Rune of Forge"
		if(/datum/patron/concordat/viator)
			ritechoices+="Rune of Trickery"
		if(/datum/patron/concordat/morwenna)
			ritechoices+="Rune of Death"
		if(/datum/patron/concordat/handwerra)
			ritechoices+="Rune of Plague"
		if(/datum/patron/concordat/miluse)
			ritechoices+="Rune of Love"
		if(/datum/patron/concordat/auxentius)
			ritechoices+="Rune of Justice"
		if(/datum/patron/concordat/wulfric)
			ritechoices+="Rune of Storms"
			ritechoices+="Rune of Stirring"
		if(/datum/patron/tribunal/praecursor)
			ritechoices+="Rune of Psydon"

	if(HAS_TRAIT(user, TRAIT_DREAMWALKER) && !("Rune of Stirring" in ritechoices))
		ritechoices+="Rune of Stirring"

	var/runeselection = input(user, "Which rune shall I inscribe?", src) as null|anything in ritechoices
	var/turf/step_turf = get_step(get_turf(user), user.dir)
	switch(runeselection)
		if("Rune of Sun")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her radiance..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/astrata(step_turf)
		if("Rune of Moon")
			to_chat(user, span_cultsmall("I begin inscribing the rune of His wisdom."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/noc(step_turf)
		if("Rune of Beasts")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His madness."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/dendor(step_turf)
		if("Rune of Forge")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Their craft..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/malum(step_turf)
		if("Rune of Trickery")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Their trickery..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/xylix(step_turf)
		if("Rune of Death")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her embrace..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/necra(step_turf)
		if("Rune of Plague")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her plague..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/pestra(step_turf)
		if("Rune of Love")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her love..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/eora(step_turf)
		if("Rune of Justice")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His justice..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/ravox(step_turf)
		if("Rune of Storms")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His storm..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/abyssor(step_turf)
		if("Rune of Stirring")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Dream..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/abyssor_alt_inactive(step_turf)
		if("Rune of Zizo")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Knowledge..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/zizo(step_turf)
		if("Rune of Transaction")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His transactions..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/matthios(step_turf)
		if("Rune of Violence")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His slaughter..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/graggar(step_turf)
		if("Rune of Hedonism")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her addiction..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/baotha(step_turf)
		if("Rune of Psydon")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His presence..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/effect/decal/cleanable/roguerune/god/psydon(step_turf)
		if("Rune of Divinity")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Their divinity..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/undivided(step_turf)
