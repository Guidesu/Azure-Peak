#define BOND_SPOUSE_M "Spouse (M)"
#define BOND_SPOUSE_F "Spouse (F)"
#define BOND_ADOPTED_SON "Adopted Son"
#define BOND_ADOPTED_DAUGHTER "Adopted Daughter"
#define BOND_BROTHER "Brother"
#define BOND_SISTER "Sister"

/proc/bond_type_display(bond_type)
	switch(bond_type)
		if(BOND_SPOUSE_M)
			return ""
		if(BOND_SPOUSE_F)
			return ""
		if(BOND_ADOPTED_SON)
			return " "
		if(BOND_ADOPTED_DAUGHTER)
			return " "
		if(BOND_BROTHER)
			return ""
		if(BOND_SISTER)
			return ""
	return bond_type

/proc/bond_type_instrumental(bond_type)
	switch(bond_type)
		if(BOND_SPOUSE_M)
			return ""
		if(BOND_SPOUSE_F)
			return ""
		if(BOND_ADOPTED_SON)
			return " "
		if(BOND_ADOPTED_DAUGHTER)
			return " "
		if(BOND_BROTHER)
			return ""
		if(BOND_SISTER)
			return ""
	return bond_type

/proc/bond_type_is_marriage(bond_type)
	return (bond_type == BOND_SPOUSE_M || bond_type == BOND_SPOUSE_F)

/proc/bond_type_is_adoption(bond_type)
	return (bond_type == BOND_ADOPTED_SON || bond_type == BOND_ADOPTED_DAUGHTER)

/proc/bond_type_is_sibling(bond_type)
	return (bond_type == BOND_BROTHER || bond_type == BOND_SISTER)

#define FAMILYTREE_BOND_RANGE 7

/proc/familytree_priest_can_perform_bond(mob/living/carbon/human/priest)
	if(!priest?.devotion || !priest.patron)
		return FALSE
	if(istype(priest.patron, /datum/patron/divine/eora))
		return TRUE
	if(istype(priest.patron, /datum/patron/divine/astrata))
		return priest.devotion.level >= CLERIC_T3
	if(istype(priest.patron, /datum/patron/inhumen/zizo))
		return priest.devotion.level >= CLERIC_T3
	return FALSE

