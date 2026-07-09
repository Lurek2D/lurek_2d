# Trick Score Sports

## Design target

A technical game design document for a marketable 2D Trick Score Sports built with Lurek2D. The design target is combo windows, trick timing, course lines, and style scoring, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Trick Score Sports should be positioned as a focused sports racing entry about combo windows, trick timing, course lines, and style scoring. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Course layout | `lurek.tilemap`, `lurek.physics`, `lurek.camera` | For Trick Score Sports, this area covers course layout from the current design; it should support combo windows, trick timing, course lines, and style scoring. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Character movement | `lurek.input`, `lurek.math`, `lurek.animation`, `lurek.tween` | For Trick Score Sports, this area covers character movement from the current design; it should support combo windows, trick timing, course lines, and style scoring. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Trick/combo logic | `lurek.patterns`, `lurek.timer`, `lurek.event` | For Trick Score Sports, this area covers trick/combo logic from the current design; it should support combo windows, trick timing, course lines, and style scoring. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Effects/audio/UI | `lurek.render`, `lurek.audio`, `lurek.particle`, `lurek.ui` | For Trick Score Sports, this area covers effects/audio/ui from the current design; it should support combo windows, trick timing, course lines, and style scoring. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Progress | `lurek.save` | For Trick Score Sports, this area covers progress from the current design; it should support combo windows, trick timing, course lines, and style scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Physical feel and timing | `lurek.physics`, `lurek.input`, `lurek.timer` | For Trick Score Sports, this area covers combining controller response, contact checks, lap clocks, trick windows, or possession timing; it should support combo windows, trick timing, course lines, and style scoring. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| AI rivals and match rules | `lurek.ai`, `lurek.event`, `lurek.save` | For Trick Score Sports, this area covers resolving rival decisions, fouls, checkpoints, score events, ghosts, and season progress; it should support combo windows, trick timing, course lines, and style scoring. Use it for inspectable decision scoring and scheduled planners. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Action framing and score feedback | `lurek.camera`, `lurek.tween`, `lurek.audio`, `lurek.ui` | For Trick Score Sports, this area covers keeping fast motion readable and showing score pressure without mutating rule state; it should support combo windows, trick timing, course lines, and style scoring. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Trick Score Sports, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support combo windows, trick timing, course lines, and style scoring. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Trick Score Sports, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support combo windows, trick timing, course lines, and style scoring. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Trick Score Sports, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support combo windows, trick timing, course lines, and style scoring. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Trick Score Sports, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support combo windows, trick timing, course lines, and style scoring. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Trick Score Sports, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support combo windows, trick timing, course lines, and style scoring. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Trick Score Sports, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support combo windows, trick timing, course lines, and style scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Trick Score Sports, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support combo windows, trick timing, course lines, and style scoring. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Trick Score Sports, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support combo windows, trick timing, course lines, and style scoring. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Trick Score Sports, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support combo windows, trick timing, course lines, and style scoring. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Trick Score Sports state should center on combo windows, trick timing, course lines, and style scoring. Treat rider as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Trick Score Sports state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for trick score sports previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Trick Score Sports into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where rider, trick states, rails, ramps, score chains, timers, and replay markers need stable identity across several systems. Single-purpose values can stay in domain tables, but any trick score sports object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Trick Score Sports is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/trick_score_sports/main.lua` - owns trick score sports callback handoff and startup wiring.
- `content/games/trick_score_sports/conf.toml` - owns trick score sports window, input, asset, and runtime defaults.
- `content/games/trick_score_sports/data/trick_score_sports_rules.toml` - owns trick score sports authored rules for combo windows, trick timing, course lines, and style scoring.
- `content/games/trick_score_sports/data/rider.toml` - owns trick score sports content records for rider.
- `content/games/trick_score_sports/scripts/scenes/trick_score_sports_play.lua` - owns trick score sports scene-local orchestration and pause/result transitions.
- `content/games/trick_score_sports/scripts/systems/trick_score_sports_state.lua` - owns trick score sports authoritative state containers and domain update order.
- `content/games/trick_score_sports/scripts/systems/trick_score_sports_validation.lua` - owns trick score sports data integrity checks before content enters a run.
- `content/games/trick_score_sports/scripts/ui/trick_score_sports_hud.lua` - owns trick score sports HUD, inspector, prompt, and accessibility surfaces.
- `content/games/trick_score_sports/assets/trick_score_sports/` - owns trick score sports media grouped by stable asset IDs.

## Game structure

Trick Score Sports should be built as a set of named domain services rather than one large gameplay script.

- `trick_score_sports_state` owns durable rider, trick states, and rails records.
- `trick_score_sports_rules` validates commands, applies combo windows, trick timing, course lines, and style scoring, and emits deterministic events.
- `trick_score_sports_content` loads tables, checks IDs, and reports missing media before play starts.
- `trick_score_sports_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `trick_score_sports_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `trick_score_sports_debug` exposes ramps, score chains, and timers in overlays without mutating shipped state.

## Data and content model

- `rider_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `rider_table` data should live in `data/` and be validated before Trick Score Sports enters active play.
- `trick_states_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `trick_states_table` data should live in `data/` and be validated before Trick Score Sports enters active play.
- `rails_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `rails_table` data should live in `data/` and be validated before Trick Score Sports enters active play.
- Trick Score Sports save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Trick Score Sports content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate trick score sports setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for rider, trick states, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for combo windows, trick timing, course lines, and style scoring; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Trick Score Sports tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one course, jump, grind, manual, five tricks, combo multiplier, bail, three objectives, timer, results screen, and high-score save.

## Risks

The risk is animation driving rules. Movement state and collision should be authoritative; animation should visualize trick state, not determine whether a trick succeeded.
