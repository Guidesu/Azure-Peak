// Inspiration system — adapted from CEV-Eris's inspiration_component
// Examining certain objects (art, books, oddities) gives inspiration
// which converts to insight over time

/datum/component/inspiration
	/// How much inspiration this object provides
	var/inspiration_amount = 5
	/// Cooldown between uses (deciseconds)
	var/cooldown = 5 MINUTES
	/// Last time this was used
	var/last_used = -INFINITY
	/// Whether this object can be used multiple times
	var/reusable = TRUE
	/// Message shown when inspired
	var/inspire_message = "You feel inspired by this."

/datum/component/inspiration/Initialize(amount = 5, cd = 5 MINUTES, _reusable = TRUE, _message = null)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	inspiration_amount = amount
	cooldown = cd
	reusable = _reusable
	if(_message)
		inspire_message = _message

/datum/component/inspiration/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/inspiration/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/datum/component/inspiration/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return
	if(world.time < last_used + cooldown)
		examine_list += span_notice("You've recently examined this. You need time to reflect before it inspires you again.")
		return
	last_used = world.time
	H.sanity.give_insight(inspiration_amount)
	to_chat(H, span_notice(inspire_message))
	if(!reusable)
		qdel(parent)

// ============== INSPIRATION PRESETS ==============

// Art objects — paintings, statues, tapestries
/datum/component/inspiration/art
	inspiration_amount = 10
	cooldown = 10 MINUTES
	inspire_message = "The artistry moves you. You feel a surge of inspiration."

// Books and scrolls
/datum/component/inspiration/literature
	inspiration_amount = 8
	cooldown = 15 MINUTES
	inspire_message = "The words stir something within you. You feel enlightened."

// Holy objects — shrines, altars, relics
/datum/component/inspiration/holy
	inspiration_amount = 15
	cooldown = 30 MINUTES
	inspire_message = "You feel the divine presence. Your spirit is uplifted."

// Nature — beautiful views, ancient trees, waterfalls
/datum/component/inspiration/nature
	inspiration_amount = 5
	cooldown = 5 MINUTES
	inspire_message = "The beauty of nature fills you with peace."

// Dark/forbidden — cursed objects, dark tomes, haunted items
/datum/component/inspiration/dark
	inspiration_amount = 20
	cooldown = 30 MINUTES
	inspire_message = "The forbidden knowledge tempts you. You feel both drawn and repelled."
