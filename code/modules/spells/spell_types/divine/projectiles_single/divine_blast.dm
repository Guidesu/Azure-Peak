/datum/action/cooldown/spell/projectile/divine_blast
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon_state = "dblast"
	name = "Divine Blast"
	desc = "Shoot out a blast of divine power! Deals more damage to heretics(Vaeltians/Inhumen) and Undead! \n\
	Damage is increased by 100% versus simple-minded creechurs.\n\
	Toggle arc mode (Shift+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage."
	clothes_req = FALSE
	range = 12
	projectile_type = /obj/projectile/energy/divineblast
	projectile_type_arc = /obj/projectile/energy/divineblast/arc
	overlay_state = "divine_blast"
	sound = list('sound/magic/vlightning.ogg')
	active = FALSE
	releasedrain = 20
	chargedrain = 1
	chargetime = 0
	recharge_time = 5 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	invocations = list("Göttliche Macht")
	invocation_type = "shout"
	glow_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW
	projectile_type = /obj/projectile/energy/divineblast
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
		list("name" = "Focus", "tag" = "FOCUS", "proj" = /obj/projectile/energy/divineblast, "invocation" = "Sakral Strahl!"),
		list("name" = "Arc", "tag" = "ARC", "proj" = /obj/projectile/energy/divineblast/arc, "invocation" = "Sakral Strahl!"),
	)

/obj/projectile/energy/divineblast
	name = "Divine Blast"
	icon_state = "divine_blast"
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	damage = 20 // wont do much to a divine worshipper
	woundclass = BCLASS_STAB // divine blade!
	nodamage = FALSE
	npc_simple_damage_mult = 2 // The Simple Skele Gibber
	hitsound = 'sound/magic/churn.ogg'
	speed = 1

/obj/projectile/energy/divineblast/arc
	name = "arced divine blast"
	damage = 32
	arcshot = TRUE

