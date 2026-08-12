/obj/effect/proc_holder/spell/invoked/projectile/unholyblast // this CANNOT be a child of divine_blast bc you have to call parent on cast. 
	name = "Unholy Blast"
	desc = "Channel unholy power and sunder the unbelievers. Deals additional damage to wretched conformists and Vaeltites! \n\
	Damage is increased by 100% versus simple-minded creechurs.\n\
	Toggle arc mode (Shift+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage."
	clothes_req = FALSE
	range = 12
	overlay_state = "unholy_blast"
	projectile_type = /obj/projectile/energy/unholyblast
	projectile_type_arc = /obj/projectile/energy/unholyblast/arc
	sound = list('sound/magic/vlightning.ogg')
	active = FALSE
	releasedrain = 20
	chargedrain = 1
	chargetime = 0
	recharge_time = 5 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	invocations = list("Dunkle macht")
	invocation_type = "shout"
	glow_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW
	projectile_type = /obj/projectile/energy/unholyblast
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = 25
	invocation_type = INVOCATION_SHOUT
	charge_required = TRUE
	charge_time = CHARGETIME_MAJOR
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_swingdelay_type = SWINGDELAY_PENALTY
	charge_sound = 'sound/magic/charging.ogg'

	cooldown_time = 10 SECONDS
	associated_skill = /datum/skill/magic/holy
	spell_impact_intensity = SPELL_IMPACT_LOW
	spell_requirements = SPELL_REQUIRES_HUMAN
	var/next_bonus_time = 0
	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Focus", "tag" = "FOCUS", "proj" = /obj/projectile/energy/unholyblast, "invocation" = "Larkas Strahl!"),
		list("name" = "Arc", "tag" = "ARC", "proj" = /obj/projectile/energy/unholyblast/arc, "invocation" = "Larkas Strahl!"),
	)

/obj/projectile/energy/unholyblast
	name = "Unholy Blast"
	icon_state = "unholy_blast"
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	damage = 20 // wont do much to a heretical worshipper
	woundclass = BCLASS_CUT // I REALLY wanted to do cut
	nodamage = FALSE
	npc_simple_damage_mult = 2 // The Simple Skele Gibber
	hitsound = 'sound/magic/soulsteal.ogg' // its kinda quiet BUT its cool
	speed = 1

/obj/projectile/energy/unholyblast/arc
	name = "arced unholy blast"
	damage = 32
	arcshot = TRUE

