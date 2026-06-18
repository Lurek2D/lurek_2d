//! This file owns guarded `lurek.*` callback invocation helpers used by the desktop app runtime and UI bridges.
//! It exposes logging and checked variants, probes callback presence, and resolves functions from the active Lua VM.
//! Optional timeout wrappers install instruction hooks so runaway callbacks abort with a named runtime error.
//! The file is the safety boundary between host events and Lua execution, keeping timeout policy in one owner.
//! Open it when callback guard semantics change; frame orchestration and input dispatch live in sibling modules.

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
