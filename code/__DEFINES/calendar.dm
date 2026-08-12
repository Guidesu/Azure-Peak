#define CALENDAR_EPOCH_YEAR 1513
// Per player feedback, I am fixing the year to 1513 to avoid people dealing with implications of aging etc. Cycle instead track how many years passed OOC.
// The suffix on this year (see get_ic_date_as_string / get_ic_date_short_as_string) is "AC" - After the Compact, marking years since the
// Vaeltis Compact was founded and the Court of Six Seats began governing Auxentia in the Concordat's name.
#define YEAR_PER_CYCLE 1 // How many years until the calendar repeats itself from epoch year
#define CALENDAR_MONTHS_PER_YEAR 12
#define CALENDAR_DAYS_IN_MONTH 28 // 28 days ensures each year has exactly 48 weeks, so every year/cycle starts on Monday
#define CALENDAR_DAYS_IN_YEAR (CALENDAR_MONTHS_PER_YEAR * CALENDAR_DAYS_IN_MONTH) // 336
#define CALENDAR_DAYS_IN_WEEK 7
#define CALENDAR_WEEKS_IN_YEAR (CALENDAR_DAYS_IN_YEAR / CALENDAR_DAYS_IN_WEEK) // 48 weeks exactly

#define CALENDAR_SYSTEM_VAELTIC "vaeltic"

#define CALENDAR_CATEGORY_HOLY_DAY "holy_day"
#define CALENDAR_CATEGORY_FESTIVAL "festival"
#define CALENDAR_CATEGORY_VIGIL "vigil"
#define CALENDAR_CATEGORY_SEASONAL "seasonal"
#define CALENDAR_CATEGORY_CIVIC "civic"

#define CALENDAR_EVENTS_JSON_PATH "strings/calendar_events.json"

// Moon phase defines
#define MOON_PHASE_NEW "new_moon"
#define MOON_PHASE_WAXING_CRESCENT "waxing_crescent"
#define MOON_PHASE_FIRST_QUARTER "first_quarter"
#define MOON_PHASE_WAXING_GIBBOUS "waxing_gibbous"
#define MOON_PHASE_FULL "full_moon"
#define MOON_PHASE_WANING_GIBBOUS "waning_gibbous"
#define MOON_PHASE_LAST_QUARTER "last_quarter"
#define MOON_PHASE_WANING_CRESCENT "waning_crescent"

// Blood moon chance on full moon (15%)
#define BLOOD_MOON_CHANCE 15

// Lunar cycle length = 28 days (matches CALENDAR_DAYS_IN_MONTH)
// Day 1 = new moon, Day 14 = full moon, Day 28 = new moon again
#define LUNAR_CYCLE_DAYS 28
