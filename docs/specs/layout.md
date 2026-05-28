# layout

## TL;DR

- The `layout` module is a pure algorithmic component providing tree, DAG, and force-directed graph node-positioning algorithms for pipeline visualization, skill trees, dialog trees, and node editors.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/layout/`
- Lua API path(s): `src/lua_api/layout_api.rs`
- Primary Lua namespace: `lurek.layout`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `layout` module offers four complementary 2D graph layout algorithms with no engine runtime dependencies, making it usable from any scripting context. `layout_tree` implements the Reingold-Tilford algorithm for compact hierarchical tree layout, packing sibling subtrees as tightly as possible with configurable horizontal and vertical node separation. Both top-down and left-to-right orientations are supported via `TreeConfig`. `layout_dag` applies the multi-phase Sugiyama layered layout to directed acyclic graphs — cycle removal, layer assignment, crossing minimization, and coordinate assignment — producing readable hierarchical diagrams for tech trees, build-dependency graphs, and quest dependency views.

For general undirected graphs where hierarchy is not meaningful, `layout_force` runs the Fruchterman-Reingold spring simulation. Nodes repel each other while edges attract; a cooling schedule reduces displacement each iteration until convergence. `ForceConfig` exposes temperature, cooling rate, repulsion constant, and maximum iterations. Seeding is deterministic given the same integer seed, producing reproducible node editor layouts.

All three algorithms return a `LayoutResult` mapping `NodeId` to `(f32, f32)` coordinates in logical pixels. Two post-processing utilities compose cleanly with any layout output: `snap_to_grid` rounds positions to a configurable cell size, and `center_in_area` translates the entire layout to fill a target viewport rectangle. The full algorithm suite is exposed via the `lurek.layout.*` Lua API, targeting pipeline visualization, dialog tree views, skill trees, and org charts.

## Source Documentation

### `dag.rs`
- Sugiyama layered layout algorithm for directed acyclic graphs.
- `layout_dag(nodes, edges, config)` returns a `LayoutResult` with `(x, y)` positions.
- Phases: cycle removal, layer assignment, crossing minimisation, coordinate assignment.
- `DagConfig` controls node separation, layer height, and direction (top-down / LR).
- Output coordinates are in logical pixels; caller applies camera transform.
- Used by `lurek.layout.dag`; suitable for dependency trees and tech-tree UIs.

### `force.rs`
- Fruchterman-Reingold force-directed layout for arbitrary undirected graphs.
- `layout_force(nodes, edges, config)` iterates attraction/repulsion until convergence.
- `ForceConfig` controls temperature, cooling rate, repulsion constant, and max iterations.
- Initialises nodes on a random grid; deterministic given the same seed.
- Convergence is detected when the max node displacement falls below a threshold.
- Used by `lurek.layout.force` for social graphs, skill webs, and mind maps.

### `grid_align.rs`
- Post-processing utilities: snap node positions to a grid and centre in a bounding box.
- `snap_to_grid(positions, cell_size)` rounds each node to the nearest grid cell.
- `center_layout(positions, viewport)` translates the whole layout to fill a rect.
- Pure functions; no mutation of the graph structure, only the coordinate map.
- Applied after any layout algorithm before the positions are returned to Lua.

### `mod.rs`
- Generic graph/tree/DAG layout algorithms.
- Provides algorithms for positioning nodes in 2D space:
- **Tree layout** — Reingold-Tilford algorithm for hierarchical trees
- **DAG layout** — Sugiyama layered algorithm for directed acyclic graphs
- **Force-directed** — Fruchterman-Reingold spring simulation for arbitrary graphs
- **Grid alignment** — Post-processing snap-to-grid and centering
- Used by: pipeline visualization, dialog tree view, skill trees, node editors.

### `tree.rs`
- Reingold-Tilford algorithm for compact hierarchical tree node layout.
- `layout_tree(root, children, config)` returns a `HashMap<NodeId, (f32, f32)>`.
- Handles arbitrary branching factors; sibling subtrees are packed as tightly as possible.
- `TreeConfig` sets horizontal and vertical node separation distances.
- Supports top-down and left-to-right orientations via the `orientation` field.
- Used by `lurek.layout.tree` for dialogue trees, skill trees, and org charts.

### `types.rs`
- Shared layout types: nodes, edges, configuration structs, and result containers.
- `LayoutNode` carries an ID and optional size hint for layout algorithms.
- `LayoutEdge` is a directed `(from, to)` pair with an optional weight.
- `LayoutResult` is the common return type: a `HashMap<NodeId, (f32, f32)>`.
- `LayoutConfig` base fields (padding, viewport size) are embedded in every algorithm config.

## Types

- `ForceConfig` (`struct`, `force.rs`): Configuration for force-directed layout.
- `NodeId` (`type`, `types.rs`): Unique node identifier (index-based for performance).
- `LayoutNode` (`struct`, `types.rs`): A node with position and size in layout space.
- `LayoutEdge` (`struct`, `types.rs`): A directed edge between two nodes.
- `LayoutConfig` (`struct`, `types.rs`): Configuration for layout spacing.
- `LayoutResult` (`struct`, `types.rs`): Result of a layout computation.

## Functions

- `layout_dag` (`dag.rs`): Lays out a directed acyclic graph using a layered approach.
- `layout_force` (`force.rs`): Applies force-directed layout to a graph.
- `snap_to_grid` (`grid_align.rs`): Snaps all node positions to the nearest grid point.
- `center_in_area` (`grid_align.rs`): Centers the layout within a given area.
- `layout_tree` (`tree.rs`): Lays out a tree rooted at `root` with the given parent-to-children adjacency.
- `LayoutNode::new` (`types.rs`): Creates a new node with default size at origin.
- `LayoutNode::with_size` (`types.rs`): Sets the node size, returning self for chaining.
- `LayoutNode::with_label` (`types.rs`): Sets the node label, returning self for chaining.
- `LayoutEdge::new` (`types.rs`): Creates a new edge with default weight 1.0.
- `LayoutEdge::with_weight` (`types.rs`): Sets the edge weight, returning self for chaining.
- `LayoutResult::new` (`types.rs`): Creates a result and computes bounding dimensions from node positions.
- `LayoutResult::get` (`types.rs`): Gets a positioned layout node by its ID.
- `LayoutResult::count` (`types.rs`): Returns the number of positioned nodes.

## Lua API Reference

- Binding path(s): `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`

### Module Functions
- `lurek.layout.tree`: Lays out a tree using the Reingold-Tilford algorithm.
- `lurek.layout.dag`: Lays out a DAG using the Sugiyama layered algorithm.
- `lurek.layout.force`: Lays out a graph using force-directed Fruchterman-Reingold simulation.
- `lurek.layout.snapToGrid`: Snaps all node positions to the nearest grid point.
- `lurek.layout.centerInArea`: Centers the layout within a given area.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/layout/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
