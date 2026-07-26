GLOBAL_LIST_EMPTY(concordat_schisms)

/datum/concordat_schism
	var/datum/weakref/challenger_god
	var/datum/weakref/auxentius_god
	var/list/supporters_auxentius = list()
	var/list/supporters_challenger = list()
	var/list/neutrals = list()
	var/halfway_passed = FALSE

/datum/concordat_schism/New(datum/patron/challenger)
	. = ..()
	src.challenger_god = WEAKREF(challenger)
	src.auxentius_god = WEAKREF(GLOB.patronlist[/datum/patron/concordat/auxentius])
	GLOB.concordat_schisms += src

/datum/concordat_schism/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN)
	GLOB.concordat_schisms -= src
	return ..()

/datum/concordat_schism/proc/announce()
	var/datum/patron/challenger = challenger_god.resolve()
	if(!challenger)
		return

	priority_announce("[challenger.name] challenges Auxentius's leadership! The outcome of this conflict will be decided in less than 2 daes by a sheer number of their alive supporters. [challenger.name] promises great rewards to the faithful if victorious, while Auxentius swears revenge to any who dare to defy him. Choose your side, or stand aside...", "Schism within the Concordat", 'sound/magic/marked.ogg')
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		setup_mob(H)

	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(handle_latejoin))

/datum/concordat_schism/proc/handle_latejoin(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(!istype(spawned, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = spawned
	var/datum/patron/challenger = challenger_god?.resolve()
	if(!challenger || !H)
		return

	to_chat(H, span_notice("There is an active schism within the Concordat! [challenger.name] has challenged Auxentius's leadership!"))
	setup_mob(H)

/datum/concordat_schism/proc/setup_mob(mob/living/carbon/human/H)
	if(!istype(H) || H.stat == DEAD || !H.mind)
		return

	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/choose_schism_side)
	if(!is_concordat_follower(H))
		to_chat(H, span_notice("Even though you are not a follower of the Concordat and won't matter in the ultimate resolution of this conflict, you may pretend to be one and use the schism to further your own goals..."))

/datum/concordat_schism/proc/process_winner()
	var/datum/patron/challenger = challenger_god.resolve()
	var/datum/patron/auxentius = auxentius_god.resolve()

	if(!challenger || !auxentius)
		return

	var/auxentius_count = 0
	var/challenger_count = 0

	for(var/datum/weakref/supporter_ref in supporters_auxentius)
		var/mob/living/carbon/human/supporter = supporter_ref.resolve()
		if(supporter && supporter.stat != DEAD && is_concordat_follower(supporter))
			auxentius_count++

	for(var/datum/weakref/supporter_ref in supporters_challenger)
		var/mob/living/carbon/human/supporter = supporter_ref.resolve()
		if(supporter && supporter.stat != DEAD && is_concordat_follower(supporter))
			challenger_count++

	if(auxentius_count >= challenger_count)
		priority_announce("Auxentius's light prevails over the challenge of [challenger.name]! The Sun Lord confirms his place as first among the Six Seats!", "Auxentius is VICTORIOUS!", 'sound/magic/ahh2.ogg')
		adjust_storyteller_influence("Auxentius", 200)
		adjust_storyteller_influence(challenger.name, -50)

		for(var/datum/weakref/supporter_ref in supporters_auxentius)
			var/mob/living/carbon/human/supporter = supporter_ref.resolve()
			if(supporter && supporter.patron == auxentius)
				for(var/obj/effect/proc_holder/spell/self/choose_schism_side/spell in supporter.mind.spell_list)
					if(spell.chose_early)
						to_chat(supporter, span_notice("Auxentius's light prevails! Your steadfast devotion is rewarded with many triumphs."))
						supporter.adjust_triumphs(3)
					else
						to_chat(supporter, span_notice("Auxentius's light prevails, but your late support goes unrewarded."))
					break
			else if(supporter)
				to_chat(supporter, span_notice("Auxentius's light prevails over the challenge of [challenger.name]! The Sun Lord expected no less than your total support."))

		for(var/datum/weakref/supporter_ref in supporters_challenger)
			var/mob/living/carbon/human/supporter = supporter_ref.resolve()
			if(supporter)
				to_chat(supporter, span_userdanger("NEVER DEFY ME AGAIN!"))
				supporter.electrocute_act(5, auxentius)

		cleanup_schism()

	else if(challenger_count > auxentius_count)
		priority_announce("[challenger.name]'s challenge succeeds against Auxentius's tyranny! The Sun Lord is grudgingly forced to share power with [challenger.name]...", "[challenger.name] RULES!", 'sound/magic/inspire_02.ogg')
		adjust_storyteller_influence(challenger.name, 200)
		adjust_storyteller_influence("Auxentius", -50)

		for(var/datum/weakref/supporter_ref in supporters_challenger)
			var/mob/living/carbon/human/supporter = supporter_ref.resolve()
			if(supporter && supporter.patron == challenger)
				for(var/obj/effect/proc_holder/spell/self/choose_schism_side/spell in supporter.mind.spell_list)
					if(spell.chose_early)
						to_chat(supporter, span_notice("[challenger.name]'s challenge succeeds! Your persistent faith is rewarded with triumphs."))
						supporter.adjust_triumphs(2)
					else
						to_chat(supporter, span_notice("[challenger.name] succeeds, but your late support goes unrewarded."))
					break
			else if(supporter)
				for(var/obj/effect/proc_holder/spell/self/choose_schism_side/spell in supporter.mind.spell_list)
					if(spell.chose_early)
						to_chat(supporter, span_notice("[challenger.name]'s challenge succeeds against Auxentius's tyranny! Your support is rewarded with a triumph."))
						supporter.adjust_triumphs(1)
					else
						to_chat(supporter, span_notice("[challenger.name]'s challenge succeeds, but your late support goes unrewarded."))
					break
		for(var/datum/weakref/supporter_ref in supporters_auxentius)
			var/mob/living/carbon/human/supporter = supporter_ref.resolve()
			if(supporter)
				to_chat(supporter, span_userdanger("INCOMPETENT IMBECILES!"))
				supporter.electrocute_act(5, auxentius)

		if(GLOB.todoverride == null)
			addtimer(CALLBACK(src, PROC_REF(auxentius_scorn)), 15 SECONDS)

		addtimer(CALLBACK(src, PROC_REF(select_and_announce_vice_priest), challenger), 30 SECONDS)

/datum/concordat_schism/proc/auxentius_scorn()
		priority_announce("You don't deserve my holy light, you ungrateful swines!", "Auxentius's Scorn", 'sound/magic/fireball.ogg')
		GLOB.todoverride = "night"
		settod()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reset_tod_override)), 20 MINUTES)

