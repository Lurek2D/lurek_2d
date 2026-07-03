//! Owns the app app implementation for the app subsystem and keeps related runtime rules local here.
//! Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
//! Defines how app app data is validated, transformed, or stored before neighboring systems consume it.
//! Separates app app behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing app app defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the app app state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping app app calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse app app rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on app app state, helpers, or integration rules.

// Engine callback metadata remains parsed by docs generators, but is not part of the prose ownership block.
//! @engine-callback | draw | function lurek.draw() | Called every frame to queue world render commands.
//! @engine-callback | draw_ui | function lurek.draw_ui() | Called every frame after world drawing to queue UI and HUD render commands.
//! @engine-callback | exit | function lurek.exit() | Called before the runtime exits after an explicit close path.
//! @engine-callback | fixedUpdate | function lurek.fixedUpdate(dt) | Deprecated fixed-step update callback; use `lurek.process_physics(dt)`.
//! @engine-param | fixedUpdate | dt | number | false | Fixed timestep in seconds.
//! @engine-callback | focus | function lurek.focus(focused) | Called when the application window gains or loses focus.
//! @engine-param | focus | focused | boolean | false | True when the window is focused.
//! @engine-callback | gamepadaxis | function lurek.gamepadaxis(id, axis, value) | Called when a connected gamepad axis changes.
//! @engine-param | gamepadaxis | id | integer | false | Gamepad slot id.
//! @engine-param | gamepadaxis | axis | string | false | Axis name.
//! @engine-param | gamepadaxis | value | number | false | Axis value reported by the backend.
//! @engine-callback | gamepadconnected | function lurek.gamepadconnected(id) | Called when a gamepad connects.
//! @engine-param | gamepadconnected | id | integer | false | Gamepad slot id.
//! @engine-callback | gamepaddisconnected | function lurek.gamepaddisconnected(id) | Called when a gamepad disconnects.
//! @engine-param | gamepaddisconnected | id | integer | false | Gamepad slot id.
//! @engine-callback | gamepadpressed | function lurek.gamepadpressed(id, button) | Called when a gamepad button is pressed.
//! @engine-param | gamepadpressed | id | integer | false | Gamepad slot id.
//! @engine-param | gamepadpressed | button | string | false | Button name.
//! @engine-callback | gamepadreleased | function lurek.gamepadreleased(id, button) | Called when a gamepad button is released.
//! @engine-param | gamepadreleased | id | integer | false | Gamepad slot id.
//! @engine-param | gamepadreleased | button | string | false | Button name.
//! @engine-callback | init | function lurek.init() | Called once after the Lua VM, shared state, and `lurek.*` modules are ready.
//! @engine-callback | joystickadded | function lurek.joystickadded(id) | Compatibility callback called when a gamepad connects.
//! @engine-param | joystickadded | id | integer | false | Gamepad slot id.
//! @engine-callback | joystickremoved | function lurek.joystickremoved(id) | Compatibility callback called when a gamepad disconnects.
//! @engine-param | joystickremoved | id | integer | false | Gamepad slot id.
//! @engine-callback | keypressed | function lurek.keypressed(key, scancode, isrepeat) | Called when a keyboard key is pressed and UI did not consume it.
//! @engine-param | keypressed | key | string | false | Normalized key name.
//! @engine-param | keypressed | scancode | string | false | Normalized physical scancode, or an empty string when unavailable.
//! @engine-param | keypressed | isrepeat | boolean | false | True when the key press is an OS repeat event.
//! @engine-callback | keyreleased | function lurek.keyreleased(key, scancode) | Called when a keyboard key is released.
//! @engine-param | keyreleased | key | string | false | Normalized key name.
//! @engine-param | keyreleased | scancode | string | false | Normalized physical scancode, or an empty string when unavailable.
//! @engine-callback | mousemoved | function lurek.mousemoved(x, y, dx, dy) | Called when the pointer moves in game coordinates and UI did not consume it.
//! @engine-param | mousemoved | x | number | false | Pointer x coordinate in game space.
//! @engine-param | mousemoved | y | number | false | Pointer y coordinate in game space.
//! @engine-param | mousemoved | dx | number | false | Delta x since the previous pointer event.
//! @engine-param | mousemoved | dy | number | false | Delta y since the previous pointer event.
//! @engine-callback | mousepressed | function lurek.mousepressed(x, y, button) | Called when a mouse button is pressed and UI did not consume it.
//! @engine-param | mousepressed | x | number | false | Pointer x coordinate in game space.
//! @engine-param | mousepressed | y | number | false | Pointer y coordinate in game space.
//! @engine-param | mousepressed | button | integer | false | One-based mouse button index.
//! @engine-callback | mousereleased | function lurek.mousereleased(x, y, button) | Called when a mouse button is released and UI did not consume it.
//! @engine-param | mousereleased | x | number | false | Pointer x coordinate in game space.
//! @engine-param | mousereleased | y | number | false | Pointer y coordinate in game space.
//! @engine-param | mousereleased | button | integer | false | One-based mouse button index.
//! @engine-callback | process | function lurek.process(dt) | Called every frame for game logic.
//! @engine-param | process | dt | number | false | Frame delta time in seconds.
//! @engine-callback | process_late | function lurek.process_late(dt) | Called every frame after `process` and fixed-step physics callbacks.
//! @engine-param | process_late | dt | number | false | Frame delta time in seconds.
//! @engine-callback | process_physics | function lurek.process_physics(dt) | Called at the fixed timestep zero or more times per rendered frame.
//! @engine-param | process_physics | dt | number | false | Fixed timestep in seconds.
//! @engine-callback | ready | function lurek.ready() | Called once after startup when the first frame resources are ready.
//! @engine-callback | resize | function lurek.resize(width, height) | Called after the renderer and viewport are resized.
//! @engine-param | resize | width | integer | false | Window width in pixels after clamping.
//! @engine-param | resize | height | integer | false | Window height in pixels after clamping.
//! @engine-callback | textinput | function lurek.textinput(text) | Called when committed text input arrives and UI did not consume it.
//! @engine-param | textinput | text | string | false | Committed text.
//! @engine-callback | touchmoved | function lurek.touchmoved(id, x, y, dx, dy, pressure) | Called when a touch point moves.
//! @engine-param | touchmoved | id | integer | false | Touch identifier.
//! @engine-param | touchmoved | x | number | false | Touch x coordinate in game space.
//! @engine-param | touchmoved | y | number | false | Touch y coordinate in game space.
//! @engine-param | touchmoved | dx | number | false | Delta x since the previous touch event.
//! @engine-param | touchmoved | dy | number | false | Delta y since the previous touch event.
//! @engine-param | touchmoved | pressure | number | true | Normalized pressure when available.
//! @engine-callback | touchpressed | function lurek.touchpressed(id, x, y, dx, dy, pressure) | Called when a touch point starts.
//! @engine-param | touchpressed | id | integer | false | Touch identifier.
//! @engine-param | touchpressed | x | number | false | Touch x coordinate in game space.
//! @engine-param | touchpressed | y | number | false | Touch y coordinate in game space.
//! @engine-param | touchpressed | dx | number | false | Initial delta x, normally `0`.
//! @engine-param | touchpressed | dy | number | false | Initial delta y, normally `0`.
//! @engine-param | touchpressed | pressure | number | true | Normalized pressure when available.
//! @engine-callback | touchreleased | function lurek.touchreleased(id, x, y, dx, dy, pressure) | Called when a touch point ends or is cancelled.
//! @engine-param | touchreleased | id | integer | false | Touch identifier.
//! @engine-param | touchreleased | x | number | false | Touch x coordinate in game space.
//! @engine-param | touchreleased | y | number | false | Touch y coordinate in game space.
//! @engine-param | touchreleased | dx | number | false | Delta x since the previous touch event.
//! @engine-param | touchreleased | dy | number | false | Delta y since the previous touch event.
//! @engine-param | touchreleased | pressure | number | true | Normalized pressure when available.
//! @engine-callback | visible | function lurek.visible(visible) | Called when the window occlusion/visibility state changes.
//! @engine-param | visible | visible | boolean | false | True when the window is visible.
//! @engine-callback | wheelmoved | function lurek.wheelmoved(dx, dy) | Called when mouse-wheel input arrives and UI did not consume it.
//! @engine-param | wheelmoved | dx | number | false | Horizontal wheel delta.
//! @engine-param | wheelmoved | dy | number | false | Vertical wheel delta.

