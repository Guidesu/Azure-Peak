// Structures used by byos.dmm. See per-item notes below.

/obj/structure/bars/grille/rusty
	name = "rusty grille"
	desc = "A few good hits ought to smash it open."
	max_integrity = 70
	color = "#d9c8c1"

/obj/structure/bars/rusty
	name = "rusty bars"
	desc = "these look fragile"
	color ="#ffcd9f"
	max_integrity = 200

/obj/structure/chair/smallbench
	name = "small bench"
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "benchsmall"
	buildstackamount = 1
	item_chair = null
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"
	sleepy = 0.5
	layer = OBJ_LAYER
	density = FALSE

/obj/structure/curtain/directional/red
	color = "#a32121"

/obj/structure/lever/cursed
	name = "Cursed Lever"
	desc = "A lever radiating a sinister aura. Only those of a certain allegiance may touch it."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "leverwall0"
	var/allowed_factions = null // List of factions allowed to use this lever, e.g. list("orcs", "tribe")

/obj/structure/lever/cursed/attack_hand(mob/user)
	if(!istype(user, /mob/living))
		return
	var/mob/living/L = user
	if(src.allowed_factions && (!L.faction || !length(src.allowed_factions & L.faction)))
		to_chat(user, "<span class='danger'>A dark force repels your hand!</span>")
		playsound(src, 'sound/magic/magic_nulled.ogg', 50)
		return
	. = ..()
	icon_state = "leverwall[toggled]"

/obj/structure/lever/cursed/onkick(mob/user)
	if(!istype(user, /mob/living))
		return
	var/mob/living/L = user
	if(src.allowed_factions && (!L.faction || !length(src.allowed_factions & L.faction)))
		to_chat(user, "<span class='danger'>A dark force repels your kick!</span>")
		playsound(src, 'sound/magic/magic_nulled.ogg', 50)
		return
	. = ..()
	icon_state = "leverwall[toggled]"

/obj/structure/fluff/psycross/psycrucifix/stone
	name = "stone psydonic crucifix"
	desc = "Formed of stone, this great Psycross symbolises that HE is forever ENDURING. Considered a rare sight upon the vale."
	icon_state = "psycruci_r"
	max_integrity = 120
	chance2hear = 10

/obj/structure/fluff/psycross/psycrucifix/silver
	name = "silver psydonic crucifix"
	icon_state = "psycruci_s"
	desc = "Constructed of Blessed Silver, this crucifix symbolises absolute faith in the ONE - For PSYDON WEEPS, for all mortal ilk. PSYDON WEEPS, for all who walk upon the soil. PSYDON WEEPS..."
	attacked_sound = list("sound/combat/hits/onmetal/metalimpact (1).ogg", "sound/combat/hits/onmetal/metalimpact (2).ogg")

/obj/structure/fluff/walldeco/mercenaryflag
	name = "mercenary guild banner"
	desc = "A rugged white banner stitched with a blood-red sparrow, the mark of the Mercenary Guild. A loose confederation of smaller mercenary companies and independent contractors, they can be trusted as far as you can spend your gold."
	icon_state = "sparrow"

// ---------------------------------------------------------------------------
// Jungle flora. Parents /obj/structure/flora/roguetree, /roguegrass,
// /rogueshroom already exist in this codebase; these leaves were missing.

#define BYOS_COLOR_JUNGLE "#9bb6ae"

/obj/structure/flora/roguegrass/bush/jungle
	name = "jungle bush"
	desc = ""
	color = BYOS_COLOR_JUNGLE
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "bushb"

/obj/structure/flora/roguegrass/bush/jungle/Initialize(mapload)
	. = ..()
	if(prob(30))
		icon_state = "busha[rand(1, 3)]"
	else if(prob(50))
		icon_state = "bushb[rand(1, 3)]"
	else
		icon_state = "bushc[rand(1, 3)]"

