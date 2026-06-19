//! This file owns shared Lua execution policy used by GUI app, headless runs, and other host-side callers.
//! `LuaExecutionPolicy` centralizes callback timeout configuration and instruction-hook cadence.
//! The helper executes already-resolved Lua functions and removes timeout hooks with RAII cleanup.
//! Keeping this logic in runtime avoids diverging timeout semantics between GUI and headless hosts.
//! Open it when Lua callback timeout policy or hook cleanup behavior changes.

use mlua::prelude::*;
use mlua::HookTriggers;
use std::time::{Duration, Instant};

/// Shared execution policy for guarded host-side Lua calls.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LuaExecutionPolicy {
    /// Optional per-callback timeout in milliseconds.
    pub timeout_ms: Option<f32>,
    /// Instruction interval used by the timeout hook.
    pub hook_instruction_interval: u32,
}

impl LuaExecutionPolicy {
    /// Construct a policy with the default hook cadence and optional timeout.
    pub fn with_timeout(timeout_ms: Option<f32>) -> Self {
        Self {
            timeout_ms,
            ..Self::default()
        }
    }
}

impl Default for LuaExecutionPolicy {
    /// Create a policy with no timeout and the default instruction cadence.
    fn default() -> Self {
        Self {
            timeout_ms: None,
            hook_instruction_interval: 20_000,
        }
    }
}

/// Call a resolved Lua function under the given execution policy.
pub fn call_function_with_policy<'lua, Args, Return>(
    lua: &'lua Lua,
    name: &str,
    function: LuaFunction<'lua>,
    args: Args,
    policy: LuaExecutionPolicy,
) -> LuaResult<Return>
where
    Args: IntoLuaMulti<'lua>,
    Return: FromLuaMulti<'lua>,
{
    if let Some(timeout_ms) = policy.timeout_ms.filter(|value| *value > 0.0) {
        return call_with_timeout(lua, name, function, args, timeout_ms, policy);
    }
    function.call::<_, Return>(args)
}

struct LuaHookGuard<'lua> {
    lua: &'lua Lua,
}

impl Drop for LuaHookGuard<'_> {
    fn drop(&mut self) {
        self.lua.remove_hook();
    }
}

fn call_with_timeout<'lua, Args, Return>(
    lua: &'lua Lua,
    name: &str,
    function: LuaFunction<'lua>,
    args: Args,
    timeout_ms: f32,
    policy: LuaExecutionPolicy,
) -> LuaResult<Return>
where
    Args: IntoLuaMulti<'lua>,
    Return: FromLuaMulti<'lua>,
{
    let timeout = Duration::from_secs_f64((timeout_ms as f64 / 1000.0).max(0.000_001));
    let deadline = Instant::now() + timeout;
    let callback_name = name.to_string();
    lua.set_hook(
        HookTriggers {
            on_calls: false,
            on_returns: false,
            every_line: false,
            every_nth_instruction: Some(policy.hook_instruction_interval.max(1)),
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
    let _guard = LuaHookGuard { lua };
    function.call::<_, Return>(args)
}