use super::debug_overlay::DebugOverlay;
use super::error_screen::ErrorScreen;
use super::lua_callbacks::{
    call_function_with_optional_timeout, call_lua_callback_checked_with_timeout,
    call_lua_callback_with_timeout, has_lua_callback,
};
use super::splash_screen::{load_splash_branding, make_splash_commands, SplashBranding};
use crate::event::EventArg;
use crate::filesystem::watcher::FileWatcher;
use crate::input::keyboard::{winit_key_to_string, winit_scancode_to_string};
use crate::input::SystemCursor;
#[allow(unused_imports)]
use crate::log_msg;
use crate::lua_api::create_lua_vm;
use crate::raycaster::RaycasterRenderState;
use crate::render::renderer::{RenderCommand, TextureData};
use crate::render::GpuRenderer;
pub use crate::runtime::config::Config;
use crate::runtime::log_messages::{
    L003_GAME_LOADED, L006_SPLASH_SCREEN, L007_NO_MAIN_LUA, L010_RENDER_ERROR, L011_LUA_ERROR,
    L016_LUA_VM_INIT_FAIL, L017_MAIN_LUA_READ_FAIL, L021_CLIPBOARD_FAIL, L023_GPU_TEX_TOO_SMALL,
    L024_SURFACE_LOST, L033_GPU_ADAPTER, L034_GPU_TEX_DIM, L035_GPU_INIT, L039_WINDOW_CLOSE,
    L040_ICON_LOAD_FAIL, L041_ICON_CONV_FAIL, L043_DROP_FILE, L044_DROP_GAME,
    L070_SURFACE_NO_READBACK, L071_CURSOR_GRAB_FAIL, L072_CURSOR_GRAB_LOCK_FAIL,
    L073_CURSOR_POS_FAIL, L074_SCREENSHOT_NO_READBACK, L075_SCREENSHOT_SAVE_FAIL,
    L076_SCREENSHOT_ENCODE_FAIL, L077_DRAG_HOVER, L078_DRAG_HOVER_CANCEL, L079_DRAG_DROP_IGNORED,
    L080_GAME_DIR, L081_LOG_FILE, L082_LOG_FILE_FAIL, L083_DROP_ARCHIVE, L084_DROP_ARCHIVE_FAIL,
};
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ShaderKey, ShapeKey, SpriteBatchKey, TextureKey,
};
pub use crate::runtime::shared_state::WindowState;
use crate::runtime::{FullscreenType, SharedState};
use crate::window::{center_window_on_monitor, move_window_to_display, select_startup_monitor};
use mlua::prelude::*;
use slotmap::SlotMap;
use std::cell::RefCell;
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::rc::Rc;
use std::sync::Arc;
use std::time::{Duration, Instant};
use winit::application::ApplicationHandler;
use winit::event::{ElementState, MouseButton, WindowEvent};
use winit::event_loop::{ActiveEventLoop, ControlFlow, EventLoop};
use winit::keyboard::PhysicalKey;
use winit::window::{CursorGrabMode, CursorIcon, Window, WindowId};

