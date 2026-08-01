// Merge of the old Auxentius (sun, order) and Auxentius (justice, glory, battle) - the Concordat's godhead.
/datum/patron/concordat/auxentius
	name = "Auxentius"
	domain = "God of the Sun, Law, Oaths, and Kingship"
	desc = "First among equals of the Court of Six Seats, Auxentius is called the Sun's Law made flesh - the light that keeps order and the sword that enforces it. \
	Some magistrates and knights alike swear that a war fought under his gaze protects the realm; that his law is a shield raised over hearth and kingdom both. \
	Others say his light is the tyrant's light, a glare that finds no shadow innocent, and that his oath-bound justice serves the crown before it serves the wronged. \
	Both readings kneel before the same sun."
	worshippers = "Zealots, Farmers, Warriors, Sellswords, and those who swear or seek Justice"
	mob_traits = list(TRAIT_APRICITY, TRAIT_SHARPER_BLADES)
	traits_tier = list(TRAIT_BATTLEMASTER = CLERIC_T1, TRAIT_JUSTICARSIGHT = CLERIC_T3)
	miracles = list(/datum/action/cooldown/spell/touch/orison				= CLERIC_ORI,
					/datum/action/cooldown/spell/miracle/ignition/auxentius	= CLERIC_T0,
					/datum/action/cooldown/spell/auxentius/battle/tug					= CLERIC_T0,
					/datum/action/cooldown/spell/auxentius/battle/provocation	       	= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal		 		= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle		= CLERIC_T1,
					/datum/action/cooldown/spell/auxentius/auxentian_gaze		= CLERIC_T1,
					/datum/action/cooldown/spell/auxentius/battle/strikeoraegis		= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/sacred_flame	= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/fortify/auxentius	= CLERIC_T2,
					/datum/action/cooldown/spell/auxentius/battle/withstand		   	= CLERIC_T2,
					/datum/action/cooldown/spell/auxentius/battle/challenge			= CLERIC_T2,
					/datum/action/cooldown/spell/auxentius/miracle_pyre    	= CLERIC_T3,
					/datum/action/cooldown/spell/auxentius/firecloak		    = CLERIC_T3,
					/datum/action/cooldown/spell/auxentius/battle/persistence			= CLERIC_T3,
					/datum/action/cooldown/spell/auxentius/battle/battlecry			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/revive			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/immolation		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/auxentius	= CLERIC_T4,
	)
	confess_lines = list(
		"AUXENTIUS IS MY LIGHT!",
		"AUXENTIUS BRINGS LAW!",
		"THROUGH STRIFE, GRACE! THROUGH PERSISTENCE, GLORY!",
		"I SERVE THE GLORY OF THE SUN AND THE JUSTICE OF HIS SWORD!",
	)
	storyteller = /datum/storyteller/auxentius
	COOLDOWN_DECLARE(lesser_heal_buff_cooldown)
	titles = list(
		"Sun Lord",
		"Sun", // should match any sort of Sun(x) title
		"Justiciar",
		"Justicar", // it is misspelled ingame enough that we should probably accept this too
		"Tyrant",
		"Overtyrant",
	)

// In daylight, church, cross, ritual chalk, or near a knight's statue.
/datum/patron/concordat/auxentius/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer during daytime if outside.
	if(istype(get_area(follower), /area/rogue/outdoors) && (GLOB.tod == "day" || GLOB.tod == "dawn"))
		return TRUE
	// Allows prayer near any knight statue and its subtypes.
	for(var/obj/structure/fluff/statue/knight/K in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Auxentius to hear my prayer I must either be in his blessed daylight, within the church, near a psycross, or near a knightly statue in memorium of the fallen.."))
	return FALSE

/datum/patron/concordat/auxentius/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A wreath of gentle light passes over [target]!")
	*message_self = ("I'm bathed in holy light!")

	var/bonus = 0

	if(GLOB.tod == "day")
		bonus += 2

	if(HAS_TRAIT(target, TRAIT_NOBLE)) //We heal her favorites more.
		bonus += 2.5

	if(istype(target.rmb_intent, /datum/rmb_intent/strong))
		bonus += 1

	if(istype(target.get_active_held_item(), /obj/item/rogueweapon))
		bonus += 0.5

	if(target == user && target.blood_volume <= BLOOD_VOLUME_OKAY && COOLDOWN_FINISHED(src, lesser_heal_buff_cooldown))
		user.emote("warcry")
		user.blood_volume += BLOOD_VOLUME_SURVIVE / 3
		bonus += 2
		COOLDOWN_START(src, lesser_heal_buff_cooldown, 30 SECONDS)

	if(!bonus)
		return

	*conditional_buff = TRUE
	*situational_bonus = bonus
