# bin

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `bin` module namespace groups standalone executable entry points under `src/bin` that support diagnostics, maintenance, migration, and developer-side operational tasks. Unlike engine runtime modules, these binaries are process-level tools with narrow goals and explicit command semantics.

Each binary should remain small, task-oriented, and decoupled from gameplay runtime state. Shared logic should be imported from stable library modules instead of duplicated in command code, so maintenance remains centralized and behavior stays consistent between tooling and runtime surfaces.

This module is intentionally integration-oriented: it wires CLI inputs to engine/library APIs, formats outputs, and exits with clear status codes. It is not intended to host feature-domain business logic.

As the toolset grows, the quality bar is discoverability and reliability: clear command contracts, predictable side effects, and stable output formats that can be consumed by local scripts and CI workflows.

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