mod gamepad;
mod main_loop;
mod runner;
mod screens;
/// Recompute viewport scale and offset from game-space size to current window size.
pub fn recompute_viewport(ws: &mut WindowState, win_w: u32, win_h: u32) {
    let gw = ws.game_width.max(1.0);
    let gh = ws.game_height.max(1.0);
    match ws.scale_mode_str.as_str() {
        "letterbox" => {
            let s = (win_w as f32 / gw).min(win_h as f32 / gh);
            ws.viewport_scale_x = s;
            ws.viewport_scale_y = s;
            ws.viewport_offset_x = (win_w as f32 - gw * s) * 0.5;
            ws.viewport_offset_y = (win_h as f32 - gh * s) * 0.5;
        }
        "stretch" => {
            ws.viewport_scale_x = win_w as f32 / gw;
            ws.viewport_scale_y = win_h as f32 / gh;
            ws.viewport_offset_x = 0.0;
            ws.viewport_offset_y = 0.0;
        }
        "pixel" => {
            let s = ((win_w as f32 / gw).min(win_h as f32 / gh))
                .floor()
                .max(1.0);
            ws.viewport_scale_x = s;
            ws.viewport_scale_y = s;
            ws.viewport_offset_x = (win_w as f32 - gw * s) * 0.5;
            ws.viewport_offset_y = (win_h as f32 - gh * s) * 0.5;
        }
        _ => {
            ws.viewport_scale_x = 1.0;
            ws.viewport_scale_y = 1.0;
            ws.viewport_offset_x = 0.0;
            ws.viewport_offset_y = 0.0;
        }
    }
}

fn shared_flag(
    state: &Option<Rc<RefCell<SharedState>>>,
    read: impl FnOnce(&SharedState) -> bool,
) -> bool {
    state
        .as_ref()
        .map(|state| read(&state.borrow()))
        .unwrap_or(false)
}

fn call_lua_ui_bool<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    method: &str,
    args: A,
    timeout_ms: Option<f32>,
) -> Result<bool, mlua::Error> {
    let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") else {
        return Ok(false);
    };
    let Ok(ui) = lurek.get::<_, LuaTable>("ui") else {
        return Ok(false);
    };
    let Ok(func) = ui.get::<_, LuaFunction>(method) else {
        return Ok(false);
    };
    call_function_with_optional_timeout(lua, &format!("ui.{method}"), func, args, timeout_ms)
}

fn call_lua_ui_update(lua: &Lua, dt: f32, timeout_ms: Option<f32>) -> Result<(), mlua::Error> {
    let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") else {
        return Ok(());
    };
    let Ok(ui) = lurek.get::<_, LuaTable>("ui") else {
        return Ok(());
    };
    let Ok(func) = ui.get::<_, LuaFunction>("update") else {
        return Ok(());
    };
    call_function_with_optional_timeout(lua, "ui.update", func, dt, timeout_ms)
}
/// High-level app runtime state used by the frame/event loop.
pub enum RunState {
    /// Normal game/runtime execution.
    Running,
    /// Fatal error mode that renders an `ErrorScreen`.
    Error(ErrorScreen),
    /// Transition state while rebuilding runtime after reload/restart.
    Restarting,
}
/// Build splash window title with engine version suffix.
pub fn splash_window_title(base_title: &str) -> String {
    format!("{} v{}", base_title, env!("CARGO_PKG_VERSION"))
}
/// Fit source size into max bounds while preserving aspect ratio.
pub fn fit_contain_size(src_w: u32, src_h: u32, max_w: f32, max_h: f32) -> (f32, f32) {
    let src_w = src_w.max(1) as f32;
    let src_h = src_h.max(1) as f32;
    let scale = (max_w.max(1.0) / src_w).min(max_h.max(1.0) / src_h);
    (src_w * scale, src_h * scale)
}

