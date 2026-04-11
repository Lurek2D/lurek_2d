# window

## General Info

- Module group: `Platform Services`
- Source path: `src/window/`
- Lua API path(s): `src/lua_api/window_api.rs`
- Primary Lua namespace: `lurek.window`
- Rust test path(s): tests/rust/unit/window_tests.rs
- Lua test path(s): tests/lua/unit/test_window.lua, tests/lua/unit/test_window_scaling.lua

## Summary

The `window` module owns engine-level window state and viewport conversion helpers. Its job is to expose a clean Rust surface for title changes, fullscreen and vsync requests, resizing, position changes, focus queries, DPI conversion, and game-space to pixel-space mapping.

This module exists to keep window policy testable and separate from the live OS window handle. Most write operations update `WindowState` pending fields, and the app layer applies those requests on the next frame through `winit`. That split lets Lua and Rust gameplay code request window behavior without importing platform code into unrelated systems.

The module intentionally does not own the actual event loop, swapchain/surface management, or renderer presentation. `engine::app` and the runtime state own the live window object, and `render` owns drawing. The `event_loop` file is currently just a reserved placeholder rather than an active subsystem.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Platform Services responsibility boundary defined in the architecture docs.

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

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/window/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
