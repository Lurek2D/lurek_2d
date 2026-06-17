# layout

## TL;DR

- Computes graph layouts with grid snapping.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/layout/`
- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`
- Lua API surface: `5` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/layout_tests.rs
- Lua test path(s): tests/lua/unit/test_layout_unit.lua

## Summary

- The layout module gives users automatic 2D node placement for graph-like and tree-like visuals.
- It supports layered DAG layout, recursive tree layout, and force layout for organic relation maps.
- Shared result formats make it easy to swap strategies without changing integration code.
- Grid snapping and centering helpers polish raw coordinates for editor and HUD presentation without discarding existing coordinates.
- The module is useful for tech trees, dialog graphs, dependency maps, and debug topology views.
- Invalid DAG or tree inputs degrade deterministically instead of dropping nodes or recursing forever.
- It replaces manual positioning with repeatable, scriptable layout computation.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### dag.rs

- Provides staged layered layout for directed graphs where flow direction and rank readability are primary goals. `layout/dag` delivers the dag implementation for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Organizes nodes into bands, reorders local neighborhoods to reduce crossings, and then assigns stable screen coordinates.
- Applies spacing and margin policy from shared layout config so outputs align with other module strategies. Public callable behavior is centered on `layout_dag`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Prefers deterministic structure over visual drift to keep dependency and progression maps legible across updates. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### force.rs

- Delivers force-based layout for arbitrary connectivity where organic grouping matters more than strict hierarchy. `layout/force` delivers the force implementation for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Balances repulsion and edge tension over iterative cooling to separate clusters while preserving relation cues. The file owns or coordinates data contracts including `ForceConfig`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes tunable simulation intensity, area bounds, and convergence rhythm for different graph densities. Public callable behavior is centered on `layout_force`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Produces coordinate fields that remain compatible with shared layout result types and downstream alignment passes. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### grid_align.rs

- Provides finishing transforms that regularize raw layout coordinates before visual presentation. `layout/grid_align` delivers the grid align implementation for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Snaps node positions to consistent grid rhythm to improve scanability and manual editing behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Recenters complete layouts into target areas without changing graph topology or sibling ordering. Public callable behavior is centered on `snap_to_grid`, `center_in_area`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### mod.rs

- Aggregates graph and tree layout strategies into one coherent coordinate service for runtime visuals. `layout/mod` is the layout module index, declaring `dag`, `force`, `grid_align`, `tree`, `types` so agents can identify which files own each feature slice before opening implementation code.
- Unifies result and config contracts so callers can switch placement style without changing integration code. `src/layout/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `dag::layout_dag`, `force::{layout_force, ForceConfig}`, `grid_align::{center_in_area, snap_to_grid}`, `tree::layout_tree`, and 1 more centralized for the layout subsystem.

### tree.rs

- Implements rooted hierarchy placement that keeps parent-child reading order clear and branch spacing compact. `layout/tree` delivers the tree implementation for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Walks subtrees recursively to allocate horizontal extent before anchoring parent coordinates in stable positions. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies shared spacing controls to balance density and readability for branching structures of uneven depth. Public callable behavior is centered on `layout_tree`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Targets dialog flows and progression trees that require explicit structure with minimal manual cleanup. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### types.rs

- Defines the common data contract that every layout algorithm in this module reads and writes. `layout/types` delivers the shared type definitions and data contracts for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes node identity, geometry hints, and mutable coordinates in a shape tuned for repeated transforms. The file owns or coordinates data contracts including `NodeId`, `LayoutNode`, `LayoutEdge`, `LayoutConfig`, `LayoutResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Represents graph relations with lightweight edge records that support directional and weighted workflows. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_size`, `with_label`, `with_weight`, `get`, `count` stays attached to the local data model and invariants.
- Packages algorithm outputs into a uniform result container for renderer and tooling consumption. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- `dag` and `tree` keep every input node in the output, even when cycles or disconnected components make the graph invalid for ideal hierarchical layout.
