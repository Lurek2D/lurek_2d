# pathfind

## General Info

- Module group: `Feature Systems`
- Source path: `src/pathfind/`
- Lua API path(s): `src/lua_api/pathfind_api.rs`
- Primary Lua namespace: `lurek.pathfind`
- Rust test path(s): tests/rust/unit/pathfinding_tests.rs
- Lua test path(s): tests/lua/unit/test_pathfinding.lua, tests/lua/stress/test_pathfinding_stress.lua, tests/lua/golden/test_pathfinding_golden.lua, tests/lua/integration/test_tilemap_pathfinding.lua, tests/lua/integration/test_pathfinding_entity.lua, tests/lua/integration/test_ai_pathfinding.lua

## Summary

The `pathfind` module is Lurek2D's navigation algorithm stack. It covers A-star, flow fields, hierarchical pathfinding, influence maps, unit-size-aware path requests, adjacency-graph pathing, and background worker support for expensive searches.

It exists so movement planning and spatial search stay isolated from AI orchestration, physics, and scene code. Other modules can consume paths, flow directions, or influence values without re-implementing grids, heuristics, smoothing, or asynchronous dispatch.

It intentionally does not own agent decision-making, movement execution, collision resolution, or rendering beyond optional debug output. It answers where to go and how to evaluate traversability, not how a game object should behave once a path exists.

**Scope boundary**: This module currently depends on `image`, `render`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `ai_flow_field.rs`: Provides a simpler BFS-style flow-field implementation used for lightweight AI movement support.
- `astar.rs`: Implements A-star search, line-of-sight checks, and path smoothing helpers over navigation grids.
- `async_pool.rs`: Dispatches pathfinding work to background threads with request management and cancellation support.
- `flow_field.rs`: Implements Dijkstra-based flow fields for crowd steering toward one or more targets.
- `graph_path.rs`: Implements adjacency-graph pathfinding for province-style or node-link worlds instead of regular grids.
- `grid.rs`: Defines a standalone grid with generic path search, BFS, Dijkstra, and flow-field generation support.
- `hpa.rs`: Implements hierarchical pathfinding using chunk abstraction and entrance-based higher-level search.
- `influence_map.rs`: Stores and updates multi-layer spatial influence values for tactical or strategic reasoning.
- `mod.rs`: Declares the pathfinding submodules and re-exports the main grids, algorithms, and support types.
- `nav_grid.rs`: Defines the main navigation grid with walkability, costs, diagonal rules, and thread-friendly snapshots.
- `pathgrid.rs`: Provides an alternate path grid with float costs and built-in path operations.
- `render.rs`: Generates debug render output for grids, flow fields, and influence maps.
- `unit_pathfinder.rs`: Wraps pathfinding for unit-sized actors, including caching, partial paths, and nearest-walkable recovery.

## Types

- `FlowField` (`struct`, `ai_flow_field.rs`): Direction-field result that guides many agents toward a destination without separate full path storage per actor.
- `PathResult` (`type`, `async_pool.rs`): A completed path result returned by [`PathThreadPool::poll`].
- `PathThreadPool` (`struct`, `async_pool.rs`): Background worker pool for off-thread path requests.
- `FlowField` (`struct`, `flow_field.rs`): Direction-field result that guides many agents toward a destination without separate full path storage per actor.
- `ProvincePath` (`struct`, `graph_path.rs`): A path through the province adjacency graph.
- `ProvinceCostFn` (`struct`, `graph_path.rs`): Configurable cost function for province pathfinding.
- `Grid` (`struct`, `grid.rs`): Standalone generic grid type for search algorithms and support operations.
- `AbstractEdge` (`struct`, `hpa.rs`): An edge in the abstract graph connecting two entrance nodes.
- `AbstractNode` (`struct`, `hpa.rs`): A node in the abstract graph, representing an entrance point on a chunk boundary.
- `Chunk` (`struct`, `hpa.rs`): A chunk region of the grid used during abstract graph construction.
- `AbstractGraph` (`struct`, `hpa.rs`): Higher-level graph abstraction used by hierarchical pathfinding.
- `InfluenceMap` (`struct`, `influence_map.rs`): Multi-layer float grid for tactical influence, pressure, or ownership analysis.
- `DiagonalMode` (`enum`, `nav_grid.rs`): Controls how diagonal movement is handled during pathfinding.
- `NavGrid` (`struct`, `nav_grid.rs`): The main navigation grid used by most search helpers, storing blocked cells, movement costs, and diagonal policy.
- `Cell` (`struct`, `pathgrid.rs`): Core cell representation used by one of the grid variants.
- `PathGrid` (`struct`, `pathgrid.rs`): Alternate grid representation with float costs and built-in path utilities.
- `Waypoint` (`struct`, `unit_pathfinder.rs`): A waypoint along a computed path.
- `UnitPathfinder` (`struct`, `unit_pathfinder.rs`): High-level wrapper that adapts pathfinding to unit radius, caching, partial paths, and recovery logic.

