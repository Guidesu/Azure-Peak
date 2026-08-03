/**
 * tgui interface for examining skills, traits, charflaws, and languages.
 * Replaces the old to_chat-based output from the HUD skills button.
 */

/mob/living/proc/open_skills_traits_ui()
	return

/mob/living/carbon/human/open_skills_traits_ui()
	var/datum/skills_traits_ui/ui = new(src)
	ui.ui_interact(src)

/datum/skills_traits_ui
	var/mob/living/carbon/human/owner

/datum/skills_traits_ui/New(mob/living/carbon/human/H)
	owner = H

/datum/skills_traits_ui/Destroy()
	owner = null
	. = ..()

/datum/skills_traits_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsTraits", "Skills & Traits")
		ui.open()

/datum/skills_traits_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/skills_traits_ui/ui_data(mob/user)
	var/list/data = list()

	// --- Skills ---
	var/list/skills_list = list()
	if(owner?.skills)
		var/datum/skill_holder/SH = owner.skills
		var/list/shown_skills = list()
		for(var/datum/skill/S in SH.known_skills)
			if(SH.known_skills[S])
				shown_skills += S
		shown_skills = sortList(shown_skills, GLOBAL_PROC_REF(cmp_skills_for_display))
		for(var/datum/skill/S in shown_skills)
			var/skill_level = SH.known_skills[S]
			var/effective_cap = SH.get_effective_skill_cap(S)
			var/is_legendary = (skill_level >= SKILL_LEVEL_LEGENDARY)
			var/is_capped = !is_legendary && (skill_level >= effective_cap)

			var/percent = 0
			var/can_advance = FALSE
			var/can_advance_post = FALSE
			if(!is_capped && !is_legendary)
				if(skill_level >= SKILL_LEVEL_APPRENTICE)
					var/datum/sleep_adv/sadv = owner.mind?.sleep_adv
					if(sadv)
						var/sleep_xp = sadv.get_sleep_xp(S.type)
						var/needed_xp = sadv.get_requried_sleep_xp_for_skill(S.type, 1)
						if(needed_xp > 0)
							percent = clamp(round(sleep_xp * 100 / needed_xp), 0, 200)
						can_advance = sadv.enough_sleep_xp_to_advance(S.type, 1)
						can_advance_post = sadv.enough_sleep_xp_to_advance(S.type, 2)
				else
					var/list/brackets = SH.get_xp_brackets(skill_level)
					var/current_xp = SH.skill_experience[S]
					var/bracket_start = brackets[1]
					var/bracket_end = brackets[2]
					var/bracket_range = bracket_end - bracket_start
					if(bracket_range > 0)
						percent = clamp(round((current_xp - bracket_start) * 100 / bracket_range), 0, 100)

			skills_list += list(list(
				"name" = "[S]",
				"desc" = S.desc,
				"level" = SSskills.level_names_plain[skill_level],
				"level_num" = skill_level,
				"xp_percent" = percent,
				"capped" = is_capped,
				"legendary" = is_legendary,
				"can_advance" = can_advance,
				"can_advance_post" = can_advance_post,
				"color" = S.color,
				"trait_gated" = (S.max_untraited_level < SKILL_LEVEL_LEGENDARY),
				"trait_uncap" = S.trait_uncap,
			))
	data["skills"] = skills_list

	// --- Character Flaws ---
	var/list/flaws_list = list()
	if(owner?.charflaws?.len)
		for(var/datum/charflaw/cf in owner.charflaws)
			var/datum/charflaw/addiction/ad_cf = null
			if(istype(cf, /datum/charflaw/addiction))
				ad_cf = cf
			flaws_list += list(list(
				"name" = cf.name,
				"desc" = cf.desc,
				"sated" = ad_cf ? ad_cf.sated : null,
			))
	data["charflaws"] = flaws_list

	// --- Languages ---
	var/list/langs_list = list()
	if(owner?.mind?.language_holder)
		for(var/X in owner.mind.language_holder.languages)
			if(!X || !ispath(X, /datum/language))
				continue
			var/datum/language/LA = new X()
			langs_list += list(list(
				"name" = LA.name,
				"key" = LA.key,
			))
			qdel(LA)
	data["languages"] = langs_list

	// --- Traits ---
	var/list/traits_list = list()
	if(owner)
		for(var/X in GLOB.roguetraits)
			if(HAS_TRAIT(owner, X))
				// Strip HTML spans for tgui display
				var/desc_text = GLOB.roguetraits[X]
				traits_list += list(list(
					"name" = "[X]",
					"desc" = desc_text,
				))
	data["traits"] = traits_list

	return data

/datum/skills_traits_ui/ui_close(mob/user)
	qdel(src)
