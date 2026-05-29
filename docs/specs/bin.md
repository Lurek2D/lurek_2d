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

- Headless CLI entry point for offline game validation, archive packaging, and batch screenshot capture.
- Accepts a subcommand — `validate`, `pack`, or `screenshot-batch` — from argv and dispatches to the matching function.
- `validate` runs the Python game-validation script on a target directory; `pack` zips a game folder into a `.lurek` archive.
- `screenshot-batch` iterates a games root directory, captures a fixed number of frames from each game, and writes PNG files to an output directory for CI smoke-test comparison.

### lurekc.rs

- Console-less launcher variant for the shared `lurek_run()` bootstrap path.

## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
