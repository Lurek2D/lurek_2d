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

## Source Documentation

### `ai_flow_field.rs`
- Precomputed flow field steering multiple agents toward a single goal cell.
- BFS distance propagation with 8-directional neighbours and diagonal cost.
- Per-cell normalised direction vectors for smooth unit movement.
- Walkability mask support for blocking impassable terrain.

### `astar.rs`
- A\* pathfinding on a `NavGrid` with configurable diagonal modes and unit sizes.
- Heuristic selection: octile distance for diagonal movement, Manhattan otherwise.
- Early termination via `max_nodes` with partial-path fallback to closest reached cell.
- Bresenham line-of-sight checks for walkability validation.
- String-pull path smoothing that removes redundant waypoints.

### `async_pool.rs`
- Fixed-size thread pool that runs A* pathfinding off the game thread.
- Job submission, cancellation, and non-blocking result polling via channels.
- Workers share a single work queue and skip cancelled requests early.

### `bidir.rs`
- Bidirectional A* search that expands from both start and goal simultaneously.
- Meets in the middle when both closed sets overlap, halving explored nodes on large grids.
- Falls back to a partial forward path when the node budget is exhausted.
- Respects NavGrid diagonal mode and per-cell movement cost.
- Supports variable unit sizes for multi-tile pathfinding.

### `flow_field.rs`
- Dijkstra-based flow field that seeds from one or more goal cells and computes shortest paths across a NavGrid.
- Each reachable cell stores a normalised direction vector toward the nearest goal and its accumulated travel cost.
- Supports variable unit sizes for clearance-aware pathfinding using the backing grid's walkability checks.
- Provides world-space steering that converts pixel coordinates to tile lookups and returns a scaled velocity.
- Includes a debug visualisation helper that renders the field directions and obstacles to an ImageData bitmap.

### `graph_nav.rs`
- A* shortest-path search over weighted directed/bidirectional graphs.
- Range query returning all nodes reachable within a cost budget.
- Heuristic support for informed search; falls back to Dijkstra when omitted.
- Min-heap priority queue node with reverse ordering for `BinaryHeap`.
- Path reconstruction from predecessor map.

### `graph_path.rs`
- Province-level A* pathfinding across adjacency graphs with configurable move costs.
- Dijkstra-based reachability flood to find all provinces within a cost budget.
- Per-province and per-edge-tag cost modelling with blocked-province exclusion.
- Min-heap priority queue node with reverse ordering for standard `BinaryHeap`.
- Euclidean centroid heuristic for A* admissibility.

### `grid.rs`
- Flat 2-D grid with per-cell walkability and movement-cost storage.
- A* pathfinding with optional diagonal movement and Euclidean/Manhattan heuristic.
- Dijkstra shortest-path search respecting per-cell costs.
- BFS unweighted shortest path for uniform-cost grids.
- Dijkstra-based flow-field generation toward a single goal cell.
- Internal min-heap node and path reconstruction utilities.

### `hex_grid.rs`
- Hex grid with configurable flat-top or pointy-top offset layout.
- Per-cell blocked flags and movement cost for weighted pathfinding.
- A* search returning shortest path between two hex cells.
- Line-of-sight, field-of-view, and range-of-movement queries.
- Cube-coordinate math for distance, interpolation, and rounding.

### `hpa.rs`
- Hierarchical Pathfinding A* (HPA*) over a chunked NavGrid abstraction.
- Partition the grid into fixed-size chunks and detect entrance nodes at chunk boundaries.
- Build an abstract graph of entrance-to-entrance edges with A*-computed costs.
- Run abstract-level A* search using octile distance heuristic.
- Refine abstract waypoints back into full grid-level paths via per-segment A*.
- BFS-based reachability test over chunk connectivity without computing a full path.
- Temporary start/goal insertion into the abstract graph for single queries.
- Boundary scanning logic handles both horizontal and vertical chunk edges.
- Supports variable unit sizes passed through to underlying A* refinement.

### `influence_map.rs`
- Grid-based influence map with named floating-point layers over a uniform cell grid.
- Stamp radial influence with distance falloff, propagate via neighbourhood smoothing, and decay over time.
- Query aggregated influence inside world-space rectangles or locate extrema positions.
- Blend multiple layers with weighted combination into a destination layer.
- Debug visualisation rendering layers into an RGBA image for inspection.

### `iso_grid.rs`
- Grid-based A* pathfinding over a rectangular isometric cell map.
- Per-cell blocked flags and movement cost support for weighted searches.
- Bresenham line-of-sight query between two grid positions.
- 4-directional neighbour expansion with bounds and passability filtering.

### `jps.rs`
- Jump Point Search (JPS) optimised A* on uniform-cost 8-directional grids.
- Prunes symmetric neighbours to skip large open areas without expanding every cell.
- Identifies forced neighbours and jump points along cardinal and diagonal directions.
- Produces a full tile-by-tile path by interpolating between jump points.
- Uses octile distance heuristic and a min-heap open list.

