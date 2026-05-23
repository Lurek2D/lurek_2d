# app

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.input`
- Rust test path(s): tests/engine_tests.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

The `app` module serves as the primary application lifecycle controller and integration point for Lurek2D, positioned at the top of the Edge/Integration tier. Its core responsibility is to orchestrate the engine's initialization, manage the central game loop, and mediate communication between hardware events, graphics presentation, and Lua script execution. The central component is `LurekApp`, which initializes all engine subsystems in strict dependency order, establishes the `wgpu` rendering surface, and assumes control of the `winit` event loop.

During active execution, `LurekApp` drives the engine's frame lifecycle. Each frame, it advances the core `Clock` timing, polls hardware inputs (including keyboard, mouse, touch, and `gilrs`-driven gamepads), steps the physics simulation, and dispatches events to the active Lua environment via structured callbacks such as `load`, `update`, `draw`, and `keypressed`. The module implements safety boundaries around script execution using `lua_callbacks` wrappers, ensuring that unhandled Lua panics are caught and long-running scripts can be aborted via instruction-count timeouts before they freeze the application.

Beyond the main loop, the `app` module owns several critical user-facing and developer-experience systems. When a fatal Lua error or unrecoverable engine fault occurs, the `ErrorScreen` subsystem intercepts the crash and replaces the game view with a structured diagnostic overlay. This screen cleanly formats error messages and stack traces, provides syntax-highlighted context, and supports one-click clipboard exports to aid rapid debugging. Fatal-screen text now prefers the active/configured runtime font set, and only falls back to internal embedded fonts when runtime fonts are unavailable. During startup, the `splash_screen` component decodes embedded branding assets and presents them while the engine waits for initial assets to load or prompts for a drag-and-drop game folder. For performance monitoring, the `DebugOverlay` subsystem renders a lightweight, configurable heads-up display showing current framerate, memory usage, and draw-call counts, while the `frame_profile` system logs detailed per-phase execution timings to the console.

Additionally, `app` seamlessly manages development workflows with built-in hot-reload capabilities. By integrating filesystem watchers, it detects changes to `conf.toml`, Lua scripts, and asset files, automatically restarting the execution context to instantly reflect modifications without requiring a manual reboot. By design, the `app` module owns no intrinsic game domain logic; instead, it composes the output of the Foundations, Platform Services, and Feature Systems modules to deliver the final interactive runtime shell.

## Source Documentation

### `app.rs`
- Implements the central `LurekApp` runtime driven by winit's `ApplicationHandler`.
- Manages GPU surface creation, wgpu adapter/device selection, and surface reconfiguration.
- Orchestrates the frame loop: tick input, call Lua process/draw callbacks, then present.
- Handles window events (keyboard, mouse, touch, gamepad, drag-drop, resize, focus).
- Provides splash-screen and error-screen rendering paths when no game is loaded or a fatal occurs.
- Renders fatal-screen text with runtime active/default fonts when available, with embedded-font fallback.
- Owns hot-reload watchers for conf.toml, Lua scripts, and asset files with automatic restart.
- Integrates gilrs for gamepad polling, force-feedback vibration, and axis/button callbacks.
- Performs viewport letterbox/stretch/pixel scaling and automatic screenshot capture.
- Boots the Lua VM, loads main.lua, fires `lurek.init()`, and enters the main game loop.
- Provides `App` bootstrap wrapper that initializes logging and launches the event loop.

### `debug_overlay.rs`
- Owns the lightweight debug HUD toggled by F12 or Lua.
- Renders FPS counter and draw-call counter in a semi-transparent box.
- Produces render commands only when the overlay is enabled and a font key is available.

### `error_screen.rs`
- Formats fatal Lua and engine errors into a user-facing screen.
- Splits message text and traceback, word-wraps long lines, and cleans Lua string markers.
- Builds full-screen render commands showing error title, body, traceback, and hint footer.
- Provides clipboard export text for quick copy of error details.

### `frame_profile.rs`
- Formats per-frame timing data into compact single-line strings for logging.
- Reads tick, update, render, and callback timings from `FrameProfile`.

### `lua_callbacks.rs`
- Invokes named `lurek.*` Lua callbacks with error logging and optional timeout.
- Installs an instruction-count hook to abort runaway callbacks after a deadline.
- Provides checked and unchecked variants for both timed and untimed invocation.

### `mod.rs`
- Orchestrates the Lurek2D application lifecycle from window creation through frame rendering.
- Bridges winit events to Lua callbacks, GPU rendering, input polling, and hot-reload.
- Houses the error screen, debug overlay, splash screen, and frame profiling submodules.
- Provides Lua callback timeout wrappers used across the frame update path.

### `splash_screen.rs`
- Decodes embedded splash icon and banner PNGs into temporary texture storage.
- Builds render commands for the splash screen layout with centred branding.
- Shows a drag-and-drop hint that changes colour when a folder is hovered.
- Provides the `SplashBranding` struct used by the app loop until a game loads.

## Types

- `RunState` (`enum`, `app.rs`): Tracks whether the engine is running normally, showing an error, or shutting down.
- `LurekApp` (`struct`, `app.rs`): Lurek2D application state managed by the winit event loop.
- `App` (`struct`, `app.rs`): Public entry point used to launch the engine with loaded configuration and optional startup error context. It is the outward-facing runtime shell around the real application lifecycle.
- `DebugOverlay` (`struct`, `debug_overlay.rs`): Small runtime overlay for FPS and draw-call visibility. It is useful when changes affect per-frame diagnostics rather than the full devtools subsystem.
- `ErrorScreen` (`struct`, `error_screen.rs`): Structured error presentation model that converts failures into readable render commands. It is the module's user-facing failure surface.
- `SplashTexture` (`struct`, `splash_screen.rs`): Handle and dimensions for one splash texture uploaded to render texture storage.
- `SplashBranding` (`struct`, `splash_screen.rs`): Embedded splash-branding assets prepared for splash-screen rendering.

## Functions

- `recompute_viewport` (`app.rs`): Recomputes viewport scale and offset based on game and window dimensions.
- `splash_window_title` (`app.rs`): Returns the splash-mode window title with the engine version appended.
- `fit_contain_size` (`app.rs`): Computes the largest size that fits `src` inside `max` while preserving aspect ratio.
- `LurekApp::new` (`app.rs`): Build app runtime state and initialize filesystem watchers from startup config.
- `LurekApp::resolve_present_mode` (`app.rs`): Select supported present mode and normalized vsync flag from requested mode.
- `LurekApp::init_lua` (`app.rs`): Create the Lua VM, load main.lua, and fire `lurek.init()`.
- `App::new` (`app.rs`): Create bootstrap app wrapper with config and optional pre-start config error.
- `App::run` (`app.rs`): Start the winit event loop and run the runtime for the selected game directory.
- `DebugOverlay::new` (`debug_overlay.rs`): Create disabled debug overlay state.
- `DebugOverlay::build_render_commands` (`debug_overlay.rs`): Build render commands for FPS and draw-call counters in a top-right panel.
- `ErrorScreen::from_error` (`error_screen.rs`): Build error screen model from plain text where first line is title and remainder is body.
- `ErrorScreen::from_lua_error` (`error_screen.rs`): Build error screen model from `mlua::Error`, splitting message and traceback sections.
- `ErrorScreen::from_engine_error` (`error_screen.rs`): Build error screen model from `EngineError` display text.
- `ErrorScreen::build_render_commands` (`error_screen.rs`): Build draw commands that render full-screen error background, text body, traceback, and footer hints.
- `ErrorScreen::as_text` (`error_screen.rs`): Return formatted text representation used for clipboard export and logs.
- `wrap_text` (`error_screen.rs`): Wraps a text string at word boundaries to fit within `max_chars` columns.
- `format_traceback` (`error_screen.rs`): Cleans up a Lua traceback string for display.
- `format_frame_profile_line` (`frame_profile.rs`): Format one `FrameProfile` sample as a compact single-line timing string.
- `call_lua_callback` (`lua_callbacks.rs`): Call `lurek.<name>(...)` and log failures to `error!` without returning them.
- `call_lua_callback_checked` (`lua_callbacks.rs`): Call `lurek.<name>(...)` and return any Lua error to the caller.
- `call_lua_callback_with_timeout` (`lua_callbacks.rs`): Call `lurek.<name>(...)` with optional timeout and log failures.
- `call_lua_callback_checked_with_timeout` (`lua_callbacks.rs`): Call `lurek.<name>(...)` and optionally abort execution when callback exceeds `timeout_ms`.
- `load_splash_branding` (`splash_screen.rs`): Decode embedded icon/banner PNG assets and upload them into splash texture storage.
- `make_splash_commands` (`splash_screen.rs`): Build render commands for splash screen branding and drag-and-drop hint text.

## Lua API Reference

- Namespace: `lurek.input`

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

- Keep this module reference synchronized with `src/app/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
- `app` owns only window-backed runtime execution. `--headless` is intentionally handled in `runtime::headless` before any `App::run()` call.
- The frame loop consumes `SharedState::restart_requested` (set by `lurek.event.restart()`) and triggers `restart_game()`, which tears down and rebuilds the Lua VM for GUI, TUI, and CLI under the same `App::run()` path.
