# app

## TL;DR

- The `app` module serves as the primary application lifecycle controller and integration point for Lurek2D, positioned at the top of the Edge/Integration tier.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.input`
- Rust test path(s): tests/engine_tests.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

The `app` module is the composition root and execution orchestrator for the runtime binary. It owns startup order, `winit` event-loop integration, frame lifecycle sequencing, and the bridge points where platform events are translated into Lua callbacks and render submission steps. Instead of holding domain logic for gameplay systems, it coordinates those systems through explicit frame phases and shared runtime services.

At runtime, the module drives a deterministic loop around timing (`Clock`), input/device polling, script callbacks, simulation ticks, and renderer presentation. It also centralizes operational surfaces that must remain globally consistent: fatal error screen fallback, debug overlay rendering, splash screen flow, and frame-profile instrumentation text. This gives one authoritative place for "what happens each frame" and avoids lifecycle drift across feature modules.

The boundary is intentionally integration-focused. Submodules like `lua_callbacks`, `frame_profile`, and `debug_overlay` serve orchestration concerns and are consumed by the main app runner, while heavy business logic stays in specialized modules (`render`, `input`, `audio`, `physics`, etc.). The app layer therefore acts as an execution scheduler and policy host, not as a domain owner.

From a maintenance perspective, this module is where reliability controls belong: callback timeout wrappers, safe recovery paths for user-facing failures, and event-to-callback routing guarantees. In practice, changes here should preserve strict ordering guarantees and keep side effects observable, because almost every runtime subsystem is activated through this module's frame pipeline.

Implementation detail and boundary guarantees for app: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: app.rs: Implements the central LurekApp runtime driven by winit's ApplicationHandler.; debug_overlay.rs: Owns the lightweight debug HUD toggled by F12 or Lua.; error_screen.rs: Formats fatal Lua and engine errors into a user-facing screen.; frame_profile.rs: Formats per-frame timing data into compact single-line strings for logging.; lua_callbacks.rs: Invokes named lurek.* Lua callbacks with error logging and optional timeout.; mod.rs: Orchestrates the Lurek2D application lifecycle from window creation through frame rendering.; splash_screen.rs: Decodes embedded splash icon and banner PNGs into temporary texture storage.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### app.rs

- Implements the primary desktop runtime loop that binds windowing, rendering, input, and Lua execution.
- Owns application bootstrap from startup configuration through event-loop handoff and steady frame progression.
- Manages graphics surface lifecycle, device provisioning, and resize-aware presentation reconfiguration.
- Coordinates tick ordering so input, update callbacks, render callbacks, and presentation stay deterministic.
- Routes platform events into runtime systems with consistent keyboard, mouse, touch, and controller handling.
- Integrates gamepad polling and feedback signaling as part of per-frame platform service orchestration.
- Maintains viewport scaling and letterbox behavior so visual output remains stable across window sizes.
- Handles splash and fallback presentation paths before gameplay state is fully available.
- Provides fatal-error rendering transition when execution cannot continue in normal game flow.
- Controls screenshot timing and capture output as part of frame lifecycle responsibilities.
- Drives Lua VM startup, script loading, and callback invocation as the script execution spine.
- Applies guarded callback execution paths to keep runtime responsive under script-side anomalies.
- Coordinates hot-reload triggers for content and script changes in active development sessions.
- Preserves state continuity across reload boundaries where restart semantics allow safe recovery.
- Maintains integration seams between render backend, runtime state, and high-level app orchestration.
- Centralizes frame-profile collection points for observability and performance diagnostics.
- Exposes utility operations used by auxiliary app submodules without duplicating orchestration logic.
- Ensures one coherent ownership model for transient frame state and long-lived application resources.
- Keeps platform interactions isolated so gameplay modules consume normalized runtime behavior.
- Serves as the operational heartbeat that advances the engine from launch to shutdown.
- Anchors the complete desktop execution lifecycle under one deterministic application control surface.

### debug_overlay.rs

- Implements a lightweight runtime HUD that visualizes key frame diagnostics during gameplay.
- Renders compact counters for frame rate and draw workload as overlay command output.
- Gates all overlay emission behind explicit enable state to avoid accidental rendering noise.
- Serves as a low-cost observability surface for quick in-session performance inspection.

### error_screen.rs

- Formats fatal runtime failures into a user-facing visual report that remains readable under stress.
- Splits primary error content from traceback context and normalizes noisy text artifacts.
- Wraps long lines into screen-friendly layout blocks for predictable in-window readability.
- Builds full-screen render command payloads for title, detail body, traceback, and guidance text.
- Provides clipboard-ready export text so failure details can be captured quickly.
- Serves as the terminal failure presentation path when normal gameplay rendering cannot continue.

### frame_profile.rs

- Formats frame timing samples into compact textual summaries for trace and diagnostics output.
- Reads tick, update, render, and callback metrics from the runtime profile snapshot.
- Emits one stable line shape that supports quick frame-budget scanning in logs.

### lua_callbacks.rs

- Implements guarded invocation of named `lurek.*` callbacks from engine-side runtime flow.
- Provides checked and logging variants so callers choose explicit error propagation behavior.
- Supports optional timeout enforcement via instruction hooks to stop runaway callback execution.
- Serves as the callback safety boundary between frame orchestration and Lua script handlers.

### mod.rs

- Defines the application module boundary for lifecycle orchestration from startup to shutdown.
- Groups runtime loop control, visual fallback paths, callback guards, and profiling helpers.
- Serves as the high-level composition root for app-level execution responsibilities.

### splash_screen.rs

- Implements splash branding presentation before gameplay content is loaded into active runtime state.
- Decodes embedded visual assets into temporary texture storage used by startup rendering.
- Builds centered splash layout command sequences with icon, banner, and hint messaging elements.
- Adapts hint styling based on drag-and-drop hover state for clearer startup interaction feedback.
- Serves as the pre-game visual bridge between process launch and first playable scene.

## Lua API Ref

- Binding: None direct
- Namespace: `lurek.input`

### Functions

- No documented module-level functions.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `image`: Imports or references `image` from `src/image/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: Imports or references `lua_api` from `src/lua_api/`.
- `math`: Imports or references `math` from `src/math/`.
- `parallax`: Imports or references `src/parallax/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `window`: Imports or references `src/window/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
