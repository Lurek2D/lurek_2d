# Physics Logic Puzzle

## Design target

A technical game design document for a marketable 2D Physics Logic Puzzle built with Lurek2D. The design target is contraption cause-and-effect, sensor checks, reset safety, and deterministic physics, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Physics Logic Puzzle should be positioned as a focused puzzle games entry about contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Physics bodies | `lurek.physics`, `lurek.math` | For Physics Logic Puzzle, this area covers physics bodies from the current design; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Construction UI | `lurek.input`, `lurek.ui`, `lurek.render` | For Physics Logic Puzzle, this area covers construction ui from the current design; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Level data | `lurek.filesystem`, `lurek.serialize`, `lurek.tilemap` | For Physics Logic Puzzle, this area covers level data from the current design; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. |
| Effects and feedback | `lurek.audio`, `lurek.particle`, `lurek.tween` | For Physics Logic Puzzle, this area covers effects and feedback from the current design; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Saves/progress | `lurek.save` | For Physics Logic Puzzle, this area covers saves/progress from the current design; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Board rules and undoable phases | `lurek.patterns`, `lurek.event`, `lurek.serialize` | For Physics Logic Puzzle, this area covers representing moves, cascades, resets, hints, and solved checks as traceable transitions; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Grid facts and spatial constraints | `lurek.tilefield`, `lurek.physics`, `lurek.pathfind` | For Physics Logic Puzzle, this area covers validating blocked cells, push paths, sensor contacts, or reachable targets against authoritative state; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Puzzle clarity and feedback | `lurek.render`, `lurek.animation`, `lurek.audio` | For Physics Logic Puzzle, this area covers highlighting cause and effect after rules resolve rather than using effects as rule state; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Scene ownership and mode boundaries | `lurek.scene` | For Physics Logic Puzzle, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Physics Logic Puzzle, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Physics Logic Puzzle, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Physics Logic Puzzle, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Physics Logic Puzzle, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Physics Logic Puzzle, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Physics Logic Puzzle, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Physics Logic Puzzle, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Physics Logic Puzzle, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Physics Logic Puzzle state should center on contraption cause-and-effect, sensor checks, reset safety, and deterministic physics. Treat bodies as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Physics Logic Puzzle state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for physics logic puzzle previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Physics Logic Puzzle into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where bodies, joints, triggers, goals, reset anchors, timers, and puzzle validators need stable identity across several systems. Single-purpose values can stay in domain tables, but any physics logic puzzle object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Physics Logic Puzzle is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/physics_logic_puzzle/main.lua` - owns physics logic puzzle callback handoff and startup wiring.
- `content/games/physics_logic_puzzle/conf.toml` - owns physics logic puzzle window, input, asset, and runtime defaults.
- `content/games/physics_logic_puzzle/data/physics_logic_puzzle_rules.toml` - owns physics logic puzzle authored rules for contraption cause-and-effect, sensor checks, reset safety, and deterministic physics.
- `content/games/physics_logic_puzzle/data/bodies.toml` - owns physics logic puzzle content records for bodies.
- `content/games/physics_logic_puzzle/scripts/scenes/physics_logic_puzzle_play.lua` - owns physics logic puzzle scene-local orchestration and pause/result transitions.
- `content/games/physics_logic_puzzle/scripts/systems/physics_logic_puzzle_state.lua` - owns physics logic puzzle authoritative state containers and domain update order.
- `content/games/physics_logic_puzzle/scripts/systems/physics_logic_puzzle_validation.lua` - owns physics logic puzzle data integrity checks before content enters a run.
- `content/games/physics_logic_puzzle/scripts/ui/physics_logic_puzzle_hud.lua` - owns physics logic puzzle HUD, inspector, prompt, and accessibility surfaces.
- `content/games/physics_logic_puzzle/assets/physics_logic_puzzle/` - owns physics logic puzzle media grouped by stable asset IDs.

## Game structure

Physics Logic Puzzle should be built as a set of named domain services rather than one large gameplay script.

- `physics_logic_puzzle_state` owns durable bodies, joints, and triggers records.
- `physics_logic_puzzle_rules` validates commands, applies contraption cause-and-effect, sensor checks, reset safety, and deterministic physics, and emits deterministic events.
- `physics_logic_puzzle_content` loads tables, checks IDs, and reports missing media before play starts.
- `physics_logic_puzzle_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `physics_logic_puzzle_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `physics_logic_puzzle_debug` exposes goals, reset anchors, and timers in overlays without mutating shipped state.

## Data and content model

- `bodies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `bodies_table` data should live in `data/` and be validated before Physics Logic Puzzle enters active play.
- `joints_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `joints_table` data should live in `data/` and be validated before Physics Logic Puzzle enters active play.
- `triggers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `triggers_table` data should live in `data/` and be validated before Physics Logic Puzzle enters active play.
- Physics Logic Puzzle save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Physics Logic Puzzle content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate physics logic puzzle setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for bodies, joints, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for contraption cause-and-effect, sensor checks, reset safety, and deterministic physics; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Physics Logic Puzzle tests can run without presentation timing.

## Vertical slice acceptance

The slice should include five levels, three placeable object types, joints or connectors, budget scoring, run/reset buttons, goal validation, best score save, and debug draw.

## Risks

The risk is non-repeatable solutions. Fix simulation timestep, keep object definitions stable, and make every level restart reconstruct physics from logical placement data.
