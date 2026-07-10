<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/pathfind.md or source docstrings instead. -->

# pathfind

## TL;DR

- Navigates grids, hex layouts, isometric maps, navmeshes, and province graphs.
- Employs A*, JPS, bidirectional search, HPA*, and async thread pools.
- Uses Dijkstra flow fields, tactical influence maps, steering stacks, context steering, ORCA-style local avoidance, and debug visual overlays.

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind`
- Binding: `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`
- Lua API surface: `35` functions, `31` types, `209` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `pathfind` module is the engine's navigation and movement-analysis surface for users who need more than one hard-coded shortest-path helper.
- It supports several spatial models at once, including weighted grids, hex and isometric spaces, province-style graphs, influence fields, and other routing abstractions, so different worlds can still share one navigation family.
- A* is only part of the surface. The module also covers bidirectional search, Jump Point Search, hierarchical routing, graph travel, flow fields, influence maps, steering, local avoidance, and reachability-style analysis under one subsystem.
- This breadth matters because movement questions differ dramatically across features. Some systems need one precise route, others need shared guidance, tactical pressure, move ranges, or background jobs for expensive searches.
- That makes the module useful not only for point-to-point travel but also for squad guidance, threat-aware movement, logistics overlays, and strategic map reasoning where spatial scoring matters.
- Async search support is especially important because pathfinding is often one of the first systems that must leave the main loop without losing an engine-owned, script-facing API.
- Shared abstractions for grids and graph-like inputs reduce adapter overhead and make it easier for a project to compare algorithms without rewriting all navigation data plumbing.
- Range and reachability helpers are as important as final path extraction. Many systems need to know where a unit could move, what lies inside a budget, or which cells are effectively controlled before they need an explicit route.
- Influence, steering, ORCA, and shared-field helpers broaden the module into tactical movement analysis. Movement is not only about reaching a goal; it is also about preferring safe zones, avoiding danger, and turning desired motion into local movement advice for several actors.
- Because several world models can feed the same pathfinding family, projects can evolve from simple grid routing to richer graph or field-based navigation without abandoning the same conceptual subsystem.
- That flexibility is one of the main reasons the module exists as a family rather than as one algorithm wrapper: different gameplay scales can still share one navigation vocabulary.
- Cost rules are part of that vocabulary too. Terrain penalties, danger zones, ownership boundaries, and temporary blockers can all be expressed as navigation data instead of being bolted on after a path is returned.
- This helps projects keep route quality and tactical intent aligned, because the same system can explain not only where an actor can go, but why one route is preferred over another.
- The module is also valuable when several agents share the same traversability model but need different routing policies over it.
- That makes `pathfind` a planning layer, not only a shortest-path helper.
- Debug and visualization helpers matter because navigation bugs usually come from topology, weights, or blocked-space assumptions rather than from the solver implementation alone.
- `tilemap`, `province`, and related modules define traversable space, but `pathfind` owns how that space is searched, scored, and turned into movement advice.
- Province-level BFS, weighted Dijkstra/A*, connected-component traversal, and reachability belong here even when `province` exposes convenience methods that adapt registry topology into pathfinding inputs.
- Read `pathfind` as the reusable navigation and local-movement analysis layer of the engine, not as an animation or physics integration system.

This module primarily collaborates with `flownet`, `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/pathfind`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/pathfind_api.rs`
- Referenced engine modules: `flownet`, `image`, `render`, `runtime`

## Imports

