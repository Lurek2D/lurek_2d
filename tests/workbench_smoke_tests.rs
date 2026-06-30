//! Workbench smoke coverage for headless boot plus an optional real-window screenshot path.

use std::cell::RefCell;
use std::path::PathBuf;
use std::process::Command;
use std::rc::Rc;
use std::time::{Duration, Instant};

use lurek2d::lua_api::{create_lua_vm, SharedState};
use lurek2d::runtime::config::Config;
use lurek2d::runtime::RuntimeMode;

fn make_workbench_vm() -> mlua::Lua {
    let game_dir = PathBuf::from("workbench");
    let (config, conf_error) = Config::load(&game_dir);
    assert!(
        conf_error.is_none(),
        "workbench conf.toml should parse cleanly"
    );

    let mut shared = SharedState::new(1600, 900, "WorkbenchSmoke", game_dir.clone());
    shared.runtime_mode = RuntimeMode::Headless;
    let state = Rc::new(RefCell::new(shared));
    state.borrow_mut().load_default_fonts();
    create_lua_vm(state, &config.modules).expect("Failed to create workbench Lua VM")
}

fn find_binary() -> PathBuf {
    let candidates = [
        "build/release/lurek2d.exe",
        "build/debug/lurek2d.exe",
        "build/release/lurek2d",
        "build/debug/lurek2d",
    ];
    for rel in &candidates {
        let path = PathBuf::from(rel);
        if path.exists() {
            return path;
        }
    }
    panic!("No lurek2d binary found under build/. Run `cargo build` first.");
}

fn headless_render_path() -> PathBuf {
    let dir = PathBuf::from("work").join("workbench_smoke");
    std::fs::create_dir_all(&dir).expect("Failed to create workbench smoke work directory");
    dir.join("headless_ui_smoke.png")
}

fn run_workbench_screenshot() -> PathBuf {
    let binary = find_binary();
    let game_dir = std::fs::canonicalize("workbench").expect("workbench directory should exist");
    let screenshot_dir = PathBuf::from("work").join("workbench_smoke");
    std::fs::create_dir_all(&screenshot_dir).expect("Failed to create screenshot directory");
    let screenshot_path = std::fs::canonicalize(&screenshot_dir)
        .unwrap_or_else(|_| PathBuf::from(".").join(&screenshot_dir))
        .join("workbench_smoke.png");

    if screenshot_path.exists() {
        std::fs::remove_file(&screenshot_path)
            .expect("Failed to remove stale workbench screenshot");
    }

    let mut child = Command::new(&binary)
        .arg(&game_dir)
        .arg(format!("--screenshot={}", screenshot_path.display()))
        .arg("--screenshot-frames=120")
        .spawn()
        .unwrap_or_else(|error| panic!("Failed to spawn {}: {error}", binary.display()));

    let deadline = Instant::now() + Duration::from_secs(45);
    loop {
        match child.try_wait().expect("Failed to poll workbench process") {
            Some(status) => {
                assert!(
                    status.success(),
                    "workbench process exited unsuccessfully: {status}"
                );
                break;
            }
            None => {
                if Instant::now() >= deadline {
                    let _ = child.kill();
                    panic!("workbench smoke process did not exit within 45 seconds");
                }
                std::thread::sleep(Duration::from_millis(200));
            }
        }
    }

    screenshot_path
}