/obj/structure/flora/roguegrass/bush/jungle/large
	color = BYOS_COLOR_JUNGLE
	icon = 'icons/obj/flora/largejungleflora.dmi'
	icon_state = "bush"
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER
	opacity = TRUE
	attacked_sound = 'sound/misc/woodhit.ogg'
	max_integrity = 100
	debris = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 1, /obj/item/grown/log/tree/small = 1)
	static_debris = list(/obj/item/grown/log/tree/small = 1)

/obj/structure/flora/roguegrass/bush/jungle/large/Initialize(mapload)
	. = ..()
	icon_state = "bush[pick(1,2,3)]"

/obj/structure/flora/roguegrass/jungle
	name = "jungle grass"
	desc = ""
	color = BYOS_COLOR_JUNGLE
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa"

/obj/structure/flora/roguegrass/jungle/Initialize(mapload)
	. = ..()
	icon_state = "grassa[rand(1, 5)]"

/obj/structure/flora/roguegrass/jungle/sparse
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassb"

/obj/structure/flora/roguegrass/jungle/sparse/Initialize(mapload)
	. = ..()
	icon_state = "grassb[rand(1, 5)]"

/obj/structure/flora/roguetree/jungle //version with mechanics this time
	name = "jungle tree"
	color = BYOS_COLOR_JUNGLE
	stump_type = /obj/structure/flora/roguetree/stump/palm
	icon = 'icons/obj/flora/jungletrees.dmi'
	icon_state = "tree"
	pixel_x = -48
	pixel_y = -20
	max_integrity = 300
	debris = list(/obj/item/grown/log/tree/stick = 2)
	static_debris = list(/obj/item/grown/log/tree = 3)

/obj/structure/flora/roguetree/jungle/Initialize(mapload)
	. = ..()
	icon_state = "tree[rand(1, 6)]"

/obj/structure/flora/roguetree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	max_integrity = 200
	debris = list(/obj/item/grown/log/tree/stick = 2)
	static_debris = list(/obj/item/grown/log/tree = 2)

/obj/structure/flora/roguetree/jungle/small/Initialize(mapload)
	. = ..()
	icon_state = "tree[rand(1, 6)]"

// Never explicitly declared upstream either (only referenced as a
// stump_type/spawn-table value) — DM auto-creates this as an empty stub
// inheriting from /obj/structure/flora/roguetree/stump, matching upstream
// behavior exactly.
/obj/structure/flora/roguetree/stump/palm
	name = "palm stump"
	desc = "Shade no more."

#undef BYOS_COLOR_JUNGLE

// rogueshroom "unhappy" (underdark mushroom) family — real behavior (light,
// screams, rare bonus drop on destruction), not decorative-only, ported in full.
/obj/structure/flora/rogueshroom/unhappy
	name = "corpse fungus"
	icon_state = "scarymush"
	icon = 'icons/roguetown/misc/foliagemushroom48x64.dmi'
	desc = "This mushroom looks alive and thinking, giving you mush to think about."
	random_mush_zone = FALSE
	max_integrity = 240
	pixel_x = -8
	var/mush_light_range = 3
	var/mush_light_power = 3
	var/mush_light_color = "#850707"
	var/mush_animate = TRUE
	var/mush_scream = TRUE
	var/list/abyssal_screams = list(
		'sound/effects/ghost.ogg',
		'sound/misc/astratascream.ogg'
	)

/obj/structure/flora/rogueshroom/unhappy/Initialize(mapload)
	. = ..()
	if(mush_animate)
		animate(src, icon_state = "[icon_state]animated", delay = rand(1, 100), loop = -1, time = 10)
	if(mush_light_power > 0)
		set_light(mush_light_range, mush_light_range, mush_light_power, l_color = mush_light_color)

/obj/structure/flora/rogueshroom/unhappy/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(damage_amount > 0 && mush_scream)
		playsound(src, pick(abyssal_screams), 50, FALSE)

/obj/structure/flora/rogueshroom/unhappy/obj_destruction(damage_flag)
	playsound(src, pick(abyssal_screams), 60, FALSE)
	. = ..()

