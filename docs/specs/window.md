# window

## General Info

- Module group: `Platform Services`
- Source path: `src/window/`
- Lua API path(s): `src/lua_api/window_api.rs`
- Primary Lua namespace: `lurek.window`
- Rust test path(s): tests/rust/unit/window_tests.rs
- Lua test path(s): tests/lua/unit/test_window.lua, tests/lua/unit/test_window_scaling.lua

## Summary

## Summary

The `window` module provides Lurek2D's OS window management API and viewport coordinate system. It is a Platform Services tier module that allows Lua scripts to control window properties, display mode, and resolution scaling without blocking the winit event loop. All window state changes are expressed as deferred writes to `WindowState` fields, which `App::event_loop_iteration()` reads and applies at frame start on the main OS thread — the only thread on which winit window operations are safe.

**Deferred command model.** Lua calls to window-mutation functions (e.g. `setTitle`, `setSize`, `setFullscreen`) do not execute immediately. Instead, they write pending fields into a `WindowState` struct in `SharedState`. The `App` event loop reads these pending fields at the start of each frame and issues the corresponding winit `Window` calls before rendering. This ensures no window API is ever called from a Lua callback on a non-main thread. Read-only queries (`isFullscreen`, `isMinimized`, `hasFocus`, etc.) return cached values from the previous frame's observation of `WindowState`.

**Window management.** `set_title(s)` schedules a title bar text change. `set_size(w, h)` schedules a logical pixel resize. `set_position(x, y)` schedules a screen-coordinate move. `set_fullscreen(bool)` toggles between windowed and exclusive borderless fullscreen. `set_vsync(mode)` toggles vertical synchronisation. `set_icon(path)` loads a PNG from the game filesystem and schedules it as the platform window icon. `minimize()`, `maximize()`, `restore()` schedule the corresponding winit window state transitions. `close()` schedules engine shutdown after the current frame completes. `request_attention()` triggers a taskbar flash on Windows or dock bounce on macOS for background notifications. `show_message_box(title, message, kind)` opens a synchronous platform-native modal dialog — intended only for fatal error reporting before engine exit, not for in-game UI.

**DPI and pixel dimensions.** `get_dpi_scale()` returns the monitor's reported device pixel ratio. `to_dpi_pixels(logical)` converts a device-independent value to physical pixels; `from_dpi_pixels(physical)` converts the reverse. `get_pixel_dimensions()` returns (physical_w, physical_h) as the product of logical size and DPI scale factor. These are needed for correctly sizing surfaces on high-DPI monitors.

**Viewport and scale modes.** `viewport.rs` owns the logical game dimension and scale-mode pipeline. `ScaleMode` enum: `Expand` (game world grows with the window, more world visible), `FixedWidth` (horizontal world extent is fixed, vertical adapts), `PixelPerfect` (integer scaling only, black bars), `Stretch` (always fill the window, no aspect ratio correction). `set_scale_mode(mode)` schedules a mode switch for the next frame. The viewport recomputes `scale`, `offset_x`, `offset_y`, and `logical_w / logical_h` from the window's physical pixel dimensions and the chosen mode.

**Coordinate conversion.** `to_pixels(world_x, world_y)` converts a position in game-world coordinates to on-screen pixel coordinates using the current viewport scale and offset. `from_pixels(px, py)` converts the reverse direction — essential for translating raw mouse pixel positions from `lurek.input` into game-world coordinates for hit-testing or picking. `ScaleInfo` is a read-only snapshot struct returned by `get_scale_info()` carrying scale factor, letterbox offsets, and logical dimensions for manual coordinate work.

**Window info queries.** `WindowInfo` is a snapshot struct returned by `lurek.window.info()`: `width`, `height` (logical), `physicalWidth`, `physicalHeight`, `dpiScale`, `x`, `y` (screen position), `title`, `isFullscreen`, `isMinimized`, `isMaximized`, `hasFocus`, `hasMouseFocus`, `isVisible`, `vsync`. `ModeInfo` is the compact fullscreen+vsync state snapshot returned by `getMode()`.

**set_mode.** The combined `set_mode(opts)` call accepts a table with optional `width`, `height`, `fullscreen`, and `vsync` fields and batches all four changes into a single deferred write, avoiding successive frame delays when changing multiple window properties together.

