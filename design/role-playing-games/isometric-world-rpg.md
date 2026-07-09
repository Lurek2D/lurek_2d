# Isometric World RPG

## Design target

A technical game design document for a marketable 2D Isometric World RPG built with Lurek2D. The design target is height-sorted exploration, party positioning, object interaction, and world flags, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Isometric World RPG should be positioned as a focused role playing games entry about height-sorted exploration, party positioning, object interaction, and world flags. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Isometric terrain and wall tiles | `lurek.tilemap`, `lurek.camera` | For Isometric World RPG, this area covers isometric terrain and wall tiles from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Gameplay cell facts | `lurek.tilefield` | For Isometric World RPG, this area covers gameplay cell facts from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Actors, props, and stable object identity | `lurek.ecs`, `lurek.scene`, `lurek.save` | For Isometric World RPG, this area covers actors, props, and stable object identity from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it to decide which systems are active and which state may change in each screen. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Click-to-move navigation | `lurek.pathfind`, `lurek.input` | For Isometric World RPG, this area covers click-to-move navigation from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. |
| Doors, containers, triggers, and interaction zones | `lurek.physics`, `lurek.event`, `lurek.ui` | For Isometric World RPG, this area covers doors, containers, triggers, and interaction zones from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene lights, shadows, and tile-level light blockers | `lurek.light`, `lurek.tilelight`, `lurek.render` | For Isometric World RPG, this area covers scene lights, shadows, and tile-level light blockers from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for tile-level light propagation and darkness gameplay. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Tiled-authored areas | `lurek.tilemap` | For Isometric World RPG, this area covers tiled-authored areas from the current design; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. |
| Quests, party entities, and world state | `lurek.ecs`, `lurek.dialog`, `lurek.save` | For Isometric World RPG, this area covers binding actors, quests, dialogue flags, inventory, and progression to stable IDs; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Maps, navigation, and encounters | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Isometric World RPG, this area covers keeping visual maps separate from blockers, triggers, encounter regions, and reachable destinations; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Stats, items, and authored tables | `lurek.dataframe`, `lurek.serialize`, `lurek.ui` | For Isometric World RPG, this area covers validating skills, equipment, rewards, and status descriptions before runtime use; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Isometric World RPG, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Isometric World RPG, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Isometric World RPG, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Isometric World RPG, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Isometric World RPG, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Isometric World RPG, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Isometric World RPG, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Isometric World RPG, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Isometric World RPG, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support height-sorted exploration, party positioning, object interaction, and world flags. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Isometric World RPG state should center on height-sorted exploration, party positioning, object interaction, and world flags. Treat party as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Isometric World RPG state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for isometric world rpg previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Isometric World RPG into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where party, NPCs, doors, containers, encounters, quest markers, and lighting refs need stable identity across several systems. Single-purpose values can stay in domain tables, but any isometric world rpg object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Isometric World RPG is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/isometric_world_rpg/main.lua` - owns isometric world rpg callback handoff and startup wiring.
- `content/games/isometric_world_rpg/conf.toml` - owns isometric world rpg window, input, asset, and runtime defaults.
- `content/games/isometric_world_rpg/data/isometric_world_rpg_rules.toml` - owns isometric world rpg authored rules for height-sorted exploration, party positioning, object interaction, and world flags.
- `content/games/isometric_world_rpg/data/party.toml` - owns isometric world rpg content records for party.
- `content/games/isometric_world_rpg/scripts/scenes/isometric_world_rpg_play.lua` - owns isometric world rpg scene-local orchestration and pause/result transitions.
- `content/games/isometric_world_rpg/scripts/systems/isometric_world_rpg_state.lua` - owns isometric world rpg authoritative state containers and domain update order.
- `content/games/isometric_world_rpg/scripts/systems/isometric_world_rpg_validation.lua` - owns isometric world rpg data integrity checks before content enters a run.
- `content/games/isometric_world_rpg/scripts/ui/isometric_world_rpg_hud.lua` - owns isometric world rpg HUD, inspector, prompt, and accessibility surfaces.
- `content/games/isometric_world_rpg/assets/isometric_world_rpg/` - owns isometric world rpg media grouped by stable asset IDs.

## Game structure

Isometric World RPG should be built as a set of named domain services rather than one large gameplay script.

- `isometric_world_rpg_state` owns durable party, NPCs, and doors records.
- `isometric_world_rpg_rules` validates commands, applies height-sorted exploration, party positioning, object interaction, and world flags, and emits deterministic events.
- `isometric_world_rpg_content` loads tables, checks IDs, and reports missing media before play starts.
- `isometric_world_rpg_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `isometric_world_rpg_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `isometric_world_rpg_debug` exposes containers, encounters, and quest markers in overlays without mutating shipped state.

## Data and content model

- `party_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `party_table` data should live in `data/` and be validated before Isometric World RPG enters active play.
- `NPCs_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `NPCs_table` data should live in `data/` and be validated before Isometric World RPG enters active play.
- `doors_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `doors_table` data should live in `data/` and be validated before Isometric World RPG enters active play.
- Isometric World RPG save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Isometric World RPG content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate isometric world rpg setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for party, NPCs, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for height-sorted exploration, party positioning, object interaction, and world flags; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Isometric World RPG tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one Tiled isometric area with an exterior and one interior, floor/decal/wall/roof layers, three tall props, one working door, one container, one NPC spawn, one exit trigger, one point light, at least one wall/light occluder, click-to-move over an `iso_square` tilefield, hover/click interaction selection, roof or wall cutaway behavior, save/reload of object state, and debug overlays for anchors, depth keys, blockers, colliders, lights, and interaction bounds.

## Risks

The largest risk is visual ambiguity from unstable draw order. Centralize depth-key generation and make debug labels visible before adding many authored props. The second risk is Tiled metadata drift. Keep a versioned Tiled class/profile schema and validate maps at load time so content mistakes fail early instead of becoming invisible runtime bugs.