- `flownet`: Imports or references `src/flownet/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### ai_flow_field.rs

- Builds a lightweight steering field from one goal cell so many agents can follow shared directional guidance.
- Owns per-cell distances, normalized direction vectors, the active goal, and the walkability mask it samples.
- Uses breadth-first expansion over eight neighbors, then derives best downhill directions for each reachable cell.
- Provides the boundary between simple static obstacle masks and agent steering code that only needs local vectors.
- Open this owner when single-goal flow behavior, diagonal step rules, or direction synthesis needs correction.

### astar.rs

- Implements core `NavGrid` A* search used by higher-level pathfinding features across the runtime.
- Owns heap nodes, octile and Manhattan heuristics, unit-size neighbor expansion, and route recovery.
- Supports early termination with partial paths while respecting diagonal policy, costs, and node budgets.
- Provides local Bresenham clearance checks only for path smoothing, not visibility or action semantics.
- Receives movement data from grids or adapters and never owns tilefield channels beyond movement costs.
- Returns ordered route results for callers while keeping async queues, HPA graphs, and navmeshes separate.
- Open this owner when baseline grid route quality changes, not for fog, lighting, raycasting, or minimaps.

### async_pool.rs

- Runs prioritized off-thread path queries so expensive A* work can happen without blocking the main game loop.
- Owns async request and event payloads, worker queue state, cancellation tables, and owner-version supersession.
- Streams partial or final path results back to callers, including cancelled, failed, complete, and superseded states.
- Provides the execution boundary between synchronous path solvers and systems that need queued background navigation.
- Tracks per-owner live requests so newer versions can invalidate stale work before outdated routes reach gameplay.
- This file is the right owner for queue ordering, thread-count policy, pending counts, and worker shutdown rules.
- Neighboring changes usually involve NavGrid snapshots, A* budget behavior, and Lua or gameplay request adapters.
- Open this file when path jobs need new lifecycle semantics or when streamed progress events stop matching callers.

### bidir.rs

- Runs bidirectional A* on NavGrid data so search can expand from start and goal until the frontiers meet.
- Owns paired open sets, forward and backward parent tables, shared heuristics, and meet-point reconstruction.
- Respects diagonal mode, unit-size walkability, and tile costs while still supporting partial fallback results.
- Provides the algorithm boundary between single-frontier A* and reduced-expansion searches for longer routes.
- This file is the right owner when meet detection, backward expansion, or budget exhaustion behavior is wrong.
- Neighboring edits usually involve NavGrid movement policy and baseline A* helpers reused by both frontiers.

### context_steering.rs

- Implements slot-based context steering that scores angular interest and danger before choosing a movement lane.
- Owns directional ring buffers, behavior registrations, wander accumulation, and the chosen heading snapshot.
- Mixes seek, avoid, wander, fixed-direction, and boundary pressures into one compact frame-friendly sampler.
- Resolves conflicts by comparing interest against danger per slot instead of blending unsafe vectors directly.
- Provides the pathfind-owned boundary between authored context behaviors and final travel heading selection.
- Use this owner when directional slot math or danger suppression yields jittery or unsafe movement choices.
- Open generic steering only when the bug is force combination policy rather than lane selection semantics.

### flow_field.rs

- Builds a NavGrid-backed flow field that points each reachable cell toward one or more target cells.
- Owns direction vectors, accumulated costs, target storage, and the shared-grid reference used for recomputation.
- Calculates steering data with unit-size aware walkability, then exposes direction, angle, cost, and velocity helpers.
- Also renders a debug image so field quality and blocked-cell effects can be inspected outside the live renderer.
- Provides the boundary between raw navigation costs and agent steering systems that need cheap per-frame guidance.
- Open this owner when target propagation, steering output, or debug visualization stops matching pathing intent.

### goal_map.rs

- Builds a multi-source goal distance map that AI can sample for attraction, fleeing, and reachability queries.
- Owns weighted source definitions, packed distance storage, dirty tracking, and binary save and restore helpers.
- Bakes a four-neighbor Dijkstra field from registered sources and a blocker predicate supplied by the caller.
- Exposes direct distance lookup, downhill gradients, flee vectors, and threshold flood-fill over baked results.
- Provides the boundary between authored goal sets and cheap runtime samples that agents can use every frame.
- Open this owner when source registration, bake rules, or serialized distance-field contracts need adjustment.

### graph_nav.rs

- Implements generic graph A* and budgeted range traversal for flownet-style node and edge networks.
- Owns graph heap nodes, predecessor reconstruction, and directed or bidirectional edge walking rules.
- Searches active graph edges only, then returns ordered node ids or reachable nodes with accumulated cost.
- Provides the boundary between generic graph data and systems that need reusable network traversal primitives.
- Open this owner when graph heuristic use, edge direction handling, or range flood semantics need revision.

### graph_path.rs

- Owns the pathfind graph path implementation for the pathfind subsystem and keeps related runtime rules local here.
- Keeps path graphs, routes, and traversal-facing helpers ownership so helpers stay close to invariants this file updates.
- Defines how pathfind graph path data is validated, transformed, or stored before neighboring systems consume it.
- Separates pathfind graph path behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where pathfind code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing pathfind graph path defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near pathfind graph path state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping pathfind graph path calculations at their owning subsystem boundary.

### grid.rs

- Implements the general weighted tile grid used for A*, Dijkstra, BFS, and flow-field style distance queries.
- Owns walkability flags, per-cell float costs, priority-queue nodes, and parent reconstruction over flat storage.
- Exposes multiple search styles from one owner so callers can swap between heuristic, weighted, and uniform modes.
- Provides the boundary between simple tile cost maps and higher-level systems that need reusable grid algorithms.
- Also builds a distance field from many targets, keeping multi-goal propagation close to the core grid substrate.
- This file matters when neighbor policy, cost semantics, or path reconstruction rules for generic grids change.
- Open this owner for shared grid-search fixes before touching specialized NavGrid, hex, iso, or province solvers.

### hex_grid.rs

- Implements weighted pathfinding on hex maps with selectable flat-top or pointy-top offset coordinate layouts.
- Owns blocked flags, movement costs, neighbor offset rules, cube-coordinate conversion, and hex-line generation.
- Runs A* between hexes, then also exposes line of sight, field of view, and movement budget range queries.
- Provides the boundary between hex topology math and gameplay systems that need pathing over six-neighbor boards.
- Uses cube rounding and interpolation so visibility and distance logic stay aligned with the chosen hex layout.
- This file matters when hex adjacency, path cost semantics, or range calculations no longer match map behavior.
- Open this owner for hex-specific navigation fixes before changing rectangular grid, iso, or navmesh code paths.

### hpa.rs

- Builds the hierarchical pathfinding layer that partitions a NavGrid into chunks and entrance-based abstract nodes.
- Owns chunk metadata, abstract nodes, abstract edges, and the scans that detect cross-chunk entrances on borders.
- Constructs an abstract graph with intra-chunk edge costs, then uses abstract A* before refining to grid paths.
- Provides the scale boundary between low-level tile walkability and long-distance routing that needs fewer expands.
- Also exposes reachability checks over chunk connectivity so callers can reject impossible goals before refinement.
- This file is where chunk size, entrance placement, abstract heuristics, and refinement strategy are coordinated.
- Neighboring edits usually involve NavGrid dirty tracking, base A* behavior, and systems consuming long routes.
- Open this owner when large-map path performance changes or when abstract graph correctness needs investigation.

### influence_map.rs

- Owns named influence layers over a uniform grid so AI can score space with floating-point tactical signals.
- Supports stamping radial influence, smoothing, decay, blending, extrema queries, and rectangular aggregation.
- Stores layer data in flat arrays keyed by layer name, keeping spatial analytics close to their update helpers.
- Also renders influence layers to debug images so designers can inspect how fields combine across the map.
- Provides the boundary between abstract decision weights and concrete cell-space data queried by gameplay code.
- Open this owner when layer math, blend semantics, or visualization of influence values needs correction.

### iso_grid.rs

- Implements weighted pathfinding on rectangular isometric grids with blocked flags and per-cell costs.
- Owns cell indexing, four-neighbor A*, Manhattan heuristics, and Bresenham line-of-sight checks for the map.
- Returns ordered tile paths for iso maps while keeping cost weighting and obstacle handling in one owner.
- Provides the boundary between isometric map data and systems that need reliable navigation on projected tiles.
- Open this file when iso path cost rules, neighbor policy, or LOS behavior no longer matches gameplay maps.

### jps.rs

- Implements Jump Point Search on uniform eight-way grids so large open areas can be searched with fewer expansions.
- Owns blocked-cell storage, jump detection, forced-neighbor rules, pruned successor generation, and path expansion.
- Searches by leaping between jump points, then reconstructs the full tile path that callers expect to consume.
- Provides the optimization boundary between plain grid A* and symmetry-pruned search for cost-uniform maps.
- This file is the right owner when forced-neighbor logic, jump recursion, or successor pruning needs correction.
- Neighboring changes usually involve uniform grid assumptions and tooling that compares JPS routes to baseline A*.
- Open this owner when open-area path performance regresses or when jump-point reconstruction becomes inconsistent.

### mod.rs

- Exports the pathfinding surface for routing, spatial fields, steering, local avoidance, and debug views.
- Acts as the navigation index for A*, HPA, flow fields, influence maps, ORCA, and province graphs.
- Keeps boundaries explicit so callers can locate data, search, movement, validation, or debug ownership.
- Re-exports grid, hex, iso, navmesh, steering, tactical, and graph helpers without storing live state.
- This index owns visibility contracts, not queues, caches, solver internals, or renderer submission data.
- Start here when tracing navigation behavior because it reveals the authoritative file split by feature.
- Neighboring changes usually span `NavGrid`, async requests, solvers, steering helpers, and debug adapters.
- Update this file when adding, retiring, or renaming pathfinding owners or public re-export policy.

### nav_grid.rs

- Owns the runtime walkability grid that stores byte movement costs, diagonal policy, and HPA dirty rectangles.
- Provides constructors, bulk mutation, byte import and export, snapshots, and cell queries over flat tile data.
- Defines DiagonalMode parsing so Lua and engine callers share one source of truth for corner-cutting behavior.
- Also enforces unit-size walkability checks, making this file the clearance boundary for multi-tile navigation.
- This file is where chunk size, dirty invalidation hints, and neighbor enumeration rules are coordinated together.
- Neighboring changes usually involve A*, HPA, render debug overlays, and Lua bindings that edit pathing grids.
- Open this owner when navigation cost storage or directional movement policy changes across the pathfind stack.

### navmesh.rs

- Implements polygon-based pathfinding where free movement areas are modeled as connected mesh regions.
- Owns polygon vertex storage, polygon adjacency lists, centroid heuristics, and point-in-polygon lookups.
- Finds a corridor of polygons with A*, then returns world-space start, centroid waypoints, and goal points.
- Provides the boundary between arbitrary 2D walk regions and gameplay code that cannot rely on tile grids.
- Open this owner when polygon connectivity, centroid routing, or containment checks need correction.

### orca.rs

- Implements ORCA-style local collision avoidance that projects preferred motion into safe velocity choices.
- Owns solver agents, pairwise half-plane constraints, time horizon tuning, spatial neighbor filtering,
- and the linear projection step used to produce collision-safe motion.
- Computes a safe velocity for every registered agent while respecting radius and max-speed bounds.
- Provides the crowd-avoidance boundary between desired steering intent and collision-safe local movement output.
- Open this owner when avoidance stability, neighbor constraints, safe-velocity projection, or
- crowd-scale performance behavior needs adjustment.

### pathgrid.rs

- Implements a world-space path grid whose cells carry walkability and float costs for eight-way A* searches.
- Owns Cell records, octile search nodes, line-of-sight smoothing, and cell-center conversion for world outputs.
- Returns paths as world coordinates, making this file the adapter between tile search and movement-space waypoints.
- Also blocks diagonal corner cutting so smoothed routes still respect impassable geometry at cell boundaries.
- This file matters when world coordinate conversion, smoothing rules, or per-cell cost handling need adjustment.
- Open this owner before changing generic A* helpers when the bug only affects world-space path grid consumers.

### range_map.rs

- Builds a budget-limited travel map over a weighted grid so callers can preview where movement can reach.
- Owns per-cell optional costs, Dijkstra heap expansion, and helpers that return cells with or without distances.
- Respects blockers, per-cell weights, and optional diagonal movement while capping expansion by a travel budget.
- Provides the boundary between raw movement costs and UI or AI systems that need reachable-area calculations.
- Open this owner when movement budget semantics, diagonal weighting, or reachability output shape needs changes.

### render.rs

- Adds debug rendering adapters that turn pathfinding state into renderer commands for inspection overlays.
- Owns NavGrid tile shading, FlowField arrow drawing, and InfluenceMap heat visualization command generation.
- Provides the presentation boundary between pathfinding data structures and the generic RenderCommand stream.
- This file is the right owner when debug overlay colors, glyph shapes, or sampling rules need adjustment.
- Neighboring changes usually involve render command capabilities and the path structures being visualized.

### steering.rs

- Owns steering behavior stacks for pathfinding-adjacent local movement and force-based navigation.
- Centers implementation around `Force`, `SteeringEntity`, manager state, and flock parameter invariants.
- Validates entity counts, finite vectors, weights, radii, speeds, and target inputs before calculations run.
- Keeps path following, flocking, pursuit, evasion, wander, arrival, separation, and custom forces here.
- Produces deterministic movement forces that callers can compose without duplicating path avoidance rules.
- Stores named entities and behavior lists while route search, grid ownership, and rendering live elsewhere.
- Keeps crate helpers focused on movement behavior while Lua registration and table conversion stay elsewhere.
- Reports structured pathfind errors for invalid movement data instead of leaking panics into callers.
- Update this file when steering defaults, lifecycle handling, validation, or force calculation semantics change.
- Leave context-slot steering, ORCA, tactical fields, and raw path solvers in their own navigation owners.

### unit_pathfinder.rs

- Wraps a shared NavGrid in a stateful per-unit pathfinding service with cache-aware route and utility queries.
- Owns Waypoint output records, cache keys, cached path storage, shared-goal field caches, and optional LRU-style eviction behavior.
- Calls baseline A* for full, smoothed, or partial routes, then exposes length, cost, LOS, and reachability helpers.
- Also searches for the nearest walkable fallback cell and shared-goal route batches, keeping per-unit recovery logic close to shared grid access.
- Provides the boundary between raw navigation algorithms and gameplay units that need repeated path requests.
- Open this owner when route caching, per-unit helper semantics, or fallback walkability behavior needs changes.

### validation.rs

- Owns shared validation helpers for pathfinding, tactical fields, steering, and local avoidance modules.
- Keeps finite number, count, and positive-value checks close to the navigation owners that enforce them.
- Update this file when movement-facing modules need common limits or structured `PathfindError` guards.



## Lua API Ref

### Functions

- `lurek.pathfind.cancelAsyncPath(request_id) -> boolean`: Marks an async path request as cancelled.
- `lurek.pathfind.clearAsyncPaths() -> nil`: Drops all queued async path requests and recreates the worker pool with the configured thread count.
- `lurek.pathfind.getAsyncPendingCount() -> integer`: Returns the number of async path requests that have not emitted a terminal event.
- `lurek.pathfind.getThreadCount() -> integer`: Returns the configured pathfinding thread count.
- `lurek.pathfind.graphConnected(edges, from, to, opts?) -> boolean`: Returns true when a target node is reachable from a start node in an integer-id graph.
- `lurek.pathfind.graphConnectedComponents(edges, nodes?, opts?) -> table`: Returns connected components for an integer-id graph. Pass `nodes` to include isolated node ids.
- `lurek.pathfind.graphRoute(edges, from, to, opts?) -> integer[]`: Finds a route through an integer-id graph. Edges may be `{from,to}`, `{a,b}`, `{province_a,province_b}`, or `{from_id,to_id}` arrays. Options: `directed`, `algorithm` ("bfs"|"dijkstra"), and optional `cost(from, to)`.
- `lurek.pathfind.graphRoutes(edges, requests, opts?) -> table`: Finds routes for a batch of graph `{from, to}` requests using the same edge table and options as `graphRoute`.
- `lurek.pathfind.newContextSteering(slots) -> LContextSteering`: Creates a context steering model with the requested directional slot count.
- `lurek.pathfind.newFlowField(grid_ud) -> LFlowField`: Creates a flow field for a navigation grid.
- `lurek.pathfind.newGoalMap(width, height) -> LGoalMap`: Creates a new multi-source Dijkstra distance-field goal map for the given grid dimensions.
- `lurek.pathfind.newHexGrid(width, height, layout_str?) -> LHexGrid`: Creates a hex grid with the given dimensions.
- `lurek.pathfind.newHexGridFromField(field_ud, opts?) -> LHexGrid`: Creates a hex navigation grid from a hex tilefield level and movement category.
- `lurek.pathfind.newInfluenceMap(w, h, cs) -> LInfluenceMap`: Creates a grid influence map with the supplied cell dimensions and world cell size.
- `lurek.pathfind.newIsoGrid(width, height) -> LIsoGrid`: Creates an isometric grid with the given dimensions.
- `lurek.pathfind.newIsoGridFromField(field_ud, opts?) -> LIsoGrid`: Creates an isometric navigation grid from an iso-square tilefield level and movement category.
- `lurek.pathfind.newJpsGrid(width, height) -> LJpsGrid`: Creates a Jump Point Search grid with given dimensions.
- `lurek.pathfind.newNavGrid(width, height) -> LNavGrid`: Creates a navigation grid with the given dimensions.
- `lurek.pathfind.newNavGridFromField(field_ud, opts?) -> LNavGrid`: Creates a navigation grid from a tilefield level and movement category.
- `lurek.pathfind.newNavGridFromProvider(provider) -> LNavGrid`: Builds a navigation grid from a Lua provider table with width, height, optional costs/blocked arrays, or getCost/isBlocked callbacks.
- `lurek.pathfind.newNavGridFromTileMap(tm_ud, layer_index, blocked_table) -> LNavGrid`: Creates a navigation grid from a tilemap layer and blocked gid table.
- `lurek.pathfind.newNavMesh() -> LNavMesh`: Creates an empty navigation mesh for polygon-based pathfinding.
- `lurek.pathfind.newORCASolver(time_horizon) -> LORCASolver`: Creates an ORCA avoidance solver with the supplied prediction horizon.
- `lurek.pathfind.newPathFlowField(grid_ud) -> LAIFlowField`: Creates an AI flow field from a path grid.
- `lurek.pathfind.newPathGrid(w, h, cell_size) -> LPathGrid`: Creates a cell-size path grid with given dimensions.
- `lurek.pathfind.newPathGridFromProvider(provider) -> LPathGrid`: Builds a path grid from a Lua provider table with width, height, optional cellSize, costs/walkable arrays, or getCost/isWalkable callbacks.
- `lurek.pathfind.newPathfinder(grid_ud) -> LUnitPathfinder`: Creates a unit pathfinder for a navigation grid.
- `lurek.pathfind.newSteeringManager() -> LSteeringManager`: Creates an empty steering manager with support for built-in and custom movement behaviors.
- `lurek.pathfind.pollAsyncPaths() -> table`: Returns all currently available async path events without blocking.
- `lurek.pathfind.rangeMap(opts) -> table`: Computes reachable cells from range map options.
- `lurek.pathfind.rangeMapFromField(field_ud, opts) -> table`: Computes reachable cells from a tilefield level and movement category.
- `lurek.pathfind.setThreadCount(count) -> nil`: Sets the configured pathfinding worker-thread count.
- `lurek.pathfind.submitAsyncPath(grid_ud, opts) -> integer`: Queues an async path query against a navigation grid snapshot.
- `lurek.pathfind.submitAsyncPathPairs(grid_ud, opts) -> integer`: Queues one async paired batch query against a navigation grid snapshot.
- `lurek.pathfind.submitAsyncPathsToGoal(grid_ud, opts) -> integer`: Queues one async shared-goal batch query against a navigation grid snapshot.

### Callbacks

- `LGoalMap:setBlocker` param `fn` (`function`): `fn(x: integer, y: integer) -> boolean` (one-based).
- `LSteeringManager:addCustomBehavior` param `func` (`function`): Function called as `(agent, dt)` that returns an X and Y steering force.

### Enums

- No documented module-level enums/constants.

### Types

#### LAIFlowField Type

- Lua-side wrapper for an AI flow field over a path grid.

##### Fields

- No documented fields.

##### Methods

- `LAIFlowField:getDirection(x, y) -> number`: Returns flow direction vector for a one-based cell.
- `LAIFlowField:getDistance(x, y) -> number`: Returns distance to goal for a one-based cell.
- `LAIFlowField:getGoal() -> integer`: Returns the one-based flow field goal, or nil when no goal is set.
- `LAIFlowField:getHeight() -> integer`: Returns flow field height from this object.
- `LAIFlowField:getWidth() -> integer`: Returns flow field width from this object.
- `LAIFlowField:hasGoal() -> boolean`: Returns whether a flow field goal is currently set.
- `LAIFlowField:setGoal(x, y) -> nil`: Sets the one-based flow field goal and recalculates the field.
- `LAIFlowField:type() -> string`: Returns the Lua-visible type name for this AI flow field handle.
- `LAIFlowField:typeOf(name) -> boolean`: Returns whether this AI flow field handle matches a supported type name.

#### LContextSteering Type

- Lua handle for slot-based context steering direction selection.

##### Fields

- No documented fields.

##### Methods

- `LContextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight) -> nil`: Adds rectangular bounds avoidance to context steering.
- `LContextSteering:addAvoidPoint(x, y, radius, weight) -> nil`: Adds a point avoidance influence to context steering.
- `LContextSteering:addSeekTarget(tx, ty, weight) -> nil`: Adds a context steering target attraction.
- `LContextSteering:addWander(jitter, weight) -> nil`: Adds wander noise to context steering.
- `LContextSteering:chosenMagnitude() -> number`: Returns the magnitude of the last selected context steering slot.
- `LContextSteering:clearBehaviors() -> nil`: Removes all context steering behaviors.
- `LContextSteering:evaluate(ax, ay, vx, vy) -> number, number`: Evaluates context steering and returns the selected movement direction.
- `LContextSteering:slotCount() -> integer`: Returns the number of directional slots used by this context steering model.
- `LContextSteering:type() -> string`: Returns the Lua-visible type name for this context steering handle.
- `LContextSteering:typeOf(name) -> boolean`: Returns whether this context steering handle matches a supported type name.

#### LFlowField Type

- Lua-side wrapper for a flow field over a navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LFlowField:calculate(tx, ty, unit_size?) -> nil`: Calculates a flow field toward one target cell.
- `LFlowField:calculateFor(name, tx, ty) -> nil`: Calculates a flow field toward one target cell using a named navigation footprint.
- `LFlowField:calculateMulti(targets, unit_size?) -> nil`: Calculates a flow field toward multiple target cells.
- `LFlowField:calculateMultiFor(name, targets) -> nil`: Calculates a flow field toward multiple target cells using a named navigation footprint.
- `LFlowField:getBuildCount() -> integer`: Returns how many full flow-field builds have actually run on this object.
- `LFlowField:getCostToTarget(x, y) -> number`: Returns integration cost to the target from a one-based grid cell.
- `LFlowField:getDirection(x, y) -> number`: Returns flow direction vector at a one-based grid cell.
- `LFlowField:getDirectionAngle(x, y) -> number`: Returns flow direction angle at a one-based grid cell.
- `LFlowField:getGeneration() -> integer`: Returns the navigation-grid generation that produced the current flow field, or nil before the first build.
- `LFlowField:getTargets() -> table`: Returns target cells for this flow field.
- `LFlowField:isCalculated() -> boolean`: Returns whether the flow field has been calculated.
- `LFlowField:pathFrom(x, y, max_steps?) -> table`: Reconstructs a downhill route from one start cell to the nearest active target in the current flow field.
- `LFlowField:pathsFrom(starts, max_steps?) -> table`: Reconstructs downhill routes from many start cells to the nearest active target using one shared flow field.
- `LFlowField:steer(wx, wy, speed, tw, th) -> number`: Returns a steering velocity for a world position using the flow field.
- `LFlowField:type() -> string`: Returns the Lua-visible type name for this flow field handle.
- `LFlowField:typeOf(name) -> boolean`: Returns whether this flow field handle matches a supported type name.

#### LFlowFieldGetTargetsResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LFlowFieldPathFromResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LGoalMap Type

- Lua-side wrapper for a multi-source Dijkstra distance-field (goal map).

##### Fields

- No documented fields.

##### Methods

- `LGoalMap:addSource(x, y, weight?) -> nil`: Registers a source cell for this goal map. Coordinates are one-based.
- `LGoalMap:bake() -> nil`: Runs multi-source Dijkstra to build the distance field using the registered blocker.
- `LGoalMap:clearSources() -> nil`: Removes all registered source cells.
- `LGoalMap:distanceAt(x, y) -> integer`: Returns the minimum cost from (x, y) to the nearest source.
- `LGoalMap:flee(x, y, fear?) -> number`: Returns a normalised direction vector pointing away from sources (for fleeing NPCs).
- `LGoalMap:floodFill(cx, cy, threshold) -> table`: Returns all cells reachable from (cx, cy) within `threshold` steps.
- `LGoalMap:gradientAt(x, y) -> number`: Returns a normalised direction vector pointing toward the nearest source.
- `LGoalMap:isReady() -> boolean`: Returns true when the distance field has been baked and not invalidated.
- `LGoalMap:restore(blob) -> nil`: Restores a distance field from a blob produced by `save`.
- `LGoalMap:save() -> string`: Serialises the current distance field to a binary blob string.
- `LGoalMap:setBlocker(fn) -> nil`: Sets a Lua predicate called during `bake` to determine blocked cells.
- `LGoalMap:setSources(sources) -> nil`: Replaces all registered source cells. Each entry must have x, y (one-based) and optional weight.
- `LGoalMap:type() -> string`: Returns the Lua-visible type name for this goal map handle.
- `LGoalMap:typeOf(name) -> boolean`: Returns whether this goal map handle matches a supported type name.

