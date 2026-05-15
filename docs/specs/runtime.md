# runtime

## General Info

- Module group: `Core Runtime`
- Source path: `src/runtime/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.runtime`
- Rust test path(s): tests/rust/unit/runtime_tests.rs, tests/rust/unit/window_tests.rs, tests/rust/ext/graphics_runtime_smoke_tests.rs, plus runtime-focused unit coverage embedded in src/runtime/messages.rs
- Lua test path(s): tests/lua/config/test_config.lua, tests/lua/unit/test_runtime_core_unit.lua

## Summary

Foundational shared state, engine configuration, error types, resource keys, and the log message catalog forming the root of the engine dependency graph. `SharedState` is the central mutable container holding all engine subsystem instances — accessed via `RefCell` borrows by binding code. `Config` stores TOML-parsed engine settings (window size, audio device, physics step, asset paths).

`EngineError` is the unified error enum with variants for every failure domain (IO, Lua, GPU, audio, network, physics, parse). `RuntimeMode` distinguishes normal execution from headless test mode. Resource keys (`TextureKey`, `SoundKey`, `FontKey`) provide typed handles for asset lookup. The log message catalog defines structured message codes used by all modules for consistent diagnostic output. Exposed as `lurek.runtime.*`. Core Runtime tier — imported by every module.

## Source Documentation

### `config.rs`
- Runtime configuration types parsed from `conf.toml` at engine startup.
- Top-level `Config` struct with sections for window, renderer, modules, and performance.
- Feature-toggle table (`ModulesConfig`) controlling which engine subsystems are loaded.
- Dependency validation that auto-disables modules when prerequisites are off.
- TOML merge logic: user overrides are layered on top of built-in defaults.
- Serde-based serialization for round-trip configuration persistence.

### `error.rs`
- Defines `EngineError` — the engine-wide error enum covering all subsystem failures.
- Provides `ErrorCategory` for high-level failure classification (init, runtime, resource, script, filesystem, system).
- Assigns stable machine-readable error codes (`E1001`–`E1012`) and recovery hints per variant.
- Exposes `ErrorSnapshot` for serializable log/UI output with compact JSON encoding.
- Supplies the `EngineResult<T>` convenience alias used throughout the runtime.

### `headless.rs`
- Implements the no-window headless runtime path for script automation and CI use.
- `HeadlessOptions` carries game directory, eval snippets, and an optional frame-count override.
- `run_headless` maps engine errors to process exit codes; `run_headless_checked` preserves structured errors for test callers.
- Init sequence installs a stdout-routed `print` global and prepends game-directory roots to `package.path`.
- Frame loop drives `process_physics`, `fixedUpdate`, `process`, and `process_late` in order; count and dt come from config or CLI flag.
- Callback timeout is enforced via Lua instruction-count hooks when a limit is configured in `PerformanceConfig`.

### `log_messages.rs`
- Stable, structured log message identifiers for all engine subsystems.
- Each constant provides a short code (e.g. "L001") used as prefix in log output.
- Identifiers grouped by domain: L=lifecycle, A=audio, G=graphics, P=physics, FS=filesystem.
- Additional prefixes: AN=animation, EN=ECS, TM=tilemap, SV=save, SC=scene, TH=thread, PF=pathfind.
- Extended prefixes: MD=mods, NW=network, PL=pipeline, AT=automation, CP=compute, SR=serial, GU=GUI.
- Runtime log level control via set_log_level/get_log_level with atomic override.
- log_msg! macro for consistent formatted log output with message lookup.
- Codes are stable across versions for log parsing, alerting, and external tool integration.

### `messages.rs`
- Embedded TOML-based message catalog for runtime log and display text.
- Lazy one-shot initialization with fallback to raw identifiers.
- Recursive string extraction from nested TOML tables.

### `mod.rs`
- Engine runtime foundations: configuration, shared state, and error types.
- Loads `conf.toml` into a typed `Config` struct consumed by all subsystems.
- Provides `SharedState` for mutable cross-module communication during a frame.
- Defines `EngineError` variants and slot-map resource keys.

### `mode.rs`
- Defines `RuntimeMode` enum with four variants: `gui`, `tui`, `headless`, and `cli`.
- Provides lowercase string tokens for config serialization and CLI parsing via `as_str` and `Display`.
- `FromStr` accepts any casing and returns a typed parse error that names the rejected token.
- Used by `config.rs` during TOML deserialization and by `main.rs` to select the startup path.

