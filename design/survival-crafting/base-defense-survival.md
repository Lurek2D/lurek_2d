# Base Defense Survival

## Design target

A technical game design document for a marketable 2D Base Defense Survival built with Lurek2D. The design target is build placement, wave direction, resource triage, and base readability, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Base Defense Survival should be positioned as a focused survival crafting entry about build placement, wave direction, resource triage, and base readability. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Buildable map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera` | For Base Defense Survival, this area covers buildable map from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Structures and enemies | `lurek.ecs`, `lurek.physics`, `lurek.animation` | For Base Defense Survival, this area covers structures and enemies from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Enemy routing | `lurek.pathfind` | For Base Defense Survival, this area covers enemy routing from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Wave director | `lurek.ai`, `lurek.timer`, `lurek.event` | For Base Defense Survival, this area covers wave director from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for inspectable decision scoring and scheduled planners. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Feedback/UI | `lurek.ui`, `lurek.render`, `lurek.audio`, `lurek.particle` | For Base Defense Survival, this area covers feedback/ui from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Persistence | `lurek.save` | For Base Defense Survival, this area covers persistence from the current design; it should support build placement, wave direction, resource triage, and base readability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Resource loops and world chunks | `lurek.tilefield`, `lurek.procgen`, `lurek.save` | For Base Defense Survival, this area covers tracking harvestable cells, generated areas, shelter state, and long-term progression; it should support build placement, wave direction, resource triage, and base readability. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Threats, needs, and schedules | `lurek.ai`, `lurek.timer`, `lurek.ecs` | For Base Defense Survival, this area covers coordinating creatures, weather, hunger, crafting stations, repairs, waves, or daily routines; it should support build placement, wave direction, resource triage, and base readability. Use it for inspectable decision scoring and scheduled planners. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Crafting and inventory UI | `lurek.dataframe`, `lurek.ui`, `lurek.log` | For Base Defense Survival, this area covers validating recipes, showing requirements, and reporting missing resources or impossible tasks; it should support build placement, wave direction, resource triage, and base readability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Base Defense Survival, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support build placement, wave direction, resource triage, and base readability. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Base Defense Survival, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support build placement, wave direction, resource triage, and base readability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Base Defense Survival, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support build placement, wave direction, resource triage, and base readability. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Base Defense Survival, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support build placement, wave direction, resource triage, and base readability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Base Defense Survival, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support build placement, wave direction, resource triage, and base readability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Base Defense Survival, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support build placement, wave direction, resource triage, and base readability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Base Defense Survival, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support build placement, wave direction, resource triage, and base readability. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Base Defense Survival, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support build placement, wave direction, resource triage, and base readability. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Base Defense Survival, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support build placement, wave direction, resource triage, and base readability. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Base Defense Survival state should center on build placement, wave direction, resource triage, and base readability. Treat walls as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Base Defense Survival state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for base defense survival previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Base Defense Survival into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where walls, turrets, enemies, waves, resources, repair tasks, and alerts need stable identity across several systems. Single-purpose values can stay in domain tables, but any base defense survival object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Base Defense Survival is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/base_defense_survival/main.lua` - owns base defense survival callback handoff and startup wiring.
- `content/games/base_defense_survival/conf.toml` - owns base defense survival window, input, asset, and runtime defaults.
- `content/games/base_defense_survival/data/base_defense_survival_rules.toml` - owns base defense survival authored rules for build placement, wave direction, resource triage, and base readability.
- `content/games/base_defense_survival/data/walls.toml` - owns base defense survival content records for walls.
- `content/games/base_defense_survival/scripts/scenes/base_defense_survival_play.lua` - owns base defense survival scene-local orchestration and pause/result transitions.
- `content/games/base_defense_survival/scripts/systems/base_defense_survival_state.lua` - owns base defense survival authoritative state containers and domain update order.
- `content/games/base_defense_survival/scripts/systems/base_defense_survival_validation.lua` - owns base defense survival data integrity checks before content enters a run.
- `content/games/base_defense_survival/scripts/ui/base_defense_survival_hud.lua` - owns base defense survival HUD, inspector, prompt, and accessibility surfaces.
- `content/games/base_defense_survival/assets/base_defense_survival/` - owns base defense survival media grouped by stable asset IDs.

## Game structure

Base Defense Survival should be built as a set of named domain services rather than one large gameplay script.

- `base_defense_survival_state` owns durable walls, turrets, and enemies records.
- `base_defense_survival_rules` validates commands, applies build placement, wave direction, resource triage, and base readability, and emits deterministic events.
- `base_defense_survival_content` loads tables, checks IDs, and reports missing media before play starts.
- `base_defense_survival_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `base_defense_survival_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `base_defense_survival_debug` exposes waves, resources, and repair tasks in overlays without mutating shipped state.

## Data and content model

- `walls_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `walls_table` data should live in `data/` and be validated before Base Defense Survival enters active play.
- `turrets_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `turrets_table` data should live in `data/` and be validated before Base Defense Survival enters active play.
- `enemies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `enemies_table` data should live in `data/` and be validated before Base Defense Survival enters active play.
- Base Defense Survival save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Base Defense Survival content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate base defense survival setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for walls, turrets, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for build placement, wave direction, resource triage, and base readability; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Base Defense Survival tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one map, two resource types, three structures, three enemy types, five waves, repair, upgrade, route preview, defeat condition, and save/load between waves.

## Risks

The risk is path exploit ambiguity. Decide early whether maze-building is a feature. The path system and UI must explain blocked routes, breach choices, and enemy priorities.
