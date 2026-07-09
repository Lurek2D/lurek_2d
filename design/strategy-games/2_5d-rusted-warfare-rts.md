# 2.5D Classic RTS Design

## Design target

A technical game design document for a marketable 2D 2.5D Classic RTS Design built with Lurek2D. The design target is 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

2.5D Classic RTS Design should be positioned as a focused strategy games entry about 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Game flow | `lurek.scene`, `lurek.input`, `lurek.ui` | For 2.5D Classic RTS Design, this area covers game flow from the current design; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it to decide which systems are active and which state may change in each screen. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| World state | `lurek.ecs`, `lurek.tilemap`, `lurek.tilefield` | For 2.5D Classic RTS Design, this area covers world state from the current design; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Simulation | `lurek.pathfind`, `lurek.ai`, `lurek.physics` | For 2.5D Classic RTS Design, this area covers simulation from the current design; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| Data and persistence | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe`, `lurek.save` | For 2.5D Classic RTS Design, this area covers data and persistence from the current design; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Presentation | `lurek.render`, `lurek.camera`, `lurek.audio`, `lurek.animation`, `lurek.tween`, `lurek.particle` | For 2.5D Classic RTS Design, this area covers presentation from the current design; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Orders, formations, and navigation | `lurek.pathfind`, `lurek.graph`, `lurek.ai` | For 2.5D Classic RTS Design, this area covers querying routes, flows, adjacency, threat maps, and scheduled command decisions; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for inspectable decision scoring and scheduled planners. |
| Territory, fog, and map overlays | `lurek.province`, `lurek.awareness`, `lurek.minimap` | For 2.5D Classic RTS Design, this area covers tracking ownership, visibility, strategic regions, alerts, and overview commands; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Economy, production, and telemetry | `lurek.timer`, `lurek.dataframe`, `lurek.charts` | For 2.5D Classic RTS Design, this area covers driving build queues, resource ticks, balance tables, and debug economy reports; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Scene ownership and mode boundaries | `lurek.scene` | For 2.5D Classic RTS Design, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For 2.5D Classic RTS Design, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For 2.5D Classic RTS Design, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For 2.5D Classic RTS Design, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For 2.5D Classic RTS Design, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For 2.5D Classic RTS Design, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For 2.5D Classic RTS Design, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For 2.5D Classic RTS Design, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For 2.5D Classic RTS Design, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative 2.5D Classic RTS Design state should center on 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms. Treat units as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current 2.5D Classic RTS Design state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for 2.5d classic rts design previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split 2.5D Classic RTS Design into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where units, aircraft, projectiles, factories, resources, fog cells, and command groups need stable identity across several systems. Single-purpose values can stay in domain tables, but any 2.5d classic rts design object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for 2.5D Classic RTS Design is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/2_5d_rusted_warfare_rts/main.lua` - owns 2.5d classic rts design callback handoff and startup wiring.
- `content/games/2_5d_rusted_warfare_rts/conf.toml` - owns 2.5d classic rts design window, input, asset, and runtime defaults.
- `content/games/2_5d_rusted_warfare_rts/data/2_5d_rusted_warfare_rts_rules.toml` - owns 2.5d classic rts design authored rules for 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms.
- `content/games/2_5d_rusted_warfare_rts/data/units.toml` - owns 2.5d classic rts design content records for units.
- `content/games/2_5d_rusted_warfare_rts/scripts/scenes/2_5d_rusted_warfare_rts_play.lua` - owns 2.5d classic rts design scene-local orchestration and pause/result transitions.
- `content/games/2_5d_rusted_warfare_rts/scripts/systems/2_5d_rusted_warfare_rts_state.lua` - owns 2.5d classic rts design authoritative state containers and domain update order.
- `content/games/2_5d_rusted_warfare_rts/scripts/systems/2_5d_rusted_warfare_rts_validation.lua` - owns 2.5d classic rts design data integrity checks before content enters a run.
- `content/games/2_5d_rusted_warfare_rts/scripts/ui/2_5d_rusted_warfare_rts_hud.lua` - owns 2.5d classic rts design HUD, inspector, prompt, and accessibility surfaces.
- `content/games/2_5d_rusted_warfare_rts/assets/2_5d_rusted_warfare_rts/` - owns 2.5d classic rts design media grouped by stable asset IDs.

## Game structure

2.5D Classic RTS Design should be built as a set of named domain services rather than one large gameplay script.

