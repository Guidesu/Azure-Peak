// Ported from Ratwood-2.0's code/datums/sexcon/sex_actions/force/*.dm.
// These are "force" variants of oral acts: the user grabs the target and forces
// them to service the user, as opposed to sexcon2's existing oral/ category
// (which is framed as the user performing oral on the target). Gated on an
// aggressive grab via require_grab/required_grab_state, both of which already
// exist on /datum/sex_action in this repo's _base_action.dm but were unused
// until this port.
/datum/sex_action/force
	abstract_type = /datum/sex_action/force
	require_grab = TRUE
	required_grab_state = GRAB_AGGRESSIVE
	stamina_cost = 1.0
	debug_erp_panel_verb = FALSE
