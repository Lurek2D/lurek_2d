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

Built upon the robust `winit` 0.30 backend, it controls window creation, sizing, positioning, and input acquisition while insulating the game loop from native platform quirks. To ensure frame-perfect consistency, the `WindowState` system employs a deferred update strategy: requests to change properties like title, size, position, fullscreen mode, or cursor visibility are queued during the frame and applied atomically just before the next event poll, completely eliminating mid-frame tearing or inconsistent state reads.

Handling modern display environments is a primary focus of this module. It provides comprehensive multi-monitor enumeration (`get_displays`), returning detailed `DisplayInfo` snapshots that include resolution, DPI scale, refresh rate, and physical layout coordinates. This allows the engine to intelligently select startup monitors, center windows across distinct screens, and adapt to DPI scaling changes on the fly. The viewport system (`viewport.rs`) works in tandem with the window manager to decouple the logical game resolution from the physical window size. It provides coordinate conversion helpers that automatically translate OS-level mouse coordinates into game-space coordinates based on the active scale mode (e.g., stretch, letterbox, pixel-perfect).

The module also handles critical rendering integration points. VSync configuration can be toggled between immediate (uncapped), FIFO (standard vsync), and mailbox modes, giving developers tight control over frame presentation and latency. Fullscreen operations support both exclusive mode for maximum performance and borderless desktop mode for seamless multitasking. Additionally, the module exposes native platform features—such as asynchronous file dialogs via `rfd` and OS-level message boxes—allowing for standard file picking and alert interactions without blocking the primary game loop. Fully accessible through the `lurek.window.*` API, this module provides the dependable foundation required to host the engine on any supported desktop OS.

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
