// Ported from Twilight-Axis's awful_artillery/code/_artillery.dm. Core
// artillery structure: azimuth/elevation/charge TGUI controls, skill/stat
// gated accuracy, barrel wear leading to a catastrophic burst, and a
// misfire chance for untrained users. All player-facing text and admin
// placeholder names translated from Russian into English.

#define GRAVITY 9.81
#define BASE_AZIMUTH_ERROR 16
#define OVERHEAT_ERROR 50

/obj/item/artillery_shell
	name = "artillery shell (base type - should not appear in-game)"
	icon = 'modular_dreamvalley/icons/twilight_artillery/artillery.dmi'
	icon_state = "cannonball"

/obj/item/artillery_shell/proc/shell_action()

/obj/structure/artillery
	name = "artillery piece (base type - should not appear in-game)"
	desc = "If you're seeing this, something didn't get subtyped properly."

	icon = 'modular_dreamvalley/icons/twilight_artillery/artillery.dmi'
	icon_state = "mortar"

	anchored = 0
	density = 1
	var/azimuth = 0
	var/elevation = 0
	var/elevation_min = 1
	var/elevation_max = 90

	var/charge_level = 0
	var/charge_min = 0
	var/charge_max = 5

	var/base_velocity = 5
	var/charge_velocity_step = 15

	var/ammo_type = /obj/item/artillery_shell

	var/obj/item/artillery_shell/ammo

	var/associated_skill = /datum/skill/combat/twilight_firearms
	var/associated_stat = STAT_INTELLIGENCE

	var/barrel_integrity = 15
	var/last_fired = 0
	var/cooldown  = 10 SECONDS

	var/no_expert_time_multiplier = 3

/obj/structure/artillery/Initialize()
	. = ..()
	barrel_integrity = rand(6, 14)
	charge_velocity_step = rand(8, 20)


/obj/structure/artillery/examine(mob/user)
	. = ..()
	if((world.time - last_fired) < cooldown)
		. += span_info("The barrel feels hot; you probably shouldn't fire it right now.")
	else
		. += span_info("The barrel feels cold; it should be safe to fire.")

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = user
		var/perception = C.get_stat(STAT_PERCEPTION) - 10
		if(perception > 0 || HAS_TRAIT(user, TRAIT_ARTILLERY_EXPERT))
			if(((barrel_integrity - perception) < 1) || HAS_TRAIT(user, TRAIT_ARTILLERY_EXPERT))
				. += span_danger("My keen eye tells me the barrel will be destroyed after [barrel_integrity] more shots.")
			else
				. += span_green("The piece looks sound. It should hold for at least a few more shots.")
		else
			. += span_green("The piece looks sound. It should hold for at least a few more shots.")

/obj/structure/artillery/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, ammo_type))
		if(ammo)
			to_chat(usr, span_info("There's already a shell loaded."))
		else
			if(do_after(user, 20, target = src))
				used_item.forceMove(src)
				ammo = used_item
				to_chat(usr, span_info("I load a shell into [src.name]."))
				playsound(src, 'modular_dreamvalley/sound/twilight_artillery/loading.ogg', 100, 0, 1, 1, null, null, FALSE, TRUE)
				log_game("[user] loaded artillery shell into [src]")

	if(istype(used_item, /obj/item/twilight_powderflask))
		if(ammo)
			to_chat(usr, span_info("There's a shell inside; I need to remove it before pouring in powder."))
		else
			playsound(src, 'modular_dreamvalley/sound/twilight_artillery/powder.ogg', 100, 0, 1, 1, null, null, FALSE, TRUE)
			if(do_after(user, 20, target = src))
				to_chat(usr, span_info("I load [src.name] with powder."))
				charge_level = min(charge_level + 1, charge_max)
				log_game("[user] added gun powder into [src]")

	return ..()


