/datum/virtue/origin
	var/map_group_order = 4
	var/map_state_order = 1
	var/map_origin_order = 1
	var/map_visible = FALSE
	var/map_x = 50
	var/map_y = 50
	var/map_state_id
	var/map_state_name
	var/map_origin_name
	var/list_group_id
	var/list_group_name
	var/list_group_order = 0
	var/list_item_order = 0
	var/list_subgroup_name

/datum/virtue/origin/unknown
	map_group_order = 4
	map_state_order = 100
	map_origin_order = 1
	map_visible = FALSE
	map_x = 50.0
	map_y = 50.0
	map_state_id = "unknown"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 100
	list_item_order = 1
	name = "Nowhere"
	origin_name = "Elsewhere"
	desc = ""
	origin_desc = "   ,   ,     —   , \
	  ,    ,       .    , \
	       ,       , \
	   — , , ,   ."

/datum/virtue/origin/azuria
	map_group_order = 1
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.4
	map_y = 38.8
	map_state_id = "azuria"
	map_state_name = ""
	map_origin_name = ""
	name = "Azurian"
	origin_name = "Azuria"
	desc = ""
	restricted = FALSE
	added_languages = list(/datum/language/oldazurian)
	origin_desc = ""

/datum/virtue/origin/enigma
	map_group_order = 3
	map_state_order = 3
	map_origin_order = 1
	map_visible = TRUE
	map_x = 64.2
	map_y = 75.0
	map_state_id = "enigma"
	map_state_name = ""
	map_origin_name = ""
	name = "Enigmian"
	origin_name = "Enigma"
	desc = ""
	restricted = FALSE
	origin_desc = ""

/datum/virtue/origin/grenzelhoft
	map_group_order = 1
	map_state_order = 4
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.3
	map_y = 47.4
	map_state_id = "grenzelhoft"
	map_state_name = ""
	map_origin_name = ""
	name = "Grenzelhoftian"
	origin_name = "Grenzelhoft"
	added_languages = list(/datum/language/grenzelhoftian)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/valorian
	map_group_order = 1
	map_state_order = 2
	map_origin_order = 1
	map_visible = TRUE
	map_x = 26.4
	map_y = 36.1
	map_state_id = "valoria"
	map_state_name = ""
	map_origin_name = ""
	name = "Valorian"
	origin_name = "Valoria"
	added_languages = list(/datum/language/valorian)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/heartfelt
	map_group_order = 3
	map_state_order = 6
	map_origin_order = 1
	map_visible = TRUE
	map_x = 33.0
	map_y = 33.0
	map_state_id = "heartfelt"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 6
	list_item_order = 1
	name = "Heartfeltian"
	origin_name = "Heartfelt"
	desc = ""
	origin_desc = ""

