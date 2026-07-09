# Traditional Grid Roguelike

## Design target

A technical game design document for a marketable 2D Traditional Grid Roguelike built with Lurek2D. The design target is turn authority, field of view, item identity, and reproducible dungeon runs, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Traditional Grid Roguelike should be positioned as a focused roguelikes entry about turn authority, field of view, item identity, and reproducible dungeon runs. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Dungeon generation | `lurek.procgen`, `lurek.tilemap`, `lurek.tilefield` | For Traditional Grid Roguelike, this area covers dungeon generation from the current design; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Entities and inventory | `lurek.ecs` | For Traditional Grid Roguelike, this area covers entities and inventory from the current design; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Monster AI | `lurek.ai`, `lurek.pathfind`, `lurek.awareness` | For Traditional Grid Roguelike, this area covers monster ai from the current design; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| UI log and panels | `lurek.ui`, `lurek.render`, `lurek.terminal` | For Traditional Grid Roguelike, this area covers ui log and panels from the current design; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for text-grid display, log-heavy screens, or terminal-style roguelike UI. |
| Saves and seeds | `lurek.save`, `lurek.serialize`, `lurek.filesystem` | For Traditional Grid Roguelike, this area covers saves and seeds from the current design; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. |
| Seeds, layouts, and run records | `lurek.procgen`, `lurek.tilefield`, `lurek.save` | For Traditional Grid Roguelike, this area covers generating reproducible rooms, keeping cell facts queryable, and persisting run summaries or unlocks; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| AI, awareness, and turn pressure | `lurek.ai`, `lurek.awareness`, `lurek.timer` | For Traditional Grid Roguelike, this area covers scheduling enemy decisions, field-of-view checks, stealth, cooldowns, or turn phases; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for inspectable decision scoring and scheduled planners. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| Inventory, logs, and readable outcomes | `lurek.ui`, `lurek.terminal`, `lurek.log` | For Traditional Grid Roguelike, this area covers making item identity, combat messages, and debug evidence inspectable; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for text-grid display, log-heavy screens, or terminal-style roguelike UI. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Traditional Grid Roguelike, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Traditional Grid Roguelike, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Traditional Grid Roguelike, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Traditional Grid Roguelike, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Traditional Grid Roguelike, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Traditional Grid Roguelike, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Traditional Grid Roguelike, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Traditional Grid Roguelike, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Traditional Grid Roguelike, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support turn authority, field of view, item identity, and reproducible dungeon runs. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Traditional Grid Roguelike state should center on turn authority, field of view, item identity, and reproducible dungeon runs. Treat tiles as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Traditional Grid Roguelike state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for traditional grid roguelike previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Traditional Grid Roguelike into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where tiles, monsters, items, traps, logs, field-of-view cells, and run records need stable identity across several systems. Single-purpose values can stay in domain tables, but any traditional grid roguelike object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Traditional Grid Roguelike is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/traditional_grid_roguelike/main.lua` - owns traditional grid roguelike callback handoff and startup wiring.
- `content/games/traditional_grid_roguelike/conf.toml` - owns traditional grid roguelike window, input, asset, and runtime defaults.
- `content/games/traditional_grid_roguelike/data/traditional_grid_roguelike_rules.toml` - owns traditional grid roguelike authored rules for turn authority, field of view, item identity, and reproducible dungeon runs.
- `content/games/traditional_grid_roguelike/data/tiles.toml` - owns traditional grid roguelike content records for tiles.
- `content/games/traditional_grid_roguelike/scripts/scenes/traditional_grid_roguelike_play.lua` - owns traditional grid roguelike scene-local orchestration and pause/result transitions.
- `content/games/traditional_grid_roguelike/scripts/systems/traditional_grid_roguelike_state.lua` - owns traditional grid roguelike authoritative state containers and domain update order.
- `content/games/traditional_grid_roguelike/scripts/systems/traditional_grid_roguelike_validation.lua` - owns traditional grid roguelike data integrity checks before content enters a run.
- `content/games/traditional_grid_roguelike/scripts/ui/traditional_grid_roguelike_hud.lua` - owns traditional grid roguelike HUD, inspector, prompt, and accessibility surfaces.
- `content/games/traditional_grid_roguelike/assets/traditional_grid_roguelike/` - owns traditional grid roguelike media grouped by stable asset IDs.

## Game structure

Traditional Grid Roguelike should be built as a set of named domain services rather than one large gameplay script.

- `traditional_grid_roguelike_state` owns durable tiles, monsters, and items records.
- `traditional_grid_roguelike_rules` validates commands, applies turn authority, field of view, item identity, and reproducible dungeon runs, and emits deterministic events.
- `traditional_grid_roguelike_content` loads tables, checks IDs, and reports missing media before play starts.
- `traditional_grid_roguelike_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `traditional_grid_roguelike_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `traditional_grid_roguelike_debug` exposes traps, logs, and field-of-view cells in overlays without mutating shipped state.

## Data and content model

- `tiles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `tiles_table` data should live in `data/` and be validated before Traditional Grid Roguelike enters active play.
- `monsters_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `monsters_table` data should live in `data/` and be validated before Traditional Grid Roguelike enters active play.
- `items_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `items_table` data should live in `data/` and be validated before Traditional Grid Roguelike enters active play.
- Traditional Grid Roguelike save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Traditional Grid Roguelike content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate traditional grid roguelike setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for tiles, monsters, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for turn authority, field of view, item identity, and reproducible dungeon runs; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Traditional Grid Roguelike tests can run without presentation timing.

## Vertical slice acceptance

The slice should include generated dungeon floor, player movement, FOV, three monsters, five items, melee combat, stairs, death screen, message log, and seed-stable restart.

## Risks

The risk is accidental real-time leakage. Keep every rule behind action resolution and verify that the same seed plus action list produces the same outcome.
