// ═══════════════════════════════════════════════════════════════════
// CHI DISCIPLINES — MINOR SUB-DISCIPLINES
// Each minor discipline is a specialized branch of one of the six
// major elements. They focus on a specific application of their
// parent element's principles.
// ═══════════════════════════════════════════════════════════════════

// ─── EARTH sub-discipline: Forgecraft ───────────────────────────────
/datum/magic_aspect/artifice
	name = "Forgecraft"
	latin_name = "Sub-Disciplina Fabricae"
	desc = "The earthbender's craft tradition. Forgecraft is the art of sensing the \
		earth within forged metal and shaping it — not for war, but for creation. \
		A forge-bender repairs armor, mends broken weapons, and shapes chi-forged \
		tools from raw materials. It is the peaceful side of the metal tradition."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	binding_gestures = list(
		"assumes a craftsman's posture, hands steady and focused",
	)
	unbinding_gestures = list(
		"sets down the invisible tools, the craft-sense fading",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/arcyne_forge,
		/datum/action/cooldown/spell/mending,
	)

// ─── VOID sub-discipline: Barrier ───────────────────────────────────
/datum/magic_aspect/exowardry
	name = "Barrier"
	latin_name = "Sub-Disciplina Clausurae"
	desc = "The void-bender's external warding tradition. Barrier focuses entirely \
		on raising walls of pure will — force barriers that deny passage and \
		shape the battlefield. Where the full Void discipline includes traps and \
		suppression, Barrier is purely defensive: wall off a corridor, seal a gate, \
		redirect the flow of battle."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	binding_gestures = list(
		"presses both palms outward, the space between them hardening",
	)
	unbinding_gestures = list(
		"lowers their hands, the barrier dissolving",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/forcewall,
	)

// ─── AIR sub-discipline: Displacement ───────────────────────────────
/datum/magic_aspect/displacement
	name = "Displacement"
	latin_name = "Sub-Disciplina Translationis"
	desc = "The airbender's evasion tradition. Displacement is the art of becoming \
		the wind itself — stepping between spaces, flowing past obstacles, and \
		appearing where your opponent is not. Where Air teaches redirection, \
		Displacement teaches disappearance."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_DISPLACEMENT
	binding_gestures = list(
		"shifts their weight, body flickering at the edges",
		"steps sideways and seems to blur, air folding around them",
	)
	unbinding_gestures = list(
		"settles back into their body, the air unfolding",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/phase,
	)

// ─── VOID sub-discipline: Ironskin ──────────────────────────────────
/datum/magic_aspect/autowardry
	name = "Ironskin"
	latin_name = "Sub-Disciplina Ferri Corporis"
	desc = "The void-bender's self-warding tradition. Ironskin clads the bender in \
		a personal barrier of pure will — an armor of negation that turns aside \
		blows before they land. The warding technique is replaced and an improved \
		version takes its place while the discipline is active."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	binding_gestures = list(
		"wraps their arms around themselves, chi hardening against their skin",
	)
	unbinding_gestures = list(
		"uncrosses their arms, the chi-armor falling away",
	)
	choice_spells = list(
		/datum/action/cooldown/spell/conjure_arcyne_ward/dragonhide,
		/datum/action/cooldown/spell/conjure_arcyne_ward/crystalhide,
	)

// ─── SPIRIT sub-discipline: Lesser Enhancement ─────────────────────
/datum/magic_aspect/lesser_augmentation
	name = "Lesser Enhancement"
	latin_name = "Sub-Disciplina Augmenti Minoris"
	desc = "A reduced form of the Enhancement tradition, available as a secondary focus. \
		The bender turns a portion of their spiritual energy inward, enhancing the body \
		with chi. The body becomes a vessel — strengthened, sharpened, pushed beyond its \
		natural limits. The mind is never directly enhanced, for the mind is the seat of \
		the spirit, and one cannot use spiritual energy to enhance one's ability to wield \
		spiritual energy so bluntly."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_BUFF
	binding_gestures = list(
		"draws a thread of chi inward, body stirring with energy",
	)
	unbinding_gestures = list(
		"lets the thread settle, the inner stir fading",
	)
	pointbuy_budget = 6
	pointbuy_spells = list(
		/datum/action/cooldown/spell/darkvision,
		/datum/action/cooldown/spell/augment_buff/blood_rush,
		/datum/action/cooldown/spell/augment_buff/guidance,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/augment_buff/enlarge,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/nondetection,
		/datum/action/cooldown/spell/augment_buff/surge,
		/datum/action/cooldown/spell/augment_buff/precognition,
		/datum/action/cooldown/spell/augment_buff/grasp,
		// 1-cost utility filler
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/datum/action/cooldown/spell/create_campfire,
	)

// ─── VOID sub-discipline: Illusion ──────────────────────────────────
/datum/magic_aspect/illusion
	name = "Illusion"
	latin_name = "Sub-Disciplina Illusionis"
	desc = "The void-bender's deception tradition. Illusion weaves false images from \
		the space between perception and reality — not creating anything real, but \
		shaping what others believe they see. The void-bender does not bend light or \
		matter; they bend the mind's expectation of what should be there."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ILLUSION
	binding_gestures = list(
		"waves their hand before their face, the air shimmering with unreality",
	)
	unbinding_gestures = list(
		"drops their hand, the shimmer fading to truth",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/invisibility,
	)

// ─── WATER sub-discipline: Hearthcraft ──────────────────────────────
/datum/magic_aspect/hearthcraft
	name = "Hearthcraft"
	latin_name = "Sub-Disciplina Domus"
	desc = "The waterbender's home tradition. Hearthcraft is the gentle art of tending \
		the hearth — creating shelter from the elements, kindling fire for warmth, and \
		maintaining the flow of life that water represents. It is the peaceful side of \
		the water tradition: where combat waterbending freezes and crushes, hearthcraft \
		nurtures and shelters."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEARTH
	binding_gestures = list(
		"kneels and touches the ground, a warmth spreading outward",
	)
	unbinding_gestures = list(
		"rises from the kneel, the warmth fading",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/great_shelter,
		/datum/action/cooldown/spell/create_campfire,
	)

// ─── EARTH sub-discipline: Aegis ────────────────────────────────────
/datum/magic_aspect/aegiscraft
	name = "Aegis"
	latin_name = "Sub-Disciplina Aegidis"
	desc = "The earthbender's shield tradition. Aegis projects a barrier of compressed \
		stone and will — a solid, unyielding shield that embodies earth's principle of \
		substance. Where earthbending commands the ground beneath one's feet, Aegis \
		commands the ground before one's body, shaping it into a wall of protection."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	binding_gestures = list(
		"raises one arm before them, stone and will solidifying into a shield",
	)
	unbinding_gestures = list(
		"lowers their arm, the shield crumbling to dust",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/conjure_aegis,
	)

// ─── VOID sub-discipline: Hex ───────────────────────────────────────
/datum/magic_aspect/hex
	name = "Hex"
	latin_name = "Sub-Disciplina Maleficii"
	desc = "The void-bender's curse tradition. Hex is the art of the crooked word — \
		speaking a disruption into an opponent's chi flow that causes their own energy \
		to turn against them. Where other void techniques deny from without, Hex undoes \
		from within: withering the body, sapping the spirit, and leaving the cursed \
		to waste away under the weight of their own corrupted energy."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEX
	binding_gestures = list(
		"gestures crookedly, chi twisting against itself",
	)
	unbinding_gestures = list(
		"straightens their gesture, the crooked chi unwinding",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/wither,
	)