/obj/projectile/energy/unholyblast/on_hit(target, blocked = FALSE)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] dissipates harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(M))
			var/mob/living/L = M
			if(out_of_effective_range())
				qdel(src)
				return
			if(blocked < 100)
				if(HAS_TRAIT(L, TRAIT_SILVER_WEAK) && !L.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
					L.visible_message("<font color='white'>Divine power staggers [L]!</font>")
					L.Immobilize(3 SECONDS)
					L.apply_status_effect(/datum/status_effect/debuff/clickcd, 3 SECONDS)
				apply_divine_damage(L)
				var/datum/action/cooldown/spell/projectile/unholy_blast/S = source_spell
				if(S && S.can_apply_god_bonus())
					apply_god_bonus(L)
					S.consume_god_bonus()
	qdel(src)

/datum/action/cooldown/spell/projectile/unholy_blast/proc/can_apply_god_bonus()
	return world.time >= next_bonus_time

/obj/projectile/energy/unholyblast/on_hit(target, blocked = FALSE)
	if(blocked >= 100)
		return
	if(isliving(target))
		var/mob/living/H = target
		if(out_of_effective_range())
			return
		if(H.mob_biotypes & MOB_UNDEAD)
			damage += 20
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.patron, /datum/patron/concordat))
			damage += 20
		if(istype(H.patron, /datum/patron/tribunal/praecursor))
			damage += 20
		var/mob/living/carbon/human/caster
		if (ishuman(firer))
			caster = firer
			switch(caster.patron.type)
				if(/datum/patron/oldkin/hausvette)
					H.adjustToxLoss(10)
					H.Dizzy(5)
					H.visible_message(span_warning("[H] looks unwell..."), span_warning("I feel dizzy... and I've been poisoned!"))
					if(HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !H.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
						H.visible_message("<font color='white'>Unholy power rebukes [H]!</font>")
						to_chat(H, span_userdanger("Unholy wrath rebukes my presence! My body catches aflame!"))
						H.adjust_fire_stacks(2, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
				if(/datum/patron/concordat/morwenna)
					if(HAS_TRAIT(H, TRAIT_NOBLE))
						damage += 10 
						H.adjust_fire_stacks(4) //ditto to Auxentius
						H.visible_message(span_warning("[H]'s blue blood burns bright!"), span_warning("My body burns-- my blood is being transacted into fire!"))
					else
						H.visible_message(span_warning("[H] is set aflame with gilded flames!"), span_warning("Gilded flame engulfs me!"))
					H.adjust_fire_stacks(2)
					H.ignite_mob()
					if(HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !H.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
						H.visible_message("<font color='white'>Unholy power rebukes [H]!</font>")
						to_chat(H, span_userdanger("Unholy wrath rebukes my presence! My body catches aflame!"))
						H.adjust_fire_stacks(2, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
				if(/datum/patron/oldkin/volkovoi)
					H.visible_message(span_warning("A splatter of blood covers [H]'s face!"), span_warning("A glob of blood splatters my vision!"))
					H.Dizzy(5)
					H.blur_eyes(5)
					if(HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !H.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
						H.visible_message("<font color='white'>Unholy power rebukes [H]!</font>")
						to_chat(H, span_userdanger("Unholy wrath rebukes my presence! My body catches aflame!"))
						H.adjust_fire_stacks(2, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
						H.Slowdown(4) //Suffer
				if(/datum/patron/unveiled/aurelian)
					if(istype(H.patron, /datum/patron/concordat/morwenna)) //Hilarious, always hit with full regardless of silver weak
						H.adjust_fire_stacks(6, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
						H.visible_message(span_warning("[H] is smited by unholy spite!"), span_warning("Zizo's seething <b>hatred</b> smites me!"))
						H.Slowdown(3)
					if(!HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !HAS_TRAIT(H, TRAIT_LYCANRESILENCE) && !istype(H.patron, /datum/patron/concordat/morwenna)) //We churn you for NOT being silver weak. ZIZO. ZIZO. ZIZO.
						H.adjust_fire_stacks(3, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
						H.visible_message(span_warning("Seething ambition sears [H]'s flesh aflame!"), span_warning("Visions of progress and ambition sears my flesh, mynd and sets me aflame!"))
						H.Slowdown(3)
					if(HAS_TRAIT(H, TRAIT_LYCANRESILENCE) && !istype(H.patron, /datum/patron/concordat/morwenna)) //EXCEPT WEREWOLVES... Fuck Ignatius. Specifically within werebeast form, hense the trait, not the antag check.
						H.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine) //Less cause this is an actual antag, UNLESS they worship Necra in which case you kind of deserve this.
						H.ignite_mob()
						H.visible_message(span_warning("[H] is churned by unholy spite!"), span_warning("Zizo's seething <b>hatred</b> rebukes me!"))
						H.Slowdown(3)
					if(HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !HAS_TRAIT(H, TRAIT_LYCANRESILENCE) && !istype(H.patron, /datum/patron/concordat/morwenna))
						H.visible_message(span_warning("Unholy spite slams into [H]!"), span_warning("Unholy spite slams into me!"))
						H.Slowdown(2) //Less severe slowdown
	else
		L.apply_damage(damage_to_do, BURN)

/obj/projectile/energy/unholyblast/proc/apply_god_bonus(mob/living/L)
	var/mob/living/carbon/human/caster = firer
	if(!istype(caster))
		return

	switch(caster.patron?.type)
		if(/datum/patron/inhumen/zizo)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/inhumen/graggar)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/inhumen/matthios)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/inhumen/baotha)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)

/datum/action/cooldown/spell/projectile/unholy_blast/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/unholy_blast/proc/apply_mode(index)
	var/list/mode = modes[index]
	projectile_type = mode["proj"]
	invocations = list(mode["invocation"])
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/unholy_blast/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] mode."))

/datum/action/cooldown/spell/projectile/unholy_blast/proc/update_mode_maptext(tag)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(tag)
		holder.color = "#00ccff"

/datum/action/cooldown/spell/projectile/unholy_blast/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Firing mode (Shift+G): Focus (standard blast) / Arc (lobs over obstacles with reduced damage).")
	return stats