/mob/living/carbon/human/proc/familytree_establish_bond()
	set name = "Establish Bond"
	set category = "Cleric"
	set desc = "      ."

	var/mob/living/carbon/human/priest = src
	if(!priest.mind || !priest.client)
		return

	if(!familytree_priest_can_perform_bond(priest))
		to_chat(priest, span_warning("            ."))
		return

	if(priest.stat != CONSCIOUS)
		to_chat(priest, span_warning("     ."))
		return

	SSfamilytree.ftlog("ESTABLISH_BOND cast by [priest.real_name] ([priest.ckey])")

	var/holy_level = priest.get_skill_level(/datum/skill/magic/holy)
	var/can_bypass = (holy_level >= SKILL_LEVEL_LEGENDARY)

	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(FAMILYTREE_BOND_RANGE, priest))
		if(H == priest || H.stat == DEAD || !H.client || !H.ckey)
			continue
		candidates += H

	if(candidates.len < 2)
		to_chat(priest, span_warning("     ."))
		return

	var/mob/living/carbon/human/person1 = tgui_input_list(priest, "      ?", "Establish Bond", candidates)
	if(!person1 || QDELETED(person1) || !(person1 in view(FAMILYTREE_BOND_RANGE, priest)))
		return

	var/list/bond_options = list(
		BOND_SPOUSE_M,
		BOND_SPOUSE_F,
		BOND_ADOPTED_SON,
		BOND_ADOPTED_DAUGHTER,
		BOND_BROTHER,
		BOND_SISTER,
	)

	var/bond_type = tgui_input_list(priest, "[person1.real_name] :", "Bond Type", bond_options)
	if(!bond_type)
		return

	candidates -= person1

	var/list/valid_second = list()
	for(var/mob/living/carbon/human/candidate in candidates)
		if(can_bypass)
			valid_second += candidate
			continue
		if(bond_type_is_marriage(bond_type))
			if(SSfamilytree.GetSpeciesCompatibilityFailureReason(person1, candidate))
				continue
			if(!familytree_estates_compatible(person1, candidate))
				continue
			if(!familytree_role_tiers_compatible(person1, candidate))
				continue
			if(!familytree_polygamy_compatible(person1, candidate))
				continue
		else
			if(SSfamilytree.is_isolated(person1) || SSfamilytree.is_isolated(candidate))
				if(person1.dna?.species?.type != candidate.dna?.species?.type)
					continue
		valid_second += candidate

	if(!valid_second.len)
		to_chat(priest, span_warning("  ."))
		return

	var/mob/living/carbon/human/person2 = tgui_input_list(priest, "   ?", "Establish Bond", valid_second)
	if(!person2 || QDELETED(person2) || !(person2 in view(FAMILYTREE_BOND_RANGE, priest)) || !(person1 in view(FAMILYTREE_BOND_RANGE, priest)))
		return

	if(bond_type_is_marriage(bond_type) && person1.spouse_mob == person2)
		to_chat(priest, span_warning("    ."))
		return

	if(!can_bypass && bond_type_is_marriage(bond_type) && !familytree_polygamy_compatible(person1, person2))
		to_chat(priest, span_warning("‡°‚ µ ‚‹  ‚° ±°."))
		return

	var/instr = bond_type_instrumental(bond_type)

	var/priest_confirm = tgui_alert(priest, "[person1.real_name]  [instr] [person2.real_name].  ?", "Establish Bond", list("", ""))
	if(priest_confirm != "")
		return

	if(!(person1 in view(FAMILYTREE_BOND_RANGE, priest)) || !(person2 in view(FAMILYTREE_BOND_RANGE, priest)))
		to_chat(priest, span_warning(" ."))
		return

	var/offer1 = tgui_alert(person1, "  [instr] [person2.real_name]. ?", " ", list("", ""))
	if(offer1 != "")
		to_chat(priest, span_warning("[person1.real_name] ()."))
		return

	var/offer2 = tgui_alert(person2, "[person1.real_name]  () [instr]. ?", " ", list("", ""))
	if(offer2 != "")
		to_chat(priest, span_warning("[person2.real_name] ()."))
		return

	if(!(person1 in view(FAMILYTREE_BOND_RANGE, priest)) || !(person2 in view(FAMILYTREE_BOND_RANGE, priest)))
		to_chat(priest, span_warning(" ."))
		return

	var/success = FALSE

	if(bond_type_is_marriage(bond_type))
		var/datum/heritage/family = person1.MarryTo(person2)
		if(family)
			success = TRUE
			SSfamilytree.on_family_formed(family)

	else if(bond_type_is_adoption(bond_type))
		success = familytree_holy_adopt(person1, person2)

	else if(bond_type_is_sibling(bond_type))
		success = familytree_holy_sibling(person1, person2)

	if(!success)
		to_chat(priest, span_warning("   ."))
		return

	var/announcement = "[priest.real_name] () : [person1.real_name]  [instr] [person2.real_name]."
	for(var/mob/living/carbon/human/M in view(FAMILYTREE_BOND_RANGE, priest))
		to_chat(M, span_love(announcement))

#define FAMILYTREE_DIVORCE_RANGE 7

