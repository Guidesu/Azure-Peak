// Twilight-Axis compatibility DEFINES for DreamValley
// This file must be included BEFORE any Twilight code that uses these defines.

// Job priority defines
#define JP_BOOST 1
#define JOB_PREF_UI_HIGH 3
#define JOB_PREF_UI_NEVER 0
#define JOB_PREF_UI_LOW 1
#define JOB_PREF_UI_BOOST 4
#define JOB_PREF_UI_MEDIUM 2

// Gwynt music channel
#define CHANNEL_GWYNT_MUSIC 777

// Threat region defines
#define THREAT_REGION_DESERT_NEAR "desert_near"
#define THREAT_REGION_DESERT_DEEP "desert_deep"
#define THREAT_REGION_DESERTDARK "desertdark"
#define THREAT_REGION_DESERTDARK_DEEP "desertdark_deep"
#define THREAT_REGION_AZURE_BASIN "azure_basin"
#define THREAT_REGION_AZURE_GROVE "azure_grove"
#define THREAT_REGION_AZUREAN_COAST "azurean_coast"
#define THREAT_REGION_ROCKHILL_BASIN "rockhill_basin"
#define THREAT_REGION_ROCKHILL_BOG_NORTH "rockhill_bog_north"
#define THREAT_REGION_ROCKHILL_BOG_WEST "rockhill_bog_west"
#define THREAT_REGION_ROCKHILL_BOG_SOUTH "rockhill_bog_south"
#define THREAT_REGION_ROCKHILL_BOG_SUNKMIRE "rockhill_bog_sunkmire"
#define THREAT_REGION_ROCKHILL_WOODS_NORTH "rockhill_woods_north"
#define THREAT_REGION_ROCKHILL_WOODS_SOUTH "rockhill_woods_south"
#define THREAT_REGION_ROCKHILL_OUTER_GROVE "rockhill_outer_grove"
#define THREAT_REGION_AL_ASHUR_OASIS "al_ashur_oasis"
#define THREAT_REGION_AL_ASHUR_CARAVAN_ROAD "al_ashur_caravan_road"
#define THREAT_REGION_AL_ASHUR_SPICE_DUNES "al_ashur_spice_dunes"
#define THREAT_REGION_AL_ASHUR_DEEP_DUNES "al_ashur_deep_dunes"
#define THREAT_REGION_AL_ASHUR_SUNKEN_RUINS "al_ashur_sunken_ruins"

// Trade region defines (Twilight uses TRADE_REGION_ prefix)
#define TRADE_REGION_AL_ASHUR_OASIS "al_ashur_oasis"
#define TRADE_REGION_AL_ASHUR_CARAVAN_ROAD "al_ashur_caravan_road"
#define TRADE_REGION_AL_ASHUR_SPICE_DUNES "al_ashur_spice_dunes"
#define TRADE_REGION_AL_ASHUR_GIZA_ROUTE "al_ashur_giza_route"
#define TRADE_REGION_AL_ASHUR_SUNKEN_RUINS "al_ashur_sunken_ruins"

// Character tags for enigma roles
#define CTAG_ROYALSERGEANT "royalsergeant"
#define CTAG_BAILIFF "bailiff"
#define CTAG_MAYOR "mayor"
#define CTAG_COURTPHYSICIAN "courtphysician"
#define CTAG_ROYALGUARD_ENIGMA "royalguard_enigma"
#define CTAG_SHERIFF "sheriff"
#define CTAG_VANGUARD "vanguard"
#define CTAG_WATCHMAN "watchman"
#define CTAG_WARDEN_ENIGMA "warden_enigma"
#define CTAG_KNIGHT_ENIGMA "knight_enigma"
#define CTAG_OVERSEER "overseer"
#define CTAG_TOWN_WATCH "town_watch"
#define CTAG_ROYALKNIGHT "royalknight"

// Job name defines for enigma roles
#define BAILIFF "Bailiff"
#define MAYOR "Mayor"
#define COURTPHYSICIAN "Court Physician"
#define ROYALGUARD "Royal Guard"
#define ROYALSERGEANT "Royal Sergeant"
#define SHERIFF "Sheriff"
#define CITYWATCH "City Watch"
#define TOWNWATCH "Town Watch"
#define VANGUARD "Vanguard"
#define VANGUARDS "Vanguards"
#define OVERSEER "Overseer"
#define ROYALKNIGHT "Royal Knight"

// Job display order defines
#define JDO_BAILIFF 100
#define JDO_MAYOR 101
#define JDO_COURTPHYSICIAN 102
#define JDO_ROYALGUARD 103
#define JDO_ROYALSERGEANT 104
#define JDO_SHERIFF 105
#define JDO_TOWNWATCH 106
#define JDO_VANGUARD 107
#define JDO_OVERSEER 108
#define JDO_ROYALKNIGHT 109

// Job color defines
#define JCOLOR_CITYWATCH "#3a5a7a"
#define JCOLOR_VANGUARD "#4a6a3a"

// Bitflag defines for enigma roles
#define BITFLAG_CITYWATCH 1024
#define BITFLAG_VANGUARD 2048

// Role defines
#define ROLE_ZIZOIDCULTIST "zizoidcultist"
#define ROLE_CULT "cult"

// Antag HUD defines
#define ANTAG_HUD_ZIZOID "zizoid"

// Trait defines
#define TRAIT_VOLF "volf"
#define TRAIT_MAGIC_SHIELD "magic_shield"
#define TRAIT_ZIZOEYES "zizoeyes"
#define TRAIT_WOUNDREGEN "woundregen"
#define TRAIT_NO_RUNECHAT_ANIMATION "no_runechat_animation"
#define TRAIT_VILLAIN "villain"
#define TRAIT_SHAKY_SPEECH "shaky_speech"
#define TRAIT_ZIZOID_HUNTED "zizoid_hunted"

// Economic realm defines
#define REALM_ZYBANTU "zybantu"
#define REALM_VALORIA "valoria"
#define REALM_HAMMERHOLD_TA "hammerhold_ta"

// Omen defines
#define OMEN_ASCEND "ascend"

// Clean type defines
#define CLEAN_TYPE_LIGHT_DECAL 4096

// Clothing color defines
#define CLOTHING_AZURE "#4a7aaa"

// Detail text defines
#define DETAIL_TEXT_UNIVERSITY_OF_AZURIA "university_of_azuria"

// Stat tracking defines
#define STATS_ASTRATA_REVIVALS "astrata_revivals"

// Armor defines
#define ARMOR_CULTNECK 15

// Mob descriptor slot defines
#define MOB_DESCRIPTOR_SLOT_DEFIANT "defiant"

// Status effect IDs
#define STATUS_EFFECT_BALL_KICK_RECOVERY "ball_kick_recovery"

// Missing martyr procs (defined here so they're available before martyr code)
/proc/martyr_ult_active(mob/living/carbon/human/user)
	return FALSE

/proc/get_martyr_component_for(mob/living/carbon/human/user)
	return null
