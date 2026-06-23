<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/layout.md or source docstrings instead. -->

# layout

## TL;DR

- Computes size-aware graph layouts with post-processing helpers for grid snapping and viewport centering.

## General Info

- Module group: `Foundations`
- Source path: `src/layout`
- Binding: `src/lua_api/layout_api.rs`
- Namespace: `lurek.layout`
- Lua API surface: `10` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `layout` module is the automatic placement layer for users who need graph-like structures to become readable 2D diagrams without hand-positioning every node.
- It supports different layout strategies for different shapes, so dependency graphs, trees, and more organic maps can use an algorithm that matches the structure.
- Tree and DAG layouts account for real node widths and heights, so larger labels or panels do not collapse into adjacent siblings or ranks.
- Circular and radial layouts compute ring radii from node dimensions instead of using a naive count-only radius.
- Grid layout scores candidate column counts and uses variable row/column sizes for dense or disconnected inputs.
- Spiral, force, and stress layouts include rectangle-aware overlap reduction for larger unordered graphs.
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

### circular.rs

- Owns deterministic circular placement for cycle-heavy graphs, overviews, and equal-emphasis node sets.
- Computes a chord-safe radius from real node sizes and spacing, then places sorted ids on one ring.
- Keeps no graph traversal state; change this file only for ring geometry, radius, or ordering behavior.

### dag.rs

- `src/layout/dag.rs` lays out directed graphs in layers so flow direction, rank order, and dependency reading stay clear.
- It owns layer assignment, cyclic fallback placement, barycenter ordering, and centered per-layer coordinates.
- Shared `LayoutConfig` spacing and margins are applied here so DAG results align with the rest of the layout module.
- This file is the layered-graph algorithm boundary; it does not own shared types, force simulation, or tree recursion.
- Read it when rank construction, crossing reduction, deterministic fallback, or DAG coordinate rules need changes.

### force.rs

- `src/layout/force.rs` computes force-directed graph layouts for cases where clustering matters more than strict rank.
- It owns simulation, size-aware forces, cooling, bounded placement, initial seeding, and overlap cleanup.
- `ForceConfig` lives here because iteration count, strengths, and area size are specific to this algorithm family.
- This file outputs shared `LayoutResult` data but does not own node contracts, tree logic, or alignment cleanup.
- Read it when graph spacing, convergence behavior, simulation cost, or force-tuning semantics need to change.

### grid.rs

- Owns deterministic row-column placement for dense, disconnected, or topology-neutral node sets.
- Scores candidate column counts using real node widths, row heights, area, and readable aspect ratio.
- Ignores edges by design, making it a fast fallback when graph topology should not drive placement.
- Change this file for packed-grid defaults, variable cell sizing, or deterministic ordering behavior.

### grid_align.rs

- `src/layout/grid_align.rs` provides finishing passes that snap layout coordinates and center finished results in areas.
- It owns coordinate post-processing only, leaving graph structure, traversal order, and base placement to other files.
- `snap_to_grid` regularizes node positions, while `center_in_area` shifts the whole result into a target rectangle.
- Read it when layout cleanup, presentation alignment, or final bounding-box updates after post-processing need changes.

### mod.rs

- Indexes layout algorithms, shared payload types, and coordinate post-processing helper owners.
- Declares tree, DAG, force, circular, radial, grid, spiral, stress, and alignment submodules.
- Reexports main entry points so callers switch strategies without depending on deep owner paths.
- Keeps coordinate math and live state out of this file; sibling modules own placement behavior.
- Guides agents to the right algorithm owner before changing spacing, overlap, or result geometry.
- Changes here affect reachability and API shape, not placement rules, spacing policy, or results.

### radial.rs

- `src/layout/radial.rs` owns concentric breadth-first graph placement for hub-and-spoke and network-map views.
- It provides a deterministic radial layout similar to Graphviz twopi, grouping nodes by hop distance from a root.
- Edges are treated as undirected for level discovery so arbitrary graph data can still produce useful rings.
- Rings use chord-safe radii and parent-angle ordering so dense branches avoid obvious overlap and crossings.
- Read it when radial ring assignment, root handling, or disconnected fallback placement need to change.

### spiral.rs

