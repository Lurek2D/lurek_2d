# Exploration Collectathon

## Design target

A technical game design document for a marketable 2D Exploration Collectathon built with Lurek2D. The design target is zone memory, traversal gates, collectible accounting, and map completion, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Exploration Collectathon should be positioned as a focused action adventure entry about zone memory, traversal gates, collectible accounting, and map completion. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Connected zones | `lurek.scene`, `lurek.tilemap`, `lurek.camera`, `lurek.parallax` | For Exploration Collectathon, this area covers connected zones from the current design; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it to decide which systems are active and which state may change in each screen. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for layered scrolling backgrounds and depth cues. |
| Collectibles and triggers | `lurek.ecs`, `lurek.event`, `lurek.save` | For Exploration Collectathon, this area covers collectibles and triggers from the current design; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Movement feel | `lurek.physics`, `lurek.animation`, `lurek.tween` | For Exploration Collectathon, this area covers movement feel from the current design; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Map and completion UI | `lurek.ui`, `lurek.minimap`, `lurek.render` | For Exploration Collectathon, this area covers map and completion ui from the current design; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Characters and flavor | `lurek.dialog`, `lurek.audio`, `lurek.i18n` | For Exploration Collectathon, this area covers characters and flavor from the current design; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Room, hotspot, and traversal maps | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Exploration Collectathon, this area covers separating visual rooms from interaction cells, blocked routes, door links, and reachable targets; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Conversation and inspection flow | `lurek.dialog`, `lurek.ui`, `lurek.i18n` | For Exploration Collectathon, this area covers binding speakers, prompts, object text, and localized labels to stable content IDs; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Exploration visibility | `lurek.awareness`, `lurek.light`, `lurek.minimap` | For Exploration Collectathon, this area covers tracking seen areas, revealing hints, and summarizing discovered exits without exposing hidden objectives too early; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Scene ownership and mode boundaries | `lurek.scene` | For Exploration Collectathon, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Exploration Collectathon, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Exploration Collectathon, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Exploration Collectathon, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Exploration Collectathon, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Exploration Collectathon, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Exploration Collectathon, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Exploration Collectathon, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Exploration Collectathon, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support zone memory, traversal gates, collectible accounting, and map completion. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Exploration Collectathon state should center on zone memory, traversal gates, collectible accounting, and map completion. Treat areas as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Exploration Collectathon state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for exploration collectathon previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Exploration Collectathon into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where areas, collectibles, NPC hints, unlock flags, traversal upgrades, and zone entrances need stable identity across several systems. Single-purpose values can stay in domain tables, but any exploration collectathon object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Exploration Collectathon is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/exploration_collectathon/main.lua` - owns exploration collectathon callback handoff and startup wiring.
- `content/games/exploration_collectathon/conf.toml` - owns exploration collectathon window, input, asset, and runtime defaults.
- `content/games/exploration_collectathon/data/exploration_collectathon_rules.toml` - owns exploration collectathon authored rules for zone memory, traversal gates, collectible accounting, and map completion.
- `content/games/exploration_collectathon/data/areas.toml` - owns exploration collectathon content records for areas.
- `content/games/exploration_collectathon/scripts/scenes/exploration_collectathon_play.lua` - owns exploration collectathon scene-local orchestration and pause/result transitions.
- `content/games/exploration_collectathon/scripts/systems/exploration_collectathon_state.lua` - owns exploration collectathon authoritative state containers and domain update order.
- `content/games/exploration_collectathon/scripts/systems/exploration_collectathon_validation.lua` - owns exploration collectathon data integrity checks before content enters a run.
- `content/games/exploration_collectathon/scripts/ui/exploration_collectathon_hud.lua` - owns exploration collectathon HUD, inspector, prompt, and accessibility surfaces.
- `content/games/exploration_collectathon/assets/exploration_collectathon/` - owns exploration collectathon media grouped by stable asset IDs.

## Game structure

Exploration Collectathon should be built as a set of named domain services rather than one large gameplay script.

- `exploration_collectathon_state` owns durable areas, collectibles, and NPC hints records.
- `exploration_collectathon_rules` validates commands, applies zone memory, traversal gates, collectible accounting, and map completion, and emits deterministic events.
- `exploration_collectathon_content` loads tables, checks IDs, and reports missing media before play starts.
- `exploration_collectathon_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `exploration_collectathon_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `exploration_collectathon_debug` exposes unlock flags, traversal upgrades, and  in overlays without mutating shipped state.

## Data and content model

- `areas_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `areas_table` data should live in `data/` and be validated before Exploration Collectathon enters active play.
- `collectibles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `collectibles_table` data should live in `data/` and be validated before Exploration Collectathon enters active play.
- `NPC_hints_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `NPC_hints_table` data should live in `data/` and be validated before Exploration Collectathon enters active play.
- Exploration Collectathon save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Exploration Collectathon content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate exploration collectathon setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for areas, collectibles, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for zone memory, traversal gates, collectible accounting, and map completion; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Exploration Collectathon tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one hub, two connected zones, three collectible types, one unlockable traversal ability, map completion UI, one NPC hint, secret room, music transition, and save/load.

## Risks

The risk is content drift: collectathon games become hard to test when item IDs and gates are informal. Maintain a completion registry and validate that every persistent pickup and gate has a stable data ID.