- `2_5d_rusted_warfare_rts_state` owns durable units, aircraft, and projectiles records.
- `2_5d_rusted_warfare_rts_rules` validates commands, applies 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms, and emits deterministic events.
- `2_5d_rusted_warfare_rts_content` loads tables, checks IDs, and reports missing media before play starts.
- `2_5d_rusted_warfare_rts_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `2_5d_rusted_warfare_rts_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `2_5d_rusted_warfare_rts_debug` exposes factories, resources, and fog cells in overlays without mutating shipped state.

## Data and content model

- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before 2.5D Classic RTS Design enters active play.
- `aircraft_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `aircraft_table` data should live in `data/` and be validated before 2.5D Classic RTS Design enters active play.
- `projectiles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `projectiles_table` data should live in `data/` and be validated before 2.5D Classic RTS Design enters active play.
- 2.5D Classic RTS Design save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- 2.5D Classic RTS Design content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate 2.5d classic rts design setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for units, aircraft, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for 2D RTS control with altitude metadata, projectile arcs, fog, and combined arms; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so 2.5D Classic RTS Design tests can run without presentation timing.

## Vertical slice acceptance
The first playable slice should prove the 2.5D requirement, not just generic RTS control.

- One small skirmish map with ground height samples, cliffs, ramps, and resource points.
- One builder, one factory, one tank, one artillery unit, one aircraft, one turret, and one HQ.
- Ground units path around blockers.
- Aircraft pass over ground blockers and cast altitude-aware shadows.
- Artillery shells arc over low obstacles, collide with high terrain or valid target altitude, and produce splash damage.
- Direct-fire cannon projectiles use swept circle 2D checks plus altitude filtering.
- Fog of war, minimap pings, basic enemy AI, and save/load work.
- Debug overlay can show XY colliders, altitude ranges, terrain height samples, projectile arcs, and impact kind.

## Risks
- If altitude remains script-only, Lua systems must duplicate physics filtering, projectile collision, terrain impact, and debug visualization. That will make large RTS simulations harder to optimize and harder to keep deterministic.
- If the engine tries to solve this as full 3D physics, the feature will become too broad and conflict with the runtime-only 2D scope of the design library.
- Ballistic projectiles need deterministic sampling and a predictable maximum number of substeps to avoid frame-dependent hits.
- Large battles require stable data-oriented update patterns. The altitude layer should be cheap metadata plus query helpers, not one full rigid body per shell fragment or visual-only effect.

## Design anchor

This document describes a 2D real-time strategy game for classic macro-RTS expectations: base building, large armies, fog, factories, terrain, and combined arms. The goal is to define the Lurek2D project architecture needed for a large-unit-count, Lua-authored RTS where the world is visually and tactically 2D, but units and projectiles can still reason about altitude above the terrain.

The important design constraint is: the game remains a 2D RTS. It does not require a 3D scene graph, 3D rigid bodies, skeletal meshes, or full 3D navigation. The additional axis is a gameplay altitude layer used for flying units, ballistic projectiles, shadow rendering, collision filtering, line of sight, target clearance, and impact resolution.

## Player fantasy

The player commands a base, expands across resource nodes, builds factories, creates combined-arms armies, scouts through fog of war, and wins by destroying the enemy base or completing scenario objectives. Battles should feel large and readable: ground units move across terrain, aircraft fly over obstacles, artillery shells arc over walls, missiles can overshoot or collide with targets at altitude, and explosions are visually layered with shadows and impact decals.

## Core loop

1. Start with a command unit or headquarters.
2. Scout nearby terrain and resource points.
3. Build extractors, power, factories, defenses, and radar.
4. Produce land, air, naval, and artillery units.
5. Use minimap and group commands to maneuver armies.
6. Resolve battles through target priorities, terrain, projectile arcs, air/ground separation, splash damage, and economy pressure.
7. Expand or tech up until one side wins.

## Required game systems

- Large-scale entity management for hundreds or thousands of units, projectiles, wrecks, decals, effects, and build previews.
- Grid or navmesh-backed pathfinding for ground, amphibious, naval, hover, and air movement classes.
- Fog of war, radar reveal, sonar-like reveal for water maps, and minimap overlays.
- Data-driven unit definitions for modding: movement type, footprint, collision radius, altitude envelope, weapons, build cost, build time, vision, radar, armor, damage classes, sprite sets, sounds, and death effects.
- Command system: move, attack-move, patrol, guard, stop, repair, reclaim, build, queue, rally point, transport load/unload.
- Production system with factory queues, prerequisites, tech tiers, build assist, and cancellation refunds.
- Weapon system with hitscan beams, direct-fire projectiles, homing missiles, ballistic arcs, artillery shells, bombs, torpedoes, and area-of-effect damage.
- 2.5D spatial rules for altitude, body height, terrain height, projectile arcs, target clearance, and air/ground collision filtering.
- Deterministic fixed-step simulation for gameplay logic, separated from visual interpolation.
- Save/replay-friendly state snapshots.

