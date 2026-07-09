# Top-Down Adventure

## Design target

A technical game design document for a marketable 2D Top-Down Adventure built with Lurek2D. The design target is room-to-room exploration, item gates, combat reads, and checkpoint safety, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Top-Down Adventure should be positioned as a focused action adventure entry about room-to-room exploration, item gates, combat reads, and checkpoint safety. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Rooms and overworld | `lurek.tilemap`, `lurek.scene`, `lurek.camera` | For Top-Down Adventure, this area covers rooms and overworld from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to decide which systems are active and which state may change in each screen. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Player/enemies/items | `lurek.ecs`, `lurek.animation`, `lurek.physics` | For Top-Down Adventure, this area covers player/enemies/items from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| Combat and interactions | `lurek.input`, `lurek.event`, `lurek.audio`, `lurek.particle` | For Top-Down Adventure, this area covers combat and interactions from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Navigation and enemy AI | `lurek.pathfind`, `lurek.ai` | For Top-Down Adventure, this area covers navigation and enemy ai from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. |
| Dialogue and quests | `lurek.dialog`, `lurek.ui` | For Top-Down Adventure, this area covers dialogue and quests from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Persistence | `lurek.save` | For Top-Down Adventure, this area covers persistence from the current design; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Room, hotspot, and traversal maps | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Top-Down Adventure, this area covers separating visual rooms from interaction cells, blocked routes, door links, and reachable targets; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Conversation and inspection flow | `lurek.dialog`, `lurek.ui`, `lurek.i18n` | For Top-Down Adventure, this area covers binding speakers, prompts, object text, and localized labels to stable content IDs; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Exploration visibility | `lurek.awareness`, `lurek.light`, `lurek.minimap` | For Top-Down Adventure, this area covers tracking seen areas, revealing hints, and summarizing discovered exits without exposing hidden objectives too early; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Scene ownership and mode boundaries | `lurek.scene` | For Top-Down Adventure, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Top-Down Adventure, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Top-Down Adventure, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Top-Down Adventure, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Top-Down Adventure, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Top-Down Adventure, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Top-Down Adventure, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Top-Down Adventure, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Top-Down Adventure, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support room-to-room exploration, item gates, combat reads, and checkpoint safety. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Top-Down Adventure state should center on room-to-room exploration, item gates, combat reads, and checkpoint safety. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Top-Down Adventure state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for top-down adventure previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Top-Down Adventure into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, enemies, pickups, doors, triggers, chests, and map flags need stable identity across several systems. Single-purpose values can stay in domain tables, but any top-down adventure object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Top-Down Adventure is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/top_down_adventure/main.lua` - owns top-down adventure callback handoff and startup wiring.
- `content/games/top_down_adventure/conf.toml` - owns top-down adventure window, input, asset, and runtime defaults.
- `content/games/top_down_adventure/data/top_down_adventure_rules.toml` - owns top-down adventure authored rules for room-to-room exploration, item gates, combat reads, and checkpoint safety.
- `content/games/top_down_adventure/data/player.toml` - owns top-down adventure content records for player.
- `content/games/top_down_adventure/scripts/scenes/top_down_adventure_play.lua` - owns top-down adventure scene-local orchestration and pause/result transitions.
- `content/games/top_down_adventure/scripts/systems/top_down_adventure_state.lua` - owns top-down adventure authoritative state containers and domain update order.
- `content/games/top_down_adventure/scripts/systems/top_down_adventure_validation.lua` - owns top-down adventure data integrity checks before content enters a run.
- `content/games/top_down_adventure/scripts/ui/top_down_adventure_hud.lua` - owns top-down adventure HUD, inspector, prompt, and accessibility surfaces.
- `content/games/top_down_adventure/assets/top_down_adventure/` - owns top-down adventure media grouped by stable asset IDs.

## Game structure

Top-Down Adventure should be built as a set of named domain services rather than one large gameplay script.

- `top_down_adventure_state` owns durable player, enemies, and pickups records.
- `top_down_adventure_rules` validates commands, applies room-to-room exploration, item gates, combat reads, and checkpoint safety, and emits deterministic events.
- `top_down_adventure_content` loads tables, checks IDs, and reports missing media before play starts.
- `top_down_adventure_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `top_down_adventure_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `top_down_adventure_debug` exposes doors, triggers, and chests in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Top-Down Adventure enters active play.
- `enemies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `enemies_table` data should live in `data/` and be validated before Top-Down Adventure enters active play.
- `pickups_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `pickups_table` data should live in `data/` and be validated before Top-Down Adventure enters active play.
- Top-Down Adventure save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Top-Down Adventure content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate top-down adventure setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, enemies, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for room-to-room exploration, item gates, combat reads, and checkpoint safety; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Top-Down Adventure tests can run without presentation timing.

## Vertical slice acceptance

One slice should include three rooms, one weapon, one key item, two enemy types, one puzzle door, one NPC dialogue, one secret, room transition, HUD hearts/resources, and checkpoint save/load.

## Risks

The risk is blending room content with global state. Use authored room data for layout and spawn definitions, but keep durable progression in a separate world-state service.
