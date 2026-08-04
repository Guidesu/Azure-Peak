# DreamValley — Agent Notes

## Build / Compile

This project compiles with BYOND DreamMaker (dm.exe).

```powershell
& "C:\Users\lugin\Desktop\BYOND\bin\dm.exe" -max_errors 0 roguetown.dme
```

A clean compile prints `0 errors, 0 warnings`.
The `roguetown.dmb` output is the compiled game file.

OpenDream can also be used but the path in older docs is stale; DreamMaker
is the primary compiler.

## Simple Animal / Carbon Architecture

All simple animals inherit from `/mob/living/carbon/simple_animal` (not
`/mob/living/simple_animal`). This means every simple animal — hostile
creatures, farm animals, familiars, bosses, undead, etc. — is now a full
carbon mob with bodyparts, organs, reagents, and carbon combat mechanics.

Key implementation details:

- **Type path**: `/mob/living/carbon/simple_animal` (defined in
  `code/modules/mob/living/simple_animal/simple_animal.dm`)
- **Bodyparts/organs**: Created in `Initialize()` via `create_bodyparts()`
  and `create_internal_organs()`. Default organs (lungs, heart, brain,
  tongue, eyes, ears, liver, stomach) are spawned if none are set.
- **Health**: `updatehealth()` counts ALL damage types (brute, burn, tox,
  oxy, clone) using carbon's bodypart-based getters, so bodypart damage
  reduces health just like the old simple_animal system.
- **Damage routing**: `adjustHealth()` routes through carbon's
  `take_overall_damage()` / `heal_overall_damage()` which distribute
  damage across bodyparts.
- **Icon rendering**: `update_body_parts()` and `update_damage_overlays()`
  are no-ops; simple animals use a single icon state, not bodypart overlays.
- **pseudo_carbon**: The old `/mob/living/carbon/simple_animal/pseudo_carbon`
  subtype still exists for backward compatibility but is now largely
  redundant since all simple animals are already carbon.

## Sexcon / Chastity Port

The sexcon system was ported from Ratwood-2.0. Ratwood-specific paths that
don't exist in this codebase are stubbed in
`code/datums/sexcon/sexcon_port_stubs.dm` so the ported code compiles without
editing every call site. Key stub categories:

- **Patron aliases**: Xylix→Viator, Baotha→Hausvette, Eora→Miluse
- **Status effects**: stinky_contact, emberwine, cum_consumed, surrender/collar
- **Stress events**: cumok, cummax, unseemly_made_love, thrill, chastity_*
- **Components**: collar_master (minimal), intimate_reaction (full, in modular/)
- **Vars/procs**: has_gnoll_scent_this_round, bellsound, check_handholding,
  eora_register_consensual_pair, start_sex_session, log_chastity_command

The full chastity device system (core, equip, variants, cursed, keys, sprite
accessory, bodypart feature) lives under
`modular/code/game/objects/items/lewd/chastity/` and
`code/game/objects/items/rogueitems/keys_chastity.dm`.

Chastity-related defines are in `code/__DEFINES/sexcon_defines.dm`
(TRAIT_CHASTITY__, CHASTITY__ constants, BODYPART_FEATURE_CHASTITY,
COMSIG_CARBON_LOSE_CHASTITY).

## Stat Integration System

DreamValley has 7 core stats (STR/PER/INT/CON/WIL/SPD/LCK) defined on
`/mob/living` in `code/modules/mob/living/stats.dm`. The stat integration
system in `code/modules/mob/living/stat_integration.dm` extends these stats
to affect non-combat actions, ported from CEV-Eris design.

**Utility procs:**

- `get_stat_mult(stat, cap)` — action-time multiplier (0-1) based on stat
- `get_stat_speed(stat)` — speed multiplier (0.5-2.0), 1.0 at baseline 10
- `get_min_stat(list)`, `get_max_stat(list)`, `get_sum_stat(list)`, `get_avg_stat(list)` — compound checks
- `stat_check(stat, difficulty, chance_per_point)` — returns quality tier 0-5
- `stat_check_best(list, ...)`, `stat_check_all(list, ...)` — multi-stat versions
- `add_temp_stat(stat, amount, duration, id)` / `remove_temp_stat(stat, id)` — timed buffs/debuffs

**Convenience procs** (all defined on `/mob/living`):