## Functions

- `FlowField::new` (`ai_flow_field.rs`): Creates a new FlowField from a SimpleGrid's dimensions and walkability.
- `FlowField::set_goal` (`ai_flow_field.rs`): Sets the goal cell and triggers BFS recomputation.
- `FlowField::compute` (`ai_flow_field.rs`): Recomputes the flow field from the current goal.
- `FlowField::get_direction` (`ai_flow_field.rs`): Gets the normalized direction toward the goal for a cell (0-based).
- `FlowField::get_distance` (`ai_flow_field.rs`): Gets the BFS distance for a cell (0-based).
- `astar` (`astar.rs`): Run A★ search on `grid` from `start` to `goal`.
- `line_of_sight` (`astar.rs`): Check line-of-sight between two cells using Bresenham's algorithm,
- `smooth_path` (`astar.rs`): Smooth a path by removing unnecessary waypoints via line-of-sight checks
- `PathThreadPool::new` (`async_pool.rs`): Spawn `thread_count` workers ready to process path requests.
- `PathThreadPool::submit` (`async_pool.rs`): Submit a pathfinding request.
- `PathThreadPool::poll` (`async_pool.rs`): Collect all completed results without blocking.
- `PathThreadPool::cancel` (`async_pool.rs`): Mark a request as cancelled (best-effort — may already be in progress).
- `PathThreadPool::pending_count` (`async_pool.rs`): Number of requests submitted but not yet returned via [`poll`].
- `PathThreadPool::set_thread_count` (`async_pool.rs`): Update the thread count.
- `PathThreadPool::get_thread_count` (`async_pool.rs`): Current configured thread count.
- `FlowField::new` (`flow_field.rs`): Create an empty flow field backed by `grid`.
- `FlowField::calculate` (`flow_field.rs`): Compute the flow field toward a single target cell.
- `FlowField::calculate_multi` (`flow_field.rs`): Compute the flow field toward multiple target cells simultaneously.
- `FlowField::get_direction` (`flow_field.rs`): Get the normalised direction vector at cell `(x, y)`.
- `FlowField::get_direction_angle` (`flow_field.rs`): Get the direction as an angle in radians (via `atan2`).
- `FlowField::get_cost_to_target` (`flow_field.rs`): Get the integrated cost from cell `(x, y)` to the nearest target.
- `FlowField::is_calculated` (`flow_field.rs`): Whether the flow field has been computed at least once.
- `FlowField::get_targets` (`flow_field.rs`): Target cells from the most recent computation.
- `FlowField::get_width` (`flow_field.rs`): Grid width in cells.
- `FlowField::get_height` (`flow_field.rs`): Grid height in cells.
- `FlowField::steer` (`flow_field.rs`): Convert a world-space position into a velocity vector.
- `FlowField::draw_to_image` (`flow_field.rs`): Render the flow field to an image with direction arrows.
- `ProvinceCostFn::new` (`graph_path.rs`): Create a cost function with default cost 1.0 and no overrides.
- `find_province_path` (`graph_path.rs`): Find a path between two provinces using A* with centroid distance heuristic.
- `province_reachable` (`graph_path.rs`): Find all provinces reachable from `start` within a cost budget using Dijkstra.
- `Grid::new` (`grid.rs`): Creates a new grid where every cell is walkable with the given movement cost.
- `Grid::width` (`grid.rs`): Returns the grid width in cells.
- `Grid::height` (`grid.rs`): Returns the grid height in cells.
- `Grid::set_walkable` (`grid.rs`): Sets whether the cell at `(x, y)` is walkable.
- `Grid::is_walkable` (`grid.rs`): Returns whether the cell at `(x, y)` is walkable.
- `Grid::set_cost` (`grid.rs`): Sets the movement cost of the cell at `(x, y)`.
- `Grid::get_cost` (`grid.rs`): Returns the movement cost of the cell at `(x, y)`.
- `Grid::find_path_astar` (`grid.rs`): Finds a path from `(sx, sy)` to `(gx, gy)` using A*.
- `Grid::find_path_dijkstra` (`grid.rs`): Finds a path from `(sx, sy)` to `(gx, gy)` using Dijkstra's algorithm.
- `Grid::find_path_bfs` (`grid.rs`): Finds a shortest-hop path from `(sx, sy)` to `(gx, gy)` using BFS.
- `Grid::build_flow_field` (`grid.rs`): Builds a flow field pointing toward `(gx, gy)`.
- `build_abstract` (`hpa.rs`): Build the abstract graph from a `NavGrid`.
- `hpa_star` (`hpa.rs`): Run HPA★ from `start` to `goal` on the abstract graph, then refine to tiles.
- `is_reachable` (`hpa.rs`): Check if `goal` is reachable from `start` using the abstract graph.
- `InfluenceMap::new` (`influence_map.rs`): Creates a new empty influence map with the given dimensions.
- `InfluenceMap::add_layer` (`influence_map.rs`): Adds a new named layer initialized to zero.
- `InfluenceMap::has_layer` (`influence_map.rs`): Returns whether a layer exists.
- `InfluenceMap::set_influence` (`influence_map.rs`): Sets influence at a grid cell (0-based).
- `InfluenceMap::get_influence` (`influence_map.rs`): Gets influence at a grid cell (0-based).
- `InfluenceMap::get_width` (`influence_map.rs`): Number of cells along the X axis.
- `InfluenceMap::get_height` (`influence_map.rs`): Number of cells along the Y axis.
- `InfluenceMap::get_cell_size` (`influence_map.rs`): World-space size of each cell.
- `InfluenceMap::get_layer_names` (`influence_map.rs`): Names of all registered layers (order not guaranteed).
- `InfluenceMap::stamp_influence` (`influence_map.rs`): Stamps circular influence in world-space coordinates with linear falloff.
- `InfluenceMap::propagate` (`influence_map.rs`): 3×3 averaging diffusion.
- `InfluenceMap::decay` (`influence_map.rs`): Multiplies every cell in a layer by the decay factor.
- `InfluenceMap::clear_layer` (`influence_map.rs`): Clears all cells in a layer to zero.
- `InfluenceMap::clear_all` (`influence_map.rs`): Clears all layers to zero.
- `InfluenceMap::max_position` (`influence_map.rs`): Returns the world-space position of the cell with the highest value.
- `InfluenceMap::min_position` (`influence_map.rs`): Returns the world-space position of the cell with the lowest value.
- `InfluenceMap::query_rect` (`influence_map.rs`): Sums influence within a world-space rectangle.
- `InfluenceMap::blend` (`influence_map.rs`): Blends two layers into a destination: dest = wA * A + wB * B.
- `InfluenceMap::draw_to_image` (`influence_map.rs`): Render the influence map to an image.
- `DiagonalMode::from_lua_str` (`nav_grid.rs`): Parse a Lua string into a `DiagonalMode`.
- `DiagonalMode::to_lua_str` (`nav_grid.rs`): Convert to the canonical Lua string representation.
- `NavGrid::new` (`nav_grid.rs`): Create a new grid where every cell has cost 1 (fully walkable).
- `NavGrid::from_costs` (`nav_grid.rs`): Create a grid from a pre-built cost array.
- `NavGrid::get_width` (`nav_grid.rs`): Grid width in cells.
- `NavGrid::get_height` (`nav_grid.rs`): Grid height in cells.
- `NavGrid::get_dimensions` (`nav_grid.rs`): Returns `(width, height)`.
- `NavGrid::get_cost` (`nav_grid.rs`): Get the traversal cost of cell `(x, y)`.
- `NavGrid::set_cost` (`nav_grid.rs`): Set the traversal cost of cell `(x, y)`.
- `NavGrid::is_blocked` (`nav_grid.rs`): Returns `true` if cell `(x, y)` is blocked (cost 0 or out-of-bounds).
- `NavGrid::set_blocked` (`nav_grid.rs`): Mark cell `(x, y)` as blocked (cost 0) or unblocked (cost 1).
- `NavGrid::is_walkable` (`nav_grid.rs`): Check whether an `NxN` unit footprint anchored at `(x, y)` is fully walkable.
- `NavGrid::fill` (`nav_grid.rs`): Set every cell to `cost`.
- `NavGrid::fill_rect` (`nav_grid.rs`): Set all cells in the rectangle `(x, y, w, h)` to `cost`, clamped to grid bounds.
- `NavGrid::load_from_bytes` (`nav_grid.rs`): Overwrite the grid from a raw byte slice (row-major, one byte per cell).
- `NavGrid::save_to_bytes` (`nav_grid.rs`): Export the cost grid as a byte vector (row-major, one byte per cell).
- `NavGrid::set_chunk_size` (`nav_grid.rs`): Set the HPA* chunk size (clamped to `[2, min(width, height)]`).
- `NavGrid::get_chunk_size` (`nav_grid.rs`): Current HPA* chunk size.
- `NavGrid::set_diagonal_mode` (`nav_grid.rs`): Set the diagonal movement mode.
- `NavGrid::get_diagonal_mode` (`nav_grid.rs`): Current diagonal movement mode.
- `NavGrid::set_dirty` (`nav_grid.rs`): Record a dirty rectangle `(x, y, w, h)` for incremental HPA* updates.
- `NavGrid::clear_dirty` (`nav_grid.rs`): Clear all pending dirty rectangles.
- `NavGrid::dirty_rects` (`nav_grid.rs`): Returns the list of dirty rectangles recorded since the last clear.
- `NavGrid::neighbors` (`nav_grid.rs`): Return walkable neighbours of `(x, y)` respecting the current diagonal mode.
- `NavGrid::snapshot` (`nav_grid.rs`): Create a lightweight clone suitable for use on another thread.
- `NavGrid::draw_to_image` (`nav_grid.rs`): Render the navigation grid to an image with optional path overlay.
- `PathGrid::new` (`pathgrid.rs`): Creates a new PathGrid where all cells are walkable with cost 1.0.
- `PathGrid::in_bounds` (`pathgrid.rs`): Returns true if (x, y) is within grid bounds.
- `PathGrid::set_walkable` (`pathgrid.rs`): Sets walkability for a cell (0-based coords).
- `PathGrid::is_walkable` (`pathgrid.rs`): Returns whether a cell is walkable (0-based coords).
- `PathGrid::set_cost` (`pathgrid.rs`): Sets cost multiplier for a cell (0-based coords).
- `PathGrid::get_cost` (`pathgrid.rs`): Gets cost multiplier for a cell (0-based coords).
- `PathGrid::find_path` (`pathgrid.rs`): A★ search from (sx,sy) to (gx,gy) in 0-based grid coords.
- `PathGrid::find_path_smoothed` (`pathgrid.rs`): A★ + string-pulling (greedy LOS post-processing).
- `PathGrid::cell_center` (`pathgrid.rs`): Returns the world-space center of cell (x, y).
- `NavGrid::generate_render_commands` (`render.rs`): Generate debug render commands visualising the navigation grid.
- `FlowField::generate_render_commands` (`render.rs`): Generate debug render commands visualising flow directions.
- `InfluenceMap::generate_render_commands` (`render.rs`): Generate debug render commands visualising one influence layer as a heatmap.
- `UnitPathfinder::new` (`unit_pathfinder.rs`): Create a new pathfinder backed by `grid`.
- `UnitPathfinder::find_path` (`unit_pathfinder.rs`): Find a path from `(x1, y1)` to `(x2, y2)` for a `unit_size×unit_size` unit.
- `UnitPathfinder::find_path_smooth` (`unit_pathfinder.rs`): Find a path and apply Theta★ line-of-sight smoothing.
- `UnitPathfinder::get_path_length` (`unit_pathfinder.rs`): Sum of euclidean distances between consecutive waypoints.
- `UnitPathfinder::get_path_cost` (`unit_pathfinder.rs`): Sum of grid traversal costs along a path.
- `UnitPathfinder::find_partial_path` (`unit_pathfinder.rs`): Search with a node expansion limit; returns `(path, complete)`.
- `UnitPathfinder::find_nearest_walkable` (`unit_pathfinder.rs`): Find the nearest walkable cell within `max_radius` of `(x, y)` using BFS.
- `UnitPathfinder::is_reachable` (`unit_pathfinder.rs`): Quick connectivity check: can `(x2, y2)` be reached from `(x1, y1)`?
- `UnitPathfinder::heuristic_distance` (`unit_pathfinder.rs`): Octile heuristic distance between two points.
- `UnitPathfinder::line_of_sight` (`unit_pathfinder.rs`): Line-of-sight check between two cells, respecting unit footprint.
- `UnitPathfinder::set_cache_enabled` (`unit_pathfinder.rs`): Enable or disable path caching.
- `UnitPathfinder::is_cache_enabled` (`unit_pathfinder.rs`): Returns `true` if caching is enabled.
- `UnitPathfinder::clear_cache` (`unit_pathfinder.rs`): Remove all cached path results.
- `UnitPathfinder::get_cache_size` (`unit_pathfinder.rs`): Number of entries currently in the cache.
- `UnitPathfinder::set_cache_max_size` (`unit_pathfinder.rs`): Set the maximum cache size.

