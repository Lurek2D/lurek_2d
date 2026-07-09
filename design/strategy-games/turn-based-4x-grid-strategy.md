# Turn-Based 4X Grid Strategy

## Design target

A technical game design document for a marketable 2D Turn-Based 4X Grid Strategy built with Lurek2D. The design target is turn authority, exploration, city growth, diplomacy, and map-scale planning, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Turn-Based 4X Grid Strategy should be positioned as a focused strategy games entry about turn authority, exploration, city growth, diplomacy, and map-scale planning. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Hex or square world map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera`, `lurek.minimap` | For Turn-Based 4X Grid Strategy, this area covers hex or square world map from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Movement range and route previews | `lurek.pathfind` | For Turn-Based 4X Grid Strategy, this area covers movement range and route previews from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Cities, units, improvements | `lurek.ecs` | For Turn-Based 4X Grid Strategy, this area covers cities, units, improvements from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| AI players | `lurek.ai` | For Turn-Based 4X Grid Strategy, this area covers ai players from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for inspectable decision scoring and scheduled planners. |
| Research/economy tables | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` | For Turn-Based 4X Grid Strategy, this area covers research/economy tables from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Save/load | `lurek.save` | For Turn-Based 4X Grid Strategy, this area covers save/load from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Interface | `lurek.ui`, `lurek.render`, `lurek.overlay` | For Turn-Based 4X Grid Strategy, this area covers interface from the current design; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Orders, formations, and navigation | `lurek.pathfind`, `lurek.graph`, `lurek.ai` | For Turn-Based 4X Grid Strategy, this area covers querying routes, flows, adjacency, threat maps, and scheduled command decisions; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for inspectable decision scoring and scheduled planners. |
| Territory, fog, and map overlays | `lurek.province`, `lurek.awareness`, `lurek.minimap` | For Turn-Based 4X Grid Strategy, this area covers tracking ownership, visibility, strategic regions, alerts, and overview commands; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Economy, production, and telemetry | `lurek.timer`, `lurek.dataframe`, `lurek.charts` | For Turn-Based 4X Grid Strategy, this area covers driving build queues, resource ticks, balance tables, and debug economy reports; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Scene ownership and mode boundaries | `lurek.scene` | For Turn-Based 4X Grid Strategy, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Turn-Based 4X Grid Strategy, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Turn-Based 4X Grid Strategy, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Turn-Based 4X Grid Strategy, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Turn-Based 4X Grid Strategy, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Turn-Based 4X Grid Strategy, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Turn-Based 4X Grid Strategy, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Turn-Based 4X Grid Strategy, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Turn-Based 4X Grid Strategy, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support turn authority, exploration, city growth, diplomacy, and map-scale planning. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Turn-Based 4X Grid Strategy state should center on turn authority, exploration, city growth, diplomacy, and map-scale planning. Treat factions as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Turn-Based 4X Grid Strategy state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for turn-based 4x grid strategy previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Turn-Based 4X Grid Strategy into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where factions, cities, units, tiles, techs, diplomacy states, and notifications need stable identity across several systems. Single-purpose values can stay in domain tables, but any turn-based 4x grid strategy object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Turn-Based 4X Grid Strategy is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/turn_based_4x_grid_strategy/main.lua` - owns turn-based 4x grid strategy callback handoff and startup wiring.
- `content/games/turn_based_4x_grid_strategy/conf.toml` - owns turn-based 4x grid strategy window, input, asset, and runtime defaults.
- `content/games/turn_based_4x_grid_strategy/data/turn_based_4x_grid_strategy_rules.toml` - owns turn-based 4x grid strategy authored rules for turn authority, exploration, city growth, diplomacy, and map-scale planning.
- `content/games/turn_based_4x_grid_strategy/data/factions.toml` - owns turn-based 4x grid strategy content records for factions.
- `content/games/turn_based_4x_grid_strategy/scripts/scenes/turn_based_4x_grid_strategy_play.lua` - owns turn-based 4x grid strategy scene-local orchestration and pause/result transitions.
- `content/games/turn_based_4x_grid_strategy/scripts/systems/turn_based_4x_grid_strategy_state.lua` - owns turn-based 4x grid strategy authoritative state containers and domain update order.
- `content/games/turn_based_4x_grid_strategy/scripts/systems/turn_based_4x_grid_strategy_validation.lua` - owns turn-based 4x grid strategy data integrity checks before content enters a run.
- `content/games/turn_based_4x_grid_strategy/scripts/ui/turn_based_4x_grid_strategy_hud.lua` - owns turn-based 4x grid strategy HUD, inspector, prompt, and accessibility surfaces.
- `content/games/turn_based_4x_grid_strategy/assets/turn_based_4x_grid_strategy/` - owns turn-based 4x grid strategy media grouped by stable asset IDs.

## Game structure

Turn-Based 4X Grid Strategy should be built as a set of named domain services rather than one large gameplay script.

- `turn_based_4x_grid_strategy_state` owns durable factions, cities, and units records.
- `turn_based_4x_grid_strategy_rules` validates commands, applies turn authority, exploration, city growth, diplomacy, and map-scale planning, and emits deterministic events.
- `turn_based_4x_grid_strategy_content` loads tables, checks IDs, and reports missing media before play starts.
- `turn_based_4x_grid_strategy_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `turn_based_4x_grid_strategy_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `turn_based_4x_grid_strategy_debug` exposes tiles, techs, and diplomacy states in overlays without mutating shipped state.

## Data and content model

- `factions_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `factions_table` data should live in `data/` and be validated before Turn-Based 4X Grid Strategy enters active play.
- `cities_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `cities_table` data should live in `data/` and be validated before Turn-Based 4X Grid Strategy enters active play.
- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before Turn-Based 4X Grid Strategy enters active play.
- Turn-Based 4X Grid Strategy save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Turn-Based 4X Grid Strategy content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate turn-based 4x grid strategy setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for factions, cities, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for turn authority, exploration, city growth, diplomacy, and map-scale planning; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Turn-Based 4X Grid Strategy tests can run without presentation timing.

## Vertical slice acceptance

The first shippable slice should support one generated map, two factions, one city per faction, three unit types, movement range overlay, end-turn resolution, fog update, production queue completion, and a save/load round trip. Avoid adding diplomacy depth before the core turn transaction is reliable.

## Risks

The largest risk is mixing visual tiles with strategic truth. Keep terrain art, gameplay costs, ownership, and visibility as separate layers. The second risk is non-deterministic AI; log every AI decision with inputs and selected policy so turn replays can be debugged.
