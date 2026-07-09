# Party-Based CRPG

## Design target

A technical game design document for a marketable 2D Party-Based CRPG built with Lurek2D. The design target is party state, dialogue consequences, tactical encounters, and inventory depth, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Party-Based CRPG should be positioned as a focused role playing games entry about party state, dialogue consequences, tactical encounters, and inventory depth. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Exploration maps | `lurek.tilemap`, `lurek.camera`, `lurek.scene` | For Party-Based CRPG, this area covers exploration maps from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it to decide which systems are active and which state may change in each screen. |
| Party and NPCs | `lurek.ecs`, `lurek.pathfind`, `lurek.ai` | For Party-Based CRPG, this area covers party and npcs from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. |
| Dialogue and quests | `lurek.dialog`, `lurek.event` | For Party-Based CRPG, this area covers dialogue and quests from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Inventory/stats | `lurek.serialize` | For Party-Based CRPG, this area covers inventory/stats from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| UI-heavy screens | `lurek.ui`, `lurek.render`, `lurek.i18n` | For Party-Based CRPG, this area covers ui-heavy screens from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Persistence | `lurek.save` | For Party-Based CRPG, this area covers persistence from the current design; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Quests, party entities, and world state | `lurek.ecs`, `lurek.dialog`, `lurek.save` | For Party-Based CRPG, this area covers binding actors, quests, dialogue flags, inventory, and progression to stable IDs; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Maps, navigation, and encounters | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Party-Based CRPG, this area covers keeping visual maps separate from blockers, triggers, encounter regions, and reachable destinations; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Stats, items, and authored tables | `lurek.dataframe`, `lurek.serialize`, `lurek.ui` | For Party-Based CRPG, this area covers validating skills, equipment, rewards, and status descriptions before runtime use; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Party-Based CRPG, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Party-Based CRPG, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Party-Based CRPG, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Party-Based CRPG, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Party-Based CRPG, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Party-Based CRPG, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Party-Based CRPG, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Party-Based CRPG, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Party-Based CRPG, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support party state, dialogue consequences, tactical encounters, and inventory depth. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Party-Based CRPG state should center on party state, dialogue consequences, tactical encounters, and inventory depth. Treat party members as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Party-Based CRPG state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for party-based crpg previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Party-Based CRPG into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where party members, NPCs, abilities, inventory, quests, areas, and combatants need stable identity across several systems. Single-purpose values can stay in domain tables, but any party-based crpg object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Party-Based CRPG is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/party_based_crpg/main.lua` - owns party-based crpg callback handoff and startup wiring.
- `content/games/party_based_crpg/conf.toml` - owns party-based crpg window, input, asset, and runtime defaults.
- `content/games/party_based_crpg/data/party_based_crpg_rules.toml` - owns party-based crpg authored rules for party state, dialogue consequences, tactical encounters, and inventory depth.
- `content/games/party_based_crpg/data/party_members.toml` - owns party-based crpg content records for party members.
- `content/games/party_based_crpg/scripts/scenes/party_based_crpg_play.lua` - owns party-based crpg scene-local orchestration and pause/result transitions.
- `content/games/party_based_crpg/scripts/systems/party_based_crpg_state.lua` - owns party-based crpg authoritative state containers and domain update order.
- `content/games/party_based_crpg/scripts/systems/party_based_crpg_validation.lua` - owns party-based crpg data integrity checks before content enters a run.
- `content/games/party_based_crpg/scripts/ui/party_based_crpg_hud.lua` - owns party-based crpg HUD, inspector, prompt, and accessibility surfaces.
- `content/games/party_based_crpg/assets/party_based_crpg/` - owns party-based crpg media grouped by stable asset IDs.

## Game structure

Party-Based CRPG should be built as a set of named domain services rather than one large gameplay script.

- `party_based_crpg_state` owns durable party members, NPCs, and abilities records.
- `party_based_crpg_rules` validates commands, applies party state, dialogue consequences, tactical encounters, and inventory depth, and emits deterministic events.
- `party_based_crpg_content` loads tables, checks IDs, and reports missing media before play starts.
- `party_based_crpg_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `party_based_crpg_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `party_based_crpg_debug` exposes inventory, quests, and areas in overlays without mutating shipped state.

## Data and content model

- `party_members_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `party_members_table` data should live in `data/` and be validated before Party-Based CRPG enters active play.
- `NPCs_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `NPCs_table` data should live in `data/` and be validated before Party-Based CRPG enters active play.
- `abilities_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `abilities_table` data should live in `data/` and be validated before Party-Based CRPG enters active play.
- Party-Based CRPG save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Party-Based CRPG content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate party-based crpg setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for party members, NPCs, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for party state, dialogue consequences, tactical encounters, and inventory depth; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Party-Based CRPG tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one town area, one dungeon room, two companions, branching dialogue, one quest with two outcomes, inventory equip flow, one combat encounter, and consequence saved across reload.

## Risks

The largest risk is narrative flag sprawl. Use named flags, event logs, and validation that every dialogue condition references an existing state key.