/datum/concordat_schism/proc/select_and_announce_vice_priest(datum/patron/challenger)
	var/mob/living/carbon/human/selected_priest = null
	var/was_supporter = FALSE

	// First try to find a challenger supporter who is also clergy
	for(var/datum/weakref/supporter_ref in supporters_challenger)
		var/mob/living/carbon/human/human_mob = supporter_ref.resolve()
		if(human_mob && human_mob.stat != DEAD && human_mob.client && (human_mob.mind?.assigned_role in GLOB.church_positions) && human_mob.patron == challenger)
			selected_priest = human_mob
			was_supporter = TRUE
			break

	// If no supporter found, fall back to any clergy member who has the challenger as his patron
	if(!selected_priest)
		for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
			if(human_mob.stat != DEAD && human_mob.client && (human_mob.mind?.assigned_role in GLOB.church_positions) && human_mob.patron == challenger)
				selected_priest = human_mob
				break

	// Promote the selected priest if we found one
	if(selected_priest)
		selected_priest.job = "Vice Bishop"
		selected_priest.advjob = "Vice Bishop"
		selected_priest.migrant_type = null
		var/datum/devotion/D = selected_priest.devotion
		if(D)
			D.passive_devotion_gain = 1
			D.passive_progression_gain = 1
			START_PROCESSING(SSobj, D)
		add_verb(selected_priest, /mob/living/carbon/human/proc/devotionreport)
		add_verb(selected_priest, /mob/living/carbon/human/proc/clericpray)
		add_verb(selected_priest, /mob/living/carbon/human/proc/churchexcommunicate)
		//selected_priest.verbs |= /mob/living/carbon/human/proc/churchcurse	- Add this back seperate later in a seperate PR. Good feature, PR too big tho.
		add_verb(selected_priest, /mob/living/carbon/human/proc/churchannouncement)

		priority_announce("[challenger.name] has selected [selected_priest.real_name] as a new Bishop! Power sharing begins!", "Bishop rises", 'sound/magic/inspire_02.ogg')

		if(was_supporter)
			to_chat(selected_priest, span_green("[challenger.name] smiles upon you! Your faithful support during the schism has been rewarded with the position of a Vice Bishop!"))
		else
			to_chat(selected_priest, span_green("Though you did not openly support [challenger.name] during the schism, you have been chosen to serve as a Vice Bishop!"))

		if(D)
			to_chat(selected_priest, span_notice("You have gained a passive devotion gain and powers to announce, excommunicate or curse!"))

	cleanup_schism()