- Owns expanding spiral placement for large unordered graphs, search results, and map-like previews.
- Sorts node ids, probes a golden-angle spiral, and rejects positions colliding with prior nodes.
- Ignores edges for fast refreshes; change this file for spacing, probes, or collision policy.

### stress.rs

- `src/layout/stress.rs` owns distance-preserving graph placement for topology-readable arbitrary graphs.
- It provides a lightweight stress layout inspired by multidimensional scaling without keeping persistent solver state.
- The algorithm computes graph distances, seeds positions on a circle, relaxes pairs, and clears overlaps.
- Iteration count is capped through `StressConfig` so callers can choose stable output or fast 10 FPS refreshes.
- Read it when graph-distance preservation, relaxation cost, or default stress tuning need to change.

### tree.rs

- `src/layout/tree.rs` lays out rooted hierarchies by recursively placing children and centering parents over spans.
- It owns deterministic traversal, cycle fallback handling, subtree spans, and depth-based y placement.
- Shared `LayoutConfig` spacing rules are applied here so hierarchy outputs stay compatible with other layout modes.
- This file is the hierarchy-specific algorithm boundary; it does not own shared types or post-layout alignment passes.
- Read it when parent-child ordering, subtree spacing, root fallback behavior, or tree coordinate rules need changes.

### types.rs

- Defines shared node, edge, config, and result structs consumed by every layout algorithm owner.
- Owns common ids, positions, sizes, spacing policy, labels, and final bounding-box reporting.
- Keeps builder helpers attached to the payload types that Lua bindings and Rust algorithms consume.
- Provides rectangle overlap, positive size, and margin normalization helpers for quality cleanup.
- Carries reusable layout data only; it does not choose tree, DAG, force, radial, or grid strategy.
- Change this file when payload fields, shared spacing semantics, or result shape expectations move.



## Lua API Ref

### Functions

- `lurek.layout.centerInArea(result, width, height) -> table`: Centers the layout within a given area.
- `lurek.layout.circular(nodes, config?) -> table`: Lays out nodes around a chord-safe circle for cycle-heavy graphs and overviews.
- `lurek.layout.dag(nodes, edges, config?) -> table`: Lays out a size-aware DAG with centered layers, stable barycenter ordering, and height-aware ranks.
- `lurek.layout.force(nodes, edges, config?) -> table`: Lays out a graph using bounded size-aware force simulation with final overlap cleanup.
- `lurek.layout.grid(nodes, config?) -> table`: Lays out nodes in a compact variable-size grid for dense or disconnected graphs.
- `lurek.layout.radial(nodes, edges, root, config) -> table`: Lays out a graph on size-aware breadth-first concentric rings from a root node.
- `lurek.layout.snapToGrid(result, gridSize) -> table`: Snaps all node positions to the nearest grid point.
- `lurek.layout.spiral(nodes, config?) -> table`: Lays out nodes on an expanding overlap-checked spiral for fast large-graph refreshes.
- `lurek.layout.stress(nodes, edges, config?) -> table`: Lays out a graph by preserving graph-distance relationships with bounded relaxation and cleanup.
- `lurek.layout.tree(nodes, children, root, config) -> table`: Lays out a size-aware tree, centering parents over child spans and keeping disconnected nodes.

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
| Current artifact | `tests/artifacts/current/layout/layout_circular_cycle_network.png` |
| Current artifact | `tests/artifacts/current/layout/layout_dag_pipeline.png` |
| Current artifact | `tests/artifacts/current/layout/layout_force_cluster.png` |
| Current artifact | `tests/artifacts/current/layout/layout_grid_inventory_matrix.png` |
| Current artifact | `tests/artifacts/current/layout/layout_quality_metrics.txt` |
| Current artifact | `tests/artifacts/current/layout/layout_radial_service_topology.png` |
| Current artifact | `tests/artifacts/current/layout/layout_snap_to_grid.png` |
| Current artifact | `tests/artifacts/current/layout/layout_spiral_large_unordered.png` |
| Current artifact | `tests/artifacts/current/layout/layout_stress_distance_network.png` |
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
| Baseline artifact | `tests/artifacts/baselines/layout/layout_quality_metrics.txt` |
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
- The algorithms are deterministic: the same nodes, edges, and config produce the same coordinates.
- Layout quality tests and evidence assert zero rectangle overlap for complex varied-size inputs across all public layout methods.
