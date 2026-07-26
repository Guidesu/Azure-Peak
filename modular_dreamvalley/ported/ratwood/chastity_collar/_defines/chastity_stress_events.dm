/**
 * Chastity mood stress events — chastity_collar port, Stage 1. Referenced by refresh_chastity_mood_effects()
 * in chastity_core.dm. Follows the /datum/stressevent pattern used elsewhere in this repo
 * (see code/datums/sexcon2/sex_stress.dm and code/datums/stress/negative_events.dm for precedent).
 */

/datum/stressevent/chastity_devout
	timer = 20 MINUTES
	stressadd = -2
	desc = span_notice("My vow is sealed in iron. I keep faith with what was asked of me.")

/datum/stressevent/chastity_masochist
	timer = 15 MINUTES
	stressadd = -3
	desc = span_love("Every bite of the spikes is its own perverse reward.")

/datum/stressevent/chastity_church
	timer = 20 MINUTES
	stressadd = -1
	desc = span_notice("My station demands this discipline of me, and I bear it gladly.")

/datum/stressevent/chastity_frustration
	timer = 10 MINUTES
	stressadd = 4
	desc = span_red("Locked up and utterly denied. I can't stop thinking about it.")

/datum/stressevent/chastity_flat_cramped
	timer = 10 MINUTES
	stressadd = 3
	desc = span_red("The flat cage crushes me into an unbearably cramped shape.")