/// Startup target inferred from a drag-and-drop path.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DropStartupTarget {
    /// Dropped archive with `.lurek` extension.
    Archive,
    /// Resolved game directory containing `main.lua`.
    GameDir(PathBuf),
    /// Path that does not resolve to a launchable game target.
    Unsupported,
}

const SUPPORTED_SCALE_MODES: &[&str] = &["none", "letterbox", "stretch", "pixel"];
const DEFAULT_STARTUP_MAX_ARCHIVE_BYTES: u64 = 512 * 1024 * 1024;
const DEFAULT_HOT_RELOAD_DEBOUNCE: Duration = Duration::from_millis(250);

/// GPU startup phase that failed before the app could enter steady execution.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AppStartupStage {
    /// Failed while binding the wgpu surface to the window.
    Surface,
    /// Failed while selecting a compatible adapter.
    Adapter,
    /// Failed while creating the wgpu device or queue.
    Device,
}

/// Structured startup failure used to avoid panics during GPU initialization.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AppStartupError {
    /// GPU startup phase that failed.
    pub stage: AppStartupStage,
    /// Requested backend string from config.
    pub backend: String,
    /// Requested power-preference string from config.
    pub power_preference: String,
    /// Human-readable failure details.
    pub details: String,
}

impl AppStartupError {
    fn to_error_screen(&self) -> ErrorScreen {
        let stage = match self.stage {
            AppStartupStage::Surface => "surface creation",
            AppStartupStage::Adapter => "adapter selection",
            AppStartupStage::Device => "device creation",
        };
        ErrorScreen::from_error(&format!(
            "GPU Startup Failed\nstage: {}\nbackend: {}\npower preference: {}\n{}",
            stage, self.backend, self.power_preference, self.details
        ))
    }
}

/// Map a structured startup failure into recoverable app error state.
pub fn map_startup_error_to_run_state(error: &AppStartupError) -> RunState {
    RunState::Error(error.to_error_screen())
}

/// Policy used to validate startup targets and `.lurek` archives before loading.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StartupTargetPolicy {
    /// Maximum archive size accepted for `.lurek` startup input.
    pub max_archive_bytes: u64,
    /// Whether filesystem symlinks are rejected for startup inputs.
    pub reject_symlinks: bool,
}

impl Default for StartupTargetPolicy {
    fn default() -> Self {
        Self {
            max_archive_bytes: DEFAULT_STARTUP_MAX_ARCHIVE_BYTES,
            reject_symlinks: true,
        }
    }
}

/// Diagnostic emitted while classifying startup input.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StartupTargetDiagnostic {
    /// The target was rejected because it resolves through a symlink.
    SymlinkRejected(PathBuf),
    /// The target does not contain a launchable `main.lua`.
    MissingMainLua(PathBuf),
    /// The archive exceeded the allowed size limit.
    ArchiveTooLarge {
        /// Archive path being validated.
        path: PathBuf,
        /// Observed archive size.
        actual_bytes: u64,
        /// Maximum allowed archive size.
        max_bytes: u64,
    },
    /// The archive contained an unsafe entry path.
    UnsafeArchiveEntry(String),
}

/// Classification result plus diagnostics for drag-drop startup input.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StartupTargetReport {
    /// Resolved startup target kind.
    pub target: DropStartupTarget,
    /// Diagnostics emitted while resolving the target.
    pub diagnostics: Vec<StartupTargetDiagnostic>,
}

/// Callback failure mode used by app-hosted Lua execution.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CallbackFailurePolicy {
    /// Only record the error and continue.
    ReportOnly,
    /// Enter app error mode after recording the failure.
    Fatal,
}

/// Diagnostic record for one Lua callback failure.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CallbackErrorRecord {
    /// Callback name such as `draw` or `ui.keypressed`.
    pub callback: String,
    /// App phase that triggered the callback.
    pub phase: String,
    /// Error text captured from Lua.
    pub message: String,
    /// Applied failure policy.
    pub policy: CallbackFailurePolicy,
}

/// Structured report for one attempted window-state apply cycle.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct WindowRuntimeReport {
    /// Requested size and the clamped size that was applied.
    pub clamped_size: Option<((u32, u32), (u32, u32))>,
    /// Unsupported scale mode that was ignored.
    pub invalid_scale_mode: Option<String>,
    /// Requested vsync mode and the normalized applied mode.
    pub vsync_adjustment: Option<(i32, i32)>,
    /// Requested display index that could not be applied.
    pub invalid_display_index: Option<usize>,
}

impl WindowRuntimeReport {
    fn is_empty(&self) -> bool {
        self.clamped_size.is_none()
            && self.invalid_scale_mode.is_none()
            && self.vsync_adjustment.is_none()
            && self.invalid_display_index.is_none()
    }
}

type WindowRuntimeValidation = (
    Option<(u32, u32)>,
    Option<String>,
    Option<i32>,
    WindowRuntimeReport,
);

/// Dispatch stage used for input-routing diagnostics.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InputDispatchTarget {
    /// Host/platform state was updated first.
    Platform,
    /// `lurek.ui` had the first callback chance.
    Ui,
    /// Game callback was invoked after UI.
    Game,
}