/mob/living/carbon/human/proc/familytree_dissolve_marriage()
	set name = "Dissolve Marriage"
	set category = "Cleric"
	set desc = "   ."

	var/mob/living/carbon/human/priest = src
	if(!priest.mind || !priest.client)
		return

	if(!familytree_priest_can_perform_bond(priest))
		to_chat(priest, span_warning("            ."))
		return

	if(priest.stat != CONSCIOUS)
		to_chat(priest, span_warning("     ."))
		return

	SSfamilytree.ftlog("DISSOLVE_MARRIAGE cast by [priest.real_name] ([priest.ckey])")

	var/list/married_people = list()
	for(var/mob/living/carbon/human/H in view(FAMILYTREE_DIVORCE_RANGE, priest))
		if(H == priest || H.stat == DEAD || !H.client || !H.ckey)
			continue
		if(H.spouse_mob && H.family_member_datum?.get_spouse_members().len)
			married_people += H

	if(!married_people.len)
		to_chat(priest, span_warning("  ,   ."))
		return

	var/mob/living/carbon/human/person1 = tgui_input_list(priest, "  ?", "Dissolve Marriage", married_people)
	if(!person1 || QDELETED(person1) || !(person1 in view(FAMILYTREE_DIVORCE_RANGE, priest)))
		return

	var/mob/living/carbon/human/person2 = person1.spouse_mob
	if(!person2 || QDELETED(person2) || !(person2 in view(FAMILYTREE_DIVORCE_RANGE, priest)))
		to_chat(priest, span_warning("() ()  ."))
		return

	var/confirm1 = tgui_alert(person1, "     [person2.real_name]?", "Dissolve Marriage", list("", ""))
	if(confirm1 != "")
		to_chat(priest, span_warning("[person1.real_name]  () ."))
		return

	var/confirm2 = tgui_alert(person2, "     [person1.real_name]?", "Dissolve Marriage", list("", ""))
	if(confirm2 != "")
		to_chat(priest, span_warning("[person2.real_name]  () ."))
		return

	if(!(person1 in view(FAMILYTREE_DIVORCE_RANGE, priest)) || !(person2 in view(FAMILYTREE_DIVORCE_RANGE, priest)))
		to_chat(priest, span_warning(" ."))
		return

	var/datum/family_member/member1 = person1.family_member_datum
	var/datum/family_member/member2 = person2.family_member_datum

	if(member1 && member2)
		member1.RemoveSpouse(member2, TRUE)

	person1.spouse_mob = null
	person2.spouse_mob = null

	var/announcement = "[priest.real_name] ()   [person1.real_name]  [person2.real_name]."
	for(var/mob/living/carbon/human/M in view(FAMILYTREE_DIVORCE_RANGE, priest))
		to_chat(M, span_warning(announcement))

/proc/familytree_holy_adopt(mob/living/carbon/human/child, mob/living/carbon/human/parent)
	if(!child || !parent)
		return FALSE

	if(!parent.family_datum)
		var/datum/heritage/new_family = new /datum/heritage(parent, null)
		parent.family_datum = new_family
		SSfamilytree.register_family(new_family)

	var/datum/family_member/parent_member = parent.family_member_datum
	if(!parent_member)
		return FALSE

	var/datum/family_member/coparent_member = familytree_get_ritual_adoptive_coparent(parent_member, child)
	parent.family_datum.AddToFamily(child, parent_member, coparent_member, TRUE)
	return (child.family_datum != null)

/proc/familytree_holy_sibling(mob/living/carbon/human/person1, mob/living/carbon/human/person2)
	if(!person1 || !person2)
		return FALSE

	var/mob/living/carbon/human/new_sibling = person1
	var/mob/living/carbon/human/anchor_person = person2
	var/datum/heritage/target_house = person2.family_datum
	if(!target_house && person1.family_datum)
		target_house = person1.family_datum
		new_sibling = person2
		anchor_person = person1

	if(!target_house)
		target_house = new /datum/heritage(person2, null)
		person2.family_datum = target_house
		SSfamilytree.register_family(target_house)

	var/datum/family_member/existing_member = anchor_person.family_member_datum
	if(!existing_member)
		return FALSE

	var/datum/family_member/new_member = target_house.GetFamilyMember(new_sibling)
	if(!new_member)
		new_member = target_house.CreateFamilyMember(new_sibling)
	if(!new_member)
		return FALSE

	return new_member.AddSwornSibling(existing_member)

