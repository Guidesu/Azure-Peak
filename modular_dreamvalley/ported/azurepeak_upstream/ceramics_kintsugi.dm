// Ported from upstream Azure-Peak PR #8146 ("Kintsugi Pottery and Glazeable
// wearables + More Clay Stuff"). Only the net-new statuette items are ported
// here — the Kintsugi (gold-seam) glaze finish itself was intentionally left
// out of dyer.dm to avoid touching the shared cooking.dmi sheet this fork has
// already diverged on (it has its own local _shattergold/_porcelain states
// upstream doesn't). These five items just add new craftable pottery.

/obj/item/natural/clay/rawpot
	name = "unfired clay pot"
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelainpotraw"
	desc = "A large clay pot fashioned out of clay."
	cooked_type = /obj/item/reagent_containers/glass/bucket/pot
	smeltresult = /obj/item/reagent_containers/glass/bucket/pot

/obj/item/natural/clay/rawoctopus
	name = "unfired clay octopus statuette"
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelainoctopusraw"
	desc = "A large octopus statuette fashioned out of clay."
	cooked_type = /obj/item/natural/clay/porcelain/octopus
	smeltresult = /obj/item/natural/clay/porcelain/octopus

/obj/item/natural/clay/rawbeaver
	name = "unfired clay beaver statuette"
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelainbeaverraw"
	desc = "A medium-sized beaver statuette fashioned out of clay."
	cooked_type = /obj/item/natural/clay/porcelain/beaver
	smeltresult = /obj/item/natural/clay/porcelain/beaver

/obj/item/natural/clay/rawcarp
	name = "unfired clay carp statuette"
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelaincarpraw"
	desc = "A large carp statuette fashioned out of clay."
	cooked_type = /obj/item/natural/clay/porcelain/carp
	smeltresult = /obj/item/natural/clay/porcelain/carp

/obj/item/natural/clay/rawcaryatid
	name = "unfired clay caryatid"
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelaincaryatidraw"
	desc = "A medium-sized caryatid fashioned out of clay."
	cooked_type = /obj/item/natural/clay/porcelain/caryatid
	smeltresult = /obj/item/natural/clay/porcelain/caryatid

/obj/item/natural/clay/porcelain/octopus
	name = "porcelain octopus statuette"
	desc = "A large octopus statuette made out of porcelain."
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelainoctopus"

/obj/item/natural/clay/porcelain/beaver
	name = "porcelain beaver statuette"
	desc = "A medium-sized beaver statuette made out of porcelain."
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelainbeaver"

/obj/item/natural/clay/porcelain/carp
	name = "porcelain carp statuette"
	desc = "A large carp statuette made out of porcelain."
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelaincarp"

/obj/item/natural/clay/porcelain/caryatid
	name = "porcelain caryatid"
	desc = "A medium-sized caryatid made out of porcelain."
	icon = 'modular_dreamvalley/icons/roguetown/items/ceramics_kintsugi.dmi'
	icon_state = "clayporcelaincaryatid"

/datum/crafting_recipe/roguetown/ceramics/claypot
	name = "clay pot"
	result = list(/obj/item/natural/clay/rawpot)
	reqs = list(/obj/item/natural/clay = 3)
	craftdiff = 2

/datum/crafting_recipe/roguetown/ceramics/clayoctopus
	name = "clay octopus statuette"
	result = list(/obj/item/natural/clay/rawoctopus)
	reqs = list(/obj/item/natural/clay = 3)
	craftdiff = 4

/datum/crafting_recipe/roguetown/ceramics/claybeaver
	name = "clay beaver statuette"
	result = list(/obj/item/natural/clay/rawbeaver)
	reqs = list(/obj/item/natural/clay = 3)
	craftdiff = 4

/datum/crafting_recipe/roguetown/ceramics/claycarp
	name = "clay carp statuette"
	result = list(/obj/item/natural/clay/rawcarp)
	reqs = list(/obj/item/natural/clay = 3)
	craftdiff = 4

/datum/crafting_recipe/roguetown/ceramics/claycaryatid
	name = "clay caryatid"
	result = list(/obj/item/natural/clay/rawcaryatid)
	reqs = list(/obj/item/natural/clay = 2)
	craftdiff = 4