**Lua surface.** `lurek.window.setTitle(s)`, `lurek.window.setSize(w, h)`, `lurek.window.setPosition(x, y)`, `lurek.window.setFullscreen(bool)`, `lurek.window.setVsync(mode)`, `lurek.window.setIcon(path)`, `lurek.window.minimize()`, `lurek.window.maximize()`, `lurek.window.restore()`, `lurek.window.close()`, `lurek.window.requestAttention()`, `lurek.window.showMessageBox(title, msg, kind)`, `lurek.window.setMode(opts)`. Queries: `lurek.window.info()` → WindowInfo table, `lurek.window.getMode()` → ModeInfo table, `lurek.window.getDpiScale()` → float, `lurek.window.getPixelDimensions()` → (w, h). Viewport: `lurek.window.toPixels(wx, wy)` → (px, py), `lurek.window.fromPixels(px, py)` → (wx, wy), `lurek.window.setScaleMode(mode_str)`, `lurek.window.getScaleMode()` → string, `lurek.window.getScaleInfo()` → table.

**Scope boundary.** Platform Services tier. Depends on `runtime` (WindowState), `math`. Lua bridge in `src/lua_api/window_api.rs`.

## Files

- `event_loop.rs`: Reserved placeholder for future event-loop specific code; current event-loop behavior lives outside this module.
- `management.rs`: Owns window commands and queries such as title, fullscreen, vsync, size, position, minimize, maximize, restore, visibility, DPI scale, and message boxes.
- `mod.rs`: Declares the window submodules and re-exports the public management and viewport helpers as the module's main surface.
- `viewport.rs`: Owns logical game dimensions, scale-mode changes, and coordinate conversion between game space and on-screen pixels.

## Types

- `ModeInfo` (`struct`, `management.rs`): A compact snapshot of fullscreen and vsync state returned by the window mode query helpers.
- `ScaleInfo` (`struct`, `viewport.rs`): A read-only snapshot of current viewport scale, offsets, and logical game dimensions used by coordinate-conversion callers.

## Functions

- `set_title` (`management.rs`): Schedules a window title change for the next frame.
- `set_fullscreen` (`management.rs`): Schedules a fullscreen mode change.
- `is_fullscreen` (`management.rs`): Returns whether the window is currently in fullscreen mode.
- `set_vsync` (`management.rs`): Schedules a VSync mode change.
- `get_vsync` (`management.rs`): Returns the current VSync mode integer.
- `get_dpi_scale` (`management.rs`): Returns the DPI scale factor of the display the window is on.
- `get_position` (`management.rs`): Returns the current window position in screen coordinates as `(x, y)`.
- `set_position` (`management.rs`): Schedules a window position change to `(x, y)` in screen coordinates.
- `minimize` (`management.rs`): Schedules a window minimize (iconify) operation.
- `maximize` (`management.rs`): Schedules a window maximize operation.
- `restore` (`management.rs`): Schedules a window restore from minimized or maximized state.
- `is_minimized` (`management.rs`): Returns whether the window is currently minimized.
- `is_maximized` (`management.rs`): Returns whether the window is currently maximized.
- `has_focus` (`management.rs`): Returns whether the window currently has keyboard focus.
- `request_attention` (`management.rs`): Schedules a user-attention request (taskbar flash on Windows / dock bounce on macOS).
- `close` (`management.rs`): Schedules window closure on the next frame, exiting the game loop.
- `set_icon` (`management.rs`): Schedules a window icon change from the given file path.
- `set_size` (`management.rs`): Schedules a window resize to `(w, h)` logical pixels.
- `get_fullscreen_type_str` (`management.rs`): Returns the fullscreen type as a lowercase string.
- `get_fullscreen` (`management.rs`): Returns the fullscreen state and type as a `(bool, &str)` pair.
- `is_visible` (`management.rs`): Returns whether the window is currently visible.
- `has_mouse_focus` (`management.rs`): Returns whether the mouse cursor is inside the window.
- `to_dpi_pixels` (`management.rs`): Converts a device-independent value to physical pixels using the DPI scale.
- `from_dpi_pixels` (`management.rs`): Converts a physical pixel value to device-independent coordinates.
- `get_pixel_dimensions` (`management.rs`): Returns the window dimensions in physical pixels (logical size × DPI scale).
- `set_mode` (`management.rs`): Schedules a combined window mode change (size + optional fullscreen + optional vsync).
- `get_mode` (`management.rs`): Returns the current window mode settings.
- `show_message_box` (`management.rs`): Shows a platform-native message box dialog.
- `get_width` (`viewport.rs`): Returns the logical game width in virtual pixels.
- `get_height` (`viewport.rs`): Returns the logical game height in virtual pixels.
- `get_scale_mode` (`viewport.rs`): Returns the current viewport scale mode string.
- `set_scale_mode` (`viewport.rs`): Schedules a viewport scale mode change.
- `to_pixels` (`viewport.rs`): Converts game-space coordinates `(x, y)` to window pixel coordinates.
- `from_pixels` (`viewport.rs`): Converts window pixel coordinates `(x, y)` back to game-space coordinates.
- `get_scale_info` (`viewport.rs`): Returns the current viewport scale and offset information.
- `set_scale_mode_validated` (`viewport.rs`): Validates and schedules a viewport scale mode change.