/// Diagnostic report for one input event routed through the app host.
#[derive(Debug, Clone, PartialEq)]
pub struct InputDispatchReport {
    /// Stable event kind such as `keypressed` or `mousemoved`.
    pub event_kind: String,
    /// Ordered dispatch targets that were considered.
    pub order: Vec<InputDispatchTarget>,
    /// Whether UI consumed the event before the game callback.
    pub ui_consumed: bool,
    /// Optional callback error text.
    pub callback_error: Option<String>,
    /// Optional transformed game-space coordinates.
    pub coordinates: Option<(f32, f32)>,
}

/// Structured report for one runtime reload attempt.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReloadReport {
    /// Short trigger name such as `manual` or `hot_reload`.
    pub trigger: String,
    /// Files that contributed to the reload request, when known.
    pub changed_paths: Vec<PathBuf>,
    /// Ordered lifecycle phases reached by the reload attempt.
    pub phases: Vec<String>,
    /// Whether the new runtime session was committed.
    pub reloaded: bool,
    /// Whether an old session was restored after failure.
    pub rolled_back: bool,
    /// Failure summary when reload did not commit.
    pub failure: Option<String>,
}

/// Report emitted when hot reload coalesces filesystem changes into one restart.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HotReloadReport {
    /// Paths merged into the debounce window.
    pub changed_paths: Vec<PathBuf>,
    /// Reload report emitted when the debounce window completed.
    pub reload: ReloadReport,
}

#[derive(Debug, Default)]
struct AppDiagnostics {
    callback_errors: Vec<CallbackErrorRecord>,
    window_reports: Vec<WindowRuntimeReport>,
    input_reports: Vec<InputDispatchReport>,
    hot_reload_reports: Vec<HotReloadReport>,
}

struct RuntimeSession {
    lua: Lua,
    state: Rc<RefCell<SharedState>>,
    has_game: bool,
}

struct RuntimeSessionError {
    screen: ErrorScreen,
    summary: String,
    state: Option<Rc<RefCell<SharedState>>>,
}

/// Classify a dropped path into archive, game directory, or unsupported input.
pub fn classify_drop_startup_target(path: &Path) -> DropStartupTarget {
    classify_drop_startup_target_with_policy(path, &StartupTargetPolicy::default()).target
}

/// Classify a dropped path under an explicit startup policy and retain diagnostics.
pub fn classify_drop_startup_target_with_policy(
    path: &Path,
    policy: &StartupTargetPolicy,
) -> StartupTargetReport {
    let mut diagnostics = Vec::new();
    if policy.reject_symlinks
        && std::fs::symlink_metadata(path)
            .map(|meta| meta.file_type().is_symlink())
            .unwrap_or(false)
    {
        diagnostics.push(StartupTargetDiagnostic::SymlinkRejected(path.to_path_buf()));
        return StartupTargetReport {
            target: DropStartupTarget::Unsupported,
            diagnostics,
        };
    }

    let is_lurek_archive = path
        .extension()
        .map(|extension| extension.eq_ignore_ascii_case("lurek"))
        .unwrap_or(false);
    if is_lurek_archive {
        if let Ok(metadata) = std::fs::metadata(path) {
            if metadata.len() > policy.max_archive_bytes {
                diagnostics.push(StartupTargetDiagnostic::ArchiveTooLarge {
                    path: path.to_path_buf(),
                    actual_bytes: metadata.len(),
                    max_bytes: policy.max_archive_bytes,
                });
                return StartupTargetReport {
                    target: DropStartupTarget::Unsupported,
                    diagnostics,
                };
            }
        }
        return StartupTargetReport {
            target: DropStartupTarget::Archive,
            diagnostics,
        };
    }

    if path.is_dir() {
        let main_lua = path.join("main.lua");
        if main_lua.exists() {
            let resolved = path.canonicalize().unwrap_or_else(|_| path.to_path_buf());
            return StartupTargetReport {
                target: DropStartupTarget::GameDir(resolved),
                diagnostics,
            };
        }
        diagnostics.push(StartupTargetDiagnostic::MissingMainLua(path.to_path_buf()));
        return StartupTargetReport {
            target: DropStartupTarget::Unsupported,
            diagnostics,
        };
    }

    if let Some(parent) = path.parent() {
        if policy.reject_symlinks
            && std::fs::symlink_metadata(parent)
                .map(|meta| meta.file_type().is_symlink())
                .unwrap_or(false)
        {
            diagnostics.push(StartupTargetDiagnostic::SymlinkRejected(
                parent.to_path_buf(),
            ));
            return StartupTargetReport {
                target: DropStartupTarget::Unsupported,
                diagnostics,
            };
        }
        if parent.join("main.lua").exists() {
            let resolved = parent
                .canonicalize()
                .unwrap_or_else(|_| parent.to_path_buf());
            return StartupTargetReport {
                target: DropStartupTarget::GameDir(resolved),
                diagnostics,
            };
        }
    }

    diagnostics.push(StartupTargetDiagnostic::MissingMainLua(
        path.parent().unwrap_or(path).to_path_buf(),
    ));
    StartupTargetReport {
        target: DropStartupTarget::Unsupported,
        diagnostics,
    }
}

