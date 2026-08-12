// Oddities — strange artifacts that can be meditated on for insight/stat growth
// Adapted from CEV-Eris's oddity system for DreamValley's medieval fantasy setting
//
// Eris-style stat scaling:
// - Each oddity has oddity_stats = list(STAT_DEFINE = max_value)
// - On init, the actual value is randomized: rand(2, max_value)
// - On use, the value is DOUBLED (like Eris: stat_up = L[stat] * 2)
// - The bonus is added to oddity_stat_bonuses, which stacks on top of base stats
// - Base stats stay 1-20; effective stat (get_stat) = base + oddity bonus
// - Oddity bonuses range from -200 to +200 per stat
// - Cursed oddities have negative oddity_stats values

/obj/item/oddity
	name = "strange artifact"
	desc = "An oddity that seems to resonate with something unseen. Meditating on it may reveal hidden truths."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "necro_crystal"
	w_class = WEIGHT_CLASS_SMALL
	/// Whether this oddity is consumed when used for meditation
	var/single_use = TRUE
	/// The stat this oddity is most aligned with (if any) — for examine flavor
	var/aligned_stat
	/// Flavor text shown when examining closely
	var/oddity_flavor = "You feel a strange sensation when you hold this..."
	/// Sanity restoration when in proximity
	var/sanity_aura = 0.5
	/// Eris-style stat list: list(STAT_DEFINE = max_value). Randomized on init.
	/// Positive values = stat boost on use. Negative values = stat penalty (cursed).
	var/list/oddity_stats = null
	/// Whether to randomize the stat values on init (Eris behavior)
	var/random_stats = TRUE

/obj/item/oddity/Initialize(mapload)
	. = ..()
	// Randomize oddity stats like Eris: rand(2, max_value) for positive, rand(max_value, -2) for negative
	if(oddity_stats && random_stats)
		for(var/stat in oddity_stats)
			var/max_val = oddity_stats[stat]
			if(max_val > 0)
				oddity_stats[stat] = rand(2, max_val)
			else if(max_val < 0)
				oddity_stats[stat] = rand(max_val, -2)

/obj/item/oddity/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.sanity)
			. += span_notice("[oddity_flavor]")
		// Show stat aspects like Eris (requires INT check)
		if(oddity_stats && H.get_stat(STAT_INTELLIGENCE) >= STAT_BASELINE)
			for(var/stat in oddity_stats)
				var/val = oddity_stats[stat]
				var/aspect
				if(val >= 10)
					aspect = "an overwhelming"
				else if(val >= 6)
					aspect = "a strong"
				else if(val >= 3)
					aspect = "a medium"
				else if(val >= 1)
					aspect = "a weak"
				else if(val <= -10)
					aspect = "a devastating"
				else if(val <= -6)
					aspect = "a strong"
				else if(val <= -3)
					aspect = "a medium"
				else if(val <= -1)
					aspect = "a weak"
				else
					continue
				var/stat_name = stat
				// Pretty-print stat name
				switch(stat)
					if(STAT_STRENGTH)
						stat_name = "Strength"
					if(STAT_PERCEPTION)
						stat_name = "Perception"
					if(STAT_INTELLIGENCE)
						stat_name = "Intelligence"
					if(STAT_CONSTITUTION)
						stat_name = "Constitution"
					if(STAT_WILLPOWER)
						stat_name = "Willpower"
					if(STAT_SPEED)
						stat_name = "Speed"
					if(STAT_FORTUNE)
						stat_name = "Fortune"
				if(val > 0)
					. += span_notice("This item has [aspect] aspect of [stat_name].")
				else
					. += span_warning("This item has [aspect] curse of [stat_name].")

/obj/item/oddity/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return
	if(H.sanity.resting > 0)
		to_chat(H, span_notice("You focus on [src], letting your mind wander..."))
		H.sanity.give_insight(20)
		if(H.sanity.insight >= INSIGHT_REST_THRESHOLD)
			H.sanity.use_oddity(src)
	else
		to_chat(H, span_notice("You need to rest and gain insight before you can meditate on [src]."))

// ============== ODDITY SUBTYPES ==============
// Each uses an existing icon_state from DreamValley's icon files.
// oddity_stats values are MAX random values — actual bonus is rand(2, max) * 2 on use.

/obj/item/oddity/crystal
	name = "strange crystal"
	desc = "A crystal that hums with an otherworldly energy. Gazing into it reveals shifting patterns."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "necro_crystal"
	aligned_stat = "Intelligence"
	oddity_flavor = "The crystal pulses with a rhythm that matches your heartbeat."
	sanity_aura = 1.0
	oddity_stats = list(STAT_INTELLIGENCE = 10, STAT_WILLPOWER = 5)

