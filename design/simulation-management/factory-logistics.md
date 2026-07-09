# Factory Logistics

## Design target

A technical game design document for a marketable 2D Factory Logistics built with Lurek2D. The design target is belt flow, machine ratios, routing bottlenecks, and production telemetry, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Factory Logistics should be positioned as a focused simulation management entry about belt flow, machine ratios, routing bottlenecks, and production telemetry. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Grid placement | `lurek.tilemap`, `lurek.tilefield`, `lurek.input` | For Factory Logistics, this area covers grid placement from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. |
| Machines and items | `lurek.ecs` | For Factory Logistics, this area covers machines and items from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Transport networks | `lurek.pathfind`, `lurek.graph`, `lurek.math` | For Factory Logistics, this area covers transport networks from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Data tables | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` | For Factory Logistics, this area covers data tables from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Visualization | `lurek.render`, `lurek.particle`, `lurek.charts`, `lurek.ui` | For Factory Logistics, this area covers visualization from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Persistence | `lurek.save` | For Factory Logistics, this area covers persistence from the current design; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Large simulation state | `lurek.ecs`, `lurek.timer`, `lurek.dataframe` | For Factory Logistics, this area covers owning agents, jobs, resources, needs, and scheduled updates with inspectable records; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Movement, supply, and coverage | `lurek.pathfind`, `lurek.graph`, `lurek.overlay` | For Factory Logistics, this area covers debugging routes, networks, service coverage, storage links, and unreachable tasks; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Reports and forecasting | `lurek.charts`, `lurek.ui`, `lurek.log` | For Factory Logistics, this area covers surfacing trends, alerts, bottlenecks, and reproducible state changes; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Factory Logistics, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Factory Logistics, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Factory Logistics, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Factory Logistics, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Factory Logistics, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Factory Logistics, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Factory Logistics, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Factory Logistics, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Factory Logistics, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support belt flow, machine ratios, routing bottlenecks, and production telemetry. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Factory Logistics state should center on belt flow, machine ratios, routing bottlenecks, and production telemetry. Treat machines as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Factory Logistics state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for factory logistics previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Factory Logistics into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where machines, belts, items, recipes, routes, buffers, and production counters need stable identity across several systems. Single-purpose values can stay in domain tables, but any factory logistics object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Factory Logistics is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/factory_logistics/main.lua` - owns factory logistics callback handoff and startup wiring.
- `content/games/factory_logistics/conf.toml` - owns factory logistics window, input, asset, and runtime defaults.
- `content/games/factory_logistics/data/factory_logistics_rules.toml` - owns factory logistics authored rules for belt flow, machine ratios, routing bottlenecks, and production telemetry.
- `content/games/factory_logistics/data/machines.toml` - owns factory logistics content records for machines.
- `content/games/factory_logistics/scripts/scenes/factory_logistics_play.lua` - owns factory logistics scene-local orchestration and pause/result transitions.
- `content/games/factory_logistics/scripts/systems/factory_logistics_state.lua` - owns factory logistics authoritative state containers and domain update order.
- `content/games/factory_logistics/scripts/systems/factory_logistics_validation.lua` - owns factory logistics data integrity checks before content enters a run.
- `content/games/factory_logistics/scripts/ui/factory_logistics_hud.lua` - owns factory logistics HUD, inspector, prompt, and accessibility surfaces.
- `content/games/factory_logistics/assets/factory_logistics/` - owns factory logistics media grouped by stable asset IDs.

## Game structure

Factory Logistics should be built as a set of named domain services rather than one large gameplay script.

- `factory_logistics_state` owns durable machines, belts, and items records.
- `factory_logistics_rules` validates commands, applies belt flow, machine ratios, routing bottlenecks, and production telemetry, and emits deterministic events.
- `factory_logistics_content` loads tables, checks IDs, and reports missing media before play starts.
- `factory_logistics_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `factory_logistics_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `factory_logistics_debug` exposes recipes, routes, and buffers in overlays without mutating shipped state.

## Data and content model

- `machines_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `machines_table` data should live in `data/` and be validated before Factory Logistics enters active play.
- `belts_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `belts_table` data should live in `data/` and be validated before Factory Logistics enters active play.
- `items_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `items_table` data should live in `data/` and be validated before Factory Logistics enters active play.
- Factory Logistics save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Factory Logistics content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate factory logistics setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for machines, belts, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for belt flow, machine ratios, routing bottlenecks, and production telemetry; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Factory Logistics tests can run without presentation timing.

## Vertical slice acceptance

Build one resource source, one belt type, three machines, four items, one research unlock, live throughput chart, blocked-output warning, blueprint placement, delete tool, and save/load.

## Risks

The main risk is representing every moving item as an expensive actor. Keep logical flow compact and reserve ECS entities for machines, carriers, and visible exceptions. Render many item sprites from transport buffers rather than simulating them as independent agents.
