# pathfind

## TL;DR

- The `pathfind` module is a comprehensive Feature Systems tier library providing a vast array of pathfinding algorithms and spatial reasoning tools for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind/`
- Lua API path(s): `src/lua_api/pathfind_api.rs`
- Primary Lua namespace: `lurek.pathfind`
- Rust test path(s): tests/rust/unit/pathfinding_tests.rs
- Lua test path(s): tests/lua/unit/test_pathfind.lua, tests/lua/stress/test_pathfind_stress.lua, tests/lua/golden/test_pathfind_golden_grid.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_pathfind_ecs.lua, tests/lua/integration/test_ai_pathfind.lua

## Summary

It is designed to handle everything from simple grid-based movement to complex, multi-agent AI steering and hierarchical navigation. The foundation of the module is the `NavGrid`, a robust 2D grid structure supporting per-cell walkability masks, integer-based movement costs, and configurable diagonal movement policies (with corner-cutting prevention). On top of this, the module implements classical algorithms like A* (with octile or Manhattan heuristics), Dijkstra's algorithm for cost-weighted reachability, and unweighted BFS. For high-performance uniform-cost grids, it features Jump Point Search (JPS), which dramatically accelerates A* by pruning symmetric neighbors.

To address the challenges of large open worlds and massive agent counts, the module includes several advanced AI pathing techniques. Hierarchical Pathfinding A* (HPA*) partitions grids into chunks, building an abstract graph of boundary entrances to allow near-instant long-distance path planning that is later refined into tile-by-tile routes. For crowd simulation, the `FlowField` and `ai_flow_field` structures precompute directional vectors across a grid toward a specific goal, allowing hundreds of agents to steer smoothly without calculating individual paths. Additionally, the `InfluenceMap` system allows developers to propagate, blend, and decay scalar values across grids—perfect for tactical AI to evaluate threat levels, control zones, or attractive points of interest.

Beyond standard square grids, the module offers extensive support for alternative spatial layouts. It includes a fully featured `HexGrid` with cube-coordinate math, supporting both pointy-top and flat-top layouts, alongside specific line-of-sight and field-of-view queries. An `IsoGrid` provides specialized routing for isometric map layouts. For non-grid environments, the `NavMesh` structure allows A* routing across connected arbitrary polygons, extracting smoothed centroid corridors. To ensure pathfinding never stalls the primary game loop, the module features a dedicated `PathThreadPool`, allowing asynchronous, off-thread path requests via non-blocking channels. Finally, the `UnitPathfinder` provides a high-level, stateful wrapper for individual agents, handling path caching, variable unit sizes (clearance checks), partial paths, and string-pull smoothing. The entire suite is accessible via the `lurek.pathfind.*` Lua API.

## Files

### ai_flow_field.rs

- Precomputed flow field steering multiple agents toward a single goal cell.
- BFS distance propagation with 8-directional neighbours and diagonal cost.
- Per-cell normalised direction vectors for smooth unit movement.
- Walkability mask support for blocking impassable terrain.

### astar.rs

- A\* pathfinding on a `NavGrid` with configurable diagonal modes and unit sizes.
- Heuristic selection: octile distance for diagonal movement, Manhattan otherwise.
- Early termination via `max_nodes` with partial-path fallback to closest reached cell.
- Bresenham line-of-sight checks for walkability validation.
- String-pull path smoothing that removes redundant waypoints.

### async_pool.rs

- Fixed-size thread pool that runs A* pathfinding off the game thread.
- Job submission, cancellation, and non-blocking result polling via channels.
- Workers share a single work queue and skip cancelled requests early.

### bidir.rs

- Bidirectional A* search that expands from both start and goal simultaneously.
- Meets in the middle when both closed sets overlap, halving explored nodes on large grids.
- Falls back to a partial forward path when the node budget is exhausted.
- Respects NavGrid diagonal mode and per-cell movement cost.
- Supports variable unit sizes for multi-tile pathfinding.

### flow_field.rs

- Dijkstra-based flow field that seeds from one or more goal cells and computes shortest paths across a NavGrid.
- Each reachable cell stores a normalised direction vector toward the nearest goal and its accumulated travel cost.
- Supports variable unit sizes for clearance-aware pathfinding using the backing grid's walkability checks.
- Provides world-space steering that converts pixel coordinates to tile lookups and returns a scaled velocity.
- Includes a debug visualisation helper that renders the field directions and obstacles to an ImageData bitmap.

### goal_map.rs

- Multi-source Dijkstra distance field for goal-oriented AI movement.
- Builds a cost-to-reach field from N weighted source cells.
- `gradient_at` returns the downhill direction (move toward goal).
- `flee_at` returns the uphill direction (move away from goal).
- `flood_fill` returns all reachable cells within a distance threshold.
- `bake` accepts a generic blocker predicate; call from Lua bindings.
- `save` / `restore` serialise the distance field as a compact binary blob.

### graph_nav.rs

- A* shortest-path search over weighted directed/bidirectional graphs.
- Range query returning all nodes reachable within a cost budget.
- Heuristic support for informed search; falls back to Dijkstra when omitted.
- Min-heap priority queue node with reverse ordering for `BinaryHeap`.
- Path reconstruction from predecessor map.

### graph_path.rs

- Province-level A* pathfinding across adjacency graphs with configurable move costs.
- Dijkstra-based reachability flood to find all provinces within a cost budget.
- Per-province and per-edge-tag cost modelling with blocked-province exclusion.
- Min-heap priority queue node with reverse ordering for standard `BinaryHeap`.
- Euclidean centroid heuristic for A* admissibility.

### grid.rs

- Flat 2-D grid with per-cell walkability and movement-cost storage.
- A* pathfinding with optional diagonal movement and Euclidean/Manhattan heuristic.
- Dijkstra shortest-path search respecting per-cell costs.
- BFS unweighted shortest path for uniform-cost grids.
- Dijkstra-based flow-field generation toward a single goal cell.
- Internal min-heap node and path reconstruction utilities.

### hex_grid.rs

- Hex grid with configurable flat-top or pointy-top offset layout.
- Per-cell blocked flags and movement cost for weighted pathfinding.
- A* search returning shortest path between two hex cells.
- Line-of-sight, field-of-view, and range-of-movement queries.
- Cube-coordinate math for distance, interpolation, and rounding.

### hpa.rs

- Hierarchical Pathfinding A* (HPA*) over a chunked NavGrid abstraction.
- Partition the grid into fixed-size chunks and detect entrance nodes at chunk boundaries.
- Build an abstract graph of entrance-to-entrance edges with A*-computed costs.
- Run abstract-level A* search using octile distance heuristic.
- Refine abstract waypoints back into full grid-level paths via per-segment A*.
- BFS-based reachability test over chunk connectivity without computing a full path.
- Temporary start/goal insertion into the abstract graph for single queries.
- Boundary scanning logic handles both horizontal and vertical chunk edges.
- Supports variable unit sizes passed through to underlying A* refinement.

### influence_map.rs

- Grid-based influence map with named floating-point layers over a uniform cell grid.
- Stamp radial influence with distance falloff, propagate via neighbourhood smoothing, and decay over time.
- Query aggregated influence inside world-space rectangles or locate extrema positions.
- Blend multiple layers with weighted combination into a destination layer.
- Debug visualisation rendering layers into an RGBA image for inspection.

### iso_grid.rs

- Grid-based A* pathfinding over a rectangular isometric cell map.
- Per-cell blocked flags and movement cost support for weighted searches.
- Bresenham line-of-sight query between two grid positions.
- 4-directional neighbour expansion with bounds and passability filtering.

### jps.rs

- Jump Point Search (JPS) optimised A* on uniform-cost 8-directional grids.
- Prunes symmetric neighbours to skip large open areas without expanding every cell.
- Identifies forced neighbours and jump points along cardinal and diagonal directions.
- Produces a full tile-by-tile path by interpolating between jump points.
- Uses octile distance heuristic and a min-heap open list.

### mod.rs

- Grid-based and graph-based pathfinding algorithms (A*, bidirectional, JPS, HPA*).
- `GoalMap`: multi-source Dijkstra distance field for goal-oriented AI movement.
- Flow fields and influence maps for group movement and tactical queries.
- Navigation grids, hex grids, isometric grids, and navmesh support.
- Async thread-pool dispatch for off-thread path computation.

### nav_grid.rs

- Integer-cost walkability grid for tile-based pathfinding.
- Per-cell movement weight (0 = blocked, 1–254 = traversal cost).
- Cardinal and diagonal neighbour queries with corner-cut policies.
- Dirty-rectangle tracking for deferred HPA* hierarchy invalidation.
- Bulk fill, rect fill, byte import/export, and deep-copy snapshot.
- Debug visualisation: render grid + path overlay to an ImageData buffer.

### navmesh.rs

- Polygon-based navigation mesh for 2D pathfinding.
- A\* search over polygon adjacency graph with centroid heuristic.
- Ray-cast point-in-polygon containment test.
- Centroid waypoint extraction from polygon corridors.
- Directed and bidirectional polygon connectivity.

### pathgrid.rs

- Grid-based A* pathfinding with 8-directional movement and variable cell costs.
- Bresenham line-of-sight checks for post-search path smoothing (string-pull).
- World-space coordinate conversion: cell indices map to centres via configurable cell size.
- Diagonal corner-cutting prevention to avoid clipping through blocked corners.
- Octile distance heuristic for consistent and admissible cost estimation.

### range_map.rs

- Dijkstra-based budget-limited range expansion over a 2D grid.
- Produces a cost map showing which cells are reachable within a travel budget.
- Supports cardinal and diagonal movement with per-cell cost weights.

### render.rs

- Debug visualization for pathfinding structures as colored `RenderCommand` lists.
- NavGrid renders walkable/blocked cells, FlowField draws directional arrows, InfluenceMap shows signed heat.
- Each struct exposes `generate_render_commands` returning a `Vec<RenderCommand>` for overlay drawing.

### unit_pathfinder.rs

- Stateful per-unit pathfinder wrapping a shared `NavGrid` reference.
- Full A* path search with optional string-pull smoothing for shorter results.
- Partial-path expansion with configurable node budget for real-time budgets.
- BFS reachability test and nearest-walkable-cell search within a radius.
- LRU path cache with configurable max size and manual invalidation.
- Octile heuristic and Bresenham line-of-sight utility helpers.

## Lua API Ref

- Binding: `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LAIFlowField Type


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


