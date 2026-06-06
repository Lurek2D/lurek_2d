---
inclusion: manual
---

# lua-rust-bridge

## Mission
Own binding-layer mechanics between Lua and Rust.

## When To Use
- Writing or reviewing `LuaUserData` code.
- Converting values across the Lua boundary.
- Handling boundary errors.
- Checking SharedState borrow behavior in closures.

## When To Skip
- Public API design, Lua game script work, pure Rust domain logic.

## Rules

### Thin Wrapper Rule (Hard Constraint)
`src/lua_api/*_api.rs` contains only `LuaUserData` impls, `add_methods`, module registration, and type conversions. When a binding file contains `if/match/for` logic beyond conversion, the logic must move to `src/<module>/`. A binding function exceeding ~20 lines is almost certainly doing too much.

### UserData Types
- Must wrap a handle or an `Arc<>`-shared reference, not a raw struct. Raw structs bind Lua lifetimes to Rust lifetimes in ways mlua cannot enforce safely.

### Callback / Registry Key Pattern
- `lua.create_registry_value(callback)?` stores a `LuaFunction` for later use.
- Never let a borrowed `LuaFunction` escape the current call stack — it will dangle when the Lua state advances.

### Borrow Safety Rule
- Extract all fields from `RefCell<>` or `Arc<Mutex<>>` before invoking any Lua-callable function.
- Pattern: `let x = { state.borrow().field.clone() }; lua.call(x)?`
- The borrow must be fully dropped (scope closed) before the call.

### Type Conversion Checklist
For each boundary function:
1. Validate integer ranges before casting `i64` to `u32` or `usize`.
2. Validate string content when enum-like.
3. Clamp `f32`/`f64` values to meaningful game ranges at the boundary, not deep in the module.

### Error Type
- `mlua::Error::RuntimeError(msg)` is the standard error type for Lua-visible failures. Message must include `lurek.<module>.<function>` call site.
- `mlua::Error::ExternalError` is for non-displayable engine faults only.

### Registration Convention
- `pub fn register(lua: &Lua, state: &SharedState) -> mlua::Result<()>` — each `*_api.rs` exports exactly one `register` function, called from `src/lua_api/register.rs`.

### add_methods Rules
- `LuaUserData::add_methods` calls only `add_method`, `add_method_mut`, `add_function`, or `add_meta_method`. No side effects, no lazy-init, no global state changes inside `add_methods`.

### Validation
- After modifying a binding, run `python tools/validate/validate_lua_api.py`. It checks all registered functions have a docstring, argument names match documented types, and the generated stub stays in sync.

## References
- `src/lua_api/`
- `src/lua_api/mod.rs`
- `tools/validate/validate_lua_api.py`
- `docs/specs/lua-api-file-standard.md`
