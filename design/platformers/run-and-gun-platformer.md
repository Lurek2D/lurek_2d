# Run-and-Gun Platformer

## Design target

A technical game design document for a marketable 2D Run-and-Gun Platformer built with Lurek2D. The design target is scrolling combat, weapon cadence, enemy staging, and projectile readability, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Run-and-Gun Platformer should be positioned as a focused platformers entry about scrolling combat, weapon cadence, enemy staging, and projectile readability. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Level and scrolling | `lurek.tilemap`, `lurek.camera`, `lurek.parallax` | For Run-and-Gun Platformer, this area covers level and scrolling from the current design; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for layered scrolling backgrounds and depth cues. |
| Actor/projectile population | `lurek.ecs`, `lurek.physics`, `lurek.animation` | For Run-and-Gun Platformer, this area covers actor/projectile population from the current design; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Enemy behavior | `lurek.ai`, `lurek.patterns` | For Run-and-Gun Platformer, this area covers enemy behavior from the current design; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for inspectable decision scoring and scheduled planners. Use it for state machines, rule phases, command patterns, and undoable transition models. |
| Effects | `lurek.particle`, `lurek.audio`, `lurek.effect`, `lurek.render` | For Run-and-Gun Platformer, this area covers effects from the current design; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| UI and score | `lurek.ui`, `lurek.save` | For Run-and-Gun Platformer, this area covers ui and score from the current design; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Movement controller and collision probes | `lurek.physics`, `lurek.input`, `lurek.math` | For Run-and-Gun Platformer, this area covers buffering actions, querying grounded or wall contact, and keeping feel constants explicit; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Rooms, hazards, and checkpoints | `lurek.tilemap`, `lurek.tilefield`, `lurek.scene` | For Run-and-Gun Platformer, this area covers separating visual layers from lethal cells, respawn anchors, collectibles, and room transitions; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to decide which systems are active and which state may change in each screen. |
| Feel, camera, and assist overlays | `lurek.camera`, `lurek.effect`, `lurek.overlay` | For Run-and-Gun Platformer, this area covers showing safe timing windows, tuning shake or zoom, and inspecting retry-critical collision facts; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. |
| Scene ownership and mode boundaries | `lurek.scene` | For Run-and-Gun Platformer, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Run-and-Gun Platformer, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Run-and-Gun Platformer, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Run-and-Gun Platformer, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Run-and-Gun Platformer, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Run-and-Gun Platformer, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Run-and-Gun Platformer, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Run-and-Gun Platformer, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Run-and-Gun Platformer, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support scrolling combat, weapon cadence, enemy staging, and projectile readability. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Run-and-Gun Platformer state should center on scrolling combat, weapon cadence, enemy staging, and projectile readability. Treat actors as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Run-and-Gun Platformer state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for run-and-gun platformer previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Run-and-Gun Platformer into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where actors, bullets, weapons, enemy waves, pickups, bosses, and score events need stable identity across several systems. Single-purpose values can stay in domain tables, but any run-and-gun platformer object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Run-and-Gun Platformer is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/run_and_gun_platformer/main.lua` - owns run-and-gun platformer callback handoff and startup wiring.
- `content/games/run_and_gun_platformer/conf.toml` - owns run-and-gun platformer window, input, asset, and runtime defaults.
- `content/games/run_and_gun_platformer/data/run_and_gun_platformer_rules.toml` - owns run-and-gun platformer authored rules for scrolling combat, weapon cadence, enemy staging, and projectile readability.
- `content/games/run_and_gun_platformer/data/actors.toml` - owns run-and-gun platformer content records for actors.
- `content/games/run_and_gun_platformer/scripts/scenes/run_and_gun_platformer_play.lua` - owns run-and-gun platformer scene-local orchestration and pause/result transitions.
- `content/games/run_and_gun_platformer/scripts/systems/run_and_gun_platformer_state.lua` - owns run-and-gun platformer authoritative state containers and domain update order.
- `content/games/run_and_gun_platformer/scripts/systems/run_and_gun_platformer_validation.lua` - owns run-and-gun platformer data integrity checks before content enters a run.
- `content/games/run_and_gun_platformer/scripts/ui/run_and_gun_platformer_hud.lua` - owns run-and-gun platformer HUD, inspector, prompt, and accessibility surfaces.
- `content/games/run_and_gun_platformer/assets/run_and_gun_platformer/` - owns run-and-gun platformer media grouped by stable asset IDs.

## Game structure

Run-and-Gun Platformer should be built as a set of named domain services rather than one large gameplay script.

- `run_and_gun_platformer_state` owns durable actors, bullets, and weapons records.
- `run_and_gun_platformer_rules` validates commands, applies scrolling combat, weapon cadence, enemy staging, and projectile readability, and emits deterministic events.
- `run_and_gun_platformer_content` loads tables, checks IDs, and reports missing media before play starts.
- `run_and_gun_platformer_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `run_and_gun_platformer_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `run_and_gun_platformer_debug` exposes enemy waves, pickups, and bosses in overlays without mutating shipped state.

## Data and content model

- `actors_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `actors_table` data should live in `data/` and be validated before Run-and-Gun Platformer enters active play.
- `bullets_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `bullets_table` data should live in `data/` and be validated before Run-and-Gun Platformer enters active play.
- `weapons_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `weapons_table` data should live in `data/` and be validated before Run-and-Gun Platformer enters active play.
- Run-and-Gun Platformer save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Run-and-Gun Platformer content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate run-and-gun platformer setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for actors, bullets, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for scrolling combat, weapon cadence, enemy staging, and projectile readability; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Run-and-Gun Platformer tests can run without presentation timing.

## Vertical slice acceptance

One level should include two weapons, three enemy types, destructible crate, scrolling camera, checkpoint, miniboss phase, pickups, score, hit feedback, and restart flow.

## Risks

The risk is projectile overload. Separate projectile simulation from presentation, pool repeated effects, and cap offscreen actors aggressively.
