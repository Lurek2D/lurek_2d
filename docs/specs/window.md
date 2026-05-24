# window

## TL;DR

- The `window` module is an essential Platform Services tier component responsible for OS-level window lifecycle and multi-monitor management.

## General Info

- Module group: `Platform Services`
- Source path: `src/window/`
- Lua API path(s): `src/lua_api/window_api.rs`
- Primary Lua namespace: `lurek.window`
- Rust test path(s): tests/rust/unit/window_tests.rs
- Lua test path(s): tests/lua/unit/test_window_core_unit.lua

## Summary

 Built upon the robust `winit` 0.30 backend, it controls window creation, sizing, positioning, and input acquisition while insulating the game loop from native platform quirks. To ensure frame-perfect consistency, the `WindowState` system employs a deferred update strategy: requests to change properties like title, size, position, fullscreen mode, or cursor visibility are queued during the frame and applied atomically just before the next event poll, completely eliminating mid-frame tearing or inconsistent state reads.

Handling modern display environments is a primary focus of this module. It provides comprehensive multi-monitor enumeration (`get_displays`), returning detailed `DisplayInfo` snapshots that include resolution, DPI scale, refresh rate, and physical layout coordinates. This allows the engine to intelligently select startup monitors, center windows across distinct screens, and adapt to DPI scaling changes on the fly. The viewport system (`viewport.rs`) works in tandem with the window manager to decouple the logical game resolution from the physical window size. It provides coordinate conversion helpers that automatically translate OS-level mouse coordinates into game-space coordinates based on the active scale mode (e.g., stretch, letterbox, pixel-perfect).

The module also handles critical rendering integration points. VSync configuration can be toggled between immediate (uncapped), FIFO (standard vsync), and mailbox modes, giving developers tight control over frame presentation and latency. Fullscreen operations support both exclusive mode for maximum performance and borderless desktop mode for seamless multitasking. Additionally, the module exposes native platform features—such as asynchronous file dialogs via `rfd` and OS-level message boxes—allowing for standard file picking and alert interactions without blocking the primary game loop. Fully accessible through the `lurek.window.*` API, this module provides the dependable foundation required to host the engine on any supported desktop OS.

## Source Documentation

### `event_loop.rs`
- Multi-monitor enumeration, display info snapshots, and primary-monitor detection.
- Monitor selection with fallback logic (current → primary → first available).
- Window centering and cross-display movement helpers.
- Startup monitor resolution for initial window placement.

### `management.rs`
- Stage deferred window property changes (title, size, position, icon, display).
- Fullscreen and vsync mode switching with exclusive/desktop variants.
- Minimize, maximize, restore, close, and attention-request staging.
- Focus, visibility, and mouse-focus queries.
- DPI-aware pixel conversion helpers.
- Combined mode update and snapshot via `set_mode`/`get_mode`.
- Native OS message-box dialog via `rfd`.

### `mod.rs`
- OS window lifecycle: creation, sizing, positioning, fullscreen, and DPI handling.
- Multi-monitor support: display enumeration, selection, and window placement.
- Virtual viewport: logical-to-pixel scaling and scale-mode selection.

### `viewport.rs`
- Logical game viewport size queries and scale-mode staging.
- Coordinate conversion between logical game space and physical screen pixels.
- Viewport scale/offset snapshot via `ScaleInfo`.

## Types

- `DisplayInfo` (`struct`, `event_loop.rs`): Snapshot of one connected display returned by `get_displays`.
- `ModeInfo` (`struct`, `management.rs`): A compact snapshot of fullscreen and vsync state returned by the window mode query helpers.
- `ScaleInfo` (`struct`, `viewport.rs`): A read-only snapshot of current viewport scale, offsets, and logical game dimensions used by coordinate-conversion callers.

## Functions

