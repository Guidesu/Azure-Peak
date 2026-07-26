/// Concordat storytellers
#define CONCORDAT_STORYTELLERS list( \
	/datum/storyteller/auxentius, \
	/datum/storyteller/miluse, \
	/datum/storyteller/wulfric, \
	/datum/storyteller/viator, \
	/datum/storyteller/handwerra, \
	/datum/storyteller/morwenna, \
)

/// Severance storytellers
#define SEVERANCE_STORYTELLERS list( \
	/datum/storyteller/ignatius, \
)

/// Old Kin storytellers
#define OLDKIN_STORYTELLERS list( \
	/datum/storyteller/volkovoi, \
	/datum/storyteller/hausvette, \
)

/// Tribunal storytellers
#define TRIBUNAL_STORYTELLERS list( \
	/datum/storyteller/praecursor, \
)

/// Unveiled storytellers
#define UNVEILED_STORYTELLERS list( \
	/datum/storyteller/aurelian, \
)

/// All storytellers
#define STORYTELLERS_ALL (CONCORDAT_STORYTELLERS + SEVERANCE_STORYTELLERS + OLDKIN_STORYTELLERS + TRIBUNAL_STORYTELLERS + UNVEILED_STORYTELLERS)

/datum/storyteller/praecursor
	name = "Praecursor"
	vote_desc = "Peace reigns. No villains will be present. His children can rest easy, for they have earned their respite"
	desc = "Mundane and moderate events fire 1.2x more often. No antagonists, no divine intervention. Gnolls absent."
	welcome_text = "A temperate breeze rolls through the quiet streets.."
	weight = 6
	always_votable = TRUE
	color_theme = "#80ced8"
	preferred_gnoll_mode = GNOLL_SCALING_NONE
	wretch_slot_cap = 0
	guarantees_roundstart_roleset = FALSE
	roundstart_prob = 0

	//Has no influence, your actions will not impact him his spawn rates. Cus he's asleep.
	//Tl;dr - higher event spawn rates to keep stuff interesting, no god intervention, no antags. (Raids and omens will still happen at normal rate.)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.2,
		EVENT_TRACK_MODERATE = 1.2,
		EVENT_TRACK_INTERVENTION = 0,			//No god intervention, cus he's asleep.
		EVENT_TRACK_CHARACTER_INJECTION = 0,	//No antagonist spawns.
	)

/// Merge of the old Astrata (sun, order) and Ravox (justice, glory, battle) storytellers.
/datum/storyteller/auxentius
	name = "Auxentius"
	vote_desc = "Order and glory reign. No great villains will rise, and gnolls do not stalk the daelight. His favor shines upon nobility, their decrees, and clashing steel - though raids and omens still answer His call."
	desc = "Bandits, liches, werewolves, and vampire lords cannot roll. Masquerade is the only roundstart hard antag and gets a 1.5x weight bump. Raids fire more often and get a weight bump. Gnolls absent. Wretches scale normally."
	welcome_text = "The warmth of daelight rouses you from your slumber, as the trumpets of Zericho echo in the distance.."
	weight = 6
	always_votable = TRUE
	follower_modifier = LOWER_FOLLOWER_MODIFIER
	color_theme = "#FFD700"
	preferred_gnoll_mode = GNOLL_SCALING_NONE
	guarantees_roundstart_roleset = FALSE
	roundstart_prob = 0

	starting_point_multipliers = list(
		EVENT_TRACK_CHARACTER_INJECTION = 0,
	)

	tag_multipliers = list(
		TAG_RAID = 1.3,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.9,
		EVENT_TRACK_PERSONAL = 0.95,
		EVENT_TRACK_INTERVENTION = 1,
		EVENT_TRACK_CHARACTER_INJECTION = 0,	//No antagonist spawns under His order.
		EVENT_TRACK_OMENS = 1,
		EVENT_TRACK_RAIDS = 1.5,
	)

	influence_sets = list(
	"Set 1" = list(
		STATS_LAWS_AND_DECREES_MADE = list("name" = "Laws and decrees:", "points" = 2.75, "capacity" = 45),
	),
	"Set 2" = list(
		STATS_ALIVE_NOBLES = list("name" = "Number of nobles:", "points" = 2.5, "capacity" = 60),
	),
	"Set 3" = list(
		STATS_NOBLE_DEATHS = list("name" = "Noble deaths:", "points" = -3.75, "capacity" = -60),
		STATS_PEOPLE_SMITTEN = list("name" = "People smitten:", "points" = 4, "capacity" = 40),
	),
	"Set 4" = list(
		STATS_ASTRATA_REVIVALS = list("name" = "Holy revivals:", "points" = 6, "capacity" = 75),
		STATS_PRAYERS_MADE = list("name" = "Prayers made:", "points" = 2.25, "capacity" = 65),
	),
	"Set 5" = list(
		STATS_TAXES_COLLECTED = list("name" = "Taxes collected:", "points" = 0.2, "capacity" = 80),
	),
	"Set 6" = list(
		STATS_COMBAT_SKILLS = list("name" = "Combat skills learned:", "points" = 1.065, "capacity" = 90),
	),
	"Set 7" = list(
		STATS_WARCRIES = list("name" = "Warcries made:", "points" = 0.35, "capacity" = 50),
	))

