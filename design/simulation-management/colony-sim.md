# Colony Sim

## Design target

A technical game design document for a marketable 2D Colony Sim built with Lurek2D. The design target is pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Colony Sim should be positioned as a focused simulation management entry about pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Colony map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera` | For Colony Sim, this area covers colony map from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Pawns and objects | `lurek.ecs` | For Colony Sim, this area covers pawns and objects from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Job assignment | `lurek.ai` | For Colony Sim, this area covers job assignment from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for inspectable decision scoring and scheduled planners. |
| Navigation | `lurek.pathfind` | For Colony Sim, this area covers navigation from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Events and alerts | `lurek.event`, `lurek.ui`, `lurek.audio` | For Colony Sim, this area covers events and alerts from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Simulation data | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` | For Colony Sim, this area covers simulation data from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Persistence | `lurek.save` | For Colony Sim, this area covers persistence from the current design; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Large simulation state | `lurek.ecs`, `lurek.timer`, `lurek.dataframe` | For Colony Sim, this area covers owning agents, jobs, resources, needs, and scheduled updates with inspectable records; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Movement, supply, and coverage | `lurek.pathfind`, `lurek.graph`, `lurek.overlay` | For Colony Sim, this area covers debugging routes, networks, service coverage, storage links, and unreachable tasks; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Reports and forecasting | `lurek.charts`, `lurek.ui`, `lurek.log` | For Colony Sim, this area covers surfacing trends, alerts, bottlenecks, and reproducible state changes; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Colony Sim, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Colony Sim, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Colony Sim, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Colony Sim, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Colony Sim, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Colony Sim, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Colony Sim, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Colony Sim, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Colony Sim, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Colony Sim state should center on pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability. Treat pawns as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Colony Sim state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for colony sim previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Colony Sim into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where pawns, jobs, stockpiles, rooms, alerts, needs, events, and schedules need stable identity across several systems. Single-purpose values can stay in domain tables, but any colony sim object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Colony Sim is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/colony_sim/main.lua` - owns colony sim callback handoff and startup wiring.
- `content/games/colony_sim/conf.toml` - owns colony sim window, input, asset, and runtime defaults.
- `content/games/colony_sim/data/colony_sim_rules.toml` - owns colony sim authored rules for pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability.
- `content/games/colony_sim/data/pawns.toml` - owns colony sim content records for pawns.
- `content/games/colony_sim/scripts/scenes/colony_sim_play.lua` - owns colony sim scene-local orchestration and pause/result transitions.
- `content/games/colony_sim/scripts/systems/colony_sim_state.lua` - owns colony sim authoritative state containers and domain update order.
- `content/games/colony_sim/scripts/systems/colony_sim_validation.lua` - owns colony sim data integrity checks before content enters a run.
- `content/games/colony_sim/scripts/ui/colony_sim_hud.lua` - owns colony sim HUD, inspector, prompt, and accessibility surfaces.
- `content/games/colony_sim/assets/colony_sim/` - owns colony sim media grouped by stable asset IDs.

## Game structure

Colony Sim should be built as a set of named domain services rather than one large gameplay script.

- `colony_sim_state` owns durable pawns, jobs, and stockpiles records.
- `colony_sim_rules` validates commands, applies pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability, and emits deterministic events.
- `colony_sim_content` loads tables, checks IDs, and reports missing media before play starts.
- `colony_sim_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `colony_sim_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `colony_sim_debug` exposes rooms, alerts, and needs in overlays without mutating shipped state.

## Data and content model

- `pawns_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `pawns_table` data should live in `data/` and be validated before Colony Sim enters active play.
- `jobs_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `jobs_table` data should live in `data/` and be validated before Colony Sim enters active play.
- `stockpiles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `stockpiles_table` data should live in `data/` and be validated before Colony Sim enters active play.
- Colony Sim save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Colony Sim content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate colony sim setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for pawns, jobs, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for pawn jobs, survival needs, stockpiles, alerts, and long-running simulation stability; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Colony Sim tests can run without presentation timing.

## Vertical slice acceptance

One map should support five pawns, sleep/eat/work needs, construction blueprints, hauling, stockpiles, one hostile incident, job priority UI, pause/speed control, and save/load.

## Risks

The largest risk is simulation churn. Put hard budgets on scans, cache derived regions, and avoid per-pawn global searches. Emergence should come from small explicit systems, not unbounded scripts.
