# runtime

## General Info

- Module group: `Core Runtime`
- Source path: `src/runtime/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): tests/rust/unit/window_tests.rs, tests/rust/ext/graphics_runtime_smoke_tests.rs, plus runtime-focused unit coverage embedded in src/runtime/messages.rs
- Lua test path(s): tests/lua/config/test_config.lua, tests/lua/harness.rs

## Summary

The runtime module is the engine's shared substrate. It defines startup configuration, the canonical engine error type, stable log message IDs, the embedded human-readable message catalog, and the central `SharedState` object that all Lua bindings and the main loop mutate through `Rc<RefCell<_>>`.

This module exists so the rest of Lurek2D can agree on a single source of truth for engine-wide state and identifiers. Rendering, input, audio, events, timers, filesystem access, and many higher-level systems all meet here through typed resource pools, per-frame timing fields, the event queue, and pending runtime actions such as restart, quit, async loads, and screenshots.

It intentionally does not own subsystem behavior. Rendering logic lives in `render`, audio mixing in `audio`, input device state machines in `input`, sandboxed path policy in `filesystem`, and Lua-facing registration in `src/lua_api/`. If a change is about how a subsystem behaves rather than how global state is stored or shared, that change usually belongs outside `runtime`.

**Scope boundary**: This module currently depends on `audio`, `camera`, `event`, `filesystem`, `input`, `light`, `parallax`, `particle`, and other adjacent modules. It stays within the Core Runtime responsibility boundary defined in the architecture docs.

## Files

- `config.rs`: Engine configuration loaded from `conf.toml` (preferred) or `conf.lua` (legacy).
- `error.rs`: Structured error types and result alias for the Lurek2D engine.
- `log_messages.rs`: Structured logging with stable message IDs for the Lurek2D engine.
- `messages.rs`: TOML-backed message catalog for stable, human-readable engine log messages.
- `mod.rs`: Core engine runtime: configuration, error handling, shared state, and resource management.
- `resource_keys.rs`: Typed resource keys for generational ID-based resource pools.
- `shared_state.rs`: Central shared runtime state for the Lurek2D engine.

## Types

- `Config` (`struct`, `config.rs`): Top-level engine configuration.
- `GraphicsConfig` (`struct`, `config.rs`): GPU backend and power-preference settings resolved once at engine startup.
- `WindowConfig` (`struct`, `config.rs`): Window dimensions, title, vsync, fullscreen, and resize settings.
- `ModulesConfig` (`struct`, `config.rs`): Flags to enable or disable optional engine subsystems.
- `PerformanceConfig` (`struct`, `config.rs`): Frame rate cap and other performance tuning options.
- `ErrorCategory` (`enum`, `error.rs`): Error category for grouping related engine errors.
- `EngineError` (`enum`, `error.rs`): All possible error conditions that can occur in the Lurek2D engine.
- `EngineResult` (`type`, `error.rs`): Convenience alias for `Result<T, EngineError>` used throughout the engine.
- `MessageCatalog` (`struct`, `messages.rs`): Immutable map from stable message ID (e.g.
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
- `SharedState` (`struct`, `shared_state.rs`): Shared mutable state passed via `Rc<RefCell<SharedState>>` to all Lua API closures and the engine loop.
- `RendererStats` (`struct`, `shared_state.rs`): Snapshot of renderer statistics for a single frame.

## Functions

- `ModulesConfig::validate_and_fix` (`config.rs`): Enforces dependency constraints so that a partially-disabled config is never internally inconsistent.
- `Config::load` (`config.rs`): Loads engine configuration from the game directory.
- `Config::load_from_conf_toml` (`config.rs`): Loads engine configuration from `conf.toml` in the game directory.
- `Config::load_from_conf_lua` (`config.rs`): Loads engine configuration from `conf.lua` in the game directory.
- `ErrorCategory::as_str` (`error.rs`): Returns the category name as a lowercase string.
- `EngineError::code` (`error.rs`): Returns the stable error code for this variant.
- `EngineError::category` (`error.rs`): Returns the error category for this variant.
- `EngineError::recovery_hint` (`error.rs`): Returns a human-readable recovery hint for this error variant.
- `set_log_level` (`log_messages.rs`): Sets the global log level at runtime (called from `lurek.platform.setLogLevel`).
- `get_log_level` (`log_messages.rs`): Returns the current log level name.
- `MessageCatalog::from_toml` (`messages.rs`): Parse the embedded TOML source and build a flat ID → text map.
- `MessageCatalog::get` (`messages.rs`): Look up the human-readable text for a message ID.
- `MessageCatalog::len` (`messages.rs`): Number of registered message entries.
- `MessageCatalog::is_empty` (`messages.rs`): Returns `true` if the catalog contains no entries.
- `init` (`messages.rs`): Initialise the global message catalog from the embedded TOML.
- `get_message` (`messages.rs`): Resolve a stable message ID to its human-readable text.
- `catalog` (`messages.rs`): Returns a reference to the global [`MessageCatalog`], or `None` if [`init`] has not been called yet.
- `SharedState::new` (`shared_state.rs`): Creates a new `SharedState` with the given window dimensions, title, and game directory.
- `SharedState::step_timer` (`shared_state.rs`): Advances the clock by one tick and syncs `delta_time`, `total_time`, and `fps`.
- `SharedState::request_async_load` (`shared_state.rs`): Submits a background file-read request, lazily creating the async loader.
- `SharedState::load_default_fonts` (`shared_state.rs`): Loads all 6 embedded bitmap fonts into `fonts` and stores their keys in `default_fonts`.
- `SharedState::poll_async_load` (`shared_state.rs`): Polls a pending async load and returns the status and optional data.
- `SharedState::compute_stats` (`shared_state.rs`): Computes a snapshot of the current renderer statistics.

## Lua API Reference

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- `audio`: Imports or references `audio` from `src/audio/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `parallax`: Imports or references `parallax` from `src/parallax/`.
- `particle`: Imports or references `particle` from `src/particle/`.
- `raycaster`: Imports or references `raycaster` from `src/raycaster/`.
- `render`: Imports or references `render` from `src/render/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `tilemap` from `src/tilemap/`.
- `timer`: Imports or references `timer` from `src/timer/`.
- `ui`: Imports or references `ui` from `src/ui/`.

## Notes

- Keep this module reference synchronized with `src/runtime/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
