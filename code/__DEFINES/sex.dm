GLOBAL_LIST_INIT(sex_actions, build_sex_actions())

GLOBAL_LIST_EMPTY(sex_sessions)
GLOBAL_LIST_EMPTY(sex_collectives)
GLOBAL_VAR_INIT(collective_counter, 1)
GLOBAL_LIST_EMPTY(locked_sex_objects)

#define SEX_ACTION(sex_action_type) GLOB.sex_actions[sex_action_type]

#define COMSIG_SEX_ADJUST_AROUSAL "sex_adjust_arousal"					// (amount) - Adjust arousal level
#define COMSIG_SEX_SET_AROUSAL "sex_set_arousal"						// (amount) - Set arousal to specific value
#define COMSIG_SEX_AROUSAL_CHANGED "sex_arosual_change"					// fires to the parent about a change
#define COMSIG_SEX_FREEZE_AROUSAL "sex_freeze_arousal"					// (freeze_state) - Toggle arousal freeze
#define COMSIG_SEX_GET_AROUSAL "sex_get_arousal"						// () - Get current arousal info
#define COMSIG_SEX_CLIMAX "sex_climax"									// (type, target) - Handle climax event
#define COMSIG_SEX_RECEIVE_ACTION "sex_receive_action"					// (arousal_amt, pain_amt, giving, force, speed) - Receive action effects

// Knotting Component Signals
/// Attempts to knot a target. Args: (target, force_level)
#define COMSIG_SEX_TRY_KNOT "sex_try_knot"
/// Removes an existing knot. Args: (forceful_removal, notify, keep_top_status, keep_btm_status)
#define COMSIG_SEX_REMOVE_KNOT "sex_remove_knot"

// General Sex Signals
/// Checks if user can use their penis. Return: TRUE/FALSE
#define COMSIG_SEX_CAN_USE_PENIS "sex_can_use_penis"
/// Checks if user is considered limp. Return: TRUE/FALSE
#define COMSIG_SEX_CONSIDERED_LIMP "sex_considered_limp"
/// Sends a signal whenever the user thrusts, or gets thrusted at
#define COMSIG_SEX_JOSTLE "sex_jostle"

// Intimate accessory (chastity, piercings, etc.) reaction/guard signals — ratwood chastity_collar port, Stage 1.
/// Minimal organ bitmask scoped to feeding COMSIG_CARBON_SEX_ACTION_RECEIVED/VALIDATE. Ratwood's old sexcon had
/// an equivalent SEX_PART_* bitmask baked into every sex_action; sexcon2 has no such concept (see
/// /datum/sex_action/proc/get_acted_sex_part() in code/datums/sexcon2/actions/_base_action.dm for the mapping).
#define SEX_PART_NULL 0
#define SEX_PART_COCK (1<<0)
#define SEX_PART_CUNT (1<<1)
#define SEX_PART_ANUS (1<<2)

/// Fired on the RECEIVING mob after receive_sex_action() on /datum/component/arousal has applied arousal/pain for
/// an incoming sex action, so worn accessories (chastity devices, piercings) can react with flavor text, sounds, etc.
/// Args: (mob/living/carbon/human/acting_mob, datum/sex_action/action, acted_sex_part, giving, arousal_amt, pain_amt, applied_force, applied_speed)
#define COMSIG_CARBON_SEX_ACTION_RECEIVED "carbon_sex_action_received"
/// Fired on the TARGET before a sex action is allowed to proceed (from can_perform()/shows_on_menu() on /datum/sex_action),
/// letting components veto or hide the action (e.g. chastity blocking penetration of a locked organ).
/// Return COMPONENT_SEX_ACTION_BLOCK to veto the action / hide it from the menu.
/// Args: (mob/living/carbon/human/user, datum/sex_action/action, acted_sex_part, menu_check)
#define COMSIG_CARBON_SEX_ACTION_VALIDATE "carbon_sex_action_validate"
	/// Return value for COMSIG_CARBON_SEX_ACTION_VALIDATE: vetoes/hides the action.
	#define COMPONENT_SEX_ACTION_BLOCK 1

