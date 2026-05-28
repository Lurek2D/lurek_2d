# Binary Entry

## TL;DR

- Binary entry points own process startup for the Lurek2D executable distribution.
- They sit at the top of the Edge / Integration tier and expose no direct `lurek.*` Lua namespace.
- The Lua-facing binary data module is documented separately in [../specs/binary.md](../specs/binary.md).

## Scope

This document covers executable entry points and adjacent packaging support:

- [../../src/main.rs](../../src/main.rs) - primary `lurek2d` executable entry point.
- [../../src/lib.rs](../../src/lib.rs) - shared `lurek_run()` runtime bootstrap called by launcher binaries.
- [../../src/bin/lurek_headless.rs](../../src/bin/lurek_headless.rs) - headless command-line helper for validation, packing, and screenshot batches.
- [../../src/bin/lurekc.rs](../../src/bin/lurekc.rs) - Windows console-less launcher variant for the shared bootstrap path.
- [../../build.rs](../../build.rs) - build-time resource and packaging support for executable output.

This document does not describe a Rust module under `src/<module>/`, and it is not part of the module-spec roster in [../specs/README.md](../specs/README.md).

## Entry Points

### Primary Executable

[../../src/main.rs](../../src/main.rs) is the `lurek2d` executable entry point declared in [../../Cargo.toml](../../Cargo.toml). On Windows it raises the timer resolution before delegating to `lurek2d::lurek_run()`. It returns the process exit code produced by the shared runtime bootstrap.

### Shared Runtime Bootstrap

`lurek2d::lurek_run()` in [../../src/lib.rs](../../src/lib.rs) is the common startup path used by the primary executable and launcher variants. It owns top-level process concerns such as panic reporting, command-line argument parsing, runtime mode selection, screenshot options, hidden-window options, and final delegation into the application runtime.

The bootstrap path must stay above engine subsystems. It coordinates startup, but game logic, rendering, audio, physics, and Lua API behavior remain in their owning modules.

### Headless Helper

[../../src/bin/lurek_headless.rs](../../src/bin/lurek_headless.rs) is a standalone CLI tool for automation and packaging workflows. It supports:

- `validate [game_dir]` - invokes the Python game validator script.
- `pack <game_dir> <output.lurek>` - compresses a game directory into a distributable `.lurek` archive after checking for `main.lua`.
- `screenshot-batch <games_root> <output_dir> [frames]` - runs the engine for each valid game folder and captures PNG screenshots.

The `validate` and `pack` commands do not require a GPU surface or OS window. `screenshot-batch` spawns engine instances to capture frames.

### Console-Less Launcher

[../../src/bin/lurekc.rs](../../src/bin/lurekc.rs) is a launcher variant for Windows GUI distribution. It applies the Windows GUI subsystem attribute so a terminal window does not open beside the game window, then calls the same `lurek2d::lurek_run()` bootstrap as the primary executable.

It must preserve standard runtime modes and return the same process exit codes as `lurek2d`.

## Responsibilities

Binary entry code may:

- Choose the executable mode from command-line arguments.
- Set process-level platform behavior required before engine startup.
- Configure top-level panic and error reporting.
- Delegate to the shared engine runtime and return its exit code.
- Run packaging or validation helpers that belong to distribution tooling.

Binary entry code must not:

- Add a direct `lurek.*` Lua namespace.
- Own reusable engine business logic.
- Bypass the `app` and `runtime` module ownership boundaries for normal engine execution.
- Become a module spec under `docs/specs/`.

## Relationship To `binary`

`bin` and `binary` are separate concepts:

- Binary entry documentation describes process entry points such as `src/main.rs` and files under `src/bin/`.
- [../specs/binary.md](../specs/binary.md) describes the Lua-facing binary data toolkit implemented under `src/binary/` and registered through `src/lua_api/binary_api.rs`.

Do not use this architecture document as evidence for Lua API coverage. Lua API coverage belongs to generated API docs and module specs.

## Change Checklist

When executable entry behavior changes:

- Update this document if a new binary is added, removed, or changes responsibility.
- Keep [../specs/README.md](../specs/README.md) free of a `bin` row unless a real `src/bin` module with a direct Lua API exists.
- Update [../CHANGELOG.md](../CHANGELOG.md) for user-visible launcher, packaging, or documentation changes.
- Regenerate docs only if source annotations or generated API/spec content changed.
