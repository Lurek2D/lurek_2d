# pathfind

## TL;DR

- The `pathfind` module provides grid, graph, flow-field, and navmesh navigation systems with synchronous and async path query support.

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind/`
- Binding: `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`
- Lua API surface: `13` functions, `22` types, `104` methods
- Rust test path(s): tests/rust/unit/pathfinding_tests.rs
- Lua test path(s): tests/lua/unit/test_pathfind.lua, tests/lua/stress/test_pathfind_stress.lua, tests/lua/golden/test_pathfind_golden_grid.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_pathfind_ecs.lua, tests/lua/integration/test_ai_pathfind.lua

## Summary

The `pathfind` module is the navigation toolbox for movement and route reasoning across different world representations. It supports cell grids, graph navigation, flow fields, and mesh-like traversal so games can choose the model that fits each system.

On grid-based maps, the module provides classic and optimized search paths such as A*, Dijkstra, BFS, and Jump Point Search. Movement rules include costs, blockers, diagonal policies, and clearance constraints, which keeps path outputs aligned with actual gameplay collision assumptions.

For larger maps and multi-agent workloads, it includes hierarchical and field-based techniques. HPA-style abstraction reduces long-distance search cost, while flow-field navigation lets many agents share directional guidance toward goals.

Alternative layouts are first-class rather than add-ons. Hex and isometric helpers provide layout-specific queries, and graph/navmesh paths cover non-rectangular or region-based traversal styles.

Beyond shortest-path queries, the module supports planning and control use cases. Distance maps, influence surfaces, visibility checks, and reachability queries help AI decide not only where to go, but also where to hold, avoid, flank, or regroup. This allows one module to support both tactical movement and strategic positioning.

It also scales from single-unit requests to high-volume workloads. Async pools keep expensive path jobs off the main update path, while deterministic polling lets callers integrate results without frame stalls. This is important for games that mix player navigation, NPC routing, and background simulation in the same frame budget.

Debug-facing outputs and utility queries make behavior easier to inspect. Teams can test map assumptions, verify blocked corridors, and audit traversal policies directly through the same API family used in production scripts.

Async execution support keeps heavy path requests off the main loop when needed. In practice, `lurek.pathfind` provides one complete routing contract: represent space, query routes, compute reachability, and integrate deterministic navigation results into AI and gameplay logic.

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

- Flat 2-D grid with per-cell walkability and movement-cost storage.
- Provides A* with optional diagonal movement and selectable heuristics.
- Includes Dijkstra and BFS variants for weighted and uniform-cost search.
- Builds flow fields from a single goal cell for steering behavior.
- Keeps internal heap and path reconstruction helpers close to the grid model.
- Supports movement-cost lookups suitable for tile-based gameplay maps.
- Acts as the basic navigation surface for cell-level routing.

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

- Grid-based and graph-based pathfinding algorithms for cells, graphs, and flow fields.
- Collects A*, bidirectional search, JPS, HPA*, goal maps, and influence maps under one namespace.
- Includes grid, hex, isometric, and navmesh navigation surfaces.
- Keeps async dispatch and debug rendering close to the rest of the pathfinding stack.

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

- `lurek.pathfind.getThreadCount`: Returns the configured pathfinding thread count.
- `lurek.pathfind.newFlowField`: Creates a flow field for a navigation grid.
- `lurek.pathfind.newGoalMap`: Creates a new multi-source Dijkstra distance-field goal map for the given grid dimensions.
- `lurek.pathfind.newHexGrid`: Creates a hex grid with the given dimensions.
- `lurek.pathfind.newJpsGrid`: Creates a Jump Point Search grid with given dimensions.
- `lurek.pathfind.newNavGrid`: Creates a navigation grid with the given dimensions.
- `lurek.pathfind.newNavGridFromTileMap`: Creates a navigation grid from a tilemap layer and blocked gid table.
- `lurek.pathfind.newNavMesh`: Creates an empty navigation mesh for polygon-based pathfinding.
- `lurek.pathfind.newPathFlowField`: Creates an AI flow field from a path grid.
- `lurek.pathfind.newPathGrid`: Creates a cell-size path grid with given dimensions.
- `lurek.pathfind.newPathfinder`: Creates a unit pathfinder for a navigation grid.
- `lurek.pathfind.rangeMap`: Computes reachable cells from range map options.
- `lurek.pathfind.setThreadCount`: Sets the configured pathfinding worker-thread count.

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

- `LAIFlowField:getDirection`: Returns flow direction vector for a one-based cell.
- `LAIFlowField:getDistance`: Returns distance to goal for a one-based cell.
- `LAIFlowField:getGoal`: Returns the one-based flow field goal, or nil when no goal is set.
- `LAIFlowField:getHeight`: Returns flow field height from this object.
- `LAIFlowField:getWidth`: Returns flow field width from this object.
- `LAIFlowField:hasGoal`: Returns whether a flow field goal is currently set.
- `LAIFlowField:setGoal`: Sets the one-based flow field goal and recalculates the field.
- `LAIFlowField:type`: Returns the Lua-visible type name for this AI flow field handle.
- `LAIFlowField:typeOf`: Returns whether this AI flow field handle matches a supported type name.

#### LFlowField Type

- Lua-side wrapper for a flow field over a navigation grid.

##### Fields

- No documented fields.

##### Methods

- `LFlowField:calculate`: Calculates a flow field toward one target cell.
- `LFlowField:calculateMulti`: Calculates a flow field toward multiple target cells.
- `LFlowField:getCostToTarget`: Returns integration cost to the target from a one-based grid cell.
- `LFlowField:getDirection`: Returns flow direction vector at a one-based grid cell.
- `LFlowField:getDirectionAngle`: Returns flow direction angle at a one-based grid cell.
- `LFlowField:getTargets`: Returns target cells for this flow field.
- `LFlowField:isCalculated`: Returns whether the flow field has been calculated.
- `LFlowField:steer`: Returns a steering velocity for a world position using the flow field.
- `LFlowField:type`: Returns the Lua-visible type name for this flow field handle.
- `LFlowField:typeOf`: Returns whether this flow field handle matches a supported type name.

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

- `LGoalMap:addSource`: Registers a source cell for this goal map. Coordinates are one-based.
- `LGoalMap:bake`: Runs multi-source Dijkstra to build the distance field using the registered blocker.
- `LGoalMap:clearSources`: Removes all registered source cells.
- `LGoalMap:distanceAt`: Returns the minimum cost from (x, y) to the nearest source.
- `LGoalMap:flee`: Returns a normalised direction vector pointing away from sources (for fleeing NPCs).
- `LGoalMap:floodFill`: Returns all cells reachable from (cx, cy) within `threshold` steps.
- `LGoalMap:gradientAt`: Returns a normalised direction vector pointing toward the nearest source.
- `LGoalMap:isReady`: Returns true when the distance field has been baked and not invalidated.
- `LGoalMap:restore`: Restores a distance field from a blob produced by `save`.
- `LGoalMap:save`: Serialises the current distance field to a binary blob string.
- `LGoalMap:setBlocker`: Sets a Lua predicate called during `bake` to determine blocked cells.
- `LGoalMap:setSources`: Replaces all registered source cells. Each entry must have x, y (one-based) and optional weight.
- `LGoalMap:type`: Returns the Lua-visible type name for this goal map handle.
- `LGoalMap:typeOf`: Returns whether this goal map handle matches a supported type name.

#### LHexGrid Type

- Lua-side wrapper for a hexagonal grid.

##### Fields

- No documented fields.

##### Methods

- `LHexGrid:distance`: Returns hex distance between two one-based hex cells.
- `LHexGrid:fieldOfView`: Returns visible hex cells within range from an origin.
- `LHexGrid:findPath`: Finds a path between one-based hex cells.
- `LHexGrid:isBlocked`: Returns whether a one-based hex cell is blocked.
- `LHexGrid:lineOfSight`: Returns whether two one-based hex cells have line of sight.
- `LHexGrid:rangeOfMovement`: Returns reachable hex cells within a movement budget.
- `LHexGrid:setBlocked`: Sets blocked state for a one-based hex cell.
- `LHexGrid:setCost`: Sets movement cost for a one-based hex cell.
- `LHexGrid:type`: Returns the Lua-visible type name for this hex grid handle.
- `LHexGrid:typeOf`: Returns whether this hex grid handle matches a supported type name.

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

- `LJpsGrid:findPath`: Finds a JPS path between one-based grid cells.
- `LJpsGrid:isBlocked`: Returns whether a one-based JPS grid cell is blocked.
- `LJpsGrid:setBlocked`: Sets blocked state for a one-based JPS grid cell.
- `LJpsGrid:type`: Returns the Lua-visible type name for this JPS grid handle.
- `LJpsGrid:typeOf`: Returns whether this JPS grid handle matches a supported type name.

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

- `LNavGrid:clearDirty`: Clears all dirty region markers from the grid.
- `LNavGrid:fill`: Fills the entire grid with a uniform movement cost.
- `LNavGrid:fillRect`: Fills a one-based rectangular area with a movement cost.
- `LNavGrid:findHpaPath`: Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.
- `LNavGrid:getChunkSize`: Returns the hierarchical chunk size in cells.
- `LNavGrid:getCost`: Returns movement cost at a one-based grid cell.
- `LNavGrid:getDiagonalMode`: Returns the current diagonal movement mode name.
- `LNavGrid:getDimensions`: Returns grid width and height as two integers.
- `LNavGrid:getHeight`: Returns grid height from this object.
- `LNavGrid:getWidth`: Returns grid width from this object.
- `LNavGrid:isBlocked`: Returns whether a one-based grid cell is blocked.
- `LNavGrid:isWalkable`: Returns whether a one-based grid cell is walkable for a unit size.
- `LNavGrid:loadFromString`: Loads grid data from a serialized binary string.
- `LNavGrid:rebuildAbstract`: Rebuilds the cached abstract graph for this grid.
- `LNavGrid:saveToString`: Saves grid data to a serialized binary string.
- `LNavGrid:setBlocked`: Sets blocked state at a one-based grid cell.
- `LNavGrid:setChunkSize`: Sets hierarchical chunk size for abstract graph partitioning.
- `LNavGrid:setCost`: Sets movement cost at a one-based grid cell.
- `LNavGrid:setDiagonalMode`: Sets diagonal movement mode for this object.
- `LNavGrid:setDirty`: Marks a one-based rectangular region dirty for incremental rebuild.
- `LNavGrid:type`: Returns the Lua-visible type name for this navigation grid handle.
- `LNavGrid:typeOf`: Returns whether this navigation grid handle matches a supported type name.

#### LNavMesh Type

- Lua-side wrapper for a navigation mesh.

##### Fields

- No documented fields.

##### Methods

- `LNavMesh:addPolygon`: Adds a polygon from vertex tables and returns a one-based id.
- `LNavMesh:connectPolygons`: Connects two polygons by one-based id.
- `LNavMesh:findPath`: Finds a path through the navmesh between world points.
- `LNavMesh:getPolygonCount`: Returns the total navmesh polygon count.
- `LNavMesh:type`: Returns the Lua-visible type name for this navmesh handle.
- `LNavMesh:typeOf`: Returns whether this navmesh handle matches a supported type name.

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

- `LPathGrid:findPath`: Finds a path between one-based path grid cells.
- `LPathGrid:findPathSmoothed`: Finds a smoothed path between one-based path grid cells.
- `LPathGrid:getCellSize`: Returns path grid cell size from this object.
- `LPathGrid:getCost`: Returns movement cost at a one-based cell.
- `LPathGrid:getHeight`: Returns grid height from this object.
- `LPathGrid:getWidth`: Returns grid width from this object.
- `LPathGrid:isWalkable`: Returns walkability at a one-based cell.
- `LPathGrid:setCost`: Sets movement cost at a one-based cell.
- `LPathGrid:setWalkable`: Sets walkability at a one-based cell.
- `LPathGrid:type`: Returns the Lua-visible type name for this path grid handle.
- `LPathGrid:typeOf`: Returns whether this path grid handle matches a supported type name.

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

- `LUnitPathfinder:clearCache`: Clears all cached paths on this object.
- `LUnitPathfinder:findNearestWalkable`: Finds nearest walkable one-based grid cell within a radius.
- `LUnitPathfinder:findPartialPath`: Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.
- `LUnitPathfinder:findPath`: Finds a path between one-based grid cells.
- `LUnitPathfinder:findPathBidirectional`: Finds a path using bidirectional A* and returns completion status.
- `LUnitPathfinder:findPathSmooth`: Finds a smoothed path between one-based grid cells.
- `LUnitPathfinder:getCacheSize`: Returns the current path cache entry count.
- `LUnitPathfinder:getPathCost`: Returns the total movement cost along a waypoint path.
- `LUnitPathfinder:getPathLength`: Returns the total Euclidean length of a waypoint path.
- `LUnitPathfinder:heuristicDistance`: Returns heuristic distance between two one-based cells.
- `LUnitPathfinder:isCacheEnabled`: Returns whether path cache is enabled.
- `LUnitPathfinder:isReachable`: Returns whether a target cell is reachable from a start cell.
- `LUnitPathfinder:lineOfSight`: Returns whether two one-based cells have line of sight.
- `LUnitPathfinder:setCacheEnabled`: Enables or disables the path cache on this object.
- `LUnitPathfinder:setCacheMaxSize`: Sets maximum path cache size for this object.
- `LUnitPathfinder:type`: Returns the Lua-visible type name for this pathfinder handle.
- `LUnitPathfinder:typeOf`: Returns whether this pathfinder handle matches a supported type name.

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
