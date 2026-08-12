// ═══════════════════════════════════════════════════════════════════
// CHI DISCIPLINES — MAJOR ELEMENTS
// Four elements (Fire, Water, Earth, Air) + two auxiliary (Spirit, Void).
// Each discipline channels chi through martial forms to manipulate
// the natural world. No "mana" or "arcane" — only breath, stance, and will.
// ═══════════════════════════════════════════════════════════════════

// ─── FIRE ───────────────────────────────────────────────────────────
/datum/magic_aspect/pyromancy
	name = "Fire"
	latin_name = "Disciplina Ignis"
	desc = "The element of power. Firebending channels the breath of the dragon — \
		the chi within one's own body ignited into living flame through stance, breath, and ferocity. \
		Fire is aggressive, relentless, and alive. A firebender who loses their focus loses their flame; \
		one who masters their inner fire becomes an unstoppable force of nature. \
		Fire opposes Water — each extinguishes the other, and a bender who understands both \
		can read the flow of any battle."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_PYROMANCY
	school_color = GLOW_COLOR_FIRE
	binding_gestures = list(
		"assumes a wide horse stance, fists igniting with chi",
		"breathes deep, exhaling a plume of flame",
		"snaps into a forward strike stance, palms blazing",
	)
	unbinding_gestures = list(
		"closes their fists, extinguishing the inner flame",
		"breathes out slowly, the fire within settling to embers",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/bending_stance/fire,
		/datum/action/cooldown/spell/firebending,
		/datum/action/cooldown/spell/projectile/spitfire,
		/datum/action/cooldown/spell/ultio,
	)
	spell_order = list(
		ASPECT_CHOICE,
		/datum/action/cooldown/spell/telegraphed_strike/dragons_breath,
		/datum/action/cooldown/spell/projectile/fireball/barrage,
		/datum/action/cooldown/spell/fire_curtain,
		/datum/action/cooldown/spell/projectile/smoke_burst,
		/datum/action/cooldown/spell/create_campfire,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/projectile/pyroclasm,
		),
		"gefechtsgelehrter" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/fire_strike,
		),
	)

// ─── WATER ──────────────────────────────────────────────────────────
/datum/magic_aspect/cryomancy
	name = "Water"
	latin_name = "Disciplina Aquae"
	desc = "The element of change. Waterbending flows like a river — it finds the \
		path of least resistance, then strikes with the weight of the ocean behind it. \
		A waterbender does not fight their opponent's force; they redirect it, freeze it, \
		and turn it against them. Where fire destroys, water endures. Where earth stands firm, \
		water adapts. The northern and southern traditions teach that water is life itself — \
		and to bend it is to hold life and death in your hands. Water opposes Fire."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CRYOMANCY
	school_color = GLOW_COLOR_ICE
	binding_gestures = list(
		"flows into a gentle stance, arms circling like a river current",
		"draws moisture from the air, frost crystallizing around their hands",
		"settles into a still posture, breath misting in the cold",
	)
	unbinding_gestures = list(
		"lets their arms fall, the frost melting from their hands",
		"breathes warmly, the ice within thawing to still water",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/bending_stance/water,
		/datum/action/cooldown/spell/waterbending,
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/projectile/rimecast,
		/datum/action/cooldown/spell/forcewall/ice,
		/datum/action/cooldown/spell/verglas,
		/datum/action/cooldown/spell/fridigitation,
	)
	spell_order = list(
		/datum/action/cooldown/spell/bending_stance/water,
		/datum/action/cooldown/spell/waterbending,
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/projectile/rimecast,
		/datum/action/cooldown/spell/forcewall/ice,
		/datum/action/cooldown/spell/verglas,
		/datum/action/cooldown/spell/fridigitation,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/frozen_mist,
		),
	)

