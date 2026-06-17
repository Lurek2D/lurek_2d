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

- Implements the primary desktop runtime loop that binds windowing, rendering, input, and Lua execution. `app/app` delivers the app implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Owns application bootstrap from startup configuration through event-loop handoff and steady frame progression. The file owns or coordinates data contracts including `RunState`, `DropStartupTarget`, `LurekApp`, `App`, `AppRunOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Manages graphics surface lifecycle, device provisioning, and resize-aware presentation reconfiguration. Public callable behavior is centered on `recompute_viewport`, `splash_window_title`, `fit_contain_size`, `classify_drop_startup_target`, `should_open_startup_picker_on_key`, while method-level behavior such as `new`, `resolve_present_mode`, `init_lua`, `run` stays attached to the local data model and invariants.
- Coordinates tick ordering so input, update callbacks, render callbacks, and presentation stay deterministic. Runtime integration reaches sibling engine areas through crate modules `event`, `filesystem`, `input`, `log_msg`, `lua_api`, `render`, and 2 more, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Routes platform events into runtime systems with consistent keyboard, mouse, touch, and controller handling. External integration uses `super`, `gilrs`, `mlua`, `slotmap`, `std`, and 1 more, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Integrates gamepad polling and feedback signaling as part of per-frame platform service orchestration. The file boundary separates app implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Maintains viewport scaling and letterbox behavior so visual output remains stable across window sizes. State changes, validation paths, and helper routines in `src/app/app.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Handles splash and fallback presentation paths before gameplay state is fully available. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.
- Provides fatal-error rendering transition when execution cannot continue in normal game flow. The implementation keeps feature-specific decisions near their data and helper functions, reducing cross-module coupling while preserving a clear engine-facing boundary.
- Controls screenshot timing and capture output as part of frame lifecycle responsibilities. Documentation here is intended to feed source-derived specs, so every file-level line states concrete responsibilities instead of generic presence or placeholder text.

### debug_overlay.rs

- Implements a lightweight runtime HUD that visualizes key frame diagnostics during gameplay. `app/debug_overlay` delivers the debug overlay implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Renders compact counters for frame rate and draw workload as overlay command output. The file owns or coordinates data contracts including `DebugOverlay`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Gates all overlay emission behind explicit enable state to avoid accidental rendering noise. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `build_render_commands` stays attached to the local data model and invariants.

### error_screen.rs

- Formats fatal runtime failures into a user-facing visual report that remains readable under stress. `app/error_screen` delivers the error screen implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Splits primary error content from traceback context and normalizes noisy text artifacts. The file owns or coordinates data contracts including `ErrorScreen`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Wraps long lines into screen-friendly layout blocks for predictable in-window readability. Public callable behavior is centered on `wrap_text`, `format_traceback`, while method-level behavior such as `from_error`, `from_lua_error`, `from_engine_error`, `build_render_commands`, `as_text` stays attached to the local data model and invariants.
- Builds full-screen render command payloads for title, detail body, traceback, and guidance text. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Provides clipboard-ready export text so failure details can be captured quickly. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### frame_profile.rs

- Formats frame timing samples into compact textual summaries for trace and diagnostics output. `app/frame_profile` delivers the frame profile implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### lua_callbacks.rs

- Implements guarded invocation of named `lurek.*` callbacks from engine-side runtime flow. `app/lua_callbacks` delivers the lua callbacks implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides checked and logging variants so callers choose explicit error propagation behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports optional timeout enforcement via instruction hooks to stop runaway callback execution. Public callable behavior is centered on `call_lua_callback`, `call_lua_callback_checked`, `has_lua_callback`, `call_lua_callback_with_timeout`, `call_lua_callback_checked_with_timeout`, and 1 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Serves as the callback safety boundary between frame orchestration and Lua script handlers. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Defines the application module boundary for lifecycle orchestration from startup to shutdown. `app/mod` is the app module index, declaring `app`, `debug_overlay`, `error_screen`, `frame_profile`, `lua_callbacks`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
- Groups runtime loop control, visual fallback paths, callback guards, and profiling helpers. `src/app/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `app::{App, AppRunOptions}`, `debug_overlay::DebugOverlay`, `error_screen::ErrorScreen` centralized for the app subsystem.

### splash_screen.rs

- Implements splash branding presentation before gameplay content is loaded into active runtime state. `app/splash_screen` delivers the splash screen implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Decodes embedded visual assets into temporary texture storage used by startup rendering. The file owns or coordinates data contracts including `SplashTexture`, `SplashBranding`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Builds centered splash layout command sequences with icon, banner, and hint messaging elements. Public callable behavior is centered on `load_splash_branding`, `make_splash_commands`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Adapts hint styling based on drag-and-drop hover state for clearer startup interaction feedback. Runtime integration reaches sibling engine areas through crate modules `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

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
