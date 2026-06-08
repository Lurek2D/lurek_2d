# pathfind

## TL;DR

- Navigates grids, hex layouts, isometric maps, navmeshes, and province graphs.
- Employs A*, JPS, bidirectional search, HPA*, and async thread pools.
- Uses Dijkstra flow fields, tactical influence maps, and debug visual overlays.

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind/`
- Binding: `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`
- Lua API surface: `13` functions, `22` types, `104` methods
- Rust test path(s): tests/rust/unit/pathfinding_tests.rs
- Lua test path(s): tests/lua/unit/test_pathfind.lua, tests/lua/stress/test_pathfind_stress.lua, tests/lua/golden/test_pathfind_golden_grid.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_pathfind_ecs.lua, tests/lua/integration/test_ai_pathfind.lua

## Summary

- This module gives users a unified navigation toolkit across grid, hex, isometric, navmesh, and graph-based worlds.
- Standard grid pathfinding supports A*, Dijkstra, BFS, and related movement-query workflows.
- JPS support accelerates open-grid shortest-path searches.
- Bidirectional A* support improves long-distance query efficiency in many layouts.
- Hierarchical pathfinding support scales large-map queries through abstracted chunk-level routing.
- NavGrid APIs support walkability, cost weights, and variable-unit-size navigation constraints.
- Path smoothing helpers reduce noisy waypoint chains through line-of-sight checks.
- Partial-path and budgeted search modes support frame-time-safe fallback behavior.
- Async path pool support offloads heavy queries to worker threads.
- Cancellation support helps avoid wasting work on stale async requests.
- Flow-field support enables crowd movement toward goals with per-cell direction guidance.
- Goal-map support enables multi-source distance and flee-style gradient queries.
- Influence-map support enables tactical pressure fields with stamp, blur, and decay behaviors.
- Graph-nav support enables non-grid routing for province and abstract node networks.
- Province/path graph helpers support strategic map movement and region-level planning.
- Hex and isometric grid variants support non-rectangular movement models.
- Navmesh support enables polygonal traversal for open-area navigation.
- Range-map utilities support movement radius and reachable-area previews.
- Unit-pathfinder wrappers support per-agent cached path behavior.
- Debug rendering support visualizes paths, fields, and influence layers for tuning.
- Image export debug paths support snapshot-based validation workflows.
- The module is useful for AI locomotion, tactical planning, and player movement assistance.
- It centralizes navigation behaviors that are often fragmented across game systems.
- For users, this means consistent path semantics across very different map representations.
- It reduces bespoke path code and improves runtime observability.
- The practical result is more reliable movement behavior under scale.
- It also supports iteration speed through rich debugging surfaces.
- Overall, users get a comprehensive pathfinding and spatial-reasoning runtime.
- This makes advanced navigation systems feasible without custom engine rewrites.
- It bridges low-level search algorithms and gameplay-facing movement decisions.
- That bridge is critical in projects combining tactical AI, large worlds, and real-time constraints.
- Users can start simple and scale toward hierarchical and async strategies as complexity grows.
- The module keeps those strategies within one coherent API family.
- It supports both direct movement and higher-level strategic navigation logic.
- In short, it is the engine's navigation backbone for diverse world topologies.

## Imports

- `flownet`: Imports or references `src/flownet/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### ai_flow_field.rs

- Precomputed flow field steering many agents toward a single goal cell.
- Propagates breadth-first distance over 8-directional neighbours with diagonal cost.
- Stores per-cell direction vectors for smooth unit movement.
- Respects walkability masks when terrain blocks pathing.
- Gives group movement code a cheap steering target instead of a full path.

### astar.rs

- A* pathfinding on a NavGrid with diagonal modes and configurable unit sizes.
- Chooses octile or Manhattan heuristics to match the movement model.
- Stops early when a node budget is reached and falls back to a partial path.
- Uses Bresenham line-of-sight checks for path smoothing and validation.
- Removes redundant waypoints through string-pull smoothing.
- Serves as the standard single-unit shortest-path search for grid movement.

