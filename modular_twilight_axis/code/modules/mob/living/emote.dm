/datum/emote/living/blush
	key_third_person = ""
	message = ""
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_blush()
	set name = ""
	set category = "Emotes"

	emote("blush", intentional = TRUE)

/datum/emote/living/pray
	key_third_person = ""
	message = ""
	
/datum/emote/living/meditate
	key_third_person = ""
	message = ""

/datum/emote/living/bow
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/burp
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/choke
	key_third_person = ""
	message = ""

/datum/emote/living/cross
	key_third_person = ""
	message = ""

/datum/emote/living/collapse
	key_third_person = ""
	message = ""

/datum/emote/living/whisper
	key_third_person = ""
	message = ""
	message_mime = ""

/datum/emote/living/cough
	key_third_person = ""
	message = ""

/datum/emote/living/clearthroat
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/dance
	key_third_person = ""
	message = ""

/datum/emote/living/drool
	key_third_person = ""
	message = ""

/datum/emote/living/faint
	key_third_person = ""
	message = ""

/datum/emote/living/frown
	key_third_person = ""
	message = ""
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gag
	key_third_person = ""
	message = ""

/datum/emote/living/gasp
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/breathgasp
	key_third_person = ""
	message = ""

/datum/emote/living/giggle
	key_third_person = ""
	message = ""

/datum/emote/living/chuckle
	key_third_person = ""
	message = ""


/datum/emote/living/glare
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/grin
	key_third_person = ""
	message = ""

/datum/emote/living/groan
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/grimace
	key_third_person = ""
	message = ""

/datum/emote/living/jump
	key_third_person = ""
	message = ""


/datum/emote/living/leap
	key_third_person = ""
	message = ""

/datum/emote/living/kiss
	key_third_person = ""
	message = ""
	message_param = ""
	emote_type = EMOTE_VISIBLE
	use_params_for_runechat = TRUE

/datum/emote/living/lick
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/spit
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/spit/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mouth)
			if(H.mouth.spitoutmouth)
				H.visible_message(span_warning(""))
				H.dropItemToGround(H.mouth, silent = FALSE)
			return
	..()

/datum/emote/living/hug
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/slap
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_PRECISE_GROIN)
			message_param = ""
		else if(H.zone_selected == BODY_ZONE_PRECISE_SKULL)
			message_param = ""
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = ""
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = ""
	..()

/datum/emote/living/pinch
	message = ""
	message_param = ""

/datum/emote/living/pinch/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_HEAD)
			message_param = ""
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = ""
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = ""
		else
			var/ru_zone_selected = zone_translations[user.zone_selected]
			message_param = ""
	..()

/datum/emote/living/laugh
	key_third_person = ""
	message = ""
	message_mime = ""
	message_muffled = ""

/datum/emote/living/look
	key_third_person = ""
	message = ""
	message_param = ""
/mob/living/carbon/human/verb/emote_look()
	set name = ""
	set category = "Emotes"

	emote("look", intentional = TRUE)

/datum/emote/living/nod
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/point
	key_third_person = ""
	message = ""
	message_param = ""

/datum/emote/living/pout
	key_third_person = ""
	message = ""
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_pout()
	set name = ""
	set category = "Emotes"

	emote("pout", intentional = TRUE)

/datum/emote/living/scream
	key_third_person = ""
	message = ""
	message_mime = ""
	message_muffled = ""
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE

/datum/emote/living/scream/painscream
	message = ""

/datum/emote/living/scream/strain
	message = ""

/datum/emote/living/scream/agony
	message = ""

/datum/emote/living/haltyell
	message = ""

/datum/emote/living/rage
	message = ""

/datum/emote/living/attnwhistle
	message = ""
	message_muffled = "" 

/datum/emote/living/scowl
	key_third_person = ""
	message = ""
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_scowl()
	set name = ""
	set category = "Emotes"

	emote("scowl", intentional = TRUE)


/datum/emote/living/shakehead
	key_third_person = ""
	message = ""

/datum/emote/living/shake
	key_third_person = ""
	message = ""

/datum/emote/living/shiver
	key_third_person = ""
	message = ""

/datum/emote/living/sigh
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/whistle
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/hmm
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/huh
	key_third_person = ""
	message_muffled = "" 

/datum/emote/living/hum
	key_third_person = ""
	message = ""
	message_muffled = "" 

/datum/emote/living/smile
	key_third_person = ""
	message = ""

/datum/emote/living/carbon/clap
	key_third_person = ""
	message = ""

/datum/emote/living/sneeze
	key_third_person = ""
	message = ""
	message_muffled = ""

/datum/emote/living/hmph
	key = "hmph"
	key_third_person = ""
	message = ""
	message_muffled = ""
/mob/living/carbon/human/verb/emote_hmph()
	set name = ""
	set category = "Emotes.Noises"

	emote("hmph", intentional = TRUE)

/datum/emote/living/shh
	key_third_person = ""
	message = ""
	message_muffled = ""

/datum/emote/living/smug
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_smug()
	set name = ""
	set category = "Emotes"

	emote("smug", intentional = TRUE)

/datum/emote/living/sniff
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_sniff()
	set name = ""
	set category = "Emotes"

	emote("sniff", intentional = TRUE)

