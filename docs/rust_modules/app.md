# app

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: None direct
- Namespace: `lurek.input`
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): tests/engine_tests.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

The app module serves as the desktop execution heartbeat for Lurek2D. It unifies winit windowing, wgpu graphics, user inputs, and the LuaJIT virtual machine into a deterministic main loop. From process launch to final shutdown, it governs bootstrapping, manages graphic surface reconfigurations, and controls viewport scaling so visuals remain stable.

For scripting, the module coordinates the delivery of platform updates into Lua event handlers. It serves as the safety boundary, executing key lifecycle callbacks—such as fixed physics ticks, variable updates, rendering passes, and input event handlers—inside guarded boundaries. This protects against script anomalies, timeout lockups, and supports hot-reloading during live development.

To guide early startup and handle system faults, the module implements specialized visual screens. It renders a pre-game splash screen with branding elements and drag-and-drop feedback. If an unrecoverable failure occurs, it transitions to a formatted, clipboard-ready fatal crash screen that isolates traceback details and shows immediate troubleshooting guidance.

For diagnostics, the module incorporates lightweight performance tracking utilities. It aggregates frame timing profiles—update, rendering, and callback durations—into compact text traces for logs. It also supplies a togglable debug HUD showing real-time frame rates and draw workloads, offering low-cost visibility into live engine budgets.

## Files

### [app.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/app.rs)

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

### [debug_overlay.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/debug_overlay.rs)

- Implements a lightweight runtime HUD that visualizes key frame diagnostics during gameplay.
- Renders compact counters for frame rate and draw workload as overlay command output.
- Gates all overlay emission behind explicit enable state to avoid accidental rendering noise.
- Serves as a low-cost observability surface for quick in-session performance inspection.

### [error_screen.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/error_screen.rs)

- Formats fatal runtime failures into a user-facing visual report that remains readable under stress.
- Splits primary error content from traceback context and normalizes noisy text artifacts.
- Wraps long lines into screen-friendly layout blocks for predictable in-window readability.
- Builds full-screen render command payloads for title, detail body, traceback, and guidance text.
- Provides clipboard-ready export text so failure details can be captured quickly.
- Serves as the terminal failure presentation path when normal gameplay rendering cannot continue.

### [frame_profile.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/frame_profile.rs)

- Formats frame timing samples into compact textual summaries for trace and diagnostics output.
- Reads tick, update, render, and callback metrics from the runtime profile snapshot.
- Emits one stable line shape that supports quick frame-budget scanning in logs.

### [lua_callbacks.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/lua_callbacks.rs)