/// Fired on a chastity-device wearer whenever a tool attempts to interact with the device's lock (lockpick,
/// hammer & chisel, forced removal). Return COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK to silently block the attempt.
/// Args: (mob/user, obj/item/interaction_item, new_locked_state, method)
#define COMSIG_CARBON_CHASTITY_LOCK_INTERACT "carbon_chastity_lock_interact"
	/// Return value for COMSIG_CARBON_CHASTITY_LOCK_INTERACT: silently blocks the lock interaction.
	#define COMPONENT_CHASTITY_LOCK_INTERACT_BLOCK 1
/// Fired on a chastity-device wearer whenever the device's lock state actually changes (locked/unlocked).
/// Args: (mob/user, obj/item/interaction_item, new_locked_state, interaction_source)
#define COMSIG_CARBON_CHASTITY_LOCK_CHANGED "carbon_chastity_lock_changed"
/// Fired on a chastity-device wearer whenever chastity-related traits/mode change and mood/visuals need refreshing.
/// Args: (obj/item/chastity/device, reason)
#define COMSIG_CARBON_CHASTITY_STATE_CHANGED "carbon_chastity_state_changed"

#define SEX_SPEED_LOW 1
#define SEX_SPEED_MID 2
#define SEX_SPEED_HIGH 3
#define SEX_SPEED_EXTREME 4

#define SEX_SPEEDS list(SEX_SPEED_LOW, SEX_SPEED_MID, SEX_SPEED_HIGH, SEX_SPEED_EXTREME)

#define SEX_SPEED_MIN 1
#define SEX_SPEED_MAX 5

#define SEX_FORCE_LOW 1
#define SEX_FORCE_MID 2
#define SEX_FORCE_HIGH 3
#define SEX_FORCE_EXTREME 4

#define SEX_FORCES list(SEX_FORCE_LOW, SEX_FORCE_MID, SEX_FORCE_HIGH, SEX_FORCE_EXTREME)

#define SEX_FORCE_MIN 1
#define SEX_FORCE_MAX 5

#define SEX_MANUAL_AROUSAL_DEFAULT 1
#define SEX_MANUAL_AROUSAL_UNAROUSED 2
#define SEX_MANUAL_AROUSAL_PARTIAL 3
#define SEX_MANUAL_AROUSAL_FULL 4

#define SEX_MANUAL_AROUSALS LIST(SEX_MANUAL_AROUSAL_DEFAULT, SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_PARTIAL, SEX_MANUAL_AROUSAL_FULL)

#define SEX_MANUAL_AROUSAL_MIN 1
#define SEX_MANUAL_AROUSAL_MAX 4

#define BLUEBALLS_GAIN_THRESHOLD 40
#define BLUEBALLS_LOOSE_THRESHOLD 35

#define PAIN_MILD_EFFECT 10
#define PAIN_MED_EFFECT 20
#define PAIN_HIGH_EFFECT 30
#define PAIN_MINIMUM_FOR_DAMAGE PAIN_MED_EFFECT
#define PAIN_DAMAGE_DIVISOR 50

#define MAX_AROUSAL 150
#define PASSIVE_EJAC_THRESHOLD 108
#define THRILLSEEKER_THRESHOLD 85
#define ACTIVE_EJAC_THRESHOLD 100
#define SEX_MAX_CHARGE 300
#define CHARGE_FOR_CLIMAX 100
#define AROUSAL_HARD_ON_THRESHOLD 20
#define CHARGE_RECHARGE_RATE (CHARGE_FOR_CLIMAX / (2 MINUTES))
#define AROUSAL_TIME_TO_UNHORNY (10 SECONDS)
#define SPENT_AROUSAL_RATE (3 / (1 SECONDS))
#define IMPOTENT_AROUSAL_LOSS_RATE (3 / (1 SECONDS))

#define MOAN_COOLDOWN 3 SECONDS
#define PAIN_COOLDOWN 6 SECONDS

#define MIN_PENIS_SIZE 1
#define DEFAULT_PENIS_SIZE 2
#define MAX_PENIS_SIZE 3