/// Merge of the old Noc (moon, knowledge) and Eora (love, life, beauty) storytellers.
/datum/storyteller/miluse
	name = "Miluše"
	vote_desc = "Knowledge and love reign. Occurrences are tame, but remain suspectable to arcyne intervention. Her favor shines upon those who dream for greater ambitions and those who dream of romance."
	desc = "Magical events fire 1.2x more often, haunted 1.1x, widespread events and boons get weight bumps. No antag pool changes. Single gnoll possible."
	welcome_text = "The air crackles with arcyne energy, sweetened faintly by the smell of freshly-baked pies.."
	weight = 4
	always_votable = TRUE
	color_theme = "#F0F0F0"
	preferred_gnoll_mode = GNOLL_SCALING_SINGLE

	tag_multipliers = list(
		TAG_MAGICAL = 1.2,
		TAG_HAUNTED = 1.1,
		TAG_WIDESPREAD = 1.3,
		TAG_BOON = 1.1,
	)
	cost_variance = 25

	point_gains_multipliers = list(
		EVENT_TRACK_PERSONAL = 1.2,
		EVENT_TRACK_INTERVENTION = 1.5,
		EVENT_TRACK_CHARACTER_INJECTION = 0,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_BOOKS_PRINTED = list("name" = "Books printed:", "points" = 2, "capacity" = 40),
		),
		"Set 2" = list(
			STATS_LITERACY_TAUGHT = list("name" = "Literacy taught:", "points" = 20, "capacity" = 140),
		),
		"Set 3" = list(
			STATS_BOOKS_BURNED = list("name" = "Books burned:", "points" = -2, "capacity" = -50),
		),
		"Set 4" = list(
			STATS_SKILLS_DREAMED = list("name" = "Skills dreamed:", "points" = 0.325, "capacity" = 100),
		),
		"Set 5" = list(
			STATS_VOYEURS = list("name" = "Voyeurs:", "points" = 5, "capacity" = 50),
		),
		"Set 6" = list(
			STATS_HUGS_MADE = list("name" = "Hugs made:", "points" = 2.5, "capacity" = 70),
		),
		"Set 7" = list(
			STATS_KISSES_MADE = list("name" = "Kisses made:", "points" = 7, "capacity" = 70),
		),
		"Set 8" = list(
			STATS_MARRIAGES_MADE = list("name" = "Marriages made:", "points" = 20, "capacity" = 80),
		),
	)

/// Direct successor to the old Abyssor storyteller, re-themed around Wulfric's hearth-and-war domain.
/datum/storyteller/wulfric
	name = "Wulfric"
	vote_desc = "War-as-protection reigns. Occurrences are tame, though their temperance oft-sways like a held breath before battle. His favor shines upon the fished, leeched, and drowned - dreamwalkers ride the deep, but no gnolls dare His shores."
	desc = "Water events get a 1.3x weight bump, trade 1.2x. Dreamwalker gets a 1.5x weight bump in the antag pool. Gnolls absent."
	welcome_text = "The horizon grows dark, as its clouds gather for a coming storm.."
	weight = 4
	always_votable = TRUE
	color_theme = "#3366CC"
	preferred_gnoll_mode = GNOLL_SCALING_NONE

	tag_multipliers = list(
		TAG_WATER = 1.3,
		TAG_TRADE = 1.2,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_FISH_CAUGHT = list("name" = "Fish caught:", "points" = 1.75, "capacity" = 85),
		),
		"Set 2" = list(
			STATS_WATER_CONSUMED = list("name" = "Water consumed:", "points" = 0.014, "capacity" = 90),
		),
		"Set 3" = list(
			STATS_ABYSSOR_REMEMBERED = list("name" = "Wulfric remembered:", "points" = 1.1, "capacity" = 50),
			STATS_ALIVE_AXIAN = list("name" = "Number of axians:", "points" = 8, "capacity" = 70),
		),
		"Set 4" = list(
			STATS_LEECHES_EMBEDDED = list("name" = "Leeches embedded:", "points" = 0.75, "capacity" = 70),
		),
		"Set 5" = list(
			STATS_PEOPLE_DROWNED = list("name" = "People drowned:", "points" = 12, "capacity" = 75),
			STATS_BATHS_TAKEN = list("name" = "Baths taken:", "points" = 4.5, "capacity" = 60),
		)
	)

