// Ported from Twilight-Axis's modular_twilight_axis/firearms module
// (code/datums/skills.dm + code/datums/components.dm merged into one file
// since both are tiny). No player-facing text needed translation.
//
// TRAIT_FIREARMS_MARKSMAN is defined here (added to code/__DEFINES/traits.dm
// as part of this port, since it did not previously exist in this repo).

/datum/skill/combat/twilight_firearms
	name = "Firearms"
	desc = "Increases reload speed and reduces the time it takes to aim gunpowder weapons. At Master or Legendary level, completely nullifies the chance to burn oneself when firing."
	dreams = list(
	"...«cannons at the ready!», you hear the deckmaster shout, as your galleon is gaining on the enemy warship. Your comrades-in-arms slide the huge artillery piece forward, its monstrous barrel already loaded with a cannonball, while you ignite your torch, holding it near the fuse, waiting for the order to fire...",
	"...motionless, you lay in the tall grass, your arquebus aimed at the passing caravan's guard. Covering your right ear with your shoulder, you steadily breathe out, gently pushing the trigger...",
	"...the line of grenadiers fires their guns, the sound of gunshots just barely bearable thanks to you covering your ears moments earlier. The enemies fall by the dozens, yet more of them continue their advance. «Fix bayonets!», you command to your men, drawing your own kriegsmesser from its sheath. «For the Empire, charge!..»"
	)
	max_untraited_level = SKILL_LEVEL_EXPERT
	trait_uncap = list(TRAIT_FIREARMS_MARKSMAN = SKILL_LEVEL_LEGENDARY)

/obj/effect/proc_holder/spell/invoked/takeapprentice/Initialize()
	. = ..()
	traits_to_skills += list(
		TRAIT_FIREARMS_MARKSMAN = list(
			/datum/skill/combat/twilight_firearms
		)
	)

/datum/component/storage/concrete/roguetown/belt/holster_belt
	screen_max_rows = 2
	screen_max_columns = 2