/datum/virtue/origin/etrusca
	map_group_order = 3
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 43.9
	map_y = 40.2
	map_state_id = "etrusca"
	map_state_name = ""
	map_origin_name = ""
	name = "Etruscan"
	origin_name = "Etrusca"
	added_languages = list(/datum/language/etruscan)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/otava
	map_group_order = 3
	map_state_order = 5
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.1
	map_y = 90.2
	map_state_id = "otava"
	map_state_name = ""
	map_origin_name = ""
	name = "Otavan"
	origin_name = "Otava"
	added_languages = list(/datum/language/otavan)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/gronn
	map_group_order = 1
	map_state_order = 5
	map_origin_order = 1
	map_visible = TRUE
	map_x = 11.3
	map_y = 31.6
	map_state_id = "gronn"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "gronn"
	list_group_name = ""
	name = "Gronnic"
	origin_name = "Gronn"
	added_languages = list(/datum/language/gronnic)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/racial/crimson_lands
	map_group_order = 1
	map_state_order = 6
	map_origin_order = 1
	map_visible = TRUE
	map_x = 26.5
	map_y = 69.3
	map_state_id = "crimson_lands"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "crimson_lands"
	list_group_name = ""
	list_group_order = 7
	list_item_order = 1
	name = "Crimsonlander"
	origin_name = "Crimson Lands"
	added_languages = list(/datum/language/raneshi)
	races = list(/datum/species/anthromorph,
				/datum/species/anthromorphsmall)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/raneshen
	map_group_order = 1
	map_state_order = 7
	map_origin_order = 1
	map_visible = TRUE
	map_x = 50.4
	map_y = 71.6
	map_state_id = "raneshen"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "zybantian_empire"
	list_group_name = ""
	list_group_order = 8
	list_item_order = 3
	list_subgroup_name = ""
	name = "Zybantu - Ranesheni"
	origin_name = "Raneshan"
	added_languages = list(/datum/language/raneshi)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/naledi
	map_group_order = 1
	map_state_order = 8
	map_origin_order = 1
	map_visible = TRUE
	map_x = 34.7
	map_y = 77.5
	map_state_id = "naledi"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "zybantian_empire"
	list_group_name = ""
	list_group_order = 8
	list_item_order = 2
	list_subgroup_name = ""
	name = "Zybantu - Naledian"
	origin_name = "Naledi"
	added_languages = list(/datum/language/raneshi)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/zybantian
	map_group_order = 1
	map_state_order = 9
	map_origin_order = 1
	map_visible = TRUE
	map_x = 40.8
	map_y = 67.4
	map_state_id = "zybantu"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "zybantian_empire"
	list_group_name = ""
	list_group_order = 8
	list_item_order = 1
	name = "Zybantian"
	origin_name = "Zybantu"
	added_languages = list(/datum/language/raneshi)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/kazengun
	map_group_order = 3
	map_state_order = 4
	map_origin_order = 1
	map_visible = TRUE
	map_x = 84.8
	map_y = 66.9
	map_state_id = "kazengun"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "kazengun"
	list_group_name = ""
	list_group_order = 7
	list_item_order = 1
	name = "Kazengun - Mainlander"
	origin_name = "Kazengun"
	added_languages = list(/datum/language/kazengunese)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/lingyue
	map_group_order = 3
	map_state_order = 7
	map_origin_order = 1
	map_visible = TRUE
	map_x = 81.3
	map_y = 36.4
	map_state_id = "jeoseon"
	map_state_name = ""
	map_origin_name = ""
	list_group_id = "kazengun"
	list_group_name = ""
	list_group_order = 7
	list_item_order = 2
	name = "Kazengun - Jeoseonese"
	origin_name = "Kazengun"
	added_languages = list(/datum/language/lingyuese)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/gyedzenese
	map_group_order = 2
	map_state_order = 3
	map_origin_order = 1
	map_visible = TRUE
	map_x = 72.4
	map_y = 36.6
	map_state_id = "gyedzai"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 3
	list_item_order = 1
	name = "Gyedzenese"
	origin_name = "Gyedzai"
	added_languages = list(/datum/language/gyedzenese)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/hammerhold
	map_group_order = 1
	map_state_order = 10
	map_origin_order = 1
	map_visible = TRUE
	map_x = 23.1
	map_y = 18.8
	map_state_id = "hammerhold"
	map_state_name = ""
	map_origin_name = ""
	name = "Hammerholdian"
	origin_name = "Hammerhold"
	added_languages = list(/datum/language/elvish)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/avar
	map_group_order = 2
	map_state_order = 2
	map_origin_order = 1
	map_visible = TRUE
	map_x = 62.2
	map_y = 24.8
	map_state_id = "aavnr"
	map_state_name = ""
	map_origin_name = ""
	name = "Aavnic"
	origin_name = "Avar"
	added_languages = list(/datum/language/aavnic)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/racial/lirvas
	map_group_order = 2
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 75.3
	map_y = 48.5
	map_state_id = "lirvas"
	map_state_name = ""
	map_origin_name = ""
	name = "Lirvasian"
	origin_name = "Lirvas"
	added_languages = list(/datum/language/draconic)
	races = list(/datum/species/kobold,
				/datum/species/lizardfolk,
				/datum/species/anthromorph,
				/datum/species/dracon)
	desc = ""
	origin_desc = ""

/datum/virtue/origin/racial/underdark
	map_group_order = 4
	map_state_order = 3
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "underdark"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 3
	list_item_order = 1
	name = "Underdweller"
	origin_name = "the Underdark"
	desc = ""
	added_languages = list(/datum/language/undercommon)
	races = list(/datum/species/elf/dark,
				/datum/species/human/halfelf,
				/datum/species/kobold,
				/datum/species/dwarf/mountain,
				/datum/species/dwarf/gnome,
				/datum/species/goblinp,
				/datum/species/anthromorphsmall,
				/datum/species/ooze)
	origin_desc = ""

/datum/virtue/origin/racial/underdark_drow
	map_group_order = 4
	map_state_order = 3
	map_origin_order = 2
	map_visible = FALSE
	map_state_id = "underdark"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 3
	list_item_order = 2
	name = "Underdweller - Drow Cities"
	origin_name = "the Underdark"
	desc = ""
	added_languages = list(/datum/language/undead)
	races = list(/datum/species/elf/dark,
				/datum/species/human/halfelf)
	origin_desc = ""

/datum/virtue/origin/racial/akhdruk
	map_group_order = 4
	map_state_order = 4
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "akhdruk"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 4
	list_item_order = 1
	name = "Akhdruki"
	added_languages = list(/datum/language/dwarvish)
	origin_name = "Drud Akhdruk"
	desc = ""
	races = list(/datum/species/dwarf/mountain,
				/datum/species/dwarf/gnome)
	origin_desc = ""

/datum/virtue/origin/racial/infernal
	map_group_order = 4
	map_state_order = 5
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "infernal"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 5
	list_item_order = 1
	name = "Infernal"
	added_languages = list(/datum/language/hellspeak)
	origin_name = "the Inferno"
	desc = ""
	races = list(/datum/species/tieberian,
				/datum/species/dullahan,
				/datum/species/demihuman)
	origin_desc = ""

/datum/virtue/origin/racial/ancient
	map_group_order = 4
	map_state_order = 6
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "ancient"
	map_state_name = ""
	map_origin_name = ""
	list_group_order = 6
	list_item_order = 1
	name = "Ancient"
	origin_name = "Age Long Gone"
	added_languages = list(/datum/language/celestial)
	desc = ""
	races = list(/datum/species/elf/wood,
				/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/aasimar,
				/datum/species/dracon)
	origin_desc = ""
