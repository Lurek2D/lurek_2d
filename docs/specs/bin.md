# bin

## TL;DR

- Boots CLI or game.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Binding: None direct
- Namespace: None direct
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

- Defines how users actually start Lurek2D: either as an interactive desktop run or as a non-interactive CLI workflow.
- Enables automation-oriented use cases like validation, packaging, and screenshot batches without opening a game window.
- Gives one consistent entry layer so teams can switch between local playtesting and pipeline tooling with minimal friction.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### lurek_headless.rs

- Implements the headless CLI runner used for validation, packaging, and screenshot batch workflows.
- Dispatches subcommands into deterministic offline operations without opening an interactive runtime window.
- Runs game validation tooling and archive packaging against target directories for CI and release prep.
- Captures batch screenshots across multiple games to support visual smoke checks in automation pipelines.
- Serves as the command-line entrypoint for non-interactive engine operations.

### lurekc.rs

- Defines the console-suppressed desktop launcher that delegates to the shared engine bootstrap.
- Reuses the main runtime startup path while controlling subsystem behavior on Windows.
- Serves as the minimal binary entrypoint for standard interactive game launch.



## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
