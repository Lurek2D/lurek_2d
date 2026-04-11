# app

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): tests/rust/unit/engine_tests.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

The app module is the engine composition root. It exists to turn configuration, platform services, shared runtime state, and the Lua VM into a running desktop application with a winit event loop, GPU renderer, input processing, and frame lifecycle callbacks.

This is where engine startup policy lives: window creation, renderer initialization, splash behavior when no game is loaded, SharedState ownership, frame pacing, restart or error-screen transitions, and routing of OS events into engine systems. If a change affects the overall boot sequence or the order in which runtime systems come alive, it usually lands here.

The module intentionally does not own the underlying domain logic for rendering, input, audio, physics, or Lua bindings. It wires those systems together and drives them at runtime, but their actual behavior lives in their own modules. App is orchestration, not a place for subsystem-specific business logic.

**Scope boundary**: This module currently depends on `event`, `image`, `input`, `light`, `lua_api`, `math`, `render`, `runtime`, and other adjacent modules. It stays within the Edge/Integration responsibility boundary defined in the architecture docs.

## Files

- `app.rs`: Defines the public App entry point and the internal runtime implementation that owns the window, event loop integration, renderer, Lua VM, and frame lifecycle. This is the main file for startup flow, event handling, splash mode, and run-state transitions.
- `app_winit.rs`: Contains alternate or parked winit-specific app code that is not part of the active module export surface. Treat it as implementation context, not the first place to extend live behavior unless it is reconnected deliberately.
- `debug_overlay.rs`: Defines DebugOverlay, the lightweight in-engine overlay for frame and draw statistics. It exists so app-level runtime state can expose quick visual diagnostics without dragging in the full devtools stack.
- `error_screen.rs`: Defines ErrorScreen, the structured presentation for runtime and Lua failures. This file owns how fatal problems become user-visible render commands instead of raw crashes or console output.
- `mod.rs`: Module root that exposes the public app-facing types. It keeps the external surface small while hiding most of the runtime wiring details.

## Types

- `App` (`struct`, `app.rs`): Public entry point used to launch the engine with loaded configuration and optional startup error context. It is the outward-facing runtime shell around the real application lifecycle.
- `App` (`struct`, `app_winit.rs`): Public entry point used to launch the engine with loaded configuration and optional startup error context. It is the outward-facing runtime shell around the real application lifecycle.
- `DebugOverlay` (`struct`, `debug_overlay.rs`): Small runtime overlay for FPS and draw-call visibility. It is useful when changes affect per-frame diagnostics rather than the full devtools subsystem.
- `ErrorScreen` (`struct`, `error_screen.rs`): Structured error presentation model that converts failures into readable render commands. It is the module's user-facing failure surface.

## Functions

- `App::new` (`app.rs`): Creates a new `App` with the given `Config` and an optional conf.lua error.
- `App::run` (`app.rs`): Initialises the GPU, window, Lua VM, and runs the event loop until the game exits.
- `App::new` (`app_winit.rs`): Creates a new `App` with the given `Config`.
- `App::run` (`app_winit.rs`): Initialises the GPU, window, Lua VM, and runs the event loop until the game exits.
- `DebugOverlay::new` (`debug_overlay.rs`): Creates a new disabled debug overlay.
- `DebugOverlay::build_render_commands` (`debug_overlay.rs`): Generates draw commands for the overlay.
- `ErrorScreen::from_error` (`error_screen.rs`): Creates an `ErrorScreen` from a plain error message string.
- `ErrorScreen::from_lua_error` (`error_screen.rs`): Creates an `ErrorScreen` from an `mlua::Error`.
- `ErrorScreen::from_engine_error` (`error_screen.rs`): Creates an `ErrorScreen` from an `EngineError`.
- `ErrorScreen::build_render_commands` (`error_screen.rs`): Generates a sequence of `RenderCommand` values that render the error screen.
- `ErrorScreen::as_text` (`error_screen.rs`): Returns the full error text as a plain string suitable for clipboard copy.
- `wrap_text` (`error_screen.rs`): Wraps a text string at word boundaries to fit within `max_chars` columns.
- `format_traceback` (`error_screen.rs`): Cleans up a Lua traceback string for display.

## Lua API Reference

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- `event`: Imports or references `event` from `src/event/`.
- `image`: Imports or references `image` from `src/image/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: Imports or references `lua_api` from `src/lua_api/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `timer`: Imports or references `timer` from `src/timer/`.

## Notes

- Keep this module reference synchronized with `src/app/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