/// Return `true` when the splash screen should open the startup picker for a key press.
pub fn should_open_startup_picker_on_key(key_str: &str, ctrl_held: bool) -> bool {
    matches!(key_str, "enter" | "space") || (ctrl_held && key_str == "o")
}
/// Central app runtime state shared by winit callbacks and frame update/render flow.
pub struct LurekApp {
    /// Loaded game configuration from conf.toml.
    config: Config,
    /// Root directory of the active game project.
    game_dir: PathBuf,
    /// Active winit window handle.
    window: Option<Arc<Window>>,
    /// wgpu presentation surface bound to the window.
    surface: Option<wgpu::Surface<'static>>,
    /// Negotiated surface texture format.
    surface_format: wgpu::TextureFormat,
    /// Composite alpha mode for the surface.
    surface_alpha_mode: wgpu::CompositeAlphaMode,
    /// Present modes supported by the GPU adapter.
    surface_present_modes: Vec<wgpu::PresentMode>,
    /// Currently active present mode.
    surface_present_mode: wgpu::PresentMode,
    /// Texture usages enabled on the surface.
    surface_usage: wgpu::TextureUsages,
    /// GPU renderer owning the device, queue, and pipeline state.
    renderer: Option<GpuRenderer>,
    /// Active Lua VM instance.
    pub lua: Option<Lua>,
    /// Shared runtime state accessible by Lua bindings.
    pub state: Option<Rc<RefCell<SharedState>>>,
    /// Whether a valid main.lua has been loaded.
    has_game: bool,
    /// Timestamp of the last completed frame presentation.
    last_frame: Instant,
    /// Whether `lurek.ready()` has been fired this session.
    ready_fired: bool,
    /// Accumulated time for fixed-rate physics stepping.
    physics_accumulator: f64,
    /// Accumulated time for fixed-rate game update stepping.
    fixed_update_accumulator: f64,
    /// One-shot guard for `lurek.fixedUpdate` deprecation warning.
    fixed_update_deprecation_warned: bool,
    /// Previous-frame mouse button states for edge detection.
    prev_mouse: [bool; 5],
    /// Current game-space mouse X position.
    mouse_x: f32,
    /// Current game-space mouse Y position.
    mouse_y: f32,
    /// Current run-state: running, error, or restarting.
    pub run_state: RunState,
    /// Debug HUD overlay state.
    debug_overlay: DebugOverlay,
    /// Configuration parse error deferred to first-frame display.
    conf_error: Option<String>,
    /// File watcher for conf.toml hot-reload.
    conf_watcher: FileWatcher,
    /// File watcher for Lua script hot-reload.
    content_script_watcher: FileWatcher,
    /// File watcher for asset hot-reload.
    content_asset_watcher: FileWatcher,
    /// Whether the game directory was explicitly provided via CLI.
    explicit_game_dir: bool,
    /// Current vsync mode: -1=mailbox, 0=off, 1=fifo.
    window_vsync_mode: i32,
    /// Loaded bitmap fonts used by splash and error screens.
    engine_fonts: Option<(SlotMap<FontKey, crate::font::Font>, FontKey, FontKey)>,
    /// Decoded splash branding textures.
    splash_branding: Option<SplashBranding>,
    /// Whether splash branding decode has already failed.
    splash_branding_failed: bool,
    /// Whether the Ctrl key is currently held.
    ctrl_held: bool,
    /// Whether the Lua VM has been initialised this session.
    lua_initialized: bool,
    /// Whether a file is being hovered over the window.
    drag_hover: bool,
    /// Maximum GPU texture dimension used for surface clamping.
    max_surface_dim: u32,
    /// Reusable buffer for viewport-wrapped render commands.
    render_cmd_buf: Vec<RenderCommand>,
    /// Temporary buffer for auto-parallax layer render commands.
    auto_parallax_buf: Vec<Rc<RefCell<crate::parallax::ParallaxLayer>>>,
    /// Temporary buffer for auto-tilemap render commands.
    auto_tilemap_buf: Vec<Rc<RefCell<crate::tilemap::TileMap>>>,
    /// Temporary buffer for auto-particle render commands.
    auto_particle_cmd_buf: Vec<RenderCommand>,
    /// Temporary buffer for auto-UI render commands.
    auto_ui_cmd_buf: Vec<RenderCommand>,
    /// CLI-requested automatic screenshot output path.
    auto_screenshot_path: Option<PathBuf>,
    /// Number of frames to wait before taking the auto-screenshot.
    auto_screenshot_frames: u32,
    /// Time in seconds to wait before taking the auto-screenshot.
    auto_screenshot_time: Option<f32>,
    /// Whether the automatic screenshot has been captured.
    auto_screenshot_done: bool,
    /// Frames rendered since the auto-screenshot timer started.
    auto_screenshot_frame_count: u32,
    /// Instant when auto-screenshot timing began.
    auto_screenshot_start: Option<Instant>,
    /// Optional frame count after which the runtime should exit automatically.
    auto_quit_frames: Option<u32>,
    /// Optional time in seconds after which the runtime should exit automatically.
    auto_quit_time: Option<f32>,
    /// Whether the auto-quit condition has already been reached.
    auto_quit_done: bool,
    /// Frames rendered since auto-quit timing began.
    auto_quit_frame_count: u32,
    /// Instant when auto-quit timing began.
    auto_quit_start: Option<Instant>,
    /// Keep the OS window hidden for non-interactive automated runs.
    hidden_window: bool,
    /// CLI-supplied initial window position override.
    window_pos: Option<(i32, i32)>,
    /// Temp directory keeping extracted .lurek archive contents alive.
    lurek_temp_dir: Option<tempfile::TempDir>,
    /// Instant when the current perf report interval started.
    perf_report_started: Instant,
    /// Frame count accumulated in the current perf interval.
    perf_frames: u32,
    /// Accumulated tick phase milliseconds for the perf interval.
    perf_tick_ms_acc: f64,
    /// Accumulated update phase milliseconds for the perf interval.
    perf_update_ms_acc: f64,
    /// Accumulated render phase milliseconds for the perf interval.
    perf_render_ms_acc: f64,
    /// Whether LUREK_PERF_LOG=1 periodic logging is active.
    perf_log_enabled: bool,
    /// Latest app-host diagnostics for callback, window, input, and reload reports.
    diagnostics: AppDiagnostics,
    /// Per-callback failure policy overrides used by tests and host policy wiring.
    callback_failure_overrides: HashMap<String, CallbackFailurePolicy>,
    /// Coalesced hot-reload paths waiting for the debounce window to expire.
    pending_hot_reload_paths: Vec<PathBuf>,
    /// Deadline after which coalesced file changes trigger one reload.
    pending_hot_reload_deadline: Option<Instant>,
    /// Debounce window applied to watcher-triggered restarts.
    hot_reload_debounce: Duration,
}
/// Register watchers for script and asset files under `game_dir`.
fn build_content_watchers(game_dir: &Path) -> (FileWatcher, FileWatcher) {
    let mut script_watcher = FileWatcher::new();
    let mut asset_watcher = FileWatcher::new();
    register_content_watchers(game_dir, &mut script_watcher, &mut asset_watcher);
    (script_watcher, asset_watcher)
}