### `mod.rs`
- Grid-based and graph-based pathfinding algorithms (A*, bidirectional, JPS, HPA*).
- Flow fields and influence maps for group movement and tactical queries.
- Navigation grids, hex grids, isometric grids, and navmesh support.
- Async thread-pool dispatch for off-thread path computation.

### `nav_grid.rs`
- Integer-cost walkability grid for tile-based pathfinding.
- Per-cell movement weight (0 = blocked, 1–254 = traversal cost).
- Cardinal and diagonal neighbour queries with corner-cut policies.
- Dirty-rectangle tracking for deferred HPA* hierarchy invalidation.
- Bulk fill, rect fill, byte import/export, and deep-copy snapshot.
- Debug visualisation: render grid + path overlay to an ImageData buffer.

### `navmesh.rs`
- Polygon-based navigation mesh for 2D pathfinding.
- A\* search over polygon adjacency graph with centroid heuristic.
- Ray-cast point-in-polygon containment test.
- Centroid waypoint extraction from polygon corridors.
- Directed and bidirectional polygon connectivity.

### `pathgrid.rs`
- Grid-based A* pathfinding with 8-directional movement and variable cell costs.
- Bresenham line-of-sight checks for post-search path smoothing (string-pull).
- World-space coordinate conversion: cell indices map to centres via configurable cell size.
- Diagonal corner-cutting prevention to avoid clipping through blocked corners.
- Octile distance heuristic for consistent and admissible cost estimation.

### `range_map.rs`
- Dijkstra-based budget-limited range expansion over a 2D grid.
- Produces a cost map showing which cells are reachable within a travel budget.
- Supports cardinal and diagonal movement with per-cell cost weights.

### `render.rs`
- Debug visualization for pathfinding structures as colored `RenderCommand` lists.
- NavGrid renders walkable/blocked cells, FlowField draws directional arrows, InfluenceMap shows signed heat.
- Each struct exposes `generate_render_commands` returning a `Vec<RenderCommand>` for overlay drawing.

### `unit_pathfinder.rs`
- Stateful per-unit pathfinder wrapping a shared `NavGrid` reference.
- Full A* path search with optional string-pull smoothing for shorter results.
- Partial-path expansion with configurable node budget for real-time budgets.
- BFS reachability test and nearest-walkable-cell search within a radius.
- LRU path cache with configurable max size and manual invalidation.
- Octile heuristic and Bresenham line-of-sight utility helpers.

## Types

- `FlowField` (`struct`, `ai_flow_field.rs`): Direction-field result that guides many agents toward a destination without separate full path storage per actor.
- `PathResult` (`type`, `async_pool.rs`): A completed path result returned by [`PathThreadPool::poll`].
- `PathThreadPool` (`struct`, `async_pool.rs`): Background worker pool for off-thread path requests.
- `FlowField` (`struct`, `flow_field.rs`): Direction-field result that guides many agents toward a destination without separate full path storage per actor.
- `ProvincePath` (`struct`, `graph_path.rs`): A path through the province adjacency graph.
- `ProvinceCostFn` (`struct`, `graph_path.rs`): Configurable cost function for province pathfinding.
- `Grid` (`struct`, `grid.rs`): Standalone generic grid type for search algorithms and support operations.
- `HexLayout` (`enum`, `hex_grid.rs`): Hex grid layout orientation.
- `HexGrid` (`struct`, `hex_grid.rs`): A hexagonal grid supporting pathfinding, LOS, FOV, and range queries.
- `AbstractEdge` (`struct`, `hpa.rs`): An edge in the abstract graph connecting two entrance nodes.
- `AbstractNode` (`struct`, `hpa.rs`): A node in the abstract graph, representing an entrance point on a chunk boundary.
- `Chunk` (`struct`, `hpa.rs`): A chunk region of the grid used during abstract graph construction.
- `AbstractGraph` (`struct`, `hpa.rs`): Higher-level graph abstraction used by hierarchical pathfinding.
- `InfluenceMap` (`struct`, `influence_map.rs`): Multi-layer float grid for tactical influence, pressure, or ownership analysis.
- `IsoGrid` (`struct`, `iso_grid.rs`): A 2D isometric grid supporting A* pathfinding and LOS.
- `JpsGrid` (`struct`, `jps.rs`): A uniform-cost grid optimised for JPS pathfinding.
- `DiagonalMode` (`enum`, `nav_grid.rs`): Controls how diagonal movement is handled during pathfinding.
- `NavGrid` (`struct`, `nav_grid.rs`): The main navigation grid used by most search helpers, storing blocked cells, movement costs, and diagonal policy.
- `NavMesh` (`struct`, `navmesh.rs`): Polygon-based 2D navigation mesh supporting A\* pathfinding.
- `Cell` (`struct`, `pathgrid.rs`): Core cell representation used by one of the grid variants.
- `PathGrid` (`struct`, `pathgrid.rs`): Alternate grid representation with float costs and built-in path utilities.
- `RangeMap` (`struct`, `range_map.rs`): A precomputed range map: cheapest path costs from a single origin.
- `Waypoint` (`struct`, `unit_pathfinder.rs`): A waypoint along a computed path.
- `UnitPathfinder` (`struct`, `unit_pathfinder.rs`): High-level wrapper that adapts pathfinding to unit radius, caching, partial paths, and recovery logic.

