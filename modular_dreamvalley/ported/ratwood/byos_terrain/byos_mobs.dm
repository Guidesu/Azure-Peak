// Mobs for byos.dmm. Ported from Ratwood-2.0 code/modules/mob/living/carbon/simple_animal/rogue/creacher/dragger.dm.
// Note: /mob/living/carbon/simple_animal/pet/cat/inn is NOT ported here — it already exists
// implicitly in this codebase (code/modules/mob/living/carbon/simple_animal/friendly/cat.dm
// defines an /attack_hand override directly on that path with no explicit parent
// declaration), exactly as it does upstream, so DM's implicit type creation already
// gives it a real definition with no vars — the map's direct placement compiles as-is.

/mob/living/carbon/simple_animal/hostile/rogue/dragger/flesh
	name = "FLESH HOMUNCULUS"
	desc = null
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/flesh.dmi'
	icon_state = "FLESH"
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	maxHealth = 666
	health = 666
	melee_damage_lower = 33
	melee_damage_upper = 66
	STACON = 15
	STASTR = 16
	STASPD = 2
	STAWIL = 16
	pixel_x = 0