### async_pool.rs

- Fixed-size thread pool that runs A* pathfinding off the game thread.
- Submits jobs through channels and polls results without blocking.
- Shares one work queue across workers while skipping cancelled requests early.
- Gives pathfinding heavy workloads a parallel execution path.
- Keeps thread management isolated from callers.

### bidir.rs

- Bidirectional A* search that expands from both start and goal at once.
- Meets in the middle when the closed sets overlap to cut explored nodes.
- Falls back to a partial forward path when the node budget runs out.
- Respects NavGrid diagonal mode and per-cell movement cost.
- Supports variable unit sizes for multi-tile pathfinding.
- Helps large open grids return useful routes with less search work.

### flow_field.rs

- Dijkstra-based flow field seeded from one or more goal cells over a NavGrid.
- Stores normalized direction vectors toward the nearest goal beside accumulated cost.
- Supports variable unit sizes for clearance-aware pathfinding.
- Converts world-space positions into tile lookups and steering velocities.
- Includes debug visualisation for directions and obstacles.
- Provides the group-movement layer above raw path search.

### goal_map.rs

- Multi-source Dijkstra distance field for goal-oriented AI movement.
- Builds a cost-to-reach map from many weighted source cells.
- Returns downhill gradient, uphill flee direction, and flood-fill reachability.
- Supports custom blocker predicates during baking from Lua bindings.
- Serializes and restores the field as a compact binary blob.
- Gives AI code a reusable distance surface for steering and influence.

### graph_nav.rs

- A* shortest-path search over weighted directed or bidirectional graphs.
- Supports cost-bounded range queries for reachable nodes.
- Falls back to Dijkstra when no heuristic is provided.
- Reconstructs paths from predecessor maps for caller consumption.
- Serves graph-based navigation where grid adjacency is not enough.

### graph_path.rs

- Province-level A* pathfinding across adjacency graphs with configurable move costs.
- Adds Dijkstra-based reachability flooding for budget-limited travel.
- Models blocked provinces and edge-tag costs in the search cost.
- Uses a min-heap priority queue node for standard BinaryHeap ordering.
- Applies a Euclidean centroid heuristic for admissible A* search.
- Fits strategic map travel where regions, not cells, are the navigation unit.

### grid.rs

- Flat 2D grid storage with per-cell walkability flags and movement-cost values enabling pathfinding and navigation queries on tile-based maps.
- Implements A* algorithm with optional 8-connected diagonal movement, configurable Euclidean/Manhattan heuristics, and cached distance scoring.
- Supports Dijkstra and BFS variants for weighted multi-target distance fields and uniform-cost search enabling flow field and range queries.
- Provides efficient indexing, neighbor enumeration, and reconstruction helpers supporting O(log N) priority-queue based pathfinding.
- Integrates cell walkability validation preventing path generation through obstacles while respecting per-cell terrain movement costs.
- Serves as the fundamental navigation surface for grid-based game AI, unit movement, and tactical route planning across tile maps.

### hex_grid.rs

- Hex grid with configurable flat-top or pointy-top offset layout.
- Stores blocked flags and movement costs for weighted pathfinding.
- Runs A* search for shortest paths between hex cells.
- Exposes line-of-sight, field-of-view, and movement-range queries.
- Uses cube-coordinate math for distance, interpolation, and rounding.
- Fits tactics and map systems that need hex adjacency instead of squares.
- Keeps hex navigation self-contained and script-friendly.

### hpa.rs

