# Tactics RPG Grid Battle

## Design target

A technical game design document for a marketable 2D Tactics RPG Grid Battle built with Lurek2D. The design target is grid tactics, elevation, party builds, ability previews, and campaign roster state, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Tactics RPG Grid Battle should be positioned as a focused tactics combat entry about grid tactics, elevation, party builds, ability previews, and campaign roster state. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Grid or isometric battlefield | `lurek.tilemap`, `lurek.camera`, `lurek.render` | For Tactics RPG Grid Battle, this area covers grid or isometric battlefield from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Move and skill range | `lurek.pathfind`, `lurek.tilefield` | For Tactics RPG Grid Battle, this area covers move and skill range from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Party and enemies | `lurek.ecs`, `lurek.serialize`, `lurek.save` | For Tactics RPG Grid Battle, this area covers party and enemies from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Ability sequencing | `lurek.patterns`, `lurek.tween`, `lurek.animation` | For Tactics RPG Grid Battle, this area covers ability sequencing from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Dialogue and cut-ins | `lurek.dialog`, `lurek.ui`, `lurek.cinematic` | For Tactics RPG Grid Battle, this area covers dialogue and cut-ins from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for scripted camera, portrait, music, or scene presentation timelines. |
| Progression data | `lurek.filesystem`, `lurek.dataframe` | For Tactics RPG Grid Battle, this area covers progression data from the current design; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Turn economy and tactical previews | `lurek.patterns`, `lurek.timer`, `lurek.ui` | For Tactics RPG Grid Battle, this area covers showing action points, initiative, legal actions, hit previews, and reaction windows; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Cover, grid, and line-of-sight | `lurek.tilefield`, `lurek.pathfind`, `lurek.awareness` | For Tactics RPG Grid Battle, this area covers querying reachable cells, cover arcs, visibility, elevation tags, and threat zones; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| Squad state and campaign records | `lurek.ecs`, `lurek.save`, `lurek.dataframe` | For Tactics RPG Grid Battle, this area covers persisting unit identities, abilities, injuries, equipment, and authored mission data; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Scene ownership and mode boundaries | `lurek.scene` | For Tactics RPG Grid Battle, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Tactics RPG Grid Battle, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Tactics RPG Grid Battle, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Tactics RPG Grid Battle, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Tactics RPG Grid Battle, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Tactics RPG Grid Battle, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Tactics RPG Grid Battle, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Tactics RPG Grid Battle, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Tactics RPG Grid Battle, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support grid tactics, elevation, party builds, ability previews, and campaign roster state. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Tactics RPG Grid Battle state should center on grid tactics, elevation, party builds, ability previews, and campaign roster state. Treat units as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Tactics RPG Grid Battle state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for tactics rpg grid battle previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Tactics RPG Grid Battle into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where units, grid cells, abilities, statuses, turn order, dialogue beats, and rewards need stable identity across several systems. Single-purpose values can stay in domain tables, but any tactics rpg grid battle object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Tactics RPG Grid Battle is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/tactics_rpg_grid_battle/main.lua` - owns tactics rpg grid battle callback handoff and startup wiring.
- `content/games/tactics_rpg_grid_battle/conf.toml` - owns tactics rpg grid battle window, input, asset, and runtime defaults.
- `content/games/tactics_rpg_grid_battle/data/tactics_rpg_grid_battle_rules.toml` - owns tactics rpg grid battle authored rules for grid tactics, elevation, party builds, ability previews, and campaign roster state.
- `content/games/tactics_rpg_grid_battle/data/units.toml` - owns tactics rpg grid battle content records for units.
- `content/games/tactics_rpg_grid_battle/scripts/scenes/tactics_rpg_grid_battle_play.lua` - owns tactics rpg grid battle scene-local orchestration and pause/result transitions.
- `content/games/tactics_rpg_grid_battle/scripts/systems/tactics_rpg_grid_battle_state.lua` - owns tactics rpg grid battle authoritative state containers and domain update order.
- `content/games/tactics_rpg_grid_battle/scripts/systems/tactics_rpg_grid_battle_validation.lua` - owns tactics rpg grid battle data integrity checks before content enters a run.
- `content/games/tactics_rpg_grid_battle/scripts/ui/tactics_rpg_grid_battle_hud.lua` - owns tactics rpg grid battle HUD, inspector, prompt, and accessibility surfaces.
- `content/games/tactics_rpg_grid_battle/assets/tactics_rpg_grid_battle/` - owns tactics rpg grid battle media grouped by stable asset IDs.

## Game structure

Tactics RPG Grid Battle should be built as a set of named domain services rather than one large gameplay script.

- `tactics_rpg_grid_battle_state` owns durable units, grid cells, and abilities records.
- `tactics_rpg_grid_battle_rules` validates commands, applies grid tactics, elevation, party builds, ability previews, and campaign roster state, and emits deterministic events.
- `tactics_rpg_grid_battle_content` loads tables, checks IDs, and reports missing media before play starts.
- `tactics_rpg_grid_battle_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `tactics_rpg_grid_battle_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `tactics_rpg_grid_battle_debug` exposes statuses, turn order, and dialogue beats in overlays without mutating shipped state.

## Data and content model

- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before Tactics RPG Grid Battle enters active play.
- `grid_cells_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `grid_cells_table` data should live in `data/` and be validated before Tactics RPG Grid Battle enters active play.
- `abilities_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `abilities_table` data should live in `data/` and be validated before Tactics RPG Grid Battle enters active play.
- Tactics RPG Grid Battle save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Tactics RPG Grid Battle content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate tactics rpg grid battle setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for units, grid cells, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for grid tactics, elevation, party builds, ability previews, and campaign roster state; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Tactics RPG Grid Battle tests can run without presentation timing.

## Vertical slice acceptance

Ship one battle with four party members, two classes, five abilities, one status effect, one dialogue intro, one victory condition, battle forecast UI, experience award, and persistence back to campaign state.

## Risks

Progression systems can overwhelm battle clarity. Keep formulas data-driven but limited at first, and make every ability preview include target cells, expected damage, status chance, and resource cost.