/obj/item/oddity/bone_charm
	name = "bone charm"
	desc = "A charm carved from ancient bone. It feels warm to the touch."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "bone"
	aligned_stat = "Willpower"
	oddity_flavor = "You hear faint whispers of those who came before."
	sanity_aura = 0.8
	oddity_stats = list(STAT_WILLPOWER = 8, STAT_CONSTITUTION = 4)

/obj/item/oddity/ancient_coin
	name = "ancient coin"
	desc = "A coin from a civilization long forgotten. Its markings are unlike any you've seen."
	icon = 'icons/roguetown/items/valuable.dmi'
	icon_state = "i1"
	aligned_stat = "Fortune"
	oddity_flavor = "You feel luckier just holding it."
	sanity_aura = 0.5
	oddity_stats = list(STAT_FORTUNE = 10, STAT_PERCEPTION = 3)

/obj/item/oddity/bloodstone
	name = "bloodstone"
	desc = "A dark red gemstone that seems to pulse with life."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "ruby_cut"
	aligned_stat = "Constitution"
	oddity_flavor = "You feel your heart beat stronger when you hold it."
	sanity_aura = 0.7
	oddity_stats = list(STAT_CONSTITUTION = 8, STAT_STRENGTH = 6)

/obj/item/oddity/wolf_fang
	name = "great wolf fang"
	desc = "A massive fang from a dire wolf. It still feels full of primal energy."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "bone"
	aligned_stat = "Strength"
	oddity_flavor = "You feel the urge to hunt coursing through your veins."
	sanity_aura = 0.6
	oddity_stats = list(STAT_STRENGTH = 10, STAT_SPEED = 4)

/obj/item/oddity/elf_mirror
	name = "elven mirror shard"
	desc = "A fragment of an elven mirror. It reflects things that aren't there."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "quartz_cut"
	aligned_stat = "Perception"
	oddity_flavor = "You see glimpses of things beyond sight in the reflection."
	sanity_aura = 0.9
	oddity_stats = list(STAT_PERCEPTION = 10, STAT_INTELLIGENCE = 4)

/obj/item/oddity/wind_chime
	name = "whispering chime"
	desc = "A small chime that produces sounds even when there is no wind."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "raw_opal"
	aligned_stat = "Speed"
	oddity_flavor = "You feel lighter, as if the wind itself carries you."
	sanity_aura = 0.6
	oddity_stats = list(STAT_SPEED = 10, STAT_FORTUNE = 3)

/obj/item/oddity/grimoire_fragment
	name = "grimoire fragment"
	desc = "A torn page from an ancient grimoire. The text shifts when you look away."
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "psyble_0"
	aligned_stat = "Intelligence"
	oddity_flavor = "The words seem to whisper secrets into your mind."
	sanity_aura = 1.2
	single_use = FALSE
	oddity_stats = list(STAT_INTELLIGENCE = 6, STAT_WILLPOWER = 6)

/obj/item/oddity/holy_relic
	name = "holy relic"
	desc = "A sacred relic that radiates divine energy."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "diamond_cut"
	aligned_stat = "Willpower"
	oddity_flavor = "You feel the presence of something greater than yourself."
	sanity_aura = 1.5
	single_use = FALSE
	oddity_stats = list(STAT_WILLPOWER = 10, STAT_CONSTITUTION = 5, STAT_FORTUNE = 5)

// ============== CURSED ODDITIES ==============
// These have negative oddity_stats — they drain stats but may offer other power.
// The cursed_idol has mixed stats: drains some, boosts others.

/obj/item/oddity/cursed_idol
	name = "cursed idol"
	desc = "A small idol of unknown origin. Looking at it too long makes your skin crawl."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "raw_onyxa"
	aligned_stat = "Fortune"
	oddity_flavor = "You feel both blessed and doomed at the same time."
	sanity_aura = -0.5 // Negative aura — drives you mad
	oddity_stats = list(STAT_FORTUNE = 8, STAT_CONSTITUTION = -6, STAT_WILLPOWER = -4)
	// The idol boosts fortune but drains constitution and willpower

/obj/item/oddity/dark_totem
	name = "dark totem"
	desc = "A totem carved from black wood. It whispers promises of power."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "bone"
	aligned_stat = "Strength"
	oddity_flavor = "You feel strength flowing into you, but something else is leaving."
	sanity_aura = -1.0
	oddity_stats = list(STAT_STRENGTH = 12, STAT_WILLPOWER = -8, STAT_FORTUNE = -4)
	// Great strength, but terrible willpower and fortune

/obj/item/oddity/shadow_mirror
	name = "shadow mirror"
	desc = "A mirror that shows not your reflection, but your shadow given form."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "raw_onyxa"
	aligned_stat = "Perception"
	oddity_flavor = "You see too much. The shadows whisper truths you wish you didn't know."
	sanity_aura = -0.8
	oddity_stats = list(STAT_PERCEPTION = 12, STAT_INTELLIGENCE = 6, STAT_CONSTITUTION = -8)
	// Incredible perception and intelligence, but body withers
