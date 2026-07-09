# Grand Strategy Province Map

## Design target

A technical game design document for a marketable 2D Grand Strategy Province Map built with Lurek2D. The design target is province ownership, diplomacy pressure, map overlays, and long-horizon decisions, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Grand Strategy Province Map should be positioned as a focused strategy games entry about province ownership, diplomacy pressure, map overlays, and long-horizon decisions. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Province topology | `lurek.province`, `lurek.pathfind` | For Grand Strategy Province Map, this area covers province topology from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Map rendering | `lurek.render`, `lurek.svg`, `lurek.image`, `lurek.minimap` | For Grand Strategy Province Map, this area covers map rendering from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for vector-derived map or UI presentation input. Use it for portraits, CGs, backgrounds, loaded images, and image processing inputs. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Data-heavy rules | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` | For Grand Strategy Province Map, this area covers data-heavy rules from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Countries, armies, markets | `lurek.ecs` | For Grand Strategy Province Map, this area covers countries, armies, markets from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Events and decisions | `lurek.event`, `lurek.dialog`, `lurek.ui` | For Grand Strategy Province Map, this area covers events and decisions from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| AI rulers | `lurek.ai` | For Grand Strategy Province Map, this area covers ai rulers from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for inspectable decision scoring and scheduled planners. |
| Persistence | `lurek.save` | For Grand Strategy Province Map, this area covers persistence from the current design; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Orders, formations, and navigation | `lurek.pathfind`, `lurek.graph`, `lurek.ai` | For Grand Strategy Province Map, this area covers querying routes, flows, adjacency, threat maps, and scheduled command decisions; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for inspectable decision scoring and scheduled planners. |
| Territory, fog, and map overlays | `lurek.province`, `lurek.awareness`, `lurek.minimap` | For Grand Strategy Province Map, this area covers tracking ownership, visibility, strategic regions, alerts, and overview commands; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Economy, production, and telemetry | `lurek.timer`, `lurek.dataframe`, `lurek.charts` | For Grand Strategy Province Map, this area covers driving build queues, resource ticks, balance tables, and debug economy reports; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Scene ownership and mode boundaries | `lurek.scene` | For Grand Strategy Province Map, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Grand Strategy Province Map, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Grand Strategy Province Map, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Grand Strategy Province Map, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Grand Strategy Province Map, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Grand Strategy Province Map, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Grand Strategy Province Map, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Grand Strategy Province Map, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Grand Strategy Province Map, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Grand Strategy Province Map state should center on province ownership, diplomacy pressure, map overlays, and long-horizon decisions. Treat provinces as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Grand Strategy Province Map state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for grand strategy province map previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Grand Strategy Province Map into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where provinces, factions, armies, treaties, events, resources, and map overlays need stable identity across several systems. Single-purpose values can stay in domain tables, but any grand strategy province map object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Grand Strategy Province Map is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/grand_strategy_province_map/main.lua` - owns grand strategy province map callback handoff and startup wiring.
- `content/games/grand_strategy_province_map/conf.toml` - owns grand strategy province map window, input, asset, and runtime defaults.
- `content/games/grand_strategy_province_map/data/grand_strategy_province_map_rules.toml` - owns grand strategy province map authored rules for province ownership, diplomacy pressure, map overlays, and long-horizon decisions.
- `content/games/grand_strategy_province_map/data/provinces.toml` - owns grand strategy province map content records for provinces.
- `content/games/grand_strategy_province_map/scripts/scenes/grand_strategy_province_map_play.lua` - owns grand strategy province map scene-local orchestration and pause/result transitions.
- `content/games/grand_strategy_province_map/scripts/systems/grand_strategy_province_map_state.lua` - owns grand strategy province map authoritative state containers and domain update order.
- `content/games/grand_strategy_province_map/scripts/systems/grand_strategy_province_map_validation.lua` - owns grand strategy province map data integrity checks before content enters a run.
- `content/games/grand_strategy_province_map/scripts/ui/grand_strategy_province_map_hud.lua` - owns grand strategy province map HUD, inspector, prompt, and accessibility surfaces.
- `content/games/grand_strategy_province_map/assets/grand_strategy_province_map/` - owns grand strategy province map media grouped by stable asset IDs.

## Game structure

Grand Strategy Province Map should be built as a set of named domain services rather than one large gameplay script.

- `grand_strategy_province_map_state` owns durable provinces, factions, and armies records.
- `grand_strategy_province_map_rules` validates commands, applies province ownership, diplomacy pressure, map overlays, and long-horizon decisions, and emits deterministic events.
- `grand_strategy_province_map_content` loads tables, checks IDs, and reports missing media before play starts.
- `grand_strategy_province_map_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `grand_strategy_province_map_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `grand_strategy_province_map_debug` exposes treaties, events, and resources in overlays without mutating shipped state.

## Data and content model

- `provinces_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `provinces_table` data should live in `data/` and be validated before Grand Strategy Province Map enters active play.
- `factions_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `factions_table` data should live in `data/` and be validated before Grand Strategy Province Map enters active play.
- `armies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `armies_table` data should live in `data/` and be validated before Grand Strategy Province Map enters active play.
- Grand Strategy Province Map save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Grand Strategy Province Map content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate grand strategy province map setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for provinces, factions, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for province ownership, diplomacy pressure, map overlays, and long-horizon decisions; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Grand Strategy Province Map tests can run without presentation timing.

## Vertical slice acceptance

The first slice should include a 20-province region, three countries, pause/speed controls, province selection, political and terrain map modes, one diplomatic action, army movement through adjacency, one event chain, and save/load.

## Risks

The major risk is hidden rule coupling. Grand strategy systems become unmaintainable when economy, war, diplomacy, and UI mutate each other directly. Use command/result records between domains and make every monthly tick auditable.
