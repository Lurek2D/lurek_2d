# City Builder

## Design target

A technical game design document for a marketable 2D City Builder built with Lurek2D. The design target is zoning, service coverage, demand curves, and visible civic feedback, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

City Builder should be positioned as a focused simulation management entry about zoning, service coverage, demand curves, and visible civic feedback. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| City grid | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera`, `lurek.minimap` | For City Builder, this area covers city grid from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Buildings and agents | `lurek.ecs`, `lurek.pathfind` | For City Builder, this area covers buildings and agents from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Service coverage | `lurek.pathfind`, `lurek.charts` | For City Builder, this area covers service coverage from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Economy and demand | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` | For City Builder, this area covers economy and demand from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| UI overlays | `lurek.ui`, `lurek.render`, `lurek.color` | For City Builder, this area covers ui overlays from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for palette, heatmap, faction, and accessibility categories. |
| Save/load | `lurek.save` | For City Builder, this area covers save/load from the current design; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Large simulation state | `lurek.ecs`, `lurek.timer`, `lurek.dataframe` | For City Builder, this area covers owning agents, jobs, resources, needs, and scheduled updates with inspectable records; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Movement, supply, and coverage | `lurek.pathfind`, `lurek.graph`, `lurek.overlay` | For City Builder, this area covers debugging routes, networks, service coverage, storage links, and unreachable tasks; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Reports and forecasting | `lurek.charts`, `lurek.ui`, `lurek.log` | For City Builder, this area covers surfacing trends, alerts, bottlenecks, and reproducible state changes; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For City Builder, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For City Builder, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For City Builder, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For City Builder, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For City Builder, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For City Builder, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For City Builder, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For City Builder, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For City Builder, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support zoning, service coverage, demand curves, and visible civic feedback. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative City Builder state should center on zoning, service coverage, demand curves, and visible civic feedback. Treat buildings as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current City Builder state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for city builder previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split City Builder into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where buildings, roads, zones, citizens, services, budgets, and overlays need stable identity across several systems. Single-purpose values can stay in domain tables, but any city builder object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for City Builder is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/city_builder/main.lua` - owns city builder callback handoff and startup wiring.
- `content/games/city_builder/conf.toml` - owns city builder window, input, asset, and runtime defaults.
- `content/games/city_builder/data/city_builder_rules.toml` - owns city builder authored rules for zoning, service coverage, demand curves, and visible civic feedback.
- `content/games/city_builder/data/buildings.toml` - owns city builder content records for buildings.
- `content/games/city_builder/scripts/scenes/city_builder_play.lua` - owns city builder scene-local orchestration and pause/result transitions.
- `content/games/city_builder/scripts/systems/city_builder_state.lua` - owns city builder authoritative state containers and domain update order.
- `content/games/city_builder/scripts/systems/city_builder_validation.lua` - owns city builder data integrity checks before content enters a run.
- `content/games/city_builder/scripts/ui/city_builder_hud.lua` - owns city builder HUD, inspector, prompt, and accessibility surfaces.
- `content/games/city_builder/assets/city_builder/` - owns city builder media grouped by stable asset IDs.

## Game structure

City Builder should be built as a set of named domain services rather than one large gameplay script.

- `city_builder_state` owns durable buildings, roads, and zones records.
- `city_builder_rules` validates commands, applies zoning, service coverage, demand curves, and visible civic feedback, and emits deterministic events.
- `city_builder_content` loads tables, checks IDs, and reports missing media before play starts.
- `city_builder_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `city_builder_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `city_builder_debug` exposes citizens, services, and budgets in overlays without mutating shipped state.

## Data and content model

- `buildings_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `buildings_table` data should live in `data/` and be validated before City Builder enters active play.
- `roads_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `roads_table` data should live in `data/` and be validated before City Builder enters active play.
- `zones_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `zones_table` data should live in `data/` and be validated before City Builder enters active play.
- City Builder save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- City Builder content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate city builder setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for buildings, roads, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for zoning, service coverage, demand curves, and visible civic feedback; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so City Builder tests can run without presentation timing.

## Vertical slice acceptance

The first slice should support road placement, residential/commercial/industrial zones, one service building, population growth, tax income, demand bars, pollution overlay, pause/speed control, and save/load.

## Risks

The risk is over-simulating citizens too early. Start with aggregate building simulation, then add visual agents as feedback. The player needs truthful overlays more than thousands of independent pawns.
