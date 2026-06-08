# window

## TL;DR

- Manages OS window lifecycles, displays, VSync syncs, and viewport scaling with native dialogs.

## General Info

- Module group: `Platform Services`
- Source path: `src/window/`
- Binding: `src/lua_api/window_api.rs`
- Namespace: `lurek.window`
- Lua API surface: `55` functions, `4` types, `0` methods
- Rust test path(s): tests/rust/unit/window_tests.rs
- Lua test path(s): tests/lua/unit/test_window_core_unit.lua

## Summary

- This module gives users runtime control over the application window, displays, scaling, and desktop integration features.
- Display APIs expose monitor inventory, resolution data, and current-screen placement.
- Window lifecycle controls cover position, size, minimize, maximize, restore, and close behavior.
- Fullscreen controls support desktop and exclusive modes with VSync configuration options.
- Deferred state application keeps mode changes safe within event-loop boundaries.
- Title, icon, and attention APIs support polished desktop application behavior.
- DPI and pixel conversion helpers support high-DPI-aware coordinate handling.
- Scale-mode and viewport helpers keep logical game space consistent across window sizes.
- Screen/game coordinate mapping supports reliable pointer-to-world interactions.
- Native dialogs support message boxes and file-picking integration.
- Theme and focus visibility queries support adaptive UI behavior.
- The module is useful for desktop UX quality, settings menus, and multi-monitor workflows.
- For users, it centralizes OS window interactions behind one scriptable API surface.
- It reduces platform-quirk handling in gameplay and UI scripts.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### event_loop.rs

- This file provides event-loop side monitor and display helpers for window placement flow.
- It enumerates displays and captures snapshot metadata used by window-facing APIs.
- It selects startup and fallback monitors with deterministic preference ordering.
- It supports centering and cross-display movement operations for runtime window control.
- It anchors monitor-aware behavior required by multi-display desktop setups.

### management.rs

- This file provides deferred window management operations staged for safe event-loop apply.
- It controls title, size, position, display target, and icon updates through queued state.
- It manages fullscreen and vsync mode changes across desktop and exclusive variants.
- It exposes minimize, maximize, restore, close, and attention requests for app lifecycle flow.
- It provides focus, visibility, and pointer-presence queries for runtime interaction logic.
- It includes DPI conversion and mode snapshot helpers used by Lua and engine integration.

### mod.rs

- This module delivers the high-level desktop window subsystem for lifecycle and display control.
- It unifies monitor handling, mode changes, viewport scaling, and state query surfaces.
- It provides the runtime boundary between OS window behavior and script-facing APIs.

### viewport.rs

- This file provides viewport scaling helpers between logical game space and physical pixels.
- It exposes logical dimensions and scale mode state used by rendering and input mapping.
- It computes conversion factors and offsets so coordinate translation remains consistent.
- It supports runtime staging of scale behavior without direct renderer coupling.

## Lua API Ref

### Functions

