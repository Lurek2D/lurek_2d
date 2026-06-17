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

- Implements the headless CLI runner used for validation, packaging, and screenshot batch workflows. `bin/lurek_headless` delivers the lurek headless implementation for the bin subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Dispatches subcommands into deterministic offline operations without opening an interactive runtime window. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Runs game validation tooling and archive packaging against target directories for CI and release prep. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Captures batch screenshots across multiple games to support visual smoke checks in automation pipelines. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### lurekc.rs

- Defines the console-suppressed desktop launcher that delegates to the shared engine bootstrap. `bin/lurekc` delivers the lurekc implementation for the bin subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.



## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
