# DreamValley campaign branch

This repository is the editable Azure Peak game used by DreamValley. It is not
a generated copy. Edit DM, DMI, DMM, TGUI, and configuration here in VS Code
exactly as you would for a normal SS13 codebase.

## Repository layout

- `origin` is `https://github.com/Guidesu/Azure-Peak.git`, your GitHub fork.
- `upstream` is `https://github.com/Azure-Peak/Azure-Peak.git`, official Azure
  Peak.
- `dreamvalley-campaign` is the long-lived campaign/integration branch.
- `modular_dreamvalley/` contains DreamValley-specific DM code.
- `roguetown.dme` has one DreamValley include at its end.

The local `rust_g64.dll` and compiled `roguetown.json` are intentionally ignored.
They are runtime/build dependencies, not source changes.

## Build and run from VS Code

Open this folder in VS Code, then use **Terminal → Run Task**:

1. `DreamValley: Compile Azure Peak`
2. `DreamValley: Run Azure Peak locally`

The run task binds to loopback with an automatically chosen port. It does not
open a router port. The installed Stardew host mod performs these same steps
automatically after loading a save.

## Normal development

Make a focused branch whenever you add a game feature:

```powershell
git switch dreamvalley-campaign
git switch -c feature/my-feature
```

Edit and test normally, commit the feature, then merge it into the campaign
branch. DreamValley-specific hooks should stay in `modular_dreamvalley` where
possible. Azure gameplay changes can live in their natural `code/`, `modular/`,
`icons/`, or `_maps/` locations.

## Bring in official Azure Peak updates

```powershell
git fetch upstream
git switch dreamvalley-campaign
git merge upstream/main
```

Resolve any normal gameplay conflicts, compile, and boot once before committing
the merge. Because DreamValley has one DME include and an isolated module, most
upstream updates should merge without touching the integration layer.

For one specific upstream fix instead of a full update:

```powershell
git fetch upstream
git cherry-pick <commit>
```

## Persistence model

Campaign worlds use a static DMM base plus persistent deltas:

- atomic periodic checkpoints;
- an append-only journal between checkpoints;
- changed turf chunks for construction and terrain;
- stable IDs for opted-in objects, containers, items, and characters;
- reconstruction of transient controllers, caches, signals, particles, and UI
  when the world starts.

The initial contracts are in
`modular_dreamvalley/persistence/contracts.dm`. Gameplay types opt in through
`dreamvalley_should_persist()` and return JSON-safe custom state. The campaign
manager tracks stable object IDs and dirty turf deltas. Runtime-created items,
structures, and machinery are captured as a two-pass object graph so nested
contents can be restored after their containers. The host-side store owns
atomic files and recovery.

OpenDream and the Stardew host communicate through
`data/dreamvalley/bridge`: DM emits generation-numbered checkpoint envelopes,
the host validates and atomically commits them, and DM consumes acknowledgement
files. Backlogs are committed in numeric generation order and replaying a
checkpoint after a host crash is idempotent.

## Campaign lifecycle

The DreamValley branch enables campaign mode even when Azure Peak is launched
directly instead of through Stardew:

- automatic round completion and its reboot pipeline are suppressed;
- one in-game day takes one real hour by default;
- dawn runs 06:00-07:00, day 07:00-20:00, dusk 20:00-21:00, and night
  21:00-06:00;
- the old nightly Triumph reward is disabled because an endless campaign would
  otherwise farm a round-balanced currency;
- ambient storyteller events remain active, but automatic antagonist assignment
  and injection are disabled;
- player gamemode/end-round votes are replaced by campaign settings;
- random, special, event, and Triumph migrant waves are disabled, while an
  administrator can still explicitly force a migrant wave;
- JOIN and Continue are the ordinary ways players enter the campaign;
- campaign rules, clock configuration, and checkpoint restoration are exposed
  through the JSON bridge and stored in checkpoints.

The default private-campaign rules are returned in the `rules` object of
`dreamvalley_campaign_status_json()`. They can be changed through
`dreamvalley_configure_rules_json()` using the keys
`ambient_storyteller_events`, `antagonists`, `player_votes`,
`automatic_migrants`, and `round_rewards`. The defaults preserve ambient world
activity but disable every automatic system that assumes a competitive round.
Explicit admin-forced events and deliberate server shutdown remain available.

