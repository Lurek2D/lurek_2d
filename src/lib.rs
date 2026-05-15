#![allow(unused_doc_comments)]
#![allow(clippy::doc_lazy_continuation)]
//! Core Lurek2D crate modules and the top-level runtime entry point.

/// Exposes the AI subsystem module.
pub mod ai;
/// Exposes the animation subsystem module.
pub mod animation;
/// Exposes the application bootstrap and runtime loop module.
pub mod app;
/// Exposes the audio subsystem module.
pub mod audio;
#[cfg(feature = "automation-plugin")]
/// Exposes the automation subsystem module when the plugin is enabled.
pub mod automation;
/// Exposes the camera subsystem module.
pub mod camera;
/// Exposes the compute subsystem module.
pub mod compute;
/// Exposes the data utilities subsystem module.
pub mod data;
/// Exposes the dataframe subsystem module.
pub mod dataframe;
/// Exposes the debug bridge subsystem module.
pub mod debugbridge;
#[cfg(feature = "devtools-plugin")]
/// Exposes the developer tools subsystem module when the plugin is enabled.
pub mod devtools;
/// Exposes the runtime documentation subsystem module.
pub mod docs;
/// Exposes the ECS subsystem module.
pub mod ecs;
/// Exposes the visual effects subsystem module.
pub mod effect;
/// Exposes the event subsystem module.
pub mod event;
/// Exposes the filesystem subsystem module.
pub mod filesystem;
/// Exposes the globe subsystem module.
pub mod globe;
#[cfg(feature = "graph")]
/// Exposes the graph subsystem module when the feature is enabled.
pub mod graph;
/// Exposes the HTML subsystem module.
pub mod html;
/// Exposes the internationalization subsystem module.
pub mod i18n;
/// Exposes the image subsystem module.
pub mod image;
/// Exposes the input subsystem module.
pub mod input;
/// Exposes the lighting subsystem module.
pub mod light;
/// Exposes the structured logging subsystem module.
pub mod log;
/// Exposes the Lua API bridge subsystem module.
pub mod lua_api;
/// Exposes the math subsystem module.
pub mod math;
/// Exposes the minimap subsystem module.
pub mod minimap;
/// Exposes the mod management subsystem module.
pub mod mods;
/// Exposes the networking subsystem module.
pub mod network;
/// Exposes the parallax subsystem module.
pub mod parallax;
/// Exposes the particle subsystem module.
pub mod particle;
/// Exposes the pathfinding subsystem module.
pub mod pathfind;
/// Exposes the reusable patterns subsystem module.
pub mod patterns;
/// Exposes the physics subsystem module.
pub mod physics;
/// Exposes the pipeline subsystem module.
pub mod pipeline;
/// Exposes the procedural generation subsystem module.
pub mod procgen;
/// Exposes the province subsystem module.
pub mod province;
/// Exposes the raycaster subsystem module.
pub mod raycaster;
/// Exposes the rendering subsystem module.
pub mod render;
/// Exposes the release-safe Lua REPL subsystem module.
pub mod repl;
/// Exposes the core runtime subsystem module.
pub mod runtime;
/// Exposes the save subsystem module.
pub mod save;
/// Exposes the scene subsystem module.
pub mod scene;
/// Exposes the serialization subsystem module.
pub mod serial;
/// Exposes the spine animation subsystem module.
pub mod spine;
/// Exposes the sprite subsystem module.
pub mod sprite;
/// Exposes the terminal subsystem module.
pub mod terminal;
/// Exposes the threading subsystem module.
pub mod thread;
/// Exposes the tilemap subsystem module.
pub mod tilemap;
/// Exposes the timer subsystem module.
pub mod timer;
/// Exposes the tween subsystem module.
pub mod tween;
/// Exposes the UI subsystem module.
pub mod ui;
/// Exposes the window subsystem module.
pub mod window;

