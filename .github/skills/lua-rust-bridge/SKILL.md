---
name: lua-rust-bridge
description: "Load this skill when implementing the Lua-Rust binding layer in Lurek2D: writing impl LuaUserData blocks, registering modules via mlua 0.9, converting types between Lua and Rust, handling errors across the boundary, or managing SharedState borrows in closures. Skip it for API surface design (use lua-api-design), general Lua scripting (use lua-scripting), or pure Rust domain logic (use rust-coding)."
---
# lua-rust-bridge

## Mission

Own the mlua 0.9 binding mechanics: impl LuaUserData, SharedState borrow patterns, type conversions, error propagation, and registration conventions.

## When To Load

- Writing a new src/lua_api/<module>_api.rs file
- Adding methods to an existing LuaUserData implementation
- Fixing borrow errors or type conversion failures at the Lua-Rust boundary
- Understanding how SharedState flows through closures

## When To Skip

- API naming and design -> use lua-api-design skill
- General Lua scripting -> use lua-scripting skill
- Pure Rust domain logic -> use rust-coding skill

## Domain Knowledge

**Thin Wrapper Rule:** src/lua_api/<module>_api.rs owns ALL impl LuaUserData and mlua imports. Domain modules under src/<module>/ stay pure Rust with zero mlua dependency. The bridge is a thin translation layer only.

**SharedState borrow pattern:** clone the Rc BEFORE moving into the closure. Inside the closure, borrow() for reads, borrow_mut() for writes. Never hold a borrow across a Lua callback invocation - drop it first, invoke the callback, then re-borrow.

**Registration conventions:** flat function body (no nested helpers), section comment separators between logical groups, state.clone() before each closure. Every registered function gets a /// @param/@return docstring block immediately above.

**Type conversions:** prefer lua.to_value()/lua.from_value() for complex types over manual field-by-field table iteration. For simple types, direct FromLua/IntoLua implementations suffice.

**Error handling:** always .map_err(LuaError::external)? to convert Rust errors to Lua errors. Never panic on bad Lua input - return a descriptive LuaError instead. Use mlua::Result<T> as the return type for all registered functions.

**Forbidden patterns:** lua.load() is forbidden except with // LUA-EVAL-JUSTIFIED comment. Never render inside a Lua closure - queue a RenderCommand instead. No business logic in the bridge - delegate to src/<module>/ functions.

**Callback storage:** store Lua callbacks as LuaRegistryKey (not LuaFunction). LuaFunction holds a borrow on the Lua state and cannot be stored across frames.

**Validate:** tools/validate/validate_lua_api.py checks all src/lua_api/ files against these conventions.

## Companion File Index

None - all guidance is inline.

## References

- src/lua_api/timer_api.rs - gold standard binding file
- src/lua_api/mod.rs - SharedState definition and module registration
- tools/validate/validate_lua_api.py - binding convention validator
