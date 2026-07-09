# Bullet-Hell Shmup

## Design target

A technical game design document for a marketable 2D Bullet-Hell Shmup built with Lurek2D. The design target is pattern density, boss scripting, hitbox fairness, and replay scoring, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Bullet-Hell Shmup should be positioned as a focused shooters entry about pattern density, boss scripting, hitbox fairness, and replay scoring. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Stage rendering | `lurek.render`, `lurek.parallax`, `lurek.camera` | For Bullet-Hell Shmup, this area covers stage rendering from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for layered scrolling backgrounds and depth cues. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Bullet patterns | `lurek.math`, `lurek.patterns`, `lurek.particle` | For Bullet-Hell Shmup, this area covers bullet patterns from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Actors and collision | `lurek.ecs`, `lurek.physics` | For Bullet-Hell Shmup, this area covers actors and collision from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| Boss scripting | `lurek.ai`, `lurek.tween`, `lurek.event` | For Bullet-Hell Shmup, this area covers boss scripting from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for inspectable decision scoring and scheduled planners. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Effects/audio | `lurek.audio`, `lurek.effect`, `lurek.animation` | For Bullet-Hell Shmup, this area covers effects/audio from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Score/replay | `lurek.save`, `lurek.serialize`, `lurek.log` | For Bullet-Hell Shmup, this area covers score/replay from the current design; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Projectiles, hit checks, and combat space | `lurek.physics`, `lurek.ecs`, `lurek.math` | For Bullet-Hell Shmup, this area covers tracking actors and bullets with stable IDs while collision and range checks stay deterministic; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Enemy decisions and perception | `lurek.ai`, `lurek.awareness`, `lurek.timer` | For Bullet-Hell Shmup, this area covers scheduling target selection, threat response, cooldowns, patrols, and firing windows; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for inspectable decision scoring and scheduled planners. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| Combat readability | `lurek.camera`, `lurek.particle`, `lurek.audio`, `lurek.effect` | For Bullet-Hell Shmup, this area covers making impacts, recoil, warnings, and damage feedback visible without changing combat rules; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Scene ownership and mode boundaries | `lurek.scene` | For Bullet-Hell Shmup, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Bullet-Hell Shmup, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Bullet-Hell Shmup, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Bullet-Hell Shmup, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Bullet-Hell Shmup, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Bullet-Hell Shmup, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Bullet-Hell Shmup, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Bullet-Hell Shmup, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Bullet-Hell Shmup, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support pattern density, boss scripting, hitbox fairness, and replay scoring. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Bullet-Hell Shmup state should center on pattern density, boss scripting, hitbox fairness, and replay scoring. Treat player as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Bullet-Hell Shmup state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for bullet-hell shmup previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Bullet-Hell Shmup into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where player, bullets, emitters, bosses, pickups, phases, score events, and replays need stable identity across several systems. Single-purpose values can stay in domain tables, but any bullet-hell shmup object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Bullet-Hell Shmup is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/bullet_hell_shmup/main.lua` - owns bullet-hell shmup callback handoff and startup wiring.
- `content/games/bullet_hell_shmup/conf.toml` - owns bullet-hell shmup window, input, asset, and runtime defaults.
- `content/games/bullet_hell_shmup/data/bullet_hell_shmup_rules.toml` - owns bullet-hell shmup authored rules for pattern density, boss scripting, hitbox fairness, and replay scoring.
- `content/games/bullet_hell_shmup/data/player.toml` - owns bullet-hell shmup content records for player.
- `content/games/bullet_hell_shmup/scripts/scenes/bullet_hell_shmup_play.lua` - owns bullet-hell shmup scene-local orchestration and pause/result transitions.
- `content/games/bullet_hell_shmup/scripts/systems/bullet_hell_shmup_state.lua` - owns bullet-hell shmup authoritative state containers and domain update order.
- `content/games/bullet_hell_shmup/scripts/systems/bullet_hell_shmup_validation.lua` - owns bullet-hell shmup data integrity checks before content enters a run.
- `content/games/bullet_hell_shmup/scripts/ui/bullet_hell_shmup_hud.lua` - owns bullet-hell shmup HUD, inspector, prompt, and accessibility surfaces.
- `content/games/bullet_hell_shmup/assets/bullet_hell_shmup/` - owns bullet-hell shmup media grouped by stable asset IDs.

## Game structure

Bullet-Hell Shmup should be built as a set of named domain services rather than one large gameplay script.

- `bullet_hell_shmup_state` owns durable player, bullets, and emitters records.
- `bullet_hell_shmup_rules` validates commands, applies pattern density, boss scripting, hitbox fairness, and replay scoring, and emits deterministic events.
- `bullet_hell_shmup_content` loads tables, checks IDs, and reports missing media before play starts.
- `bullet_hell_shmup_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `bullet_hell_shmup_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `bullet_hell_shmup_debug` exposes bosses, pickups, and phases in overlays without mutating shipped state.

## Data and content model

- `player_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `player_table` data should live in `data/` and be validated before Bullet-Hell Shmup enters active play.
- `bullets_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `bullets_table` data should live in `data/` and be validated before Bullet-Hell Shmup enters active play.
- `emitters_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `emitters_table` data should live in `data/` and be validated before Bullet-Hell Shmup enters active play.
- Bullet-Hell Shmup save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Bullet-Hell Shmup content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate bullet-hell shmup setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for player, bullets, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for pattern density, boss scripting, hitbox fairness, and replay scoring; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Bullet-Hell Shmup tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one scrolling stage, three enemy waves, one boss with two phases, bullet pool, graze scoring, bomb/clear mechanic, score save, and deterministic replay seed.

## Risks

The risk is treating bullets as rich objects. Keep bullet data compact, avoid allocations during patterns, and make pattern scripts declarative enough to debug frame-by-frame.
