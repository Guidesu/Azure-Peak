

// Sexcon defines ported from Ratwood-2.0.
// Most of the sexcon defines (MAX_AROUSAL, SEX_SPEED_*, SEX_FORCE_*, etc.) already
// exist in code/__DEFINES/sex.dm from the old sexcon2 system. This file only contains
// defines that are NEW in Ratwood's sexcon and not already defined in sex.dm.

#define AROUSAL_MID_UNHORNY_RATE (0.4 / (1 SECONDS))
#define AROUSAL_LOW_UNHORNY_RATE (0.2 / (1 SECONDS))

#define IMPREG_PROB_INCREMENT 10
#define IMPREG_PROB_MAX 95

#define SEX_CATEGORY_MISC (1<<0)
#define SEX_CATEGORY_HANDS (1<<1)
#define SEX_CATEGORY_PENETRATE (1<<2)

#define SEX_ACTION_INTIMATE_CHECK_NONE 0
#define SEX_ACTION_INTIMATE_CHECK_USER (1<<0)
#define SEX_ACTION_INTIMATE_CHECK_TARGET (1<<1)
#define SEX_ACTION_INTIMATE_CHECK_BOTH (SEX_ACTION_INTIMATE_CHECK_USER|SEX_ACTION_INTIMATE_CHECK_TARGET)

/proc/build_sex_actions()
	. = list()
	for(var/path in typesof(/datum/sex_action))
		if(is_abstract(path))
			continue
		.[path] = new path()
	return .

/////////////////

// Called when a bodypart is checked from an action: /datums/sexcon/sexcon.dm
#define COMSIG_ERP_LOCATION_ACCESSIBLE "erp_location_accessible"
	// Bitflags
	#define SIG_CHECK_FAIL (1 << 0)
	#define SKIP_ADJACENCY_CHECK (1 << 1)
	#define SKIP_TILE_CHECK (1 << 2)
	#define SKIP_GRAB_CHECK (1 << 3)
	// Args
	#define ERP_ACTION 1
	#define ERP_BODYPART 2
	#define ERP_SELF_TARGET 3
	#define ERP_USER 4
	#define ERP_TARGET 5
	#define ERP_LOCATION 6
	#define ERP_GRABS 7
	#define ERP_SKIPUNDIES 8
