// Breakdown types — adapted from CEV-Eris for DreamValley's medieval fantasy setting
// Positive breakdowns give resilience; negative ones cause harmful behavior

// ============== POSITIVE BREAKDOWNS ==============

/datum/breakdown/positive
	start_message_span = "bold notice"
	icon_state = "positive"

/// Stalwart — triggers when badly hurt, heals and restores sanity
/datum/breakdown/positive/stalwart
	name = "Stalwart"
	duration = 0
	restore_sanity_post = 100
	start_messages = list(
		"You endure your pain well, and emerge in bliss.",
		"You feel like you could take on the world!",
		"Your pain no longer bothers you.",
		"You feel like the pain has cleared your head.",
		"You feel the pain, and you feel the gain!"
	)

/datum/breakdown/positive/stalwart/can_occur()
	return holder.owner.maxHealth - holder.owner.health > 30

/datum/breakdown/positive/stalwart/conclude()
	holder.owner.adjustBruteLoss(-25)
	holder.owner.adjustFireLoss(-25)
	holder.owner.adjustOxyLoss(-45)
	..()

/// Adaptation — increases max sanity and reduces future breakdown chance
/datum/breakdown/positive/adaptation
	name = "Adaptation"
	duration = 0
	restore_sanity_post = 100
	start_messages = list(
		"You feel like your mind has been sharpened by your experiences.",
		"You feel like you're starting to get used to this.",
		"You feel mentally prepared.",
		"You feel like you're one step ahead.",
		"You feel like you have the upper hand."
	)

/datum/breakdown/positive/adaptation/conclude()
	holder.positive_prob = min(holder.positive_prob + 10, 100)
	holder.negative_prob = max(holder.negative_prob - 5, 0)
	holder.max_level = max(holder.max_level + 20, 0)
	..()

/// Concentration — temporary sanity invulnerability
/datum/breakdown/positive/concentration
	name = "Absolute Concentration"
	duration = 20 MINUTES
	start_messages = list(
		"You focus and feel your mind turning inward.",
		"You have taken the first step toward enlightenment.",
		"You are disconnected from the world around you.",
		"You have become iron willed.",
		"Nothing phases you anymore."
	)

/datum/breakdown/positive/concentration/New()
	..()
	restore_sanity_pre = holder.max_level

/datum/breakdown/positive/concentration/occur()
	++holder.sanity_invulnerability
	return ..()

/datum/breakdown/positive/concentration/conclude()
	--holder.sanity_invulnerability
	..()

/// Determination — temporary pain resistance
/datum/breakdown/positive/determination
	name = "Determination"
	duration = 10 MINUTES
	restore_sanity_pre = 100
	start_messages = list(
		"You feel invincible!",
		"You are unstoppable, you are unbreakable!",
		"You feel like a warrior of legend!",
		"You feel a rush of adrenaline in your veins. Nothing can hurt you now!",
		"You've learned to brush off wounds that would kill lesser beings!"
	)
	end_messages = list(
		"The last drop of adrenaline leaves your veins. You feel like a normal human now."
	)

/// A Lesson Learnt — gain random stat points
/datum/breakdown/positive/lesson
	name = "A Lesson Learnt"
	duration = 0
	restore_sanity_post = 100
	start_messages = list(
		"You feel like you've learned from your experience.",
		"Something in your mind clicks. You feel more competent!",
		"You manage to learn from past mistakes.",
		"You take in the knowledge of your past experiences.",
		"Everything makes more sense now!"
	)

/datum/breakdown/positive/lesson/conclude()
	if(holder?.owner)
		// Use oddity bonus layer — no cap, scales like Eris
		var/list/stat_keys = list(STAT_STRENGTH, STAT_PERCEPTION, STAT_INTELLIGENCE, STAT_CONSTITUTION, STAT_WILLPOWER, STAT_SPEED, STAT_FORTUNE)
		var/stat = pick(stat_keys)
		holder.owner.add_oddity_stat_bonus(stat, rand(1, 2))
	..()

// ============== NEGATIVE BREAKDOWNS ==============

/datum/breakdown/negative
	start_message_span = "danger"
	restore_sanity_pre = 25
	icon_state = "negative"
	is_negative = TRUE

