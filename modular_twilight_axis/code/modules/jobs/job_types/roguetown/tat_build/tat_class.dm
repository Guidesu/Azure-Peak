/proc/get_client_active_tat_build(client/C)
	if(!C?.prefs)
		return null

	return C.prefs.tat_build

/proc/client_can_use_tat_role_bucket(client/C, required_bucket)
	if(!required_bucket)
		return TRUE

	if(!C?.ckey)
		return FALSE

	if(tat_is_role_bucket_locked(C.ckey, required_bucket))
		return FALSE

	return TRUE

/proc/human_can_use_tat_role_bucket(mob/living/carbon/human/H, required_bucket)
	if(!required_bucket)
		return TRUE

	if(!H)
		return FALSE

	var/key = H.ckey || H.client?.ckey
	if(!key)
		return FALSE

	if(tat_is_role_bucket_locked(key, required_bucket))
		return FALSE

	return TRUE

/proc/client_has_tat_role_bucket(client/C, required_bucket)
	if(!required_bucket)
		return TRUE

	if(!client_can_use_tat_role_bucket(C, required_bucket))
		return FALSE

	var/datum/tat_build/build = get_client_active_tat_build(C)
	if(!build)
		return FALSE

	if(!build.can_save())
		return FALSE

	return build.get_role_bucket() == required_bucket

/proc/tat_build_has_role_bucket(datum/tat_build/build, required_bucket)
	if(!required_bucket)
		return TRUE

	if(!build)
		return FALSE

	if(!build.can_save())
		return FALSE

	return build.get_role_bucket() == required_bucket

/proc/human_has_tat_role_bucket(mob/living/carbon/human/H, required_bucket)
	if(!required_bucket)
		return TRUE

	if(!human_can_use_tat_role_bucket(H, required_bucket))
		return FALSE

	if(H?.active_tat_build)
		return tat_build_has_role_bucket(H.active_tat_build, required_bucket)

	if(!H?.client)
		return FALSE

	return client_has_tat_role_bucket(H.client, required_bucket)

/proc/get_human_active_tat_build(mob/living/carbon/human/H)
	if(!H)
		return null

	if(H.client)
		H.active_tat_build = get_client_active_tat_build(H.client)

	return H.active_tat_build

/mob/living/carbon/human
	var/datum/tat_build/active_tat_build = null
	var/tat_build_pre_client_applied = FALSE
	var/tat_build_post_client_applied = FALSE

/datum/advclass/tat_class
	name = "Free Soul"
	tutorial = "A freeform class used for the TAT build system."

	allowed_sexes = list(MALE, FEMALE)

	outfit = /datum/outfit/job/roguetown/tat_class/basic

	subclass_stats = list()
	subclass_skills = list()
	traits_applied = list()

/datum/advclass/tat_class/check_requirements(mob/living/carbon/human/H)
	var/key = H?.ckey || H?.client?.ckey
	if(key)
		tat_refresh_ban_cache_for_ckey(key)

	if(!..())
		return FALSE

	return TRUE

/datum/advclass/tat_class/equipme(mob/living/carbon/human/H, dummy = FALSE)
	if(!H)
		return FALSE

	if(!dummy)
		H.tat_handles_preference_loadout = TRUE
		H.tat_free_soul_title = name
		get_human_active_tat_build(H)

	return ..()

/datum/outfit/job/roguetown/tat_class
	name = "Free Soul"

/datum/outfit/job/roguetown/tat_class/basic/pre_equip(mob/living/carbon/human/H)
	..()

/datum/outfit/job/roguetown/tat_class/basic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(!H || !H.mind)
		return

	apply_tat_build_pre_client(H)

/datum/outfit/job/roguetown/tat_class/basic/proc/apply_tat_build_pre_client(mob/living/carbon/human/H)
	if(!H || !H.mind)
		return

	if(H.tat_build_pre_client_applied)
		addtimer(CALLBACK(src, PROC_REF(apply_tat_build_post_client), H), 10)
		return

	var/datum/tat_build/build = get_human_active_tat_build(H)
	if(!build)
		addtimer(CALLBACK(src, PROC_REF(apply_tat_build_pre_client), H), 10)
		return

	if(!build.can_save())
		return

	if(!build.apply_pre_client_to_human(H))
		return

	H.tat_build_pre_client_applied = TRUE

	addtimer(CALLBACK(src, PROC_REF(apply_tat_build_post_client), H), 10)

/datum/outfit/job/roguetown/tat_class/basic/proc/apply_tat_build_post_client(mob/living/carbon/human/H)
	if(!H || !H.mind)
		return

	if(H.tat_build_post_client_applied)
		return

	if(!H.client)
		addtimer(CALLBACK(src, PROC_REF(apply_tat_build_post_client), H), 10)
		return

	var/datum/tat_build/build = get_human_active_tat_build(H)
	if(!build)
		return

	if(!build.can_save())
		return

	if(!build.apply_post_client_to_human(H))
		return

	H.tat_build_post_client_applied = TRUE
	var/final_title = H.tat_free_soul_title || H.advjob || H.mind.assigned_role
	if(H.job == "Towner" && length(final_title))
		SSrole_class_handler.add_class_register_msg("towner", "[H.real_name] is the [final_title]", H)