/obj/structure/flora/rogueshroom/unhappy/angel
	name = "grieving angel"
	icon_state = "angelmush"
	desc = "Each of these mushrooms is believed to have sprouted out of angel tears in the long past."
	mush_light_range = 3
	mush_light_power = 3
	mush_light_color = "#e2e2e2"
	mush_animate = FALSE

/obj/structure/flora/rogueshroom/unhappy/random
	name = "corpse fungus"

/obj/structure/flora/rogueshroom/unhappy/random/Initialize(mapload)
	. = ..()
	var/list/mushroom_types = list(
		/obj/structure/flora/rogueshroom/unhappy = 249,
		/obj/structure/flora/rogueshroom/unhappy/angel = 249,
	)
	var/mushroom_type = pickweight(mushroom_types)
	new mushroom_type(loc)
	qdel(src)

// ---------------------------------------------------------------------------
// Desert/Zybantium fluff — ported from Ratwood-2.0's modular_deserttown
// (the same sibling module the earlier byos_desert_floors/_walls turfs came
// from). Not present in this codebase at all, including their icons.

/obj/structure/drape
	plane = -3

/obj/structure/drape/zybantine
	name = "zybantine drape"
	desc = "Made from prestigious fabric, a display of wealth."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_drapes.dmi'
	icon_state = "zybantinedrape1"
	color = "#a3a3a3"

/obj/structure/drape/zybantine/Initialize(mapload)
	. = ..()
	icon_state = "zybantinedrape[rand(1, 2)]"

/obj/structure/chair/zybantine_sofa/right
	name = "zybantine sofa"
	icon_state = "zybantinesofa_right"
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_chairs.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/zybantine_sofa/left
	name = "zybantine sofa"
	icon_state = "zybantinesofa_left"
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_chairs.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/fermentation_keg/sandpot
	name = "sand pot"
	desc = "A common clay pot used for storing and sometimes fermenting fluids. Favoured over wooden barrels in the desert due to the relative scarcity of wood."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_pots.dmi'
	icon_state = "sandpot1"

/obj/structure/fermentation_keg/sandpot/Initialize(mapload)
	. = ..()
	icon_state = "sandpot[rand(1, 2)]"

/obj/structure/fermentation_keg/sandpot/beer/Initialize(mapload)
	. = ..()
	icon_state = "sandpot2"
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 900)

/obj/structure/flora/roguetree/palm
	name = "palm tree"
	desc = "Scant, precious shade."
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_bigpalm.dmi'
	icon_state = "palm1"
	pixel_x = -32
	opacity = 0 //palm trees are skinny
	density = 0

/obj/structure/flora/roguetree/palm/Initialize(mapload)
	. = ..()
	icon_state = "palm[rand(1,2)]"

// ---------------------------------------------------------------------------
// Canopy/market-booth fluff — ported from Ratwood-2.0's modular_hearthstone,
// not present in this codebase. Only /side is in the map's actual missing
// list, but its parent /obj/structure/fluff/canopy doesn't exist here either,
// so the minimal base + the one placed variant are both included.

/obj/structure/fluff/canopy
	name = "Canopy"
	desc = ""
	icon = 'modular_dreamvalley/ported/ratwood/byos_terrain/icons/byos_decor.dmi'
	icon_state = "canopy"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	blade_dulling = DULLING_BASH
	resistance_flags = FLAMMABLE
	max_integrity = 20
	integrity_failure = 0.33
	dir = SOUTH
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg','sound/combat/hits/onwood/woodimpact (2).ogg')

/obj/structure/fluff/canopy/side
	icon_state = "canopyb-side"

// ---------------------------------------------------------------------------
// Vampire lord relic — parent /obj/structure/vampire already exists in this
// codebase's own vampire_neu module. Bare stub in source (name/icon/vars
// only, no procs), ported as-is per the "purely decorative" carve-out.
/obj/structure/vampire/necromanticbook
	name = "Tome of Souls"
	icon_state = "tome"
	pixel_x = -16
	var/list/useoptions = list("Create Death Knight", "Steal the Sun")
	var/sunstolen = FALSE
