# Squad Tactics Skirmish

## Design target

A technical game design document for a marketable 2D Squad Tactics Skirmish built with Lurek2D. The design target is action points, cover, reactions, squad identity, and tactical previews, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Squad Tactics Skirmish should be positioned as a focused tactics combat entry about action points, cover, reactions, squad identity, and tactical previews. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Tactical map | `lurek.tilemap`, `lurek.tilefield`, `lurek.light` | For Squad Tactics Skirmish, this area covers tactical map from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. |
| Movement ranges | `lurek.pathfind` | For Squad Tactics Skirmish, this area covers movement ranges from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Soldiers and enemies | `lurek.ecs` | For Squad Tactics Skirmish, this area covers soldiers and enemies from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Enemy behavior | `lurek.ai` | For Squad Tactics Skirmish, this area covers enemy behavior from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for inspectable decision scoring and scheduled planners. |
| Combat presentation | `lurek.animation`, `lurek.particle`, `lurek.audio`, `lurek.effect` | For Squad Tactics Skirmish, this area covers combat presentation from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| UI and tooltips | `lurek.ui`, `lurek.render`, `lurek.input` | For Squad Tactics Skirmish, this area covers ui and tooltips from the current design; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. |
| Turn economy and tactical previews | `lurek.patterns`, `lurek.timer`, `lurek.ui` | For Squad Tactics Skirmish, this area covers showing action points, initiative, legal actions, hit previews, and reaction windows; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Cover, grid, and line-of-sight | `lurek.tilefield`, `lurek.pathfind`, `lurek.awareness` | For Squad Tactics Skirmish, this area covers querying reachable cells, cover arcs, visibility, elevation tags, and threat zones; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| Squad state and campaign records | `lurek.ecs`, `lurek.save`, `lurek.dataframe` | For Squad Tactics Skirmish, this area covers persisting unit identities, abilities, injuries, equipment, and authored mission data; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Scene ownership and mode boundaries | `lurek.scene` | For Squad Tactics Skirmish, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support action points, cover, reactions, squad identity, and tactical previews. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Squad Tactics Skirmish, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Squad Tactics Skirmish, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Squad Tactics Skirmish, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support action points, cover, reactions, squad identity, and tactical previews. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Squad Tactics Skirmish, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support action points, cover, reactions, squad identity, and tactical previews. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Squad Tactics Skirmish, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Squad Tactics Skirmish, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support action points, cover, reactions, squad identity, and tactical previews. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Squad Tactics Skirmish, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Squad Tactics Skirmish, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support action points, cover, reactions, squad identity, and tactical previews. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Squad Tactics Skirmish state should center on action points, cover, reactions, squad identity, and tactical previews. Treat soldiers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Squad Tactics Skirmish state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for squad tactics skirmish previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Squad Tactics Skirmish into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where soldiers, enemies, cover cells, action points, weapons, objectives, and reactions need stable identity across several systems. Single-purpose values can stay in domain tables, but any squad tactics skirmish object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Squad Tactics Skirmish is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/squad_tactics_skirmish/main.lua` - owns squad tactics skirmish callback handoff and startup wiring.
- `content/games/squad_tactics_skirmish/conf.toml` - owns squad tactics skirmish window, input, asset, and runtime defaults.
- `content/games/squad_tactics_skirmish/data/squad_tactics_skirmish_rules.toml` - owns squad tactics skirmish authored rules for action points, cover, reactions, squad identity, and tactical previews.
- `content/games/squad_tactics_skirmish/data/soldiers.toml` - owns squad tactics skirmish content records for soldiers.
- `content/games/squad_tactics_skirmish/scripts/scenes/squad_tactics_skirmish_play.lua` - owns squad tactics skirmish scene-local orchestration and pause/result transitions.
- `content/games/squad_tactics_skirmish/scripts/systems/squad_tactics_skirmish_state.lua` - owns squad tactics skirmish authoritative state containers and domain update order.
- `content/games/squad_tactics_skirmish/scripts/systems/squad_tactics_skirmish_validation.lua` - owns squad tactics skirmish data integrity checks before content enters a run.
- `content/games/squad_tactics_skirmish/scripts/ui/squad_tactics_skirmish_hud.lua` - owns squad tactics skirmish HUD, inspector, prompt, and accessibility surfaces.
- `content/games/squad_tactics_skirmish/assets/squad_tactics_skirmish/` - owns squad tactics skirmish media grouped by stable asset IDs.

## Game structure

Squad Tactics Skirmish should be built as a set of named domain services rather than one large gameplay script.

- `squad_tactics_skirmish_state` owns durable soldiers, enemies, and cover cells records.
- `squad_tactics_skirmish_rules` validates commands, applies action points, cover, reactions, squad identity, and tactical previews, and emits deterministic events.
- `squad_tactics_skirmish_content` loads tables, checks IDs, and reports missing media before play starts.
- `squad_tactics_skirmish_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `squad_tactics_skirmish_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `squad_tactics_skirmish_debug` exposes action points, weapons, and objectives in overlays without mutating shipped state.

## Data and content model

- `soldiers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `soldiers_table` data should live in `data/` and be validated before Squad Tactics Skirmish enters active play.
- `enemies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `enemies_table` data should live in `data/` and be validated before Squad Tactics Skirmish enters active play.
- `cover_cells_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `cover_cells_table` data should live in `data/` and be validated before Squad Tactics Skirmish enters active play.
- Squad Tactics Skirmish save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Squad Tactics Skirmish content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate squad tactics skirmish setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for soldiers, enemies, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for action points, cover, reactions, squad identity, and tactical previews; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Squad Tactics Skirmish tests can run without presentation timing.

## Vertical slice acceptance

One mission should support two player units, three enemies, movement range overlay, cover preview, one weapon, overwatch reaction, enemy turn, mission success/failure, and a combat log that explains every damage result.

## Risks

The risk is preview/commit mismatch. The same services must feed both UI prediction and final resolution, with random seeds or probability rolls isolated at commit time.
