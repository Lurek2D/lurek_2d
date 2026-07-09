# Farming Cozy Survival

## Design target

A technical game design document for a marketable 2D Farming Cozy Survival built with Lurek2D. The design target is farm routines, calendar pressure, NPC schedules, crafting, and gentle risk, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Farming Cozy Survival should be positioned as a focused survival crafting entry about farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Farm/town maps | `lurek.tilemap`, `lurek.scene`, `lurek.camera` | For Farming Cozy Survival, this area covers farm/town maps from the current design; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to decide which systems are active and which state may change in each screen. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Crops/items/crafting | `lurek.ecs` | For Farming Cozy Survival, this area covers crops/items/crafting from the current design; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Calendar/weather | `lurek.timer`, `lurek.event`, `lurek.save` | For Farming Cozy Survival, this area covers calendar/weather from the current design; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| NPCs | `lurek.dialog`, `lurek.ai`, `lurek.pathfind` | For Farming Cozy Survival, this area covers npcs from the current design; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Cozy feedback | `lurek.audio`, `lurek.particle`, `lurek.tween`, `lurek.ui` | For Farming Cozy Survival, this area covers cozy feedback from the current design; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Resource loops and world chunks | `lurek.tilefield`, `lurek.procgen`, `lurek.save` | For Farming Cozy Survival, this area covers tracking harvestable cells, generated areas, shelter state, and long-term progression; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Threats, needs, and schedules | `lurek.ai`, `lurek.timer`, `lurek.ecs` | For Farming Cozy Survival, this area covers coordinating creatures, weather, hunger, crafting stations, repairs, waves, or daily routines; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for inspectable decision scoring and scheduled planners. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Crafting and inventory UI | `lurek.dataframe`, `lurek.ui`, `lurek.log` | For Farming Cozy Survival, this area covers validating recipes, showing requirements, and reporting missing resources or impossible tasks; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Farming Cozy Survival, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Farming Cozy Survival, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Farming Cozy Survival, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Farming Cozy Survival, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Farming Cozy Survival, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Farming Cozy Survival, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Farming Cozy Survival, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Farming Cozy Survival, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Farming Cozy Survival, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Farming Cozy Survival state should center on farm routines, calendar pressure, NPC schedules, crafting, and gentle risk. Treat crops as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Farming Cozy Survival state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for farming cozy survival previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Farming Cozy Survival into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where crops, animals, tools, villagers, recipes, seasons, and relationship events need stable identity across several systems. Single-purpose values can stay in domain tables, but any farming cozy survival object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Farming Cozy Survival is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/farming_cozy_survival/main.lua` - owns farming cozy survival callback handoff and startup wiring.
- `content/games/farming_cozy_survival/conf.toml` - owns farming cozy survival window, input, asset, and runtime defaults.
- `content/games/farming_cozy_survival/data/farming_cozy_survival_rules.toml` - owns farming cozy survival authored rules for farm routines, calendar pressure, NPC schedules, crafting, and gentle risk.
- `content/games/farming_cozy_survival/data/crops.toml` - owns farming cozy survival content records for crops.
- `content/games/farming_cozy_survival/scripts/scenes/farming_cozy_survival_play.lua` - owns farming cozy survival scene-local orchestration and pause/result transitions.
- `content/games/farming_cozy_survival/scripts/systems/farming_cozy_survival_state.lua` - owns farming cozy survival authoritative state containers and domain update order.
- `content/games/farming_cozy_survival/scripts/systems/farming_cozy_survival_validation.lua` - owns farming cozy survival data integrity checks before content enters a run.
- `content/games/farming_cozy_survival/scripts/ui/farming_cozy_survival_hud.lua` - owns farming cozy survival HUD, inspector, prompt, and accessibility surfaces.
- `content/games/farming_cozy_survival/assets/farming_cozy_survival/` - owns farming cozy survival media grouped by stable asset IDs.

## Game structure

Farming Cozy Survival should be built as a set of named domain services rather than one large gameplay script.

- `farming_cozy_survival_state` owns durable crops, animals, and tools records.
- `farming_cozy_survival_rules` validates commands, applies farm routines, calendar pressure, NPC schedules, crafting, and gentle risk, and emits deterministic events.
- `farming_cozy_survival_content` loads tables, checks IDs, and reports missing media before play starts.
- `farming_cozy_survival_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `farming_cozy_survival_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `farming_cozy_survival_debug` exposes villagers, recipes, and seasons in overlays without mutating shipped state.

## Data and content model

- `crops_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `crops_table` data should live in `data/` and be validated before Farming Cozy Survival enters active play.
- `animals_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `animals_table` data should live in `data/` and be validated before Farming Cozy Survival enters active play.
- `tools_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `tools_table` data should live in `data/` and be validated before Farming Cozy Survival enters active play.
- Farming Cozy Survival save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Farming Cozy Survival content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate farming cozy survival setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for crops, animals, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for farm routines, calendar pressure, NPC schedules, crafting, and gentle risk; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Farming Cozy Survival tests can run without presentation timing.

## Vertical slice acceptance

One vertical slice should support one farm map, one town map, two crops, one crafting station, three NPCs, gift reaction, day-end save, shop purchase, and seasonal day rollover.

## Risks

The risk is routine without feedback. Every daily action should produce clear audio, animation, UI confirmation, and long-term progression so repetition feels intentional.
