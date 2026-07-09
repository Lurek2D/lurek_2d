# Sokoban Spatial Puzzle

## Design target

A technical game design document for a marketable 2D Sokoban Spatial Puzzle built with Lurek2D. The design target is grid pushes, undo, level validation, and rule clarity, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Sokoban Spatial Puzzle should be positioned as a focused puzzle games entry about grid pushes, undo, level validation, and rule clarity. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Grid levels | `lurek.tilemap`, `lurek.tilefield`, `lurek.filesystem` | For Sokoban Spatial Puzzle, this area covers grid levels from the current design; it should support grid pushes, undo, level validation, and rule clarity. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. |
| Objects and rules | `lurek.ecs`, `lurek.patterns` | For Sokoban Spatial Puzzle, this area covers objects and rules from the current design; it should support grid pushes, undo, level validation, and rule clarity. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for state machines, rule phases, command patterns, and undoable transition models. |
| Input/undo | `lurek.input`, `lurek.event`, `lurek.serialize` | For Sokoban Spatial Puzzle, this area covers input/undo from the current design; it should support grid pushes, undo, level validation, and rule clarity. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Presentation | `lurek.render`, `lurek.animation`, `lurek.tween`, `lurek.audio` | For Sokoban Spatial Puzzle, this area covers presentation from the current design; it should support grid pushes, undo, level validation, and rule clarity. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Progress | `lurek.save` | For Sokoban Spatial Puzzle, this area covers progress from the current design; it should support grid pushes, undo, level validation, and rule clarity. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Board rules and undoable phases | `lurek.patterns`, `lurek.event`, `lurek.serialize` | For Sokoban Spatial Puzzle, this area covers representing moves, cascades, resets, hints, and solved checks as traceable transitions; it should support grid pushes, undo, level validation, and rule clarity. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Grid facts and spatial constraints | `lurek.tilefield`, `lurek.physics`, `lurek.pathfind` | For Sokoban Spatial Puzzle, this area covers validating blocked cells, push paths, sensor contacts, or reachable targets against authoritative state; it should support grid pushes, undo, level validation, and rule clarity. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Puzzle clarity and feedback | `lurek.render`, `lurek.animation`, `lurek.audio` | For Sokoban Spatial Puzzle, this area covers highlighting cause and effect after rules resolve rather than using effects as rule state; it should support grid pushes, undo, level validation, and rule clarity. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Scene ownership and mode boundaries | `lurek.scene` | For Sokoban Spatial Puzzle, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support grid pushes, undo, level validation, and rule clarity. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Sokoban Spatial Puzzle, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support grid pushes, undo, level validation, and rule clarity. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Sokoban Spatial Puzzle, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support grid pushes, undo, level validation, and rule clarity. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Sokoban Spatial Puzzle, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support grid pushes, undo, level validation, and rule clarity. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Sokoban Spatial Puzzle, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support grid pushes, undo, level validation, and rule clarity. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Sokoban Spatial Puzzle, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support grid pushes, undo, level validation, and rule clarity. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Sokoban Spatial Puzzle, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support grid pushes, undo, level validation, and rule clarity. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Sokoban Spatial Puzzle, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support grid pushes, undo, level validation, and rule clarity. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Sokoban Spatial Puzzle, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support grid pushes, undo, level validation, and rule clarity. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Sokoban Spatial Puzzle state should center on grid pushes, undo, level validation, and rule clarity. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Sokoban Spatial Puzzle state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for sokoban spatial puzzle previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Sokoban Spatial Puzzle into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, crates, targets, walls, move log, hints, and solved-state markers need stable identity across several systems. Single-purpose values can stay in domain tables, but any sokoban spatial puzzle object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Sokoban Spatial Puzzle is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/sokoban_spatial_puzzle/main.lua` - owns sokoban spatial puzzle callback handoff and startup wiring.
- `content/games/sokoban_spatial_puzzle/conf.toml` - owns sokoban spatial puzzle window, input, asset, and runtime defaults.
- `content/games/sokoban_spatial_puzzle/data/sokoban_spatial_puzzle_rules.toml` - owns sokoban spatial puzzle authored rules for grid pushes, undo, level validation, and rule clarity.
- `content/games/sokoban_spatial_puzzle/data/player.toml` - owns sokoban spatial puzzle content records for player.
- `content/games/sokoban_spatial_puzzle/scripts/scenes/sokoban_spatial_puzzle_play.lua` - owns sokoban spatial puzzle scene-local orchestration and pause/result transitions.
- `content/games/sokoban_spatial_puzzle/scripts/systems/sokoban_spatial_puzzle_state.lua` - owns sokoban spatial puzzle authoritative state containers and domain update order.
- `content/games/sokoban_spatial_puzzle/scripts/systems/sokoban_spatial_puzzle_validation.lua` - owns sokoban spatial puzzle data integrity checks before content enters a run.
- `content/games/sokoban_spatial_puzzle/scripts/ui/sokoban_spatial_puzzle_hud.lua` - owns sokoban spatial puzzle HUD, inspector, prompt, and accessibility surfaces.
- `content/games/sokoban_spatial_puzzle/assets/sokoban_spatial_puzzle/` - owns sokoban spatial puzzle media grouped by stable asset IDs.

## Game structure

Sokoban Spatial Puzzle should be built as a set of named domain services rather than one large gameplay script.

- `sokoban_spatial_puzzle_state` owns durable player, crates, and targets records.
- `sokoban_spatial_puzzle_rules` validates commands, applies grid pushes, undo, level validation, and rule clarity, and emits deterministic events.
- `sokoban_spatial_puzzle_content` loads tables, checks IDs, and reports missing media before play starts.
- `sokoban_spatial_puzzle_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `sokoban_spatial_puzzle_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `sokoban_spatial_puzzle_debug` exposes walls, move log, and hints in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Sokoban Spatial Puzzle enters active play.
- `crates_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `crates_table` data should live in `data/` and be validated before Sokoban Spatial Puzzle enters active play.
- `targets_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `targets_table` data should live in `data/` and be validated before Sokoban Spatial Puzzle enters active play.
- Sokoban Spatial Puzzle save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Sokoban Spatial Puzzle content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate sokoban spatial puzzle setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, crates, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for grid pushes, undo, level validation, and rule clarity; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Sokoban Spatial Puzzle tests can run without presentation timing.

## Vertical slice acceptance

The slice should include ten levels, push blocks, goals, walls, undo, restart, move counter, level select, solved-state save, and one special rule.

## Risks

The risk is desync between animation and logic. Commit logical moves atomically and let presentation follow. Never let tween completion decide puzzle truth.