## Functions

- `FlowField::new` (`ai_flow_field.rs`): Create an uninitialised field of size `width × height` using the supplied walkability mask.
- `FlowField::set_goal` (`ai_flow_field.rs`): Set the goal cell to `(gx, gy)` and recompute the full flow field.
- `FlowField::compute` (`ai_flow_field.rs`): Run a BFS from the current goal cell to fill `distances` then derive `directions`.
- `FlowField::get_direction` (`ai_flow_field.rs`): Return the normalised direction at `(x, y)`; returns `(0,0)` when out of bounds.
- `FlowField::get_distance` (`ai_flow_field.rs`): Return the BFS distance at `(x, y)`; returns `INFINITY` when out of bounds or unreachable.
- `astar` (`astar.rs`): Run A★ search on `grid` from `start` to `goal`.
- `line_of_sight` (`astar.rs`): Check line-of-sight between two cells using Bresenham's algorithm,
- `smooth_path` (`astar.rs`): Smooth a path by removing unnecessary waypoints via line-of-sight checks
- `PathThreadPool::new` (`async_pool.rs`): Spawn `thread_count` workers (minimum 1) and connect them to shared channels.
- `PathThreadPool::submit` (`async_pool.rs`): Submit an A\* job; caller must pass a cloned grid snapshot.
- `PathThreadPool::poll` (`async_pool.rs`): Drain all available completed results without blocking.
- `PathThreadPool::cancel` (`async_pool.rs`): Mark `id` as cancelled; workers skip it if still queued.
- `PathThreadPool::pending_count` (`async_pool.rs`): Return the number of jobs submitted but not yet delivered.
- `PathThreadPool::set_thread_count` (`async_pool.rs`): Update the recorded thread count; does not respawn existing workers.
- `PathThreadPool::get_thread_count` (`async_pool.rs`): Return the configured worker thread count.
- `bidirectional_astar` (`bidir.rs`): Run bidirectional A★ search on `grid` from `start` to `goal`.
- `FlowField::new` (`flow_field.rs`): Create an uninitialised flow field linked to `grid`; call `calculate` before querying.
- `FlowField::calculate` (`flow_field.rs`): Seed the field with a single target cell and recompute.
- `FlowField::calculate_multi` (`flow_field.rs`): Recompute the field seeded from all cells in `targets`.
- `FlowField::get_direction` (`flow_field.rs`): Return the normalised flow direction at `(x, y)`; returns `(0,0)` when out of bounds.
- `FlowField::get_direction_angle` (`flow_field.rs`): Return the flow direction at `(x, y)` as an angle in radians relative to the +x axis.
- `FlowField::get_cost_to_target` (`flow_field.rs`): Return the Dijkstra cost from `(x, y)` to the nearest target; `INFINITY` when unreachable.
- `FlowField::is_calculated` (`flow_field.rs`): Return true if `calculate` or `calculate_multi` has been called at least once.
- `FlowField::get_targets` (`flow_field.rs`): Return a clone of the target cells used for the last computation.
- `FlowField::get_width` (`flow_field.rs`): Return the grid width.
- `FlowField::get_height` (`flow_field.rs`): Return the grid height.
- `FlowField::steer` (`flow_field.rs`): Convert world position to tile, sample direction, and return a velocity scaled by `speed`.
- `FlowField::draw_to_image` (`flow_field.rs`): Render the flow field to an `ImageData` with `cell_size` pixels per tile for debugging.
- `graph_astar` (`graph_nav.rs`): Find the shortest path between two nodes using A* (or Dijkstra when no heuristic is supplied).
- `graph_range` (`graph_nav.rs`): Find all nodes within `max_cost` from `start` using Dijkstra.
- `ProvinceCostFn::new` (`graph_path.rs`): Create a default cost function with `default_cost = 1.0` and no blocked provinces.
- `find_province_path` (`graph_path.rs`): Find a path between two provinces using A* with centroid distance heuristic.
- `province_reachable` (`graph_path.rs`): Find all provinces reachable from `start` within a cost budget using Dijkstra.
- `Grid::new` (`grid.rs`): Create a fully walkable `width × height` grid where every cell starts at `default_cost`.
- `Grid::width` (`grid.rs`): Return the grid width in cells.
- `Grid::height` (`grid.rs`): Return the grid height in cells.
- `Grid::set_walkable` (`grid.rs`): Set the walkability of cell `(x, y)`; silently ignores out-of-bounds coordinates.
- `Grid::is_walkable` (`grid.rs`): Return true when `(x, y)` is in bounds and walkable.
- `Grid::set_cost` (`grid.rs`): Set the movement cost for cell `(x, y)`; silently ignores out-of-bounds coordinates.
- `Grid::get_cost` (`grid.rs`): Return the movement cost at `(x, y)`; returns 1.0 when out of bounds.
- `Grid::find_path_astar` (`grid.rs`): Run A\* from `(sx,sy)` to `(gx,gy)`; use diagonal neighbours when `diagonal` is true.
- `Grid::find_path_dijkstra` (`grid.rs`): Run Dijkstra from `(sx,sy)` to `(gx,gy)`; respects movement costs, no heuristic.
- `Grid::find_path_bfs` (`grid.rs`): Run BFS (unweighted) from `(sx,sy)` to `(gx,gy)`; ignores movement costs.
- `Grid::build_flow_field` (`grid.rs`): Build a 4-directional Dijkstra flow field toward `(gx, gy)`; returns one `(dx,dy)` per cell.
- `HexGrid::new` (`hex_grid.rs`): Create a fully unblocked hex grid of size `width × height` using `layout`.
- `HexGrid::set_blocked` (`hex_grid.rs`): Mark cell `(col, row)` as blocked or passable.
- `HexGrid::set_cost` (`hex_grid.rs`): Set movement cost for cell `(col, row)`.
- `HexGrid::is_blocked` (`hex_grid.rs`): Return true when `(col, row)` is out-of-bounds or explicitly blocked.
- `HexGrid::find_path` (`hex_grid.rs`): Run A\* from `from` to `to`; return ordered path or `None` when unreachable.
- `HexGrid::line_of_sight` (`hex_grid.rs`): Return true when every hex on the straight line from `from` to `to` is passable.
- `HexGrid::field_of_view` (`hex_grid.rs`): Return all cells visible from `origin` within `max_range` hex steps.
- `HexGrid::range_of_movement` (`hex_grid.rs`): Return all cells reachable from `origin` with total movement cost ≤ `budget`.
- `HexGrid::neighbors` (`hex_grid.rs`): Return the passable hex neighbours of `(col, row)` using layout-appropriate offsets.
- `HexGrid::distance` (`hex_grid.rs`): Return the hex-grid distance between `a` and `b` in steps.
- `build_abstract` (`hpa.rs`): Build the abstract graph from a `NavGrid`.
- `hpa_star` (`hpa.rs`): Run HPA★ from `start` to `goal` on the abstract graph, then refine to tiles.
- `is_reachable` (`hpa.rs`): Check if `goal` is reachable from `start` using the abstract graph.
- `InfluenceMap::new` (`influence_map.rs`): Create an empty influence map with the given grid dimensions and world-space `cell_size`.
- `InfluenceMap::add_layer` (`influence_map.rs`): Register a new zero-filled layer named `name`; replaces any existing layer with that name.
- `InfluenceMap::has_layer` (`influence_map.rs`): Return true when a layer named `name` exists.
- `InfluenceMap::set_influence` (`influence_map.rs`): Set the influence value at cell `(x, y)` on `layer`; no-op if out-of-bounds.
- `InfluenceMap::get_influence` (`influence_map.rs`): Return the influence value at `(x, y)` on `layer`, or `0.0` if out-of-bounds or layer absent.
- `InfluenceMap::get_width` (`influence_map.rs`): Return the grid width in cells.
- `InfluenceMap::get_height` (`influence_map.rs`): Return the grid height in cells.
- `InfluenceMap::get_cell_size` (`influence_map.rs`): Return the world-space cell size.
- `InfluenceMap::get_layer_names` (`influence_map.rs`): Return the names of all registered layers.
- `InfluenceMap::stamp_influence` (`influence_map.rs`): Add `value` (scaled by falloff and distance) to all cells within `radius` of world point `(wx, wy)` on `layer`.
- `InfluenceMap::propagate` (`influence_map.rs`): Smooth `layer` by blending each cell with its 3×3 neighbourhood average, weighted by `momentum`.
- `InfluenceMap::decay` (`influence_map.rs`): Multiply every cell in `layer` by `factor`.
- `InfluenceMap::clear_layer` (`influence_map.rs`): Zero all cells in `layer`.
- `InfluenceMap::clear_all` (`influence_map.rs`): Zero all cells in every layer.
- `InfluenceMap::max_position` (`influence_map.rs`): Return the world-space position of the highest-value cell in `layer`, or `(0.0, 0.0)` if absent.
- `InfluenceMap::min_position` (`influence_map.rs`): Return the world-space position of the lowest-value cell in `layer`, or `(0.0, 0.0)` if absent.
- `InfluenceMap::query_rect` (`influence_map.rs`): Return the sum of all cell values in `layer` that fall within world-space rectangle `(wx, wy, ww, wh)`.
- `InfluenceMap::blend` (`influence_map.rs`): Write `weight_a * layer_a + weight_b * layer_b` into `dest`; all three layers must exist.
- `InfluenceMap::draw_to_image` (`influence_map.rs`): Render the "enemy" and "ally" layers into a color `ImageData` at `cell_size` pixels per cell.
- `IsoGrid::new` (`iso_grid.rs`): Create a fully passable grid of `width × height` cells with unit movement costs.
- `IsoGrid::set_blocked` (`iso_grid.rs`): Mark cell `(x, y)` as blocked or passable.
- `IsoGrid::set_cost` (`iso_grid.rs`): Set the movement cost for cell `(x, y)`.
- `IsoGrid::find_path` (`iso_grid.rs`): Run A\* from `from` to `to`; return an ordered path or `None` when unreachable.
- `IsoGrid::line_of_sight` (`iso_grid.rs`): Return true when all cells on the Bresenham line from `from` to `to` are passable.
- `IsoGrid::neighbors` (`iso_grid.rs`): Return the 4-directional passable neighbours of `(x, y)`.
- `JpsGrid::new` (`jps.rs`): Create an unblocked `width × height` grid.
- `JpsGrid::set_blocked` (`jps.rs`): Mark cell `(x, y)` as blocked or passable.
- `JpsGrid::is_blocked` (`jps.rs`): Return true when `(x, y)` is out-of-bounds or marked blocked.
- `JpsGrid::find_path` (`jps.rs`): Run JPS A\* from `from` to `to`; return a full tile-by-tile path or `None` when unreachable.
- `DiagonalMode::from_lua_str` (`nav_grid.rs`): Parse a case-insensitive Lua string to a `DiagonalMode`; return `None` for unknown strings.
- `DiagonalMode::to_lua_str` (`nav_grid.rs`): Return the canonical lowercase Lua string for this mode.
- `NavGrid::new` (`nav_grid.rs`): Create a fully walkable `width × height` grid with all costs set to `1`.
- `NavGrid::from_costs` (`nav_grid.rs`): Create a grid from an existing flat cost buffer; panics if `costs.len() != width * height`.
- `NavGrid::get_width` (`nav_grid.rs`): Return the grid width in tiles.
- `NavGrid::get_height` (`nav_grid.rs`): Return the grid height in tiles.
- `NavGrid::get_dimensions` (`nav_grid.rs`): Return `(width, height)` as a tuple.
- `NavGrid::get_cost` (`nav_grid.rs`): Return the cost at `(x, y)`; returns `0` (blocked) for out-of-bounds coordinates.
- `NavGrid::set_cost` (`nav_grid.rs`): Set the cost at `(x, y)`; silently ignores out-of-bounds coordinates.
- `NavGrid::is_blocked` (`nav_grid.rs`): Return true when `(x, y)` has cost `0` (blocked) or is out-of-bounds.
- `NavGrid::set_blocked` (`nav_grid.rs`): Set `(x, y)` to cost `0` (blocked) or `1` (passable).
- `NavGrid::is_walkable` (`nav_grid.rs`): Return true when a `unit_size × unit_size` footprint anchored at `(x, y)` is fully walkable.
- `NavGrid::fill` (`nav_grid.rs`): Set all cells to `cost`.
- `NavGrid::fill_rect` (`nav_grid.rs`): Set all cells in the axis-aligned rectangle at `(x, y, w, h)` to `cost`.
- `NavGrid::load_from_bytes` (`nav_grid.rs`): Replace the cost buffer from `data`; return an error if the length does not match `width * height`.
- `NavGrid::save_to_bytes` (`nav_grid.rs`): Return a copy of the cost buffer as a byte vector.
- `NavGrid::set_chunk_size` (`nav_grid.rs`): Set the chunk size used by HPA*; clamped to `[2, min(width, height)]`.
- `NavGrid::get_chunk_size` (`nav_grid.rs`): Return the current HPA* chunk size.
- `NavGrid::set_diagonal_mode` (`nav_grid.rs`): Set the diagonal movement policy for neighbour queries.
- `NavGrid::get_diagonal_mode` (`nav_grid.rs`): Return the current diagonal movement policy.
- `NavGrid::set_dirty` (`nav_grid.rs`): Record a dirty rectangle `(x, y, w, h)` for deferred hierarchy invalidation.
- `NavGrid::clear_dirty` (`nav_grid.rs`): Clear all pending dirty rectangles.
- `NavGrid::dirty_rects` (`nav_grid.rs`): Return the current slice of pending dirty rectangles.
- `NavGrid::neighbors` (`nav_grid.rs`): Return the passable neighbours of `(x, y)` respecting the current `diagonal_mode`.
- `NavGrid::snapshot` (`nav_grid.rs`): Return a deep copy of this grid without carrying over dirty rectangles.
- `NavGrid::draw_to_image` (`nav_grid.rs`): Render the grid and optionally overlay a `path`, `start`, and `end` marker into an `ImageData`.
- `NavMesh::new` (`navmesh.rs`): Create an empty mesh.
- `NavMesh::add_polygon` (`navmesh.rs`): Add a polygon region with at least 3 vertices; return its index or `None` if fewer than 3 vertices.
- `NavMesh::connect` (`navmesh.rs`): Add a directed edge from polygon `a` to `b`; if `bidirectional`, also add the reverse edge.
- `NavMesh::polygon_count` (`navmesh.rs`): Return the total number of registered polygons.
- `NavMesh::find_path` (`navmesh.rs`): Find a world-space path from `start` to `goal`; return centroid waypoints or `None` if either point is outside all polygons.
- `PathGrid::new` (`pathgrid.rs`): Create a fully walkable `width × height` grid with given world-space `cell_size`.
- `PathGrid::in_bounds` (`pathgrid.rs`): Return true when `(x, y)` is within the grid dimensions.
- `PathGrid::set_walkable` (`pathgrid.rs`): Set walkability of cell `(x, y)`.
- `PathGrid::is_walkable` (`pathgrid.rs`): Return true when `(x, y)` is in-bounds and walkable.
- `PathGrid::set_cost` (`pathgrid.rs`): Set movement cost of cell `(x, y)`.
- `PathGrid::get_cost` (`pathgrid.rs`): Return movement cost of cell `(x, y)`, or `f32::INFINITY` when out-of-bounds.
- `PathGrid::find_path` (`pathgrid.rs`): Run 8-directional A\* from cell `(sx, sy)` to `(gx, gy)`; return world-space waypoints or `None`.
- `PathGrid::find_path_smoothed` (`pathgrid.rs`): Run A\* then apply string-pull smoothing to reduce waypoint count.
- `PathGrid::cell_center` (`pathgrid.rs`): Return the world-space centre of cell `(x, y)`.
- `RangeMap::from_grid` (`range_map.rs`): Build a range map from a flat `costs`/`blocked` grid expanding from `(origin_x, origin_y)` within `budget`.
- `RangeMap::reachable` (`range_map.rs`): Return true when `(x, y)` was reached within the budget.
- `RangeMap::cost_to` (`range_map.rs`): Return travel cost from origin to `(x, y)`, or `None` when unreachable or out-of-bounds.
- `RangeMap::reachable_cells` (`range_map.rs`): Return all `(x, y)` cells reachable within the budget.
- `RangeMap::reachable_cells_with_cost` (`range_map.rs`): Return all reachable cells as `(x, y, travel_cost)` triples.
- `NavGrid::generate_render_commands` (`render.rs`): Return `RenderCommand`s that draw each cell as a red (blocked) or dark-blue (walkable) tile.
- `FlowField::generate_render_commands` (`render.rs`): Return `RenderCommand`s drawing flow arrows coloured by cost-to-target; dots for impassable cells.
- `InfluenceMap::generate_render_commands` (`render.rs`): Return `RenderCommand`s drawing influence values as green (positive) or red (negative) tiles.
- `UnitPathfinder::new` (`unit_pathfinder.rs`): Create a new pathfinder wrapping `grid` with caching enabled and a default max size of 1024.
- `UnitPathfinder::find_path` (`unit_pathfinder.rs`): Find a path from `(x1, y1)` to `(x2, y2)` for a unit of `unit_size`; return waypoints or `None`.
- `UnitPathfinder::find_path_smooth` (`unit_pathfinder.rs`): Find a path then apply A\* string-pull smoothing; return waypoints or `None`.
- `UnitPathfinder::get_path_length` (`unit_pathfinder.rs`): Return the Euclidean length of `path` in cells.
- `UnitPathfinder::get_path_cost` (`unit_pathfinder.rs`): Return the sum of `NavGrid` costs for all waypoints in `path`.
- `UnitPathfinder::find_partial_path` (`unit_pathfinder.rs`): Run A\* limited to `max_nodes` expansions; return `(partial_path, reached_goal)`.
- `UnitPathfinder::find_nearest_walkable` (`unit_pathfinder.rs`): BFS-search for the nearest `unit_size`-walkable cell within `max_radius` steps from `(x, y)`.
- `UnitPathfinder::is_reachable` (`unit_pathfinder.rs`): Return true when `(x2, y2)` is reachable from `(x1, y1)` via BFS for a unit of `unit_size`.
- `UnitPathfinder::heuristic_distance` (`unit_pathfinder.rs`): Return the octile distance heuristic between two cell coordinates.
- `UnitPathfinder::line_of_sight` (`unit_pathfinder.rs`): Return true when the Bresenham line from `(x1, y1)` to `(x2, y2)` passes only walkable cells for `unit_size`.
- `UnitPathfinder::set_cache_enabled` (`unit_pathfinder.rs`): Enable or disable path caching; clears existing cache when disabled.
- `UnitPathfinder::is_cache_enabled` (`unit_pathfinder.rs`): Return true when path caching is currently enabled.
- `UnitPathfinder::clear_cache` (`unit_pathfinder.rs`): Remove all cached paths.
- `UnitPathfinder::get_cache_size` (`unit_pathfinder.rs`): Return the current number of cached entries.
- `UnitPathfinder::set_cache_max_size` (`unit_pathfinder.rs`): Set the maximum cache size and evict old entries if needed.
- `UnitPathfinder::nav_grid` (`unit_pathfinder.rs`): Return a reference to the shared `NavGrid`.