### `resource_keys.rs`
- Typed slotmap keys for every engine resource pool (textures, fonts, sounds, particles, etc.).
- Each key is a lightweight handle safe to store in Lua userdata and pass across frames.
- Generated via `slotmap::new_key_type!` for O(1) lookup with generational validity checks.

### `shared_state.rs`
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

## Types

- `Config` (`struct`, `config.rs`): Top-level engine configuration.
- `RuntimeConfig` (`struct`, `config.rs`): `[runtime]` table holding the selected startup mode.
- `RenderConfig` (`struct`, `config.rs`): GPU backend and power-preference settings resolved once at engine startup.
- `WindowConfig` (`struct`, `config.rs`): Window dimensions, title, vsync, fullscreen, and resize settings.
- `TuiConfig` (`struct`, `config.rs`): Terminal-grid window defaults for GUI-backed TUI startup.
- `CliConfig` (`struct`, `config.rs`): Terminal-grid and history defaults for GUI-backed CLI startup.
- `HeadlessConfig` (`struct`, `config.rs`): Headless frame count and `dt` defaults.
- `ModulesConfig` (`struct`, `config.rs`): Flags to enable or disable optional engine subsystems.
- `PerformanceConfig` (`struct`, `config.rs`): Frame rate cap and other performance tuning options.
- `ErrorCategory` (`enum`, `error.rs`): Error category for grouping related engine errors.
- `EngineError` (`enum`, `error.rs`): All possible error conditions that can occur in the Lurek2D engine.
- `EngineResult` (`type`, `error.rs`): Convenience alias for `Result<T, EngineError>` used throughout the engine.
- `ErrorSnapshot` (`struct`, `error.rs`): A serialisable snapshot of an engine error.
- `HeadlessOptions` (`struct`, `headless.rs`): CLI-derived inputs for one headless run.
- `MessageCatalog` (`struct`, `messages.rs`): Immutable map from stable message ID (e.g.
- `RuntimeMode` (`enum`, `mode.rs`): Supported startup modes: `gui`, `tui`, `headless`, and `cli`.
- `RuntimeModeParseError` (`struct`, `mode.rs`): Error for invalid mode tokens.
- `TextureKey` (`struct`, `resource_keys.rs`): Key for texture resources stored in SharedState.
- `FontKey` (`struct`, `resource_keys.rs`): Key for font resources stored in SharedState.
- `CanvasKey` (`struct`, `resource_keys.rs`): Key for canvas off-screen render targets.
- `SoundKey` (`struct`, `resource_keys.rs`): Key for audio source entries in the Mixer.
- `ParticleKey` (`struct`, `resource_keys.rs`): Key for particle system instances.
- `SpriteBatchKey` (`struct`, `resource_keys.rs`): Key for sprite batch instances.
- `ShaderKey` (`struct`, `resource_keys.rs`): Key for custom shader instances.
- `MeshKey` (`struct`, `resource_keys.rs`): Key for mesh instances.
- `ShapeKey` (`struct`, `resource_keys.rs`): Key for compound shape instances.
- `BusKey` (`struct`, `resource_keys.rs`): Key for audio bus instances in the Mixer.
- `MidiPlayerKey` (`struct`, `resource_keys.rs`): Key for MIDI player instances.
- `QueueableKey` (`struct`, `resource_keys.rs`): Key for queueable audio source instances in the Mixer.
- `LightKey` (`struct`, `resource_keys.rs`): Key for light source instances in LightWorld.
- `OccluderKey` (`struct`, `resource_keys.rs`): Key for shadow occluder instances in LightWorld.
- `FullscreenType` (`enum`, `shared_state.rs`): Fullscreen mode type for window management.
- `WindowState` (`struct`, `shared_state.rs`): Tracks window state and queues window operations for the event loop.
- `ErrorInfo` (`struct`, `shared_state.rs`): Structured error information for the last engine error.
- `ScreenshotRequest` (`struct`, `shared_state.rs`): Pending request to save the next rendered screen frame as a PNG.
- `FrameProfile` (`struct`, `shared_state.rs`): Per-frame callback timing snapshot recorded by the app loop.
- `ResourceMemoryStats` (`struct`, `shared_state.rs`): Resource-memory accounting snapshot with per-kind bytes and counts.
- `PhysicsRunConfig` (`struct`, `shared_state.rs`): Physics and fixed-update runtime configuration sub-domain (`fixed_dt`, `max_steps`, `debug_draw`, `fixed_update_dt`), held as `SharedState::physics_run`.
- `SharedState` (`struct`, `shared_state.rs`): Shared mutable state passed via `Rc<RefCell<SharedState>>` to all Lua API closures and the engine loop.
- `RendererStats` (`struct`, `shared_state.rs`): Snapshot of renderer statistics for a single frame.

## Functions

- `ModulesConfig::apply_headless_profile` (`config.rs`): Force module switches that must be disabled in no-window headless runtime.
- `ModulesConfig::validate_and_fix` (`config.rs`): Disable modules whose dependencies are not enabled and emit warnings.
- `Config::load` (`config.rs`): Load configuration, preferring `conf.toml` when it exists in `game_dir`.
- `Config::load_from_conf_toml` (`config.rs`): Parse `conf.toml`, merge it over defaults, and return config with optional parse error.
- `ErrorCategory::as_str` (`error.rs`): Map error category to stable lowercase identifier string.
- `EngineError::code` (`error.rs`): Return stable machine-readable error code for this variant.
- `EngineError::category` (`error.rs`): Return high-level category used for diagnostics grouping.
- `EngineError::recovery_hint` (`error.rs`): Return operator hint describing likely remediation path.
- `ErrorSnapshot::to_json` (`error.rs`): Encode snapshot as compact JSON for external consumers.
- `EngineError::snapshot` (`error.rs`): Build snapshot payload from this error value.
- `run_headless` (`headless.rs`): Runs the no-window Lua runtime and maps errors to `ExitCode`.
- `run_headless_checked` (`headless.rs`): Runs headless while preserving structured engine errors for tests.
- `set_log_level` (`log_messages.rs`): Sets the global log level at runtime (called from `lurek.runtime.setLogLevel`).
- `get_log_level` (`log_messages.rs`): Returns the current log level name.
- `MessageCatalog::from_toml` (`messages.rs`): Parse TOML and build a message catalog map; keep empty map on parse errors.
- `MessageCatalog::get` (`messages.rs`): Fetch message text for one identifier if present.
- `MessageCatalog::len` (`messages.rs`): Count entries currently loaded in the catalog.
- `MessageCatalog::is_empty` (`messages.rs`): Check whether the catalog has zero loaded entries.
- `init` (`messages.rs`): Initialise the global message catalog from the embedded TOML.
- `get_message` (`messages.rs`): Resolve a stable message ID to its human-readable text.
- `resolve_message` (`messages.rs`): Resolve an arbitrary message ID to its human-readable text.
- `has_message` (`messages.rs`): Returns `true` if the global message catalog contains the given ID.
- `message_count` (`messages.rs`): Number of entries currently registered in the global message catalog.
- `catalog` (`messages.rs`): Returns a reference to the global [`MessageCatalog`], or `None` if [`init`] has not been called yet.
- `RuntimeMode::as_str` (`mode.rs`): Return the lowercase config and CLI token for this mode.
- `RuntimeModeParseError::value` (`mode.rs`): Return the invalid token supplied by the caller.
- `SharedState::new` (`shared_state.rs`): Create a new shared state with initial window dimensions, title, and game directory.
- `SharedState::step_timer` (`shared_state.rs`): Advance the frame clock and update delta time, FPS, and total time.
- `SharedState::touch_texture` (`shared_state.rs`): Mark a texture as recently used for LRU eviction tracking.
- `SharedState::touch_canvas` (`shared_state.rs`): Mark a canvas as recently used for LRU eviction tracking.
- `SharedState::evict_lru_resources` (`shared_state.rs`): Evict least-recently-used textures until memory usage is within budget.
- `SharedState::resource_memory_stats` (`shared_state.rs`): Compute current resource memory usage across all asset types.
- `SharedState::request_async_load` (`shared_state.rs`): Submit an asynchronous file read and return a poll handle.
- `SharedState::request_async_write` (`shared_state.rs`): Submit an asynchronous file write and return a poll handle.
- `SharedState::load_default_fonts` (`shared_state.rs`): Load all built-in font sizes and set the default active font.
- `SharedState::poll_async_load` (`shared_state.rs`): Check the status of a pending asynchronous read operation.
- `SharedState::poll_async_write` (`shared_state.rs`): Check the status of a pending asynchronous write operation.
- `SharedState::compute_stats` (`shared_state.rs`): Compute aggregate renderer statistics for the current frame.

## Lua API Reference

- Namespace: `lurek.runtime`

## References

- `audio`: Imports or references `audio` from `src/audio/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Core Runtime` into `Platform Services`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: Imports or references `src/lua_api/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
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

## Notes

- Keep this module reference synchronized with `src/runtime/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
- **conf.toml only (updated 2026-04-21)**: `conf.lua` support has been removed. `Config::load` tries `conf.toml` and returns `Config::default()` if absent. `load_from_conf_lua`, `build_config_table`, and `read_config_table` have been deleted. Configuration is TOML-only.
- **Hot-reload (updated 2026-05-07)**: `app` now watches `conf.toml` and applies mutable settings live (target fps, physics tick, fixed update tick, log level, window title, viewport scale mode) while incrementing a runtime config revision counter.
- **Hot-reload programmatic trigger (updated 2026-05-12)**: `lurek.runtime.reloadConfig()` sets `SharedState::pending_config_reload`; the app loop consumes this flag and calls `FileWatcher::force_changed()` before the normal `poll_config_hot_reload` path, enabling Lua-triggered reloads without requiring a file change on disk.
- **Config inspector (updated 2026-05-12, extended 2026-05-15)**: `lurek.runtime.getConfig()` returns a snapshot table of active runtime-mutable config values and startup mode state: `runtime_mode`, `physics_tick_rate`, `fixed_update_tick_rate`, `frame_budget_warn_ms`, `lua_callback_timeout_ms`, `vsync`, `log_level`, `config_reload_revision`.
- **PhysicsRunConfig (updated 2026-05-12)**: Four physics-related fields (`physics_fixed_dt`, `physics_max_steps`, `fixed_update_dt`, `physics_debug_draw`) removed from flat `SharedState` and grouped into `PhysicsRunConfig` sub-struct accessible as `SharedState::physics_run`.
- **evict_lru_resources total budget (updated 2026-05-12)**: Eviction check now uses `resource_memory_stats().total_bytes` (textures + fonts + canvases + shaders) instead of texture-only byte sum. `canvas_last_used` map and `touch_canvas()` method added for canvas recency tracking. Internal allocation pattern improved: `Vec::with_capacity` + `sort_unstable_by_key`.
- **messages.rs unsafe removed (updated 2026-05-12)**: `MessageCatalog` stores `&'static str` values via `Box::leak` in `collect_strings`; no `unsafe` blocks remain in `messages.rs`. `get_message` return type and `MessageCatalog::get` return type unchanged.
- **Engine diagnostics (updated 2026-05-12)**: `lurek.engine.getResourceStats()` includes per-kind bytes/counts (`texture`, `font`, `canvas`, `shader`, `total`), `lurek.engine.getFrameProfile()` now includes both callback buckets and app-loop buckets (`app_tick_ms`, `app_update_ms`, `app_render_ms`, `app_frame_total_ms`), and `lurek.engine.getFrameProfileText()` returns a compact one-line timing summary.
- **Lua callback timeout (updated 2026-05-12)**: `[performance].lua_callback_timeout_ms` is mirrored into runtime state and enforced for app-driven Lua callbacks via an instruction hook. Timeouts are surfaced as runtime errors and route the app to `RunState::Error`.
- **Runtime modes (updated 2026-05-15)**: `[runtime].mode` accepts `gui`, `tui`, `headless`, and `cli`. CLI flags `--mode=...`, `--gui`, `--tui`, `--headless`, and `--cli` override config. GUI remains the default and still routes through `App::run`. TUI and CLI also use the GUI event loop, but force a terminal-grid window sized from `[tui]` or `[cli]` config. Headless bypasses `App::run` and runs without window, render, input, audio, or terminal modules.
- **Headless callbacks (updated 2026-05-15)**: `--headless` loads `main.lua` only when a game directory was supplied, runs any `--eval` snippets, calls `lurek.init()` and `lurek.ready()` if present, then runs configured or CLI-specified frames through `lurek.process_physics(dt)`, `lurek.fixedUpdate(dt)`, `lurek.process(dt)`, and `lurek.process_late(dt)` without draw callbacks.