/// Direct successor to the old Xylix storyteller, re-themed around Viator's trade/travel/luck domain.
/datum/storyteller/viator
	name = "Viator"
	vote_desc = "Unpredictability reigns. Nothing is set in stone, yet everything is possible. His favor shines upon acts of chance, whimsy, and the open road."
	desc = "Forced events bypass population prerequisites and any event that's already fired this round drops to its full repetition penalty immediately. Intervention 1.75x; character injection, omens and raids suppressed to 0. All roundstart hard antags get a 1.5x weight bump. Gnoll mode randomized."
	welcome_text = "\"..well, that's what happens out of too much spice and wine!\""
	weight = 4
	always_votable = TRUE
	event_repetition_multiplier = 0
	forced = TRUE
	color_theme = "#AA8888"
	preferred_gnoll_mode = GNOLL_SCALING_RANDOM

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_PERSONAL = 1.1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_INTERVENTION = 1.75,
		EVENT_TRACK_CHARACTER_INJECTION = 0,
		EVENT_TRACK_OMENS = 0,
		EVENT_TRACK_RAIDS = 0,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_LAUGHS_MADE = list("name" = "Laughs had:", "points" = 0.225, "capacity" = 85),
		),
		"Set 2" = list(
			STATS_PEOPLE_MOCKED = list("name" = "People mocked:", "points" = 5, "capacity" = 60),
		),
		"Set 3" = list(
			STATS_CRITS_MADE = list("name" = "Crits made:", "points" = 0.26, "capacity" = 90),
		),
		"Set 4" = list(
			STATS_SONGS_PLAYED = list("name" = "Songs played:", "points" = 0.675, "capacity" = 70),
			STATS_MOAT_FALLERS = list("name" = "Moat fallers:", "points" = 4, "capacity" = 50),
		)
	)

/// Merge of the old Necra (death, afterlife) and Matthios (exchange, greed, debt) storytellers.
/datum/storyteller/morwenna
	name = "Morwenna"
	vote_desc = "Death and debt reign. Occurrences happen less often, villains are less likely, but bandit incursions and thefts remain common. Her favor shines upon those who put the deathless back into their graves, and those who settle their accounts."
	desc = "Haunted events get a 1.3x weight bump, trade and corruption events get bumps too. Bandits are guaranteed roundstart - liches, werewolves, and vampire lords cannot roll. Antag and raid tracks slowed; personal events also slowed. Mundane and moderate events fire 1.25x more often. Single gnoll possible."
	welcome_text = "\"In the fief of Zenmarke, there was the odor of decay - and the jingling of mammons close behind..\""
	weight = 4
	always_votable = TRUE
	color_theme = "#888888"
	preferred_gnoll_mode = GNOLL_SCALING_SINGLE

	tag_multipliers = list(
		TAG_HAUNTED = 1.3,
		TAG_TRADE = 1.2,
		TAG_CORRUPTION = 1.2,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.25,
		EVENT_TRACK_PERSONAL = 0.7,
		EVENT_TRACK_MODERATE = 1.25,
		EVENT_TRACK_INTERVENTION = 1.25,
		EVENT_TRACK_CHARACTER_INJECTION = 0.5,
		EVENT_TRACK_OMENS = 1.25,
		EVENT_TRACK_RAIDS = 0.5,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_DEATHS = list("name" = "Total deaths:", "points" = 1.35, "capacity" = 100),
		),
		"Set 2" = list(
			STATS_GRAVES_CONSECRATED = list("name" = "Graves consecrated:", "points" = 6.25, "capacity" = 80),
		),
		"Set 3" = list(
			STATS_GRAVES_ROBBED = list("name" = "Graves robbed:", "points" = -3.75, "capacity" = -40),
		),
		"Set 4" = list(
			STATS_DEADITES_KILLED = list("name" = "Deadites killed:", "points" = 6.25, "capacity" = 90),
		),
		"Set 5" = list(
			STATS_VAMPIRES_KILLED = list("name" = "Vampires killed:", "points" = 12.5, "capacity" = 70),
		),
		"Set 6" = list(
			STATS_SKELETONS_KILLED = list("name" = "Skeletons killed:", "points" = 5, "capacity" = 50),
		),
		"Set 7" = list(
			STATS_SHRINE_VALUE = list("name" = "Value offered to her idol:", "points" = 0.08, "capacity" = 70),
		),
		"Set 8" = list(
			STATS_GREEDY_PEOPLE = list("name" = "Number of greedy people:", "points" = 6.5, "capacity" = 70),
			STATS_INDEBTED = list("name"= "Number of indebted people:", "points" = 5, "capacity" = 25),
		),
		"Set 9" = list(
			STATS_ITEMS_PICKPOCKETED = list("name" = "Items pickpocketed:", "points" = 4.5, "capacity" = 80),
		),
		"Set 10" = list(
			STATS_LOCKS_PICKED = list("name" = "Locks picked:", "points" = 3.75, "capacity" = 80),
		)
	)

	cost_variance = 15

