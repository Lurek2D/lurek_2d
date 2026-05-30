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

## Files

### dag.rs

- Provides staged layered layout for directed graphs where flow direction and rank readability are primary goals.
- Organizes nodes into bands, reorders local neighborhoods to reduce crossings, and then assigns stable screen coordinates.
- Applies spacing and margin policy from shared layout config so outputs align with other module strategies.
- Prefers deterministic structure over visual drift to keep dependency and progression maps legible across updates.
- Serves graph-like UI flows that need clear upstream-downstream interpretation without manual node placement.

### force.rs

- Delivers force-based layout for arbitrary connectivity where organic grouping matters more than strict hierarchy.
- Balances repulsion and edge tension over iterative cooling to separate clusters while preserving relation cues.
- Exposes tunable simulation intensity, area bounds, and convergence rhythm for different graph densities.
- Produces coordinate fields that remain compatible with shared layout result types and downstream alignment passes.
- Fits exploratory maps, relation webs, and editor views that need natural spacing without hard rank constraints.

### grid_align.rs

- Provides finishing transforms that regularize raw layout coordinates before visual presentation.
- Snaps node positions to consistent grid rhythm to improve scanability and manual editing behavior.
- Recenters complete layouts into target areas without changing graph topology or sibling ordering.
- Acts as the last geometry polish stage shared by multiple upstream layout strategies.

### mod.rs

- Aggregates graph and tree layout strategies into one coherent coordinate service for runtime visuals.
- Unifies result and config contracts so callers can switch placement style without changing integration code.
- Exposes high-level re-exports that keep dependent systems decoupled from per-algorithm file structure.

### tree.rs

- Implements rooted hierarchy placement that keeps parent-child reading order clear and branch spacing compact.
- Walks subtrees recursively to allocate horizontal extent before anchoring parent coordinates in stable positions.
- Applies shared spacing controls to balance density and readability for branching structures of uneven depth.
- Targets dialog flows and progression trees that require explicit structure with minimal manual cleanup.

### types.rs

- Defines the common data contract that every layout algorithm in this module reads and writes.
- Encodes node identity, geometry hints, and mutable coordinates in a shape tuned for repeated transforms.
- Represents graph relations with lightweight edge records that support directional and weighted workflows.
- Packages algorithm outputs into a uniform result container for renderer and tooling consumption.
- Keeps configuration and result semantics stable so backends can evolve without breaking caller expectations.

## Lua API Ref

- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`

### Functions

- `lurek.layout.centerInArea`: Centers the layout within a given area.
- `lurek.layout.dag`: Lays out a DAG using the Sugiyama layered algorithm.
- `lurek.layout.force`: Lays out a graph using force-directed Fruchterman-Reingold simulation.
- `lurek.layout.snapToGrid`: Snaps all node positions to the nearest grid point.
- `lurek.layout.tree`: Lays out a tree using the Reingold-Tilford algorithm.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
