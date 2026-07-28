// "Ancient" (Zizo-era gilbranze) weapon and armor variants used by byos.dmm.
// Ported from Ratwood-2.0's rogueweapon melee/shield files. All parent types
// already exist in this codebase; these leaves only override icon_state /
// smeltresult / flavor text, and all icon_states already exist in this
// repo's shared weapon icon sheets, so no new icon assets were required.
// Zizo/Vheslyn lore references are unrenamed base-game entities (the ancient
// false-god / first-murder myth), not part of the pantheon rename, so their
// flavor text is kept verbatim.

/obj/item/rogueweapon/greatsword/ancient
	name = "ancient greatsword"
	desc = "A massive blade, forged from polished gilbranze. Your kind will discover your true nature, in wrath and ruin. You will take to the stars and burn them out, one by one. Only when the last star turns to dust, will you finally realize that She was trying to save you from Man's greatest foe; oblivion."
	icon_state = "ancient_gsw"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/halberd/bardiche/ancient
	name = "ancient bardiche"
	desc = "A terrifying poleaxe, forged from polished gilbranze. When Her ascension came, these weapons - bereft of their wielders - sunk deep into the earth. Shadowed hands cradled the blades over the centuries, and would eventually create its steel-tipped successor; the glaive."
	icon_state = "ancient_bardiche"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/huntingknife/idagger/steel/ancient
	name = "ancient dagger"
	desc = "A short blade, forged from polished gilbranze. It is violence that shepherds ambition, and it is ambition that will free this world from mortality's chains. Zizo, Zizo, Zizo - I call upon thee; bring forth the undying, so that your works may yet be done!"
	icon_state = "adagger"
	sheathe_icon = "adagger"
	smeltresult = /obj/item/ingot/aaslag
	picklvl = 0.7

/obj/item/rogueweapon/mace/goden/steel/ancient
	name = "ancient grand mace"
	desc = "A twisting polehammer, forged in polished gilbranze. What did you think this was all about? This destruction, this war, this sacrifice; it was all to prepare Man for its true ascension."
	icon_state = "ancient_supermace"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/mace/steel/ancient
	name = "ancient mace"
	desc = "Polished gilbranze, perched atop a reinforced shaft. Break the unenlightened into naught-but-giblets; like a potter's vessels, dashed against the rocks."
	icon_state = "amace"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/mace/warhammer/steel/ancient
	name = "ancient warhammer"
	desc = "A macehead of polished gilbranze, spiked and perched atop a reinforced shaft. An elegant weapon from a more civilized age; when Man lived in harmony with one-another, and when 'the undying' was nothing more than a nitemare's thought."
	icon_state = "awarhammer"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/shield/tower/metal/ancient
	name = "ancient shield"
	desc = "A venerable scutum, plated with polished gilbranze. An undying legionnaire's closest friend; that which rebukes arrow-and-bolt alike with unphasing prejudice. It is a reminder - one of many - that Her ambition cannot be stopped."
	icon_state = "ancientsh"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/shield/tower/metal/ancient/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.8,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.8,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
	return ..()

/obj/item/rogueweapon/spear/ancient
	name = "ancient spear"
	desc = "A gnarled staff, tipped with polished gilbranze. Your breathing hilts, and your knuckles tighten around the staff; you see what is yet to come, yet your mind refuses to retain it. To know what fate this dying world has - it would drive any man inzane."
	icon_state = "ancient_spear"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/stoneaxe/woodcut/steel/ancient
	name = "ancient axe"
	desc = "A hatchet of polished gilbranze. Vheslyn molested the hearts of Man with sin - of greed towards the better offerings, and of lust for His divinity. With a single blow, blood gouted from bone and seeped into the soil; the first murder."
	icon_state = "ahandaxe"
	smeltresult = /obj/item/ingot/aaslag

/obj/item/rogueweapon/sword/sabre/ancient
	name = "ancient khopesh"
	desc = "A polished hook-sword, forged from gilbranze. The Comet Syon's glare once graced this blade; now, it's wielded by those who can't even remember what came before His sacrifice."
	smeltresult = /obj/item/ingot/aaslag
	icon_state = "akhopesh"

/obj/item/rogueweapon/sword/short/gladius/ancient
	name = "ancient gladius"
	desc = "A polished shortsword, forged from gilbranze. Favored by ZIZO's undying legionnaires, this antiquated tool serves a simple purpose; to spill the innards of unenlightened fools."
	icon_state = "agladius"
	smeltresult = /obj/item/ingot/aaslag
