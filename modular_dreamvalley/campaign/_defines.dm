/// Far Travel was not handled by DreamValley; Azure may use its normal path.
#define DREAMVALLEY_TRAVEL_UNHANDLED 0
/// DreamValley consumed the Far Travel request, either by parking or safely refusing it.
#define DREAMVALLEY_TRAVEL_HANDLED 1

/// A complete in-game day in deciseconds.
#define DREAMVALLEY_DAY_LENGTH 864000

/// Campaign clock defaults: one in-game day takes one real hour.
#define DREAMVALLEY_DEFAULT_TIME_SCALE 24
#define DREAMVALLEY_DEFAULT_DAWN_START 216000
#define DREAMVALLEY_DEFAULT_DAY_START 252000
#define DREAMVALLEY_DEFAULT_DUSK_START 720000
#define DREAMVALLEY_DEFAULT_NIGHT_START 756000
#define DREAMVALLEY_DEFAULT_START_TIME 252001