// ─── LIGHTNING (Fire sub-skill) ─────────────────────────────────────
/datum/magic_aspect/fulgurmancy
	name = "Lightning"
	latin_name = "Disciplina Fulminis"
	desc = "The cold-blooded fire. Lightning generation is the highest technique of \
		the fire discipline — separating yin and yang chi within one's own body, \
		then channeling the imbalance outward as a bolt of pure energy. Where firebending \
		is fury and breath, lightning is stillness and precision. A lightning-bender \
		must achieve absolute emotional calm; the slightest tremor of feeling disrupts \
		the flow and the bolt goes wide — or worse, turns inward. Those who master it \
		are valued for their reliability: fast, accurate, and consistent in ways that \
		flame cannot be. The most skilled have never once seen their bolt go wide."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FULGURMANCY
	school_color = GLOW_COLOR_LIGHTNING
	binding_gestures = list(
		"stands perfectly still, separating the chi within their body",
		"extends one finger, sparks crackling between their fingertips",
		"assumes a rigid posture, eyes cold and focused",
	)
	unbinding_gestures = list(
		"relaxes their stance, the sparks dying away",
		"breathes out, the divided chi reuniting within",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/arc_bolt,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/fulmination,
		/datum/action/cooldown/spell/levinstroke,
		/datum/action/cooldown/spell/light,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/greater_thunderstrike,
		),
	)

// ─── EARTH ──────────────────────────────────────────────────────────
/datum/magic_aspect/geomancy
	name = "Earth"
	latin_name = "Disciplina Terrae"
	desc = "The element of substance. Earthbending is the oldest discipline — as old as \
		the ground beneath one's feet. An earthbender stands firm, roots their stance, \
		and commands the very rock to rise. Every technique is heavy and weighty; a nimble \
		opponent might dodge a single boulder, but the earthbender does not throw one — \
		they throw a hundred. With a blast of gravel they extinguish evasion, with the \
		grasp of stone they pin their opponent, with a boulder they crush their foes to pulp. \
		When the very earth fights you, how can one stand before such ancient might? \
		Earth endures where all else erodes."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_GEOMANCY
	school_color = GLOW_COLOR_EARTHEN
	binding_gestures = list(
		"drops into a deep horse stance, feet planting into the ground",
		"strikes the earth with a palm, stone rumbling in response",
		"rises slowly, rock dust falling from their shoulders",
	)
	unbinding_gestures = list(
		"lifts their feet from the ground, the stone settling",
		"shakes out their hands, the earthen connection fading",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/bending_stance/earth,
		/datum/action/cooldown/spell/earthbending,
		/datum/action/cooldown/spell/projectile/gravel_blast,
		/datum/action/cooldown/spell/tumult,
		/datum/action/cooldown/spell/menhir,
		/datum/action/cooldown/spell/geas,
		/datum/action/cooldown/spell/magicians_stone,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/meteor_strike,
		),
		"gefechtsgelehrter" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/grenzel_meteor,
		),
	)

// ─── AIR ────────────────────────────────────────────────────────────
/datum/magic_aspect/kinesis
	name = "Air"
	latin_name = "Disciplina Ventorum"
	desc = "The element of freedom. Airbending is the most evasive of the disciplines — \
		an airbender never stands where the blow lands. They move like the wind itself, \
		flowing around obstacles, redirecting force, and striking from unexpected angles \
		with compressed gusts and spiraling currents. Where other benders impose their will \
		on the world, the airbender becomes part of it — listening to the flow of energy \
		and guiding it rather than commanding it. The origin discipline, some say, from which \
		all others branched: for chi itself is breath, and breath is air. An airbender who \
		truly understands the flow can crush, lift, and redirect anything — for all things \
		move through air, and air moves through all things."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_KINESIS
	school_color = GLOW_COLOR_KINESIS
	binding_gestures = list(
		"assumes a light, airy stance, weight shifting to the balls of their feet",
		"circles their arms in spiraling patterns, air swirling around them",
		"breathes deeply, rising slightly off the ground",
	)
	unbinding_gestures = list(
		"settles their weight back to the ground, the air growing still",
		"lets their arms drop, the currents dispersing",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/bending_stance/air,
		/datum/action/cooldown/spell/airbending,
		/datum/action/cooldown/spell/projectile/basic_offensive,
		/datum/action/cooldown/spell/crush,
		/datum/action/cooldown/spell/gravity,
		/datum/action/cooldown/spell/telegraphed_strike/kinetic_burst,
		/datum/action/cooldown/spell/greater_cleaning,
		/datum/action/cooldown/spell/levitation,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/mass_crush,
		),
	)

