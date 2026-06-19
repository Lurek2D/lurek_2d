//! This file owns no-window runtime execution for automation, tests, eval snippets, and batch Lua workflows.
//! `HeadlessOptions` captures inputs, while the main entry points map engine errors to process-oriented outcomes.
//! Startup wiring creates shared state, headless Lua VM bindings, package paths, and stdout-backed `print` behavior.
//! Frame stepping calls the usual lurek callbacks with configured dt and optional callback timeout enforcement.
//! Timeout helpers own hook-based abort logic so runaway Lua code fails cleanly during unattended execution.
//! Open it when non-GUI runtime flow changes; config, modes, and shared state contracts live in sibling files.

use crate::lua_api::create_headless_vm;
use crate::repl::value_to_string;
use crate::runtime::{
    call_function_with_policy, Config, EngineError, EngineResult, LuaExecutionPolicy, SharedState,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::rc::Rc;

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
            log::error!("{}", error);
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
            let mut stdout = io::stdout().lock();
            writeln!(stdout, "{}", parts.join("\t"))
                .map_err(|error| LuaError::RuntimeError(format!("headless print: {}", error)))?;
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
    let result = call_function_with_policy(
        lua,
        name,
        function,
        args,
        LuaExecutionPolicy::with_timeout(timeout_ms),
    );
    result.map_err(|error| EngineError::LuaError(format!("lurek.{}: {}", name, error)))
}