/// Merge of the old Malum (fire, craft) and Pestra (decay, disease, medicine) storytellers.
/datum/storyteller/handwerra
	name = "Handwerra"
	vote_desc = "Effort and care reign. Divine intervention occurs more often. Her favor shines upon masterworks, mineshafts, stitches, and alchemists."
	desc = "Work, alchemy, and medical events get weight bumps. Divine intervention fires 2x more often, personal events 1.2x. All hard antags roll at flat equal weight. Single gnoll possible."
	welcome_text = "The pounding of red-hot steel, the churning of alchemical wonders, and a hundred calloused hands.."
	color_theme = "#D4A56C"
	preferred_gnoll_mode = GNOLL_SCALING_SINGLE

	tag_multipliers = list(
		TAG_WORK = 1.5,
		TAG_ALCHEMY = 1.2,
		TAG_MEDICAL = 1.2,
		TAG_NATURE = 1.1,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_PERSONAL = 1.2,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_INTERVENTION = 2,
		EVENT_TRACK_CHARACTER_INJECTION = 1,
		EVENT_TRACK_OMENS = 1,
		EVENT_TRACK_RAIDS = 1,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_MASTERWORKS_FORGED = list("name" = "Masterworks forged:", "points" = 7, "capacity" = 85),
		),
		"Set 2" = list(
			STATS_ROCKS_MINED = list("name" = "Rocks mined:", "points" = 0.26, "capacity" = 100),
		),
		"Set 3" = list(
			STATS_CRAFT_SKILLS = list("name" = "Craft skills learned:", "points" = 0.4, "capacity" = 80),
		),
		"Set 4" = list(
			STATS_CRAFTED_ITEMS = list("name" = "Crafted items:", "points" = 0.1, "capacity" = 100),
		),
		"Set 5" = list(
			STATS_BEARDS_SHAVED = list("name" = "Beards shaved:", "points" = -4, "capacity" = -40),
			STATS_ALIVE_DWARVES = list("name" = "Number of dwarfs:", "points" = 4, "capacity" = 45),
		),
		"Set 6" = list(
			STATS_POTIONS_BREWED = list("name" = "Potions brewed:", "points" = 5.25, "capacity" = 80),
		),
		"Set 7" = list(
			STATS_WOUNDS_SEWED = list("name" = "Wounds sewed up:", "points" = 0.48, "capacity" = 100),
		),
		"Set 8" = list(
			STATS_ROT_CURED = list("name" = "Rot cured:", "points" = 5, "capacity" = 70),
		),
		"Set 9" = list(
			STATS_FOOD_ROTTED = list("name" = "Food rotted:", "points" = 0.26, "capacity" = 80),
		)
	)