/// Self-harm — character attacks themselves
/datum/breakdown/negative/selfharm
	name = "Self-harm"
	duration = 1 MINUTES
	delay = 30 SECONDS
	restore_sanity_post = 70
	start_messages = list(
		"You can't take it anymore! You completely lose control!",
		"Make it stop, make it stop! You'd do anything to make it stop!",
		"Your mind cracks under the weight of the things you've seen and felt!",
		"Your brain screams for mercy! It's time to end it all!",
		"You can't handle the pressure anymore! Your head runs wild with thoughts of death!"
	)
	end_messages = list(
		"You feel the panic subside. Perhaps it's alright to live, after all?"
	)

/datum/breakdown/negative/selfharm/update()
	. = ..()
	if(!.)
		return
	if(init_update())
		if(prob(50))
			var/emote = pick(list(
				"screams incoherently!",
				"bites their tongue and mutters under their breath.",
				"utters muffled curses.",
				"grumbles.",
				"screams with soulful agony!",
				"stares at the floor."
			))
			holder.owner.emote("me", message = emote, forced = "sanity")
		else if(!holder.owner.incapacitated())
			var/obj/item/W = holder.owner.get_active_held_item()
			if(W)
				W.attack(holder.owner, holder.owner, ran_zone())
			else
				holder.owner.visible_message(span_danger(pick(list(
					"[holder.owner] tries to end their own misery!",
					"[holder.owner] scratches at their own skin!",
					"[holder.owner] bites their own limbs uncontrollably!"
				))))
				holder.owner.adjustBruteLoss(rand(2,4))

/// Hysteric — screaming and crying, stunned
/datum/breakdown/negative/hysteric
	name = "Hysteric"
	duration = 1.5 MINUTES
	delay = 60 SECONDS
	restore_sanity_post = 50
	start_messages = list(
		"You get overwhelmed and start to panic!",
		"You're inconsolably terrified!",
		"You can't choke back the tears anymore!",
		"It's too much! You freak out and lose control!"
	)
	end_messages = list(
		"You calm down as your feelings subside. You feel horribly embarrassed!"
	)

/datum/breakdown/negative/hysteric/update()
	. = ..()
	if(!.)
		return FALSE
	if(init_update())
		holder.owner.Knockdown(3)
		holder.owner.Stun(3)
		if(prob(50))
			holder.owner.emote("scream", forced = "sanity")
		else
			holder.owner.emote("cry", forced = "sanity")

/// Delusion — phantom sounds
/datum/breakdown/negative/delusion
	name = "Delusion"
	duration = 1 MINUTES
	restore_sanity_post = 50
	start_messages = list(
		"You feel like something is speaking to you from within!",
		"You feel a voice starting to scream in your head!",
		"You feel like your brain decided to scream at you!",
		"You feel like voices are marching in your mind!",
		"You feel sounds warp into cacophony!"
	)
	end_messages = list(
		"You feel silence, again."
	)

/datum/breakdown/negative/delusion/update()
	. = ..()
	if(!.)
		return FALSE
	if(prob(10))
		holder.owner.playsound_local(holder.owner, 'sound/misc/alert.ogg', 100, 1, 15)
		shake_camera(holder.owner, 2)
	if(prob(10))
		holder.owner.playsound_local(holder.owner, 'sound/misc/alert.ogg', 50)

/// Downward spiral — makes future breakdowns worse
/datum/breakdown/negative/spiral
	name = "Downward-spiral"
	duration = 0
	restore_sanity_post = 50
	start_messages = list(
		"You feel like there is no point in any of this!",
		"Your brain refuses to comprehend any of this!",
		"You feel like you don't want to continue whatever you're doing!",
		"You feel like your best days are gone forever!",
		"You feel it. You know it. There is no turning back!"
	)

/datum/breakdown/negative/spiral/conclude()
	holder.positive_prob = max(holder.positive_prob - 10, 0)
	holder.negative_prob = min(holder.negative_prob + 20, 100)
	holder.max_level = max(holder.max_level - 20, 0)
	..()