/obj/structure/artillery/proc/calculate_coordinates(mob/living/carbon/user)
	if(charge_level == 0)
		return

	var/user_stat = user.get_stat(associated_stat)
	var/user_skill = user.get_skill_level(associated_skill)

	var/velocity = base_velocity + charge_level * charge_velocity_step
	var/range = (velocity * velocity / GRAVITY) * sin(2 * elevation)

	var/overall_artillery_skill = user_skill + (user_stat - 10) / 2

	var/target_azimuth = azimuth

	if(!HAS_TRAIT(user, TRAIT_ARTILLERY_EXPERT))
		if(overall_artillery_skill < 5)
			target_azimuth += rand(-BASE_AZIMUTH_ERROR, BASE_AZIMUTH_ERROR)
		else if(overall_artillery_skill < 7)
			target_azimuth += rand(-BASE_AZIMUTH_ERROR/2, BASE_AZIMUTH_ERROR/2)
		else if(overall_artillery_skill < 10)
			target_azimuth += rand(-BASE_AZIMUTH_ERROR/4, BASE_AZIMUTH_ERROR/4)

	if((world.time - last_fired) < cooldown)
		range += rand(-OVERHEAT_ERROR, OVERHEAT_ERROR)
		target_azimuth += rand(-OVERHEAT_ERROR, OVERHEAT_ERROR)

	var/dx = range * sin(target_azimuth)
	var/dy = range * cos(target_azimuth)

	var/target_x = round(loc.x + dx)
	var/target_y = round(loc.y + dy)

	var/vector/target = vector(target_x, target_y)

	return target

/obj/structure/artillery/proc/fire_artillery(mob/user)
	var/mob/living/carbon/human/H = user
	if(charge_level == 0)
		to_chat(user, span_warning("There's no charge in the barrel."))
		return

	if(!ammo)
		to_chat(user, span_warning("There's no shell in the barrel."))
		return

	if(!HAS_TRAIT(user, TRAIT_ARTILLERY_EXPERT))
		var/user_stat = H.get_stat(associated_stat)
		var/user_skill = H.get_skill_level(associated_skill)
		var/overall_artillery_skill = user_skill + (user_stat - 10) / 2
		var/rand_roll = rand(1, 20)

		if((rand_roll + overall_artillery_skill) < 12)
			user.visible_message(span_danger("[user] makes a critical mistake firing! [src] is destroyed!"))
			explosion(src, 1, 2, 4, flame_range = 2)
			H.adjustBruteLoss(150)
			return

	var/vector/hit_coordinates = calculate_coordinates(user)
	if(!hit_coordinates)
		to_chat(user, span_warning("Something's stopping me from firing there."))
		return
	var/turf/target = locate(hit_coordinates.x, hit_coordinates.y, src.z)
	if(!target)
		to_chat(user, span_warning("Something's stopping me from firing there."))
		return

	for(var/turf/AT in get_adjacent_turfs(src.loc))
		new/obj/effect/particle_effect/smoke/arquebus(AT)
		if(rand(1,10) > 7)
			for(var/turf/BT in get_adjacent_turfs(AT))
				new/obj/effect/particle_effect/smoke/arquebus(BT)

	var/x_mid = src.x + ((target.x - src.x) * 0.5)
	var/y_mid = src.y + ((target.y - src.y) * 0.5)
	var/z_mid = src.z + ((target.z - src.z) * 0.5)
	var/turf/turf_mid = locate(floor(x_mid), floor(y_mid), floor(z_mid))

	playsound(turf_mid, 'modular_dreamvalley/sound/twilight_artillery/flyby.ogg', 100, 0, 50, 1, null, null, FALSE, TRUE)

	playsound(src, 'modular_dreamvalley/sound/twilight_artillery/launch.ogg', 100, 0, 20, 1, null, null, FALSE, TRUE)

	ammo.forceMove(target)

	ammo.shell_action()

	ammo = null

	charge_level = 0


	if((world.time - last_fired) < cooldown)
		barrel_integrity -= 2
	else
		barrel_integrity--
	last_fired = world.time

	user.visible_message(span_danger("[user] fires [src]!"))
	log_game("[user] fired artillery([src]) at [target.loc.name]([target.x] [target.y] [target.z])")
	message_admins("Artillery fired at [ADMIN_VERBOSEJMP(src.loc)] by [user] to [ADMIN_VERBOSEJMP(target)]")

	for(var/mob/M in GLOB.player_list)
		if(istype(M, /mob/living))
			var/message = "You hear the sound of artillery fire"
			var/dist = get_dist(get_turf(src), M)
			if(dist > 15)
				message += " from about [floor(dist/15)*15] meters away"
			if(M.z < src.z)
				message += " somewhere above"
			if(M.z > src.z)
				message += " somewhere below"

			var/dir = get_dir(M, src)
			switch(dir)
				if(NORTH)
					message += " to the north"
				if(SOUTH)
					message += " to the south"
				if(EAST)
					message += " to the east"
				if(WEST)
					message += " to the west"
				if(NORTHEAST)
					message += " to the northeast"
				if(NORTHWEST)
					message += " to the northwest"
				if(SOUTHEAST)
					message += " to the southeast"
				if(SOUTHWEST)
					message += " to the southwest"

			message += "."
			to_chat(M, message)

	if(barrel_integrity <= 0)
		src.visible_message(span_danger("[src] bursts apart from a worn-out barrel!"))
		explosion(src, 1, 2, 10, flame_range = 3)