- `get_crafting_speed_mult()`, `get_crafting_quality_mod()` — INT/PER
- `get_surgery_success_mod()`, `get_surgery_speed_mult()` — INT/PER
- `get_mining_speed_mult()`, `get_mining_yield_mod()` — STR/CON
- `get_lumber_speed_mult()` — STR/SPD
- `get_alchemy_quality_mod()` — INT/WIL
- `get_cooking_quality_mod()` — INT/PER
- `get_lockpick_success_mod()`, `get_lockpick_speed_mult()` — PER/SPD
- `get_fishing_success_mod()` — PER/LCK
- `get_foraging_success_mod()` — PER/INT

**Quality tier defines** (in `code/__DEFINES/roguetown.dm`):
`STAT_QUALITY_FAILURE` (0) through `STAT_QUALITY_MASTERWORK` (5).
`STAT_BASELINE` (10), `STAT_CEILING` (20).

**Integrated systems:**

- Crafting (`code/datums/components/crafting/crafting.dm`) — speed + success + quality
- Blacksmithing (`code/modules/roguetown/roguejobs/blacksmith/anvil_recipes/_anvil_recipe.dm`) — success chance
- Item quality (`code/game/objects/items.dm` `apply_quality()`) — roll bonus from INT/PER
- Surgery (`code/modules/surgery/_surgery_step.dm`) — success chance from INT/PER
- Mining (`code/_onclick/item_attack.dm`) — damage multiplier from STR/CON
- Lumberjacking (`code/_onclick/item_attack.dm`) — damage multiplier from STR/SPD
- Alchemy (`code/modules/roguetown/roguecrafting/alchemy/mortarpestle.dm`) — bonus output from INT/WIL
- Cooking (`modular/Neu_Food/cooking_helpers.dm` `get_cooktime_divisor_stat()`) — speed from INT/SPD
- Lockpicking (`code/game/objects/structures/mineral_doors.dm`) — speed + success from PER/SPD
- Fishing (`code/modules/roguetown/roguejobs/fisher/rod.dm`) — wait time + success from PER/LCK
- Foraging (`code/game/objects/structures/roguetown/rogueflora.dm`) — success from PER/INT

## Weapon Modification System

A weapon attachment system ported from CEV-Eris gun_upgrade design,
fantasy-reskinned. Allows applying removable mods to weapons that modify
their stats (force, defense, armor penetration, durability, balance, etc.)
and add on-hit effects (burn, toxin, holy damage).

**Files:**

- Defines: `code/__DEFINES/weapon_mods.dm` (slots, upgrade keys, weapon type tags)
- Component: `code/datums/components/weapon_mods.dm` (`/datum/component/weapon_mods`)
- Items: `code/game/objects/items/rogueweapons/weapon_mods/weapon_mods.dm`

**How it works:**

1. Use a mod item on a weapon (via `afterattack`) to attach it
2. The component is auto-created on the weapon if it doesn't exist
3. Mods are stored in `attached_mods` list, keyed by slot
4. Each weapon can have at most one mod per slot
5. Use a crowbar or hammer on a modded weapon to remove mods (tgui list prompt)
6. Removing the last mod deletes the component

**Slots:** blade, grip, pommel, guard, shaft, bowstring, sight, crank,
boss, rim, coating

**Upgrade keys** (in `upgrades` list on each mod item):

- `WMOD_FORCE_ADD` / `WMOD_FORCE_MULT` — damage
- `WMOD_WDEFENSE_ADD` / `WMOD_WDEFENSE_WBONUS_ADD` — defense
- `WMOD_ARMOR_PEN_ADD` — armor penetration
- `WMOD_MAX_INTEGRITY_ADD` — durability
- `WMOD_INTDAMAGE_MULT` — integrity damage factor
- `WMOD_MINSTR_ADD` — STR requirement
- `WMOD_WBALANCE_SHIFT` — balance (heavier/swifter)
- `WMOD_THROWFORCE_ADD` — throw damage
- `WMOD_BLOCK_CHANCE_ADD` / `WMOD_COVERAGE_ADD` — shield stats
- `WMOD_CHARGESPEED_MULT` / `WMOD_RELOADTIME_MULT` — crossbow speed
- `WMOD_DAMFACTOR_MULT` / `WMOD_ACCFACTOR_MULT` — bow/crossbow stats
- `WMOD_SHARPNESS_SET` — set sharpness level
- `WMOD_BURN_DAMAGE` / `WMOD_TOX_DAMAGE` / `WMOD_HOLY_DAMAGE` — on-hit effects