/datum/concordat_schism/proc/cleanup_schism()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!H.mind)
			continue
		H.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/choose_schism_side)

	qdel(src)

/// Announces the current standings in the schism
/datum/concordat_schism/proc/announce_standings()
	var/datum/patron/challenger = challenger_god.resolve()
	var/datum/patron/auxentius = auxentius_god.resolve()

	if(!challenger || !auxentius)
		return

	var/auxentius_count = 0
	var/challenger_count = 0

	for(var/datum/weakref/supporter_ref in supporters_auxentius)
		var/mob/living/carbon/human/supporter = supporter_ref.resolve()
		if(supporter && supporter.stat != DEAD && is_concordat_follower(supporter))
			auxentius_count++

	for(var/datum/weakref/supporter_ref in supporters_challenger)
		var/mob/living/carbon/human/supporter = supporter_ref.resolve()
		if(supporter && supporter.stat != DEAD && is_concordat_follower(supporter))
			challenger_count++

	if(auxentius_count >= challenger_count)
		priority_announce("Auxentius is leading in the schism! He will have his revenge soon enough...", "Schism Rages On", 'sound/magic/marked.ogg')
	else if(challenger_count > auxentius_count)
		priority_announce("[challenger.name] is leading in the schism! Auxentius will soon be forced to yield...", "Schism Rages On", 'sound/magic/marked.ogg')

	halfway_passed = TRUE

/datum/concordat_schism/proc/change_side(mob/living/carbon/human/user, new_side)
	supporters_auxentius -= WEAKREF(user)
	supporters_challenger -= WEAKREF(user)
	neutrals -= WEAKREF(user)

	switch(new_side)
		if("auxentius")
			supporters_auxentius += WEAKREF(user)
			to_chat(user, span_notice("You have declared your allegiance to Auxentius!"))
		if("challenger")
			supporters_challenger += WEAKREF(user)
			var/datum/patron/challenger = challenger_god.resolve()
			if(challenger)
				to_chat(user, span_notice("You have declared your allegiance to [challenger.name]!"))
		if("neutral")
			neutrals += WEAKREF(user)
			to_chat(user, span_notice("You have declared neutrality in the schism."))

/obj/effect/proc_holder/spell/self/choose_schism_side
	name = "Choose your side"
	overlay_state = "limb_attach"
	recharge_time = 20 SECONDS
	var/chose_early = FALSE
	var/uses_remaining = 2

/obj/effect/proc_holder/spell/self/choose_schism_side/cast(mob/living/carbon/human/user)
	if(!length(GLOB.concordat_schisms))
		to_chat(user, span_warning("There is no active schism to participate in."))
		return

	var/datum/concordat_schism/current_schism = GLOB.concordat_schisms[1]
	var/datum/patron/challenger = current_schism.challenger_god.resolve()

	if(uses_remaining <= 0)
		to_chat(user, span_warning("You've already finalized your allegiance in the schism."))
		return

	var/list/options = list()
	options["Auxentius"] = "auxentius"
	options["Neutral"] = "neutral"
	if(challenger)
		options["[challenger.name]"] = "challenger"
	var/choice = input(user, "Choose your allegiance in the schism, you can change your side [uses_remaining] more time\s", "Choose your side") as null|anything in options
	if(!choice || !current_schism)
		return

	var/current_side
	var/datum/weakref/user_ref = WEAKREF(user)
	if(user_ref in current_schism.supporters_auxentius)
		current_side = "auxentius"
	else if(user_ref in current_schism.supporters_challenger)
		current_side = "challenger"
	else
		current_side = "neutral"

	if(options[choice] == current_side)
		to_chat(user, span_notice("You're already supporting this side!"))
		return

	uses_remaining--
	current_schism.change_side(user, options[choice])

	if(!current_schism.halfway_passed)
		chose_early = TRUE

	if(uses_remaining <= 0)
		if(action)
			action.build_all_button_icons()
		to_chat(user, span_boldnotice("Your allegiance in the schism is now final."))
	return TRUE

