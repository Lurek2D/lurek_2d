# Tactical Cover Shooter

## Design target

A technical game design document for a marketable 2D Tactical Cover Shooter built with Lurek2D. The design target is cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Tactical Cover Shooter should be positioned as a focused shooters entry about cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Map and cover | `lurek.tilemap`, `lurek.tilefield`, `lurek.light` | For Tactical Cover Shooter, this area covers map and cover from the current design; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for render-facing lighting, occlusion tone, darkness readability, and reveal mood. |
| Actors/weapons | `lurek.ecs`, `lurek.physics`, `lurek.animation` | For Tactical Cover Shooter, this area covers actors/weapons from the current design; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| LOS and navigation | `lurek.pathfind`, `lurek.math`, `lurek.awareness` | For Tactical Cover Shooter, this area covers los and navigation from the current design; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. |
| AI squads | `lurek.ai` | For Tactical Cover Shooter, this area covers ai squads from the current design; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for inspectable decision scoring and scheduled planners. |
| UI feedback | `lurek.ui`, `lurek.render`, `lurek.audio`, `lurek.effect` | For Tactical Cover Shooter, this area covers ui feedback from the current design; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Projectiles, hit checks, and combat space | `lurek.physics`, `lurek.ecs`, `lurek.math` | For Tactical Cover Shooter, this area covers tracking actors and bullets with stable IDs while collision and range checks stay deterministic; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. |
| Enemy decisions and perception | `lurek.ai`, `lurek.awareness`, `lurek.timer` | For Tactical Cover Shooter, this area covers scheduling target selection, threat response, cooldowns, patrols, and firing windows; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for inspectable decision scoring and scheduled planners. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| Combat readability | `lurek.camera`, `lurek.particle`, `lurek.audio`, `lurek.effect` | For Tactical Cover Shooter, this area covers making impacts, recoil, warnings, and damage feedback visible without changing combat rules; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Scene ownership and mode boundaries | `lurek.scene` | For Tactical Cover Shooter, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Tactical Cover Shooter, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Tactical Cover Shooter, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Tactical Cover Shooter, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Tactical Cover Shooter, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Tactical Cover Shooter, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Tactical Cover Shooter, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Tactical Cover Shooter, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Tactical Cover Shooter, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Tactical Cover Shooter state should center on cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs. Treat soldiers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Tactical Cover Shooter state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for tactical cover shooter previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Tactical Cover Shooter into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where soldiers, cover nodes, weapons, projectiles, vision cones, squads, and objectives need stable identity across several systems. Single-purpose values can stay in domain tables, but any tactical cover shooter object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Tactical Cover Shooter is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/tactical_cover_shooter/main.lua` - owns tactical cover shooter callback handoff and startup wiring.
- `content/games/tactical_cover_shooter/conf.toml` - owns tactical cover shooter window, input, asset, and runtime defaults.
- `content/games/tactical_cover_shooter/data/tactical_cover_shooter_rules.toml` - owns tactical cover shooter authored rules for cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs.
- `content/games/tactical_cover_shooter/data/soldiers.toml` - owns tactical cover shooter content records for soldiers.
- `content/games/tactical_cover_shooter/scripts/scenes/tactical_cover_shooter_play.lua` - owns tactical cover shooter scene-local orchestration and pause/result transitions.
- `content/games/tactical_cover_shooter/scripts/systems/tactical_cover_shooter_state.lua` - owns tactical cover shooter authoritative state containers and domain update order.
- `content/games/tactical_cover_shooter/scripts/systems/tactical_cover_shooter_validation.lua` - owns tactical cover shooter data integrity checks before content enters a run.
- `content/games/tactical_cover_shooter/scripts/ui/tactical_cover_shooter_hud.lua` - owns tactical cover shooter HUD, inspector, prompt, and accessibility surfaces.
- `content/games/tactical_cover_shooter/assets/tactical_cover_shooter/` - owns tactical cover shooter media grouped by stable asset IDs.

## Game structure

Tactical Cover Shooter should be built as a set of named domain services rather than one large gameplay script.

- `tactical_cover_shooter_state` owns durable soldiers, cover nodes, and weapons records.
- `tactical_cover_shooter_rules` validates commands, applies cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs, and emits deterministic events.
- `tactical_cover_shooter_content` loads tables, checks IDs, and reports missing media before play starts.
- `tactical_cover_shooter_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `tactical_cover_shooter_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `tactical_cover_shooter_debug` exposes projectiles, vision cones, and squads in overlays without mutating shipped state.

## Data and content model

- `soldiers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `soldiers_table` data should live in `data/` and be validated before Tactical Cover Shooter enters active play.
- `cover_nodes_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `cover_nodes_table` data should live in `data/` and be validated before Tactical Cover Shooter enters active play.
- `weapons_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `weapons_table` data should live in `data/` and be validated before Tactical Cover Shooter enters active play.
- Tactical Cover Shooter save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Tactical Cover Shooter content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate tactical cover shooter setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for soldiers, cover nodes, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for cover decisions, line-of-sight, suppression, squad AI, and readable weapon arcs; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Tactical Cover Shooter tests can run without presentation timing.

## Vertical slice acceptance

One level should include cover nodes, two weapons, reloads, suppression, three enemy roles, flank AI, destructible prop, objective room, and combat log.

## Risks

The main risk is invisible modifiers. Show cover state, suppression, reload, and line-of-fire previews clearly. Tactical shooters need explainability as much as fast reactions.