/obj/projectile/energy/divineblast/on_hit(target, blocked = FALSE)
	. = ..()
	if(blocked >= 100)
		return
	if(isliving(target))
		var/mob/living/H = target
		if(H.job in GLOB.church_positions) // TRAIT_CLERGY could work here but is unmaintained and druids, sextons, etc. all lack it.
			visible_message(span_warning("The divine blast bounces off [H] harmlessly!"))
			playsound(get_turf(H), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(out_of_effective_range())
			return
		if(H.mob_biotypes & MOB_UNDEAD)
			damage += 10
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.patron, /datum/patron/concordat))
			if(H in GLOB.excommunicated_players)
				damage += 20
		if(istype(H.patron, /datum/patron/unveiled))
			damage += 20
		if(istype(H.patron, /datum/patron/tribunal/praecursor))
			damage += 20
		if(HAS_TRAIT(H, TRAIT_SILVER_WEAK) && !H.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
			H.visible_message("<font color='white'>Divine power rebukes [H]!</font>")
			to_chat(H, span_userdanger("Divine fury rebukes my presence! My body catches aflame!")) //Its NOT a Silver sunder, for balance reasons w/ the buffs. Change this back to sunders when clergy isn't absolutely fucked to fight.
			H.adjust_fire_stacks(2, /datum/status_effect/fire_handler/fire_stacks/divine)
			H.ignite_mob()
		if(H.has_status_effect(/datum/status_effect/debuff/necran_cross))
			// Undead weakened by a blessed necran cross are more fragile to divine bendings
			damage += 30
		var/mob/living/carbon/human/caster
		if (ishuman(firer))
			caster = firer
			switch(caster.patron.type)
				if(/datum/patron/tribunal/custodius)
					damage += 15 // just more raw damage. As mentioned in UNDIVIDED. Our generics are better as a trade off of not having higher tier uniques.
					H.visible_message(span_warning("Holy light slams into [H] with force!"), span_warning("Holy light slams into me with force!"))
				if(/datum/patron/concordat/auxentius)
					if(istype(H.patron, /datum/patron/concordat/morwenna))
						H.visible_message(span_warning("[H] is engulfed in flames!"), span_warning("Auxentius's <b>hatred</b> sets me aflame!"))
						H.adjust_fire_stacks(3) //ANCIENT ENEMY I DO NOT FEAR YOU
						H.ignite_mob()
					else
						H.visible_message(span_warning("[H] is engulfed in flames!"), span_warning("Auxentius's fury sets me aflame!"))
						H.adjust_fire_stacks(2) //Remains regular, setting everyone on fire is funnier
						H.ignite_mob()
				if(/datum/patron/concordat/wulfric)
					H.visible_message(span_warning("Water seeps from [H]'s lips!"), span_warning("Choking water in my lungs!"))
					H.Dizzy(5)
					H.emote("drown")
				if(/datum/patron/severance/ignatius)
					H.Slowdown(2) // Shared with Auxentius cuz immobilize + offbal is 2 strong
					H.visible_message(span_warning("Roots coil around [H]'s legs!"), span_warning("Roots tangle around my legs!"))
				if(/datum/patron/concordat/morwenna)
					if((H.mob_biotypes & MOB_UNDEAD) || HAS_TRAIT(H, TRAIT_DEATHLESS)) //DEATH TO THE DEATHLESS, NECRA HATES YOU.
						H.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
						H.ignite_mob()
						H.visible_message(span_warning("[H] is rebuked by Divine Scorn!"), span_warning("The Undermaiden's <b>scornful</b> gaze rebukes me!"))
				if(/datum/patron/concordat/handwerra)
					H.vomit(stun = 0)
					H.adjustToxLoss(10)
					H.visible_message(span_warning("[H] expels some leeches out of them!"), span_warning("Something roils within me!"))
					new /obj/item/natural/worms/leech(get_turf(H))
				if(/datum/patron/concordat/miluse)
					H.blur_eyes(10)
				if(/datum/patron/concordat/miluse)
					H.visible_message(span_warning("Moonlight engulfs [H]"), span_warning("Moonlight engulfs me!"))
					damage += (caster.get_stat(STATKEY_INT) * 2)
				if(/datum/patron/concordat/auxentius)
					H.Slowdown(2)
					H.visible_message(span_warning("Divine chains briefly coil around [H]'s legs!"), span_warning("Divine chains briefly shackle around my legs!"))
				if(/datum/patron/concordat/handwerra)
					H.adjustBruteLoss(10) //Think of it like hammering into you, it was straight direct armor-peircing burn damage before and could crit you insanely fast
					H.visible_message(span_warning("[H] is hammered with divine force!"), span_warning("Malum's disappointment hammers into me!"))
					//He's not mad, he's not proud, he's not hateful, he's as neutrally disappointed in you as one can be. (Its also funnier this way)
	else
		L.apply_damage(damage_to_do, BURN)

/obj/projectile/energy/divineblast/proc/apply_god_bonus(mob/living/L)
	var/mob/living/carbon/human/caster = firer
	if(!istype(caster))
		return

	switch(caster.patron?.type)
		if(/datum/patron/divine/undivided)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/astrata)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/noc)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/dendor)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/abyssor)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/ravox)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/necra)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/xylix)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/pestra)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/malum)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		if(/datum/patron/divine/eora)
			L.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/divine)
			L.ignite_mob()
			L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)

/datum/action/cooldown/spell/projectile/divine_blast/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/divine_blast/proc/apply_mode(index)
	var/list/mode = modes[index]
	projectile_type = mode["proj"]
	invocations = list(mode["invocation"])
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/divine_blast/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] mode."))

/datum/action/cooldown/spell/projectile/divine_blast/proc/update_mode_maptext(tag)
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

/datum/action/cooldown/spell/projectile/divine_blast/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Firing mode (Shift+G): Focus (standard blast) / Arc (lobs over obstacles with reduced damage).")
	return stats