fn should_ignore_hot_reload_path(path: &Path) -> bool {
    path.components().any(|component| {
        let name = component.as_os_str().to_string_lossy();
        matches!(
            name.as_ref(),
            "save" | "logs" | "target" | ".git" | "build" | "dist" | "tmp" | ".tmp" | "temp"
        )
    })
}

fn register_content_watchers(
    game_dir: &Path,
    script_watcher: &mut FileWatcher,
    asset_watcher: &mut FileWatcher,
) {
    /// Walk directory tree and register paths by extension.
    fn walk_dir(root: &Path, script_watcher: &mut FileWatcher, asset_watcher: &mut FileWatcher) {
        let entries = match std::fs::read_dir(root) {
            Ok(entries) => entries,
            Err(_) => return,
        };
        for entry in entries.flatten() {
            let path = entry.path();
            if should_ignore_hot_reload_path(&path) {
                continue;
            }
            if path.is_dir() {
                walk_dir(&path, script_watcher, asset_watcher);
                continue;
            }
            let ext = path
                .extension()
                .and_then(|e| e.to_str())
                .map(|e| e.to_ascii_lowercase());
            match ext.as_deref() {
                Some("lua") => script_watcher.watch(&path),
                Some("png") | Some("jpg") | Some("jpeg") | Some("webp") | Some("bmp")
                | Some("gif") | Some("ogg") | Some("wav") | Some("mp3") | Some("flac")
                | Some("ttf") | Some("otf") | Some("wgsl") | Some("json") | Some("toml") => {
                    asset_watcher.watch(&path)
                }
                _ => {}
            }
        }
    }
    walk_dir(game_dir, script_watcher, asset_watcher);
}
/// Thin bootstrap wrapper that owns startup config and launches `LurekApp` event loop.
pub struct App {
    /// Runtime configuration loaded before app startup.
    config: Config,
    /// Optional configuration parse error passed to first-frame error handling.
    conf_error: Option<String>,
}

/// Startup options passed to the GUI/TUI/CLI application runner.
pub struct AppRunOptions {
    /// Directory containing the game or generated runtime script.
    pub game_dir: PathBuf,
    /// Whether the game directory was explicitly supplied by the user.
    pub explicit_game_dir: bool,
    /// Optional screenshot output path used by demo capture tools.
    pub screenshot_path: Option<PathBuf>,
    /// Frame count to wait before screenshot capture.
    pub screenshot_frames: u32,
    /// Wall-clock delay to wait before screenshot capture.
    pub screenshot_time: Option<f32>,
    /// Optional frame count that exits the runtime automatically.
    pub auto_quit_frames: Option<u32>,
    /// Optional wall-clock timeout that exits the runtime automatically.
    pub auto_quit_time: Option<f32>,
    /// Whether to create the runtime window hidden.
    pub hidden_window: bool,
    /// Optional window position requested by screenshot tools.
    pub window_pos: Option<(i32, i32)>,
}

