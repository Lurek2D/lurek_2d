# app

## TL;DR

- The `app` module serves as the primary application lifecycle controller and integration point for Lurek2D, positioned at the top of the Edge/Integration tier.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.input`
- Rust test path(s): tests/engine_tests.rs; tests/rust/ext/graphics_runtime_smoke_tests.rs
- Lua test path(s): None dedicated

## Summary

The `app` module is the composition root and execution orchestrator for the runtime binary. It owns startup order, `winit` event-loop integration, frame lifecycle sequencing, and the bridge points where platform events are translated into Lua callbacks and render submission steps. Instead of holding domain logic for gameplay systems, it coordinates those systems through explicit frame phases and shared runtime services.

At runtime, the module drives a deterministic loop around timing (`Clock`), input/device polling, script callbacks, simulation ticks, and renderer presentation. It also centralizes operational surfaces that must remain globally consistent: fatal error screen fallback, debug overlay rendering, splash screen flow, and frame-profile instrumentation text. This gives one authoritative place for "what happens each frame" and avoids lifecycle drift across feature modules.

The boundary is intentionally integration-focused. Submodules like `lua_callbacks`, `frame_profile`, and `debug_overlay` serve orchestration concerns and are consumed by the main app runner, while heavy business logic stays in specialized modules (`render`, `input`, `audio`, `physics`, etc.). The app layer therefore acts as an execution scheduler and policy host, not as a domain owner.

From a maintenance perspective, this module is where reliability controls belong: callback timeout wrappers, safe recovery paths for user-facing failures, and event-to-callback routing guarantees. In practice, changes here should preserve strict ordering guarantees and keep side effects observable, because almost every runtime subsystem is activated through this module's frame pipeline.

Implementation detail and boundary guarantees for app: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: app.rs: Implements the central LurekApp runtime driven by winit's ApplicationHandler.; debug_overlay.rs: Owns the lightweight debug HUD toggled by F12 or Lua.; error_screen.rs: Formats fatal Lua and engine errors into a user-facing screen.; frame_profile.rs: Formats per-frame timing data into compact single-line strings for logging.; lua_callbacks.rs: Invokes named lurek.* Lua callbacks with error logging and optional timeout.; mod.rs: Orchestrates the Lurek2D application lifecycle from window creation through frame rendering.; splash_screen.rs: Decodes embedded splash icon and banner PNGs into temporary texture storage.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### app.rs

- Implements the central `LurekApp` runtime driven by winit's `ApplicationHandler`.
- Manages GPU surface creation, wgpu adapter/device selection, and surface reconfiguration.
- Orchestrates the frame loop: tick input, call Lua process/draw callbacks, then present.
- Handles window events (keyboard, mouse, touch, gamepad, drag-drop, resize, focus).
- Provides splash-screen and error-screen rendering paths when no game is loaded or a fatal occurs.
- Owns hot-reload watchers for conf.toml, Lua scripts, and asset files with automatic restart.
- Integrates gilrs for gamepad polling, force-feedback vibration, and axis/button callbacks.
- Performs viewport letterbox/stretch/pixel scaling and automatic screenshot capture.
- Boots the Lua VM, loads main.lua, fires `lurek.init()`, and enters the main game loop.
- Provides `App` bootstrap wrapper that initializes logging and launches the event loop.

### debug_overlay.rs

- Owns the lightweight debug HUD toggled by F12 or Lua.
- Renders FPS counter and draw-call counter in a semi-transparent box.
- Produces render commands only when the overlay is enabled and a font key is available.

### error_screen.rs

- Formats fatal Lua and engine errors into a user-facing screen.
- Splits message text and traceback, word-wraps long lines, and cleans Lua string markers.
- Builds full-screen render commands showing error title, body, traceback, and hint footer.
- Provides clipboard export text for quick copy of error details.

### frame_profile.rs

- Formats per-frame timing data into compact single-line strings for logging.
- Reads tick, update, render, and callback timings from `FrameProfile`.
- Output format: `tick=Xms update=Xms render=Xms cb=Xms` for tracing frame budget.

### lua_callbacks.rs

- Invokes named `lurek.*` Lua callbacks with error logging and optional timeout.
- Installs an instruction-count hook to abort runaway callbacks after a deadline.
- Provides checked and unchecked variants for both timed and untimed invocation.

### mod.rs

- Orchestrates the Lurek2D application lifecycle from window creation through frame rendering.
- Bridges winit events to Lua callbacks, GPU rendering, input polling, and hot-reload.
- Houses the error screen, debug overlay, splash screen, and frame profiling submodules.
- Provides Lua callback timeout wrappers used across the frame update path.

### splash_screen.rs

- Decodes embedded splash icon and banner PNGs into temporary texture storage.
- Builds render commands for the splash screen layout with centred branding.
- Shows a drag-and-drop hint that changes colour when a folder is hovered.
- Provides the `SplashBranding` struct used by the app loop until a game loads.

## Lua API Ref

- Binding: None direct
- Namespace: `lurek.input`

### Functions

- No documented module-level functions.

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