- Hierarchical Pathfinding A* over a chunked NavGrid abstraction.
- Partitions the grid into fixed-size chunks and detects entrance nodes at boundaries.
- Builds an abstract graph of chunk-to-chunk edges with computed costs.
- Runs abstract A* search with an octile heuristic.
- Refines abstract waypoints back into full grid-level paths per segment.
- Supports BFS reachability checks over chunk connectivity.
- Temporarily inserts start and goal nodes for single-query routing.
- Handles both horizontal and vertical chunk boundaries.
- Accepts variable unit sizes through to the refinement stage.
- Cuts large map searches down to a smaller navigation graph first.

### influence_map.rs

- Grid-based influence map with named floating-point layers over a uniform cell grid.
- Stamps radial influence with falloff, smooths through neighbours, and decays over time.
- Queries aggregated influence in rectangles or locates extrema positions.
- Blends multiple layers into a destination layer with weighted combination.
- Exposes debug visualisation into an RGBA image for inspection.
- Serves tactical scoring and spatial pressure systems.

### iso_grid.rs

- Grid-based A* pathfinding over a rectangular isometric cell map.
- Stores blocked flags and movement costs for weighted searches.
- Uses Bresenham line-of-sight checks for visibility and smoothing support.
- Expands four-direction neighbours with bounds and passability filtering.
- Gives isometric tile worlds a direct path and visibility helper.

### jps.rs

- Jump Point Search optimized A* on uniform-cost 8-directional grids.
- Prunes symmetric neighbours to skip large open areas.
- Identifies forced neighbours and jump points along cardinal and diagonal directions.
- Reconstructs a full tile-by-tile path from the jump points.
- Uses an octile heuristic and a min-heap open list.
- Works best when long straight corridors dominate the map.
- Keeps uniform-grid search fast without changing the grid model.

### mod.rs

- Unified pathfinding module collecting grid-based (A*, Dijkstra, BFS, JPS) and graph-based (topological, bidirectional, HPA*) algorithms with unified API.
- Supports multiple navigation surface types (rectangular grids, hexagonal, isometric, navmeshes, province graphs) enabling diverse game world representations.
- Provides async path-request dispatch through thread pool enabling long-running queries without blocking game loop or frame timing.
- Includes debug rendering utilities for visualizing pathfinding structures, computed distances, flow fields, and path results during development.

### nav_grid.rs

- Integer-cost walkability grid for tile-based pathfinding.
- Stores per-cell movement weight where zero means blocked and higher values cost more.
- Exposes cardinal and diagonal neighbour queries with corner-cut policies.
- Tracks dirty rectangles for deferred HPA hierarchy invalidation.
- Supports bulk fill, rect fill, byte import/export, and snapshot cloning.
- Renders the grid and path overlay into ImageData for debug use.
- Forms the base grid model used by higher-level navigation layers.

### navmesh.rs

- Polygon-based navigation mesh for 2D pathfinding.
- Runs A* over a polygon adjacency graph with a centroid heuristic.
- Checks point containment with ray-cast tests and extracts centroid waypoints.
- Supports directed and bidirectional polygon connectivity.
- Serves large open areas where cell grids are too coarse.

### pathgrid.rs

- Grid-based A* pathfinding with 8-directional movement and variable cell costs.
- Uses Bresenham line-of-sight for path smoothing after search.
- Converts cell indices to world-space centres with configurable cell size.
- Prevents diagonal corner cutting through blocked corners.
- Uses an octile heuristic for consistent cost estimation.
- Gives tile maps a direct shortest-path implementation.

### range_map.rs

- Dijkstra-based budget-limited range expansion over a 2-D grid.
- Produces a cost map for cells reachable within a travel budget.
- Supports cardinal and diagonal movement with per-cell cost weights.
- Useful for movement preview, threat radius, and action-range queries.
- Keeps reachability and distance budgeting in one helper.

### render.rs

- Debug visualization for pathfinding structures as colored RenderCommand lists.
- Draws NavGrid cells, FlowField arrows, and InfluenceMap heat overlays.
- Returns batches ready for overlay drawing in the renderer.
- Gives developers a direct view into navigation data.
- Keeps visual inspection separate from path search logic.

