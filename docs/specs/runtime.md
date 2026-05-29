# runtime

## TL;DR

- The `runtime` module forms the very foundation of the Lurek2D dependency graph.

## General Info

- Module group: `Core Runtime`
- Source path: `src/runtime/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.runtime`
- Rust test path(s): tests/rust/unit/runtime_tests.rs, tests/rust/unit/window_tests.rs, tests/rust/ext/graphics_runtime_smoke_tests.rs, plus runtime-focused unit coverage embedded in src/runtime/messages.rs
- Lua test path(s): tests/lua/config/test_config.lua, tests/lua/unit/test_runtime_core_unit.lua

## Summary

As a Core Runtime tier component, it defines the essential shared state, engine configuration, unified error handling, and structured logging mechanisms upon which every other engine subsystem relies. At the heart of the module is `SharedState`, a central, mutable state container accessed via `RefCell` borrows. It orchestrates cross-module communication during a frame, tracking window state, input aggregation, timing profiles, asynchronous file I/O (GameFS), render pipeline configurations, and managing slot-map resource pools (textures, fonts, shaders, particle systems, etc.) while enforcing memory budgets via LRU eviction.

Configuration is driven by the `Config` struct, which parses the `conf.toml` file at startup. It dictates window settings, renderer preferences, performance caps (like Lua callback timeouts), and feature-toggles (`ModulesConfig`) that selectively load or auto-disable engine subsystems based on prerequisites. The runtime actively supports hot-reloading for many configuration values, allowing live tweaks to target FPS, physics ticks, log levels, and viewport settings without restarting the game. The module also robustly handles different startup modes (`gui`, `tui`, `headless`, `cli`), with the headless path specifically designed for script automation and CI testing without requiring window or audio contexts.

Error handling is unified under `EngineError`, an exhaustive enum that categorizes failures across all domains (IO, Lua, GPU, audio, network, physics) with stable, machine-readable codes (e.g., `E1001`) and actionable recovery hints. Complementing this is a comprehensive log message catalog driven by an embedded TOML file. It provides structured, consistent diagnostic output (using codes like `L001` or `G012`) via the `log_msg!` macro. To ensure safe and efficient resource management across the engine, the module defines strongly-typed `slotmap` keys (`TextureKey`, `FontKey`, etc.) that act as lightweight, generationally-checked handles suitable for storage within Lua userdata. Though most of the infrastructure is consumed through higher-level modules, the canonical runtime Lua surface is `lurek.runtime`.

### Lua API Bridge and Registration

The old `lua_api` spec duplicated this runtime namespace. Its relevant contract now lives here: `src/lua_api/` is the Edge/Integration bridge that creates sandboxed Lua VMs, installs the sealed `lurek` global, and registers every enabled `lurek.*` namespace against the runtime `SharedState`.

Module registration is trait-based. Each binding file implements a `register(lua, lurek, state)` entry point, and `src/lua_api/register.rs` walks the static `MODULES` slice using `always!` and `gated!` entries. Feature-gated modules that cannot appear in that static slice are registered after the standard pass. Binding files remain translation-only: they parse Lua values, borrow `SharedState`, call domain modules, and convert results back to Lua without owning business logic.

For the full Lua/Rust boundary design, see [docs/architecture/lua-rust-boundary.md](../architecture/lua-rust-boundary.md).

## Files

### config.rs

- Runtime configuration types parsed from `conf.toml` at engine startup.
- Top-level `Config` struct with sections for window, renderer, modules, and performance.
- Feature-toggle table (`ModulesConfig`) controlling which engine subsystems are loaded.
- Dependency validation that auto-disables modules when prerequisites are off.
- TOML merge logic: user overrides are layered on top of built-in defaults.
- Serde-based serialization for round-trip configuration persistence.

### error.rs

- Defines `EngineError` — the engine-wide error enum covering all subsystem failures.
- Provides `ErrorCategory` for high-level failure classification (init, runtime, resource, script, filesystem, system).
- Assigns stable machine-readable error codes (`E1001`–`E1012`) and recovery hints per variant.
- Exposes `ErrorSnapshot` for serializable log/UI output with compact JSON encoding.
- Supplies the `EngineResult<T>` convenience alias used throughout the runtime.

### headless.rs

