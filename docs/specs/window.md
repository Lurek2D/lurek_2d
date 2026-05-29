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

## Files

### event_loop.rs

- Multi-monitor enumeration, display info snapshots, and primary-monitor detection.
- Monitor selection with fallback logic (current → primary → first available).
- Window centering and cross-display movement helpers.
- Startup monitor resolution for initial window placement.

### management.rs

- Stage deferred window property changes (title, size, position, icon, display).
- Fullscreen and vsync mode switching with exclusive/desktop variants.
- Minimize, maximize, restore, close, and attention-request staging.
- Focus, visibility, and mouse-focus queries.
- DPI-aware pixel conversion helpers.
- Combined mode update and snapshot via `set_mode`/`get_mode`.
- Native OS message-box dialog via `rfd`.

### mod.rs

- OS window lifecycle: creation, sizing, positioning, fullscreen, and DPI handling.
- Multi-monitor support: display enumeration, selection, and window placement.
- Virtual viewport: logical-to-pixel scaling and scale-mode selection.

### viewport.rs

- Logical game viewport size queries and scale-mode staging.
- Coordinate conversion between logical game space and physical screen pixels.
- Viewport scale/offset snapshot via `ScaleInfo`.

## Lua API Ref

- Binding: `src/lua_api/window_api.rs`
- Namespace: `lurek.window`

### Functions

- `lurek.window.close`: Closes the window and signals the engine to shut down.
- `lurek.window.flash`: Flashes the window briefly to attract the user's attention.
- `lurek.window.focus`: Requests keyboard focus for the window. No-op if already focused.
- `lurek.window.fromPixels`: Converts a value from physical pixel units to logical (DPI-independent) units using the current DPI scale.
- `lurek.window.getCurrentDisplay`: Returns the index of the display that currently contains the window.
- `lurek.window.getDPIScale`: Returns the current DPI scale factor of the window. A value of 2.0 means the display uses 2x scaling (e.g., Retina).
- `lurek.window.getDesktopDimensions`: Returns the desktop resolution of a specific display, or the current display if none is specified.
- `lurek.window.getDimensions`: Returns the current window width and height in logical pixels.
- `lurek.window.getDisplayCount`: Returns the number of connected displays (monitors).
- `lurek.window.getDisplayName`: Returns the human-readable name of a display. Returns "Unknown" if the display cannot be identified.
- `lurek.window.getDisplayOrientation`: Returns the display orientation based on the window's aspect ratio.
- `lurek.window.getDisplays`: Returns a list of all connected displays with their properties. Each entry contains index, name, position (x, y), resolution (width, height), scale factor, refresh rate, and whether it is the primary monitor.
- `lurek.window.getFullscreen`: Returns the current fullscreen state and type.
- `lurek.window.getFullscreenModes`: Returns a list of all supported fullscreen video modes across all monitors. Each entry contains width, height, and refresh rate.
- `lurek.window.getGameHeight`: Returns the logical game height as defined by the current scale mode and game configuration.
- `lurek.window.getGameWidth`: Returns the logical game width as defined by the current scale mode and game configuration.
- `lurek.window.getHeight`: Returns the current window height in logical (DPI-independent) pixels.
- `lurek.window.getMode`: Returns the current window display mode: width, height, and a flags table containing fullscreen state, fullscreen type, and VSync mode.
- `lurek.window.getNativeDPIScale`: Returns the native DPI scale factor reported by the operating system.
- `lurek.window.getPixelDimensions`: Returns the window dimensions in actual physical pixels, accounting for DPI scaling.
- `lurek.window.getPosition`: Returns the window position on screen in pixels.
- `lurek.window.getSafeArea`: Returns the safe drawing area of the window. On desktop this is the full window area. Useful for compatibility with mobile-style layout code.
- `lurek.window.getScaleInfo`: Returns detailed scaling information including scale factors, offsets, and logical game dimensions. Useful for coordinate conversion between screen space and game space.
- `lurek.window.getScaleMode`: Returns the current content scale mode name (e.g., "stretch", "letterbox", "pixel-perfect").
- `lurek.window.getSystemTheme`: Returns the operating system's current color theme. Desktop currently returns "unknown".
- `lurek.window.getTitle`: Returns the current window title bar text.
- `lurek.window.getVSync`: Returns the current VSync mode. This function is exposed to Lua scripts.
- `lurek.window.getWidth`: Returns the current window width in logical (DPI-independent) pixels.
- `lurek.window.hasFocus`: Returns whether the window currently has keyboard focus.
- `lurek.window.hasMouseFocus`: Returns whether the mouse cursor is inside the window.
- `lurek.window.isFullscreen`: Returns whether the window is currently in fullscreen mode.
- `lurek.window.isHighDPIAllowed`: Returns whether high-DPI rendering is allowed. Currently always returns false on desktop.
- `lurek.window.isMaximized`: Returns whether the window is currently maximized.
- `lurek.window.isMinimized`: Returns whether the window is currently minimized to the taskbar.
- `lurek.window.isOpen`: Returns whether the window is currently open. Always returns true while the game is running.
- `lurek.window.isResizable`: Returns whether the window can be resized by the user.
- `lurek.window.isVisible`: Returns whether the window is currently visible on screen.
- `lurek.window.maximize`: Maximizes the window to fill the screen.
- `lurek.window.minimize`: Minimizes the window to the taskbar.
- `lurek.window.onDpiChange`: Registers a callback function that is called whenever the DPI scale factor changes (e.g., when the window is moved to a different monitor). Only one callback can be active at a time; setting a new one replaces the previous.
- `lurek.window.openFileDialog`: Opens a native file picker dialog and returns the selected file paths. Blocks until the user picks file(s) or cancels.
- `lurek.window.pollDpiChange`: Checks if the DPI scale has changed since the last poll and fires the onDpiChange callback if so. Call this once per frame in your update loop to detect monitor changes.
- `lurek.window.requestAttention`: Requests user attention by flashing the taskbar icon. Useful for notifying the player when the window is in the background.
- `lurek.window.restore`: Restores the window from minimized or maximized state to its previous size and position.
- `lurek.window.setDisplay`: Moves the window to the specified display. Throws an error if the index is negative.
- `lurek.window.setFullscreen`: Enables or disables fullscreen mode. Supports "desktop" (borderless) and "exclusive" types.
- `lurek.window.setIcon`: Sets the window icon from an image file. The file must exist in the game's filesystem. Supports PNG and other common image formats.
- `lurek.window.setMode`: Sets the window display mode with a specific resolution and optional flags. Use this to resize the window and configure fullscreen or VSync at the same time.
- `lurek.window.setPosition`: Moves the window to the specified screen position.
- `lurek.window.setScaleMode`: Sets the content scale mode. Controls how the game's logical resolution maps to the window size.
- `lurek.window.setTitle`: Sets the window title bar text. This function is exposed to Lua scripts.
- `lurek.window.setVSync`: Sets the vertical sync mode. Controls how frame presentation is synchronized with the display.
- `lurek.window.showMessageBox`: Displays a native OS message box dialog. Blocks execution until the user dismisses it.
- `lurek.window.toPixels`: Converts a value from logical (DPI-independent) units to physical pixel units using the current DPI scale.
- `lurek.window.windowConfig`: Applies multiple window settings at once from a configuration table. Supports title, width, height, fullscreen, fullscreentype, vsync, position (x, y), scaleMode, and display index.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