### unit_pathfinder.rs

- Stateful per-unit pathfinder wrapping a shared NavGrid reference.
- Runs full A* searches with optional string-pull smoothing.
- Supports partial paths, BFS reachability, and nearest-walkable searches.
- Caches recent routes with an LRU strategy and manual invalidation.
- Exposes octile heuristic and Bresenham LOS helpers for local decisions.
- Gives each unit its own path search facade without duplicating grid data.

## Lua API Ref

### Functions

- `lurek.pathfind.getThreadCount() -> integer`: Returns the configured pathfinding thread count.
- `lurek.pathfind.newFlowField(grid_ud) -> LFlowField`: Creates a flow field for a navigation grid.
- `lurek.pathfind.newGoalMap(width, height) -> LGoalMap`: Creates a new multi-source Dijkstra distance-field goal map for the given grid dimensions.
- `lurek.pathfind.newHexGrid(width, height, layout_str?) -> LHexGrid`: Creates a hex grid with the given dimensions.
- `lurek.pathfind.newJpsGrid(width, height) -> LJpsGrid`: Creates a Jump Point Search grid with given dimensions.
- `lurek.pathfind.newNavGrid(width, height) -> LNavGrid`: Creates a navigation grid with the given dimensions.
- `lurek.pathfind.newNavGridFromTileMap(tm_ud, layer_index, blocked_table) -> LNavGrid`: Creates a navigation grid from a tilemap layer and blocked gid table.
- `lurek.pathfind.newNavMesh() -> LNavMesh`: Creates an empty navigation mesh for polygon-based pathfinding.
- `lurek.pathfind.newPathFlowField(grid_ud) -> LAIFlowField`: Creates an AI flow field from a path grid.
- `lurek.pathfind.newPathGrid(w, h, cell_size) -> LPathGrid`: Creates a cell-size path grid with given dimensions.
- `lurek.pathfind.newPathfinder(grid_ud) -> LUnitPathfinder`: Creates a unit pathfinder for a navigation grid.
- `lurek.pathfind.rangeMap(opts) -> table`: Computes reachable cells from range map options.
- `lurek.pathfind.setThreadCount(count) -> nil`: Sets the configured pathfinding worker-thread count.

### Callbacks

- `LGoalMap:setBlocker` param `fn` (`function`): `fn(x: integer, y: integer) -> boolean` (one-based).

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

#### LFlowField Type

