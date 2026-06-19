# app

## TL;DR

- Drives the main winit/wgpu frame loop and Lua VM execution.
- Dispatches platform events to safe, guarded engine callbacks.
- Renders startup splash layouts, fatal error screens, and debug HUDs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: None direct
- Namespace: `lurek.input`
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/app_tests.rs; tests/games_load_test.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

- The `app` module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application.
- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.
- It turns platform hosting into one stable application loop.
- Read this module as the final integration boundary where rendering, input, windowing, and Lua execution are coordinated into one recoverable runtime loop.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Imports

- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `image`: Imports or references `image` from `src/image/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: Imports or references `lua_api` from `src/lua_api/`.
- `math`: Imports or references `math` from `src/math/`.
- `parallax`: Imports or references `src/parallax/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `window`: Imports or references `src/window/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.

## Files

### app.rs

- This file owns the desktop runtime loop, from startup target selection through steady frame execution and shutdown.
- It defines viewport helpers, splash-title utilities, startup-drop classification, and key rules for the splash screen.
- `RunState` models running, fatal-error, and restarting modes, while `LurekApp` stores the live host-side app state.
- That state includes window and surface handles, renderer and Lua ownership, hot-reload watchers, timing, and input.
- GPU setup, present-mode selection, surface configuration, resize clamping, and vsync switching are centralized here.
- Lua initialization also lives here, including VM creation, shared-state hookup, startup file loading, and callbacks.
- Per-frame control is split across tick, update, render, splash render, and error render paths with deterministic order.
- Window actions are deferred through local helpers so resize, focus, visibility, cursor, and fullscreen stay guarded.
- The file owns weather-free host input routing for keyboard, mouse, text, wheel, touch, drag-drop, and window events.
- Gamepad polling and vibration effects are handled here too, including slot assignment, naming, and feedback playback.
- Hot reload for scripts, assets, and config files is coordinated here through watcher refresh and polling helpers.
- Screenshot capture, auto-quit timers, perf logging, archive extraction, and restart flow are also app-level concerns.
- The `ApplicationHandler` impl binds winit lifecycle callbacks to safe runtime operations and guarded Lua dispatch.
- The outer `App` and `AppRunOptions` types provide bootstrap input, logger setup, and event-loop launch entrypoints.
- Open this file when desktop host orchestration changes; splash, errors, HUD, and callback helpers live in siblings.

### debug_overlay.rs

- This file owns `DebugOverlay`, the lightweight in-game HUD that emits FPS and draw-call render commands.
- It keeps one enable flag, computes a small top-right panel layout, and returns no commands when disabled.
- Font availability is also guarded here so debug text does not render with incomplete startup resources.
- Open this file when runtime HUD output changes; frame metrics and the app loop live in sibling files.

### error_screen.rs

- This file owns `ErrorScreen`, the render-ready model used when Lua or engine execution fails fatally.
- It separates title, wrapped message lines, and cleaned traceback lines so failure text stays readable in-window.
- Helpers format `mlua::Error`, split traceback blocks, normalize `[string ...]` markers, and wrap long lines.
- Render-command builders paint the full-screen background, title, body, traceback, and footer guidance text.
- The file also exposes clipboard-friendly plain text so failure details can be copied outside the renderer.
- This owner is about presentation and text shaping, not about deciding when the runtime enters fatal mode.
- Open it when error display semantics change; event-loop recovery and callback guards live in sibling files.

### frame_profile.rs

- This file owns compact frame-profile formatting used to serialize runtime timing samples into one diagnostic line.
- It reads `runtime::FrameProfile` fields and emits tick, update, render, and callback totals in milliseconds.
- Open this file when frame timing text changes; frame collection and event-loop orchestration live in sibling files.

### lua_callbacks.rs

- This file owns guarded `lurek.*` callback invocation helpers used by the desktop app runtime and UI bridges.
- It exposes logging and checked variants, probes callback presence, and resolves functions from the active Lua VM.
- Optional timeout wrappers install instruction hooks so runaway callbacks abort with a named runtime error.
- The file is the safety boundary between host events and Lua execution, keeping timeout policy in one owner.
- Open it when callback guard semantics change; frame orchestration and input dispatch live in sibling modules.

### mod.rs

- This module re-exports the desktop app subsystem for runtime orchestration, splash, errors, callbacks, and HUD state.
- It is the navigation map for host-loop ownership, startup surfaces, callback guards, and frame-profile helpers.
- `app.rs` owns the main runtime loop, while `splash_screen.rs` and `error_screen.rs` cover startup and failure surfaces.
- `lua_callbacks.rs` holds guarded `lurek.*` invocation helpers, and `debug_overlay.rs` renders the diagnostics HUD.
- `frame_profile.rs` formats per-frame timing samples for logs, traces, and other small diagnostics surfaces.
- Change this file when public app exports move; change sibling files when runtime behavior or startup flows change.

### splash_screen.rs

- This file owns splash-branding asset loading and centered startup render-command generation for the desktop app.
- It decodes embedded icon and banner PNGs into temporary texture storage used before game assets are active.
- Layout helpers fit branding into the window, center it, and switch the footer hint when drag-and-drop is hovering.
- The file is only about splash visuals; window creation, input handling, and frame flow stay in the main app owner.
- Open this file when startup presentation changes; runtime orchestration and fatal fallback screens live in siblings.

## Callbacks

- No global engine callback metadata was found for this module.



## Lua API Ref

### Functions

- No documented module-level functions.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `image`: Imports or references `image` from `src/image/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: Imports or references `lua_api` from `src/lua_api/`.
- `math`: Imports or references `math` from `src/math/`.
- `parallax`: Imports or references `src/parallax/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `window`: Imports or references `src/window/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.

## Notes

- No additional module-specific notes.
