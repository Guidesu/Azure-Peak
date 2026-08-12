// Breakdown datum — triggered when sanity reaches 0
// Can be positive (resilience, second wind) or negative (panic, self-harm)

/datum/breakdown
	var/name
	var/datum/sanity/holder

	var/icon_state
	var/breakdown_sound

	var/start_message_span = "danger"
	var/list/start_messages
	var/list/end_messages

	var/duration = 30 MINUTES
	var/end_time
	var/delay

	var/finished = FALSE
	var/insight_reward
	var/is_negative = FALSE

	var/restore_sanity_pre
	var/restore_sanity_post

/datum/breakdown/New(datum/sanity/S)
	..()
	holder = S

/datum/breakdown/Destroy()
	holder = null
	return ..()

/datum/breakdown/proc/can_occur()
	return !!name

/datum/breakdown/proc/update()
	if(finished || (duration && world.time > end_time) || !holder?.owner || holder.owner.stat == DEAD)
		conclude()
		return FALSE
	return TRUE

/datum/breakdown/proc/init_update()
	if(world.time + duration >= end_time + delay)
		return TRUE
	return FALSE

/datum/breakdown/proc/occur()
	if(holder?.owner && breakdown_sound)
		holder.owner.playsound_local(get_turf(holder.owner), breakdown_sound, 100)
	if(start_messages)
		to_chat(holder.owner, span_danger(pick(start_messages)))
	if(restore_sanity_pre)
		holder.restoreLevel(restore_sanity_pre)
	if(delay > 0)
		duration += delay
	if(duration == 0)
		conclude()
		return FALSE
	else if(duration > 0)
		end_time = world.time + duration
	return TRUE

/datum/breakdown/proc/conclude()
	if(!holder?.owner)
		qdel(src)
		return
	if(end_messages)
		to_chat(holder.owner, span_notice(pick(end_messages)))
	if(insight_reward)
		if(finished)
			holder.give_insight(insight_reward)
			if(restore_sanity_post)
				holder.restoreLevel(restore_sanity_post)
		else if(is_negative)
			holder.changeLevel(-rand(20,30))
	else if(restore_sanity_post)
		holder.restoreLevel(restore_sanity_post)
	qdel(src)
