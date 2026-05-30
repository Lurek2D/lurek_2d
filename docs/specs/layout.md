# layout

## TL;DR

- The `layout` module computes 2D node positions for trees and graphs using deterministic tree, DAG, and force-directed strategies.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/layout/`
- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`
- Lua API surface: `5` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `layout` module computes deterministic 2D coordinates for graph-style UI data.

It supports tree, layered DAG, and force-directed strategies, so each data shape can use a matching layout method.

Grid snapping and area-centering helpers normalize output for editor and HUD presentation. In practice, `lurek.layout` gives one reusable positioning contract for node graphs.

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

- `lurek.layout.centerInArea`: Centers the layout within a given area.
- `lurek.layout.dag`: Lays out a DAG using the Sugiyama layered algorithm.
- `lurek.layout.force`: Lays out a graph using force-directed Fruchterman-Reingold simulation.
- `lurek.layout.snapToGrid`: Snaps all node positions to the nearest grid point.
- `lurek.layout.tree`: Lays out a tree using the Reingold-Tilford algorithm.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.
