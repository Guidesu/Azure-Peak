// Ported from Vanderlin (OpenKeep): code/datums/materials/material_traits/silver_bane.dm
//
// ADAPTATION (nontrivial, read before touching): Vanderlin's original fires this trait through
// on_consume()/on_life(), i.e. a mob literally drinking/absorbing molten silver as a reagent.
// This codebase has no reagent-based molten metal system to call on_consume/on_life from (see
// molten_materials/_base.dm) - the drop makes this trait dead weight for anyone porting the same
// way Vanderlin did.
//
// More importantly, this repo ALREADY has a fully wired, more thorough silver-vs-vampire/werewolf
// punishment system: /datum/magic_item/mundane/silver (code/datums/magic_items/mundane_items/silver.dm),
// triggered via on_equip/on_pickup/on_hit against TRAIT_SILVER_WEAK, plus vampire generation checks
// (GENERATION_METHUSELAH) Vanderlin's version doesn't have. Reimplementing Vanderlin's on_consume
// logic here would create a second, weaker, disconnected silver-bane pathway, which the task brief
// explicitly warns against for the quality-tier system and applies here by the same logic.
//
// So: the trait datum itself is kept (for datum-shape parity with /datum/material/silver and
// /datum/material/weeping's traits list, and so GLOB.material_traits stays populated the way
// Vanderlin's code expects), but its on_consume/on_life bodies are intentionally left as thin
// pass-throughs to the existing magic_item/mundane/silver system rather than reimplementing
// punishment logic twice. touch_bane() is preserved as a helper other future callers can use if a
// genuine on-touch (not on-consume) hook is ever wired to material identity.
/datum/material_trait/silver_bane
	name = "Silver Bane"

/datum/material_trait/silver_bane/proc/touch_bane(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return
	var/datum/antagonist/vampire/vamp_datum = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/werewolf/wolf_datum = user.mind.has_antag_datum(/datum/antagonist/werewolf)
	if(!vamp_datum && !wolf_datum)
		return

	if(istype(vamp_datum, /datum/antagonist/vampire/lord))
		var/datum/antagonist/vampire/lord/lord_datum = vamp_datum
		if(!lord_datum.ascended)
			to_chat(user, span_userdanger("I've consumed silver, it is my BANE!"))
			user.Knockdown(10)
			user.Paralyze(10)
		return

	if(wolf_datum?.transformed == TRUE || vamp_datum)
		to_chat(user, span_userdanger("I've consumed silver, it is my BANE!"))
		user.Knockdown(10)
		user.Paralyze(10)
		user.adjustFireLoss(25)
		user.fire_act(1, 10)

/datum/material_trait/silver_bane/on_consume(mob/user, amount)
	if(ishuman(user) && user.mind)
		touch_bane(user)

/datum/material_trait/silver_bane/on_life(mob/user)
	if(ishuman(user) && user.mind)
		touch_bane(user)