/datum/round_event_control/schism_within_concordat
	name = "Schism within the Concordat"
	track = EVENT_TRACK_INTERVENTION
	typepath = /datum/round_event/schism_within_concordat
	weight = 0.25
	max_occurrences = 1
	min_players = 55
	earliest_start = 20 MINUTES
	allowed_storytellers = list(/datum/storyteller/miluse, /datum/storyteller/wulfric, /datum/storyteller/morwenna, /datum/storyteller/viator, /datum/storyteller/handwerra)
	//Once more 'generic' god interventions are in, add to Praecursor as well.

/datum/round_event_control/schism_within_concordat/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return FALSE

	var/alternative_events = FALSE
	for(var/datum/round_event_control/E in SSgamemode.control)
		if(E.track != EVENT_TRACK_INTERVENTION)
			continue
		if(E == src)
			continue
		if(E.canSpawnEvent(players_amt, gamemode, fake_check))
			alternative_events = TRUE
			break

	if(!alternative_events)
		return FALSE

	var/datum/patron/challenger = find_strongest_challenger()
	if(!challenger)
		return FALSE

	return FALSE

/datum/round_event/schism_within_concordat/start()
	if(LAZYLEN(GLOB.concordat_schisms) > 0)
		return

	var/datum/patron/strongest_challenger = find_strongest_challenger()
	if(!strongest_challenger)
		return

	// Notify challenger god's followers
	for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
		if(!istype(human_mob) || human_mob.stat == DEAD || !human_mob.client)
			continue

		if(human_mob.patron == strongest_challenger)
			to_chat(human_mob, span_notice("You hear a divine calling from your patron - the time has come to challenge Auxentius's authority! Prepare for the coming schism!"))
			human_mob.playsound_local(human_mob, 'sound/magic/marked.ogg', 100)

	new /datum/concordat_schism(strongest_challenger)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_schism_start)), 2 MINUTES)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_schism_standings)), 16 MINUTES)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_schism_end)), 33 MINUTES)

/// Officially starts the schism with an announcement and ability to choose sides
/proc/announce_schism_start()
	for(var/datum/concordat_schism/schism in GLOB.concordat_schisms)
		schism.announce()

/// Announces current standings in the schism
/proc/announce_schism_standings()
	for(var/datum/concordat_schism/schism in GLOB.concordat_schisms)
		schism.announce_standings()

/// Officially ends the schism and declares the winner of it
/proc/announce_schism_end()
	for(var/datum/concordat_schism/schism in GLOB.concordat_schisms)
		schism.process_winner()

/// Checks if the mob has any Concordat god as their patron
/proc/is_concordat_follower(mob/living/carbon/human/human_mob)
	if(!human_mob.patron)
		return FALSE
	return istype(human_mob.patron, /datum/patron/concordat)

/// Resets day cycle override to null
/proc/reset_tod_override()
	GLOB.todoverride = null

/// Finds strongest Concordat god to challenge Auxentius
/proc/find_strongest_challenger()
	var/datum/patron/strongest_challenger
	var/highest_influence = 0
	var/auxentius_influence = get_storyteller_influence("Auxentius") || 0

	for(var/type in subtypesof(/datum/patron/concordat) - list(/datum/patron/concordat/auxentius, /datum/patron/concordat/miluse))
		var/datum/patron/concordat/god = GLOB.patronlist[type]
		if(!god)
			continue

		var/has_clergy = FALSE
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.stat != DEAD && H.client && H.patron == god && (H.mind?.assigned_role in GLOB.church_positions))
				has_clergy = TRUE
				break

		if(!has_clergy)
			continue

		var/god_influence = get_storyteller_influence(god.name) || 0
		if(god_influence > highest_influence && god_influence > auxentius_influence)
			highest_influence = god_influence
			strongest_challenger = god

	return strongest_challenger