## Lua API Reference

- Binding path(s): `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`

### Module Functions
- `lurek.pathfind.newNavGrid`: Creates a navigation grid with the given dimensions.
- `lurek.pathfind.newPathfinder`: Creates a unit pathfinder for a navigation grid.
- `lurek.pathfind.newFlowField`: Creates a flow field for a navigation grid.
- `lurek.pathfind.newPathGrid`: Creates a cell-size path grid with given dimensions.
- `lurek.pathfind.newPathFlowField`: Creates an AI flow field from a path grid.
- `lurek.pathfind.setThreadCount`: Sets the configured pathfinding worker-thread count.
- `lurek.pathfind.getThreadCount`: Returns the configured pathfinding thread count.
- `lurek.pathfind.newNavGridFromTileMap`: Creates a navigation grid from a tilemap layer and blocked gid table.
- `lurek.pathfind.newHexGrid`: Creates a hex grid with the given dimensions.
- `lurek.pathfind.newJpsGrid`: Creates a Jump Point Search grid with given dimensions.
- `lurek.pathfind.newNavMesh`: Creates an empty navigation mesh for polygon-based pathfinding.
- `lurek.pathfind.rangeMap`: Computes reachable cells from range map options.

### `LAIFlowField` Methods
- `LAIFlowField:getWidth`: Returns flow field width from this object.
- `LAIFlowField:getHeight`: Returns flow field height from this object.
- `LAIFlowField:hasGoal`: Returns whether a flow field goal is currently set.
- `LAIFlowField:setGoal`: Sets the one-based flow field goal and recalculates the field.
- `LAIFlowField:getGoal`: Returns the one-based flow field goal, or nil when no goal is set.
- `LAIFlowField:getDirection`: Returns flow direction vector for a one-based cell.
- `LAIFlowField:getDistance`: Returns distance to goal for a one-based cell.
- `LAIFlowField:type`: Returns the Lua-visible type name for this AI flow field handle.
- `LAIFlowField:typeOf`: Returns whether this AI flow field handle matches a supported type name.

