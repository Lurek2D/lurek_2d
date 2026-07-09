# Dice Placement Strategy

## Design target

A technical game design document for a marketable 2D Dice Placement Strategy built with Lurek2D. The design target is drafted dice, worker slots, round pressure, and transparent scoring, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Dice Placement Strategy should be positioned as a focused card board dice entry about drafted dice, worker slots, round pressure, and transparent scoring. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Board and dice UI | `lurek.ui`, `lurek.render`, `lurek.tween`, `lurek.audio` | For Dice Placement Strategy, this area covers board and dice ui from the current design; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Rule state | `lurek.patterns`, `lurek.serialize`, `lurek.math` | For Dice Placement Strategy, this area covers rule state from the current design; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Data | `lurek.filesystem`, `lurek.dataframe` | For Dice Placement Strategy, this area covers data from the current design; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| AI/tutorial | `lurek.ai`, `lurek.dialog` | For Dice Placement Strategy, this area covers ai/tutorial from the current design; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for inspectable decision scoring and scheduled planners. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. |
| Persistence | `lurek.save` | For Dice Placement Strategy, this area covers persistence from the current design; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Turn phases and rule stack | `lurek.patterns`, `lurek.timer`, `lurek.event` | For Dice Placement Strategy, this area covers modeling draft, action, response, cleanup, and scoring phases as explicit state transitions; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Cards, boards, and token presentation | `lurek.sprite`, `lurek.ui`, `lurek.render` | For Dice Placement Strategy, this area covers drawing hands, pieces, prompts, legal targets, and resolved effects from rule state; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Rule data and replay checks | `lurek.dataframe`, `lurek.serialize`, `lurek.save` | For Dice Placement Strategy, this area covers validating card or board records and keeping match replays separate from profile progression; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Scene ownership and mode boundaries | `lurek.scene` | For Dice Placement Strategy, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Dice Placement Strategy, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Dice Placement Strategy, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Dice Placement Strategy, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Dice Placement Strategy, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Dice Placement Strategy, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Dice Placement Strategy, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Dice Placement Strategy, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Dice Placement Strategy, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support drafted dice, worker slots, round pressure, and transparent scoring. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Dice Placement Strategy state should center on drafted dice, worker slots, round pressure, and transparent scoring. Treat dice as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Dice Placement Strategy state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for dice placement strategy previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Dice Placement Strategy into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where dice, placement slots, resources, round goals, rivals, and scoring triggers need stable identity across several systems. Single-purpose values can stay in domain tables, but any dice placement strategy object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Dice Placement Strategy is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/dice_placement_strategy/main.lua` - owns dice placement strategy callback handoff and startup wiring.
- `content/games/dice_placement_strategy/conf.toml` - owns dice placement strategy window, input, asset, and runtime defaults.
- `content/games/dice_placement_strategy/data/dice_placement_strategy_rules.toml` - owns dice placement strategy authored rules for drafted dice, worker slots, round pressure, and transparent scoring.
- `content/games/dice_placement_strategy/data/dice.toml` - owns dice placement strategy content records for dice.
- `content/games/dice_placement_strategy/scripts/scenes/dice_placement_strategy_play.lua` - owns dice placement strategy scene-local orchestration and pause/result transitions.
- `content/games/dice_placement_strategy/scripts/systems/dice_placement_strategy_state.lua` - owns dice placement strategy authoritative state containers and domain update order.
- `content/games/dice_placement_strategy/scripts/systems/dice_placement_strategy_validation.lua` - owns dice placement strategy data integrity checks before content enters a run.
- `content/games/dice_placement_strategy/scripts/ui/dice_placement_strategy_hud.lua` - owns dice placement strategy HUD, inspector, prompt, and accessibility surfaces.
- `content/games/dice_placement_strategy/assets/dice_placement_strategy/` - owns dice placement strategy media grouped by stable asset IDs.

## Game structure

Dice Placement Strategy should be built as a set of named domain services rather than one large gameplay script.

- `dice_placement_strategy_state` owns durable dice, placement slots, and resources records.
- `dice_placement_strategy_rules` validates commands, applies drafted dice, worker slots, round pressure, and transparent scoring, and emits deterministic events.
- `dice_placement_strategy_content` loads tables, checks IDs, and reports missing media before play starts.
- `dice_placement_strategy_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `dice_placement_strategy_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `dice_placement_strategy_debug` exposes round goals, rivals, and  in overlays without mutating shipped state.

## Data and content model

- `dice_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `dice_table` data should live in `data/` and be validated before Dice Placement Strategy enters active play.
- `placement_slots_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `placement_slots_table` data should live in `data/` and be validated before Dice Placement Strategy enters active play.
- `resources_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `resources_table` data should live in `data/` and be validated before Dice Placement Strategy enters active play.
- Dice Placement Strategy save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Dice Placement Strategy content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate dice placement strategy setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for dice, placement slots, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for drafted dice, worker slots, round pressure, and transparent scoring; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Dice Placement Strategy tests can run without presentation timing.

## Vertical slice acceptance

The slice should include four dice types, ten slots, reroll/modify actions, one enemy or objective track, combo scoring, round rewards, seed logging, and save progression.

## Risks

The risk is randomness feeling arbitrary. Every failure should show why a die could not be placed and what mitigation options exist.
