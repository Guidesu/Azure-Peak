// NOTE ON NAMING: this decree's display name was formerly "The Zenitstadt Concordat" - kept as the DM symbol/define/id
// for minimal blast radius (see DECREE_ZENITSTADT_CONCORDAT, referenced from banking.dm, treasury.dm,
// treasury_snapshot.dm, fund_api.dm, and ATM.dm), but renamed at the player-facing layer to "The Zenitstadt Compact"
// once "the Concordat" became the proper name of the Auxentius/Miluše/Wulfric/Morwenna/Viator/Handwerra pantheon.
// A church charter literally titled "The [City] Concordat" would read as an official pantheon document rather than
// a local tax-exemption pact between one city's clergy and its Crown - "Compact" sidesteps the collision while still
// echoing the Vaeltis Compact's own terminology, which reads naturally for a lesser, local charter modeled after it.
/datum/decree/zenitstadt_concordat
	id = DECREE_ZENITSTADT_CONCORDAT
	name = "The Zenitstadt Compact"
	category = DECREE_CATEGORY_ANCIENT
	mechanical_text = "Church clergy and declared Benefactors of the Faith pay no taxes."
	flavor_text = {"This Zenitstadt Compact, sworne under the Six Seats' Grace and with Auxentius as witness, witnesseth that the Church, consecrated beneath the Concordat and quickened by Auxentius's light, shall keep the peace of the gods upon this land: to pray for the safety and prosperity of the outpost by daye and by night, to maintain the favor of the Six through proper sacrament and offering, to levy tithe from amongst its own brethren, to shelter the poor and downtrodden, and to furnish its own knightly order of templars that the common defense be not wanting.

In exchange, as the sacred envoys of the gods and sworn servants of the Six, the clergy of the Church shall bear no tax nor levy, neither upon their persons nor upon the properties of the Faith; nor shall the ruling seat intrude upon the internal discipline of the Church, save by lawful counsel taken with the Church of the Six.

Yeven under the old seal, in witness of the Six."}
	revoke_text = "The %RULER% has rescinded the Zenitstadt Compact. The Church's wealth shall serve the greater good of the outpost - let the Six judge who betrayed whom."
	restore_text = "The %RULER% has affirmed the Zenitstadt Compact. No hand shall meddle further in the disposition of the Church's worldly wealth."

/datum/decree/zenitstadt_concordat/roll_initial_year()
	return CALENDAR_EPOCH_YEAR - rand(50, 120)

/datum/decree/zenitstadt_concordat/apply_exemption(mob/living/payer, tax_category)
	if(!active)
		return FALSE
	if(payer.job in GLOB.church_positions)
		return TRUE
	if(HAS_TRAIT(payer, TRAIT_AGENT_CHURCH))
		return TRUE
	return FALSE