// ─── WIND (Air sub-skill — trajectory) ──────────────────────────────
/datum/magic_aspect/telomancy
	name = "Wind"
	latin_name = "Disciplina Teli Ventorum"
	desc = "The focused wind. Where the Air discipline flows and redirects, the Wind \
		discipline compresses — shaping chi into needles of compressed air, spiraling \
		gusts, and precise projectile strikes. A wind-bender considers themselves a branch \
		of the Air tradition, and rightly so: shaping breath into a directed strike was \
		likely the first technique ever developed. Compared to Air's broad manipulation, \
		Wind focuses almost entirely on shaping currents into deadly, high-velocity projectiles \
		that pierce armor and flesh alike."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_TELOMANCY
	school_color = GLOW_COLOR_ARCANE
	binding_gestures = list(
		"assumes a focused stance, palms forward and fingers spread",
		"compresses the air between their hands, wind tightening into a point",
		"snaps their arms forward, releasing the compressed gust",
	)
	unbinding_gestures = list(
		"opens their hands, the compressed air dispersing",
		"shakes out their wrists, the wind fading to a breeze",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/arcyne_volley,
		/datum/action/cooldown/spell/void_beam,
		/datum/action/cooldown/spell/arcyne_burst,
		/datum/action/cooldown/spell/circumdatum,
		/datum/action/cooldown/spell/greater_cleaning,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/projectile/arcyne_barrage,
		),
	)

// ─── METAL (Earth sub-skill) ────────────────────────────────────────
/datum/magic_aspect/ferramancy
	name = "Metal"
	latin_name = "Disciplina Ferri"
	desc = "The refined earth. Metalbending is the earthbender's most advanced technique — \
		sensing the trace earth within forged metal and commanding it just as one commands \
		stone. Among the major disciplines, it is the youngest, born from the discovery that \
		purified metal still contains fragments of its earthen origin. A metalbender bridges \
		the gap between primal force and human ingenuity — they shape weapons from chi-forged \
		steel, hurl them with the force of a boulder, and rend through wards and armor more \
		efficiently than any other discipline. Some traditionalists look down on metalbending \
		for its impurity, but perhaps the true reason is that metal cuts deeper than stone."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FERRAMANCY
	school_color = GLOW_COLOR_METAL
	binding_gestures = list(
		"assumes a smith's stance, hands gripping as if holding a hammer",
		"senses the earth within the metal around them, steel humming in response",
		"strikes an anvil-stance, chi-forged metal forming in their grip",
	)
	unbinding_gestures = list(
		"opens their hands, the forged metal dissolving to dust",
		"steps back from the stance, the forge within cooling",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/ferramancy_strike/falling_crescent,
		/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance,
		/datum/action/cooldown/spell/ferramancy_strike/heavens_hammer,
		/datum/action/cooldown/spell/form_blade,
		/datum/action/cooldown/spell/conjure_arcyne_ward/crystalhide,
		/datum/action/cooldown/spell/bind_armament,
		/datum/action/cooldown/spell/arcyne_forge,
		/datum/action/cooldown/spell/mending,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/blade_dance,
		),
		"gefechtsgelehrter" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/form_blade/form_hammer,
		),
	)

// ─── VOID (Auxiliary — wards, defense, suppression) ────────────────
/datum/magic_aspect/battlewardry
	name = "Void"
	latin_name = "Disciplina Vacui"
	desc = "The art of negation. Void is not an element but the space between them — \
		the stillness that governs motion, the silence that contains sound. A Void-bender \
		does not create; they deny. They raise barriers of pure will that no element can \
		penetrate, lay ward-traps that punish the reckless, and shape the battlefield with \
		force walls that channel and divide. Where other disciplines channel destruction, \
		Void specializes in the prevention of destruction. But make no mistake — a Void-bender \
		is anything but passive. Under their influence, the battlefield is molded and shaped \
		to their will, and those who strike recklessly into a Void-bender's territory find \
		themselves trapped, warded, and undone."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_BATTLEWARDRY
	school_color = GLOW_COLOR_WARD
	binding_gestures = list(
		"stands motionless, hands pressing outward as if against an invisible wall",
		"traces a line in the air, the space hardening behind their palm",
		"assumes a bracing stance, the void solidifying around them",
	)
	unbinding_gestures = list(
		"drops their hands, the barriers dissolving into nothing",
		"breathes out, the void filling back with the world's noise",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/battle_ward,
		/datum/action/cooldown/spell/forcewall,
		/datum/action/cooldown/spell/arrow_ward,
		/datum/action/cooldown/spell/bestow_ward,
		/datum/action/cooldown/spell/touch/rune_ward,
	)
	choice_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/arcyne_fortress,
		),
	)