/// Kleptomania — character steals things involuntarily
/datum/breakdown/negative/kleptomania
	name = "Kleptomania"
	duration = 10 MINUTES
	restore_sanity_post = 60
	start_messages = list(
		"You feel an overwhelming urge to take things!",
		"Your hands itch to pocket something... anything!",
		"You can't resist the temptation to steal!",
		"Everything around you looks so... takeable."
	)
	end_messages = list(
		"The urge to steal subsides."
	)

/datum/breakdown/negative/kleptomania/update()
	. = ..()
	if(!.)
		return FALSE
	if(prob(15))
		var/list/nearby_items = list()
		for(var/obj/item/I in view(1, holder.owner))
			if(I.loc == holder.owner)
				continue
			nearby_items += I
		if(nearby_items.len)
			var/obj/item/I = pick(nearby_items)
			I.attack_hand(holder.owner)

/// Paranoia — character hallucinated threats
/datum/breakdown/negative/paranoia
	name = "Paranoia"
	duration = 15 MINUTES
	restore_sanity_post = 55
	start_messages = list(
		"You feel like everyone is watching you!",
		"You can't trust anyone anymore!",
		"They're all against you! ALL OF THEM!",
		"You feel like the walls have eyes!",
		"Something is coming for you... you can feel it!"
	)
	end_messages = list(
		"The paranoia fades. You feel safe again... for now."
	)

/datum/breakdown/negative/paranoia/update()
	. = ..()
	if(!.)
		return FALSE
	if(prob(8))
		holder.owner.playsound_local(holder.owner, 'sound/effects/ghost.ogg', 50, 1, 10)
	if(prob(5))
		to_chat(holder.owner, span_danger("You hear something behind you!"))

// ============== COMMON BREAKDOWNS (can be + or -) ==============

/datum/breakdown/common
	start_message_span = "danger"
	restore_sanity_pre = 25
	icon_state = "negative"

/// Pilgrimage — character is drawn to a holy area
/datum/breakdown/common/pilgrimage
	name = "Pilgrimage"
	duration = 10 MINUTES
	insight_reward = 10
	restore_sanity_post = 50
	var/message_time = 0
	var/messages
	end_messages = list("You feel like you've arrived. The journey was worth it.")

/datum/breakdown/common/pilgrimage/occur()
	message_time = world.time + BREAKDOWN_ALERT_COOLDOWN
	messages = list(
		"You feel drawn to the temple. The gods await your prayers.",
		"You need to find a shrine. Only prayer can save you now.",
		"A pilgrimage is in order. Your soul demands it.",
		"You feel the call of the divine. Go to a holy place."
	)
	to_chat(holder.owner, span_notice(pick(messages)))
	return ..()

/datum/breakdown/common/pilgrimage/update()
	. = ..()
	if(!.)
		return FALSE
	var/area/A = get_area(holder.owner)
	if(A && (findtext(A.type, "church") || findtext(A.type, "temple")))
		finished = TRUE
		conclude()
		return FALSE
	if(world.time >= message_time)
		message_time = world.time + BREAKDOWN_ALERT_COOLDOWN
		to_chat(holder.owner, span_notice(pick(messages)))

// ============== ADDITIONAL NEGATIVE BREAKDOWNS ==============

/// Fugue — character wanders aimlessly
/datum/breakdown/negative/fugue
	name = "Fugue"
	duration = 5 MINUTES
	restore_sanity_post = 40
	start_messages = list(
		"Your mind goes blank. Your feet begin to move on their own.",
		"You lose track of who you are or where you're going.",
		"The world fades away. You walk without purpose.",
		"You feel yourself slipping away from reality."
	)
	end_messages = list(
		"You blink and realize you've been wandering. Where are you?",
		"Your senses return. You feel lost and disoriented."
	)

/datum/breakdown/negative/fugue/update()
	. = ..()
	if(!.)
		return FALSE
	if(init_update())
		// Random wandering
		if(prob(30) && !holder.owner.client)
			var/direction = pick(GLOB.cardinals)
			holder.owner.Move(get_step(holder.owner, direction), direction)
		if(prob(10))
			holder.owner.emote("me", message = "stares blankly ahead.", forced = "sanity")

