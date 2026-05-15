# bin

## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): None dedicated
- Lua test path(s): None

## Summary

Executable entry points for the Lurek2D binary distribution. `lurek_headless.rs` provides a windowless runner for CI tests and automation — it initializes the engine without creating a GPU surface or OS window. `lurekc.rs` is the compiler/bundler entry that packages game scripts and assets into a distributable archive.

Neither file contains domain logic; they parse command-line arguments and delegate to `app` and `runtime` for actual execution. The module exists in the Edge/Integration tier solely to host `fn main()` targets.

## Source Documentation

### `lurek_headless.rs`
- Headless CLI tool for game validation, packaging, and batch screenshot capture.
- `validate` subcommand invokes the Python game validator script.
- `pack` subcommand compresses a game directory into a .lurek ZIP archive.
- `screenshot-batch` subcommand runs each game for N frames and captures a PNG.
- No GPU or window required for validate/pack; screenshot-batch spawns engine instances.

### `lurekc.rs`
- Console-less launcher variant for the shared `lurek_run()` bootstrap path.
- Applies the Windows GUI subsystem attribute while preserving all runtime modes.
- Returns the same process exit code as the main `lurek2d` entry point.

## Types

- No public Rust types are currently exposed from this module.

## Functions

- No public Rust functions are currently exposed from this module.

## Lua API Reference

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/bin/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
