//! Implements the no-window headless runtime path for script automation and CI use.
//!
//! - `HeadlessOptions` carries game directory, eval snippets, and an optional frame-count override.
//! - `run_headless` maps engine errors to process exit codes; `run_headless_checked` preserves structured errors for test callers.
//! - Init sequence installs a stdout-routed `print` global and prepends game-directory roots to `package.path`.
//! - Frame loop drives `process_physics`, `fixedUpdate`, `process`, and `process_late` in order; count and dt come from config or CLI flag.
//! - Callback timeout is enforced via Lua instruction-count hooks when a limit is configured in `PerformanceConfig`.

use crate::lua_api::create_headless_vm;
use crate::repl::value_to_string;
use crate::runtime::{Config, EngineError, EngineResult, SharedState};
use mlua::prelude::*;
use mlua::HookTriggers;
use std::cell::RefCell;
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::rc::Rc;
use std::time::{Duration, Instant};

#[derive(Debug, Clone)]
/// Inputs required to run the headless runtime once.
pub struct HeadlessOptions {
    /// Game directory used for `main.lua`, GameFS, and package path roots.
    pub game_dir: PathBuf,
    /// Whether the user supplied a game directory on the CLI.
    pub explicit_game_dir: bool,
    /// Lua snippets supplied through `--eval`.
    pub eval: Vec<String>,
    /// Optional frame-count override supplied through `--frames`.
    pub frames_override: Option<u32>,
}

/// Run the headless runtime and map engine errors to process exit status.
pub fn run_headless(config: Config, options: HeadlessOptions) -> ExitCode {
    match run_headless_checked(config, options) {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{}", error);
            ExitCode::FAILURE
        }
    }
}

/// Run the headless runtime and preserve structured engine errors for tests.
pub fn run_headless_checked(config: Config, options: HeadlessOptions) -> EngineResult<()> {
    crate::runtime::messages::init();
    let state = create_headless_state(&config, &options.game_dir);
    let lua = create_headless_vm(state.clone(), &config.modules)
        .map_err(|error| EngineError::LuaError(format!("headless VM init: {}", error)))?;
    install_stdout_print(&lua)?;
    install_game_package_path(&lua, &options.game_dir)?;
    load_main_if_present(&lua, &options)?;
    for code in &options.eval {
        lua.load(code)
            .set_name("--eval")
            .exec()
            .map_err(|error| EngineError::LuaError(format!("--eval: {}", error)))?;
    }
    let timeout_ms = config.performance.lua_callback_timeout_ms;
    call_lurek_callback(&lua, "init", (), timeout_ms)?;
    call_lurek_callback(&lua, "ready", (), timeout_ms)?;

    let frames = options
        .frames_override
        .or(config.headless.frames)
        .unwrap_or(0);
    let dt = config.headless.dt.max(0.0);
    for _ in 0..frames {
        {
            let mut shared = state.borrow_mut();
            shared.delta_time = dt;
            shared.total_time += dt;
            shared.frame_counter = shared.frame_counter.wrapping_add(1);
        }
        call_lurek_callback(&lua, "process_physics", dt, timeout_ms)?;
        call_lurek_callback(&lua, "fixedUpdate", dt, timeout_ms)?;
        call_lurek_callback(&lua, "process", dt, timeout_ms)?;
        call_lurek_callback(&lua, "process_late", dt, timeout_ms)?;
    }
    Ok(())
}

/// Build the initial `SharedState` for a headless run and configure physics tick rates.
fn create_headless_state(config: &Config, game_dir: &Path) -> Rc<RefCell<SharedState>> {
    let mut shared = SharedState::new(
        config.window.width,
        config.window.height,
        &config.window.title,
        game_dir.to_path_buf(),
    );
    if let Some(identity) = &config.identity {
        shared.filesystem_identity = identity.clone();
    }
    shared.physics_run.fixed_dt = 1.0 / config.performance.physics_tick_rate.max(1) as f64;
    shared.physics_run.fixed_update_dt = match config.performance.fixed_update_tick_rate {
        Some(rate) if rate > 0 => 1.0 / rate as f64,
        _ => 0.0,
    };
    shared.frame_budget_warn_ms = config.performance.frame_budget_warn_ms;
    shared.lua_callback_timeout_ms = config.performance.lua_callback_timeout_ms;
    shared.runtime_mode = crate::runtime::RuntimeMode::Headless;
    Rc::new(RefCell::new(shared))
}

