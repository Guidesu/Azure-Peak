// Player-facing entry points for the ported relations system.
//
// Vanderlin authored gossip/rumor text through a preference UI
// (/datum/gossip_prefs, backed by /datum/preference/list_type/rumors and
// /datum/preference/list_type/noble_gossip, spread automatically each round
// by SSrelations.spread_gossip()) and assigned rivals/grudges automatically
// at round start. This repo has no matching preference-datum framework
// (grepped for read_preference/write_preference/list_type prefs — none
// exist) and no round-start occupation-division hook, so both of those are
// replaced with direct, in-the-moment player verbs instead: you say a rumor
// aloud about someone nearby (spreading it to bystanders' relation
// histories, same propagation idea as Vanderlin's "say_gossip" TGUI action),
// or you declare a grudge against someone you know.

/mob/living/carbon/human/verb/dreamvalley_view_relations()
	set name = "Relations"
	set category = "IC"
	set desc = "Review who you know, your rivals, and any history between you."

	if(!mind)
		to_chat(src, span_warning("You have no memories to speak of."))
		return
	var/datum/tgui_relations/ui = new(mind)
	ui.ui_interact(src)

/mob/living/carbon/human/verb/dreamvalley_spread_rumor()
	set name = "Spread Rumor"
	set category = "IC"
	set desc = "Say a rumor aloud about someone nearby."

	if(!mind)
		to_chat(src, span_warning("You have no memories to speak of."))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in oview(7, src))
		if(H == src || !H.mind)
			continue
		targets[H.real_name] = H

	if(!length(targets))
		to_chat(src, span_warning("There is no one nearby to gossip about."))
		return

	var/target_name = input(src, "Who is this rumor about?", "Spread Rumor") as null|anything in targets
	if(!target_name)
		return
	var/mob/living/carbon/human/subject = targets[target_name]
	if(!subject || QDELETED(subject) || !subject.mind)
		return

	var/text = stripped_input(src, "What's the rumor about [subject.real_name]?", "Spread Rumor", "", MAX_MESSAGE_LEN)
	if(!text || !length(text))
		return

	say(text) // say() itself gates on mute/unconscious/etc, no need to duplicate that here

	var/datum/relation_history/gossip/source_gossip = new()
	source_gossip.heard_text = text

	for(var/mob/living/carbon/human/listener in hearers(5, src))
		if(listener == src || !listener.mind)
			continue
		var/datum/relation/R = SSrelations.get_or_create_gossip_relation(listener.mind, subject.mind)
		if(!R)
			continue
		var/datum/relation_history/gossip/G = new()
		G.heard_text = text
		R.add_history(G)

/mob/living/carbon/human/verb/dreamvalley_hold_grudge()
	set name = "Hold a Grudge"
	set category = "IC"
	set desc = "Declare a lasting grudge against someone you know."

	if(!mind)
		to_chat(src, span_warning("You have no memories to speak of."))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in oview(7, src))
		if(H == src || !H.mind)
			continue
		targets[H.real_name] = H

	if(!length(targets))
		to_chat(src, span_warning("There is no one nearby to hold a grudge against."))
		return

	var/target_name = input(src, "Who do you hold a grudge against?", "Hold a Grudge") as null|anything in targets
	if(!target_name)
		return
	var/mob/living/carbon/human/target = targets[target_name]
	if(!target || QDELETED(target) || !target.mind)
		return

	if(!length(GLOB.dreamvalley_grudge_pool_generic))
		dreamvalley_build_grudge_pool()
	if(!length(GLOB.dreamvalley_grudge_pool_generic))
		return

	var/chosen_path = pick(GLOB.dreamvalley_grudge_pool_generic)
	var/datum/grudge_type/G = new chosen_path()

	var/datum/relation/R = mind.add_relation(target.mind, /datum/relation/had_crossed)
	var/datum/relation/R_target = target.mind.add_relation(mind, /datum/relation/was_crossed)

	var/datum/relation_history/history = new(G.grudge_name, G.aggressor_text, G.victim_text, mind, target.mind)
	if(R)
		R.add_history(history)
	if(R_target)
		R_target.add_history(history)
	qdel(G)

	to_chat(src, span_warning("You now hold a grudge against [target.real_name]: [G.grudge_name]."))