#### LGoalMap Type


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


#### LJpsGrid Type


##### Fields

- No documented fields.

##### Methods

- `LJpsGrid:findPath`: Finds a JPS path between one-based grid cells.
- `LJpsGrid:isBlocked`: Returns whether a one-based JPS grid cell is blocked.
- `LJpsGrid:setBlocked`: Sets blocked state for a one-based JPS grid cell.
- `LJpsGrid:type`: Returns the Lua-visible type name for this JPS grid handle.
- `LJpsGrid:typeOf`: Returns whether this JPS grid handle matches a supported type name.


#### LNavGrid Type


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


##### Fields

- No documented fields.

##### Methods

- `LNavMesh:addPolygon`: Adds a polygon from vertex tables and returns a one-based id.
- `LNavMesh:connectPolygons`: Connects two polygons by one-based id.
- `LNavMesh:findPath`: Finds a path through the navmesh between world points.
- `LNavMesh:getPolygonCount`: Returns the total navmesh polygon count.
- `LNavMesh:type`: Returns the Lua-visible type name for this navmesh handle.
- `LNavMesh:typeOf`: Returns whether this navmesh handle matches a supported type name.


#### LPathGrid Type


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


#### LUnitPathfinder Type


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

## References

- `flownet`: Imports or references `src/flownet/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
