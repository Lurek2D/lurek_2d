//! Implements guarded invocation of named `lurek.*` callbacks from engine-side runtime flow. `app/lua_callbacks` delivers the lua callbacks implementation for the app subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Provides checked and logging variants so callers choose explicit error propagation behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports optional timeout enforcement via instruction hooks to stop runaway callback execution. Public callable behavior is centered on `call_lua_callback`, `call_lua_callback_checked`, `has_lua_callback`, `call_lua_callback_with_timeout`, `call_lua_callback_checked_with_timeout`, and 1 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Serves as the callback safety boundary between frame orchestration and Lua script handlers. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use mlua::prelude::*;
use mlua::HookTriggers;
use std::time::{Duration, Instant};
/// Call `lurek.<name>(...)` and log failures to `error!` without returning them.
pub fn call_lua_callback<'a, A: IntoLuaMulti<'a>>(lua: &'a Lua, name: &str, args: A) {
    if let Err(e) = call_lua_callback_checked(lua, name, args) {
        log::error!("lurek.{}(): {}", name, e);
    }
}
/// Call `lurek.<name>(...)` and return any Lua error to the caller.
pub fn call_lua_callback_checked<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
) -> Result<(), mlua::Error> {
    call_lua_callback_checked_with_timeout(lua, name, args, None)
}

/// Return true when `lurek.<name>` exists and is callable in the active Lua VM.
pub fn has_lua_callback(lua: &Lua, name: &str) -> bool {
    if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {
        return lurek.get::<_, LuaFunction>(name).is_ok();
    }
    false
}
/// Call `lurek.<name>(...)` with optional timeout and log failures.
pub fn call_lua_callback_with_timeout<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
    timeout_ms: Option<f32>,
) {
    if let Err(e) = call_lua_callback_checked_with_timeout(lua, name, args, timeout_ms) {
        log::error!("lurek.{}(): {}", name, e);
    }
}
/// Call `lurek.<name>(...)` and optionally abort execution when callback exceeds `timeout_ms`.
pub fn call_lua_callback_checked_with_timeout<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
    timeout_ms: Option<f32>,
) -> Result<(), mlua::Error> {
    if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {
        if let Ok(func) = lurek.get::<_, LuaFunction>(name) {
            call_function_with_optional_timeout::<_, ()>(lua, name, func, args, timeout_ms)?;
        }
    }
    Ok(())
}
/// Call an already-resolved Lua function with optional timeout and return its value.
pub fn call_function_with_optional_timeout<'a, A, R>(
    lua: &'a Lua,
    name: &str,
    func: LuaFunction<'a>,
    args: A,
    timeout_ms: Option<f32>,
) -> Result<R, mlua::Error>
where
    A: IntoLuaMulti<'a>,
    R: FromLuaMulti<'a>,
{
    if let Some(ms) = timeout_ms.filter(|ms| *ms > 0.0) {
        return call_with_timeout(lua, name, func, args, ms);
    }
    func.call::<_, R>(args)
}
/// Execute one Lua callback with instruction-hook timeout guard.
fn call_with_timeout<'a, A, R>(
    lua: &'a Lua,
    name: &str,
    func: LuaFunction<'a>,
    args: A,
    timeout_ms: f32,
) -> Result<R, mlua::Error>
where
    A: IntoLuaMulti<'a>,
    R: FromLuaMulti<'a>,
{
    let timeout = Duration::from_secs_f64((timeout_ms as f64 / 1000.0).max(0.000_001));
    let deadline = Instant::now() + timeout;
    let callback_name = name.to_string();
    lua.set_hook(
        HookTriggers {
            on_calls: false,
            on_returns: false,
            every_line: false,
            every_nth_instruction: Some(20_000),
        },
        move |_, _| {
            if Instant::now() >= deadline {
                return Err(mlua::Error::RuntimeError(format!(
                    "lurek.{}() exceeded callback timeout ({:.2} ms)",
                    callback_name, timeout_ms
                )));
            }
            Ok(())
        },
    );
    let result = func.call::<_, R>(args);
    lua.remove_hook();
    result
}