### `LFlowField` Methods
- `LFlowField:calculate`: Calculates a flow field toward one target cell.
- `LFlowField:calculateMulti`: Calculates a flow field toward multiple target cells.
- `LFlowField:getDirection`: Returns flow direction vector at a one-based grid cell.
- `LFlowField:getDirectionAngle`: Returns flow direction angle at a one-based grid cell.
- `LFlowField:getCostToTarget`: Returns integration cost to the target from a one-based grid cell.
- `LFlowField:isCalculated`: Returns whether the flow field has been calculated.
- `LFlowField:getTargets`: Returns target cells for this flow field.
- `LFlowField:steer`: Returns a steering velocity for a world position using the flow field.
- `LFlowField:type`: Returns the Lua-visible type name for this flow field handle.
- `LFlowField:typeOf`: Returns whether this flow field handle matches a supported type name.

### `LHexGrid` Methods
- `LHexGrid:setBlocked`: Sets blocked state for a one-based hex cell.
- `LHexGrid:setCost`: Sets movement cost for a one-based hex cell.
- `LHexGrid:isBlocked`: Returns whether a one-based hex cell is blocked.
- `LHexGrid:findPath`: Finds a path between one-based hex cells.
- `LHexGrid:lineOfSight`: Returns whether two one-based hex cells have line of sight.
- `LHexGrid:fieldOfView`: Returns visible hex cells within range from an origin.
- `LHexGrid:rangeOfMovement`: Returns reachable hex cells within a movement budget.
- `LHexGrid:distance`: Returns hex distance between two one-based hex cells.
- `LHexGrid:type`: Returns the Lua-visible type name for this hex grid handle.
- `LHexGrid:typeOf`: Returns whether this hex grid handle matches a supported type name.