#define PENIS_SIZES list(\
	MIN_PENIS_SIZE,\
	DEFAULT_PENIS_SIZE,\
	MAX_PENIS_SIZE,\
	)

#define PENIS_SIZES_BY_NAME list(\
	"Small" = MIN_PENIS_SIZE,\
	"Average" = DEFAULT_PENIS_SIZE,\
	"Large" = MAX_PENIS_SIZE,\
	)

#define PENIS_TYPE_PLAIN 1
#define PENIS_TYPE_KNOTTED 2
#define PENIS_TYPE_EQUINE 3
#define PENIS_TYPE_TAPERED 4
#define PENIS_TYPE_TAPERED_DOUBLE 5
#define PENIS_TYPE_TAPERED_DOUBLE_KNOTTED 6
#define PENIS_TYPE_BARBED 7
#define PENIS_TYPE_BARBED_KNOTTED 8
#define PENIS_TYPE_TENTACLE 9

#define SHEATH_TYPE_NONE 0
#define SHEATH_TYPE_NORMAL 1
#define SHEATH_TYPE_SLIT 2

#define EARS_NORMAL 0
#define EARS_SENSITIVE 1 //Should this be used for ANYTHING else - move it. / Also only works on ANTHROS for some reason

#define ERECT_STATE_NONE 0
#define ERECT_STATE_PARTIAL 1
#define ERECT_STATE_HARD 2

#define MIN_TESTICLES_SIZE 1
#define DEFAULT_TESTICLES_SIZE 2
#define MAX_TESTICLES_SIZE 3

#define TESTICLE_SIZES list(\
	MIN_TESTICLES_SIZE,\
	DEFAULT_TESTICLES_SIZE,\
	MAX_TESTICLES_SIZE,\
	)

#define TESTICLE_SIZES_BY_NAME list(\
	"Small" = MIN_TESTICLES_SIZE,\
	"Average" = DEFAULT_TESTICLES_SIZE,\
	"Large" = MAX_TESTICLES_SIZE,\
	)

#define ORGAN_SLOT_PENIS "penis"
#define ORGAN_SLOT_TESTICLES "testicles"
#define ORGAN_SLOT_BREASTS "breasts"
#define ORGAN_SLOT_VAGINA "vagina"
#define ORGAN_SLOT_ANUS "anus"///this is a fake organ used for sex_lock

#define BREAST_SIZE_FLAT 0
#define BREAST_SIZE_VERY_SMALL 1
#define BREAST_SIZE_SMALL 2
#define BREAST_SIZE_NORMAL 3
#define BREAST_SIZE_LARGE 4
#define BREAST_SIZE_ENORMOUS 5
#define BREAST_SIZE_HEAVY 6
#define BREAST_SIZE_MASSIVE 7
#define BREAST_SIZE_HEAPING 8
#define BREAST_SIZE_OBSCENE 9
#define BREAST_SIZE_10 10
#define BREAST_SIZE_11 11
#define BREAST_SIZE_12 12

#define MIN_BREASTS_SIZE BREAST_SIZE_FLAT
#define DEFAULT_BREASTS_SIZE BREAST_SIZE_NORMAL
#define MAX_BREASTS_SIZE BREAST_SIZE_12

#define BREAST_SIZES list(\
	BREAST_SIZE_FLAT,\
	BREAST_SIZE_VERY_SMALL,\
	BREAST_SIZE_SMALL,\
	BREAST_SIZE_NORMAL,\
	BREAST_SIZE_LARGE,\
	BREAST_SIZE_ENORMOUS,\
	BREAST_SIZE_HEAVY,\
	BREAST_SIZE_MASSIVE,\
	BREAST_SIZE_HEAPING,\
	BREAST_SIZE_OBSCENE,\
	BREAST_SIZE_10,\
	BREAST_SIZE_11,\
	BREAST_SIZE_12,\
	)