/// Starts the Lurek2D runtime using the current CLI arguments and active game path.
pub fn lurek_run() -> std::process::ExitCode {
    use app::App;
    use runtime::{Config, HeadlessOptions, RuntimeMode};
    use std::env;
    use std::process::ExitCode;
    std::panic::set_hook(Box::new(|info| {
        let payload = if let Some(s) = info.payload().downcast_ref::<&str>() {
            s.to_string()
        } else if let Some(s) = info.payload().downcast_ref::<String>() {
            s.clone()
        } else {
            "Unknown panic".to_string()
        };
        let location = info
            .location()
            .map(|l| format!(" at {}:{}:{}", l.file(), l.line(), l.column()))
            .unwrap_or_default();
        let msg = format!("Lurek2D panicked: {}{}", payload, location);
        log_msg!(
            error,
            crate::runtime::log_messages::L060_LUA_CALLBACK_ERROR,
            "{}",
            msg
        );
        #[cfg(target_os = "windows")]
        {
            let is_screenshot_mode = std::env::args().any(|a| a.starts_with("--screenshot"));
            if !is_screenshot_mode {
                show_windows_error_box(&msg);
            }
        }
        eprintln!("{}", msg);
        std::process::exit(1);
    }));
    let mut screenshot_path: Option<std::path::PathBuf> = None;
    let mut screenshot_frames: u32 = 3;
    let mut screenshot_time: Option<f32> = None;
    let mut window_x: Option<i32> = None;
    let mut window_y: Option<i32> = None;
    let mut window_width: Option<u32> = None;
    let mut window_height: Option<u32> = None;
    let mut mode_override: Option<RuntimeMode> = None;
    let mut eval: Vec<String> = Vec::new();
    let mut frames_override: Option<u32> = None;
    let mut game_arg: Option<String> = None;
    let mut parse_error: Option<String> = None;
    let mut args = env::args().skip(1);
    while let Some(arg) = args.next() {
        if let Some(val) = arg.strip_prefix("--screenshot=") {
            screenshot_path = Some(std::path::PathBuf::from(val));
        } else if let Some(val) = arg.strip_prefix("--screenshot-frames=") {
            if let Ok(n) = val.parse::<u32>() {
                screenshot_frames = n;
            }
        } else if let Some(val) = arg.strip_prefix("--screenshot-time=") {
            if let Ok(s) = val.parse::<f32>() {
                screenshot_time = Some(s);
            }
        } else if let Some(val) = arg.strip_prefix("--window-x=") {
            if let Ok(n) = val.parse::<i32>() {
                window_x = Some(n);
            }
        } else if let Some(val) = arg.strip_prefix("--window-y=") {
            if let Ok(n) = val.parse::<i32>() {
                window_y = Some(n);
            }
        } else if let Some(val) = arg.strip_prefix("--window-width=") {
            if let Ok(n) = val.parse::<u32>() {
                window_width = Some(n);
            }
        } else if let Some(val) = arg.strip_prefix("--window-height=") {
            if let Ok(n) = val.parse::<u32>() {
                window_height = Some(n);
            }
        } else if let Some(val) = arg.strip_prefix("--mode=") {
            match val.parse::<RuntimeMode>() {
                Ok(mode) => mode_override = Some(mode),
                Err(error) => parse_error = Some(error.to_string()),
            }
        } else if arg == "--mode" {
            match args.next() {
                Some(value) => match value.parse::<RuntimeMode>() {
                    Ok(mode) => mode_override = Some(mode),
                    Err(error) => parse_error = Some(error.to_string()),
                },
                None => {
                    parse_error = Some("--mode requires gui, tui, headless, or cli".to_string())
                }
            }
        } else if arg == "--gui" {
            mode_override = Some(RuntimeMode::Gui);
        } else if arg == "--tui" {
            mode_override = Some(RuntimeMode::Tui);
        } else if arg == "--headless" {
            mode_override = Some(RuntimeMode::Headless);
        } else if arg == "--cli" {
            mode_override = Some(RuntimeMode::Cli);
        } else if let Some(value) = arg.strip_prefix("--eval=") {
            eval.push(value.to_string());
        } else if arg == "--eval" {
            match args.next() {
                Some(value) => eval.push(value),
                None => parse_error = Some("--eval requires Lua source code".to_string()),
            }
        } else if let Some(value) = arg.strip_prefix("--frames=") {
            match value.parse::<u32>() {
                Ok(frames) => frames_override = Some(frames),
                Err(_) => parse_error = Some(format!("invalid --frames value '{}'", value)),
            }
        } else if arg == "--frames" {
            match args.next() {
                Some(value) => match value.parse::<u32>() {
                    Ok(frames) => frames_override = Some(frames),
                    Err(_) => parse_error = Some(format!("invalid --frames value '{}'", value)),
                },
                None => parse_error = Some("--frames requires an integer value".to_string()),
            }
        } else if !arg.starts_with("--") {
            game_arg = Some(arg);
        }
    }
    if let Some(error) = parse_error {
        eprintln!("{}", error);
        return ExitCode::FAILURE;
    }
    let explicit_game_dir = game_arg.is_some();
    let mut _lurek_temp_dir: Option<tempfile::TempDir> = None;
    let game_dir = if let Some(ref arg) = game_arg {
        let path = std::path::PathBuf::from(arg);
        if path
            .extension()
            .map(|e| e.eq_ignore_ascii_case("lurek") || e.eq_ignore_ascii_case("lurek"))
            .unwrap_or(false)
        {
            match extract_lurek_archive(&path) {
                Ok(td) => {
                    let dir = td.path().to_path_buf();
                    _lurek_temp_dir = Some(td);
                    dir
                }
                Err(e) => {
                    let msg = format!("Failed to open .lurek archive '{}': {}", path.display(), e);
                    log_msg!(
                        error,
                        crate::runtime::log_messages::L060_LUA_CALLBACK_ERROR,
                        "{}",
                        msg
                    );
                    #[cfg(target_os = "windows")]
                    show_windows_error_box(&msg);
                    eprintln!("{}", msg);
                    return ExitCode::FAILURE;
                }
            }
        } else {
            path
        }
    } else {
        env::current_dir().unwrap_or_else(|_| std::path::PathBuf::from("."))
    };
    let (mut config, conf_error) = Config::load(&game_dir);
    config.modules.validate_and_fix();
    if let Some(width) = window_width {
        config.window.width = width;
    }
    if let Some(height) = window_height {
        config.window.height = height;
    }
    let mode = mode_override.unwrap_or(config.runtime.mode);
    match mode {
        RuntimeMode::Gui => {
            config.modules.validate_and_fix();
            let app = App::new(config, conf_error);
            app.run(
                game_dir,
                explicit_game_dir,
                screenshot_path,
                screenshot_frames,
                screenshot_time,
                window_x.zip(window_y),
            );
            ExitCode::SUCCESS
        }
        RuntimeMode::Headless => {
            if let Some(error) = conf_error {
                eprintln!("Configuration Error\n{}", error);
                return ExitCode::FAILURE;
            }
            runtime::run_headless(
                config,
                HeadlessOptions {
                    game_dir,
                    explicit_game_dir,
                    eval,
                    frames_override,
                },
            )
        }
        RuntimeMode::Tui => {
            config.window.width = config.tui.cols.saturating_mul(config.tui.cell_width);
            config.window.height = config.tui.rows.saturating_mul(config.tui.cell_height);
            config.window.resizable = false;
            config.window.title = format!("{} [TUI]", config.window.title);
            config.modules.render = true;
            config.modules.input = true;
            config.modules.window = true;
            config.modules.terminal = true;
            config.modules.validate_and_fix();
            let (mode_dir, temp_dir) = if explicit_game_dir {
                (game_dir, _lurek_temp_dir)
            } else {
                match create_builtin_game_dir("tui", builtin_tui_script(&config)) {
                    Ok((dir, temp)) => (dir, Some(temp)),
                    Err(error) => {
                        eprintln!("failed to create TUI runtime: {}", error);
                        return ExitCode::FAILURE;
                    }
                }
            };
            _lurek_temp_dir = temp_dir;
            let app = App::new(config, conf_error);
            app.run(
                mode_dir,
                explicit_game_dir,
                screenshot_path,
                screenshot_frames,
                screenshot_time,
                window_x.zip(window_y),
            );
            ExitCode::SUCCESS
        }
        RuntimeMode::Cli => {
            config.window.width = config.cli.cols.saturating_mul(config.cli.cell_width);
            config.window.height = config.cli.rows.saturating_mul(config.cli.cell_height);
            config.window.resizable = false;
            config.window.title = format!("{} [CLI]", config.window.title);
            config.modules.render = true;
            config.modules.input = true;
            config.modules.window = true;
            config.modules.terminal = true;
            config.modules.validate_and_fix();
            let startup_main = if explicit_game_dir {
                Some(game_dir.join("main.lua"))
            } else {
                None
            };
            let script = builtin_cli_script(&config, startup_main.as_deref());
            let (mode_dir, temp_dir) = match create_builtin_game_dir("cli", script) {
                Ok((dir, temp)) => (dir, temp),
                Err(error) => {
                    eprintln!("failed to create CLI runtime: {}", error);
                    return ExitCode::FAILURE;
                }
            };
            _lurek_temp_dir = Some(temp_dir);
            let app = App::new(config, conf_error);
            app.run(
                mode_dir,
                false,
                screenshot_path,
                screenshot_frames,
                screenshot_time,
                window_x.zip(window_y),
            );
            ExitCode::SUCCESS
        }
    }
}

