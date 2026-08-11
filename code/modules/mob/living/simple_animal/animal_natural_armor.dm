/// Natural armor values for simple animals.
///
/// This system uses TWO complementary approaches, both inspired by
/// CEV-Eris's superior_animal per-bodypart armor design:
///
/// 1. **Bodypart reduction (Eris-style)**: Sets `brute_reduction` and
///    `burn_reduction` on the animal's bodyparts in Initialize(). This
///    is flat damage reduction — subtracted from incoming damage before
///    it hits the limb. A bear's chest might have brute_reduction = 10,
///    meaning 10 brute damage is subtracted from every hit to the chest.
///
/// 2. **Armor rating (armor-list-style)**: Sets `natural_armor` list
///    mapping BODY_ZONE_* -> armor list (same format as ARMOR_* defines).
///    This provides tier-based damage reduction via getarmor(), working
///    alongside barding armor.
///
/// Both are applied: bodypart reduction first (flat subtract), then
/// armor rating (tier-based block/DR). This gives animals both
/// "thick hide absorbs X damage" and "scales block slashing tier Y".
///
/// Zones: BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
///        BODY_ZONE_L_LEG, BODY_ZONE_R_LEG

// ---------------------------------------------------------------------------
// Bodypart reduction presets (Eris-style flat reduction)
// ---------------------------------------------------------------------------

/// Brute/burn reduction values per bodypart preset.
/// Format: list(BODY_ZONE_* = list(brute = N, burn = N))

/// Thick hide — bear, minotaur. High brute reduction on chest, less on limbs.
#define ANIMAL_BP_THICK_HIDE list( \
	BODY_ZONE_HEAD = list(brute = 3, burn = 2), \
	BODY_ZONE_CHEST = list(brute = 12, burn = 5), \
	BODY_ZONE_L_ARM = list(brute = 6, burn = 3), \
	BODY_ZONE_R_ARM = list(brute = 6, burn = 3), \
	BODY_ZONE_L_LEG = list(brute = 6, burn = 3), \
	BODY_ZONE_R_LEG = list(brute = 6, burn = 3), \
)

/// Tough hide — wolf, boar. Moderate reduction everywhere.
#define ANIMAL_BP_TOUGH_HIDE list( \
	BODY_ZONE_HEAD = list(brute = 2, burn = 1), \
	BODY_ZONE_CHEST = list(brute = 8, burn = 3), \
	BODY_ZONE_L_ARM = list(brute = 4, burn = 2), \
	BODY_ZONE_R_ARM = list(brute = 4, burn = 2), \
	BODY_ZONE_L_LEG = list(brute = 4, burn = 2), \
	BODY_ZONE_R_LEG = list(brute = 4, burn = 2), \
)

/// Stone skin — troll, golem. Very high brute, no burn protection (weak to fire).
#define ANIMAL_BP_STONE_SKIN list( \
	BODY_ZONE_HEAD = list(brute = 5, burn = 0), \
	BODY_ZONE_CHEST = list(brute = 15, burn = 0), \
	BODY_ZONE_L_ARM = list(brute = 10, burn = 0), \
	BODY_ZONE_R_ARM = list(brute = 10, burn = 0), \
	BODY_ZONE_L_LEG = list(brute = 10, burn = 0), \
	BODY_ZONE_R_LEG = list(brute = 10, burn = 0), \
)

/// Dragon scales — dragon. High brute and burn reduction everywhere.
#define ANIMAL_BP_DRAGON_SCALES list( \
	BODY_ZONE_HEAD = list(brute = 8, burn = 10), \
	BODY_ZONE_CHEST = list(brute = 20, burn = 15), \
	BODY_ZONE_L_ARM = list(brute = 12, burn = 10), \
	BODY_ZONE_R_ARM = list(brute = 12, burn = 10), \
	BODY_ZONE_L_LEG = list(brute = 12, burn = 10), \
	BODY_ZONE_R_LEG = list(brute = 12, burn = 10), \
)

// ---------------------------------------------------------------------------
// Armor rating presets (tier-based, same format as ARMOR_* defines)
// ---------------------------------------------------------------------------

/// Thick hide — like a bear or large beast. Good blunt, decent slash, weak stab.
#define ANIMAL_ARMOR_THICK_HIDE list( \
	"blunt" = DR_SUPER, \
	"slash" = DBLOCK_MEDIUM, \
	"stab" = DBLOCK_LIGHT, \
	"piercing" = DBLOCK_LIGHT, \
	"fire" = DR_LIGHT \
)

/// Tough hide — like a boar or wolf. Moderate protection.
#define ANIMAL_ARMOR_TOUGH_HIDE list( \
	"blunt" = DR_HEAVY, \
	"slash" = DBLOCK_LIGHT, \
	"stab" = DBLOCK_LIGHT, \
	"piercing" = DBLOCK_NONE, \
	"fire" = DR_NONE \
)

/// Stone skin — like a troll or golem. Excellent blunt, good slash, weak to fire.
#define ANIMAL_ARMOR_STONE_SKIN list( \
	"blunt" = DR_SUPER, \
	"slash" = DBLOCK_HEAVY, \
	"stab" = DBLOCK_MEDIUM, \
	"piercing" = DBLOCK_MEDIUM, \
	"fire" = DR_NONE \
)