// ─── SPIRIT (Auxiliary — summoning, enhancement) ───────────────────
/datum/magic_aspect/conjuration
	name = "Spirit"
	latin_name = "Disciplina Animae"
	desc = "The bridge between worlds. Spirit is not an element but the thread that \
		connects the physical and spiritual realms. A Spirit-bender taps into the spirit \
		world, calling forth spirits as allies and servants. Where other benders shape \
		physical matter, the Spirit-bender commands immaterial forces — and where a spirit \
		lacks the intellect to fight well, the Spirit-bender can project their own \
		consciousness into the summon, taking direct control. Such projection cannot be \
		maintained at great range, and no spirit-bender can summon a force greater than \
		their own. But the lack of long-term risk is a major benefit, even if the bender \
		suffers a harsh recoil when their summoned spirit is struck down."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CONJURATION
	school_color = GLOW_COLOR_ARCANE
	binding_gestures = list(
		"cups their hands before their chest, chi gathering between their palms",
		"reaches outward as if grasping a thread from beyond the veil",
		"opens their eyes wide, a spirit form coalescing beside them",
	)
	unbinding_gestures = list(
		"closes their hands, the spirit form dissipating",
		"breathes out, the veil between worlds closing",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/minion_order/conjurer,
		/datum/action/cooldown/spell/command_word/fray,
		/datum/action/cooldown/spell/command_word/harry,
		/datum/action/cooldown/spell/command_word/quicken,
		/datum/action/cooldown/spell/command_word/beckon,
		/datum/action/cooldown/spell/minion_mark,
		/datum/action/cooldown/spell/conjure_recall,
		/datum/action/cooldown/spell/conjure_dismiss,
		/datum/action/cooldown/spell/conjure_projection,
	)
	choice_spells = list(
		/datum/action/cooldown/spell/conjure_summon/primordial,
		/datum/action/cooldown/spell/conjure_summon/champion,
		/datum/action/cooldown/spell/conjure_summon/attacker,
		/datum/action/cooldown/spell/conjure_summon/hordes,
		/datum/action/cooldown/spell/conjure_summon/peasant_swarm,
	)
	mastery_choice_spells = list(
		/datum/action/cooldown/spell/conjure_summon/peasant_swarm,
	)
	spell_order = list(
		/datum/action/cooldown/spell/minion_order/conjurer,
		/datum/action/cooldown/spell/command_word/fray,
		/datum/action/cooldown/spell/command_word/harry,
		/datum/action/cooldown/spell/command_word/quicken,
		/datum/action/cooldown/spell/command_word/beckon,
		ASPECT_CHOICE,
		/datum/action/cooldown/spell/minion_mark,
		/datum/action/cooldown/spell/conjure_projection,
		/datum/action/cooldown/spell/conjure_recall,
		/datum/action/cooldown/spell/conjure_dismiss,
	)
	variants = list(
		"gefechtsgelehrter" = list(
			/datum/action/cooldown/spell/conjure_summon/champion = /datum/action/cooldown/spell/conjure_summon/doppelsoldner,
		),
	)

// ─── SPIRIT — BODY ENHANCEMENT ──────────────────────────────────────
/datum/magic_aspect/augmentation
	name = "Enhancement"
	latin_name = "Disciplina Augmenti Corporis"
	desc = "The inward-facing tradition of the Spirit discipline. Rather than summoning \
		external spirits, the enhancer turns spiritual energy inward — strengthening the \
		body, sharpening the senses, and pushing human form beyond its natural limits. \
		The body becomes a vessel for chi, and the enhancer shapes that chi into speed, \
		strength, endurance, and perception. The mind is never directly enhanced — for the \
		mind is the true seat of the spirit, and one cannot use spiritual energy to enhance \
		one's ability to wield spiritual energy so bluntly. Woe betides those who face a \
		warrior sharpened by the enhancer's art."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AUGMENTATION
	school_color = GLOW_COLOR_BUFF
	binding_gestures = list(
		"turns their focus inward, chi flooding through their own body",
		"flexes and extends, muscles surging with spiritual energy",
		"settles into a ready stance, body alive with inner power",
	)
	unbinding_gestures = list(
		"lets the inner energy settle, the surge fading to calm",
		"shakes out their limbs, the enhancement draining away",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/augment_buff/blood_rush,
		/datum/action/cooldown/spell/augment_buff/guidance,
		/datum/action/cooldown/spell/augment_buff/enlarge,
		/datum/action/cooldown/spell/augment_buff/surge,
		/datum/action/cooldown/spell/augment_buff/grasp,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/augment_buff/precognition,
		),
	)
