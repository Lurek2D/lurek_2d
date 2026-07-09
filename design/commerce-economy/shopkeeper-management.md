# Shopkeeper Management

## Design target

A technical game design document for a marketable 2D Shopkeeper Management built with Lurek2D. The design target is customer routing, shelf economics, daily reports, and upgrade pacing, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Shopkeeper Management should be positioned as a focused commerce economy entry about customer routing, shelf economics, daily reports, and upgrade pacing. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Shop floor and fixtures | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera` | For Shopkeeper Management, this area covers shop floor and fixtures from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Customers, shelves, stock, workers | `lurek.ecs` | For Shopkeeper Management, this area covers customers, shelves, stock, workers from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Customer behavior and queues | `lurek.ai`, `lurek.pathfind` | For Shopkeeper Management, this area covers customer behavior and queues from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Economy tables | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` | For Shopkeeper Management, this area covers economy tables from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Shop UI and reports | `lurek.ui`, `lurek.charts`, `lurek.overlay` | For Shopkeeper Management, this area covers shop ui and reports from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Feedback and ambience | `lurek.audio`, `lurek.animation`, `lurek.particle`, `lurek.tween` | For Shopkeeper Management, this area covers feedback and ambience from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Persistence | `lurek.save` | For Shopkeeper Management, this area covers persistence from the current design; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Economy simulation | `lurek.ecs`, `lurek.timer`, `lurek.dataframe` | For Shopkeeper Management, this area covers scheduling customers, jobs, stock, prices, and daily reports from tunable records; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Routing, queues, and service coverage | `lurek.pathfind`, `lurek.graph`, `lurek.overlay` | For Shopkeeper Management, this area covers inspecting bottlenecks, reachable work areas, queue lengths, and route costs; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Charts and operational UI | `lurek.charts`, `lurek.ui`, `lurek.log` | For Shopkeeper Management, this area covers showing demand, profit, throughput, alerts, and audit trails without hiding simulation causes; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Shopkeeper Management, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Shopkeeper Management, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Shopkeeper Management, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Shopkeeper Management, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Shopkeeper Management, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Shopkeeper Management, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Shopkeeper Management, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Shopkeeper Management, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Shopkeeper Management, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support customer routing, shelf economics, daily reports, and upgrade pacing. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Shopkeeper Management state should center on customer routing, shelf economics, daily reports, and upgrade pacing. Treat customers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Shopkeeper Management state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for shopkeeper management previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Shopkeeper Management into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where customers, shelves, stock lots, workers, checkout queues, suppliers, and day summaries need stable identity across several systems. Single-purpose values can stay in domain tables, but any shopkeeper management object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Shopkeeper Management is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/shopkeeper_management/main.lua` - owns shopkeeper management callback handoff and startup wiring.
- `content/games/shopkeeper_management/conf.toml` - owns shopkeeper management window, input, asset, and runtime defaults.
- `content/games/shopkeeper_management/data/shopkeeper_management_rules.toml` - owns shopkeeper management authored rules for customer routing, shelf economics, daily reports, and upgrade pacing.
- `content/games/shopkeeper_management/data/customers.toml` - owns shopkeeper management content records for customers.
- `content/games/shopkeeper_management/scripts/scenes/shopkeeper_management_play.lua` - owns shopkeeper management scene-local orchestration and pause/result transitions.
- `content/games/shopkeeper_management/scripts/systems/shopkeeper_management_state.lua` - owns shopkeeper management authoritative state containers and domain update order.
- `content/games/shopkeeper_management/scripts/systems/shopkeeper_management_validation.lua` - owns shopkeeper management data integrity checks before content enters a run.
- `content/games/shopkeeper_management/scripts/ui/shopkeeper_management_hud.lua` - owns shopkeeper management HUD, inspector, prompt, and accessibility surfaces.
- `content/games/shopkeeper_management/assets/shopkeeper_management/` - owns shopkeeper management media grouped by stable asset IDs.

## Game structure

Shopkeeper Management should be built as a set of named domain services rather than one large gameplay script.

- `shopkeeper_management_state` owns durable customers, shelves, and stock lots records.
- `shopkeeper_management_rules` validates commands, applies customer routing, shelf economics, daily reports, and upgrade pacing, and emits deterministic events.
- `shopkeeper_management_content` loads tables, checks IDs, and reports missing media before play starts.
- `shopkeeper_management_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `shopkeeper_management_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `shopkeeper_management_debug` exposes workers, checkout queues, and suppliers in overlays without mutating shipped state.

## Data and content model

- `customers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `customers_table` data should live in `data/` and be validated before Shopkeeper Management enters active play.
- `shelves_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `shelves_table` data should live in `data/` and be validated before Shopkeeper Management enters active play.
- `stock_lots_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `stock_lots_table` data should live in `data/` and be validated before Shopkeeper Management enters active play.
- Shopkeeper Management save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Shopkeeper Management content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate shopkeeper management setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for customers, shelves, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for customer routing, shelf economics, daily reports, and upgrade pacing; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Shopkeeper Management tests can run without presentation timing.

## Vertical slice acceptance

The first slice should include one shop room, ten products, three customer archetypes, shelves, checkout, price editing, customer pathing, stockouts, day timer, revenue/profit report, one upgrade, one event day, and save/load.

## Risks

The major risk is invisible economy behavior. If players cannot explain why customers buy, leave, or complain, the design will feel arbitrary. Keep every economic result attributable to product fit, price, stock, queue time, reputation, or event modifiers.