- `get_displays` (`event_loop.rs`): Returns structured metadata for connected displays.
- `current_display_index` (`event_loop.rs`): Resolves which display currently contains the window.
- `desktop_dimensions_for_display` (`event_loop.rs`): Returns desktop size for a selected display.
- `display_name_for_display` (`event_loop.rs`): Returns display name for a selected display.
- `move_window_to_display` (`event_loop.rs`): Centers and moves the window to a selected monitor.
- `select_startup_monitor` (`event_loop.rs`): Chooses startup monitor with primary fallback.
- `center_window_on_monitor` (`event_loop.rs`): Centers the window in monitor bounds.
- `set_title` (`management.rs`): Schedules a window title change for the next frame.
- `set_fullscreen` (`management.rs`): Schedules a fullscreen mode change.
- `is_fullscreen` (`management.rs`): Returns whether the window is currently in fullscreen mode.
- `set_vsync` (`management.rs`): Schedules a VSync mode change.
- `get_vsync` (`management.rs`): Returns the current VSync mode integer.
- `get_dpi_scale` (`management.rs`): Returns the DPI scale factor of the display the window is on.
- `get_position` (`management.rs`): Returns the current window position in screen coordinates as `(x, y)`.
- `set_position` (`management.rs`): Schedules a window position change to `(x, y)` in screen coordinates.
- `set_display` (`management.rs`): Schedules moving the window to a selected monitor index.
- `minimize` (`management.rs`): Schedules a window minimize (iconify) operation.
- `maximize` (`management.rs`): Schedules a window maximize operation.
- `restore` (`management.rs`): Schedules a window restore from minimized or maximized state.
- `is_minimized` (`management.rs`): Returns whether the window is currently minimized.
- `is_maximized` (`management.rs`): Returns whether the window is currently maximized.
- `has_focus` (`management.rs`): Returns whether the window currently has keyboard focus.
- `request_attention` (`management.rs`): Schedules a user-attention request (taskbar flash on Windows / dock bounce on macOS).
- `flash` (`management.rs`): Alias for `request_attention`.
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
- `lurek.window.setTitle`: Sets the window title bar text. This function is exposed to Lua scripts.
- `lurek.window.getTitle`: Returns the current window title bar text.
- `lurek.window.getWidth`: Returns the current window width in logical (DPI-independent) pixels.
- `lurek.window.getHeight`: Returns the current window height in logical (DPI-independent) pixels.
- `lurek.window.getDimensions`: Returns the current window width and height in logical pixels.
- `lurek.window.setFullscreen`: Enables or disables fullscreen mode. Supports "desktop" (borderless) and "exclusive" types.
- `lurek.window.getFullscreen`: Returns the current fullscreen state and type.
- `lurek.window.isOpen`: Returns whether the window is currently open. Always returns true while the game is running.
- `lurek.window.setVSync`: Sets the vertical sync mode. Controls how frame presentation is synchronized with the display.
- `lurek.window.getVSync`: Returns the current VSync mode. This function is exposed to Lua scripts.
- `lurek.window.hasFocus`: Returns whether the window currently has keyboard focus.
- `lurek.window.hasMouseFocus`: Returns whether the mouse cursor is inside the window.
- `lurek.window.isMinimized`: Returns whether the window is currently minimized to the taskbar.
- `lurek.window.isMaximized`: Returns whether the window is currently maximized.
- `lurek.window.isVisible`: Returns whether the window is currently visible on screen.
- `lurek.window.minimize`: Minimizes the window to the taskbar.
- `lurek.window.maximize`: Maximizes the window to fill the screen.
- `lurek.window.restore`: Restores the window from minimized or maximized state to its previous size and position.
- `lurek.window.getPosition`: Returns the window position on screen in pixels.
- `lurek.window.setPosition`: Moves the window to the specified screen position.
- `lurek.window.getDisplayCount`: Returns the number of connected displays (monitors).
- `lurek.window.getDisplays`: Returns a list of all connected displays with their properties. Each entry contains index, name, position (x, y), resolution (width, height), scale factor, refresh rate, and whether it is the primary monitor.
- `lurek.window.getCurrentDisplay`: Returns the index of the display that currently contains the window.
- `lurek.window.setDisplay`: Moves the window to the specified display. Throws an error if the index is negative.
- `lurek.window.getDesktopDimensions`: Returns the desktop resolution of a specific display, or the current display if none is specified.
- `lurek.window.getDPIScale`: Returns the current DPI scale factor of the window. A value of 2.0 means the display uses 2x scaling (e.g., Retina).
- `lurek.window.toPixels`: Converts a value from logical (DPI-independent) units to physical pixel units using the current DPI scale.
- `lurek.window.fromPixels`: Converts a value from physical pixel units to logical (DPI-independent) units using the current DPI scale.
- `lurek.window.setIcon`: Sets the window icon from an image file. The file must exist in the game's filesystem. Supports PNG and other common image formats.
- `lurek.window.setMode`: Sets the window display mode with a specific resolution and optional flags. Use this to resize the window and configure fullscreen or VSync at the same time.
- `lurek.window.getMode`: Returns the current window display mode: width, height, and a flags table containing fullscreen state, fullscreen type, and VSync mode.
- `lurek.window.windowConfig`: Applies multiple window settings at once from a configuration table. Supports title, width, height, fullscreen, fullscreentype, vsync, position (x, y), scaleMode, and display index.
- `lurek.window.close`: Closes the window and signals the engine to shut down.
- `lurek.window.requestAttention`: Requests user attention by flashing the taskbar icon. Useful for notifying the player when the window is in the background.
- `lurek.window.flash`: Flashes the window briefly to attract the user's attention.
- `lurek.window.getFullscreenModes`: Returns a list of all supported fullscreen video modes across all monitors. Each entry contains width, height, and refresh rate.
- `lurek.window.getDisplayName`: Returns the human-readable name of a display. Returns "Unknown" if the display cannot be identified.
- `lurek.window.getPixelDimensions`: Returns the window dimensions in actual physical pixels, accounting for DPI scaling.
- `lurek.window.showMessageBox`: Displays a native OS message box dialog. Blocks execution until the user dismisses it.
- `lurek.window.focus`: Requests keyboard focus for the window. No-op if already focused.
- `lurek.window.getNativeDPIScale`: Returns the native DPI scale factor reported by the operating system.
- `lurek.window.getDisplayOrientation`: Returns the display orientation based on the window's aspect ratio.
- `lurek.window.getSafeArea`: Returns the safe drawing area of the window. On desktop this is the full window area. Useful for compatibility with mobile-style layout code.
- `lurek.window.getSystemTheme`: Returns the operating system's current color theme. Desktop currently returns "unknown".
- `lurek.window.isHighDPIAllowed`: Returns whether high-DPI rendering is allowed. Currently always returns false on desktop.
- `lurek.window.getScaleInfo`: Returns detailed scaling information including scale factors, offsets, and logical game dimensions. Useful for coordinate conversion between screen space and game space.
- `lurek.window.getScaleMode`: Returns the current content scale mode name (e.g., "stretch", "letterbox", "pixel-perfect").
- `lurek.window.setScaleMode`: Sets the content scale mode. Controls how the game's logical resolution maps to the window size.
- `lurek.window.getGameWidth`: Returns the logical game width as defined by the current scale mode and game configuration.
- `lurek.window.getGameHeight`: Returns the logical game height as defined by the current scale mode and game configuration.
- `lurek.window.isFullscreen`: Returns whether the window is currently in fullscreen mode.
- `lurek.window.isResizable`: Returns whether the window can be resized by the user.
- `lurek.window.onDpiChange`: Registers a callback function that is called whenever the DPI scale factor changes (e.g., when the window is moved to a different monitor). Only one callback can be active at a time; setting a new one replaces the previous.
- `lurek.window.pollDpiChange`: Checks if the DPI scale has changed since the last poll and fires the onDpiChange callback if so. Call this once per frame in your update loop to detect monitor changes.
- `lurek.window.openFileDialog`: Opens a native file picker dialog and returns the selected file paths. Blocks until the user picks file(s) or cancels.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/window/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.

### Already in place (0.14.0)

- `lurek.window.setPosition(x, y)` / `getPosition()` — implemented via `WindowState.pending_position` and `src/window/management.rs`. IDEA.md was outdated; implementation predates 0.14.1.

### Recent sync (1.0.9-fix.46)

- Implemented multi-monitor enhancement from IDEA: `getDisplays`, `setDisplay`, `getCurrentDisplay`, optional display-index support in `getDesktopDimensions` and `getDisplayName`.
- Implemented API discoverability enhancement: non-breaking grouped aliases under `lurek.window.display`, `lurek.window.mode`, and `lurek.window.cursor`.
- Implemented event-loop placeholder cleanup: `src/window/event_loop.rs` now owns reusable monitor helpers consumed by `app`.

### Recent sync (1.0.9-fix.73)

- Added helper `lurek.window.windowConfig(opts)` to apply common window boot/config patterns in one call.
- Clarified viewport-transform boundary:
  - `window::viewport` owns conversion helpers and scale-mode request surface.
  - `camera` owns world-camera math and view-space transforms.