/// Replace the default Lua `print` global with a version that writes to stdout.
fn install_stdout_print(lua: &Lua) -> EngineResult<()> {
    let print = lua
        .create_function(|_, values: mlua::Variadic<mlua::Value>| {
            let parts: Vec<String> = values.iter().map(value_to_string).collect();
            println!("{}", parts.join("\t"));
            Ok(())
        })
        .map_err(|error| EngineError::LuaError(format!("headless print: {}", error)))?;
    lua.globals()
        .set("print", print)
        .map_err(|error| EngineError::LuaError(format!("headless print: {}", error)))
}

/// Prepend the game directory to `package.path` so `require` resolves game scripts.
fn install_game_package_path(lua: &Lua, game_dir: &Path) -> EngineResult<()> {
    let package: LuaTable = lua
        .globals()
        .get("package")
        .map_err(|error| EngineError::LuaError(format!("package.path: {}", error)))?;
    let old_path: String = package
        .get("path")
        .map_err(|error| EngineError::LuaError(format!("package.path: {}", error)))?;
    let root = game_dir.to_string_lossy().replace('\\', "/");
    let new_path = format!(
        "{};{}/?.lua;{}/?/init.lua;{}/content/?.lua;{}/content/?/init.lua",
        old_path, root, root, root, root
    );
    package
        .set("path", new_path)
        .map_err(|error| EngineError::LuaError(format!("package.path: {}", error)))
}

/// Load and execute `main.lua` when an explicit game directory was supplied.
fn load_main_if_present(lua: &Lua, options: &HeadlessOptions) -> EngineResult<()> {
    if !options.explicit_game_dir {
        return Ok(());
    }
    let main_lua = options.game_dir.join("main.lua");
    if !main_lua.exists() {
        return Ok(());
    }
    let code = std::fs::read_to_string(&main_lua).map_err(|error| {
        EngineError::FileSystemError(format!("failed to read main.lua: {}", error))
    })?;
    lua.load(&code)
        .set_name("main.lua")
        .exec()
        .map_err(|error| EngineError::LuaError(format!("main.lua: {}", error)))
}

/// Invoke a named `lurek.*` callback if it exists; skip silently when absent.
fn call_lurek_callback<'lua, Args>(
    lua: &'lua Lua,
    name: &str,
    args: Args,
    timeout_ms: Option<f32>,
) -> EngineResult<()>
where
    Args: IntoLuaMulti<'lua>,
{
    let globals = lua.globals();
    let Ok(lurek) = globals.get::<_, LuaTable>("lurek") else {
        return Ok(());
    };
    let Ok(function) = lurek.get::<_, LuaFunction>(name) else {
        return Ok(());
    };
    let result = if let Some(ms) = timeout_ms.filter(|value| *value > 0.0) {
        call_with_timeout(lua, name, function, args, ms)
    } else {
        function.call::<_, ()>(args)
    };
    result.map_err(|error| EngineError::LuaError(format!("lurek.{}: {}", name, error)))
}

/// Call a Lua function and abort it with an error if execution exceeds the timeout.
fn call_with_timeout<'lua, Args>(
    lua: &'lua Lua,
    name: &str,
    function: LuaFunction<'lua>,
    args: Args,
    timeout_ms: f32,
) -> LuaResult<()>
where
    Args: IntoLuaMulti<'lua>,
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
    let result = function.call::<_, ()>(args);
    lua.remove_hook();
    result
}