#define BREAST_SIZES_BY_NAME list(\
	"Flat" = BREAST_SIZE_FLAT,\
	"Very Small" = BREAST_SIZE_VERY_SMALL,\
	"Small" = BREAST_SIZE_SMALL,\
	"Normal" = BREAST_SIZE_NORMAL,\
	"Large" = BREAST_SIZE_LARGE,\
	"Enormous" = BREAST_SIZE_ENORMOUS,\
	"Heavy" = BREAST_SIZE_HEAVY,\
	"Massive" = BREAST_SIZE_MASSIVE,\
	"Heaping" = BREAST_SIZE_HEAPING,\
	"Obscene" = BREAST_SIZE_OBSCENE,\
	"Size 10" = BREAST_SIZE_10,\
	"Size 11" = BREAST_SIZE_11,\
	"Size 12" = BREAST_SIZE_12,\
	)

#define KINK_PROCESS (1 << 0)
#define KINK_SEX_ACT (1 << 1)
#define KINK_ATTACKED (1 << 2)

#define KINK_BONDAGE "Bondage"
#define KINK_DOMINATION "Domination"
#define KINK_GENTLE "Gentle"
#define KINK_ONOMATOPOEIA "Onomatopoeia"
#define KINK_PRAISE "Praise"
#define KINK_PUBLIC_RISK "Public Risk"
#define KINK_ROLEPLAY "Roleplay"
#define KINK_ROUGH "Rough"
#define KINK_SENSUAL_PLAY "Sensual Play"
#define KINK_SUBMISSIVE "Submissive"
#define KINK_TEASING "Teasing"
#define KINK_VISUAL_EFFECTS "Visual Effects"

// build_sex_actions() now lives in code/__DEFINES/sexcon_defines.dm alongside the rest of the
// sexcon defines - kept there so the GLOBAL_LIST_INIT(sex_actions, ...) right above it stays
// together with the proc that populates it.


#define SUBTLE_TAG (1 << 0)
#define SUBTLE_ALL (1 << 1)
#define SUBTLE_NOGHOST (1 << 2)
#define SUBTLE_SHORT (1 << 3)

#define SEX_SOUNDS_SLOW list(\
	"sound/misc/mat/sex_clap/slow/SexSlap14.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap20.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap21.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap23.ogg",\
	"sound/misc/mat/sex_clap/slow/SexSlap34.ogg",\
	)

#define SEX_SOUNDS_HARD list(\
	"sound/misc/mat/sex_clap/hard/SexSmack17.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack18.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack20.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack21.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack24.ogg",\
	"sound/misc/mat/sex_clap/hard/SexSmack26.ogg",\
	)

#define KNOTTED_NULL 0
#define KNOTTED_AS_TOP 1
#define KNOTTED_AS_BTM 2

// Ratwood compat defines
#define AROUSAL_HIGH_UNHORNY_RATE (1.5/(1 SECONDS))
#define SEX_SPEED_LUDICROUS 5
#define SEX_FORCE_LUDICROUS 5
#define IMPREG_PROB_DEFAULT 25
#define SEX_CATEGORY_NULL 0
#define SEX_PART_JAWS (1<<3)
#define SEX_PART_SLIT_SHEATH (1<<4)
#define TRAIT_CHASTITY_SPIKED "chastity_spiked"
#define TRAIT_CHASTITY_FULL "chastity_full"
#define TRAIT_CHASTITY_CAGE "chastity_cage"
#define TRAIT_CHASTITY_PENIS_BLOCKED "chastity_penis_blocked"
#define TRAIT_CHASTITY_VAGINA_BLOCKED "chastity_vagina_blocked"
#define TRAIT_CHASTITY_ANAL "chastity_anal"
#define TRAIT_BAOTHA_FERTILITY_BOON "baotha_fertility_boon"
#define TRAIT_PSYDONIAN_GRIT "praecursorian_grit"
#define SFX_COLLARJINGLE "collarjingle"
#define PENIS_TYPE_EQUINE_KNOTTED 10
#define PENIS_TYPE_TAPERED_KNOTTED 11
#define COMSIG_MOB_EJACULATED "mob_ejaculated"
#define STATS_KNOTTED "knotted"
#define STATS_IMPREGNATIONS "impregnations"
#define addiction_permanent FALSE
#define LOWER_TEXT lowertext
