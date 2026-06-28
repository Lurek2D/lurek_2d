<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/window.md or source docstrings instead. -->

# window

## TL;DR

- Manages OS window lifecycles, displays, VSync syncs, and viewport scaling with native dialogs.

## General Info

- Module group: `Platform Services`
- Source path: `src/window`
- Binding: `src/lua_api/window_api.rs`
- Namespace: `lurek.window`
- Lua API surface: `55` functions, `4` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `window` module is the desktop-window control surface for users who need display selection, viewport scaling, mode changes, and OS-facing window behavior under one runtime API.
- Event-loop display data, staged window-management requests, and viewport conversion helpers work together so a project can reason about screen state without embedding platform-specific code in gameplay modules.
- Fullscreen choices, placement, resizing, file-dialog support, and coordinate conversion matter because the window is both a presentation target and a user-facing operating-system object.
- The module is useful for settings screens, startup configuration, tool windows, and any feature that needs to query or change how the engine occupies the desktop.
- DPI-aware scaling and coordinate conversion are especially important because modern desktop behavior is not one-to-one with raw pixels; the window surface must mediate between OS display rules and engine-facing view logic.
- It also supports editor-style and multi-display workflows while the runtime stays alive.
- Read it as the owner of desktop-window policy and scaling behavior. Other modules render or process input within the window, but `window` decides how that host surface is configured and managed.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/window`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/window_api.rs`
- Referenced engine modules: `runtime`

## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### event_loop.rs

- `src/window/event_loop.rs` owns monitor enumeration, display snapshots, and startup placement helpers for windows.
- It defines `DisplayInfo` and `FullscreenModeInfo`, keeping monitor metadata and mode snapshots under one owner.
- Current-display lookup, desktop-dimension fallbacks, display naming, and fullscreen mode listing are implemented here.
- This file decides startup monitor selection and centering rules, which makes multi-display placement behavior explicit.
- Read it when monitor preference order, fallback display data, or cross-display window movement semantics need changes.
- Higher layers should treat this file as the monitor-facing boundary, while staged state changes stay in `management.rs`.

### management.rs

- `src/window/management.rs` owns deferred window-control operations that mutate `WindowState` through staged requests.
- It defines `ModeInfo`, `WindowConfigRequest`, and file-dialog option types used to batch desktop window changes.
- Title, size, position, display target, fullscreen mode, vsync, focus, visibility, and attention helpers live here.
- This file also handles DPI conversions, logical-to-physical dimension queries, and grouped mode updates for callers.
- Native dialogs and file-picking options are built here so OS-facing window utilities stay near other management helpers.
- Read it when window lifecycle commands, staged mutation policy, or message box and file dialog behavior must change.
- This is the runtime boundary for desktop window control; monitor discovery and viewport math live in sibling files.

### mod.rs

- `src/window/mod.rs` is the module index that exposes display discovery, window control, and viewport scaling.
- It reexports monitor queries, window-management helpers, and viewport conversion APIs through one stable surface.
- No live OS window state lives here; this file declares child modules and chooses which window symbols are public.
- Read this index when wiring desktop behavior, because it shows where monitor placement ends and staged control begins.
- Changes here reshape the window boundary, since reexports decide what runtime code may import without deep paths.
- This module keeps monitor enumeration, deferred window mutations, and viewport math separated by responsibility.

### viewport.rs

- `src/window/viewport.rs` owns logical viewport sizing and coordinate conversion between game space and screen pixels.
- It defines `ScaleInfo` and uses `WindowState` scale fields to report width, height, offsets, and scale mode state.
- `to_pixels`, `from_pixels`, and scale-mode setters live here so rendering and input mapping share one viewport contract.
- Open this file when scale-mode validation, coordinate transform rules, or viewport snapshot behavior need to change.



## Lua API Ref

### Functions

- `lurek.window.close() -> nil`: Closes the window and signals the engine to shut down.
- `lurek.window.flash() -> nil`: Flashes the window briefly to attract the user's attention.
- `lurek.window.focus() -> nil`: Requests keyboard focus for the window. The request is applied by the app loop on the next frame.
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

## Examples

- `content/examples/window.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
