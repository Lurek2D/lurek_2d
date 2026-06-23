# layout manual spec overlay

## TL;DR

- Computes size-aware graph layouts with post-processing helpers for grid snapping and viewport centering.

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

## Notes

- `dag` and `tree` keep every input node in the output, even when cycles or disconnected components make the graph invalid for ideal hierarchical layout.
- The algorithms are deterministic: the same nodes, edges, and config produce the same coordinates.
- Layout quality tests and evidence assert zero rectangle overlap for complex varied-size inputs across all public layout methods.

## Architecture Links

- Intentionally empty.
