# layout manual spec overlay

## TL;DR

- Computes graph layouts with grid snapping.

## Summary

- The `layout` module is the automatic placement layer for users who need graph-like structures to become readable 2D diagrams without hand-positioning every node.
- It supports different layout strategies for different shapes, so dependency graphs, trees, and more organic maps can use an algorithm that matches the structure.
- This is useful when a graph changes and still needs readable coordinates without manual upkeep.
- Read it as the module that turns abstract structure into stable coordinates.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- `dag` and `tree` keep every input node in the output, even when cycles or disconnected components make the graph invalid for ideal hierarchical layout.

## Architecture Links

- Intentionally empty.
