// Area sanity_hazard assignments — gives existing DreamValley areas sanity impact
// Positive values restore sanity; negative values drain it.
// This file assigns values without modifying the original area files.

// ============== HOLY / SAFE AREAS (positive = restore) ==============

/area/rogue/indoors/town/church
	sanity_hazard = 1.5

/area/rogue/indoors/town
	sanity_hazard = 0.3

/area/rogue/indoors/town/bath
	sanity_hazard = 0.8

/area/rogue/indoors/town/shop
	sanity_hazard = 0.2

// ============== DANGEROUS AREAS (negative = drain) ==============

/area/rogue/outdoors/woods
	sanity_hazard = -0.3

/area/rogue/outdoors/bog
	sanity_hazard = -0.6

/area/rogue/indoors/banditcamp
	sanity_hazard = -0.5

/area/rogue/indoors/vampire_manor
	sanity_hazard = -1.0

/area/rogue/indoors/lich_start/lich_lair
	sanity_hazard = -1.2

// ============== SHELTER AREAS (positive = restore) ==============

/area/rogue/indoors/shelter
	sanity_hazard = 0.8

/area/rogue/indoors/shelter/woods
	sanity_hazard = 0.5

/area/rogue/indoors/shelter/bog
	sanity_hazard = 0.5

// ============== DUNGEON / EVIL AREAS ==============

/area/rogue/indoors/auxentiusarena
	sanity_hazard = -0.8

/area/rogue/indoors/eventarea
	sanity_hazard = -0.4
