# bin

## TL;DR

- The `bin` module provides the executable entry points for the Lurek2D binary distribution, serving as the very top of the Edge/Integration tier.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): None dedicated
- Lua test path(s): None

## Summary

 Its primary responsibility is to host the `fn main()` targets that initialize the runtime environment and delegate control to the core engine. This module contains no intrinsic game logic; instead, it parses command-line arguments and coordinates the initialization sequence by calling into the `app` and `runtime` modules.

The module provides two distinct entry points tailored for different distribution contexts. The first is `lurek_headless.rs`, a specialized CLI tool designed for automation, testing, and game validation. It initializes the engine without creating a GPU surface or OS window, making it ideal for CI pipelines. This headless runner supports several subcommands: `validate` invokes external Python scripts for game data validation, `pack` compresses a game directory into a distributable `.lurek` ZIP archive, and `screenshot-batch` systematically spawns engine instances to capture PNG screenshots over a set number of frames.

The second entry point is `lurekc.rs`, which serves as a console-less launcher variant for the engine's standard bootstrap path. It applies the Windows GUI subsystem attribute to ensure no terminal window spawns alongside the game window, providing a seamless experience for end users. It preserves all standard runtime modes and accurately returns process exit codes. By isolating these `main` targets, the `bin` module cleanly separates executable concerns from the engine library.

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
