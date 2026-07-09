# Arcade Team Sports

## Design target

A technical game design document for a marketable 2D Arcade Team Sports built with Lurek2D. The design target is readable possession, quick matches, AI teammates, and score-state pressure, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Arcade Team Sports should be positioned as a focused sports racing entry about readable possession, quick matches, AI teammates, and score-state pressure. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Field/court rendering | `lurek.render`, `lurek.camera`, `lurek.tilemap` | For Arcade Team Sports, this area covers field/court rendering from the current design; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. |
| Players and ball | `lurek.ecs`, `lurek.physics`, `lurek.animation` | For Arcade Team Sports, this area covers players and ball from the current design; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Input/local control | `lurek.input`, `lurek.ui` | For Arcade Team Sports, this area covers input/local control from the current design; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Teammate AI | `lurek.ai`, `lurek.pathfind` | For Arcade Team Sports, this area covers teammate ai from the current design; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Match flow | `lurek.timer`, `lurek.event`, `lurek.audio`, `lurek.save` | For Arcade Team Sports, this area covers match flow from the current design; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Physical feel and timing | `lurek.physics`, `lurek.input`, `lurek.timer` | For Arcade Team Sports, this area covers combining controller response, contact checks, lap clocks, trick windows, or possession timing; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| AI rivals and match rules | `lurek.ai`, `lurek.event`, `lurek.save` | For Arcade Team Sports, this area covers resolving rival decisions, fouls, checkpoints, score events, ghosts, and season progress; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for inspectable decision scoring and scheduled planners. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Action framing and score feedback | `lurek.camera`, `lurek.tween`, `lurek.audio`, `lurek.ui` | For Arcade Team Sports, this area covers keeping fast motion readable and showing score pressure without mutating rule state; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Arcade Team Sports, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Arcade Team Sports, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Arcade Team Sports, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Arcade Team Sports, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Arcade Team Sports, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Arcade Team Sports, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Arcade Team Sports, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Arcade Team Sports, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Arcade Team Sports, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support readable possession, quick matches, AI teammates, and score-state pressure. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Arcade Team Sports state should center on readable possession, quick matches, AI teammates, and score-state pressure. Treat players as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Arcade Team Sports state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for arcade team sports previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Arcade Team Sports into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where players, ball, goals, teams, possession, match timer, and rule events need stable identity across several systems. Single-purpose values can stay in domain tables, but any arcade team sports object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Arcade Team Sports is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/arcade_team_sports/main.lua` - owns arcade team sports callback handoff and startup wiring.
- `content/games/arcade_team_sports/conf.toml` - owns arcade team sports window, input, asset, and runtime defaults.
- `content/games/arcade_team_sports/data/arcade_team_sports_rules.toml` - owns arcade team sports authored rules for readable possession, quick matches, AI teammates, and score-state pressure.
- `content/games/arcade_team_sports/data/players.toml` - owns arcade team sports content records for players.
- `content/games/arcade_team_sports/scripts/scenes/arcade_team_sports_play.lua` - owns arcade team sports scene-local orchestration and pause/result transitions.
- `content/games/arcade_team_sports/scripts/systems/arcade_team_sports_state.lua` - owns arcade team sports authoritative state containers and domain update order.
- `content/games/arcade_team_sports/scripts/systems/arcade_team_sports_validation.lua` - owns arcade team sports data integrity checks before content enters a run.
- `content/games/arcade_team_sports/scripts/ui/arcade_team_sports_hud.lua` - owns arcade team sports HUD, inspector, prompt, and accessibility surfaces.
- `content/games/arcade_team_sports/assets/arcade_team_sports/` - owns arcade team sports media grouped by stable asset IDs.

## Game structure

Arcade Team Sports should be built as a set of named domain services rather than one large gameplay script.

- `arcade_team_sports_state` owns durable players, ball, and goals records.
- `arcade_team_sports_rules` validates commands, applies readable possession, quick matches, AI teammates, and score-state pressure, and emits deterministic events.
- `arcade_team_sports_content` loads tables, checks IDs, and reports missing media before play starts.
- `arcade_team_sports_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `arcade_team_sports_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `arcade_team_sports_debug` exposes teams, possession, and match timer in overlays without mutating shipped state.

## Data and content model

- `players_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `players_table` data should live in `data/` and be validated before Arcade Team Sports enters active play.
- `ball_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `ball_table` data should live in `data/` and be validated before Arcade Team Sports enters active play.
- `goals_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `goals_table` data should live in `data/` and be validated before Arcade Team Sports enters active play.
- Arcade Team Sports save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Arcade Team Sports content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate arcade team sports setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for players, ball, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for readable possession, quick matches, AI teammates, and score-state pressure; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Arcade Team Sports tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one field, two teams, passing, shooting/scoring, possession changes, goalie or defender AI, match timer, local two-player option, and results save.

## Risks

The risk is input ambiguity. Every control action should have clear priority rules. Ball possession, tackle windows, and target selection must be visible enough that failure feels fair.
