# Action Roguelite

## Design target

A technical game design document for a marketable 2D Action Roguelite built with Lurek2D. The design target is run pressure, build variety, enemy density, and seed reproducibility, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Action Roguelite should be positioned as a focused roguelikes entry about run pressure, build variety, enemy density, and seed reproducibility. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Room graph generation | `lurek.procgen`, `lurek.scene`, `lurek.tilemap` | For Action Roguelite, this area covers room graph generation from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for seeded layouts and generated content that must be reproducible from run data. Use it to decide which systems are active and which state may change in each screen. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. |
| Combat actors | `lurek.ecs`, `lurek.physics`, `lurek.animation` | For Action Roguelite, this area covers combat actors from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Enemy and boss AI | `lurek.ai`, `lurek.pathfind`, `lurek.patterns` | For Action Roguelite, this area covers enemy and boss ai from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for inspectable decision scoring and scheduled planners. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for state machines, rule phases, command patterns, and undoable transition models. |
| Upgrades and items | `lurek.dataframe`, `lurek.serialize` | For Action Roguelite, this area covers upgrades and items from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Effects and juice | `lurek.particle`, `lurek.audio`, `lurek.effect`, `lurek.tween` | For Action Roguelite, this area covers effects and juice from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Persistence | `lurek.save` | For Action Roguelite, this area covers persistence from the current design; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Seeds, layouts, and run records | `lurek.procgen`, `lurek.tilefield`, `lurek.save` | For Action Roguelite, this area covers generating reproducible rooms, keeping cell facts queryable, and persisting run summaries or unlocks; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for seeded layouts and generated content that must be reproducible from run data. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| AI, awareness, and turn pressure | `lurek.ai`, `lurek.awareness`, `lurek.timer` | For Action Roguelite, this area covers scheduling enemy decisions, field-of-view checks, stealth, cooldowns, or turn phases; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for inspectable decision scoring and scheduled planners. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| Inventory, logs, and readable outcomes | `lurek.ui`, `lurek.terminal`, `lurek.log` | For Action Roguelite, this area covers making item identity, combat messages, and debug evidence inspectable; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for text-grid display, log-heavy screens, or terminal-style roguelike UI. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Scene ownership and mode boundaries | `lurek.scene` | For Action Roguelite, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Action Roguelite, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Action Roguelite, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Action Roguelite, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Action Roguelite, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Action Roguelite, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Action Roguelite, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Action Roguelite, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Action Roguelite, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support run pressure, build variety, enemy density, and seed reproducibility. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Action Roguelite state should center on run pressure, build variety, enemy density, and seed reproducibility. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Action Roguelite state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for action roguelite previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Action Roguelite into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, enemies, pickups, projectiles, rooms, run modifiers, and reward choices need stable identity across several systems. Single-purpose values can stay in domain tables, but any action roguelite object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Action Roguelite is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/action_roguelite/main.lua` - owns action roguelite callback handoff and startup wiring.
- `content/games/action_roguelite/conf.toml` - owns action roguelite window, input, asset, and runtime defaults.
- `content/games/action_roguelite/data/action_roguelite_rules.toml` - owns action roguelite authored rules for run pressure, build variety, enemy density, and seed reproducibility.
- `content/games/action_roguelite/data/player.toml` - owns action roguelite content records for player.
- `content/games/action_roguelite/scripts/scenes/action_roguelite_play.lua` - owns action roguelite scene-local orchestration and pause/result transitions.
- `content/games/action_roguelite/scripts/systems/action_roguelite_state.lua` - owns action roguelite authoritative state containers and domain update order.
- `content/games/action_roguelite/scripts/systems/action_roguelite_validation.lua` - owns action roguelite data integrity checks before content enters a run.
- `content/games/action_roguelite/scripts/ui/action_roguelite_hud.lua` - owns action roguelite HUD, inspector, prompt, and accessibility surfaces.
- `content/games/action_roguelite/assets/action_roguelite/` - owns action roguelite media grouped by stable asset IDs.

## Game structure

Action Roguelite should be built as a set of named domain services rather than one large gameplay script.

- `action_roguelite_state` owns durable player, enemies, and pickups records.
- `action_roguelite_rules` validates commands, applies run pressure, build variety, enemy density, and seed reproducibility, and emits deterministic events.
- `action_roguelite_content` loads tables, checks IDs, and reports missing media before play starts.
- `action_roguelite_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `action_roguelite_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `action_roguelite_debug` exposes projectiles, rooms, and run modifiers in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Action Roguelite enters active play.
- `enemies_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `enemies_table` data should live in `data/` and be validated before Action Roguelite enters active play.
- `pickups_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `pickups_table` data should live in `data/` and be validated before Action Roguelite enters active play.
- Action Roguelite save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Action Roguelite content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate action roguelite setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, enemies, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for run pressure, build variety, enemy density, and seed reproducibility; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Action Roguelite tests can run without presentation timing.

## Vertical slice acceptance

The slice should include seeded room chain, three enemy types, one boss, ten upgrades, reward selection, death/restart loop, meta unlock flag, and run summary.

## Risks

The main risk is upgrade combinatorics. Use declarative modifiers and central conflict rules before adding many items. Every item should explain which events or stats it changes.
