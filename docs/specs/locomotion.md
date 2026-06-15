# locomotion

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/locomotion/`
- Binding: None direct
- Namespace: None direct
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `locomotion` module is documented from the current source tree and existing module reference data.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- `ai`: Imports or references `src/ai/`. Cross-group dependency from ``Edge/Integration`` into `Feature Systems`.

## Files

### mod.rs

- Legacy compatibility shim for locomotion-facing types.
- Re-exports steering behavior primitives from `crate::ai::steering`.



## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- `ai`: Imports or references `src/ai/`. Cross-group dependency from ``Edge/Integration`` into `Feature Systems`.

## Notes

- No additional module-specific notes.