#### LHexGrid Type

- Lua-side wrapper for a hexagonal grid.

##### Fields

- No documented fields.

##### Methods

- `LHexGrid:distance(c1, r1, c2, r2) -> number`: Returns hex distance between two one-based hex cells.
- `LHexGrid:fieldOfView(col, row, max_range) -> table`: Returns visible hex cells within range from an origin.
- `LHexGrid:findPath(fc, fr, tc, tr) -> table`: Finds a path between one-based hex cells.
- `LHexGrid:isBlocked(col, row) -> boolean`: Returns whether a one-based hex cell is blocked.
- `LHexGrid:rangeOfMovement(col, row, budget) -> table`: Returns reachable hex cells within a movement budget.
- `LHexGrid:setBlocked(col, row, blocked) -> nil`: Sets blocked state for a one-based hex cell.
- `LHexGrid:setCost(col, row, cost) -> nil`: Sets movement cost for a one-based hex cell.
- `LHexGrid:type() -> string`: Returns the Lua-visible type name for this hex grid handle.
- `LHexGrid:typeOf(name) -> boolean`: Returns whether this hex grid handle matches a supported type name.

#### LHexGridFieldOfViewResult Type

- Generated result shape from @field tags.

##### Fields

- `col` (`integer`): Col.
- `row` (`integer`): Row.

