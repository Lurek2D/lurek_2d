---
applyTo: "src/engine/**"
---

# Engine Module Instructions

`src/engine/` is the top-level orchestrator. It owns the `App` struct, the main game loop, `Config`, and `EngineError`. This is the only module allowed to import from all other modules simultaneously.

## Core Rules

- **`App::run()` is the sole game loop** — all coordination (Window creation, GpuRenderer, Clock, SharedState, Lua VM) happens here; no other module may create a winit `Window`
- **SharedState lives here conceptually but is defined in `lua_api/mod.rs`** — `app.rs` creates it and passes `Rc<RefCell<SharedState>>` to `create_lua_vm()`
- **Callback pattern**: call `luna.load()` once; call `luna.update(dt)` and `luna.draw()` every frame. All callbacks are optional — check if the function exists before calling
- **Splash screen**: when no game directory is given, push `DrawCommand`s for the Luna2D splash screen rather than loading a Lua script
- **Frame timing**: use `Clock::tick()` at the top of the loop; delta time is `f64` seconds

## Layer / Boundary Rules

- `engine/` is the only module that may import from all other modules
- `engine/error.rs` defines `EngineError` — all modules surface their errors via this type or `String`
- `engine/config.rs` owns window dimensions, title, vsync, FPS target — no hardcoded literals in `app.rs`
- Never import winit types outside `engine/app.rs` and `src/window/`

## Compliance

- `EngineError` variants must cover: `Init`, `Render`, `Input`, `Audio`, `Physics`, `FileSystem`, `Lua`
- Game loop order per frame: tick clock → update input → fire event callbacks → `luna.update(dt)` → clear draw commands → `renderer.clear()` → `luna.draw()` → `execute_commands()` → `update_with_buffer()`
- Frame pacing handled by wgpu present mode — do not implement manual sleep-based frame limiting

## Module Toggle System

`Config::modules` (`ModulesConfig` in `src/engine/config.rs`) holds one bool per optional subsystem.
These flags are parsed from `conf.lua` (`t.modules.*`) but currently **not enforced** — enforcement
is an open implementation task. When implementing:

- Pass `&config.modules` to `create_lua_vm()` as a second argument
- See `src/lua_api/mod.rs` for which APIs to guard under which flag (documented in the module-toggle-research report)
- Call `modules.validate_and_fix()` before passing to `create_lua_vm()` — fixes dependency violations with `log::warn!`
- After enforcement, a disabled module means its `luna.*` table is **absent** (nil) — not a stub

### Dependency constraints (enforce in `ModulesConfig::validate_and_fix()`)

| If flag is true | Then this flag must also be true |
|---|---|
| `graphics` | `window` |
| `particle` | `graphics` (+ `window`) |
| `gui` | `graphics` (+ `window`) |
| `overlay` | `graphics` (+ `window`) |
| `savegame` | `filesystem` |
| `modding` | `filesystem` |

### Mandatory modules (always registered, no flag)

`math_api`, `log_api`, `event_api` — register unconditionally regardless of `ModulesConfig`.

### Full conf.lua module flag reference (27 flags)

| conf.lua key | Covers lua_api files | Lua namespaces |
|---|---|---|
| `t.modules.window` | window_api | `luna.window.*` |
| `t.modules.graphics` | graphics_api, font_api, sprite_api | `luna.graphics.*, luna.font.*, luna.sprite.*` |
| `t.modules.audio` | audio_api | `luna.audio.*` |
| `t.modules.input` | input_api | `luna.input.*` |
| `t.modules.physics` | physics_api | `luna.physics.*` |
| `t.modules.filesystem` | filesystem_api | `luna.filesystem.*` |
| `t.modules.timer` | timer_api | `luna.timer.*` |
| `t.modules.particle` | particle_api | `luna.particle.*` |
| `t.modules.image` | image_api | `luna.image.*` |
| `t.modules.gui` | gui_api | `luna.gui.*` |
| `t.modules.overlay` | overlay_api, postfx_api | `luna.overlay.*, luna.postfx.*` |
| `t.modules.tilemap` | tilemap_api | `luna.tilemap.*` |
| `t.modules.scene` | scene_api | `luna.scene.*` |
| `t.modules.savegame` | savegame_api | `luna.savegame.*` |
| `t.modules.entity` | entity_api | `luna.entity.*` |
| `t.modules.ai` | ai_api, steering_api | `luna.ai.*, luna.steering.*` |
| `t.modules.pathfinding` | pathfinding_api | `luna.pathfinding.*` |
| `t.modules.thread` | thread_api | `luna.thread.*` |
| `t.modules.graph` | graph_api | `luna.graph.*` |
| `t.modules.data` | data_api, serial_api | `luna.data.*, luna.serial.*` |
| `t.modules.compute` | compute_api, dataframe_api | `luna.compute.*, luna.dataframe.*` |
| `t.modules.minimap` | minimap_api | `luna.minimap.*` |
| `t.modules.modding` | modding_api | `luna.modding.*` |
| `t.modules.pipeline` | pipeline_api, patterns_api | `luna.pipeline.*, luna.patterns.*` |
| `t.modules.system` | system_api | `luna.system.*` |
| `t.modules.localization` | localization_api | `luna.localization.*` |
| `t.modules.debug` | debug_api, debugbridge_api, docs_api, automation_api | `luna.debug.*, luna.debugbridge.*, luna.docs.*, luna.automation.*` |

`debug` defaults to `cfg!(debug_assertions)` — true in dev builds, false in release.

## Avoid

- Hardcoded window dimensions or titles — use `Config`
- Direct wgpu imports in `app.rs` — go through `GpuRenderer`
- Calling raw winit key events outside `engine/app.rs` — route through `KeyboardState`
- Blocking the game loop with file I/O — use `GameFS` which sandboxes I/O
- Parsing CLI arguments anywhere other than `src/main.rs`
