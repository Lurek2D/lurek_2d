# map

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/map/`
- Binding: None direct
- Namespace: None direct
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `map` module is documented from the current source tree and existing module reference data.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### mod.rs

- Legacy province-graph map helpers used by older strategy prototypes.
- Owns a lightweight province graph separate from the newer `province` runtime.
- Keeps the older data model available as an exported module for compatibility.

### province.rs

- Province graph data structure storing named territorial regions with ownership, neighbor adjacency lists enabling territorial strategy gameplay.
- Supports dynamic owner assignment and neighbor linking enabling territorial mechanics like conquest, inheritance, and vassal relationships.
- Provides lookup, iteration, and modification methods for managing province territories and diplomatic relationships during campaign gameplay.



## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