- Implements the no-window headless runtime path for script automation and CI use.
- `HeadlessOptions` carries game directory, eval snippets, and an optional frame-count override.
- `run_headless` maps engine errors to process exit codes; `run_headless_checked` preserves structured errors for test callers.
- Init sequence installs a stdout-routed `print` global and prepends game-directory roots to `package.path`.
- Frame loop drives `process_physics`, `fixedUpdate`, `process`, and `process_late` in order; count and dt come from config or CLI flag.
- Callback timeout is enforced via Lua instruction-count hooks when a limit is configured in `PerformanceConfig`.

### log_messages.rs

- Stable, structured log message identifiers for all engine subsystems.
- Each constant provides a short code (e.g. "L001") used as prefix in log output.
- Identifiers grouped by domain: L=lifecycle, A=audio, G=graphics, P=physics, FS=filesystem.
- Additional prefixes: AN=animation, EN=ECS, TM=tilemap, SV=save, SC=scene, TH=thread, PF=pathfind.
- Extended prefixes: MD=mods, NW=network, PL=pipeline, AT=automation, CP=compute, SR=serial, GU=GUI.
- Runtime log level control via set_log_level/get_log_level with atomic override.
- log_msg! macro for consistent formatted log output with message lookup.
- Codes are stable across versions for log parsing, alerting, and external tool integration.

### messages.rs

- Embedded TOML-based message catalog for runtime log and display text.
- Lazy one-shot initialization with fallback to raw identifiers.
- Recursive string extraction from nested TOML tables.

### mod.rs

- Engine runtime foundations: configuration, shared state, and error types.
- Loads `conf.toml` into a typed `Config` struct consumed by all subsystems.
- Provides `SharedState` for mutable cross-module communication during a frame.
- Defines `EngineError` variants and slot-map resource keys.

### mode.rs

- Defines `RuntimeMode` enum with four variants: `gui`, `tui`, `headless`, and `cli`.
- Provides lowercase string tokens for config serialization and CLI parsing via `as_str` and `Display`.
- `FromStr` accepts any casing and returns a typed parse error that names the rejected token.
- Used by `config.rs` during TOML deserialization and by `main.rs` to select the startup path.

### os.rs

- Operating system detection utilities for platform-specific code paths.
- `get_os_name()` returns a lowercase string: `"windows"`, `"linux"`, or `"macos"`.
- Used at startup to set OS-specific defaults (e.g. font paths, config directories).
- Exposed to Lua via `lurek.runtime.os()` for platform-conditional game scripts.
- Built on `cfg!` macros; no runtime OS probing, so the result is always correct.

### resource_keys.rs

- Typed slotmap keys for every engine resource pool (textures, fonts, sounds, particles, etc.).
- Each key is a lightweight handle safe to store in Lua userdata and pass across frames.
- Generated via `slotmap::new_key_type!` for O(1) lookup with generational validity checks.

### shared_state.rs

- Central mutable state container shared across all engine subsystems during a frame.
- Window state tracking: focus, DPI, fullscreen, scale mode, and pending resize/move requests.
- Resource pools via SlotMap for textures, fonts, canvases, shaders, meshes, and particle systems.
- Input aggregation: keyboard, mouse, touch, and gamepad state with vibration requests.
- Timing and profiling: frame clock, delta time, FPS, per-phase timing breakdown.
- Memory budget enforcement with LRU eviction of textures and canvases.
- Asynchronous file I/O through GameFS with poll-based completion.
- Physics stepping configuration and run-state parameters.
- Render pipeline state: blend mode, stencil, depth, scissor, color mask, and command buffer.
- Province registries, parallax layers, tilemaps, raycaster output, and UI context weak refs.

## Lua API Ref

- Binding: None direct
- Namespace: `lurek.runtime`

### Functions

- No documented module-level functions.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `audio`: Imports or references `audio` from `src/audio/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Core Runtime` into `Platform Services`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: `src/lua_api/system_api.rs`, `src/lua_api/engine_api.rs`, and `src/lua_api/register.rs` expose the runtime contract to Lua. `src/runtime/` must not import the binding layer.
- `midi`: Imports or references `src/midi/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `parallax`: Imports or references `parallax` from `src/parallax/`.
- `particle`: Imports or references `particle` from `src/particle/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `raycaster`: Imports or references `raycaster` from `src/raycaster/`.
- `render`: Imports or references `render` from `src/render/`.
- `repl`: Imports or references `src/repl/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `tilemap` from `src/tilemap/`.
- `timer`: Imports or references `timer` from `src/timer/`.
- `ui`: Imports or references `ui` from `src/ui/`.
