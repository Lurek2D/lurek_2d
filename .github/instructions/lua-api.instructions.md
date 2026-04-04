---
applyTo: "src/lua_api/**"
---

# Lua API Instructions

All files in `src/lua_api/` bind Rust engine state to the `luna.*` Lua namespace. Every binding must use the `register()` pattern, capture `Rc<RefCell<SharedState>>`, and never perform rendering inside a Lua closure.

## Core Rules

- **`luna.*` namespace only** — never external engine prefixes, `game.*`, or any other prefix
- **Registration pattern**: every file must expose `pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()>`
- **Clone the Rc before moving into closure**: `let s = state.clone(); lua.create_function(move |_, args| { let st = s.borrow(); ... })`
- **Return `LuaResult<T>`** from all Lua-callable functions — never panic inside a Lua closure
- **No rendering inside Lua closures** — push a `DrawCommand` variant to `state.borrow_mut().draw_commands` and return; the engine renders after `luna.draw()` returns
- **String keys lowercase**: `"space"`, `"escape"`, `"a"`, `"left"` — never uppercase, never platform-specific names

## Conditional Module Registration

`create_lua_vm()` in `src/lua_api/mod.rs` receives `modules: &ModulesConfig` as its second argument.
Three API files are **always** registered regardless of config: `math_api`, `log_api`, `event_api`.
All other 38 API files are guarded by their corresponding flag.

### Registration guard pattern

```rust
// Always registered (no guard)
math_api::register(&lua, &luna)?;
log_api::register(&lua, &luna)?;
event_api::register(&lua, &luna, state.clone())?;

// Guarded — disabled module means its luna.* table is absent (nil), not a stub
if modules.graphics {
    graphics_api::register(&lua, &luna, state.clone())?;
    font_api::register(&lua, &luna, state.clone())?;
    sprite_api::register(&lua, &luna)?;
}
if modules.audio    { audio_api::register(&lua, &luna, state.clone())?; }
if modules.input    { input_api::register(&lua, &luna, state.clone())?; }
if modules.physics  { physics_api::register(&lua, &luna)?; }
// ... one block per ModulesConfig flag
```

### API-to-flag mapping (all 41 API files)

| Flag | API files registered under this flag |
|---|---|
| always | math_api, log_api, event_api |
| `window` | window_api |
| `graphics` | graphics_api, font_api, sprite_api |
| `audio` | audio_api |
| `input` | input_api |
| `physics` | physics_api |
| `filesystem` | filesystem_api |
| `timer` | timer_api |
| `particle` | particle_api |
| `image` | image_api |
| `gui` | gui_api |
| `overlay` | overlay_api, postfx_api |
| `tilemap` | tilemap_api |
| `scene` | scene_api |
| `savegame` | savegame_api |
| `entity` | entity_api |
| `ai` | ai_api, steering_api |
| `pathfinding` | pathfinding_api |
| `thread` | thread_api |
| `graph` | graph_api |
| `data` | data_api, serial_api |
| `compute` | compute_api, dataframe_api |
| `minimap` | minimap_api |
| `modding` | modding_api |
| `pipeline` | pipeline_api, patterns_api |
| `system` | system_api |
| `localization` | localization_api |
| `debug` | debug_api, debugbridge_api, docs_api, automation_api |

See `engine.instructions.md` for dependency constraints (e.g. graphics → window).

## Layer / Boundary Rules

- `lua_api/mod.rs` owns `SharedState` struct definition and `create_lua_vm()` — no other file defines state
- Sub-API files (`graphics_api.rs`, `audio_api.rs`, etc.) must only import from `crate::graphics`, `crate::physics`, etc. — never cross-import between sub-API files
- Physics worlds stored separately from `SharedState` — use `Rc<RefCell<Vec<World>>>` passed alongside state

## Compliance

- Every new `luna.*` function must be documented in `docs/lua_api_reference.md`
- Key names must match the mapping in `src/input/keyboard.rs::key_to_string()`
- All mouse button indices: 1 = left, 2 = right, 3 = middle

## Avoid

- `.unwrap()` on `state.borrow()` — use `?` or handle the `BorrowError`
- Storing non-`Clone`/non-`'static` references in Lua closures
- Direct winit or wgpu API calls inside `lua_api/` — go through the engine abstraction
- Exposing internal engine types directly to Lua — wrap in safe userdata or return primitives
- Creating a new `Rc<RefCell<>>` for state that already exists in `SharedState`