##### Methods

- No documented methods.

#### LHexGridFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `col` (`integer`): Col.
- `row` (`integer`): Row.

##### Methods

- No documented methods.

#### LHexGridRangeOfMovementResult Type

- Generated result shape from @field tags.

##### Fields

- `col` (`integer`): Col.
- `row` (`integer`): Row.

##### Methods

- No documented methods.

#### LInfluenceMap Type

- Lua handle for a grid-based influence map with named layers.

##### Fields

- No documented fields.

##### Methods

- `LInfluenceMap:addLayer(name) -> nil`: Adds an influence layer with the given name if it does not already exist.
- `LInfluenceMap:blend(layer_a, weight_a, layer_b, weight_b, dest) -> nil`: Blends two source layers into a destination layer using independent weights.
- `LInfluenceMap:clearAll() -> nil`: Clears every influence value in every layer.
- `LInfluenceMap:clearLayer(layer) -> nil`: Clears every value in a named influence layer.
- `LInfluenceMap:decay(layer, factor) -> nil`: Multiplies a named layer by a decay factor.
- `LInfluenceMap:getCellSize() -> number`: Returns the world size represented by each influence map cell.
- `LInfluenceMap:getHeight() -> integer`: Returns the influence map height in cells.
- `LInfluenceMap:getInfluence(layer, x, y) -> number`: Returns one cell value from a named influence layer using one-based cell coordinates.
- `LInfluenceMap:getMaxPosition(layer) -> integer, integer`: Returns the cell position with the highest value on a named layer.
- `LInfluenceMap:getMinPosition(layer) -> integer, integer`: Returns the cell position with the lowest value on a named layer.
- `LInfluenceMap:getWidth() -> integer`: Returns the influence map width in cells.
- `LInfluenceMap:hasLayer(name) -> boolean`: Returns whether an influence layer exists.
- `LInfluenceMap:propagate(layer, momentum?) -> nil`: Propagates influence values across neighboring cells on a named layer.
- `LInfluenceMap:queryRect(layer, wx, wy, ww, wh) -> number[]`: Returns influence values inside a world-space rectangle on a named layer.
- `LInfluenceMap:setInfluence(layer, x, y, value) -> nil`: Sets one cell value in a named influence layer using one-based cell coordinates.
- `LInfluenceMap:stampInfluence(layer, wx, wy, radius, value, falloff?) -> nil`: Applies a radial influence stamp to a named layer in world coordinates.
- `LInfluenceMap:type() -> string`: Returns the Lua-visible type name for this influence map handle.
- `LInfluenceMap:typeOf(name) -> boolean`: Returns whether this influence map handle matches a supported type name.