- Lua-side wrapper for a flow field over a navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LFlowField:calculate(tx, ty, unit_size?) -> nil`: Calculates a flow field toward one target cell.
- `LFlowField:calculateMulti(targets, unit_size?) -> nil`: Calculates a flow field toward multiple target cells.
- `LFlowField:getCostToTarget(x, y) -> number`: Returns integration cost to the target from a one-based grid cell.
- `LFlowField:getDirection(x, y) -> number`: Returns flow direction vector at a one-based grid cell.
- `LFlowField:getDirectionAngle(x, y) -> number`: Returns flow direction angle at a one-based grid cell.
- `LFlowField:getTargets() -> table`: Returns target cells for this flow field.
- `LFlowField:isCalculated() -> boolean`: Returns whether the flow field has been calculated.
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
- `LHexGrid:lineOfSight(fc, fr, tc, tr) -> boolean`: Returns whether two one-based hex cells have line of sight.
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

- Lua-side wrapper for a navigation grid and optional abstract graph cache.

##### Fields

- No documented fields.

##### Methods

- `LNavGrid:clearDirty() -> nil`: Clears all dirty region markers from the grid.
- `LNavGrid:fill(cost) -> nil`: Fills the entire grid with a uniform movement cost.
- `LNavGrid:fillRect(x, y, w, h, cost) -> nil`: Fills a one-based rectangular area with a movement cost.
- `LNavGrid:findHpaPath(sx, sy, gx, gy, unit_size?) -> table`: Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.
- `LNavGrid:getChunkSize() -> integer`: Returns the hierarchical chunk size in cells.
- `LNavGrid:getCost(x, y) -> integer`: Returns movement cost at a one-based grid cell.
- `LNavGrid:getDiagonalMode() -> string`: Returns the current diagonal movement mode name.
- `LNavGrid:getDimensions() -> integer`: Returns grid width and height as two integers.
- `LNavGrid:getHeight() -> integer`: Returns grid height from this object.
- `LNavGrid:getWidth() -> integer`: Returns grid width from this object.
- `LNavGrid:isBlocked(x, y) -> boolean`: Returns whether a one-based grid cell is blocked.
- `LNavGrid:isWalkable(x, y, unit_size?) -> boolean`: Returns whether a one-based grid cell is walkable for a unit size.
- `LNavGrid:loadFromString(data) -> nil`: Loads grid data from a serialized binary string.
- `LNavGrid:rebuildAbstract() -> nil`: Rebuilds the cached abstract graph for this grid.
- `LNavGrid:saveToString() -> string`: Saves grid data to a serialized binary string.
- `LNavGrid:setBlocked(x, y, blocked) -> nil`: Sets blocked state at a one-based grid cell.
- `LNavGrid:setChunkSize(size) -> nil`: Sets hierarchical chunk size for abstract graph partitioning.
- `LNavGrid:setCost(x, y, cost) -> nil`: Sets movement cost at a one-based grid cell.
- `LNavGrid:setDiagonalMode(mode) -> nil`: Sets diagonal movement mode for this object.
- `LNavGrid:setDirty(x, y, w, h) -> nil`: Marks a one-based rectangular region dirty for incremental rebuild.
- `LNavGrid:type() -> string`: Returns the Lua-visible type name for this navigation grid handle.
- `LNavGrid:typeOf(name) -> boolean`: Returns whether this navigation grid handle matches a supported type name.

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

#### LUnitPathfinder Type

- Lua-side wrapper for a unit pathfinder over a navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LUnitPathfinder:clearCache() -> nil`: Clears all cached paths on this object.
- `LUnitPathfinder:findNearestWalkable(x, y, max_radius, unit_size?) -> integer`: Finds nearest walkable one-based grid cell within a radius.
- `LUnitPathfinder:findPartialPath(x1, y1, x2, y2, max_nodes, unit_size?) -> table`: Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.
- `LUnitPathfinder:findPath(x1, y1, x2, y2, unit_size?) -> table`: Finds a path between one-based grid cells.
- `LUnitPathfinder:findPathBidirectional(x1, y1, x2, y2, unit_size?, max_nodes?) -> table`: Finds a path using bidirectional A* and returns completion status.
- `LUnitPathfinder:findPathSmooth(x1, y1, x2, y2, unit_size?) -> table`: Finds a smoothed path between one-based grid cells.
- `LUnitPathfinder:getCacheSize() -> integer`: Returns the current path cache entry count.
- `LUnitPathfinder:getPathCost(path) -> number`: Returns the total movement cost along a waypoint path.
- `LUnitPathfinder:getPathLength(path) -> number`: Returns the total Euclidean length of a waypoint path.
- `LUnitPathfinder:heuristicDistance(x1, y1, x2, y2) -> number`: Returns heuristic distance between two one-based cells.
- `LUnitPathfinder:isCacheEnabled() -> boolean`: Returns whether path cache is enabled.
- `LUnitPathfinder:isReachable(x1, y1, x2, y2, unit_size?) -> boolean`: Returns whether a target cell is reachable from a start cell.
- `LUnitPathfinder:lineOfSight(x1, y1, x2, y2, unit_size?) -> boolean`: Returns whether two one-based cells have line of sight.
- `LUnitPathfinder:setCacheEnabled(enabled) -> nil`: Enables or disables the path cache on this object.
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
