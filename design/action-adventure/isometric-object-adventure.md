# Isometric Object Adventure

## Design target

A technical game design document for a marketable 2D Isometric Object Adventure built with Lurek2D. The design target is room composition, object hotspots, click movement, and inspection text, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Isometric Object Adventure should be positioned as a focused action adventure entry about room composition, object hotspots, click movement, and inspection text. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Isometric rooms and props | `lurek.tilemap`, `lurek.camera` | For Isometric Object Adventure, this area covers isometric rooms and props from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Room collision and visibility facts | `lurek.tilefield` | For Isometric Object Adventure, this area covers room collision and visibility facts from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Scene objects and hotspots | `lurek.ecs`, `lurek.scene`, `lurek.event` | For Isometric Object Adventure, this area covers scene objects and hotspots from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it to decide which systems are active and which state may change in each screen. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Cursor, hover, and selection flow | `lurek.input`, `lurek.ui`, `lurek.render` | For Isometric Object Adventure, this area covers cursor, hover, and selection flow from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Click-to-move and local navigation | `lurek.pathfind` | For Isometric Object Adventure, this area covers click-to-move and local navigation from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Trigger zones and interaction bounds | `lurek.physics` | For Isometric Object Adventure, this area covers trigger zones and interaction bounds from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| Dialogue, inspect text, and prompts | `lurek.dialog`, `lurek.ui`, `lurek.i18n` | For Isometric Object Adventure, this area covers dialogue, inspect text, and prompts from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Atmosphere and shadows | `lurek.light`, `lurek.tilelight` | For Isometric Object Adventure, this area covers atmosphere and shadows from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for tile-level light propagation and darkness gameplay. |
| Persistent room state | `lurek.save`, `lurek.serialize` | For Isometric Object Adventure, this area covers persistent room state from the current design; it should support room composition, object hotspots, click movement, and inspection text. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Room, hotspot, and traversal maps | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Isometric Object Adventure, this area covers separating visual rooms from interaction cells, blocked routes, door links, and reachable targets; it should support room composition, object hotspots, click movement, and inspection text. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Conversation and inspection flow | `lurek.dialog`, `lurek.ui`, `lurek.i18n` | For Isometric Object Adventure, this area covers binding speakers, prompts, object text, and localized labels to stable content IDs; it should support room composition, object hotspots, click movement, and inspection text. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Exploration visibility | `lurek.awareness`, `lurek.light`, `lurek.minimap` | For Isometric Object Adventure, this area covers tracking seen areas, revealing hints, and summarizing discovered exits without exposing hidden objectives too early; it should support room composition, object hotspots, click movement, and inspection text. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Scene ownership and mode boundaries | `lurek.scene` | For Isometric Object Adventure, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support room composition, object hotspots, click movement, and inspection text. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Isometric Object Adventure, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support room composition, object hotspots, click movement, and inspection text. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Isometric Object Adventure, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support room composition, object hotspots, click movement, and inspection text. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Isometric Object Adventure, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support room composition, object hotspots, click movement, and inspection text. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Isometric Object Adventure, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support room composition, object hotspots, click movement, and inspection text. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Isometric Object Adventure, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support room composition, object hotspots, click movement, and inspection text. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Isometric Object Adventure, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support room composition, object hotspots, click movement, and inspection text. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Isometric Object Adventure, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support room composition, object hotspots, click movement, and inspection text. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Isometric Object Adventure, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support room composition, object hotspots, click movement, and inspection text. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Isometric Object Adventure state should center on room composition, object hotspots, click movement, and inspection text. Treat rooms as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Isometric Object Adventure state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for isometric object adventure previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Isometric Object Adventure into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where rooms, props, hotspots, cursor targets, dialogue beats, and puzzle flags need stable identity across several systems. Single-purpose values can stay in domain tables, but any isometric object adventure object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Isometric Object Adventure is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/isometric_object_adventure/main.lua` - owns isometric object adventure callback handoff and startup wiring.
- `content/games/isometric_object_adventure/conf.toml` - owns isometric object adventure window, input, asset, and runtime defaults.
- `content/games/isometric_object_adventure/data/isometric_object_adventure_rules.toml` - owns isometric object adventure authored rules for room composition, object hotspots, click movement, and inspection text.
- `content/games/isometric_object_adventure/data/rooms.toml` - owns isometric object adventure content records for rooms.
- `content/games/isometric_object_adventure/scripts/scenes/isometric_object_adventure_play.lua` - owns isometric object adventure scene-local orchestration and pause/result transitions.
- `content/games/isometric_object_adventure/scripts/systems/isometric_object_adventure_state.lua` - owns isometric object adventure authoritative state containers and domain update order.
- `content/games/isometric_object_adventure/scripts/systems/isometric_object_adventure_validation.lua` - owns isometric object adventure data integrity checks before content enters a run.
- `content/games/isometric_object_adventure/scripts/ui/isometric_object_adventure_hud.lua` - owns isometric object adventure HUD, inspector, prompt, and accessibility surfaces.
- `content/games/isometric_object_adventure/assets/isometric_object_adventure/` - owns isometric object adventure media grouped by stable asset IDs.

## Game structure

Isometric Object Adventure should be built as a set of named domain services rather than one large gameplay script.

- `isometric_object_adventure_state` owns durable rooms, props, and hotspots records.
- `isometric_object_adventure_rules` validates commands, applies room composition, object hotspots, click movement, and inspection text, and emits deterministic events.
- `isometric_object_adventure_content` loads tables, checks IDs, and reports missing media before play starts.
- `isometric_object_adventure_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `isometric_object_adventure_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `isometric_object_adventure_debug` exposes cursor targets, dialogue beats, and  in overlays without mutating shipped state.

## Data and content model

- `rooms_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `rooms_table` data should live in `data/` and be validated before Isometric Object Adventure enters active play.
- `props_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `props_table` data should live in `data/` and be validated before Isometric Object Adventure enters active play.
- `hotspots_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `hotspots_table` data should live in `data/` and be validated before Isometric Object Adventure enters active play.
- Isometric Object Adventure save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Isometric Object Adventure content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate isometric object adventure setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for rooms, props, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for room composition, object hotspots, click movement, and inspection text; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Isometric Object Adventure tests can run without presentation timing.

## Vertical slice acceptance

The slice should include three connected isometric rooms, click-to-move, one NPC, one locked door, one key or puzzle item, one container, one inspect-only hotspot, one room transition, one trigger volume, one cutaway roof or foreground wall, one point light with an occluder, hover prompts, object state changes saved across reload, and debug overlays for tile coordinates, hotspots, colliders, blockers, cutaway triggers, and depth order.

## Risks

The biggest risk is mixing interaction logic into map art. Keep art layers, blocker facts, physics sensors, and interaction scripts separate but linked by stable object IDs. The second risk is poor picking priority in dense scenes. Make the picker deterministic, debug-visible, and configurable before adding large numbers of props and hotspots.