impl App {
    /// Create bootstrap app wrapper with config and optional pre-start config error.
    pub fn new(config: Config, conf_error: Option<String>) -> Self {
        App { config, conf_error }
    }
    /// Start the winit event loop and run the runtime for the selected game directory.
    pub fn run(self, options: AppRunOptions) {
        init_logging(
            &options.game_dir,
            self.config.log_file.as_deref(),
            self.config.log_append,
            self.config.log_level.as_deref(),
        );
        crate::runtime::messages::init();
        log_msg!(
            info,
            crate::runtime::log_messages::L001_ENGINE_START,
            "v{} (wgpu GPU backend)",
            env!("CARGO_PKG_VERSION"),
        );
        log_msg!(info, L080_GAME_DIR, "{}", options.game_dir.display());
        let event_loop = EventLoop::new().expect("Failed to create event loop");
        event_loop.set_control_flow(ControlFlow::Poll);
        let mut app = LurekApp::new(
            self.config,
            options.game_dir,
            self.conf_error,
            options.explicit_game_dir,
            options.screenshot_path,
            options.screenshot_frames,
            options.screenshot_time,
            options.auto_quit_frames,
            options.auto_quit_time,
            options.hidden_window,
            options.window_pos,
        );
        event_loop.run_app(&mut app).expect("Event loop error");
        log_msg!(info, crate::runtime::log_messages::L002_ENGINE_STOP);
    }
}
/// Initialize logger with file sink and selected level filters.
fn init_logging(
    game_dir: &Path,
    log_file: Option<&str>,
    log_append: bool,
    log_level: Option<&str>,
) {
    use std::io::Write as _;
    let log_path = if let Some(custom) = log_file {
        let p = std::path::Path::new(custom);
        if p.is_absolute() {
            p.to_path_buf()
        } else {
            game_dir.join(p)
        }
    } else {
        std::env::current_dir()
            .unwrap_or_else(|_| std::path::PathBuf::from("."))
            .join("logs")
            .join("runtime")
            .join("lurek.log")
    };
    if let Some(parent) = log_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }
    let file_result = if log_append {
        std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&log_path)
    } else {
        std::fs::OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(&log_path)
    };
    let level = match log_level {
        Some("error") => log::LevelFilter::Error,
        Some("warn") => log::LevelFilter::Warn,
        Some("info") => log::LevelFilter::Info,
        Some("debug") => log::LevelFilter::Debug,
        Some("trace") => log::LevelFilter::Trace,
        _ => {
            if cfg!(debug_assertions) {
                log::LevelFilter::Debug
            } else {
                log::LevelFilter::Error
            }
        }
    };
    let wgpu_level = if cfg!(debug_assertions) {
        log::LevelFilter::Warn
    } else {
        log::LevelFilter::Error
    };
    match file_result {
        Ok(file) => {
            let file = std::sync::Arc::new(std::sync::Mutex::new(file));
            let file_clone = std::sync::Arc::clone(&file);
            env_logger::Builder::new()
                .filter_level(level)
                .parse_default_env()
                .filter_module("wgpu", wgpu_level)
                .filter_module("wgpu_core", wgpu_level)
                .filter_module("wgpu_hal", wgpu_level)
                .filter_module("naga", wgpu_level)
                .format(move |buf, record| {
                    let ts = buf.timestamp_millis();
                    let line = format!("[{}] {:5} {}\n", ts, record.level(), record.args());
                    writeln!(buf, "[{}] {:5} {}", ts, record.level(), record.args())?;
                    if let Ok(mut f) = file_clone.lock() {
                        let _ = f.write_all(line.as_bytes());
                    }
                    Ok(())
                })
                .init();
            log_msg!(info, L081_LOG_FILE, "{}", log_path.display());
        }
        Err(e) => {
            env_logger::Builder::new()
                .filter_level(level)
                .parse_default_env()
                .filter_module("wgpu", wgpu_level)
                .filter_module("wgpu_core", wgpu_level)
                .filter_module("wgpu_hal", wgpu_level)
                .filter_module("naga", wgpu_level)
                .format_timestamp_millis()
                .init();
            log_msg!(
                warn,
                L082_LOG_FILE_FAIL,
                "path: {}, err: {}",
                log_path.display(),
                e
            );
        }
    }
}
/// Invoke `lurek.errorhandler()` if defined, otherwise build an `ErrorScreen` directly.
fn try_errorhandler_or_screen(lua: &Lua, err: &mlua::Error) -> ErrorScreen {
    let msg = format!("{}", err);
    log_msg!(error, L011_LUA_ERROR, "runtime: {}", msg);
    if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {
        if let Ok(handler) = lurek.get::<_, LuaFunction>("errorhandler") {
            match handler.call::<_, ()>(msg.clone()) {
                Ok(()) => {
                    return ErrorScreen::from_lua_error(err);
                }
                Err(handler_err) => {
                    let combined = format!(
                        "Error in lurek.errorhandler\nOriginal error: {}\n\nHandler error: {}",
                        msg, handler_err
                    );
                    return ErrorScreen::from_error(&combined);
                }
            }
        }
    }
    ErrorScreen::from_lua_error(err)
}