/// Tremors — character shakes uncontrollably
/datum/breakdown/negative/tremors
	name = "Tremors"
	duration = 3 MINUTES
	restore_sanity_post = 45
	start_messages = list(
		"Your hands begin to shake violently!",
		"A terrible trembling spreads through your body!",
		"You can't control your limbs! Everything shakes!",
		"Your body convulses with fear!"
	)
	end_messages = list(
		"The trembling subsides. You feel exhausted but in control."
	)

/datum/breakdown/negative/tremors/update()
	. = ..()
	if(!.)
		return FALSE
	if(init_update())
		holder.owner.Stun(1)
		if(prob(20))
			shake_camera(holder.owner, 3, 2)
		if(prob(15))
			holder.owner.emote("me", message = "trembles uncontrollably.", forced = "sanity")

/// Voice of Madness — character hears compelling voices
/datum/breakdown/negative/voices
	name = "Voices"
	duration = 8 MINUTES
	restore_sanity_post = 35
	start_messages = list(
		"You hear voices whispering in your head!",
		"The voices won't stop! They're telling you things!",
		"Something is speaking to you from the void!",
		"The whispers grow louder, drowning out your thoughts!"
	)
	end_messages = list(
		"The voices fade into silence. You feel shaken."
	)

/datum/breakdown/negative/voices/update()
	. = ..()
	if(!.)
		return FALSE
	if(init_update())
		if(prob(15))
			var/list/voices = list(
				"Kill them all...",
				"They deserve to die...",
				"Nobody will miss you...",
				"Do it. Do it now.",
				"They're plotting against you...",
				"You can't trust anyone...",
				"The dark is hungry...",
				"Feed the void...",
				"You are nothing...",
				"End it all...",
			)
			to_chat(holder.owner, span_danger("A voice whispers: [pick(voices)]"))

/// Berserk — character attacks randomly
/datum/breakdown/negative/berserk
	name = "Berserk Rage"
	duration = 2 MINUTES
	restore_sanity_post = 30
	start_messages = list(
		"Something snaps inside you! RAGE fills your entire being!",
		"You see red! Everything must die!",
		"A primal fury overtakes you! You can't control yourself!",
		"The beast within breaks free!"
	)
	end_messages = list(
		"The rage subsides. You stand among the aftermath, horrified."
	)

/datum/breakdown/negative/berserk/update()
	. = ..()
	if(!.)
		return FALSE
	if(init_update())
		if(!holder.owner.incapacitated() && prob(40))
			// Attack nearest mob
			var/list/nearby = list()
			for(var/mob/living/M in viewers(2, holder.owner))
				if(M == holder.owner || M.stat == DEAD)
					continue
				nearby += M
			if(nearby.len)
				var/mob/living/target = pick(nearby)
				holder.owner.a_intent = INTENT_HARM
				var/obj/item/W = holder.owner.get_active_held_item()
				if(W)
					W.attack(target, holder.owner)
				else
					target.attack_hand(holder.owner)
				holder.owner.visible_message(span_danger("[holder.owner] attacks [target] in a berserk rage!"))

// ============== ADDITIONAL POSITIVE BREAKDOWNS ==============

/// Epiphany — sudden clarity, large insight gain
/datum/breakdown/positive/epiphany
	name = "Epiphany"
	duration = 0
	restore_sanity_post = 100
	insight_reward = 50
	start_messages = list(
		"Everything makes sense now! You see the pattern!",
		"A moment of perfect clarity washes over you!",
		"The truth reveals itself to you in a flash!",
		"You understand something profound about the world!"
	)

/// Divine Vision — holy characters receive divine peace
/datum/breakdown/positive/divine_vision
	name = "Divine Vision"
	duration = 5 MINUTES
	restore_sanity_pre = 100
	restore_sanity_post = 80
	start_messages = list(
		"You feel the presence of the divine fill your soul!",
		"A holy light surrounds you, banishing all fear!",
		"The gods smile upon you! You feel invincible!",
		"You are touched by something greater than yourself!"
	)
	end_messages = list(
		"The divine presence fades, but you feel blessed."
	)

/datum/breakdown/positive/divine_vision/occur()
	++holder.sanity_invulnerability
	return ..()

/datum/breakdown/positive/divine_vision/conclude()
	--holder.sanity_invulnerability
	..()