#[test]
fn workbench_headless_boots_and_processes() {
    let lua = make_workbench_vm();
    let code =
        std::fs::read_to_string("workbench/main.lua").expect("Failed to read workbench/main.lua");

    lua.load(&code)
        .set_name("workbench/main.lua")
        .exec()
        .expect("Workbench bootstrap should load");

    let lurek: mlua::Table = lua.globals().get("lurek").expect("Missing lurek global");
    let init: mlua::Function = lurek.get("init").expect("Missing lurek.init");
    let process: mlua::Function = lurek.get("process").expect("Missing lurek.process");
    let draw: mlua::Function = lurek.get("draw").expect("Missing lurek.draw");
    let keypressed: mlua::Function = lurek.get("keypressed").expect("Missing lurek.keypressed");
    let mousemoved: mlua::Function = lurek.get("mousemoved").expect("Missing lurek.mousemoved");
    let ui: mlua::Table = lurek.get("ui").expect("Missing lurek.ui");
    let has_theme: mlua::Function = ui.get("getTheme").expect("Missing lurek.ui.getTheme");
    let widget_count: mlua::Function = ui
        .get("getWidgetCount")
        .expect("Missing lurek.ui.getWidgetCount");
    let render_to_image: mlua::Function = ui
        .get("renderToImage")
        .expect("Missing lurek.ui.renderToImage");

    init.call::<_, ()>(())
        .expect("workbench init should succeed");
    let themed: bool = has_theme
        .call(())
        .expect("workbench theme query should succeed");
    let widgets: i64 = widget_count
        .call(())
        .expect("workbench widget count query should succeed");
    process
        .call::<_, ()>(1.0 / 60.0)
        .expect("workbench process should succeed");
    let handled_f1 = keypressed
        .call::<_, bool>("f1")
        .expect("workbench should accept keyboard input");
    mousemoved
        .call::<_, bool>((24.0_f32, 24.0_f32))
        .expect("workbench should accept mouse movement");
    draw.call::<_, ()>(())
        .expect("workbench draw should succeed");

    let render_path = headless_render_path();
    if render_path.exists() {
        std::fs::remove_file(&render_path)
            .expect("Failed to remove stale headless workbench render");
    }
    render_to_image
        .call::<_, ()>((1600_i64, 900_i64, render_path.to_string_lossy().to_string()))
        .expect("workbench should render a headless UI screenshot");

    assert!(
        handled_f1,
        "workbench should handle the F1 overview shortcut"
    );
    assert!(themed, "workbench should apply a visible lurek.ui theme");
    assert!(
        widgets >= 20,
        "workbench should populate a non-trivial widget tree"
    );
    let size = std::fs::metadata(&render_path)
        .unwrap_or_else(|error| panic!("Cannot stat headless workbench render: {error}"))
        .len();
    assert!(
        size > 2048,
        "workbench headless UI render is suspiciously small: {size} bytes"
    );
}

#[test]
fn workbench_headless_buttons_accept_clicks() {
    let lua = make_workbench_vm();
    let script = r#"
local function load_workbench(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local Registry = load_workbench("app/editor_registry.lua")
local State = load_workbench("app/state.lua")
local Shell = load_workbench("app/shell.lua")
local CommandBus = load_workbench("app/command_bus.lua")
local ProjectIndex = load_workbench("app/services/project_index.lua")
local DocumentService = load_workbench("app/services/document_service.lua")

local registry = Registry.create(load_workbench)
local services = {
    commands = CommandBus.create(),
    projects = ProjectIndex.create(),
    documents = DocumentService.create(registry),
}
local ctx = State.create(registry, services)
local shell = Shell.create(ctx)
shell:update(1 / 60)

local pressed_editors = shell:mousepressed(20, 94, 1)
local released_editors = shell:mousereleased(20, 94, 1)
shell:update(0)

local pressed_home = shell:mousepressed(340, 20, 1)
local released_home = shell:mousereleased(340, 20, 1)
shell:update(0)

return {
    active_sidebar = ctx.active_sidebar,
    active_editor = ctx.active_editor,
    pressed_editors = pressed_editors,
    released_editors = released_editors,
    pressed_home = pressed_home,
    released_home = released_home,
}
"#;

    let result: mlua::Table = lua
        .load(script)
        .set_name("workbench_click_smoke")
        .eval()
        .expect("workbench click smoke should execute");

    let active_sidebar: String = result
        .get("active_sidebar")
        .expect("Missing active_sidebar result");
    let active_editor: String = result
        .get("active_editor")
        .expect("Missing active_editor result");
    let pressed_editors: bool = result
        .get("pressed_editors")
        .expect("Missing pressed_editors result");
    let released_editors: bool = result
        .get("released_editors")
        .expect("Missing released_editors result");
    let pressed_home: bool = result
        .get("pressed_home")
        .expect("Missing pressed_home result");
    let released_home: bool = result
        .get("released_home")
        .expect("Missing released_home result");

    assert!(
        pressed_editors,
        "editor sidebar button should receive mouse press"
    );
    assert!(
        released_editors,
        "editor sidebar button should receive mouse release"
    );
    assert!(pressed_home, "home button should receive mouse press");
    assert!(released_home, "home button should receive mouse release");
    assert_eq!(active_sidebar, "editors");
    assert_eq!(active_editor, "overview");
}

#[test]
#[ignore = "requires a built lurek2d binary plus a real display"]
fn workbench_window_screenshot_smoke() {
    let screenshot = run_workbench_screenshot();
    assert!(
        screenshot.exists(),
        "Workbench smoke screenshot was not created"
    );

    let size = std::fs::metadata(&screenshot)
        .unwrap_or_else(|error| panic!("Cannot stat workbench screenshot: {error}"))
        .len();
    assert!(
        size > 2048,
        "Workbench smoke screenshot is suspiciously small: {size} bytes"
    );

    let bytes = std::fs::read(&screenshot)
        .unwrap_or_else(|error| panic!("Cannot read workbench screenshot: {error}"));
    assert!(
        bytes.starts_with(&[0x89, 0x50, 0x4E, 0x47]),
        "Workbench smoke output is not a PNG: {}",
        screenshot.display()
    );
}