**Weapon type tags** (type paths for `is_type_in_list` compatibility):
`WEAPON_TAG_SWORD`, `WEAPON_TAG_AXE`, `WEAPON_TAG_DAGGER`,
`WEAPON_TAG_POLEARM`, `WEAPON_TAG_BLUNT`, `WEAPON_TAG_WHIP`,
`WEAPON_TAG_BOW`, `WEAPON_TAG_CROSSBOW`, `WEAPON_TAG_SHIELD`,
`WEAPON_TAG_MELEE` (any `/obj/item/rogueweapon`),
`WEAPON_TAG_RANGED`, `WEAPON_TAG_ALL` (any `/obj/item`)

**Available mods** (20+ items):

- Melee: blade oils (fire/poison/holy), razor edge, rust coating, leather/wire/balanced grips, heavy/light/gemstone pommels, reinforced/basket guards, reinforced/metal shafts
- Ranged: silk/sinew bowstrings, sighting pin, quick/heavy cranks
- Shield: iron/steel bosses, metal/spiked rims, sanctified coating

## Pseudo-Carbon Mob System

Makes simple animals (bears, wolves, trolls, etc.) grappleable, tackleable,
and limb-targetable like carbon mobs, without the full bodypart/organ overhead.

**Files:**

- Type + component: `code/modules/mob/living/simple_animal/pseudo_carbon.dm`
- Grab integration: `code/modules/mob/living/grabbing.dm` (choke, twist, smash)
- Pull integration: `code/modules/mob/living/living.dm` (start_pulling)
- Migrated animals: direbear, volf (wolf), boar, minotaur, troll

**Two approaches:**

1. **Type-based**: `/mob/living/simple_animal/pseudo_carbon` — inherit from this type
2. **Component-based**: `/datum/component/pseudo_carbon` — add to existing animals via `AddComponent(/datum/component/pseudo_carbon, wrestling_skill = N)`

**What it adds:**

- `/datum/pseudo_bodypart` — lightweight limb data (head, chest, arms, legs)
- Limb-specific damage tracking (brute/burn per limb)
- Limb disabling when damage exceeds max (legs give out, head stuns, arms go limp)
- Grapple resistance using wrestling_skill var
- Grab actions: choke (oxyloss), twist (limb damage), smash (limb into turf/obj)
- Sprint tackle already works via inherited `/mob/living` procs
- Examination shows damaged/disabled limbs

**Helper procs:**

- `is_pseudo_carbon(mob)` — checks both type and component
- `get_pseudo_carbon_bodypart(mob, zone)` — gets limb datum
- `get_pseudo_carbon_grab_limb(mob, user)` — finds which limb to grab

**Wrestling skill levels by animal:**

- Wolf/Boar: 2
- Direbear: 3
- Minotaur: 4
- Troll: 5

## Superior Animal System (Eris Approach)

Full carbon-based animal mobs — inherits from `/mob/living/carbon` to get
**everything** carbon has: bodyparts, organs, blood, reagents, grapple,
dismemberment, status effects. Inspired by CEV-Eris's
`/mob/living/carbon/superior_animal`.

**Files:**

- Base type: `code/modules/mob/living/carbon/superior_animal/superior_animal.dm`
- Mobs: `code/modules/mob/living/carbon/superior_animal/mobs/`
    - `direbear.dm` — direbear
    - `wolf_boar_minotaur_troll.dm` — wolf, boar, minotaur, troll

**What it gets from carbon (automatically):**

- Full bodyparts (head, chest, arms, legs) — per-limb damage tracking
- Full organ system (heart, lungs, brain, liver, stomach, etc.)
- Full blood system — bleeding, blood loss, transfusions
- Full reagent system — **all chems work** (poisons, healing, drugs)
- Full grapple system — grab/choke/twist/smash/dismember
- Full status effect system — all debuffs/buffs
- Fire/burn damage with bodypart-specific effects
- Dismemberment — limbs can be cut off
- Organ damage — heart attacks, liver failure, brain damage

**What it ports from simple_animal:**

- AI controller support (ai_controller var inherited from /atom)
- Intent system (base_intents inherited from /mob)
- Barding armor (bbarding)
- Butcher results (butcher_results, botched/perfect, head_butcher)
- Food type system (food_type, food_typecache)
- Remains type (remains_type)
- Death message, icon states (icon_living, icon_dead)
- Faction, ambushable, blood_toll_bucket (inherited from /mob/living)

**What it does NOT have:**

- No species/DNA (like spirit mobs — animals don't need human species)
- No human-specific HUD
- No human-specific inventory slots
- No human-specific speech/language system

**Helper proc:**

- `is_superior_animal(mob)` — checks if mob is a superior animal

**Migrated animals:**

- Direbear, Wolf (Volf), Boar, Minotaur, Troll
- Original simple_animal versions still exist (for backwards compat)
- pseudo_carbon component removed from original versions
