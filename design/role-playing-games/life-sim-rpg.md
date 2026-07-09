# Life Sim RPG

## Design target

A technical game design document for a marketable 2D Life Sim RPG built with Lurek2D. The design target is daily rhythm, relationships, jobs, exploration, and long-term character growth, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Life Sim RPG should be positioned as a focused role playing games entry about daily rhythm, relationships, jobs, exploration, and long-term character growth. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Town/farm maps | `lurek.tilemap`, `lurek.scene`, `lurek.camera` | For Life Sim RPG, this area covers town/farm maps from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to decide which systems are active and which state may change in each screen. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| NPCs and objects | `lurek.ecs`, `lurek.pathfind`, `lurek.ai` | For Life Sim RPG, this area covers npcs and objects from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. |
| Dialogue/relationships | `lurek.dialog` | For Life Sim RPG, this area covers dialogue/relationships from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. |
| Farming/crafting/economy | `lurek.dataframe` | For Life Sim RPG, this area covers farming/crafting/economy from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Time/calendar | `lurek.timer`, `lurek.event`, `lurek.save` | For Life Sim RPG, this area covers time/calendar from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| UI | `lurek.ui`, `lurek.render`, `lurek.i18n` | For Life Sim RPG, this area covers ui from the current design; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Quests, party entities, and world state | `lurek.ecs`, `lurek.dialog`, `lurek.save` | For Life Sim RPG, this area covers binding actors, quests, dialogue flags, inventory, and progression to stable IDs; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Maps, navigation, and encounters | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For Life Sim RPG, this area covers keeping visual maps separate from blockers, triggers, encounter regions, and reachable destinations; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Stats, items, and authored tables | `lurek.dataframe`, `lurek.serialize`, `lurek.ui` | For Life Sim RPG, this area covers validating skills, equipment, rewards, and status descriptions before runtime use; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For Life Sim RPG, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Life Sim RPG, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Life Sim RPG, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Life Sim RPG, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Life Sim RPG, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Life Sim RPG, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Life Sim RPG, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Life Sim RPG, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Life Sim RPG, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support daily rhythm, relationships, jobs, exploration, and long-term character growth. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Life Sim RPG state should center on daily rhythm, relationships, jobs, exploration, and long-term character growth. Treat residents as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Life Sim RPG state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for life sim rpg previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Life Sim RPG into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where residents, calendar entries, tasks, locations, gifts, skills, and relationship flags need stable identity across several systems. Single-purpose values can stay in domain tables, but any life sim rpg object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Life Sim RPG is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/life_sim_rpg/main.lua` - owns life sim rpg callback handoff and startup wiring.
- `content/games/life_sim_rpg/conf.toml` - owns life sim rpg window, input, asset, and runtime defaults.
- `content/games/life_sim_rpg/data/life_sim_rpg_rules.toml` - owns life sim rpg authored rules for daily rhythm, relationships, jobs, exploration, and long-term character growth.
- `content/games/life_sim_rpg/data/residents.toml` - owns life sim rpg content records for residents.
- `content/games/life_sim_rpg/scripts/scenes/life_sim_rpg_play.lua` - owns life sim rpg scene-local orchestration and pause/result transitions.
- `content/games/life_sim_rpg/scripts/systems/life_sim_rpg_state.lua` - owns life sim rpg authoritative state containers and domain update order.
- `content/games/life_sim_rpg/scripts/systems/life_sim_rpg_validation.lua` - owns life sim rpg data integrity checks before content enters a run.
- `content/games/life_sim_rpg/scripts/ui/life_sim_rpg_hud.lua` - owns life sim rpg HUD, inspector, prompt, and accessibility surfaces.
- `content/games/life_sim_rpg/assets/life_sim_rpg/` - owns life sim rpg media grouped by stable asset IDs.

## Game structure

Life Sim RPG should be built as a set of named domain services rather than one large gameplay script.

- `life_sim_rpg_state` owns durable residents, calendar entries, and tasks records.
- `life_sim_rpg_rules` validates commands, applies daily rhythm, relationships, jobs, exploration, and long-term character growth, and emits deterministic events.
- `life_sim_rpg_content` loads tables, checks IDs, and reports missing media before play starts.
- `life_sim_rpg_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `life_sim_rpg_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `life_sim_rpg_debug` exposes locations, gifts, and skills in overlays without mutating shipped state.

## Data and content model

- `residents_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `residents_table` data should live in `data/` and be validated before Life Sim RPG enters active play.
- `calendar_entries_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `calendar_entries_table` data should live in `data/` and be validated before Life Sim RPG enters active play.
- `tasks_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `tasks_table` data should live in `data/` and be validated before Life Sim RPG enters active play.
- Life Sim RPG save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Life Sim RPG content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate life sim rpg setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for residents, calendar entries, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for daily rhythm, relationships, jobs, exploration, and long-term character growth; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Life Sim RPG tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one playable day, farm plot, two crops, three NPCs with schedules, gift interaction, shop, one festival trigger, sleep/save flow, and next-day growth.

## Risks

The risk is time-dependent bugs. Make calendar transitions atomic and log daily rollovers. NPC schedules should be resolved from data every day rather than accumulated through fragile ad-hoc movement state.
