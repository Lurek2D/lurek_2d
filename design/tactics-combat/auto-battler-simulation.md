# Auto Battler Simulation

## Design target

A technical game design document for a marketable 2D Auto Battler Simulation built with Lurek2D. The design target is draft economy, board placement, autonomous combat, and legible synergies, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Auto Battler Simulation should be positioned as a focused tactics combat entry about draft economy, board placement, autonomous combat, and legible synergies. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Board and placement | `lurek.tilemap`, `lurek.input`, `lurek.ui` | For Auto Battler Simulation, this area covers board and placement from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Unit population | `lurek.ecs` | For Auto Battler Simulation, this area covers unit population from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| AI combat decisions | `lurek.ai` | For Auto Battler Simulation, this area covers ai combat decisions from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for inspectable decision scoring and scheduled planners. |
| Motion and engagement | `lurek.pathfind`, `lurek.tween`, `lurek.animation` | For Auto Battler Simulation, this area covers motion and engagement from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Draft/shop economy | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` | For Auto Battler Simulation, this area covers draft/shop economy from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Combat visualization | `lurek.render`, `lurek.particle`, `lurek.audio`, `lurek.effect` | For Auto Battler Simulation, this area covers combat visualization from the current design; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Turn economy and tactical previews | `lurek.patterns`, `lurek.timer`, `lurek.ui` | For Auto Battler Simulation, this area covers showing action points, initiative, legal actions, hit previews, and reaction windows; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Cover, grid, and line-of-sight | `lurek.tilefield`, `lurek.pathfind`, `lurek.awareness` | For Auto Battler Simulation, this area covers querying reachable cells, cover arcs, visibility, elevation tags, and threat zones; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| Squad state and campaign records | `lurek.ecs`, `lurek.save`, `lurek.dataframe` | For Auto Battler Simulation, this area covers persisting unit identities, abilities, injuries, equipment, and authored mission data; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Scene ownership and mode boundaries | `lurek.scene` | For Auto Battler Simulation, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Auto Battler Simulation, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Auto Battler Simulation, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Auto Battler Simulation, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Auto Battler Simulation, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Auto Battler Simulation, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Auto Battler Simulation, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Auto Battler Simulation, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Auto Battler Simulation, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support draft economy, board placement, autonomous combat, and legible synergies. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Auto Battler Simulation state should center on draft economy, board placement, autonomous combat, and legible synergies. Treat units as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Auto Battler Simulation state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for auto battler simulation previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Auto Battler Simulation into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where units, benches, traits, shops, rounds, targets, and combat logs need stable identity across several systems. Single-purpose values can stay in domain tables, but any auto battler simulation object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Auto Battler Simulation is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/auto_battler_simulation/main.lua` - owns auto battler simulation callback handoff and startup wiring.
- `content/games/auto_battler_simulation/conf.toml` - owns auto battler simulation window, input, asset, and runtime defaults.
- `content/games/auto_battler_simulation/data/auto_battler_simulation_rules.toml` - owns auto battler simulation authored rules for draft economy, board placement, autonomous combat, and legible synergies.
- `content/games/auto_battler_simulation/data/units.toml` - owns auto battler simulation content records for units.
- `content/games/auto_battler_simulation/scripts/scenes/auto_battler_simulation_play.lua` - owns auto battler simulation scene-local orchestration and pause/result transitions.
- `content/games/auto_battler_simulation/scripts/systems/auto_battler_simulation_state.lua` - owns auto battler simulation authoritative state containers and domain update order.
- `content/games/auto_battler_simulation/scripts/systems/auto_battler_simulation_validation.lua` - owns auto battler simulation data integrity checks before content enters a run.
- `content/games/auto_battler_simulation/scripts/ui/auto_battler_simulation_hud.lua` - owns auto battler simulation HUD, inspector, prompt, and accessibility surfaces.
- `content/games/auto_battler_simulation/assets/auto_battler_simulation/` - owns auto battler simulation media grouped by stable asset IDs.

## Game structure

Auto Battler Simulation should be built as a set of named domain services rather than one large gameplay script.

- `auto_battler_simulation_state` owns durable units, benches, and traits records.
- `auto_battler_simulation_rules` validates commands, applies draft economy, board placement, autonomous combat, and legible synergies, and emits deterministic events.
- `auto_battler_simulation_content` loads tables, checks IDs, and reports missing media before play starts.
- `auto_battler_simulation_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `auto_battler_simulation_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `auto_battler_simulation_debug` exposes shops, rounds, and targets in overlays without mutating shipped state.

## Data and content model

- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before Auto Battler Simulation enters active play.
- `benches_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `benches_table` data should live in `data/` and be validated before Auto Battler Simulation enters active play.
- `traits_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `traits_table` data should live in `data/` and be validated before Auto Battler Simulation enters active play.
- Auto Battler Simulation save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Auto Battler Simulation content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate auto battler simulation setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for units, benches, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for draft economy, board placement, autonomous combat, and legible synergies; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Auto Battler Simulation tests can run without presentation timing.

## Vertical slice acceptance

The slice should include eight units, three synergies, a reroll shop, bench management, placement grid, one full combat round, deterministic replay from seed, damage numbers, and round rewards.

## Risks

The main risk is opaque outcomes. Auto battlers require trust. Store combat events, expose damage contribution, show active synergies, and allow a debug replay that reproduces the same fight from the same seed.