#### LIsoGrid Type

- Lua-side wrapper for an isometric navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LIsoGrid:findPath(fx, fy, tx, ty) -> table`: Finds a path between one-based isometric cells.
- `LIsoGrid:getCost(x, y) -> number`: Returns movement cost for a one-based isometric grid cell.
- `LIsoGrid:isBlocked(x, y) -> boolean`: Returns whether a one-based isometric grid cell is blocked.
- `LIsoGrid:setBlocked(x, y, blocked) -> nil`: Sets blocked state for a one-based isometric grid cell.
- `LIsoGrid:setCost(x, y, cost) -> nil`: Sets movement cost for a one-based isometric grid cell.
- `LIsoGrid:type() -> string`: Returns the Lua-visible type name for this isometric grid handle.
- `LIsoGrid:typeOf(name) -> boolean`: Returns whether this isometric grid handle matches a supported type name.

#### LIsoGridFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`integer`): X coordinate.
- `y` (`integer`): Y coordinate.

##### Methods

- No documented methods.

#### LJpsGrid Type

- Lua-side wrapper for a Jump Point Search grid.

##### Fields

- No documented fields.

##### Methods

- `LJpsGrid:findPath(fx, fy, tx, ty) -> table`: Finds a JPS path between one-based grid cells.
- `LJpsGrid:isBlocked(x, y) -> boolean`: Returns whether a one-based JPS grid cell is blocked.
- `LJpsGrid:setBlocked(x, y, blocked) -> nil`: Sets blocked state for a one-based JPS grid cell.
- `LJpsGrid:type() -> string`: Returns the Lua-visible type name for this JPS grid handle.
- `LJpsGrid:typeOf(name) -> boolean`: Returns whether this JPS grid handle matches a supported type name.

#### LJpsGridFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LNavGrid Type

- Lua userdata wrapper for a navigation grid and its optional HPA cache.

##### Fields

- No documented fields.

##### Methods

- `LNavGrid:beginUpdate() -> nil`: Starts a batched navigation edit that is finalized by `commitUpdate`.
- `LNavGrid:clearDirty() -> nil`: Clears all dirty region markers from the grid.
- `LNavGrid:commitUpdate(opts?) -> integer`: Finalizes a batched navigation edit and refreshes clearance caches according to `opts.rebuild`.
- `LNavGrid:defineFootprint(name, footprint) -> nil`: Stores or replaces a named rectangular footprint for clearance caching.
- `LNavGrid:fill(cost) -> nil`: Fills the entire grid with a uniform movement cost.
- `LNavGrid:fillRect(x, y, w, h, cost) -> nil`: Fills a one-based rectangular area with a movement cost.
- `LNavGrid:findHpaPath(sx, sy, gx, gy, unit_size?) -> table`: Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.
- `LNavGrid:findHpaPathsToGoal(starts, gx, gy, unit_size?) -> table`: Finds hierarchical paths from many one-based start cells to one goal while sharing one abstract-goal search setup.
- `LNavGrid:getChunkSize() -> integer`: Returns the hierarchical chunk size in cells.
- `LNavGrid:getCost(x, y) -> integer`: Returns movement cost at a one-based grid cell.
- `LNavGrid:getDiagonalMode() -> string`: Returns the current diagonal movement mode name.
- `LNavGrid:getDimensions() -> integer`: Returns grid width and height as two integers.
- `LNavGrid:getDirtyRects() -> table`: Returns the committed dirty rectangles recorded on this grid.
- `LNavGrid:getFootprint(name) -> table`: Returns the stored width and height for a named footprint when it exists.
- `LNavGrid:getGeneration() -> integer`: Returns the current navigation-grid generation used for cache invalidation.
- `LNavGrid:getHeight() -> integer`: Returns grid height from this object.
- `LNavGrid:getWidth() -> integer`: Returns grid width from this object.
- `LNavGrid:isBlocked(x, y) -> boolean`: Returns whether a one-based grid cell is blocked.
- `LNavGrid:isWalkable(x, y, unit_size?) -> boolean`: Returns whether a one-based grid cell is walkable for a unit size.
- `LNavGrid:isWalkableFor(name, x, y) -> boolean`: Returns whether a one-based grid cell is walkable for a named footprint.
- `LNavGrid:loadFromString(data) -> nil`: Loads grid data from a serialized binary string.
- `LNavGrid:rebuildAbstract() -> nil`: Rebuilds the cached abstract graph for this grid.
- `LNavGrid:rebuildClearance(opts?) -> integer`: Rebuilds clearance caches for all defined footprints or the supplied named subset.
- `LNavGrid:saveToString() -> string`: Saves grid data to a serialized binary string.
- `LNavGrid:setBlocked(x, y, blocked) -> nil`: Sets blocked state at a one-based grid cell.
- `LNavGrid:setBlockedRect(x, y, w, h, blocked, opts?) -> nil`: Applies one blocked or passable rectangle in batch-edit style.
- `LNavGrid:setChunkSize(size) -> nil`: Sets hierarchical chunk size for abstract graph partitioning.
- `LNavGrid:setCost(x, y, cost) -> nil`: Sets movement cost at a one-based grid cell.
- `LNavGrid:setCostRect(x, y, w, h, cost, opts?) -> nil`: Applies one cost rectangle in batch-edit style.
- `LNavGrid:setDiagonalMode(mode) -> nil`: Sets diagonal movement mode for this object.
- `LNavGrid:setDirty(x, y, w, h) -> nil`: Marks a one-based rectangular region dirty for incremental rebuild.
- `LNavGrid:type() -> string`: Returns the Lua-visible type name for this navigation grid handle.
- `LNavGrid:typeOf(name) -> boolean`: Returns whether this navigation grid handle matches a supported type name.

#### LNavGridDefineFootprintResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`integer`): Height in cells.
- `w` (`integer`): Width in cells.

##### Methods

- No documented methods.

#### LNavMesh Type

- Lua-side wrapper for a navigation mesh.

##### Fields

- No documented fields.

##### Methods

- `LNavMesh:addPolygon(vertices) -> integer`: Adds a polygon from vertex tables and returns a one-based id.
- `LNavMesh:connectPolygons(a, b, bidirectional?) -> boolean`: Connects two polygons by one-based id.
- `LNavMesh:findPath(sx, sy, gx, gy) -> table`: Finds a path through the navmesh between world points.
- `LNavMesh:getPolygonCount() -> integer`: Returns the total navmesh polygon count.
- `LNavMesh:type() -> string`: Returns the Lua-visible type name for this navmesh handle.
- `LNavMesh:typeOf(name) -> boolean`: Returns whether this navmesh handle matches a supported type name.

#### LNavMeshFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LORCASolver Type

- Lua handle for reciprocal velocity obstacle avoidance agents.

##### Fields

- No documented fields.

##### Methods

- `LORCASolver:addAgent(x, y, radius, max_speed) -> integer`: Adds an ORCA avoidance agent and returns its zero-based solver index.
- `LORCASolver:agentCount() -> integer`: Returns the number of ORCA agents in this solver.
- `LORCASolver:compute(dt_or_opts) -> nil`: Computes safe velocities for all ORCA agents, optionally under a time budget.
- `LORCASolver:getSafeVelocity(idx) -> number, number`: Returns the computed safe velocity for an ORCA agent addressed by zero-based index or stable key.
- `LORCASolver:getStats() -> table`: Returns statistics from the most recent ORCA compute step.
- `LORCASolver:removeAgent(idx) -> boolean`: Removes an ORCA agent addressed by zero-based index or stable key.
- `LORCASolver:setAgent(key, opts) -> nil`: Inserts or updates an ORCA avoidance agent under a stable caller-provided key.
- `LORCASolver:setCellSize(size) -> nil`: Sets the spatial-hash cell size used when grouping ORCA agents.
- `LORCASolver:setMaxNeighbors(count) -> nil`: Sets the maximum retained neighbor count used during one ORCA solve step.
- `LORCASolver:setNeighborRadius(radius) -> nil`: Sets an explicit neighbor-query radius in world units; zero restores dynamic per-agent radius.
- `LORCASolver:setPosition(idx, x, y) -> nil`: Sets the position for an ORCA agent addressed by zero-based index or stable key.
- `LORCASolver:setPreferredVelocity(idx, pvx, pvy) -> nil`: Sets the preferred velocity for an ORCA agent addressed by zero-based index or stable key.
- `LORCASolver:setVelocity(idx, vx, vy) -> nil`: Sets the current velocity for an ORCA agent addressed by zero-based index or stable key.
- `LORCASolver:type() -> string`: Returns the Lua-visible type name for this ORCA solver handle.
- `LORCASolver:typeOf(name) -> boolean`: Returns whether this ORCA solver handle matches a supported type name.

#### LPathGrid Type

- Lua-side wrapper for a cell-size path grid.

##### Fields

- No documented fields.

##### Methods

- `LPathGrid:findPath(sx, sy, gx, gy) -> table`: Finds a path between one-based path grid cells.
- `LPathGrid:findPathSmoothed(sx, sy, gx, gy) -> table`: Finds a smoothed path between one-based path grid cells.
- `LPathGrid:getCellSize() -> number`: Returns path grid cell size from this object.
- `LPathGrid:getCost(x, y) -> number`: Returns movement cost at a one-based cell.
- `LPathGrid:getHeight() -> integer`: Returns grid height from this object.
- `LPathGrid:getWidth() -> integer`: Returns grid width from this object.
- `LPathGrid:isWalkable(x, y) -> boolean`: Returns walkability at a one-based cell.
- `LPathGrid:setCost(x, y, cost) -> nil`: Sets movement cost at a one-based cell.
- `LPathGrid:setWalkable(x, y, w) -> nil`: Sets walkability at a one-based cell.
- `LPathGrid:type() -> string`: Returns the Lua-visible type name for this path grid handle.
- `LPathGrid:typeOf(name) -> boolean`: Returns whether this path grid handle matches a supported type name.

#### LPathGridFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LPathGridFindPathSmoothedResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LPathfindRangeMapResult Type

- Generated result shape from @field tags.

##### Fields

- `cells` (`table`): Array of reachable cell tables, each with integer x, y and number cost fields.
- `height` (`integer`): Grid height.
- `width` (`integer`): Grid width.

##### Methods

- No documented methods.

#### LSteeringManager Type

- Lua handle for a steering behavior stack that combines movement forces for an agent.

##### Fields

- No documented fields.

##### Methods

- `LSteeringManager:addArrive(tx, ty, slowing?, weight?) -> nil`: Adds an arrive behavior that slows the agent as it approaches a target point.
- `LSteeringManager:addCustomBehavior(func, weight?) -> nil`: Adds a custom steering behavior backed by a Lua callback.
- `LSteeringManager:addEvade(threat_name?, weight?) -> nil`: Adds an evade behavior that moves away from another named agent when a threat name is supplied.
- `LSteeringManager:addFlee(tx, ty, panic_dist?, weight?) -> nil`: Adds a flee behavior that pushes the agent away from a target point inside a panic distance.
- `LSteeringManager:addFlock(neighbor_radius?, sep_w?, align_w?, coh_w?, weight?) -> nil`: Adds a flocking behavior with separation, alignment, and cohesion weights.
- `LSteeringManager:addPursue(target_name?, weight?) -> nil`: Adds a pursue behavior that chases another named agent when a target name is supplied.
- `LSteeringManager:addSeek(tx, ty, weight?) -> nil`: Adds a seek behavior that pulls the agent toward a target point.
- `LSteeringManager:addWander(radius?, dist?, jitter?, weight?) -> nil`: Adds a wander behavior that produces jittered exploratory movement.
- `LSteeringManager:applyCustomSteering(agent, dt) -> number, number`: Runs enabled custom steering callbacks for an agent and returns the weighted combined force.
- `LSteeringManager:calculate(px, py, vx, vy, max_speed, max_force, dt) -> number, number`: Calculates a steering force for the supplied agent movement state.
- `LSteeringManager:clearEntities() -> nil`: Clears all steering-context entities.
- `LSteeringManager:clearPath() -> nil`: Clears the active waypoint path behavior.
- `LSteeringManager:enableSpatialHash(enabled) -> nil`: Enables or disables spatial hash acceleration for neighbor queries.
- `LSteeringManager:entityCount() -> integer`: Returns the number of steering-context entities.
- `LSteeringManager:getBehaviorCount() -> integer`: Returns the number of steering behaviors configured on this manager.
- `LSteeringManager:getCombineMode() -> string`: Returns the current steering force combination mode.
- `LSteeringManager:getLastDiagnostic() -> LuaValue`: Returns the most recent steering validation or runtime diagnostic.
- `LSteeringManager:getLastSteering() -> number, number`: Returns the last steering force calculated by this manager.
- `LSteeringManager:getPathProgress() -> integer, integer`: Returns the current one-based waypoint index and total waypoint count.
- `LSteeringManager:hasPath() -> boolean`: Returns whether this manager currently has an active waypoint path.
- `LSteeringManager:removeEntity(name) -> boolean`: Removes one named steering-context entity.
- `LSteeringManager:setCombineMode(mode) -> nil`: Sets how steering behavior forces are combined.
- `LSteeringManager:setEntity(name, x, y, vx?, vy?) -> nil`: Sets or replaces one named steering-context entity.
- `LSteeringManager:setPath(waypoints, reach_radius?, weight?) -> nil`: Sets a waypoint path behavior from an array of `{x, y}` tables.
- `LSteeringManager:setSpatialHashCellSize(size) -> nil`: Sets the cell size used by the steering manager spatial hash.
- `LSteeringManager:type() -> string`: Returns the Lua-visible type name for this steering manager handle.
- `LSteeringManager:typeOf(name) -> boolean`: Returns whether this steering manager handle matches a supported type name.

#### LUnitPathfinder Type

- Lua-side wrapper for a unit pathfinder over a navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LUnitPathfinder:clearCache() -> nil`: Clears all cached paths on this object.
- `LUnitPathfinder:clearReservations() -> integer`: Clears all caller-owned reserved cells.
- `LUnitPathfinder:clearSharedGoalCache() -> nil`: Clears all cached shared-goal fields on this object.
- `LUnitPathfinder:findAttackMovePaths(starts, gx, gy, unit_size?, max_steps?) -> table`: Finds one path per start toward a shared attack-move goal.
- `LUnitPathfinder:findFormationPaths(starts, gx, gy, unit_size?, spacing?) -> table`: Finds one path per start toward formation slots around a shared goal.
- `LUnitPathfinder:findNearestWalkable(x, y, max_radius, unit_size?) -> integer`: Finds nearest walkable one-based grid cell within a radius.
- `LUnitPathfinder:findPartialPath(x1, y1, x2, y2, max_nodes, unit_size?) -> table`: Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.
- `LUnitPathfinder:findPath(x1, y1, x2, y2, unit_size?) -> table`: Finds a path between one-based grid cells.
- `LUnitPathfinder:findPathBidirectional(x1, y1, x2, y2, unit_size?, max_nodes?) -> table`: Finds a path using bidirectional A* and returns completion status.
- `LUnitPathfinder:findPathSmooth(x1, y1, x2, y2, unit_size?) -> table`: Finds a smoothed path between one-based grid cells.
- `LUnitPathfinder:findPathsToGoal(starts, gx, gy, unit_size?, max_steps?) -> table`: Finds routes from many one-based start cells to one goal cell using one shared-goal field.
- `LUnitPathfinder:findPathsToGoalFor(name, starts, gx, gy, max_steps?) -> table`: Finds routes from many one-based start cells to one goal cell using one named-footprint shared-goal field.
- `LUnitPathfinder:getCacheSize() -> integer`: Returns the current path cache entry count.
- `LUnitPathfinder:getPathCost(path) -> number`: Returns the total movement cost along a waypoint path.
- `LUnitPathfinder:getPathLength(path) -> number`: Returns the total Euclidean length of a waypoint path.
- `LUnitPathfinder:getSharedFlowField(gx, gy, unit_size?) -> LFlowField`: Returns a cached shared-goal flow field handle for one target cell and unit footprint size.
- `LUnitPathfinder:getSharedFlowFieldFor(name, gx, gy) -> LFlowField`: Returns a cached shared-goal flow field handle for one target cell and one named footprint.
- `LUnitPathfinder:getSharedFlowFieldMulti(targets, unit_size?) -> LFlowField`: Returns a cached shared-goal flow field handle for many target cells and one unit footprint size.
- `LUnitPathfinder:getSharedFlowFieldMultiFor(name, targets) -> LFlowField`: Returns a cached shared-goal flow field handle for many target cells and one named footprint.
- `LUnitPathfinder:getSharedGoalCacheSize() -> integer`: Returns the current shared-goal field cache entry count.
- `LUnitPathfinder:getSharedGoalCacheStats() -> table`: Returns shared-goal flow-field cache counters for debugging and performance inspection.
- `LUnitPathfinder:heuristicDistance(x1, y1, x2, y2) -> number`: Returns heuristic distance between two one-based cells.
- `LUnitPathfinder:isCacheEnabled() -> boolean`: Returns whether the pathfinder's internal caches are enabled.
- `LUnitPathfinder:isReachable(x1, y1, x2, y2, unit_size?) -> boolean`: Returns whether a target cell is reachable from a start cell.
- `LUnitPathfinder:reserveCells(cells) -> integer`: Records caller-owned cell reservations for batch planning.
- `LUnitPathfinder:setCacheEnabled(enabled) -> nil`: Enables or disables the pathfinder's internal route and shared-goal caches on this object.
- `LUnitPathfinder:setCacheMaxSize(n) -> nil`: Sets maximum path cache size for this object.
- `LUnitPathfinder:type() -> string`: Returns the Lua-visible type name for this pathfinder handle.
- `LUnitPathfinder:typeOf(name) -> boolean`: Returns whether this pathfinder handle matches a supported type name.

#### LUnitPathfinderFindPartialPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LUnitPathfinderFindPathBidirectionalResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LUnitPathfinderFindPathResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LUnitPathfinderFindPathSmoothResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LUnitPathfinderGetSharedGoalCacheStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `hits` (`integer`): Cache hits since the last cache reset.
- `misses` (`integer`): Cache misses since the last cache reset.
- `size` (`integer`): Current number of cached shared-goal fields.

##### Methods

- No documented methods.

## Examples

- `content/examples/pathfind.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `pathfind` owns movement algorithms, movement range, route search, costs, reachability, influence maps, steering, context steering, and ORCA local avoidance. It does not own line-of-sight, line-of-action, lighting, object-profile semantics, or high-level decision models.
- `pathfind::graph_path` owns reusable integer-id graph traversal. Public Lua helpers `lurek.pathfind.graphRoute`, `graphRoutes`, `graphConnectedComponents`, and `graphConnected` accept ordinary edge tables, while territory registries remain in `province` and logistics flow simulation remains in `flownet`.
- `lurek.pathfind.newNavGridFromField(field, opts)`, `lurek.pathfind.newHexGridFromField(field, opts)`, and `lurek.pathfind.rangeMapFromField(field, opts)` are adapters from `lurek.tilefield`; by default they read the `"move"` channel and movement costs from the field. Use the hex adapter when the field topology is `hex`.
- `newNavGridFromTileMap` remains a compatibility path for projects that want direct tilemap-to-navigation conversion without adopting `tilefield`.