### `LJpsGrid` Methods
- `LJpsGrid:setBlocked`: Sets blocked state for a one-based JPS grid cell.
- `LJpsGrid:isBlocked`: Returns whether a one-based JPS grid cell is blocked.
- `LJpsGrid:findPath`: Finds a JPS path between one-based grid cells.
- `LJpsGrid:type`: Returns the Lua-visible type name for this JPS grid handle.
- `LJpsGrid:typeOf`: Returns whether this JPS grid handle matches a supported type name.

### `LNavGrid` Methods
- `LNavGrid:getWidth`: Returns grid width from this object.
- `LNavGrid:getHeight`: Returns grid height from this object.
- `LNavGrid:getDimensions`: Returns grid width and height as two integers.
- `LNavGrid:setCost`: Sets movement cost at a one-based grid cell.
- `LNavGrid:getCost`: Returns movement cost at a one-based grid cell.
- `LNavGrid:setBlocked`: Sets blocked state at a one-based grid cell.
- `LNavGrid:isBlocked`: Returns whether a one-based grid cell is blocked.
- `LNavGrid:isWalkable`: Returns whether a one-based grid cell is walkable for a unit size.
- `LNavGrid:fill`: Fills the entire grid with a uniform movement cost.
- `LNavGrid:fillRect`: Fills a one-based rectangular area with a movement cost.
- `LNavGrid:loadFromString`: Loads grid data from a serialized binary string.
- `LNavGrid:saveToString`: Saves grid data to a serialized binary string.
- `LNavGrid:setChunkSize`: Sets hierarchical chunk size for abstract graph partitioning.
- `LNavGrid:getChunkSize`: Returns the hierarchical chunk size in cells.
- `LNavGrid:rebuildAbstract`: Rebuilds the cached abstract graph for this grid.
- `LNavGrid:findHpaPath`: Finds a hierarchical path using the cached abstract graph, rebuilding it on first use.
- `LNavGrid:setDirty`: Marks a one-based rectangular region dirty for incremental rebuild.
- `LNavGrid:clearDirty`: Clears all dirty region markers from the grid.
- `LNavGrid:setDiagonalMode`: Sets diagonal movement mode for this object.
- `LNavGrid:getDiagonalMode`: Returns the current diagonal movement mode name.
- `LNavGrid:type`: Returns the Lua-visible type name for this navigation grid handle.
- `LNavGrid:typeOf`: Returns whether this navigation grid handle matches a supported type name.