## Lua API Reference

- Binding path(s): `src/lua_api/pathfind_api.rs`
- Namespace: `lurek.pathfind`

### Module Functions
- `lurek.pathfind.newNavGrid`: Creates a new NavGrid with all cells walkable.
- `lurek.pathfind.newPathfinder`: Creates a new UnitPathfinder backed by a NavGrid.
- `lurek.pathfind.newFlowField`: Creates a new FlowField backed by a NavGrid.
- `lurek.pathfind.newPathGrid`: Creates a new PathGrid with per-cell cost and walkability.
- `lurek.pathfind.newPathFlowField`: Creates a new BFS flow field from a PathGrid.
- `lurek.pathfind.setThreadCount`: Sets the background pathfinding thread count (currently a no-op).
- `lurek.pathfind.getThreadCount`: Returns the background pathfinding thread count (currently always 0).
- `lurek.pathfind.newNavGridFromTileMap`: Builds a NavGrid from a TileMap layer, treating specified GIDs as blocked (unwalkable).

### `AiFlowField` Methods
- `AiFlowField:getWidth`: Returns the grid width.
- `AiFlowField:getHeight`: Returns the grid height.
- `AiFlowField:hasGoal`: Returns true if a goal has been set.
- `AiFlowField:setGoal`: Sets the goal cell and triggers BFS recomputation (1-based coordinates).
- `AiFlowField:getDirection`: Returns the normalised direction toward the goal (1-based coordinates).
- `AiFlowField:getDistance`: Returns the BFS distance to the goal (1-based coordinates).
- `AiFlowField:type`: Returns the type name of this object.
- `AiFlowField:typeOf`: Returns true if this object is of the given type.

