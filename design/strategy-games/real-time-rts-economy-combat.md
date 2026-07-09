# Real-Time RTS Economy Combat

## Design target

A technical game design document for a marketable 2D Real-Time RTS Economy Combat built with Lurek2D. The design target is worker economy, scouting, unit production, army control, and skirmish AI, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Real-Time RTS Economy Combat should be positioned as a focused strategy games entry about worker economy, scouting, unit production, army control, and skirmish AI. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Large 2D map with layers | `lurek.tilemap`, `lurek.camera`, `lurek.minimap` | For Real-Time RTS Economy Combat, this area covers large 2d map with layers from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Unit population | `lurek.ecs` | For Real-Time RTS Economy Combat, this area covers unit population from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Movement and formation intent | `lurek.pathfind` | For Real-Time RTS Economy Combat, this area covers movement and formation intent from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Combat simulation | `lurek.timer`, `lurek.math`, `lurek.physics` | For Real-Time RTS Economy Combat, this area covers combat simulation from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| AI skirmish opponent | `lurek.ai` | For Real-Time RTS Economy Combat, this area covers ai skirmish opponent from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for inspectable decision scoring and scheduled planners. |
| Selection UI and command panels | `lurek.ui`, `lurek.input`, `lurek.render` | For Real-Time RTS Economy Combat, this area covers selection ui and command panels from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Feedback | `lurek.audio`, `lurek.particle`, `lurek.effect` | For Real-Time RTS Economy Combat, this area covers feedback from the current design; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Orders, formations, and navigation | `lurek.pathfind`, `lurek.graph`, `lurek.ai` | For Real-Time RTS Economy Combat, this area covers querying routes, flows, adjacency, threat maps, and scheduled command decisions; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for inspectable decision scoring and scheduled planners. |
| Territory, fog, and map overlays | `lurek.province`, `lurek.awareness`, `lurek.minimap` | For Real-Time RTS Economy Combat, this area covers tracking ownership, visibility, strategic regions, alerts, and overview commands; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Economy, production, and telemetry | `lurek.timer`, `lurek.dataframe`, `lurek.charts` | For Real-Time RTS Economy Combat, this area covers driving build queues, resource ticks, balance tables, and debug economy reports; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Scene ownership and mode boundaries | `lurek.scene` | For Real-Time RTS Economy Combat, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Real-Time RTS Economy Combat, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Real-Time RTS Economy Combat, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Real-Time RTS Economy Combat, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Real-Time RTS Economy Combat, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Real-Time RTS Economy Combat, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Real-Time RTS Economy Combat, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Real-Time RTS Economy Combat, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Real-Time RTS Economy Combat, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support worker economy, scouting, unit production, army control, and skirmish AI. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Real-Time RTS Economy Combat state should center on worker economy, scouting, unit production, army control, and skirmish AI. Treat workers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Real-Time RTS Economy Combat state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for real-time rts economy combat previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Real-Time RTS Economy Combat into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where workers, bases, units, resources, orders, squads, and minimap alerts need stable identity across several systems. Single-purpose values can stay in domain tables, but any real-time rts economy combat object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Real-Time RTS Economy Combat is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/real_time_rts_economy_combat/main.lua` - owns real-time rts economy combat callback handoff and startup wiring.
- `content/games/real_time_rts_economy_combat/conf.toml` - owns real-time rts economy combat window, input, asset, and runtime defaults.
- `content/games/real_time_rts_economy_combat/data/real_time_rts_economy_combat_rules.toml` - owns real-time rts economy combat authored rules for worker economy, scouting, unit production, army control, and skirmish AI.
- `content/games/real_time_rts_economy_combat/data/workers.toml` - owns real-time rts economy combat content records for workers.
- `content/games/real_time_rts_economy_combat/scripts/scenes/real_time_rts_economy_combat_play.lua` - owns real-time rts economy combat scene-local orchestration and pause/result transitions.
- `content/games/real_time_rts_economy_combat/scripts/systems/real_time_rts_economy_combat_state.lua` - owns real-time rts economy combat authoritative state containers and domain update order.
- `content/games/real_time_rts_economy_combat/scripts/systems/real_time_rts_economy_combat_validation.lua` - owns real-time rts economy combat data integrity checks before content enters a run.
- `content/games/real_time_rts_economy_combat/scripts/ui/real_time_rts_economy_combat_hud.lua` - owns real-time rts economy combat HUD, inspector, prompt, and accessibility surfaces.
- `content/games/real_time_rts_economy_combat/assets/real_time_rts_economy_combat/` - owns real-time rts economy combat media grouped by stable asset IDs.

## Game structure

Real-Time RTS Economy Combat should be built as a set of named domain services rather than one large gameplay script.

- `real_time_rts_economy_combat_state` owns durable workers, bases, and units records.
- `real_time_rts_economy_combat_rules` validates commands, applies worker economy, scouting, unit production, army control, and skirmish AI, and emits deterministic events.
- `real_time_rts_economy_combat_content` loads tables, checks IDs, and reports missing media before play starts.
- `real_time_rts_economy_combat_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `real_time_rts_economy_combat_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `real_time_rts_economy_combat_debug` exposes resources, orders, and squads in overlays without mutating shipped state.

## Data and content model

- `workers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `workers_table` data should live in `data/` and be validated before Real-Time RTS Economy Combat enters active play.
- `bases_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `bases_table` data should live in `data/` and be validated before Real-Time RTS Economy Combat enters active play.
- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before Real-Time RTS Economy Combat enters active play.
- Real-Time RTS Economy Combat save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Real-Time RTS Economy Combat content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate real-time rts economy combat setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for workers, bases, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for worker economy, scouting, unit production, army control, and skirmish AI; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Real-Time RTS Economy Combat tests can run without presentation timing.

## Vertical slice acceptance

Build one map with harvestable resources, one headquarters, one worker, one barracks, one combat unit, drag selection, right-click movement, attack order, fog toggle, minimap markers, basic AI wave, and restartable save state.

## Risks

The main risk is pathfinding cost. Plan path budgets early and design maps with chokepoints that are readable but not solver-hostile. The second risk is command ambiguity; solve it through explicit command objects and consistent UI feedback, not hidden input branches.
