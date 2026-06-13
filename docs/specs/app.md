# app

## TL;DR

- Drives the main winit/wgpu frame loop and Lua VM execution.
- Dispatches platform events to safe, guarded engine callbacks.
- Renders startup splash layouts, fatal error screens, and debug HUDs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: None direct
- Namespace: `lurek.input`
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/app_tests.rs; tests/games_load_test.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

- The `app` module is the desktop runtime shell that drives launch-to-shutdown execution.
- It composes windowing, rendering, input routing, and Lua callbacks into one deterministic frame loop.
- This is the operational boundary that turns engine subsystems into a running application.
- It owns startup bootstrap, graphics surface bring-up, and steady frame progression.
- It handles resize, focus, visibility, and other host-level transitions during runtime.
- Callback dispatch goes through guarded execution paths instead of raw host invocations.
- Guarding contains script failures, timeout risks, and hot-reload edge cases.
- The module routes lifecycle, update, draw, input, and controller callbacks consistently.
- It also owns user-visible startup and failure presentation paths.
- Splash rendering is available before gameplay content is fully ready.
- Fatal errors switch to a readable error screen instead of silent termination.
- Development observability includes frame profile summaries and debug overlay metrics.
- Runtime health becomes inspectable through FPS and draw workload surfaces.
- Splash and error presentation are intentionally separated so startup, failure, and recovery states remain readable and testable.
- The module owns process lifecycle, frame orchestration, callback safety, and top-level diagnostics.
- Domain modules provide behavior, but `app` keeps the host responsive, ordered, and recoverable.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Imports

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

## Callbacks

- `lurek.draw() -> nil`: Called every frame for world rendering.
- `lurek.draw_ui() -> nil`: Called every frame after `draw` for UI rendering.
- `lurek.errorhandler(msg) -> nil`: Called for unhandled Lua errors.
- `lurek.exit() -> nil`: Called when the engine is shutting down.
- `lurek.fixedUpdate(dt) -> nil`: Deprecated alias for `process_physics`.
- `lurek.focus(has_focus) -> nil`: Called when window focus changes.
- `lurek.gamepadaxis(id, axis, value) -> nil`: Called when a gamepad axis value changes.
- `lurek.gamepadpressed(id, button) -> nil`: Called when a gamepad button is pressed.
- `lurek.gamepadreleased(id, button) -> nil`: Called when a gamepad button is released.
- `lurek.init() -> nil`: Called once when the engine initialises.
- `lurek.joystickadded(id) -> nil`: Called when a gamepad is connected.
- `lurek.joystickremoved(id) -> nil`: Called when a gamepad is disconnected.
- `lurek.keypressed(key, scancode, isrepeat) -> nil`: Called when a keyboard key is pressed.
- `lurek.keyreleased(key, scancode) -> nil`: Called when a keyboard key is released.
- `lurek.mousemoved(x, y, dx, dy) -> nil`: Called when the mouse cursor moves.
- `lurek.mousepressed(x, y, button) -> nil`: Called when a mouse button is pressed.
- `lurek.mousereleased(x, y, button) -> nil`: Called when a mouse button is released.
- `lurek.process(dt) -> nil`: Called every frame for variable-step gameplay logic.
- `lurek.process_late(dt) -> nil`: Called every frame after `process`.
- `lurek.process_physics(dt) -> nil`: Called on the fixed physics step.
- `lurek.quit() -> boolean?`: Called before shutdown; return true to cancel quit.
- `lurek.ready() -> nil`: Called once after init, when runtime state is ready.
- `lurek.resize(w, h) -> nil`: Called when window size changes.
- `lurek.textedited(text, start, length) -> nil`: Called when IME composition text changes.
- `lurek.textinput(text) -> nil`: Called when text input is received.
- `lurek.touchmoved(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point moves.
- `lurek.touchpressed(id, x, y, dx, dy, pressure) -> nil`: Called when a touch begins.
- `lurek.touchreleased(id, x, y, dx, dy, pressure) -> nil`: Called when a touch ends.
- `lurek.visible(is_visible) -> nil`: Called when window visibility changes.
- `lurek.wheelmoved(x, y) -> nil`: Called when the mouse wheel moves.



## Lua API Ref

### Functions

- No documented module-level functions.

### Callbacks

- No documented callback parameters in this module.

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

## Notes

- No additional module-specific notes.
