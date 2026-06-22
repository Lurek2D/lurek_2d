//! This file owns shared Lua execution policy used by GUI app, headless runs, and other host-side callers.
//! `LuaExecutionPolicy` centralizes callback timeout configuration and instruction-hook cadence.
//! The helper executes already-resolved Lua functions and removes timeout hooks with RAII cleanup.
//! Keeping this logic in runtime avoids diverging timeout semantics between GUI and headless hosts.
//! Open it when Lua callback timeout policy or hook cleanup behavior changes.

use mlua::prelude::*;
use mlua::HookTriggers;
use std::time::{Duration, Instant};

/// Upper bound applied to configured Lua execution timeouts.
pub const MAX_LUA_EXECUTION_TIMEOUT_MS: f32 = 300_000.0;

const LUA_TIMEOUT_MARKER: &str = "exceeded Lua execution timeout";

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

    /// Normalize the configured timeout to a finite positive value when present.
    pub fn normalized_timeout_ms(self) -> Option<f32> {
        self.timeout_ms
            .filter(|value| value.is_finite() && *value > 0.0)
            .map(|value| value.min(MAX_LUA_EXECUTION_TIMEOUT_MS))
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
    if let Some(timeout_ms) = policy.normalized_timeout_ms() {
        return with_timeout(
            lua,
            &format!("lurek.{}()", name),
            timeout_ms,
            policy,
            || function.call::<_, Return>(args),
        );
    }
    function.call::<_, Return>(args)
}

/// Evaluate a Lua expression or chunk under the shared execution policy.
pub fn eval_chunk_with_policy<'lua, Return>(
    lua: &'lua Lua,
    label: &str,
    code: &str,
    policy: LuaExecutionPolicy,
) -> LuaResult<Return>
where
    Return: FromLuaMulti<'lua>,
{
    if let Some(timeout_ms) = policy.normalized_timeout_ms() {
        return with_timeout(lua, label, timeout_ms, policy, || {
            lua.load(code).set_name(label).eval::<Return>()
        });
    }
    lua.load(code).set_name(label).eval::<Return>()
}

/// Execute a Lua chunk under the shared execution policy.
pub fn exec_chunk_with_policy(
    lua: &Lua,
    label: &str,
    code: &str,
    policy: LuaExecutionPolicy,
) -> LuaResult<()> {
    if let Some(timeout_ms) = policy.normalized_timeout_ms() {
        return with_timeout(lua, label, timeout_ms, policy, || {
            lua.load(code).set_name(label).exec()
        });
    }
    lua.load(code).set_name(label).exec()
}

/// Return `true` when the supplied error came from the shared timeout hook.
pub fn is_lua_timeout_error(error: &LuaError) -> bool {
    match error {
        LuaError::CallbackError { cause, .. } => is_lua_timeout_error(cause),
        LuaError::WithContext { cause, .. } => is_lua_timeout_error(cause),
        other => other.to_string().contains(LUA_TIMEOUT_MARKER),
    }
}

struct LuaHookGuard<'lua> {
    lua: &'lua Lua,
}

impl Drop for LuaHookGuard<'_> {
    fn drop(&mut self) {
        self.lua.remove_hook();
    }
}

struct LuaJitGuard<'lua> {
    lua: &'lua Lua,
}

impl LuaJitGuard<'_> {
    fn new<'lua>(lua: &'lua Lua) -> LuaJitGuard<'lua> {
        set_luajit_enabled(lua, false);
        LuaJitGuard { lua }
    }
}

impl Drop for LuaJitGuard<'_> {
    fn drop(&mut self) {
        set_luajit_enabled(self.lua, true);
    }
}

fn with_timeout<Return>(
    lua: &Lua,
    label: &str,
    timeout_ms: f32,
    policy: LuaExecutionPolicy,
    run: impl FnOnce() -> LuaResult<Return>,
) -> LuaResult<Return> {
    let timeout = Duration::from_secs_f64((timeout_ms as f64 / 1000.0).max(0.000_001));
    let deadline = Instant::now() + timeout;
    let timeout_label = label.to_string();
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
                    "{} {} ({:.2} ms)",
                    timeout_label, LUA_TIMEOUT_MARKER, timeout_ms
                )));
            }
            Ok(())
        },
    );
    let _guard = LuaHookGuard { lua };
    let _jit_guard = LuaJitGuard::new(lua);
    run()
}

fn set_luajit_enabled(lua: &Lua, enabled: bool) {
    let Ok(jit) = lua.globals().get::<_, LuaTable>("jit") else {
        return;
    };
    let method = if enabled { "on" } else { "off" };
    let Ok(function) = jit.get::<_, LuaFunction>(method) else {
        return;
    };
    let _ = function.call::<_, ()>(());
}
