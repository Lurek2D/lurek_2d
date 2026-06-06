# pathfind

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind/`
- Binding: `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`
- Lua API surface: `13` functions, `22` types, `104` methods
- Rust test path(s): tests/rust/unit/pathfinding_tests.rs
- Lua test path(s): tests/lua/unit/test_pathfind.lua, tests/lua/stress/test_pathfind_stress.lua, tests/lua/golden/test_pathfind_golden_grid.lua, tests/lua/integration/test_tilemap_pathfind.lua, tests/lua/integration/test_pathfind_ecs.lua, tests/lua/integration/test_ai_pathfind.lua

## Summary

This module provides a navigation and spatial pathfinding subsystem designed to handle diverse 2D grid and graph environments. It supports standard grid surfaces, hex grids with pointy or flat orientations, rectangular isometric cell structures, and polygon-based navigation meshes for large open spaces. Additionally, adjacency graphs represent province-level connections, giving developers a comprehensive toolkit to manage paths across strategic maps, tactical grids, or complex geometric zones.

For single-agent navigation, the system implements several stateful search algorithms optimized for performance and quality. It executes standard A* searches using octile or Manhattan heuristics, JPS to rapidly traverse open regions, and bidirectional A* searches that explore from both endpoints to find routes quickly. Waypoint smoothing through line-of-sight analysis cleans up redundant steps, while budget-limited A* queries return partial progress to keep frame rates stable.

To scale up to massive maps, the system features hierarchical and asynchronous pathfinding architectures. Hierarchical A* divides large grids into local chunks, caching boundary doorways to solve long-distance paths over an abstract graph before refining them locally. To prevent main-thread stuttering under heavy search loads, a thread-safe asynchronous work pool runs queries in parallel on background worker threads, automatically skipping canceled requests.

Group steering and tactical behaviors are managed via cost fields and distance maps. Dijkstra-based flow fields propagate movement directions from target goals, allowing massive crowds of units of varying sizes to steer smoothly around terrain obstacles. Multi-source goal maps define reachability and fleeing gradients, while layered influence maps stamp, diffuse, and decay tactical pressure over time, providing valuable spatial datasets for AI strategic scoring.

Finally, the module integrates dynamic diagnostic visualizations to facilitate developer iteration. It compiles live path grids, flow direction arrows, and influence heatmaps into colorized render commands and CPU-side image snapshots. This allows developers to inspect pathfinding search corridors, obstacle boundaries, and influence values directly inside the game world, ensuring high visibility over AI spatial reasoning and map configuration.

## Files

### [ai_flow_field.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/ai_flow_field.rs)

- Precomputed flow field steering many agents toward a single goal cell.
- Propagates breadth-first distance over 8-directional neighbours with diagonal cost.
- Stores per-cell direction vectors for smooth unit movement.
- Respects walkability masks when terrain blocks pathing.
- Gives group movement code a cheap steering target instead of a full path.

### [astar.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/astar.rs)

- A* pathfinding on a NavGrid with diagonal modes and configurable unit sizes.
- Chooses octile or Manhattan heuristics to match the movement model.
- Stops early when a node budget is reached and falls back to a partial path.
- Uses Bresenham line-of-sight checks for path smoothing and validation.
- Removes redundant waypoints through string-pull smoothing.
- Serves as the standard single-unit shortest-path search for grid movement.

### [async_pool.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/async_pool.rs)

- Fixed-size thread pool that runs A* pathfinding off the game thread.
- Submits jobs through channels and polls results without blocking.
- Shares one work queue across workers while skipping cancelled requests early.
- Gives pathfinding heavy workloads a parallel execution path.
- Keeps thread management isolated from callers.

### [bidir.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/bidir.rs)

- Bidirectional A* search that expands from both start and goal at once.
- Meets in the middle when the closed sets overlap to cut explored nodes.
- Falls back to a partial forward path when the node budget runs out.
- Respects NavGrid diagonal mode and per-cell movement cost.
- Supports variable unit sizes for multi-tile pathfinding.
- Helps large open grids return useful routes with less search work.

### [flow_field.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/flow_field.rs)

- Dijkstra-based flow field seeded from one or more goal cells over a NavGrid.
- Stores normalized direction vectors toward the nearest goal beside accumulated cost.
- Supports variable unit sizes for clearance-aware pathfinding.
- Converts world-space positions into tile lookups and steering velocities.
- Includes debug visualisation for directions and obstacles.
- Provides the group-movement layer above raw path search.

### [goal_map.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/goal_map.rs)

- Multi-source Dijkstra distance field for goal-oriented AI movement.
- Builds a cost-to-reach map from many weighted source cells.
- Returns downhill gradient, uphill flee direction, and flood-fill reachability.
- Supports custom blocker predicates during baking from Lua bindings.
- Serializes and restores the field as a compact binary blob.
- Gives AI code a reusable distance surface for steering and influence.

### [graph_nav.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/graph_nav.rs)

- A* shortest-path search over weighted directed or bidirectional graphs.
- Supports cost-bounded range queries for reachable nodes.
- Falls back to Dijkstra when no heuristic is provided.
- Reconstructs paths from predecessor maps for caller consumption.
- Serves graph-based navigation where grid adjacency is not enough.

### [graph_path.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/graph_path.rs)

- Province-level A* pathfinding across adjacency graphs with configurable move costs.
- Adds Dijkstra-based reachability flooding for budget-limited travel.
- Models blocked provinces and edge-tag costs in the search cost.
- Uses a min-heap priority queue node for standard BinaryHeap ordering.
- Applies a Euclidean centroid heuristic for admissible A* search.
- Fits strategic map travel where regions, not cells, are the navigation unit.

### [grid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/grid.rs)

- Flat 2-D grid with per-cell walkability and movement-cost storage.
- Provides A* with optional diagonal movement and selectable heuristics.
- Includes Dijkstra and BFS variants for weighted and uniform-cost search.
- Builds flow fields from a single goal cell for steering behavior.
- Keeps internal heap and path reconstruction helpers close to the grid model.
- Supports movement-cost lookups suitable for tile-based gameplay maps.
- Acts as the basic navigation surface for cell-level routing.

### [hex_grid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/hex_grid.rs)

- Hex grid with configurable flat-top or pointy-top offset layout.
- Stores blocked flags and movement costs for weighted pathfinding.
- Runs A* search for shortest paths between hex cells.
- Exposes line-of-sight, field-of-view, and movement-range queries.
- Uses cube-coordinate math for distance, interpolation, and rounding.
- Fits tactics and map systems that need hex adjacency instead of squares.
- Keeps hex navigation self-contained and script-friendly.

### [hpa.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/hpa.rs)

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

### [influence_map.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/influence_map.rs)

- Grid-based influence map with named floating-point layers over a uniform cell grid.
- Stamps radial influence with falloff, smooths through neighbours, and decays over time.
- Queries aggregated influence in rectangles or locates extrema positions.
- Blends multiple layers into a destination layer with weighted combination.
- Exposes debug visualisation into an RGBA image for inspection.
- Serves tactical scoring and spatial pressure systems.

### [iso_grid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/iso_grid.rs)

- Grid-based A* pathfinding over a rectangular isometric cell map.
- Stores blocked flags and movement costs for weighted searches.
- Uses Bresenham line-of-sight checks for visibility and smoothing support.
- Expands four-direction neighbours with bounds and passability filtering.
- Gives isometric tile worlds a direct path and visibility helper.

### [jps.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/jps.rs)

- Jump Point Search optimized A* on uniform-cost 8-directional grids.
- Prunes symmetric neighbours to skip large open areas.
- Identifies forced neighbours and jump points along cardinal and diagonal directions.
- Reconstructs a full tile-by-tile path from the jump points.
- Uses an octile heuristic and a min-heap open list.
- Works best when long straight corridors dominate the map.
- Keeps uniform-grid search fast without changing the grid model.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/mod.rs)

- Grid-based and graph-based pathfinding algorithms for cells, graphs, and flow fields.
- Collects A*, bidirectional search, JPS, HPA*, goal maps, and influence maps under one namespace.
- Includes grid, hex, isometric, and navmesh navigation surfaces.
- Keeps async dispatch and debug rendering close to the rest of the pathfinding stack.

### [nav_grid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/nav_grid.rs)

- Integer-cost walkability grid for tile-based pathfinding.
- Stores per-cell movement weight where zero means blocked and higher values cost more.
- Exposes cardinal and diagonal neighbour queries with corner-cut policies.
- Tracks dirty rectangles for deferred HPA hierarchy invalidation.
- Supports bulk fill, rect fill, byte import/export, and snapshot cloning.
- Renders the grid and path overlay into ImageData for debug use.
- Forms the base grid model used by higher-level navigation layers.

### [navmesh.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/navmesh.rs)

- Polygon-based navigation mesh for 2D pathfinding.
- Runs A* over a polygon adjacency graph with a centroid heuristic.
- Checks point containment with ray-cast tests and extracts centroid waypoints.
- Supports directed and bidirectional polygon connectivity.
- Serves large open areas where cell grids are too coarse.

### [pathgrid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/pathgrid.rs)

- Grid-based A* pathfinding with 8-directional movement and variable cell costs.
- Uses Bresenham line-of-sight for path smoothing after search.
- Converts cell indices to world-space centres with configurable cell size.
- Prevents diagonal corner cutting through blocked corners.
- Uses an octile heuristic for consistent cost estimation.
- Gives tile maps a direct shortest-path implementation.

### [range_map.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/range_map.rs)

- Dijkstra-based budget-limited range expansion over a 2-D grid.
- Produces a cost map for cells reachable within a travel budget.
- Supports cardinal and diagonal movement with per-cell cost weights.
- Useful for movement preview, threat radius, and action-range queries.
- Keeps reachability and distance budgeting in one helper.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/render.rs)

- Debug visualization for pathfinding structures as colored RenderCommand lists.
- Draws NavGrid cells, FlowField arrows, and InfluenceMap heat overlays.
- Returns batches ready for overlay drawing in the renderer.
- Gives developers a direct view into navigation data.
- Keeps visual inspection separate from path search logic.

### [unit_pathfinder.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pathfind/unit_pathfinder.rs)

- Stateful per-unit pathfinder wrapping a shared NavGrid reference.
- Runs full A* searches with optional string-pull smoothing.
- Supports partial paths, BFS reachability, and nearest-walkable searches.
- Caches recent routes with an LRU strategy and manual invalidation.
- Exposes octile heuristic and Bresenham LOS helpers for local decisions.
- Gives each unit its own path search facade without duplicating grid data.