### `LNavMesh` Methods
- `LNavMesh:addPolygon`: Adds a polygon from vertex tables and returns a one-based id.
- `LNavMesh:connectPolygons`: Connects two polygons by one-based id.
- `LNavMesh:findPath`: Finds a path through the navmesh between world points.
- `LNavMesh:getPolygonCount`: Returns the total navmesh polygon count.
- `LNavMesh:type`: Returns the Lua-visible type name for this navmesh handle.
- `LNavMesh:typeOf`: Returns whether this navmesh handle matches a supported type name.

### `LPathGrid` Methods
- `LPathGrid:getWidth`: Returns grid width from this object.
- `LPathGrid:getHeight`: Returns grid height from this object.
- `LPathGrid:getCellSize`: Returns path grid cell size from this object.
- `LPathGrid:setWalkable`: Sets walkability at a one-based cell.
- `LPathGrid:isWalkable`: Returns walkability at a one-based cell.
- `LPathGrid:setCost`: Sets movement cost at a one-based cell.
- `LPathGrid:getCost`: Returns movement cost at a one-based cell.
- `LPathGrid:findPath`: Finds a path between one-based path grid cells.
- `LPathGrid:findPathSmoothed`: Finds a smoothed path between one-based path grid cells.
- `LPathGrid:type`: Returns the Lua-visible type name for this path grid handle.
- `LPathGrid:typeOf`: Returns whether this path grid handle matches a supported type name.

