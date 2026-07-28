// Ported from Vanderlin (OpenKeep): code/controllers/subsystem/strategy_master.dm
//
// Processes every /mob/camera/strategy_controller (the RTS "overmind" camera
// mob) and every /datum/worker_mind (the per-worker AI/task loop) once per
// tick. Placed alongside this repo's other gameplay-grouping subsystems in
// code/controllers/subsystem/rogue/ (see roguerot.dm, roguemachine.dm for the
// established PROCESSING_SUBSYSTEM_DEF pattern here) rather than under
// controllers/subsystem/processing/, matching how this repo groups
// roguetown-specific gameplay ticking subsystems together.
PROCESSING_SUBSYSTEM_DEF(strategy_master)
	name = "Strategy Master"
	flags = SS_NO_INIT
	wait = 1 SECONDS
