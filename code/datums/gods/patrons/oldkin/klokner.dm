// Direct successor to Vheslyn, the old unplayable Archdevil (code/datums/gods/patrons/archdevil/archdevil.dm).
// DELIBERATE CHANGE per design brief: Vheslyn was preference_accessible = FALSE (unplayable, "there are no holy
// casters, there are no miracles"). Klokner is reframed as a barely-a-god boundary/lost-things figure and made
// PLAYABLE (preference_accessible = TRUE) since Old Kin is meant to be everyday accessible folk religion, not a
// fringe/villain cult. Mechanically this means Klokner gets an actual (if modest) miracle list and can_pray,
// unlike Vheslyn who had neither - there was no old mechanical baseline to carry over for a "real" worship path,
// so the miracle list below is assembled fresh from thematically-fitting existing spells, kept intentionally light
// per the "barely-a-god" concept.
/datum/patron/oldkin/klokner
	name = "Klokner"
	domain = "God of Boundaries, Lost Things, and the Answering Dark"
	desc = "Barely a god at all, by most accounts - more a shape you leave an offering for at the crossroads, the boundary-stone, the \
	threshold where one thing ends and another begins. Klokner is who you ask after when something is lost: a coin down a well, a \
	name nobody remembers anymore, a road that used to be there. Some say he's a kindly enough thing, so long as you knock and don't \
	trespass - a keeper of doors who returns what's owed if you're polite about asking. Others say what answers from the dark isn't \
	kind or cruel, just old and patient and endlessly willing to trade, and that not everything you get back from him comes back quite right."
	worshippers = "Wanderers, Well-Keepers, the Bereaved, and Crossroads-Folk"
	preference_accessible = TRUE // Deliberate change from Vheslyn's FALSE - Klokner is legitimate Old Kin folk religion, not an unplayable villain-god.
	undead_hater = FALSE
	mob_traits = list(TRAIT_DETACHED)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/locate_dead 				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal 					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/avert					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/fog_ward				= CLERIC_T2,
					/datum/action/cooldown/spell/klokner/threshold_ward			= CLERIC_T2,
					/datum/action/cooldown/spell/klokner/lost_and_found			= CLERIC_T3,
					/datum/action/cooldown/spell/klokner/echoing_dark			= CLERIC_T3,
					/datum/action/cooldown/spell/klokner/banish_beyond			= CLERIC_T4,
	)
	confess_lines = list(
		"SOMETHING ANSWERS FROM THE DARK.",
		"WHAT IS LOST IS NEVER TRULY GONE.",
		"I LEAVE MY OFFERING AT THE CROSSROADS.",
	)

	titles = list(
		"Keeper of the Threshold",
		"The Answering Dark",
		"Crossroads-Walker",
	)

// Near a crossroads-shrine, a well, or in liminal spaces - doorways, boundary stones, and the like.
/datum/patron/oldkin/klokner/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near wells - the classic "something lost down a well" rite.
	for(var/obj/structure/well/W in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer near a grave - another kind of threshold.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger(pick("...something is listening, but not here...", "...the dark does not answer at every threshold...")))
	return FALSE