### `FlowField` Methods
- `FlowField:getDirection`: Returns the normalised direction vector at a cell (1-based coordinates).
- `FlowField:getDirectionAngle`: Returns the flow direction as an angle in radians (1-based coordinates).
- `FlowField:getCostToTarget`: Returns the integrated cost to the nearest target (1-based coordinates).
- `FlowField:isCalculated`: Returns true if the flow field has been computed at least once.
- `FlowField:getTargets`: Returns the target cells from the most recent computation (1-based coordinates).
- `FlowField:type`: Returns the type name of this object.
- `FlowField:typeOf`: Returns true if this object is of the given type.

### `NavGrid` Methods
- `NavGrid:getWidth`: Returns the grid width in cells.
- `NavGrid:getHeight`: Returns the grid height in cells.
- `NavGrid:getDimensions`: Returns the grid dimensions as width, height.
- `NavGrid:setCost`: Sets the traversal cost of a cell (1-based coordinates).
- `NavGrid:getCost`: Returns the traversal cost of a cell (1-based coordinates).
- `NavGrid:isBlocked`: Returns true if the cell is blocked (1-based coordinates).
- `NavGrid:fill`: Sets every cell to the given cost.
- `NavGrid:loadFromString`: Overwrites the grid from a raw byte string (row-major, one byte per cell).
- `NavGrid:saveToString`: Exports the cost grid as a byte string (row-major, one byte per cell).
- `NavGrid:setChunkSize`: Sets the HPA★ chunk size.
- `NavGrid:getChunkSize`: Returns the current HPA★ chunk size.
- `NavGrid:rebuildAbstract`: Rebuilds the HPA★ abstract graph from the current grid state.
- `NavGrid:setDirty`: Records a dirty rectangle for incremental HPA★ updates (1-based coordinates).
- `NavGrid:clearDirty`: Clears all pending dirty rectangles.
- `NavGrid:setDiagonalMode`: Sets the diagonal movement mode.
- `NavGrid:getDiagonalMode`: Returns the current diagonal movement mode as a string.
- `NavGrid:type`: Returns the type name of this object.
- `NavGrid:typeOf`: Returns true if this object is of the given type.