fn create_builtin_game_dir(
    name: &str,
    main_lua: String,
) -> Result<(std::path::PathBuf, tempfile::TempDir), std::io::Error> {
    let temp_dir = tempfile::tempdir()?;
    let root = temp_dir.path().to_path_buf();
    std::fs::write(root.join("main.lua"), main_lua)?;
    std::fs::write(
        root.join("conf.toml"),
        format!(
            "[window]\ntitle = \"Lurek2D {}\"\nresizable = false\n",
            name.to_ascii_uppercase()
        ),
    )?;
    Ok((root, temp_dir))
}

fn lua_string_literal(value: &str) -> String {
    format!("{:?}", value)
}

fn builtin_cli_script(config: &runtime::Config, startup_main: Option<&std::path::Path>) -> String {
    let startup = startup_main
        .map(|path| lua_string_literal(&path.to_string_lossy().replace('\\', "/")))
        .unwrap_or_else(|| "nil".to_string());
    format!(
        r##"
local cols, rows = {cols}, {rows}
local cell_w, cell_h = {cell_w}, {cell_h}
local term, repl
local lines = {{}}
local input = ""
local history = {{}}
local history_index = nil

local function push(line)
    lines[#lines + 1] = tostring(line)
    while #lines > rows - 2 do table.remove(lines, 1) end
end

local function install_print_sink()
    print = function(...)
        local parts = {{}}
        for i = 1, select("#", ...) do
            parts[#parts + 1] = tostring(select(i, ...))
        end
        push(table.concat(parts, "\t"))
    end
end

local function submit()
    local command = input
    if command == "" then return end
    push("lurek> " .. command)
    history[#history + 1] = command
    history_index = nil
    input = ""
    local result = repl:eval(command)
    if result and result ~= "" and result ~= "(ok)" then push(result) end
    if result == "(quit)" then lurek.event.quit() end
end

function lurek.init()
    term = lurek.terminal.newTerminal(cols, rows)
    term:setCellSize(cell_w, cell_h)
    repl = lurek.repl.new({max_history})
    lurek.input.keyboard.setTextInput(true)
    install_print_sink()
    push("Lurek2D Interactive CLI")
    push("Type Lua code. :help for commands. :quit exits.")
    local startup = {startup}
    if startup then push("Startup main.lua available: " .. startup) end
end

function lurek.keypressed(key)
    if key == "return" then submit(); return end
    if key == "backspace" then input = input:sub(1, math.max(0, #input - 1)); return end
    if key == "escape" then lurek.event.quit(); return end
    if key == "tab" then
        local completions = repl:complete(input)
        if #completions == 1 then input = completions[1] elseif #completions > 1 then push(table.concat(completions, "  ")) end
        return
    end
    if key == "up" and #history > 0 then
        history_index = history_index and math.max(1, history_index - 1) or #history
        input = history[history_index]
        return
    end
    if key == "down" and history_index then
        history_index = history_index + 1
        if history_index > #history then history_index = nil; input = "" else input = history[history_index] end
    end
end

function lurek.textinput(text)
    input = input .. text
end

function lurek.draw()
    term:clear()
    for i, line in ipairs(lines) do term:print(1, i, line) end
    term:print(1, rows, "lurek> " .. input .. "_")
    term:render(0, 0)
end
"##,
        cols = config.cli.cols,
        rows = config.cli.rows,
        cell_w = config.cli.cell_width,
        cell_h = config.cli.cell_height,
        max_history = config.cli.max_history,
        startup = startup
    )
}

fn builtin_tui_script(config: &runtime::Config) -> String {
    format!(
        r##"
local cols, rows = {cols}, {rows}
local cell_w, cell_h = {cell_w}, {cell_h}
local term

function lurek.init()
    term = lurek.terminal.newTerminal(cols, rows)
    term:setCellSize(cell_w, cell_h)
end

function lurek.keypressed(key)
    if key == "escape" then lurek.event.quit() end
end

function lurek.draw()
    term:clear()
    term:print(1, 1, "Lurek2D TUI mode")
    term:print(1, 3, "This is a GUI window rendered as a terminal grid.")
    term:print(1, 4, "Run: lurek2d --mode=tui <game_dir> to load a TUI game.")
    term:print(1, rows, "Press Escape to quit.")
    term:render(0, 0)
end
"##,
        cols = config.tui.cols,
        rows = config.tui.rows,
        cell_w = config.tui.cell_width,
        cell_h = config.tui.cell_height,
    )
}
#[cfg(target_os = "windows")]
fn show_windows_error_box(msg: &str) {
    use std::ffi::OsStr;
    use std::iter::once;
    use std::os::windows::ffi::OsStrExt;
    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s).encode_wide().chain(once(0)).collect()
    }
    let text = to_wide(msg);
    let caption = to_wide("Lurek2D Crash");
    unsafe {
        windows_sys::Win32::UI::WindowsAndMessaging::MessageBoxW(
            std::ptr::null_mut(),
            text.as_ptr(),
            caption.as_ptr(),
            0x10,
        );
    }
}
fn extract_lurek_archive(
    archive_path: &std::path::Path,
) -> Result<tempfile::TempDir, Box<dyn std::error::Error>> {
    use std::fs;
    use std::io;
    let file = fs::File::open(archive_path)?;
    let mut archive = zip::ZipArchive::new(file)?;
    let temp_dir = tempfile::tempdir()?;
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let entry_name = entry.name().to_owned();
        let relative = std::path::Path::new(&entry_name);
        for component in relative.components() {
            match component {
                std::path::Component::Normal(_) | std::path::Component::CurDir => {}
                _ => {
                    return Err(format!("Unsafe path in .lurek archive: '{entry_name}'").into());
                }
            }
        }
        let dest = temp_dir.path().join(relative);
        if entry.is_dir() {
            fs::create_dir_all(&dest)?;
        } else {
            if let Some(parent) = dest.parent() {
                fs::create_dir_all(parent)?;
            }
            let mut out = fs::File::create(&dest)?;
            io::copy(&mut entry, &mut out)?;
        }
    }
    Ok(temp_dir)
}