- `lurek.window.close() -> nil`: Closes the window and signals the engine to shut down.
- `lurek.window.flash() -> nil`: Flashes the window briefly to attract the user's attention.
- `lurek.window.focus() -> nil`: Requests keyboard focus for the window. No-op if already focused.
- `lurek.window.fromPixels(value) -> number`: Converts a value from physical pixel units to logical (DPI-independent) units using the current DPI scale.
- `lurek.window.getCurrentDisplay() -> number`: Returns the index of the display that currently contains the window.
- `lurek.window.getDPIScale() -> number`: Returns the current DPI scale factor of the window. A value of 2.0 means the display uses 2x scaling (e.g., Retina).
- `lurek.window.getDesktopDimensions(display?) -> number`: Returns the desktop resolution of a specific display, or the current display if none is specified.
- `lurek.window.getDimensions() -> number`: Returns the current window width and height in logical pixels.
- `lurek.window.getDisplayCount() -> number`: Returns the number of connected displays (monitors).
- `lurek.window.getDisplayName(display?) -> string`: Returns the human-readable name of a display. Returns "Unknown" if the display cannot be identified.
- `lurek.window.getDisplayOrientation() -> string`: Returns the display orientation based on the window's aspect ratio.
- `lurek.window.getDisplays() -> table`: Returns a list of all connected displays with their properties. Each entry contains index, name, position (x, y), resolution (width, height), scale factor, refresh rate, and whether it is the primary monitor.
- `lurek.window.getFullscreen() -> boolean`: Returns the current fullscreen state and type.
- `lurek.window.getFullscreenModes() -> table`: Returns a list of all supported fullscreen video modes across all monitors. Each entry contains width, height, and refresh rate.
- `lurek.window.getGameHeight() -> number`: Returns the logical game height as defined by the current scale mode and game configuration.
- `lurek.window.getGameWidth() -> number`: Returns the logical game width as defined by the current scale mode and game configuration.
- `lurek.window.getHeight() -> number`: Returns the current window height in logical (DPI-independent) pixels.
- `lurek.window.getMode() -> number`: Returns the current window display mode: width, height, and a flags table containing fullscreen state, fullscreen type, and VSync mode.
- `lurek.window.getNativeDPIScale() -> number`: Returns the native DPI scale factor reported by the operating system.
- `lurek.window.getPixelDimensions() -> number`: Returns the window dimensions in actual physical pixels, accounting for DPI scaling.
- `lurek.window.getPosition() -> number`: Returns the window position on screen in pixels.
- `lurek.window.getSafeArea() -> number`: Returns the safe drawing area of the window. On desktop this is the full window area. Useful for compatibility with mobile-style layout code.
- `lurek.window.getScaleInfo() -> table`: Returns detailed scaling information including scale factors, offsets, and logical game dimensions. Useful for coordinate conversion between screen space and game space.
- `lurek.window.getScaleMode() -> string`: Returns the current content scale mode name (e.g., "stretch", "letterbox", "pixel-perfect").
- `lurek.window.getSystemTheme() -> string`: Returns the operating system's current color theme. Desktop currently returns "unknown".
- `lurek.window.getTitle() -> string`: Returns the current window title bar text.
- `lurek.window.getVSync() -> number`: Returns the current VSync mode. This function is exposed to Lua scripts.
- `lurek.window.getWidth() -> number`: Returns the current window width in logical (DPI-independent) pixels.
- `lurek.window.hasFocus() -> boolean`: Returns whether the window currently has keyboard focus.
- `lurek.window.hasMouseFocus() -> boolean`: Returns whether the mouse cursor is inside the window.
- `lurek.window.isFullscreen() -> boolean`: Returns whether the window is currently in fullscreen mode.
- `lurek.window.isHighDPIAllowed() -> boolean`: Returns whether high-DPI rendering is allowed. Currently always returns false on desktop.
- `lurek.window.isMaximized() -> boolean`: Returns whether the window is currently maximized.
- `lurek.window.isMinimized() -> boolean`: Returns whether the window is currently minimized to the taskbar.
- `lurek.window.isOpen() -> boolean`: Returns whether the window is currently open. Always returns true while the game is running.
- `lurek.window.isResizable() -> boolean`: Returns whether the window can be resized by the user.
- `lurek.window.isVisible() -> boolean`: Returns whether the window is currently visible on screen.
- `lurek.window.maximize() -> nil`: Maximizes the window to fill the screen.
- `lurek.window.minimize() -> nil`: Minimizes the window to the taskbar.
- `lurek.window.onDpiChange(func) -> nil`: Registers a callback function that is called whenever the DPI scale factor changes (e.g., when the window is moved to a different monitor). Only one callback can be active at a time; setting a new one replaces the previous.
- `lurek.window.openFileDialog(opts?) -> string[]`: Opens a native file picker dialog and returns the selected file paths. Blocks until the user picks file(s) or cancels.
- `lurek.window.pollDpiChange() -> number`: Checks if the DPI scale has changed since the last poll and fires the onDpiChange callback if so. Call this once per frame in your update loop to detect monitor changes.
- `lurek.window.requestAttention() -> nil`: Requests user attention by flashing the taskbar icon. Useful for notifying the player when the window is in the background.
- `lurek.window.restore() -> nil`: Restores the window from minimized or maximized state to its previous size and position.
- `lurek.window.setDisplay(display) -> nil`: Moves the window to the specified display. Throws an error if the index is negative.
- `lurek.window.setFullscreen(enabled, fstype?) -> nil`: Enables or disables fullscreen mode. Supports "desktop" (borderless) and "exclusive" types.
- `lurek.window.setIcon(path) -> nil`: Sets the window icon from an image file. The file must exist in the game's filesystem. Supports PNG and other common image formats.
- `lurek.window.setMode(w, h, flags?) -> nil`: Sets the window display mode with a specific resolution and optional flags. Use this to resize the window and configure fullscreen or VSync at the same time.
- `lurek.window.setPosition(x, y) -> nil`: Moves the window to the specified screen position.
- `lurek.window.setScaleMode(mode) -> nil`: Sets the content scale mode. Controls how the game's logical resolution maps to the window size.
- `lurek.window.setTitle(title) -> nil`: Sets the window title bar text. This function is exposed to Lua scripts.
- `lurek.window.setVSync(mode) -> nil`: Sets the vertical sync mode. Controls how frame presentation is synchronized with the display.
- `lurek.window.showMessageBox(title, message, box_type?, btn_type?) -> string`: Displays a native OS message box dialog. Blocks execution until the user dismisses it.
- `lurek.window.toPixels(value) -> number`: Converts a value from logical (DPI-independent) units to physical pixel units using the current DPI scale.
- `lurek.window.windowConfig(opts) -> nil`: Applies multiple window settings at once from a configuration table. Supports title, width, height, fullscreen, fullscreentype, vsync, position (x, y), scaleMode, and display index.

### Callbacks

- `lurek.window.onDpiChange` param `func` (`function`): Callback receiving the new DPI scale as a number.

### Enums

- No documented module-level enums/constants.

### Types

#### LWindowGetDisplaysResult Type

- Generated result shape from @field tags.

##### Fields

- `height` (`integer`): Height in pixels.
- `index` (`integer`): Display index.
- `name` (`string`): Display name.
- `primary` (`boolean`): Whether this is the primary display.
- `refreshRate` (`number`): Refresh rate in Hz.
- `scale` (`number`): Scale factor.
- `width` (`integer`): Width in pixels.
- `x` (`integer`): X position.
- `y` (`integer`): Y position.

##### Methods

- No documented methods.

#### LWindowGetFullscreenModesResult Type

- Generated result shape from @field tags.

##### Fields

- `height` (`integer`): Height in pixels.
- `refreshRate` (`number`): Refresh rate in Hz.
- `width` (`integer`): Width in pixels.

##### Methods

- No documented methods.

#### LWindowGetModeResult Type

- Generated result shape from @field tags.

##### Fields

- `fullscreen` (`boolean`): Whether fullscreen is active.
- `fullscreentype` (`string`): Fullscreen type.
- `vsync` (`boolean`): Whether VSync is enabled.

##### Methods

- No documented methods.

#### LWindowGetScaleInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `game_height` (`number`): Game height.
- `game_width` (`number`): Game width.
- `offset_x` (`number`): Offset x.
- `offset_y` (`number`): Offset y.
- `scale_x` (`number`): Scale x.
- `scale_y` (`number`): Scale y.

##### Methods

- No documented methods.