### `PathGrid` Methods
- `PathGrid:getWidth`: Returns the grid width in cells.
- `PathGrid:getHeight`: Returns the grid height in cells.
- `PathGrid:getCellSize`: Returns the world-space size of each cell.
- `PathGrid:setWalkable`: Sets the walkability of a cell (1-based coordinates).
- `PathGrid:isWalkable`: Returns true if a cell is walkable (1-based coordinates).
- `PathGrid:setCost`: Sets the cost multiplier for a cell (1-based coordinates).
- `PathGrid:getCost`: Returns the cost multiplier for a cell (1-based coordinates).
- `PathGrid:type`: Returns the type name of this object.
- `PathGrid:typeOf`: Returns true if this object is of the given type.

### `UnitPathfinder` Methods
- `UnitPathfinder:getPathLength`: Returns the euclidean length of a path table.
- `UnitPathfinder:getPathCost`: Returns the sum of grid traversal costs along a path.
- `UnitPathfinder:setCacheEnabled`: Enables or disables path result caching.
- `UnitPathfinder:isCacheEnabled`: Returns true if path result caching is enabled.
- `UnitPathfinder:clearCache`: Removes all cached path results.
- `UnitPathfinder:getCacheSize`: Returns the number of entries in the path cache.
- `UnitPathfinder:setCacheMaxSize`: Sets the maximum number of cached path entries.
- `UnitPathfinder:type`: Returns the type name of this object.
- `UnitPathfinder:typeOf`: Returns true if this object is of the given type.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/pathfind/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