- Implements guarded invocation of named `lurek.*` callbacks from engine-side runtime flow.
- Provides checked and logging variants so callers choose explicit error propagation behavior.
- Supports optional timeout enforcement via instruction hooks to stop runaway callback execution.
- Serves as the callback safety boundary between frame orchestration and Lua script handlers.
- @engine-callback | init | function lurek.init() | Called once when the engine initialises.
- @engine-callback | ready | function lurek.ready() | Called once after init, when runtime state is ready.
- @engine-callback | process_physics | function lurek.process_physics(dt) | Called on the fixed physics step.
- @engine-param | process_physics | dt | number | false | Fixed-step delta time in seconds.
- @engine-callback | fixedUpdate | function lurek.fixedUpdate(dt) | Deprecated alias for `process_physics`.
- @engine-param | fixedUpdate | dt | number | false | Fixed-step delta time in seconds.
- @engine-callback | process | function lurek.process(dt) | Called every frame for variable-step gameplay logic.
- @engine-param | process | dt | number | false | Delta time in seconds.
- @engine-callback | process_late | function lurek.process_late(dt) | Called every frame after `process`.
- @engine-param | process_late | dt | number | false | Delta time in seconds.
- @engine-callback | draw | function lurek.draw() | Called every frame for world rendering.
- @engine-callback | draw_ui | function lurek.draw_ui() | Called every frame after `draw` for UI rendering.
- @engine-callback | keypressed | function lurek.keypressed(key, scancode, isrepeat) | Called when a keyboard key is pressed.
- @engine-param | keypressed | key | string | false | Key name.
- @engine-param | keypressed | scancode | string | false | Platform scancode.
- @engine-param | keypressed | isrepeat | boolean | false | True when key repeat generated the event.
- @engine-callback | keyreleased | function lurek.keyreleased(key, scancode) | Called when a keyboard key is released.
- @engine-param | keyreleased | key | string | false | Key name.
- @engine-param | keyreleased | scancode | string | false | Platform scancode.
- @engine-callback | textinput | function lurek.textinput(text) | Called when text input is received.
- @engine-param | textinput | text | string | false | Input text fragment.
- @engine-callback | textedited | function lurek.textedited(text, start, length) | Called when IME composition text changes.
- @engine-param | textedited | text | string | false | Composition text.
- @engine-param | textedited | start | number | false | Cursor start offset.
- @engine-param | textedited | length | number | false | Selection length.
- @engine-callback | mousepressed | function lurek.mousepressed(x, y, button) | Called when a mouse button is pressed.
- @engine-param | mousepressed | x | number | false | Mouse x coordinate.
- @engine-param | mousepressed | y | number | false | Mouse y coordinate.
- @engine-param | mousepressed | button | number | false | Button index.
- @engine-callback | mousereleased | function lurek.mousereleased(x, y, button) | Called when a mouse button is released.
- @engine-param | mousereleased | x | number | false | Mouse x coordinate.
- @engine-param | mousereleased | y | number | false | Mouse y coordinate.
- @engine-param | mousereleased | button | number | false | Button index.
- @engine-callback | mousemoved | function lurek.mousemoved(x, y, dx, dy) | Called when the mouse cursor moves.
- @engine-param | mousemoved | x | number | false | Mouse x coordinate.
- @engine-param | mousemoved | y | number | false | Mouse y coordinate.
- @engine-param | mousemoved | dx | number | false | Horizontal delta.
- @engine-param | mousemoved | dy | number | false | Vertical delta.
- @engine-callback | wheelmoved | function lurek.wheelmoved(x, y) | Called when the mouse wheel moves.
- @engine-param | wheelmoved | x | number | false | Horizontal wheel delta.
- @engine-param | wheelmoved | y | number | false | Vertical wheel delta.
- @engine-callback | gamepadpressed | function lurek.gamepadpressed(id, button) | Called when a gamepad button is pressed.
- @engine-param | gamepadpressed | id | number | false | Gamepad id.
- @engine-param | gamepadpressed | button | string | false | Button name.
- @engine-callback | gamepadreleased | function lurek.gamepadreleased(id, button) | Called when a gamepad button is released.
- @engine-param | gamepadreleased | id | number | false | Gamepad id.
- @engine-param | gamepadreleased | button | string | false | Button name.
- @engine-callback | gamepadaxis | function lurek.gamepadaxis(id, axis, value) | Called when a gamepad axis value changes.
- @engine-param | gamepadaxis | id | number | false | Gamepad id.
- @engine-param | gamepadaxis | axis | string | false | Axis name.
- @engine-param | gamepadaxis | value | number | false | Axis value in range -1..1.
- @engine-callback | joystickadded | function lurek.joystickadded(id) | Called when a gamepad is connected.
- @engine-param | joystickadded | id | number | false | Gamepad id.
- @engine-callback | joystickremoved | function lurek.joystickremoved(id) | Called when a gamepad is disconnected.
- @engine-param | joystickremoved | id | number | false | Gamepad id.
- @engine-callback | touchpressed | function lurek.touchpressed(id, x, y, dx, dy, pressure) | Called when a touch begins.
- @engine-param | touchpressed | id | number | false | Touch id.
- @engine-param | touchpressed | x | number | false | Touch x coordinate.
- @engine-param | touchpressed | y | number | false | Touch y coordinate.
- @engine-param | touchpressed | dx | number | false | Horizontal delta.
- @engine-param | touchpressed | dy | number | false | Vertical delta.
- @engine-param | touchpressed | pressure | number | false | Touch pressure.
- @engine-callback | touchmoved | function lurek.touchmoved(id, x, y, dx, dy, pressure) | Called when a touch point moves.
- @engine-param | touchmoved | id | number | false | Touch id.
- @engine-param | touchmoved | x | number | false | Touch x coordinate.
- @engine-param | touchmoved | y | number | false | Touch y coordinate.
- @engine-param | touchmoved | dx | number | false | Horizontal delta.
- @engine-param | touchmoved | dy | number | false | Vertical delta.
- @engine-param | touchmoved | pressure | number | false | Touch pressure.
- @engine-callback | touchreleased | function lurek.touchreleased(id, x, y, dx, dy, pressure) | Called when a touch ends.
- @engine-param | touchreleased | id | number | false | Touch id.
- @engine-param | touchreleased | x | number | false | Touch x coordinate.
- @engine-param | touchreleased | y | number | false | Touch y coordinate.
- @engine-param | touchreleased | dx | number | false | Horizontal delta.
- @engine-param | touchreleased | dy | number | false | Vertical delta.
- @engine-param | touchreleased | pressure | number | false | Touch pressure.
- @engine-callback | focus | function lurek.focus(has_focus) | Called when window focus changes.
- @engine-param | focus | has_focus | boolean | false | True when focused.
- @engine-callback | visible | function lurek.visible(is_visible) | Called when window visibility changes.
- @engine-param | visible | is_visible | boolean | false | True when visible.
- @engine-callback | resize | function lurek.resize(w, h) | Called when window size changes.
- @engine-param | resize | w | number | false | New window width.
- @engine-param | resize | h | number | false | New window height.
- @engine-callback | quit | function lurek.quit() | Called before shutdown; return true to cancel quit.
- @engine-callback | exit | function lurek.exit() | Called when the engine is shutting down.
- @engine-callback | errorhandler | function lurek.errorhandler(msg) | Called for unhandled Lua errors.
- @engine-param | errorhandler | msg | string | false | Error message text.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/mod.rs)

- Defines the application module boundary for lifecycle orchestration from startup to shutdown.
- Groups runtime loop control, visual fallback paths, callback guards, and profiling helpers.
- Serves as the high-level composition root for app-level execution responsibilities.

### [splash_screen.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/app/splash_screen.rs)

- Implements splash branding presentation before gameplay content is loaded into active runtime state.
- Decodes embedded visual assets into temporary texture storage used by startup rendering.
- Builds centered splash layout command sequences with icon, banner, and hint messaging elements.
- Adapts hint styling based on drag-and-drop hover state for clearer startup interaction feedback.
- Serves as the pre-game visual bridge between process launch and first playable scene.