## Lua API Reference

- Binding path(s): `src/lua_api/window_api.rs`
- Namespace: `lurek.window`

### Module Functions
- `lurek.window.setTitle`: Sets the window title bar text.
- `lurek.window.getTitle`: Returns the current window title.
- `lurek.window.getWidth`: Returns the window width in pixels.
- `lurek.window.getHeight`: Returns the window height in pixels.
- `lurek.window.getDimensions`: Returns the window dimensions as width, height.
- `lurek.window.setFullscreen`: Enables or disables fullscreen mode.
- `lurek.window.getFullscreen`: Returns the fullscreen state and type string.
- `lurek.window.isOpen`: Returns whether the window is open.
- `lurek.window.setVSync`: Sets the VSync mode (1=on, 0=off, -1=adaptive).
- `lurek.window.getVSync`: Returns the current VSync mode integer.
- `lurek.window.hasFocus`: Returns whether the window has keyboard focus.
- `lurek.window.hasMouseFocus`: Returns whether the mouse cursor is inside the window.
- `lurek.window.isMinimized`: Returns whether the window is minimized.
- `lurek.window.isMaximized`: Returns whether the window is maximized.
- `lurek.window.isVisible`: Returns whether the window is visible.
- `lurek.window.minimize`: Minimizes the window to the taskbar.
- `lurek.window.maximize`: Maximizes the window to fill the desktop.
- `lurek.window.restore`: Restores the window from minimized or maximized state.
- `lurek.window.getPosition`: Returns the window position as x, y in screen coordinates.
- `lurek.window.setPosition`: Moves the window to the given screen position.
- `lurek.window.getDisplayCount`: Returns the number of connected displays.
- `lurek.window.getDesktopDimensions`: Returns the desktop resolution as width, height.
- `lurek.window.getDPIScale`: Returns the DPI scaling factor for the window.
- `lurek.window.toPixels`: Converts a device-independent coordinate to physical pixels.
- `lurek.window.fromPixels`: Converts physical pixels to device-independent coordinates.
- `lurek.window.setIcon`: Sets the window icon from a file path.
- `lurek.window.setMode`: Resizes the window and optionally changes fullscreen and vsync.
- `lurek.window.getMode`: Returns the window dimensions and mode flags as width, height, flags.
- `lurek.window.close`: Requests the window to close.
- `lurek.window.requestAttention`: Flashes the window in the taskbar to request user attention.
- `lurek.window.getFullscreenModes`: Returns all available fullscreen video modes.
- `lurek.window.getDisplayName`: Returns the name of the current display.
- `lurek.window.getPixelDimensions`: Returns the window dimensions in physical pixels.
- `lurek.window.showMessageBox`: Shows a platform-native message box dialog.
- `lurek.window.focus`: Requests the window manager to bring the window to the foreground.
- `lurek.window.getNativeDPIScale`: Returns the native DPI scale factor.
- `lurek.window.getDisplayOrientation`: Returns the current display orientation.
- `lurek.window.getSafeArea`: Returns the safe display area as x, y, w, h.
- `lurek.window.getSystemTheme`: Returns the OS color theme preference.
- `lurek.window.isHighDPIAllowed`: Returns whether high-DPI rendering is allowed.
- `lurek.window.getScaleInfo`: Returns viewport scale and offset information as a table.
- `lurek.window.getScaleMode`: Returns the current viewport scale mode string.
- `lurek.window.setScaleMode`: Sets the viewport scale mode.
- `lurek.window.getGameWidth`: Returns the logical game width in virtual pixels.
- `lurek.window.getGameHeight`: Returns the logical game height in virtual pixels.
- `lurek.window.isFullscreen`: Returns whether the window is in fullscreen mode.
- `lurek.window.isResizable`: Returns whether the window can be resized by the user.
- `lurek.window.onDpiChange`: Registers a callback invoked (with the new scale factor) when the display
- `lurek.window.pollDpiChange`: Polls for a pending DPI change event and returns the new scale factor if any.
- `lurek.window.openFileDialog`: Opens a blocking native file-open dialog. Returns the chosen path string

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/window/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.

### Already in place (0.14.0)

- `lurek.window.setPosition(x, y)` / `getPosition()` — implemented via `WindowState.pending_position` and `src/window/management.rs`. IDEA.md was outdated; implementation predates 0.14.1.
