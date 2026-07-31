/datum/decree/great_writ
	id = DECREE_GREAT_WRIT
	name = "The Great Writ"
	category = DECREE_CATEGORY_ANCIENT
	mechanical_text = "Nobles pay no taxes nor fines."
	flavor_text = {"This Great Writ, pronounced under Auxentius's Sun and with his Law as witness, declareth that the nobility of this land, and the blue blood of foreign realms sojourning within it, being of lineage blessed by Auxentius's grace, shall bear no tax nor levy upon their persons or estates.

In return, the nobles of this land shall undertake the duty of arms - to defend it in their own person and with their retainers, to answer the call to war in whatsoever hour it cometh, and to render the fealty that is owed by blood and by oath.

Yeven under the old seal, in witness of the Six."}
	revoke_text = "The %RULER% has set aside the Great Writ. The nobility shall contribute their share, in both blood and gold - let no lineage be too blessed to pay."
	restore_text = "The %RULER% has renewed the Great Writ. The blue blood of this land is freed again from the levy, that the nobility may serve in arms, not in coin."

/datum/decree/great_writ/roll_initial_year()
	return CALENDAR_EPOCH_YEAR - rand(100, 200)

/datum/decree/great_writ/apply_exemption(mob/living/payer, tax_category)
	if(!active)
		return FALSE
	if(HAS_TRAIT(payer, TRAIT_NOBLE))
		return TRUE
	return FALSE