### `LUnitPathfinder` Methods
- `LUnitPathfinder:findPath`: Finds a path between one-based grid cells.
- `LUnitPathfinder:findPathSmooth`: Finds a smoothed path between one-based grid cells.
- `LUnitPathfinder:findPathBidirectional`: Finds a path using bidirectional A* and returns completion status.
- `LUnitPathfinder:getPathLength`: Returns the total Euclidean length of a waypoint path.
- `LUnitPathfinder:getPathCost`: Returns the total movement cost along a waypoint path.
- `LUnitPathfinder:findPartialPath`: Finds the best reachable path from a start to a goal within a maximum node budget. Useful for incremental pathfinding across frames.
- `LUnitPathfinder:findNearestWalkable`: Finds nearest walkable one-based grid cell within a radius.
- `LUnitPathfinder:isReachable`: Returns whether a target cell is reachable from a start cell.
- `LUnitPathfinder:heuristicDistance`: Returns heuristic distance between two one-based cells.
- `LUnitPathfinder:lineOfSight`: Returns whether two one-based cells have line of sight.
- `LUnitPathfinder:setCacheEnabled`: Enables or disables the path cache on this object.
- `LUnitPathfinder:isCacheEnabled`: Returns whether path cache is enabled.
- `LUnitPathfinder:clearCache`: Clears all cached paths on this object.
- `LUnitPathfinder:getCacheSize`: Returns the current path cache entry count.
- `LUnitPathfinder:setCacheMaxSize`: Sets maximum path cache size for this object.
- `LUnitPathfinder:type`: Returns the Lua-visible type name for this pathfinder handle.
- `LUnitPathfinder:typeOf`: Returns whether this pathfinder handle matches a supported type name.

## References

- `flownet`: Imports or references `src/flownet/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/pathfind/` and any matching Lua bindings.
