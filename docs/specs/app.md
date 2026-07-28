<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/app.md or source docstrings instead. -->

# app

## TL;DR

- Drives the main winit/wgpu frame loop and Lua VM execution.
- Dispatches platform events to safe, guarded engine callbacks.
- Renders startup splash layouts, fatal error screens, and debug HUDs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app`
- Binding: `src/lua_api/engine_api.rs`
- Namespace: `lurek.engine`
- Lua API surface: `13` functions, `3` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `app` module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application.
- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.
- It turns platform hosting into one stable application loop.
- Read this module as the final integration boundary where rendering, input, windowing, and Lua execution are coordinated into one recoverable runtime loop.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/app`
- Owning tier: `Edge/Integration`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/engine_api.rs`
- Referenced engine modules: `event`, `filesystem`, `font`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, `raycaster`, `render`, `runtime`, `sprite`, `tilemap`, `window`

## Imports

- `event`: Imports or references `src/event/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `font`: Imports or references `src/font/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `light`: Imports or references `src/light/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `lua_api`: Imports or references `src/lua_api/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `parallax`: Imports or references `src/parallax/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `raycaster`: Imports or references `src/raycaster/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `sprite`: Imports or references `src/sprite/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `window`: Imports or references `src/window/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.

## Source Files

### app/gamepad.rs

- Owns the app app gamepad implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app app gamepad data is validated, transformed, or stored before neighboring systems consume it.
- Separates app app gamepad behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing app app gamepad defaults, lifecycle handling, validation, or data ownership rules.

### app/main_loop.rs

- Owns the app app main loop implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app app main loop data is validated, transformed, or stored before neighboring systems consume it.
- Separates app app main loop behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing app app main loop defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near app app main loop state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping app app main loop calculations explicit at their owning subsystem boundary.
- Provides local adaptation layer that lets callers reuse app app main loop rules without duplicating engine decisions.
- Open this owner before sibling files when a regression centers on app app main loop state, helpers, or rules.
- Works with neighboring app owners while keeping the main app app main loop responsibility anchored in one file.
- Changes to app app main loop names, caches, or helper boundaries should usually stay coupled inside this owner.
- This file is the right stop for maintainers tracing app app main loop regressions back to their concrete owner boundary.

### app/runner.rs

- Owns the app app runner implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app app runner data is validated, transformed, or stored before neighboring systems consume it.
- Separates app app runner behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing app app runner defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the app app runner state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping app app runner calculations explicit at their owning subsystem boundary.
- Provides the local adaptation layer that lets callers reuse app app runner rules without duplicating engine decisions.

### app/screens.rs

- Owns the app app screens implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app app screens data is validated, transformed, or stored before neighboring systems consume it.
- Separates app app screens behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing app app screens defaults, lifecycle handling, validation, or data ownership rules.

### app.rs

- Owns the app app implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app app data is validated, transformed, or stored before neighboring systems consume it.
- Separates app app behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing app app defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the app app state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping app app calculations explicit at their owning subsystem boundary.
- Provides the local adaptation layer that lets callers reuse app app rules without duplicating engine decisions.
- Open this owner before sibling files when a regression centers on app app state, helpers, or integration rules.

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

- Owns the lua callbacks owner for the app subsystem and keeps its rules local to this file.
- Keeps app data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how lua callbacks data is validated, transformed, or stored before neighboring systems use it.
- Owns app behavior with explicit state, validation, and crate-local integration boundaries.

### mod.rs

- This module re-exports the desktop app subsystem for runtime orchestration, splash, errors, callbacks, and HUD state.
- It is the navigation map for host-loop ownership, startup surfaces, callback guards, and frame-profile helpers.
- `app.rs` owns the main runtime loop, while `splash_screen.rs` and `error_screen.rs` cover startup and failure surfaces.
- `lua_callbacks.rs` holds guarded `lurek.*` invocation helpers, and `debug_overlay.rs` renders the diagnostics HUD.
- `frame_profile.rs` formats per-frame timing samples for logs, traces, and other small diagnostics surfaces.
- Change this file when public app exports move; change sibling files when runtime behavior or startup flows change.

### splash_screen.rs

- Owns the app splash screen implementation for the app subsystem and keeps related runtime rules local here.
- Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
- Defines how app splash screen data is validated, transformed, or stored before neighboring systems consume it.
- Separates app splash screen behavior from Lua bindings, tests, and sibling owners so integration stays readable.

## Callbacks

- `lurek.draw() -> nil`: Called every frame to queue world render commands.
- `lurek.draw_ui() -> nil`: Called every frame after world drawing to queue UI and HUD render commands.
- `lurek.exit() -> nil`: Called before the runtime exits after an explicit close path.
- `lurek.fixedUpdate(dt) -> nil`: Deprecated fixed-step update callback; use `lurek.process_physics(dt)`.
- `lurek.focus(focused) -> nil`: Called when the application window gains or loses focus.
- `lurek.gamepadaxis(id, axis, value) -> nil`: Called when a connected gamepad axis changes.
- `lurek.gamepadconnected(id) -> nil`: Called when a gamepad connects.
- `lurek.gamepaddisconnected(id) -> nil`: Called when a gamepad disconnects.
- `lurek.gamepadpressed(id, button) -> nil`: Called when a gamepad button is pressed.
- `lurek.gamepadreleased(id, button) -> nil`: Called when a gamepad button is released.
- `lurek.init() -> nil`: Called once after the Lua VM, shared state, and `lurek.*` modules are ready.
- `lurek.joystickadded(id) -> nil`: Compatibility callback called when a gamepad connects.
- `lurek.joystickremoved(id) -> nil`: Compatibility callback called when a gamepad disconnects.
- `lurek.keypressed(key, scancode, isrepeat) -> nil`: Called when a keyboard key is pressed and UI did not consume it.
- `lurek.keyreleased(key, scancode) -> nil`: Called when a keyboard key is released.
- `lurek.mousemoved(x, y, dx, dy) -> nil`: Called when the pointer moves in game coordinates and UI did not consume it.
- `lurek.mousepressed(x, y, button, clicks) -> nil`: Called when a mouse button is pressed and UI did not consume it.
- `lurek.mousereleased(x, y, button, clicks) -> nil`: Called when a mouse button is released and UI did not consume it.
- `lurek.process(dt) -> nil`: Called every frame for game logic.
- `lurek.process_late(dt) -> nil`: Called every frame after `process` and fixed-step physics callbacks.
- `lurek.process_physics(dt) -> nil`: Called at the fixed timestep zero or more times per rendered frame.
- `lurek.ready() -> nil`: Called once after startup when the first frame resources are ready.
- `lurek.resize(width, height) -> nil`: Called after the renderer and viewport are resized.
- `lurek.textinput(text) -> nil`: Called when committed text input arrives and UI did not consume it.
- `lurek.touchmoved(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point moves.
- `lurek.touchpressed(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point starts.
- `lurek.touchreleased(id, x, y, dx, dy, pressure) -> nil`: Called when a touch point ends or is cancelled.
- `lurek.visible(visible) -> nil`: Called when the window occlusion/visibility state changes.
- `lurek.wheelmoved(dx, dy) -> nil`: Called when mouse-wheel input arrives and UI did not consume it.



## Lua API Ref

### Functions

- `lurek.engine.fps() -> number`: Returns the latest frames-per-second value stored by the runtime.
- `lurek.engine.frameCount() -> integer`: Returns the number of frames counted by the shared runtime clock.
- `lurek.engine.getConfigRevision() -> integer`: Returns the configuration reload revision counter.
- `lurek.engine.getFrameBudget() -> number`: Returns the target frame budget for a 60 FPS update loop.
- `lurek.engine.getFrameProfile() -> table`: Returns the latest frame timing profile split by engine phase.
- `lurek.engine.getFrameProfileText() -> string`: Returns the latest frame timing profile formatted as one text line.
- `lurek.engine.getResourceStats() -> table`: Returns current resource memory usage and object counts by resource kind.
- `lurek.engine.getVersion() -> string`: Returns the engine crate version string embedded at build time.
- `lurek.engine.isDebug() -> boolean`: Returns whether the engine binary was built with debug assertions.
- `lurek.engine.memoryUsage() -> table`: Returns Lua VM memory usage as bytes and rounded kilobytes.
- `lurek.engine.platform() -> string`: Returns the current desktop operating system name.
- `lurek.engine.setResourceBudget(budget_bytes) -> nil`: Sets the hard resource budget used by public resource allocation and reporting.
- `lurek.engine.uptime() -> number`: Returns total engine runtime accumulated by the main loop.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LEngineGetFrameProfileResult Type

- Generated result shape from @field tags.

##### Fields

- `app_frame_total_ms` (`number`): App frame total ms.
- `app_render_ms` (`number`): App render ms.
- `app_tick_ms` (`number`): App tick ms.
- `app_update_ms` (`number`): App update ms.
- `callback_total_ms` (`number`): Callback total ms.
- `draw_ms` (`number`): Draw ms.
- `draw_ui_ms` (`number`): Draw ui ms.
- `fixed_update_ms` (`number`): Fixed update ms.
- `process_late_ms` (`number`): Process late ms.
- `process_ms` (`number`): Process ms.
- `process_physics_ms` (`number`): Process physics ms.

##### Methods

- No documented methods.

#### LEngineGetResourceStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `app_frame_total_ms` (`number`): App frame total ms.
- `app_render_ms` (`number`): App render ms.
- `app_tick_ms` (`number`): App tick ms.
- `app_update_ms` (`number`): App update ms.
- `budget_bytes` (`integer`): Budget bytes.
- `callback_total_ms` (`number`): Callback total ms.
- `canvas_bytes` (`integer`): Canvas bytes.
- `canvas_count` (`integer`): Canvas count.
- `draw_ms` (`number`): Draw ms.
- `draw_ui_ms` (`number`): Draw ui ms.
- `fixed_update_ms` (`number`): Fixed update ms.
- `font_bytes` (`integer`): Font bytes.
- `font_count` (`integer`): Font count.
- `process_late_ms` (`number`): Process late ms.
- `process_ms` (`number`): Process ms.
- `process_physics_ms` (`number`): Process physics ms.
- `shader_bytes` (`integer`): Shader bytes.
- `shader_count` (`integer`): Shader count.
- `texture_bytes` (`integer`): Texture bytes.
- `texture_count` (`integer`): Texture count.
- `total_bytes` (`integer`): Total bytes.

##### Methods

- No documented methods.

#### LEngineMemoryUsageResult Type

- Generated result shape from @field tags.

##### Fields

- `lua_bytes` (`integer`): Lua bytes.
- `lua_kb` (`number`): Lua kb.

##### Methods

- No documented methods.

## Examples

- `content/examples/engine.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