/// Direct successor to the old Dendor storyteller, re-themed around Ignatius's growth/risk/fire domain.
/datum/storyteller/ignatius
	name = "Ignatius"
	vote_desc = "Growth and risk reign. Overgrowth and Verevolves are more likely to occur. His favor shines upon harvests and lycanthropes - gnolls keep their distance from His wilds."
	desc = "Nature events get a 1.5x weight bump. Werewolf is the only roundstart hard antag and gets a 1.5x weight bump - bandits, liches, and vampire lords cannot roll. Intervention fires 2x more often. Gnolls absent."
	welcome_text = "The cackling of perched zads, and the glimmer of ash settling like morning dew.."
	weight = 4
	always_votable = TRUE
	color_theme = "#664422"
	preferred_gnoll_mode = GNOLL_SCALING_NONE

	tag_multipliers = list(
		TAG_NATURE = 1.5,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_PERSONAL = 0.8,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_INTERVENTION = 2,
		EVENT_TRACK_CHARACTER_INJECTION = 1,
		EVENT_TRACK_OMENS = 1,
		EVENT_TRACK_RAIDS = 1,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_TREES_CUT = list("name" = "Trees felled:", "points" = -0.35, "capacity" = -45),
		),
		"Set 2" = list(
			STATS_PLANTS_HARVESTED = list("name" = "Plants harvested:", "points" = 0.75, "capacity" = 100),
		),
		"Set 3" = list(
			STATS_ANIMALS_TAMED = list("name" = "Animals tamed:", "points" = 3, "capacity" = 90),
		),
		"Set 4" = list(
			STATS_FOREST_DEATHS = list("name" = "Forest deaths:", "points" = 6, "capacity" = 90),
		),
		"Set 5" = list(
			STATS_WEREVOLVES = list("name" = "Number of werevolves:", "points" = 12.5, "capacity" = 65),
		),
	)

// OLD KIN

/// Direct successor to the old Graggar storyteller, re-themed around Volkovoi's winter/hunger/cull domain.
/datum/storyteller/volkovoi
	name = "Volkovoi"
	vote_desc = "The cull reigns. Gnolls and assassins prowl more eagerly than under any other god, and raids occur far more often. His favor shines upon bloodshed and the hard arithmetic of a hungry winter."
	desc = "Battle, blood, and war events get weight bumps (1.2x to 1.6x). Gnolls and Assassins are guaranteed roundstart. Raid track gains 2.5x faster. Dynamic gnoll scaling - packs grow with population. Wretch T2 garrison expansion can fire."
	welcome_text = "Plumes of smoke are blown through the streets, reeking of ash and blood.."
	weight = 4
	always_votable = TRUE
	color_theme = "#8B3A3A"
	preferred_gnoll_mode = GNOLL_SCALING_DYNAMIC
	wretch_slot_cap = 15

	tag_multipliers = list(
		TAG_BATTLE = 1.6,
		TAG_BLOOD = 1.3,
		TAG_WAR = 1.2,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.8,
		EVENT_TRACK_PERSONAL = 0.7,
		EVENT_TRACK_MODERATE = 1.2,
		EVENT_TRACK_INTERVENTION = 1.5,
		EVENT_TRACK_CHARACTER_INJECTION = 1,
		EVENT_TRACK_OMENS = 0.9,
		EVENT_TRACK_RAIDS = 2.5,
	)

	influence_sets = list(
		"Set 1" = list(
			STATS_BLOOD_SPILT = list("name" = "Blood spilt:", "points" = 0.03, "capacity" = 60),
		),
		"Set 2" = list(
			STATS_ORGANS_EATEN = list("name" = "Organs eaten:", "points" = 5, "capacity" = 70),
		),
		"Set 3" = list(
			STATS_DEATHS = list("name" = "Deaths:", "points" = 5, "capacity" = 115),
		),
		"Set 4" = list(
			STATS_ASSASSINATIONS = list("name" = "Sucessful assassinations:", "points" = 20, "capacity" = 100),
		),
		"Set 5" = list(
			STATS_PEOPLE_GIBBED = list("name" = "People gibbed:", "points" = 3.5, "capacity" = 55),
		)
	)

	cost_variance = 10  // Less randomness, more direct

