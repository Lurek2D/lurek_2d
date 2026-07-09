# Massive 2D RTS

## Design target

A technical game design document for a marketable 2D Massive 2D RTS built with Lurek2D. The design target is large-unit movement, shared routing, order queues, and scalable debug telemetry, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Massive 2D RTS should be positioned as a focused strategy games entry about large-unit movement, shared routing, order queues, and scalable debug telemetry. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Game flow | `lurek.scene`, `lurek.input`, `lurek.ui` | For Massive 2D RTS, this area covers game flow from the current design; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it to decide which systems are active and which state may change in each screen. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| World state | `lurek.ecs`, `lurek.tilemap`, `lurek.tilefield` | For Massive 2D RTS, this area covers world state from the current design; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. |
| Simulation | `lurek.pathfind`, `lurek.ai`, `lurek.physics` | For Massive 2D RTS, this area covers simulation from the current design; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for inspectable decision scoring and scheduled planners. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. |
| Data and persistence | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe`, `lurek.save` | For Massive 2D RTS, this area covers data and persistence from the current design; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Presentation | `lurek.render`, `lurek.camera`, `lurek.audio`, `lurek.animation`, `lurek.tween`, `lurek.particle` | For Massive 2D RTS, this area covers presentation from the current design; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Orders, formations, and navigation | `lurek.pathfind`, `lurek.graph`, `lurek.ai` | For Massive 2D RTS, this area covers querying routes, flows, adjacency, threat maps, and scheduled command decisions; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. Use it for adjacency, supply, flow, non-grid links, formations, and network analysis. Use it for inspectable decision scoring and scheduled planners. |
| Territory, fog, and map overlays | `lurek.province`, `lurek.awareness`, `lurek.minimap` | For Massive 2D RTS, this area covers tracking ownership, visibility, strategic regions, alerts, and overview commands; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for territory ownership, regions, adjacency, strategic overlays, and faction maps. Use it for visibility, perception, reveal, stealth, fog, and field-of-view decisions. Use it for overview navigation, alerts, fog summaries, and large-map command feedback. |
| Economy, production, and telemetry | `lurek.timer`, `lurek.dataframe`, `lurek.charts` | For Massive 2D RTS, this area covers driving build queues, resource ticks, balance tables, and debug economy reports; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for economy reports, telemetry, demand curves, production graphs, and balance views. |
| Scene ownership and mode boundaries | `lurek.scene` | For Massive 2D RTS, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Massive 2D RTS, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Massive 2D RTS, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Massive 2D RTS, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Massive 2D RTS, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Massive 2D RTS, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Massive 2D RTS, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Massive 2D RTS, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Massive 2D RTS, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support large-unit movement, shared routing, order queues, and scalable debug telemetry. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Massive 2D RTS state should center on large-unit movement, shared routing, order queues, and scalable debug telemetry. Treat units as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Massive 2D RTS state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for massive 2d rts previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Massive 2D RTS into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where units, formations, orders, flow fields, buildings, threats, and debug counters need stable identity across several systems. Single-purpose values can stay in domain tables, but any massive 2d rts object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Massive 2D RTS is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/massive_2d_rts/main.lua` - owns massive 2d rts callback handoff and startup wiring.
- `content/games/massive_2d_rts/conf.toml` - owns massive 2d rts window, input, asset, and runtime defaults.
- `content/games/massive_2d_rts/data/massive_2d_rts_rules.toml` - owns massive 2d rts authored rules for large-unit movement, shared routing, order queues, and scalable debug telemetry.
- `content/games/massive_2d_rts/data/units.toml` - owns massive 2d rts content records for units.
- `content/games/massive_2d_rts/scripts/scenes/massive_2d_rts_play.lua` - owns massive 2d rts scene-local orchestration and pause/result transitions.
- `content/games/massive_2d_rts/scripts/systems/massive_2d_rts_state.lua` - owns massive 2d rts authoritative state containers and domain update order.
- `content/games/massive_2d_rts/scripts/systems/massive_2d_rts_validation.lua` - owns massive 2d rts data integrity checks before content enters a run.
- `content/games/massive_2d_rts/scripts/ui/massive_2d_rts_hud.lua` - owns massive 2d rts HUD, inspector, prompt, and accessibility surfaces.
- `content/games/massive_2d_rts/assets/massive_2d_rts/` - owns massive 2d rts media grouped by stable asset IDs.

