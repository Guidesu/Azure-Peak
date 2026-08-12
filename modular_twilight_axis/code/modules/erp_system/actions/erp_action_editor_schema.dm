/datum/erp_action_editor_schema

/// Exports editor UI field descriptors for this action (schema + current values + options).
/datum/erp_action_editor_schema/proc/export_editor_fields(datum/erp_action/A)
	. = list()
	. += list(_make_field("action_scope", "", "enum", A.action_scope, "", null, null, null, _scope_options(), "", null))
	. += list(_make_field("required_init_organ", "", "enum", A.required_init_organ, "", null, null, null, _organ_options()))
	. += list(_make_field("required_target_organ", "", "enum", A.required_target_organ, "", null, null, null, _organ_options()))
	. += list(_make_field("reserve_target_organ", "", "bool", A.reserve_target_organ, ""))
	. += list(_make_field("active_arousal_coeff", "", "number", A.active_arousal_coeff,  "", 0, 10, 0.1))
	. += list(_make_field("passive_arousal_coeff", "", "number", A.passive_arousal_coeff, "", 0, 10, 0.1))
	. += list(_make_field("active_pain_coeff", "", "number", A.active_pain_coeff,     "", 0, 10, 0.1))
	. += list(_make_field("passive_pain_coeff", "", "number", A.passive_pain_coeff,    "", 0, 10, 0.1))
	. += list(_make_field("inject_timing", "", "enum", A.inject_timing, "", null, null, null, _inject_timing_options()))
	. += list(_make_field("inject_source", "", "enum", A.inject_source, "", null, null, null, _inject_source_options()))
	. += list(_make_field("inject_target_mode", "", "enum", A.inject_target_mode, "", null, null, null, _inject_target_mode_options()))
	. += list(_make_field("require_same_tile", "", "bool", A.require_same_tile, ""))
	. += list(_make_field("allow_when_restrained", "", "bool", A.allow_when_restrained, ""))
	. += list(_make_field("require_grab", "", "bool", A.require_grab, ""))
	. += list(_make_field("required_item_tags", "", "string_list", A.required_item_tags, "", null, null, null, null, "", "tag"))
	. += list(_make_field("action_tags", "", "string_list", A.action_tags, "", null, null, null, null, "", "tag"))
	. += list(_make_field("message_start", "", "text", A.message_start, ""))
	. += list(_make_field("message_tick", "", "text", A.message_tick, ""))
	. += list(_make_field("message_finish", "", "text", A.message_finish, ""))
	. += list(_make_field("message_climax_active", "", "text", A.message_climax_active, ""))
	. += list(_make_field("message_climax_passive", "", "text", A.message_climax_passive, ""))

/// Creates a single editor field descriptor.
/datum/erp_action_editor_schema/proc/_make_field(id, label, type, value, section, min=null, max=null, step=null, options=null, desc=null, placeholder=null)
	var/list/F = list(
		"id" = id,
		"label" = label,
		"type" = type,
		"value" = value,
		"section" = section
	)

	if(!isnull(min))
		F["min"] = min
	if(!isnull(max))
		F["max"] = max
	if(!isnull(step))
		F["step"] = step
	if(islist(options))
		F["options"] = options
	if(!isnull(desc))
		F["desc"] = desc
	if(!isnull(placeholder))
		F["placeholder"] = placeholder

	return F

/// Converts ticks to seconds (UI/editor convenience).
/datum/erp_action_editor_schema/proc/_ticks_to_seconds(ticks)
	if(!isnum(ticks))
		return 0
	return ticks / 10

/// Creates an enum option entry for editor schemas.
/datum/erp_action_editor_schema/proc/_opt(value, name)
	return list("value" = value, "name" = name)

/// Builds organ enum options for editor schemas.
/datum/erp_action_editor_schema/proc/_organ_options()
	. = list()
	. += list(_opt(null, "—"))
	. += list(_opt(SEX_ORGAN_PENIS, ""))
	. += list(_opt(SEX_ORGAN_VAGINA, ""))
	. += list(_opt(SEX_ORGAN_ANUS, ""))
	. += list(_opt(SEX_ORGAN_MOUTH, ""))
	. += list(_opt(SEX_ORGAN_BREASTS, ""))
	. += list(_opt(SEX_ORGAN_HANDS, ""))
	. += list(_opt(SEX_ORGAN_LEGS, ""))
	. += list(_opt(SEX_ORGAN_TAIL, ""))
	. += list(_opt(SEX_ORGAN_BODY, ""))

/// Builds inject timing enum options for editor schemas.
/datum/erp_action_editor_schema/proc/_inject_timing_options()
	. = list()
	. += list(_opt(INJECT_NONE, ""))
	. += list(_opt(INJECT_CONTINUOUS, ""))
	. += list(_opt(INJECT_ON_FINISH, ""))

/// Builds inject source enum options for editor schemas.
/datum/erp_action_editor_schema/proc/_inject_source_options()
	. = list()
	. += list(_opt(INJECT_FROM_ACTIVE, ""))
	. += list(_opt(INJECT_FROM_PASSIVE, ""))

/// Builds inject target mode enum options for editor schemas.
/datum/erp_action_editor_schema/proc/_inject_target_mode_options()
	. = list()
	. += list(_opt(INJECT_ORGAN, ""))
	. += list(_opt(INJECT_CONTAINER, ""))
	. += list(_opt(INJECT_GROUND, ""))

/// Builds action scope enum options for editor schemas.
/datum/erp_action_editor_schema/proc/_scope_options()
	. = list()
	. += list(_opt(ERP_SCOPE_OTHER, ""))
	. += list(_opt(ERP_SCOPE_SELF,  ""))
