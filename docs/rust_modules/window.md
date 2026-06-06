# window

## General Info

- Module group: `Platform Services`
- Source path: `src/window/`
- Binding: `src/lua_api/window_api.rs`
- Namespace: `lurek.window`
- Lua API surface: `55` functions, `4` types, `0` methods
- Rust test path(s): tests/rust/unit/window_tests.rs
- Lua test path(s): tests/lua/unit/test_window_core_unit.lua

## Summary

This module serves as the primary gateway for controlling the OS-level application window and managing multi-monitor systems. By abstracting the operating system's display APIs, it lets developers query connected monitors, retrieve desktop resolutions, and transition the game window across screens seamlessly. The window manager targets startup monitors dynamically while exposing centering and window-movement operations.

To ensure seamless gameplay interactions, the window subsystem implements a deferred state-change pipeline. Title updates, resolution shifts, custom icons, and min/max window states are queued and applied safely during event-loop ticks. This manager also regulates synchronization behaviors, allowing users to toggle between VSync configurations and borderless or exclusive fullscreen modes.

Finally, the viewport system maps logical game coordinates to physical screens, computing scale factors and letterbox offsets automatically. This translation guarantees consistent mouse mapping and render scaling under varied window dimensions. The module also wraps OS dialog systems, offering native message boxes, blocking file pickers, and DPI-change callbacks for seamless integration.

## Files

### [event_loop.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/window/event_loop.rs)

- This file provides event-loop side monitor and display helpers for window placement flow.
- It enumerates displays and captures snapshot metadata used by window-facing APIs.
- It selects startup and fallback monitors with deterministic preference ordering.
- It supports centering and cross-display movement operations for runtime window control.
- It anchors monitor-aware behavior required by multi-display desktop setups.

### [management.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/window/management.rs)

- This file provides deferred window management operations staged for safe event-loop apply.
- It controls title, size, position, display target, and icon updates through queued state.
- It manages fullscreen and vsync mode changes across desktop and exclusive variants.
- It exposes minimize, maximize, restore, close, and attention requests for app lifecycle flow.
- It provides focus, visibility, and pointer-presence queries for runtime interaction logic.
- It includes DPI conversion and mode snapshot helpers used by Lua and engine integration.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/window/mod.rs)

- This module delivers the high-level desktop window subsystem for lifecycle and display control.
- It unifies monitor handling, mode changes, viewport scaling, and state query surfaces.
- It provides the runtime boundary between OS window behavior and script-facing APIs.

### [viewport.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/window/viewport.rs)

- This file provides viewport scaling helpers between logical game space and physical pixels.
- It exposes logical dimensions and scale mode state used by rendering and input mapping.
- It computes conversion factors and offsets so coordinate translation remains consistent.
- It supports runtime staging of scale behavior without direct renderer coupling.
