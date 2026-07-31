// Ported from Ratwood-2.0's code/__DEFINES/roguetown/chastity.dm — chastity_collar port, Stage 1.

#define CHASTITY_HARDMODE_DISABLED 0
#define CHASTITY_HARDMODE_ENABLED 1

/// Root directory for all chastity flavor-text JSON banks.
/// Used by pick_chastity_string() and anywhere a raw strings() call targets the chastity string dir.
#define CHASTITY_STRINGS_PATH "modular_dreamvalley/ported/ratwood/chastity_collar/strings"

/// Picks a random entry from a chastity string bank.
/// Usage: pick_chastity_string("chastity_lock_messages.json", "chastity_lock_denial")
#define pick_chastity_string(FILE, KEY) (pick(strings(FILE, KEY, CHASTITY_STRINGS_PATH)))

/// Trait source tag used for every trait chastity devices apply, so REMOVE_TRAIT calls in remove_chastity()
/// only strip chastity's own copy of a trait and don't clobber the same trait granted by something else.
#define TRAIT_SOURCE_CHASTITY "chastity_device"

// Chastity traits — used by /obj/item/chastity to lock organs and gate spiked-device content/flavor.
#define TRAIT_CHASTITY_FULL "chastity_full" // full intersex device: blocks penis AND vagina AND anus (see has_chastity_anal())
#define TRAIT_CHASTITY_CAGE "chastity_cage" // cock cage: blocks penis
#define TRAIT_CHASTITY_PENIS_BLOCKED "chastity_penis_blocked" // generic penis-blocked flag, mirrors TRAIT_CHASTITY_CAGE for non-cage devices
#define TRAIT_CHASTITY_VAGINA_BLOCKED "chastity_vagina_blocked" // insertable belt: blocks vagina only (does NOT imply anal shielding)
#define TRAIT_CHASTITY_ANAL "chastity_anal" // rear shield: blocks anus
#define TRAIT_CHASTITY_SPIKED "chastity_spiked" // punitive spiked variant: extreme-content gated, drives pain flavor banks
#define TRAIT_CHASTITY_LOCKED "chastity_locked" // physical lock engaged (device may be worn unlocked)

/// Sound played when a worn chastity device jingles on movement. Distinct define so a later stage can swap it
/// for a bespoke SFX without hunting through chastity_core.dm.
/// Named CHASTITY_JINGLE_SOUND (not SFX_JINGLE_BELLS) because code/__DEFINES/sound.dm already
/// defines SFX_JINGLE_BELLS as a string lookup key ("jingle_bells") for game/sound.dm's playsound
/// switch/item_equipped_movement_rustle component - a completely different value (a lookup key,
/// not a sound file) used across ~15 real call sites. The two defines silently collided (whichever
/// file happened to compile last won for every use site in the whole codebase) until this rename.
#define CHASTITY_JINGLE_SOUND 'sound/misc/bell_small.ogg'

/// Movement-sound throttling — mirrors chastity_core.dm's chastity_move_delay/chance defaults.
#define CHASTITY_MOVE_SOUND_DELAY 3
/// Above this many connected clients, jingle sound probability is scaled down by CHASTITY_HIGH_POP_SOUND_MULT
/// to avoid every worn device spamming the same sound effect during high-population rounds.
#define CHASTITY_HIGH_POP_THRESHOLD 80
#define CHASTITY_HIGH_POP_SOUND_MULT 0.4
