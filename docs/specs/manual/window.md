# window manual spec overlay

## TL;DR

- Manages OS window lifecycles, displays, VSync syncs, and viewport scaling with native dialogs.

## Summary

- The `window` module is the desktop-window control surface for users who need display selection, viewport scaling, mode changes, and OS-facing window behavior under one runtime API.
- Event-loop display data, staged window-management requests, and viewport conversion helpers work together so a project can reason about screen state without embedding platform-specific code in gameplay modules.
- Fullscreen choices, placement, resizing, file-dialog support, and coordinate conversion matter because the window is both a presentation target and a user-facing operating-system object.
- The module is useful for settings screens, startup configuration, tool windows, and any feature that needs to query or change how the engine occupies the desktop.
- DPI-aware scaling and coordinate conversion are especially important because modern desktop behavior is not one-to-one with raw pixels; the window surface must mediate between OS display rules and engine-facing view logic.
- It also supports editor-style and multi-display workflows while the runtime stays alive.
- Read it as the owner of desktop-window policy and scaling behavior. Other modules render or process input within the window, but `window` decides how that host surface is configured and managed.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
