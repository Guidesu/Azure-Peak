// CEV-Eris Sanity/Insight System — Adapted for DreamValley
// Replaces Eris STAT_VIG with DreamValley's STAWIL (Willpower) for sanity resistance.

// Global multipliers for admin tuning
#define GLOBAL_SANITY_MOD 1
#define GLOBAL_INSIGHT_MOD 1

// Passive sanity gain per life tick
#define SANITY_PASSIVE_GAIN 0.2

// Sanity damage modifiers — scaled by willpower instead of Eris's Vigilance
#define SANITY_DAMAGE_MOD (0.6 * GLOBAL_SANITY_MOD)
#define SANITY_VIEW_DAMAGE_MOD (0.4 * GLOBAL_SANITY_MOD)

// Damage from viewing unpleasant things (corpses, gore, horrors)
#define SANITY_DAMAGE_VIEW(damage, wil, dist) ((damage) * SANITY_VIEW_DAMAGE_MOD * (1.2 - ((wil) - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)) * (1 - (dist)/15))

// Damage from body damage
#define SANITY_DAMAGE_HURT(damage, wil) (min((damage) / 5 * SANITY_DAMAGE_MOD * (1.2 - ((wil) - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)), 60))

// Damage from shock/pain
#define SANITY_DAMAGE_SHOCK(shock, wil) ((shock) / 50 * SANITY_DAMAGE_MOD * (1.2 - ((wil) - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)))

// Damage from psy/magical effects
#define SANITY_DAMAGE_PSY(damage, wil) (damage * SANITY_DAMAGE_MOD * (2 - ((wil) - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)))

// Damage from witnessing death
#define SANITY_DAMAGE_DEATH(wil) (10 * SANITY_DAMAGE_MOD * (1 - ((wil) - STAT_BASELINE) / (STAT_CEILING - STAT_BASELINE)))

// Sanity gain from smoking, talking
#define SANITY_GAIN_SMOKE 0.05
#define SANITY_GAIN_SAY 1

// Cooldowns
#define SANITY_COOLDOWN_SAY rand(30 SECONDS, 45 SECONDS)
#define SANITY_COOLDOWN_BREAKDOWN rand(7 MINUTES, 10 MINUTES)

// Level change fadeoff — recent changes matter more for insight
#define SANITY_CHANGE_FADEOFF(level_change) (level_change * 0.75)

// Insight gain
#define INSIGHT_PASSIVE_GAIN 0.05
#define INSIGHT_GAIN(level_change) (INSIGHT_PASSIVE_GAIN + level_change / 15)

// Desire system — what the character craves during rest
#define INSIGHT_DESIRE_COUNT 2
#define INSIGHT_DESIRE_FOOD "food"
#define INSIGHT_DESIRE_ALCOHOL "alcohol"
#define INSIGHT_DESIRE_SMOKING "smoking"
#define INSIGHT_DESIRE_DRUGS "drugs"
#define INSIGHT_DESIRE_PRAYER "prayer"
#define INSIGHT_DESIRE_MUSIC "music"

// Mob distance for sanity activation
#define SANITY_MOB_DISTANCE_ACTIVATION 12

// Breakdown alert cooldown
#define BREAKDOWN_ALERT_COOLDOWN rand(45 SECONDS, 90 SECONDS)

// Sanity level thresholds for effects
#define SANITY_THRESHOLD_SPOOK 40
#define SANITY_THRESHOLD_BAD 30
#define SANITY_THRESHOLD_CRITICAL 20

// Insight rest thresholds
#define INSIGHT_REST_THRESHOLD 100
#define INSIGHT_REST_TIMER 60 SECONDS

// Internal wound flags (ERISMED)
#define IWOUND_CAN_DAMAGE 1
#define IWOUND_PROGRESS 2
#define IWOUND_PROGRESS_DEATH 4
#define IWOUND_SPREAD 8
#define IWOUND_HALLUCINATE 16
#define IWOUND_AGGRAVATION 32
#define IWOUND_RECOVER 64
#define IWOUND_STASIS 128

// Wound progression thresholds (in ticks)
#define IWOUND_1_MINUTE 30
#define IWOUND_2_MINUTES 60
#define IWOUND_4_MINUTES 120
#define IWOUND_8_MINUTES 240

// Wound nature
#define WOUND_NATURE_ORGANIC 1
#define WOUND_NATURE_ROBOTIC 2
#define WOUND_NATURE_BOTH 3

// Treatment types
#define WE_TREATMENT_ITEM 1
#define WE_TREATMENT_TOOL 2
#define WE_TREATMENT_CHEM 3
#define WE_TREATMENT_FIRSTAID 4

// Organ efficiency thresholds
#define BRUISED_2_EFFICIENCY 80
#define BROKEN_2_EFFICIENCY 50
#define DEAD_2_EFFICIENCY 0
