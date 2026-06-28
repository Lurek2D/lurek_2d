<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/bin.md or source docstrings instead. -->

# bin

## TL;DR

- Boots CLI or game.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin`
- Binding: None direct
- Namespace: None direct
- Lua API surface: `0` functions, `0` types, `0` methods
- User-facing: `false`
- Plugin tier: `not_evaluated`

## Summary

- This spec covers executable startup modes.
- `lurek_headless` is for automation, while `lurekc` is for interactive startup.
- Read it as the boundary between tool execution and live play.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/bin`
- Owning tier: `Edge/Integration`
- Plugin tier: `not_evaluated`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### lurek_headless.rs

- `src/bin/lurek_headless.rs` owns the non-interactive CLI used for validation, packaging, and screenshot batch workflows.
- It parses subcommands and dispatches offline operations without opening the normal interactive engine window.
- Validation command wiring, archive packing, recursive ZIP assembly, and batch screenshot orchestration all live here.
- This file is the entrypoint boundary for headless automation tasks, while engine runtime behavior remains elsewhere.
- Read it when CLI command set, archive layout, validator invocation, or screenshot-batch behavior needs to change.

### lurekc.rs

- `src/bin/lurekc.rs` owns the console-suppressed desktop launcher that forwards startup into the shared entrypoint.
- It exists mainly to provide the Windows GUI binary variant while keeping real bootstrap logic in the main library crate.
- Read this file when binary launch behavior or platform-specific subsystem flags change, not when runtime logic changes.



## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## Examples

- No user-facing example is registered for this module.

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
