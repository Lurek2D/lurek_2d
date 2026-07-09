# Top-Down Racing

## Design target

A technical game design document for a marketable 2D Top-Down Racing built with Lurek2D. The design target is vehicle feel, track readability, lap timing, AI rivals, and replayable routes, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Top-Down Racing should be positioned as a focused sports racing entry about vehicle feel, track readability, lap timing, AI rivals, and replayable routes. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Track map | `lurek.tilemap`, `lurek.physics`, `lurek.camera` | For Top-Down Racing, this area covers track map from the current design; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Vehicles | `lurek.ecs`, `lurek.math`, `lurek.animation` | For Top-Down Racing, this area covers vehicles from the current design; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| AI drivers | `lurek.pathfind`, `lurek.ai` | For Top-Down Racing, this area covers ai drivers from the current design; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. |
| UI/timing | `lurek.ui`, `lurek.timer`, `lurek.save` | For Top-Down Racing, this area covers ui/timing from the current design; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Feedback | `lurek.audio`, `lurek.particle`, `lurek.effect` | For Top-Down Racing, this area covers feedback from the current design; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Physical feel and timing | `lurek.physics`, `lurek.input`, `lurek.timer` | For Top-Down Racing, this area covers combining controller response, contact checks, lap clocks, trick windows, or possession timing; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| AI rivals and match rules | `lurek.ai`, `lurek.event`, `lurek.save` | For Top-Down Racing, this area covers resolving rival decisions, fouls, checkpoints, score events, ghosts, and season progress; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for inspectable decision scoring and scheduled planners. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Action framing and score feedback | `lurek.camera`, `lurek.tween`, `lurek.audio`, `lurek.ui` | For Top-Down Racing, this area covers keeping fast motion readable and showing score pressure without mutating rule state; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Top-Down Racing, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Top-Down Racing, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Top-Down Racing, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Top-Down Racing, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Top-Down Racing, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Top-Down Racing, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Top-Down Racing, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Top-Down Racing, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Top-Down Racing, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Top-Down Racing state should center on vehicle feel, track readability, lap timing, AI rivals, and replayable routes. Treat vehicles as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Top-Down Racing state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for top-down racing previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Top-Down Racing into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where vehicles, checkpoints, laps, track hazards, rivals, boosts, and ghosts need stable identity across several systems. Single-purpose values can stay in domain tables, but any top-down racing object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Top-Down Racing is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/top_down_racing/main.lua` - owns top-down racing callback handoff and startup wiring.
- `content/games/top_down_racing/conf.toml` - owns top-down racing window, input, asset, and runtime defaults.
- `content/games/top_down_racing/data/top_down_racing_rules.toml` - owns top-down racing authored rules for vehicle feel, track readability, lap timing, AI rivals, and replayable routes.
- `content/games/top_down_racing/data/vehicles.toml` - owns top-down racing content records for vehicles.
- `content/games/top_down_racing/scripts/scenes/top_down_racing_play.lua` - owns top-down racing scene-local orchestration and pause/result transitions.
- `content/games/top_down_racing/scripts/systems/top_down_racing_state.lua` - owns top-down racing authoritative state containers and domain update order.
- `content/games/top_down_racing/scripts/systems/top_down_racing_validation.lua` - owns top-down racing data integrity checks before content enters a run.
- `content/games/top_down_racing/scripts/ui/top_down_racing_hud.lua` - owns top-down racing HUD, inspector, prompt, and accessibility surfaces.
- `content/games/top_down_racing/assets/top_down_racing/` - owns top-down racing media grouped by stable asset IDs.

## Game structure

Top-Down Racing should be built as a set of named domain services rather than one large gameplay script.

- `top_down_racing_state` owns durable vehicles, checkpoints, and laps records.
- `top_down_racing_rules` validates commands, applies vehicle feel, track readability, lap timing, AI rivals, and replayable routes, and emits deterministic events.
- `top_down_racing_content` loads tables, checks IDs, and reports missing media before play starts.
- `top_down_racing_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `top_down_racing_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `top_down_racing_debug` exposes track hazards, rivals, and boosts in overlays without mutating shipped state.

## Data and content model

- `vehicles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `vehicles_table` data should live in `data/` and be validated before Top-Down Racing enters active play.
- `checkpoints_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `checkpoints_table` data should live in `data/` and be validated before Top-Down Racing enters active play.
- `laps_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `laps_table` data should live in `data/` and be validated before Top-Down Racing enters active play.
- Top-Down Racing save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Top-Down Racing content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate top-down racing setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for vehicles, checkpoints, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for vehicle feel, track readability, lap timing, AI rivals, and replayable routes; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Top-Down Racing tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one track, three cars, lap timing, checkpoints, surface slowdown, boost pad, two AI opponents, results screen, best-time save, and gamepad support.

## Risks

The risk is inconsistent handling. Use deterministic input intents and data-driven handling curves, then build debug display for velocity, traction, surface, checkpoint, and lap state.