## Current Lurek2D fit

The existing physics model already covers much of the 2D foundation needed by this design:

- Dynamic, static, kinematic, and sensor bodies are sufficient for ground footprints, triggers, walls, build blockers, projectiles, and detection volumes.
- Raycasts, overlap checks, swept circle queries, contacts, collision filtering, and CCD provide a good base for fast projectiles and collision authority.
- The 16-group world collision matrix and per-body layer/mask filters are useful for separating terrain, units, projectiles, sensors, air, water, resources, and build previews.
- Terrain, liquid, flow-field, beam reflection, projectile reflection, material, and debug-rendering APIs are useful for expressive strategy maps.

However, the current physics API appears to model only 2D position and 2D velocity. It has no first-class `z`, `altitude`, `verticalVelocity`, `heightExtent`, `terrainHeight`, or altitude-aware collision query contract. A classic large-scale RTS can fake this in Lua, but then the engine is no longer the shared spatial authority for projectiles, aircraft, ballistic impacts, shadows, and collision filtering.

## Needed implementation: 2.5D physics layer

Add an optional altitude layer to the physics subsystem. This should be explicitly 2.5D, not full 3D physics.

### Core concepts

- `x, y`: existing 2D world-space position.
- `z`: altitude above a sampled ground height in world units.
- `height`: vertical extent of the body or targetable volume.
- `groundHeight`: sampled terrain height at `(x, y)`.
- `worldZMin = groundHeight + z`.
- `worldZMax = worldZMin + height`.
- `verticalVelocity`: gameplay velocity on the altitude axis.
- `verticalGravity`: optional gravity used for shells, bombs, wreck debris, and falling aircraft.
- `clearance`: minimum altitude needed to pass over a body or terrain feature.

### Proposed Lua API



### Contact and hit payload additions

Altitude-aware hits should extend existing collision/query results without breaking older code:



### Collision semantics

- XY broad phase remains 2D and uses the existing physics world.
- Altitude filtering runs after a candidate XY hit/overlap is found.
- Two bodies collide only when their vertical intervals overlap, unless a body explicitly opts into ground-only or all-altitude collision.
- Ground units have `z = 0` and collide against terrain/building footprints in XY.
- Air units can pass over ground units and low blockers when `worldZMin` is above the blocker `worldZMax` plus clearance.
- Projectiles can hit terrain when their ballistic `worldZ` becomes less than or equal to sampled terrain height.
- Splash damage can choose whether it is cylindrical, ground-projected, or spherical-in-altitude.

## RTS data model

### Unit definition



### Weapon definition



### Map cell facts

## Simulation architecture

### Fixed update pipeline

1. Read player and AI commands.
2. Update selection, command queues, build queues, and production.
3. Update fog/radar visibility snapshots.
4. Resolve unit steering and path following.
5. Step 2D physics or movement authority for units.
6. Step altitude layer for airborne, ballistic, falling, and fixed-height bodies.
7. Resolve projectile arcs and impact events.
8. Apply damage, splash, death, wreck, reclaim, and resource events.
9. Emit UI notifications and minimap alerts.
10. Snapshot replay/save-relevant events.

### Rendering pipeline

1. Draw terrain and decals.
2. Draw ground shadows for units and projectiles, offset or scaled by altitude.
3. Draw ground units and structures sorted by Y when needed.
4. Draw airborne units and projectiles with altitude-adjusted sprite offsets.
5. Draw explosions, trails, muzzle flashes, and smoke.
6. Draw selection rings, health bars, command lines, build previews, fog, radar, minimap, and UI.

## Acceptance criteria for engine support

- Lua can attach altitude metadata to physics bodies without replacing existing 2D APIs.
- Lua can query and debug body altitude ranges.
- Ballistic projectile helpers can return body, terrain, ground, or expiry hit kinds.
- Altitude-aware collision filtering can be tested independently from rendering.
- Existing 2D physics behavior remains unchanged when no altitude layer is attached.
- Tests cover ground-vs-air separation, shell arc over low blockers, shell impact into high terrain, aircraft over ground units, and splash damage mode selection.
