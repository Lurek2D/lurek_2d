# layout

## TL;DR

- Computes graph layouts with grid snapping.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/layout/`
- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`
- Lua API surface: `5` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides graph and hierarchy layouts to compute 2D coordinates for nodes. It offers layered placement for directed graphs to reduce crossings, recursive allocations for compact trees, and force-directed simulations that arrange relation webs organically.

For visual polish, the system features grid snapping and centering. These snap coordinates to consistent grids and center diagrams inside view targets without altering topology, ensuring clean, readable node arrangements.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

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

### Functions

- `lurek.layout.centerInArea(result, width, height) -> table`: Centers the layout within a given area.
- `lurek.layout.dag(nodes, edges, config?) -> table`: Lays out a DAG using the Sugiyama layered algorithm.
- `lurek.layout.force(nodes, edges, config?) -> table`: Lays out a graph using force-directed Fruchterman-Reingold simulation.
- `lurek.layout.snapToGrid(result, gridSize) -> table`: Snaps all node positions to the nearest grid point.
- `lurek.layout.tree(nodes, children, root, config) -> table`: Lays out a tree using the Reingold-Tilford algorithm.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.