## Game structure

Massive 2D RTS should be built as a set of named domain services rather than one large gameplay script.

- `massive_2d_rts_state` owns durable units, formations, and orders records.
- `massive_2d_rts_rules` validates commands, applies large-unit movement, shared routing, order queues, and scalable debug telemetry, and emits deterministic events.
- `massive_2d_rts_content` loads tables, checks IDs, and reports missing media before play starts.
- `massive_2d_rts_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `massive_2d_rts_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `massive_2d_rts_debug` exposes flow fields, buildings, and threats in overlays without mutating shipped state.

## Data and content model

- `units_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `units_table` data should live in `data/` and be validated before Massive 2D RTS enters active play.
- `formations_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `formations_table` data should live in `data/` and be validated before Massive 2D RTS enters active play.
- `orders_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `orders_table` data should live in `data/` and be validated before Massive 2D RTS enters active play.
- Massive 2D RTS save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Massive 2D RTS content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate massive 2d rts setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for units, formations, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for large-unit movement, shared routing, order queues, and scalable debug telemetry; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Massive 2D RTS tests can run without presentation timing.

## Vertical slice acceptance
The first production-ready slice should prove these cases:

1. Load a 1000 x 1000 map and derive navigation from `tilefield`.
2. Spawn at least 1000 mixed-footprint units: 1x1 infantry, 2x2 tanks, and 4x4 heavy units.
3. Select 200+ units and issue one move order with a visible formation.
4. Units share path/corridor/flow work instead of each unit calculating a full independent route.
5. Build or remove a building during gameplay and update only affected navigation regions.
6. Patrol, guard, stop, hold position, and stance changes work through engine-level orders.
7. Auto-explore can use a fog/exploration provider to choose frontier targets.
8. Debug overlays show pathing, dirty regions, flow fields, formations, and blocked units.
9. Lua gameplay code does not implement A*, HPA, flow fields, ORCA, or formation slot assignment.
10. Benchmarks report path queue time, movement update time, and frame-time impact.

## Risks

- Independent A* per unit will not scale to thousands of units on a 1000 x 1000 grid.
- Full-grid flow-field recomputation can become expensive if many unique goals are requested every frame.
- All-pairs local avoidance is not viable at RTS scale.
- Rebuilding spatial hashes per query defeats the purpose of spatial partitioning.
- Dynamic terrain changes need generation-aware caches or units will follow stale paths.
- Exposing too much low-level pathfinding to Lua will make every game duplicate engine algorithms.

## Product promise

Build a classic large-scale 2D RTS where the game script can focus on units, economy, combat, UI, and content instead of reimplementing scalable movement algorithms. The target is a large mutable battlefield with thousands of units, multiple footprint sizes, and common RTS orders exposed through configurable Lurek APIs.

This document defines the Lurek-side architecture needed for a massive 2D RTS product and the gameplay-facing API shape that should hide navigation, grouping, and local-avoidance complexity from Lua game code.

## Scale target

- Map size: 1000 x 1000 logical cells as a normal supported case, not an edge-case stress test.
- Unit counts: thousands of active units, with a benchmark target that can be raised in stages: 500, 1000, 2500, 5000.
- Unit footprints: at minimum 1x1, 2x2, and 4x4 cells; later rectangular footprints such as 2x3 and building footprints.
- Dynamic obstacles: buildings, wrecks, terrain changes, closed gates, temporary blockers, and construction sites.
- Orders: move, attack-move, patrol, guard, auto-explore, stop, hold position, and stance changes.
- Movement quality: formations should remain recognizable without requiring perfect slot locking when terrain is narrow or crowded.

## Project structure

A game using this design should keep content and RTS logic separated:

- `content/games/massive_rts/`
- `conf.toml`
- `main.lua`
- `assets/`
- `units/`
- `terrain/`
- `ui/`
- `data/`
- `unit_types.toml`
- `weapons.toml`
- `factions.toml`
- `maps/`
- `scripts/`
- `boot.lua`
- `systems/`
- `rts_world.lua`
- `orders.lua`
- `combat.lua`
- `economy.lua`
- `fog.lua`
- `selection.lua`
- `debug_nav.lua`
- `ui/`
- `hud.lua`
- `minimap.lua`
- `command_panel.lua`

Lua owns game rules, data loading, faction definitions, UI, combat rules, and victory conditions. Lurek should own the generic algorithms: map navigation, flow/corridor pathing, local avoidance, formation slotting, order lifecycle, target acquisition policy, and path budget scheduling.

## Current Lurek API strategy

The current engine already has important low-level pieces:

- `lurek.tilefield` can describe gameplay cells and movement categories.
- `lurek.pathfind.newNavGridFromField` can derive navigation costs and blocked cells from a tilefield level.
- `lurek.pathfind` exposes `NavGrid`, A*, HPA*, flow fields, async path jobs, steering, context steering, ORCA, influence maps, and graph helpers.
- `lurek.ai` exposes `AIWorld`, agents, behavior trees, GOAP/HTN/MCTS, utility AI, squads, perception, traits, needs, and custom Lua callbacks.

For a massive RTS these are necessary but not sufficient. A game can assemble them manually, but doing so would force the game author to become the movement-system engineer. The missing layer is a high-level a future RTS facade built over `lurek.pathfind` and `lurek.ai` or a future RTS facade built over `lurek.ai` and `lurek.pathfind` API that orchestrates those primitives in a scalable, configurable way.

## Proposed high-level API

The preferred public surface is a new a future RTS facade built over `lurek.pathfind` and `lurek.ai` module that composes `tilefield`, `pathfind`, `ai`, and spatial indexing.



The game should not need to implement A*, flow fields, ORCA neighbor filtering, HPA invalidation, or formation slot assignment in Lua.

## Navigation architecture

Movement should be layered from coarse to fine:

1. **Terrain source**: `tilefield` or `tilemap` stores terrain categories, costs, blockers, construction sites, and dynamic blockers.
2. **Navigation grid**: `NavGrid` stores current walkability and cost per movement class.
3. **Clearance fields**: precomputed clearance for footprint profiles such as 1x1, 2x2, 4x4, and rectangular variants.
4. **Hierarchy**: HPA or region/portal graph stores long-range connectivity and corridor routes.
5. **Flow/corridor cache**: groups moving toward the same goal share flow fields or corridor segments instead of every unit running full A*.
6. **Formation planner**: assigns slots near the destination and along corridors, with fallback when slots are blocked.
7. **Local movement**: steering and ORCA-style avoidance produce final velocities within a fixed per-frame budget.
8. **Debug telemetry**: overlays show dirty chunks, route corridors, flow vectors, slot targets, blocked units, and neighbor counts.

## Required pathfinding extensions

### Footprint and clearance profiles

Current unit-size pathing is useful, but RTS units need named movement profiles. Add API like:



This avoids scanning every cell of a footprint for every neighbor expansion. It also allows rectangular footprints and movement-class-specific blockers later.

### Dynamic map updates

Dynamic blockers should be batched and committed:



`commitUpdate` should update generation counters, dirty rectangles, clearance fields, affected HPA chunks, and affected flow caches. Full rebuild should remain available for tools and loading, but gameplay updates should be incremental.

### Batch path requests

A high-level batch API should group similar route requests:



The engine should deduplicate goals, reuse corridors, reuse flow fields, and stream partial results. Lua should receive ownership-oriented events, not raw worker internals.

### Flow field cache

For RTS orders, many units usually share a destination or target region. Add a cache keyed by grid generation, movement class, footprint, team, destination region, and pathing mode.



The RTS world can use this handle internally, but exposing it helps advanced games debug and tune behavior.

## Required local avoidance extensions

The current ORCA-style API should gain persistent spatial partitioning and neighbor limits so thousands of units do not become a quadratic pairwise problem.

Proposed API:



This should be backed by a persistent spatial hash or grid index updated once per frame, not rebuilt per unit query.

## Required RTS order API

The engine should provide common RTS order primitives:

| Order | Engine responsibility | Lua responsibility |
| --- | --- | --- |
| `move` | route, formation slots, local avoidance, arrival events | choose selected units and target point |
| `attack_move` | move toward point, acquire hostile targets along route | combat damage rules and weapon data |
| `patrol` | route or area loop, reacquire path when blocked | decide patrol points/area |
| `guard` | follow/escort target with leash and response radius | decide target and faction rules |
| `explore` | frontier selection from fog/exploration data | fog source and exploration rewards |
| `stop` | clear path, clear queued commands | UI/action rules |
| `hold_position` | suppress chase movement, allow fire rules | combat policy |
| `stance` | passive/defensive/aggressive target policy | expose UX and faction defaults |

Orders should have a queue and lifecycle:

## Stance behavior profiles

Recommended built-in stances:

| Stance | Target acquisition | Chase | Movement interruption |
| --- | --- | --- | --- |
| `passive` | none unless explicitly targeted | no | never |
| `hold_fire` | track targets but do not fire | no | never |
| `defensive` | return fire or enemies inside guard radius | short leash | only inside leash |
| `aggressive` | acquire visible hostile in range | normal leash | can interrupt move briefly |
| `berserk` | acquire any visible hostile | long leash | can abandon formation |

The engine should make stance policy configurable, not hard-coded to one RTS design.

## Formation design

Existing squad offsets are a useful start, but RTS formations need destination slot assignment and obstacle-aware fallback.

Required formation API:



The formation planner should:

- reserve or score slots by unit footprint;
- avoid assigning 4x4 units to narrow slots;
- split large groups when a corridor is too narrow;
- keep the formation readable in open terrain;
- allow tactical fallback to a stream/column in chokepoints;
- emit debug events when formation quality degrades.

## Fog and auto-explore

Auto-explore should not be a random walk. It should be a generic frontier planner that reads a game-supplied exploration grid:



The engine chooses candidate frontier cells and routes units there; Lua defines what counts as known, visible, valuable, or dangerous.

## UI and control loop

A normal RTS frame should look like this:



The main game loop calls `rts:update(dt)` and inspects events. It should not manually step thousands of path requests or solve every unit's local avoidance from Lua.

## Debug overlays

Add a debug surface to inspect RTS-scale movement:



Debug output should include counts for active flow fields, path jobs, dirty chunks, average neighbor count, worst path queue latency, and units without valid orders.

## API gaps to track

- Add a future RTS facade built over `lurek.pathfind` and `lurek.ai` high-level module or an equivalent a future RTS facade built over `lurek.ai` and `lurek.pathfind` namespace.
- Add footprint profiles and clearance fields to `NavGrid`.
- Add rectangular footprint support, not only square `unit_size`.
- Add movement classes and movement-layer-specific costs/blockers.
- Add dynamic nav generation, batch updates, and true dirty-chunk rebuilds.
- Add shared corridor and flow-field caches for group orders.
- Add batch path submission that deduplicates routes and goals.
- Add persistent spatial indexing for steering/ORCA/fog/threat queries.
- Replace all-pairs crowd avoidance with neighbor-limited spatial queries.
- Add built-in RTS orders and order queues.
- Add configurable stance/target-acquisition policies.
- Extend squads/formations into obstacle-aware slot assignment.
- Add RTS movement debug overlays and benchmark scenes.

## Suggested implementation phases

1. **API contracts and docs**: define a future RTS facade built over `lurek.pathfind` and `lurek.ai` concepts, Lua signatures, events, and benchmark goals.
2. **Navigation substrate**: add footprint profiles, clearance fields, generation counters, and dirty-region APIs.
3. **Batch routing**: add shared route/corridor/flow cache and batch path requests for selections.
4. **Crowd movement**: add persistent spatial index and neighbor-limited local avoidance.
5. **RTS world and orders**: add unit registry, unit types, order queues, formations, stances, patrol, guard, and explore.
6. **Debug and benchmarks**: add overlays and automated evidence scenes for 1000 x 1000 maps and thousands of units.

## Definition of done

The RTS API is good enough when a Lua game can implement a playable massive 2D RTS prototype using declarative unit types and engine-provided orders without writing custom A*, HPA, flow-field, local-avoidance, or formation-slot algorithms.
