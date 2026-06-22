<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/layout.md or source docstrings instead. -->

# layout

## TL;DR

- Computes graph layouts with grid snapping.

## General Info

- Module group: `Foundations`
- Source path: `src/layout`
- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`
- Lua API surface: `5` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `layout` module is the automatic placement layer for users who need graph-like structures to become readable 2D diagrams without hand-positioning every node.
- It supports different layout strategies for different shapes, so dependency graphs, trees, and more organic maps can use an algorithm that matches the structure.
- This is useful when a graph changes and still needs readable coordinates without manual upkeep.
- Read it as the module that turns abstract structure into stable coordinates.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/layout`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/layout_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### dag.rs

- `src/layout/dag.rs` lays out directed graphs in layers so flow direction, rank order, and dependency reading stay clear.
- It owns layer assignment, cyclic fallback placement, barycenter-based crossing reduction, and per-layer coordinates.
- Shared `LayoutConfig` spacing and margins are applied here so DAG results align with the rest of the layout module.
- This file is the layered-graph algorithm boundary; it does not own shared types, force simulation, or tree recursion.
- Read it when rank construction, crossing reduction, deterministic fallback, or DAG coordinate rules need changes.

### force.rs

- `src/layout/force.rs` computes force-directed graph layouts for cases where clustering matters more than strict rank.
- It owns the simulation loop, repulsion and attraction tuning, cooling, bounded placement, and initial grid seeding.
- `ForceConfig` lives here because iteration count, strengths, and area size are specific to this algorithm family.
- This file outputs shared `LayoutResult` data but does not own node contracts, tree logic, or alignment cleanup.
- Read it when graph spacing, convergence behavior, simulation cost, or force-tuning semantics need to change.

### grid_align.rs

- `src/layout/grid_align.rs` provides finishing passes that snap layout coordinates and center finished results in areas.
- It owns coordinate post-processing only, leaving graph structure, traversal order, and base placement to other files.
- `snap_to_grid` regularizes node positions, while `center_in_area` shifts the whole result into a target rectangle.
- Read it when layout cleanup, presentation alignment, or final bounding-box updates after post-processing need changes.

### mod.rs

- `src/layout/mod.rs` is the module index for layout algorithms, shared types, and post-processing helpers.
- It declares DAG, tree, force, and grid-alignment files while keeping the shared layout contracts in `types.rs`.
- This file reexports the main entry points so callers can switch layout strategy without importing deep module paths.
- No layout state or coordinate math lives here; it only defines the public surface and subsystem ownership map.
- Read this index first when tracing layout behavior, because it shows where algorithms end and shared data begins.
- Changes here affect reachability and API shape, not node placement rules, spacing policy, or result generation.

### tree.rs

- `src/layout/tree.rs` lays out rooted hierarchies by recursively placing children and centering parents over spans.
- It owns deterministic tree traversal, cycle fallback handling, horizontal extent growth, and depth-based y placement.
- Shared `LayoutConfig` spacing rules are applied here so hierarchy outputs stay compatible with other layout modes.
- This file is the hierarchy-specific algorithm boundary; it does not own shared types or post-layout alignment passes.
- Read it when parent-child ordering, subtree spacing, root fallback behavior, or tree coordinate rules need changes.

### types.rs

- `src/layout/types.rs` defines the shared node, edge, config, and result structs used by every layout algorithm.
- It owns the common data contract for ids, positions, sizes, spacing policy, and final bounding-box reporting.
- Lightweight builder helpers live here so node and edge defaults stay attached to the types that consume them.
- This file carries reusable layout data only; it does not choose tree, DAG, force, or alignment strategies.
- Read it when layout payload fields, shared spacing semantics, or result-shape expectations need to change.



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

## Examples

- `content/examples/layout.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_layout_unit.lua` (present)
- Rust: `tests/rust/unit/layout_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_layout_evidence.lua` |
| Golden test | `tests/lua/golden/test_layout_golden.lua` |
| Current artifact | `tests/artifacts/current/layout/layout_center_in_area.png` |
| Current artifact | `tests/artifacts/current/layout/layout_dag_pipeline.png` |
| Current artifact | `tests/artifacts/current/layout/layout_force_cluster.png` |
| Current artifact | `tests/artifacts/current/layout/layout_snap_to_grid.png` |
| Current artifact | `tests/artifacts/current/layout/layout_tree_hierarchy.png` |
| Current artifact | `tests/artifacts/current/ui/layout_dashboard_compact_960x540.png` |
| Current artifact | `tests/artifacts/current/ui/layout_dashboard_desktop_1280x720.png` |
| Current artifact | `tests/artifacts/current/ui/layout_dashboard_fixture.png` |
| Current artifact | `tests/artifacts/current/ui/layout_diplomacy_fixture.png` |
| Current artifact | `tests/artifacts/current/ui/layout_gallery_manifest.txt` |
| Current artifact | `tests/artifacts/current/ui/layout_inventory_fixture.png` |
| Current artifact | `tests/artifacts/current/ui/layout_main_menu_fixture.png` |
| Current artifact | `tests/artifacts/current/ui/layout_rpg_inventory_1280x720.png` |
| Current artifact | `tests/artifacts/current/ui/layout_settings_desktop_1366x768.png` |
| Current artifact | `tests/artifacts/current/ui/layout_settings_fixture.png` |
| Current artifact | `tests/artifacts/current/ui/layout_settings_ultrawide_1920x1080.png` |
| Current artifact | `tests/artifacts/current/ui/layout_strategy_diplomacy_1400x800.png` |
| Baseline artifact | `tests/artifacts/baselines/layout/layout_center_in_area.png` |
| Baseline artifact | `tests/artifacts/baselines/layout/layout_dag_pipeline.png` |
| Baseline artifact | `tests/artifacts/baselines/layout/layout_force_cluster.png` |
| Baseline artifact | `tests/artifacts/baselines/layout/layout_snap_to_grid.png` |
| Baseline artifact | `tests/artifacts/baselines/layout/layout_tree_hierarchy.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_dashboard_compact_960x540.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_dashboard_desktop_1280x720.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_dashboard_fixture.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_diplomacy_fixture.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_gallery_manifest.txt` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_inventory_fixture.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_main_menu_fixture.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_rpg_inventory_1280x720.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_settings_desktop_1366x768.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_settings_fixture.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_settings_ultrawide_1920x1080.png` |
| Baseline artifact | `tests/artifacts/baselines/ui/layout_strategy_diplomacy_1400x800.png` |

## Architecture Links

- Intentionally empty.

## Notes

- `dag` and `tree` keep every input node in the output, even when cycles or disconnected components make the graph invalid for ideal hierarchical layout.
