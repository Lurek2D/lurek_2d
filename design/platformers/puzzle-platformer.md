# Puzzle Platformer

## Design target

A technical game design document for a marketable 2D Puzzle Platformer built with Lurek2D. The design target is movement constraints, room mechanisms, switch logic, and visual explanation, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Puzzle Platformer should be positioned as a focused platformers entry about movement constraints, room mechanisms, switch logic, and visual explanation. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Platforming | `lurek.physics`, `lurek.input`, `lurek.animation` | For Puzzle Platformer, this area covers platforming from the current design; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Puzzle rooms | `lurek.tilemap`, `lurek.scene`, `lurek.event` | For Puzzle Platformer, this area covers puzzle rooms from the current design; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to decide which systems are active and which state may change in each screen. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Interactive objects | `lurek.ecs`, `lurek.patterns`, `lurek.tween` | For Puzzle Platformer, this area covers interactive objects from the current design; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Visual explanation | `lurek.render`, `lurek.light`, `lurek.effect` | For Puzzle Platformer, this area covers visual explanation from the current design; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| State persistence | `lurek.save`, `lurek.serialize` | For Puzzle Platformer, this area covers state persistence from the current design; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Movement controller and collision probes | `lurek.physics`, `lurek.input`, `lurek.math` | For Puzzle Platformer, this area covers buffering actions, querying grounded or wall contact, and keeping feel constants explicit; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Rooms, hazards, and checkpoints | `lurek.tilemap`, `lurek.tilefield`, `lurek.scene` | For Puzzle Platformer, this area covers separating visual layers from lethal cells, respawn anchors, collectibles, and room transitions; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to decide which systems are active and which state may change in each screen. |
| Feel, camera, and assist overlays | `lurek.camera`, `lurek.effect`, `lurek.overlay` | For Puzzle Platformer, this area covers showing safe timing windows, tuning shake or zoom, and inspecting retry-critical collision facts; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Scene ownership and mode boundaries | `lurek.scene` | For Puzzle Platformer, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Puzzle Platformer, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Puzzle Platformer, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Puzzle Platformer, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Puzzle Platformer, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Puzzle Platformer, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Puzzle Platformer, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Puzzle Platformer, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Puzzle Platformer, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support movement constraints, room mechanisms, switch logic, and visual explanation. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Puzzle Platformer state should center on movement constraints, room mechanisms, switch logic, and visual explanation. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Puzzle Platformer state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for puzzle platformer previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Puzzle Platformer into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, platforms, switches, doors, triggers, hazards, and puzzle state need stable identity across several systems. Single-purpose values can stay in domain tables, but any puzzle platformer object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Puzzle Platformer is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/puzzle_platformer/main.lua` - owns puzzle platformer callback handoff and startup wiring.
- `content/games/puzzle_platformer/conf.toml` - owns puzzle platformer window, input, asset, and runtime defaults.
- `content/games/puzzle_platformer/data/puzzle_platformer_rules.toml` - owns puzzle platformer authored rules for movement constraints, room mechanisms, switch logic, and visual explanation.
- `content/games/puzzle_platformer/data/player.toml` - owns puzzle platformer content records for player.
- `content/games/puzzle_platformer/scripts/scenes/puzzle_platformer_play.lua` - owns puzzle platformer scene-local orchestration and pause/result transitions.
- `content/games/puzzle_platformer/scripts/systems/puzzle_platformer_state.lua` - owns puzzle platformer authoritative state containers and domain update order.
- `content/games/puzzle_platformer/scripts/systems/puzzle_platformer_validation.lua` - owns puzzle platformer data integrity checks before content enters a run.
- `content/games/puzzle_platformer/scripts/ui/puzzle_platformer_hud.lua` - owns puzzle platformer HUD, inspector, prompt, and accessibility surfaces.
- `content/games/puzzle_platformer/assets/puzzle_platformer/` - owns puzzle platformer media grouped by stable asset IDs.

## Game structure

Puzzle Platformer should be built as a set of named domain services rather than one large gameplay script.

- `puzzle_platformer_state` owns durable player, platforms, and switches records.
- `puzzle_platformer_rules` validates commands, applies movement constraints, room mechanisms, switch logic, and visual explanation, and emits deterministic events.
- `puzzle_platformer_content` loads tables, checks IDs, and reports missing media before play starts.
- `puzzle_platformer_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `puzzle_platformer_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `puzzle_platformer_debug` exposes doors, triggers, and hazards in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Puzzle Platformer enters active play.
- `platforms_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `platforms_table` data should live in `data/` and be validated before Puzzle Platformer enters active play.
- `switches_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `switches_table` data should live in `data/` and be validated before Puzzle Platformer enters active play.
- Puzzle Platformer save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Puzzle Platformer content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate puzzle platformer setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, platforms, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for movement constraints, room mechanisms, switch logic, and visual explanation; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Puzzle Platformer tests can run without presentation timing.

## Vertical slice acceptance

The slice should include three puzzle rooms, one reusable switch-door circuit, one movable prop, one timing mechanic, reset button, solved-state persistence, and hint UI.

## Risks

Puzzle games break when state is implicit. Every interactable must declare its inputs, outputs, reset policy, and save policy. Debug mode should list active puzzle channels and listeners.
