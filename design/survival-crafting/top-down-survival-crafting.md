# Top-Down Survival Crafting

## Design target

A technical game design document for a marketable 2D Top-Down Survival Crafting built with Lurek2D. The design target is resource gathering, crafting stations, shelter state, threats, and world chunks, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Top-Down Survival Crafting should be positioned as a focused survival crafting entry about resource gathering, crafting stations, shelter state, threats, and world chunks. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| World map and biomes | `lurek.tilemap`, `lurek.tilefield`, `lurek.procgen` | For Top-Down Survival Crafting, this area covers world map and biomes from the current design; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for seeded layouts and generated content that must be reproducible from run data. |
| Player/items/entities | `lurek.ecs` | For Top-Down Survival Crafting, this area covers player/items/entities from the current design; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Wildlife/enemies | `lurek.ai`, `lurek.pathfind`, `lurek.awareness` | For Top-Down Survival Crafting, this area covers wildlife/enemies from the current design; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| Environment systems | `lurek.timer`, `lurek.light`, `lurek.audio`, `lurek.particle` | For Top-Down Survival Crafting, this area covers environment systems from the current design; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| UI and persistence | `lurek.ui`, `lurek.save`, `lurek.serialize` | For Top-Down Survival Crafting, this area covers ui and persistence from the current design; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Resource loops and world chunks | `lurek.tilefield`, `lurek.procgen`, `lurek.save` | For Top-Down Survival Crafting, this area covers tracking harvestable cells, generated areas, shelter state, and long-term progression; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Threats, needs, and schedules | `lurek.ai`, `lurek.timer`, `lurek.ecs` | For Top-Down Survival Crafting, this area covers coordinating creatures, weather, hunger, crafting stations, repairs, waves, or daily routines; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for inspectable decision scoring and scheduled planners. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. |
| Crafting and inventory UI | `lurek.dataframe`, `lurek.ui`, `lurek.log` | For Top-Down Survival Crafting, this area covers validating recipes, showing requirements, and reporting missing resources or impossible tasks; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Top-Down Survival Crafting, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Top-Down Survival Crafting, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Top-Down Survival Crafting, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Top-Down Survival Crafting, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Top-Down Survival Crafting, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Top-Down Survival Crafting, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Top-Down Survival Crafting, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Top-Down Survival Crafting, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Top-Down Survival Crafting, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support resource gathering, crafting stations, shelter state, threats, and world chunks. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Top-Down Survival Crafting state should center on resource gathering, crafting stations, shelter state, threats, and world chunks. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Top-Down Survival Crafting state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for top-down survival crafting previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Top-Down Survival Crafting into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, resources, stations, creatures, chunks, recipes, weather, and inventory need stable identity across several systems. Single-purpose values can stay in domain tables, but any top-down survival crafting object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Top-Down Survival Crafting is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/top_down_survival_crafting/main.lua` - owns top-down survival crafting callback handoff and startup wiring.
- `content/games/top_down_survival_crafting/conf.toml` - owns top-down survival crafting window, input, asset, and runtime defaults.
- `content/games/top_down_survival_crafting/data/top_down_survival_crafting_rules.toml` - owns top-down survival crafting authored rules for resource gathering, crafting stations, shelter state, threats, and world chunks.
- `content/games/top_down_survival_crafting/data/player.toml` - owns top-down survival crafting content records for player.
- `content/games/top_down_survival_crafting/scripts/scenes/top_down_survival_crafting_play.lua` - owns top-down survival crafting scene-local orchestration and pause/result transitions.
- `content/games/top_down_survival_crafting/scripts/systems/top_down_survival_crafting_state.lua` - owns top-down survival crafting authoritative state containers and domain update order.
- `content/games/top_down_survival_crafting/scripts/systems/top_down_survival_crafting_validation.lua` - owns top-down survival crafting data integrity checks before content enters a run.
- `content/games/top_down_survival_crafting/scripts/ui/top_down_survival_crafting_hud.lua` - owns top-down survival crafting HUD, inspector, prompt, and accessibility surfaces.
- `content/games/top_down_survival_crafting/assets/top_down_survival_crafting/` - owns top-down survival crafting media grouped by stable asset IDs.

## Game structure

Top-Down Survival Crafting should be built as a set of named domain services rather than one large gameplay script.

- `top_down_survival_crafting_state` owns durable player, resources, and stations records.
- `top_down_survival_crafting_rules` validates commands, applies resource gathering, crafting stations, shelter state, threats, and world chunks, and emits deterministic events.
- `top_down_survival_crafting_content` loads tables, checks IDs, and reports missing media before play starts.
- `top_down_survival_crafting_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `top_down_survival_crafting_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `top_down_survival_crafting_debug` exposes creatures, chunks, and recipes in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Top-Down Survival Crafting enters active play.
- `resources_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `resources_table` data should live in `data/` and be validated before Top-Down Survival Crafting enters active play.
- `stations_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `stations_table` data should live in `data/` and be validated before Top-Down Survival Crafting enters active play.
- Top-Down Survival Crafting save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Top-Down Survival Crafting content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate top-down survival crafting setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, resources, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for resource gathering, crafting stations, shelter state, threats, and world chunks; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Top-Down Survival Crafting tests can run without presentation timing.

## Vertical slice acceptance

The slice should include generated biome area, gatherable resources, hunger and health, tool crafting, campfire placement, day/night, one hostile creature, inventory UI, death/restart, and save/load.

## Risks

The risk is infinite-world ambition. Build a small persistent chunk model first and validate save size, chunk regeneration, and authored progression before expanding world scale.
