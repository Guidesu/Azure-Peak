// Mob affix system - roguelike modifiers that can spawn on any mob.

// Affix type flags (where the word appears in the mob's generated name)
#define AFFIX_PREFIX_MOB (1 << 0)
#define AFFIX_SUFFIX_MOB (1 << 1)

// Common alignment flags - used by UI/loot coloring
#define AFFIX_ALIGNMENT_GOOD (1 << 0)
#define AFFIX_ALIGNMENT_EVIL (1 << 1)
#define AFFIX_ALIGNMENT_NEUTRAL (1 << 2)

// Maximum number of affixes a mob may roll naturally
#define MAX_MOB_AFFIXES 4

// Default affix roll chance for eligible spawns (0-100)
#define MOB_AFFIX_BASE_CHANCE 60

// Stat keys for the affix system
#define MA_STAT_STR "STASTR"
#define MA_STAT_PER "STAPER"
#define MA_STAT_INT "STAINT"
#define MA_STAT_CON "STACON"
#define MA_STAT_WIL "STAWIL"
#define MA_STAT_SPD "STASPD"
#define MA_STAT_LUC "STALUC"
