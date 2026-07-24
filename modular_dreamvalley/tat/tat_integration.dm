// Azure Peak-facing hooks for TAT. Continue deliberately does not use any of
// these procs: a parked body is restored from its exact character graph.

/datum/preferences
	var/datum/tat_build/tat_build
	/// Set only by TAT's Save & Join action. Continue never reads this flag.
	var/tmp/dreamvalley_tat_join_pending = FALSE

/datum/preferences/proc/dreamvalley_get_tat_build()
	if(!tat_build)
		tat_build = new(src)
	else
		tat_build.attach_preferences(src)
	return tat_build

/datum/preferences/proc/dreamvalley_open_tat(mob/user)
	var/datum/tat_build/build = dreamvalley_get_tat_build()
	build.ui_interact(user)

/proc/dreamvalley_tat_character_sheet_link()
	return "<a href='?_src_=prefs;preference=dreamvalley_tat;task=input'><b>Build &amp; Join</b></a>"

/proc/dreamvalley_tat_rank_for_bucket(bucket)
	switch(bucket)
		if(TAT_ROLE_BUCKET_TOWNER)
			return "Towner"
		if(TAT_ROLE_BUCKET_TRADER)
			return "Trader"
		if(TAT_ROLE_BUCKET_ADVENTURER)
			return "Adventurer"
		if(TAT_ROLE_BUCKET_WRETCH)
			return "Wretch"
	return null

/proc/dreamvalley_open_tat_join(mob/dead/new_player/player)
	if(!player?.client?.prefs)
		return FALSE
	player.client.prefs.dreamvalley_open_tat(player)
	return TRUE

/proc/dreamvalley_tat_join_from_builder(mob/user, datum/tat_build/build)
	if(!isnewplayer(user))
		to_chat(user, span_warning("Return to the character lobby before joining with a new build."))
		return FALSE

	var/mob/dead/new_player/player = user
	var/datum/preferences/preferences = player.client?.prefs
	if(!preferences || preferences.dreamvalley_get_tat_build() != build)
		return FALSE
	if(!build.can_save())
		to_chat(player, span_warning("Finish the build before joining."))
		return FALSE
	if(length(preferences.flavortext) < MINIMUM_FLAVOR_TEXT)
		to_chat(player, span_boldwarning("You need a minimum of [MINIMUM_FLAVOR_TEXT] characters in your flavor text in order to play."))
		return FALSE
	if(length(preferences.ooc_notes) < MINIMUM_OOC_NOTES)
		to_chat(player, span_boldwarning("You need at least a few words in your OOC notes in order to play."))
		return FALSE

	var/rank = dreamvalley_tat_rank_for_bucket(build.get_role_bucket())
	var/datum/job/job = SSjob?.GetJob(rank)
	if(!rank || !job)
		to_chat(player, span_warning("That TAT direction does not have an Azure Peak spawn role yet."))
		return FALSE

	build.save_current_to_active_slot()
	preferences.ResetJobs()
	preferences.SetJobPreferenceLevel(job, JP_HIGH)
	preferences.topjob = rank
	preferences.dreamvalley_tat_join_pending = TRUE
	preferences.save_character()

	if(SSticker?.IsRoundInProgress())
		player.AttemptLateSpawn(rank)
		if(!QDELETED(player) && isnewplayer(player))
			preferences.dreamvalley_tat_join_pending = FALSE
		return TRUE

	if(SSticker && SSticker.current_state <= GAME_STATE_PREGAME)
		player.ready = PLAYER_READY_TO_PLAY
		to_chat(player, span_notice("Your [tat_role_bucket_display_name(build.get_role_bucket())] build is saved and ready. It will enter when the world starts."))
		player.new_player_panel()
		return TRUE

	preferences.dreamvalley_tat_join_pending = FALSE
	to_chat(player, span_warning("The world is not accepting new characters right now."))
	return FALSE

/proc/dreamvalley_get_tat_class(class_path)
	if(!class_path || !SSrole_class_handler)
		return null
	var/list/classes = SSrole_class_handler.sorted_class_categories[CTAG_ALLCLASS]
	for(var/datum/advclass/class as anything in classes)
		if(class.type == class_path)
			return class
	return null

/proc/dreamvalley_try_finish_tat_join(mob/living/carbon/human/human)
	var/datum/preferences/preferences = human?.client?.prefs
	if(!preferences?.dreamvalley_tat_join_pending)
		return FALSE

	// Consume before equipping so a failed or interrupted attempt cannot apply
	// the build to a later ordinary class selection.
	preferences.dreamvalley_tat_join_pending = FALSE
	var/datum/tat_build/build = preferences.dreamvalley_get_tat_build()
	if(!build?.can_save())
		to_chat(human, span_warning("Your saved TAT build is no longer valid. Choose a class to finish joining."))
		return FALSE

	var/class_path = build.get_tat_role_class_path(build.get_role_bucket())
	var/datum/advclass/tat_class/class = dreamvalley_get_tat_class(class_path)
	if(!class || !class.check_requirements(human))
		to_chat(human, span_warning("That TAT role cannot be applied. Choose a class to finish joining."))
		return FALSE

	if(human.mind)
		human.mind.picked_advclass = class
	class.equipme(human)
	human.invisibility = 0
	var/atom/movable/screen/advsetup/setup_button = locate() in human.hud_used?.static_inventory
	qdel(setup_button)
	human.cure_blind("advsetup")
	SSrole_class_handler.adjust_class_amount(class, 1)
	return TRUE
