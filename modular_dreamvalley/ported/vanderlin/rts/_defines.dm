// Ported from Vanderlin (OpenKeep): code/__DEFINES/strategy_system.dm
//
// SCOPE NOTE: these are Vanderlin's RTS colony-sim stockpile/resource-kind
// constants (what a worker hauls/stores: stone, wood, ore, grain, etc), a
// completely different concept from BOTH:
//   - this repo's engine-level material system (code/__DEFINES/materials.dm,
//     SSmaterials, MAT_CATEGORY_*, getmaterialref())
//   - the already-ported Vanderlin crafting-material-IDENTITY layer
//     (modular_dreamvalley/ported/vanderlin/materials/_base.dm, /datum/material,
//     DV_MAT_HARDNESS_* constants)
// Vanderlin's original names for these RTS stockpile constants were bare
// `MAT_STONE`, `MAT_WOOD`, etc, which would collide/confuse against both of
// the above. Per the approved porting plan, they are renamed here to a
// `DV_RTS_MAT_*` prefix - distinct from the materials port's `DV_MAT_*`
// prefix so the two ported systems remain unambiguous at a glance. Every
// other Phase 1 RTS file (stockpile_datum.dm, etc) has been updated to use
// these renamed defines instead of the original MAT_* names.
#define DV_RTS_MAT_INGOT "Ingots"
#define DV_RTS_MAT_STONE "Stone"
#define DV_RTS_MAT_WOOD "Wood"
#define DV_RTS_MAT_GEM "Gems"
#define DV_RTS_MAT_ORE "Ores"
#define DV_RTS_MAT_COAL "Coal"
#define DV_RTS_MAT_GRAIN "Grain"
#define DV_RTS_MAT_VEG "Vegetable"
#define DV_RTS_MAT_FRUIT "Fruit"
#define DV_RTS_MAT_MEAT "Meat"
#define DV_RTS_MAT_CLOTH "Cloth"
#define DV_RTS_MAT_SILK "Silk"
#define DV_RTS_MAT_HIDE "Hide"
#define DV_RTS_MAT_LEATHER "Leather"

#define TASK_KEY_SPEED "speed"
#define TASK_KEY_REDUCTION "reduction"
#define TASK_KEY_QUANTITY "quantity"
// PHASE 5 ADDITION (worker_gear). Ported from Vanderlin's
// code/__DEFINES/strategy_system.dm - referenced by worker_gear/_base.dm's
// task_bonuses lists (e.g. pickaxe/hammer/cooking_knife's quality bonuses)
// but not used by any Phase 1-4 file, so it wasn't needed until now.
#define TASK_KEY_QUALITY "quality"

#define WORKER_SLOT_HEAD "head"
#define WORKER_SLOT_PANTS "pants"
#define WORKER_SLOT_SHIRT "shirt"
#define WORKER_SLOT_SHOES "shoes"
#define WORKER_SLOT_HANDS "hands"

// Vanderlin's code/__DEFINES/layers.dm defines STRATEGY_PLANE as -3,
// used by building_node rendering (Phase 2). This repo already has a plane
// at that exact numeric value for an unrelated purpose (GAME_PLANE_UPPER,
// code/__DEFINES/layers.dm) so the RTS plane constant is namespaced here
// rather than reusing/aliasing GAME_PLANE_UPPER. Not consumed by any Phase 1
// file yet (building_node is Phase 2) but declared now alongside the rest of
// the RTS define set so later phases have it available in one place.
#define DV_RTS_STRATEGY_PLANE -3

// Signal defines used by the Phase 1 worker AI loop (work_mind.dm) and by
// work orders (work_orders/_base_task.dm). Ported from Vanderlin's
// code/__DEFINES/dcs/signals/signals_ai.dm. COMSIG_WORKER_GEAR_CHANGED,
// COMSIG_WORKER_ATTACK_START/END and COMSIG_AI_PATH_GENERATED are declared
// here for completeness with the source file even though the gear/attack/
// enhanced-pathfinding code paths that send them are trimmed out of this
// phase's work_mind.dm (see that file's header comment) - later phases that
// restore those code paths will not need to re-add these defines.
#define COMSIG_WORKER_TASK_STARTED "worker_task_started"
#define COMSIG_WORKER_TASK_FINISHED "worker_task_finished"
#define COMSIG_WORKER_TASK_FAILED "worker_task_failed"
#define COMSIG_WORKER_STAMINA_CHANGED "worker_stamina_changed"
#define COMSIG_WORKER_MOVEMENT_SET "worker_movement_set"
#define COMSIG_WORKER_PAUSED_CHANGED "worker_paused_changed"
#define COMSIG_WORKER_GEAR_CHANGED "worker_gear_changed"
#define COMSIG_WORKER_IDLE_START "worker_idle_start"
#define COMSIG_WORKER_ATTACK_START "worker_attack_start"
#define COMSIG_WORKER_ATTACK_END "worker_attack_end"
#define COMSIG_AI_PATH_GENERATED "ai_path_generated"

// Phase 2 addition (building pipeline). Ported from Vanderlin's
// code/__DEFINES/dcs/signals/signals_ai.dm. Sent on a /turf when its pending
// break_turf work order is cancelled (worker died, order dequeued, etc) so
// both the in-flight /datum/work_order/break_turf and its
// /obj/effect/visual_effect/turf_break overlay can clean themselves up.
#define COMSIG_CANCEL_TURF_BREAK "cancel_turf_break"