Far Travel is intercepted before Azure's destructive cryosleep behavior. It
preflights the character graph, tests restoration on a disposable nullspace
body, stages a complete slot record, transfers the client to the normal
Character Sheet, and removes the runtime body only after the Stardew host
acknowledges that checkpoint. Unsupported live references or a round-trip
mismatch cancel before the source character is changed.

Ordinary character creation and JOIN now use Twilight Axis' TAT builder. Each
Character Sheet slot owns nine named TAT build presets. The builder edits
directions, stats, skill domains, traits, purchased equipment, backpack, and
stash, then **Save & Join World** maps its role direction to Azure's Towner,
Trader, Adventurer, or Wretch spawn shell and applies the matching Pliant class
without opening the old random class picker. Before world start it readies that
build; in a running world it joins immediately. Twilight-only equipment and
traits which do not exist in this Azure revision are omitted from the catalog.

This new-character path is deliberately separate from Continue. Continue
reconstructs the parked character graph and never applies TAT, a job outfit, or
new class equipment.

## Master roadmap

Completed foundation:

- [x] Editable, upstream-friendly Azure Peak campaign branch.
- [x] One-click Stardew/SMAPI host and client mod deployment.
- [x] Client content bundle discovery, hashing, and cache transfer.
- [x] Host-side atomic checkpoints, append-only journal, backup, and recovery.
- [x] Initial DM persistence contracts and stable object IDs.
- [x] Campaign mode enabled for Stardew-hosted and direct Azure launches.
- [x] Automatic round-timer completion suppressed.
- [x] One-real-hour day with short dawn/dusk and a longer daytime.
- [x] Destructive Far Travel blocked until safe character parking is complete.
- [x] DM-to-host checkpoint transport with acknowledgement and replay safety.
- [x] Persist the campaign clock and day counter in host checkpoints.
- [x] Initial runtime object graph with stable IDs and nested containment.

Core campaign work:

- [x] Persist changed turf chunks, construction, terrain, doors, containers,
  machinery, and nested items.
- [x] Add versioned character records keyed by ckey and Character Sheet slot.
- [x] Capture and restore body, mind, DNA/species, organ DNA, organs, limbs,
  appearance features, injuries, stats, skills/XP, traits, and reagents.
- [x] Capture and restore equipped, held, embedded, bandage, and recursively
  nested item graphs across modern and legacy inventory slots.
- [x] Add graph integrity checks and section-by-section round-trip diagnostics.
- [x] Persist JSON-safe mutable runtime state for spell cooldowns, legacy spell
  counters, status-effect duration/ticks/stacks, and item components.
- [x] Report concrete unresolved live references through a safe Far Travel
  audit instead of treating every spell, effect, and component as unsupported.
- [x] Add explicit graph-reference contracts for any bound/summoned objects
  reported by that audit, then pass a live-character round trip.
- [x] Make Far Travel stage and commit its exact character checkpoint before
  removing the runtime body, with crash recovery for acknowledged staging
  records.
- [x] Return the client to the normal Character Sheet while the durable
  checkpoint finishes.
- [x] Add Continue only when the selected Character Sheet slot has an exact
  parked character.
- [x] Make Continue restore the exact body and saved position without
  `AssignRole`, `EquipRank`, or duplicate class equipment.
- [x] Protect Continue with a durable resuming lock that recovers to parked
  after a crash or failed reconstruction.
- [x] Integrate the Twilight Axis TAT system as Class Selection and JOIN.
- [x] Let editing in the Character Sheet plus TAT JOIN deliberately apply a new
  character/build setup; do not add a separate Rebuild button.
- [x] Replace round-oriented storyteller, voting, antagonist, reward, and
  migration assumptions with campaign settings suitable for a private group.

Presentation and distribution:

- [x] Replace the campaign main menu with a BYOND-hub-inspired screen, live
  campaign card, cache progress, and local host controls.
- [ ] Show available worlds/servers, campaign status, JOIN/Continue, character
  access, cached-resource progress, and host controls in that hub. The active
  campaign/status/control foundation is complete; multi-world discovery and the
  gameplay-backed character actions still require the OpenDream bridge.
- [ ] Preserve BYOND-like client convenience: connect once, receive/cache
  resources, and never download the host's source repository.
- [ ] Finish the Stardew rendering/input bridge so Azure gameplay is visible
  and playable inside the Stardew shell rather than only running beside it.
- [ ] Package host and client releases with versioned cache manifests and
  update/mismatch handling.