/// Direct successor to the old Baotha storyteller, re-themed around Hausvette's harvest/hearth-luck/community-debt domain.
/datum/storyteller/hausvette
	name = "Hausvette"
	vote_desc = "Debt and drink reign. Occurrences are more erratic and negative. Her favor shines upon drunkards, debtors, and the community-bound."
	desc = "Insanity, magic, and disaster events get weight bumps (1.1x to 1.4x). Vampire Lord is guaranteed roundstart - bandits, liches, and werewolves cannot roll. All event tracks accelerated. Gnoll mode randomized. Wretch T2 garrison expansion can fire."
	welcome_text = "The sickly sweet aromas of liqour and spice fills the air.."
	weight = 4
	always_votable = TRUE
	color_theme = "#9933FF"
	preferred_gnoll_mode = GNOLL_SCALING_RANDOM
	wretch_slot_cap = 15

	tag_multipliers = list(
		TAG_INSANITY = 1.4,
		TAG_MAGIC = 1.2,
		TAG_DISASTER = 1.1,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.1,
		EVENT_TRACK_PERSONAL = 1.2,
		EVENT_TRACK_MODERATE = 1.3,
		EVENT_TRACK_INTERVENTION = 2,
		EVENT_TRACK_CHARACTER_INJECTION = 0.7,
		EVENT_TRACK_OMENS = 1.5,
		EVENT_TRACK_RAIDS = 1.2,
	)

	cost_variance = 30  // Makes events more erratic in timing

	influence_sets = list(
		"Set 1" = list(
			STATS_JUNKIES = list("name" = "Number of junkies:", "points" = 9, "capacity" = 70),
		),
		"Set 2" = list(
			STATS_DRUGS_SNORTED = list("name" = "Drugs snorted:", "points" = 4, "capacity" = 85),
		),
		"Set 3" = list(
			STATS_ALCOHOLICS = list("name" = "Number of alcoholics:", "points" = 3.25, "capacity" = 60),
		),
		"Set 4" = list(
			STATS_ALCOHOL_CONSUMED = list("name" = "Alcohol consumed:", "points" = 0.042, "capacity" = 90),
		),
		"Set 5" = list(
			STATS_NYMPHOMANIACS = list("name" = "Number of nymphomaniacs:", "points" = 6, "capacity" = 30),
		),
		"Set 6" = list(
			STATS_PLEASURES = list("name" = "Pleasures had:", "points" = 5, "capacity" = 50),
		),
	)

// UNVEILED

/// Direct successor to the old Zizo storyteller, re-themed around Aurelian's unveiled-heresy domain.
/datum/storyteller/aurelian
	name = "Aurelian"
	vote_desc = "Unveiling reigns. Liches stir more readily than under any other god, and Deadites are far more vicious. Her favor shines upon corpses; be they holy, noble, or reanimated - and upon the shrines she unmakes."
	desc = "Magical, gamble, trickery, and unexpected events get weight bumps (1.2x to 1.5x). Lich is guaranteed roundstart - bandits, werewolves, and vampire lords cannot roll. High event cost variance. Flat gnoll spawn (15% chance, 2 cap). Wretch T2 garrison expansion can fire."
	welcome_text = "A breeze of morbid air, ferrying the howls of the damned.."
	weight = 4
	always_votable = TRUE
	color_theme = "#CC4444"
	preferred_gnoll_mode = GNOLL_SCALING_FLAT
	wretch_slot_cap = 15

	tag_multipliers = list(
		TAG_MAGICAL = 1.2,
		TAG_GAMBLE = 1.5,
		TAG_TRICKERY = 1.3,
		TAG_UNEXPECTED = 1.2,
	)

	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_PERSONAL = 1.2,
		EVENT_TRACK_MODERATE = 1.1,
		EVENT_TRACK_INTERVENTION = 1.5,
		EVENT_TRACK_CHARACTER_INJECTION = 1,
		EVENT_TRACK_OMENS = 1.3,
		EVENT_TRACK_RAIDS = 0.8,
	)

	cost_variance = 50  // Events will be highly variable in cost

	influence_sets = list(
		"Set 1" = list(
			STATS_HUMEN_DEATHS = list("name" = "Humen killed:", "points" = 5.5, "capacity" = 80),
			STATS_CLERGY_DEATHS = list("name" = "Clergy killed:", "points" = 12, "capacity" = 70),
		),
		"Set 2" = list(
			STATS_DEADITES_WOKEN_UP = list("name" = "Deadites woken up:", "points" = 4, "capacity" = 85),
		),
		"Set 3" = list(
			STATS_DEADITES_ALIVE = list("name" = "Deadites alive:", "points" = 1, "capacity" = 40),
		),
		"Set 4" = list(
			STATS_LUX_HARVESTED = list("name" = "Clergy killed:", "points" = 12, "capacity" = 70),
		),
		"Set 5" = list(
			STATS_TORTURES = list("name" = "Tortures performed:", "points" = 5.25, "capacity" = 70),
		),
		"Set 6" = list(
			STATS_BOOKS_BURNED = list("name" = "Books burned:", "points" = 5, "capacity" = 50), //We actually gain influence from it
		),
	)

#undef CONCORDAT_STORYTELLERS
#undef SEVERANCE_STORYTELLERS
#undef OLDKIN_STORYTELLERS
#undef TRIBUNAL_STORYTELLERS
#undef UNVEILED_STORYTELLERS
