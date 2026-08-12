// Organic internal wounds — adapted from CEV-Eris for DreamValley
// These represent injuries to internal organs that progress and can be treated

/datum/internal_wound/organic
	diagnosis_stat = STAT_INTELLIGENCE
	wound_nature = WOUND_NATURE_ORGANIC

// ============== BLUNT TRAUMA ==============

/datum/internal_wound/organic/blunt
	treatments_item = list(/obj/item/natural/cloth/bandage = 1)
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 5)
	severity = 0
	severity_max = 5
	hal_damage = IWOUND_MEDIUM_DAMAGE

/datum/internal_wound/organic/blunt/rupture
	name = "rupture"

/datum/internal_wound/organic/blunt/hemorrhage
	name = "internal hemorrhage"

/datum/internal_wound/organic/blunt/contusion
	name = "contusion"

// ============== SHARP/PUNCTURE TRAUMA ==============

/datum/internal_wound/organic/sharp
	treatments_item = list(/obj/item/natural/cloth/bandage = 2)
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 8)
	severity = 0
	severity_max = 5
	next_wound = /datum/internal_wound/organic/swelling
	hal_damage = IWOUND_MEDIUM_DAMAGE

/datum/internal_wound/organic/sharp/perforation
	name = "perforation"

/datum/internal_wound/organic/sharp/cavity
	name = "cavitation"

/datum/internal_wound/organic/sharp/gore
	name = "gored tissue"

// ============== LACERATIONS ==============

/datum/internal_wound/organic/edge
	treatments_item = list(/obj/item/natural/cloth/bandage = 2)
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 8)
	severity = 0
	severity_max = 5
	next_wound = /datum/internal_wound/organic/swelling
	hal_damage = IWOUND_MEDIUM_DAMAGE

/datum/internal_wound/organic/edge/laceration
	name = "laceration"

/datum/internal_wound/organic/edge/gash
	name = "deep gash"

/datum/internal_wound/organic/edge/rip
	name = "ripped tissue"

// ============== BURN WOUNDS ==============

/datum/internal_wound/organic/burn
	treatments_item = list(/obj/item/reagent_containers/food/snacks/rogue/honey = 1)
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 10, /datum/reagent/consumable/honey = 5)
	stabilizers_chem = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/honey = 2)
	severity = 0
	severity_max = 5
	next_wound = /datum/internal_wound/organic/infection
	hal_damage = IWOUND_MEDIUM_DAMAGE

/datum/internal_wound/organic/burn/scorch
	name = "scorched tissue"

/datum/internal_wound/organic/burn/char
	name = "charred tissue"

/datum/internal_wound/organic/burn/incinerate
	name = "incinerated flesh"

// ============== NECROSIS ==============

/datum/internal_wound/organic/necrosis_start
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 15)
	stabilizers_chem = list(/datum/reagent/medicine/salglu_solution = 2)
	severity = 0
	severity_max = 1
	next_wound = /datum/internal_wound/organic/necrosis

/datum/internal_wound/organic/necrosis_start/damaged_tissue
	name = "damaged tissue"

/datum/internal_wound/organic/necrosis
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 20)
	severity = 0
	severity_max = 3
	next_wound = /datum/internal_wound/organic/infection
	hal_damage = IWOUND_LIGHT_DAMAGE

/datum/internal_wound/organic/necrosis/dying
	name = "necrotizing tissue"

// ============== POISONING ==============

/datum/internal_wound/organic/poisoning
	treatments_item = list(/obj/item/natural/cloth/bandage = 1)
	treatments_chem = list(/datum/reagent/medicine = 5)
	severity = 0
	severity_max = 4
	hal_damage = IWOUND_LIGHT_DAMAGE
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_AGGRAVATION
	progression_threshold = IWOUND_1_MINUTE

/datum/internal_wound/organic/poisoning/pustule
	name = "pustule"

/datum/internal_wound/organic/poisoning/poisoning
	name = "minor poisoning"

/datum/internal_wound/organic/poisoning/accumulation
	name = "foreign accumulation"
	hal_damage = IWOUND_MEDIUM_DAMAGE

// ============== INFECTION ==============

/datum/internal_wound/organic/infection
	treatments_chem = list(/datum/reagent/medicine = 10, /datum/reagent/consumable/honey = 8)
	stabilizers_chem = list(/datum/reagent/consumable/honey = 2, /datum/reagent/consumable/sugar = 3)
	severity = 0
	severity_max = 4
	next_wound = /datum/internal_wound/organic/necrosis
	hal_damage = IWOUND_LIGHT_DAMAGE
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_PROGRESS|IWOUND_SPREAD
	spread_threshold = 3

/datum/internal_wound/organic/infection/abscess
	name = "abscess"

/datum/internal_wound/organic/infection/sepsis
	name = "sepsis"
	severity_max = 5
	hal_damage = IWOUND_HEAVY_DAMAGE

// ============== INFLAMMATION ==============

/datum/internal_wound/organic/hepatitis
	name = "inflammation"
	characteristic_flag = IWOUND_AGGRAVATION
	organ_efficiency_multiplier = -0.10
	next_wound = /datum/internal_wound/organic/fibrosis
	progression_threshold = IWOUND_1_MINUTE

/datum/internal_wound/organic/fibrosis
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_AGGRAVATION
	severity_max = 4
	next_wound = /datum/internal_wound/organic/cirrhosis
	progression_threshold = IWOUND_1_MINUTE

/datum/internal_wound/organic/fibrosis/scarred
	name = "scarring"

/datum/internal_wound/organic/cirrhosis
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_AGGRAVATION
	severity_max = 4
	progression_threshold = IWOUND_2_MINUTES

/datum/internal_wound/organic/cirrhosis/scarred
	name = "severe scarring"

// ============== SWELLING ==============

/datum/internal_wound/organic/swelling
	treatments_item = list(/obj/item/natural/cloth/bandage = 1)
	treatments_chem = list(/datum/reagent/medicine/salglu_solution = 5)
	severity = 0
	severity_max = 3
	hal_damage = IWOUND_LIGHT_DAMAGE
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_AGGRAVATION

/datum/internal_wound/organic/swelling/inflamed
	name = "inflamed tissue"

/datum/internal_wound/organic/swelling/edema
	name = "edema"

// ============== MAGICAL/PSYCHIC WOUNDS ==============

/datum/internal_wound/organic/psy_damage
	name = "soul damage"
	treatments_chem = list(/datum/reagent/medicine = 15)
	severity = 0
	severity_max = 3
	psy_damage = 2
	characteristic_flag = IWOUND_CAN_DAMAGE|IWOUND_PROGRESS|IWOUND_HALLUCINATE
	progression_threshold = IWOUND_2_MINUTES

/datum/internal_wound/organic/psy_damage/corruption
	name = "corruption"
	psy_damage = 3

/datum/internal_wound/organic/psy_damage/haunting
	name = "haunting"
	psy_damage = 4
	ticks_per_hallucination = IWOUND_1_MINUTE