/obj/structure/artillery/proc/get_parts()
	return list()

/obj/structure/artillery/ui_interact(mob/user, datum/tgui/ui)
	if(!istype(user, /mob/living/carbon/human))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Artillery", "Artillery")
		ui.open()

/obj/structure/artillery/ui_data(mob/user)
	var/list/data = list()
	data["elevation"] = elevation
	data["elevation_min"] = elevation_min
	data["elevation_max"] = elevation_max
	data["azimuth"] = azimuth
	data["charge_level"] = charge_level
	data["charge_max"] = charge_max

	var/vector/target = calculate_coordinates(user)
	if(target)
		var/turf/target_turf = locate(target.x, target.y, src.z)
		if(target_turf)
			var/velocity = base_velocity + charge_level * charge_velocity_step

			data["range"] = floor((velocity * velocity / GRAVITY) * sin(2 * elevation))

			data["area_name"] = target_turf.loc.name
		else
			data["range"] = "UNKNOWN"
			data["area_name"] = "UNKNOWN"
	else
		data["range"] = "UNKNOWN"
		data["area_name"] = "UNKNOWN"


	return data

/obj/structure/artillery/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("fire")
			if(charge_level == 0)
				to_chat(ui.user, span_warning("There's no charge in the barrel."))
				return
			if(!ammo)
				to_chat(ui.user, span_warning("There's no shell in the barrel."))
				return
			if(HAS_TRAIT(ui.user, TRAIT_ARTILLERY_EXPERT))
				if(do_after(ui.user, 15, target = src))
					fire_artillery(ui.user)
			else
				if(tgui_alert(ui.user, "You don't know how to properly operate this piece. Right now you're relying entirely on guesswork and intellect - using it incorrectly could have very bad consequences.", "Mortar", list("I won't fire", "FIRE!")) == "FIRE!")
					if(do_after(ui.user, 15, target = src))
						fire_artillery(ui.user)
		if("decrease_charge")
			if(do_after(ui.user, 10, target = src))
				charge_level = max(charge_level - 1, charge_min)
				playsound(src, 'modular_dreamvalley/sound/twilight_artillery/removepowder.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				ui.user.visible_message(span_info("[ui.user] removes some excess powder from [src]."))
		if("set_elevation")
			elevation = params["value"]
			playsound(src, 'modular_dreamvalley/sound/twilight_artillery/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
			ui.user.visible_message(span_info("[ui.user] adjusts the elevation."))
		if("set_azimuth")
			azimuth = params["value"]
			playsound(src, 'modular_dreamvalley/sound/twilight_artillery/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
			ui.user.visible_message(span_info("[ui.user] adjusts the azimuth."))
		if("eject_ammo")
			if(do_after(ui.user, 20, target = src))
				playsound(src, 'modular_dreamvalley/sound/twilight_artillery/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				ammo.forceMove(loc)
				ammo = null
				ui.user.visible_message(span_info("[ui.user] removes the shell from [src]."))
		if("disasseble")
			if(do_after(ui.user, 20, target = src))
				playsound(src, 'modular_dreamvalley/sound/twilight_artillery/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				var/list/parts =  get_parts()
				for(var/path in parts)
					new path(loc)
				ui.close()
				qdel(src)
				ui.user.visible_message(span_info("[ui.user] disassembles [src]."))

	SStgui.try_update_ui(ui.user, src)

/obj/item/artillery_assembly
	name = "gun carriage"
	w_class = WEIGHT_CLASS_HUGE


#undef GRAVITY
#undef BASE_AZIMUTH_ERROR
#undef OVERHEAT_ERROR