/// Dragon scales — excellent all-around, especially vs fire.
#define ANIMAL_ARMOR_DRAGON_SCALES list( \
	"blunt" = DR_SUPER, \
	"slash" = DBLOCK_HEAVY, \
	"stab" = DBLOCK_HEAVY, \
	"piercing" = DBLOCK_HEAVY, \
	"fire" = DR_SUPER \
)

/// Vulnerable head — most animals have less protection on the head.
#define ANIMAL_ARMOR_VULNERABLE_HEAD list( \
	"blunt" = DR_LIGHT, \
	"slash" = DBLOCK_LIGHT, \
	"stab" = DBLOCK_NONE, \
	"piercing" = DBLOCK_NONE, \
	"fire" = DR_NONE \
)

/// Exposed limbs — legs/arms of beasts that aren't well-protected.
#define ANIMAL_ARMOR_EXPOSED_LIMB list( \
	"blunt" = DR_MEDIUM, \
	"slash" = DBLOCK_LIGHT, \
	"stab" = DBLOCK_NONE, \
	"piercing" = DBLOCK_NONE, \
	"fire" = DR_NONE \
)

// ---------------------------------------------------------------------------
// Proc: apply_bodypart_reduction
// Sets brute_reduction and burn_reduction on bodyparts from a preset list.
// Called in Initialize() after ..() (which calls create_bodyparts()).
// ---------------------------------------------------------------------------

/mob/living/carbon/simple_animal/proc/apply_bodypart_reduction(list/bp_presets)
	if(!length(bp_presets))
		return
	for(var/zone in bp_presets)
		var/obj/item/bodypart/BP = get_bodypart(zone)
		if(!BP)
			continue
		var/list/values = bp_presets[zone]
		if(!values)
			continue
		if(values["brute"])
			BP.brute_reduction = values["brute"]
		if(values["burn"])
			BP.burn_reduction = values["burn"]

// ===========================================================================
// Animal natural armor assignments
// ===========================================================================

// --- Direbear: thick hide on chest, vulnerable head, tough limbs ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/direbear
	natural_armor_default = ANIMAL_ARMOR_THICK_HIDE
	natural_armor = list(
		BODY_ZONE_HEAD = ANIMAL_ARMOR_VULNERABLE_HEAD,
		BODY_ZONE_CHEST = ANIMAL_ARMOR_THICK_HIDE,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_TOUGH_HIDE,
	)

// --- Wolf: tough hide overall, vulnerable head and limbs ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/wolf
	natural_armor_default = ANIMAL_ARMOR_TOUGH_HIDE
	natural_armor = list(
		BODY_ZONE_HEAD = ANIMAL_ARMOR_VULNERABLE_HEAD,
		BODY_ZONE_CHEST = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_EXPOSED_LIMB,
	)

// --- Boar: tough bristled hide, thick skull ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/boar
	natural_armor_default = ANIMAL_ARMOR_TOUGH_HIDE
	natural_armor = list(
		BODY_ZONE_HEAD = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_CHEST = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_EXPOSED_LIMB,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_EXPOSED_LIMB,
	)

// --- Troll: stone skin, regenerating, weak to fire on all parts ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/troll
	natural_armor_default = ANIMAL_ARMOR_STONE_SKIN
	natural_armor = list(
		BODY_ZONE_HEAD = list(
			"blunt" = DR_HEAVY,
			"slash" = DBLOCK_MEDIUM,
			"stab" = DBLOCK_LIGHT,
			"piercing" = DBLOCK_LIGHT,
			"fire" = DR_NONE,
		),
		BODY_ZONE_CHEST = ANIMAL_ARMOR_STONE_SKIN,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_STONE_SKIN,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_STONE_SKIN,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_STONE_SKIN,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_STONE_SKIN,
	)

// --- Minotaur: thick hide, tough head (horns) ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/minotaur
	natural_armor_default = ANIMAL_ARMOR_THICK_HIDE
	natural_armor = list(
		BODY_ZONE_HEAD = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_CHEST = ANIMAL_ARMOR_THICK_HIDE,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_TOUGH_HIDE,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_TOUGH_HIDE,
	)

// --- Dragon: dragon scales everywhere, near-impenetrable ---

/mob/living/carbon/simple_animal/hostile/retaliate/rogue/dragon
	natural_armor_default = ANIMAL_ARMOR_DRAGON_SCALES
	natural_armor = list(
		BODY_ZONE_HEAD = list(
			"blunt" = DR_SUPER,
			"slash" = DBLOCK_HEAVY,
			"stab" = DBLOCK_MEDIUM,
			"piercing" = DBLOCK_MEDIUM,
			"fire" = DR_SUPER,
		),
		BODY_ZONE_CHEST = ANIMAL_ARMOR_DRAGON_SCALES,
		BODY_ZONE_L_ARM = ANIMAL_ARMOR_DRAGON_SCALES,
		BODY_ZONE_R_ARM = ANIMAL_ARMOR_DRAGON_SCALES,
		BODY_ZONE_L_LEG = ANIMAL_ARMOR_DRAGON_SCALES,
		BODY_ZONE_R_LEG = ANIMAL_ARMOR_DRAGON_SCALES,
	)