/datum/emote/living/snore
	key_third_person = ""
	message = ""
	message_mime = ""

/datum/emote/living/stare
	key_third_person = ""
	message = ""
	message_param = ""
/mob/living/carbon/human/verb/emote_stare()
	set name = ""
	set category = "Emotes"

	emote("stare", intentional = TRUE)

/datum/emote/living/strech
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_strech()
	set name = ""
	set category = "Emotes"

	emote("stretch", intentional = TRUE)

/datum/emote/living/sway
	key = "sway"
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_sway()
	set name = ""
	set category = "Emotes"

	emote("sway", intentional = TRUE)

/datum/emote/living/tremble
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_tremble()
	set name = ""
	set category = "Emotes"

	emote("tremble", intentional = TRUE)

/datum/emote/living/twitch
	key_third_person = ""
	message = ""

/datum/emote/living/twitch_s
	message = ""

/datum/emote/living/warcry
	key_third_person = ""
	message = ""
	message_muffled = ""

/datum/emote/living/wave
	key_third_person = ""
	message = ""
	
/datum/emote/living/whimper
	key_third_person = ""
	message = ""
	message_mime = ""
	message_muffled = ""

/datum/emote/living/wsmile
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_wsmile()
	set name = ""
	set category = "Emotes"

	emote("wsmile", intentional = TRUE)

/datum/emote/living/yawn
	key_third_person = ""
	message = ""
	message_muffled = ""

/datum/emote/living/squint
	key_third_person = ""
	message = ""

/datum/emote/living/snap
	key_third_person = ""
	message = ""

/datum/emote/living/blink
	key_third_person = ""
	message = ""

/datum/emote/living/stomp
	key_third_person = ""
	message = ""

/datum/emote/living/snap2
	key_third_person = ""
	message = ""

/datum/emote/living/snap3
	key_third_person = ""
	message = ""

/datum/emote/living/fsalute
	key_third_person = ""
	message = ""

/datum/emote/living/ffsalute
	key_third_person = ""
	message = ""

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = ""
	message = ""
/datum/emote/living/carbon/human/cry/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = ""

/*
/datum/emote/living/carbon/human/sexmoanlight/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = "makes a noise."
*/

/datum/emote/living/carbon/human/eyebrow
	message = ""

/datum/emote/living/carbon/human/grumble
	key_third_person = ""
	message = ""
	message_muffled = ""
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	message = ""
	message_param = ""

/datum/emote/living/carbon/human/pale
	message = ""
/mob/living/carbon/human/verb/emote_pale()
	set name = ""
	set category = "Emotes"

	emote("pale", intentional = TRUE)

/datum/emote/living/carbon/human/raise
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_raise()
	set name = ""
	set category = "Emotes"

	emote("raise", intentional = TRUE)

/datum/emote/living/carbon/human/salute
	key_third_person = ""
	message = ""
	message_param = ""
	restraint_check = TRUE
/mob/living/carbon/human/verb/emote_salute()
	set name = ""
	set category = "Emotes"

	emote("salute", intentional = TRUE)

/datum/emote/living/carbon/human/shrug
	key_third_person = ""
	message = ""
/mob/living/carbon/human/verb/emote_shrug()
	set name = ""
	set category = "Emotes"

	emote("shrug", intentional = TRUE)

/datum/emote/living/carbon/human/wag
	key_third_person = ""
	message = ""

/datum/emote/living/carbon/human/wing
	key_third_person = ""
	message = ""

/datum/emote/living/softmoan
	key = "softmoan"
	key_third_person = ""
	message = ""
	message_muffled = ""
	emote_type = EMOTE_AUDIBLE
	show_runechat = TRUE

/mob/living/carbon/human/verb/emote_softmoan()
	set name = ""
	set category = "Emotes.Noises"

	emote("softmoan", intentional = TRUE)

/datum/emote/living/moan
	key = "moan"
	key_third_person = ""
	message = ""
	message_muffled = ""
	emote_type = EMOTE_AUDIBLE
	show_runechat = TRUE

/mob/living/carbon/human/verb/emote_moan()
	set name = ""
	set category = "Emotes.Noises"

	emote("moan", intentional = TRUE)

/datum/emote/living/pat
	key = "pat"
	key_third_person = ""
	message = ""
	message_param = ""
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE

/mob/living/carbon/human/verb/emote_pat()
	set name = ""
	set category = "Emotes"

	emote("pat", intentional = TRUE, targetted = TRUE)

/datum/emote/living/pat/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(ishuman(target))
		playsound(target.loc, 'sound/vo/hug.ogg', 100, FALSE, -1)

/*
/datum/emote/living/stat_roll/strength
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/perception
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/intelligence
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/constitution
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/willpower
	modifiers_list = list(
		TRAIT_TOLERANT = -1,
	)

	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/speed
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/fortune
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)

/datum/emote/living/stat_roll/charisma
	attempt_message_list = list(
		"",
		"",
		"",
	)

	success_message_list = list(
		"",
		"",
		"",
	)

	failure_message_list = list(
		"",
		"",
		"",
	)
*/

/datum/emote/living/carbon/slowclap
	key_third_person = ""
	message = ""

/datum/emote/living/carbon/clap1
	key_third_person = ""
	message = ""