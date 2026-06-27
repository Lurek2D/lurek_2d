//! This file owns the desktop runtime loop, from startup target selection through steady frame execution and shutdown.
//! It defines viewport helpers, splash-title utilities, startup-drop classification, and key rules for the splash screen.
//! `RunState` models running, fatal-error, and restarting modes, while `LurekApp` stores the live host-side app state.
//! That state includes window and surface handles, renderer and Lua ownership, hot-reload watchers, timing, and input.
//! GPU setup, present-mode selection, surface configuration, resize clamping, and vsync switching are centralized here.
//! Lua initialization also lives here, including VM creation, shared-state hookup, startup file loading, and callbacks.
//! Per-frame control is split across tick, update, render, splash render, and error render paths with deterministic order.
//! Window actions are deferred through local helpers so resize, focus, visibility, cursor, and fullscreen stay guarded.
//! The file owns weather-free host input routing for keyboard, mouse, text, wheel, touch, drag-drop, and window events.
//! Gamepad polling and vibration effects are handled here too, including slot assignment, naming, and feedback playback.
//! Hot reload for scripts, assets, and config files is coordinated here through watcher refresh and polling helpers.
//! Screenshot capture, auto-quit timers, perf logging, archive extraction, and restart flow are also app-level concerns.
//! The `ApplicationHandler` impl binds winit lifecycle callbacks to safe runtime operations and guarded Lua dispatch.
//! The outer `App` and `AppRunOptions` types provide bootstrap input, logger setup, and event-loop launch entrypoints.
//! Open this file when desktop host orchestration changes; splash, errors, HUD, and callback helpers live in siblings.
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
use crate::raycaster::{RaycasterBackground, RaycasterOverlayEffect};
use crate::render::renderer::{DrawMode, GradientDirection, RenderCommand, TextureData};
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
impl LurekApp {
    #[allow(clippy::too_many_arguments)]
    /// Build app runtime state and initialize filesystem watchers from startup config.
    pub fn new(
        config: Config,
        game_dir: PathBuf,
        conf_error: Option<String>,
        explicit_game_dir: bool,
        auto_screenshot_path: Option<PathBuf>,
        auto_screenshot_frames: u32,
        auto_screenshot_time: Option<f32>,
        auto_quit_frames: Option<u32>,
        auto_quit_time: Option<f32>,
        hidden_window: bool,
        window_pos: Option<(i32, i32)>,
    ) -> Self {
        let window_vsync_mode = if config.window.vsync { 1 } else { 0 };
        let mut conf_watcher = FileWatcher::new();
        conf_watcher.watch(game_dir.join("conf.toml"));
        let mut content_script_watcher = FileWatcher::new();
        let mut content_asset_watcher = FileWatcher::new();
        register_content_watchers(
            &game_dir,
            &mut content_script_watcher,
            &mut content_asset_watcher,
        );
        LurekApp {
            config,
            game_dir,
            window: None,
            surface: None,
            surface_format: wgpu::TextureFormat::Bgra8UnormSrgb,
            surface_alpha_mode: wgpu::CompositeAlphaMode::Auto,
            surface_present_modes: Vec::new(),
            surface_present_mode: wgpu::PresentMode::Fifo,
            surface_usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            renderer: None,
            lua: None,
            state: None,
            has_game: false,
            last_frame: Instant::now(),
            ready_fired: false,
            physics_accumulator: 0.0,
            fixed_update_accumulator: 0.0,
            fixed_update_deprecation_warned: false,
            prev_mouse: [false; 5],
            mouse_x: 0.0,
            mouse_y: 0.0,
            run_state: RunState::Running,
            debug_overlay: DebugOverlay::new(),
            conf_error,
            conf_watcher,
            content_script_watcher,
            content_asset_watcher,
            explicit_game_dir,
            window_vsync_mode,
            engine_fonts: None,
            splash_branding: None,
            splash_branding_failed: false,
            ctrl_held: false,
            lua_initialized: false,
            drag_hover: false,
            max_surface_dim: 4096,
            render_cmd_buf: Vec::new(),
            auto_parallax_buf: Vec::new(),
            auto_tilemap_buf: Vec::new(),
            auto_particle_cmd_buf: Vec::new(),
            auto_ui_cmd_buf: Vec::new(),
            auto_screenshot_path,
            auto_screenshot_frames,
            auto_screenshot_time,
            auto_screenshot_done: false,
            auto_screenshot_frame_count: 0,
            auto_screenshot_start: None,
            auto_quit_frames,
            auto_quit_time,
            auto_quit_done: false,
            auto_quit_frame_count: 0,
            auto_quit_start: None,
            hidden_window,
            window_pos,
            lurek_temp_dir: None,
            perf_report_started: Instant::now(),
            perf_frames: 0,
            perf_tick_ms_acc: 0.0,
            perf_update_ms_acc: 0.0,
            perf_render_ms_acc: 0.0,
            perf_log_enabled: std::env::var("LUREK_PERF_LOG").ok().as_deref() == Some("1"),
            diagnostics: AppDiagnostics::default(),
            callback_failure_overrides: HashMap::new(),
            pending_hot_reload_paths: Vec::new(),
            pending_hot_reload_deadline: None,
            hot_reload_debounce: DEFAULT_HOT_RELOAD_DEBOUNCE,
        }
    }
    /// Return the configured Lua callback timeout in milliseconds.
    fn callback_timeout_ms(&self) -> Option<f32> {
        self.config.performance.lua_callback_timeout_ms
    }

    /// Override one callback failure policy for deterministic tests and host tuning.
    pub fn set_callback_failure_policy_for_testing(
        &mut self,
        callback: &str,
        policy: CallbackFailurePolicy,
    ) {
        self.callback_failure_overrides
            .insert(callback.to_string(), policy);
    }

    fn callback_failure_policy(&self, callback: &str) -> CallbackFailurePolicy {
        self.callback_failure_overrides
            .get(callback)
            .copied()
            .unwrap_or(match callback {
                "ready" | "process_physics" | "fixedUpdate" | "process" | "process_late"
                | "draw" | "draw_ui" | "ui.update" => CallbackFailurePolicy::Fatal,
                _ => CallbackFailurePolicy::ReportOnly,
            })
    }

    fn push_callback_error(&mut self, record: CallbackErrorRecord) {
        if self.diagnostics.callback_errors.len() >= 32 {
            self.diagnostics.callback_errors.remove(0);
        }
        self.diagnostics.callback_errors.push(record);
    }

    fn push_window_report(&mut self, report: WindowRuntimeReport) {
        if report.is_empty() {
            return;
        }
        if self.diagnostics.window_reports.len() >= 32 {
            self.diagnostics.window_reports.remove(0);
        }
        self.diagnostics.window_reports.push(report);
    }

    fn push_input_report(&mut self, report: InputDispatchReport) {
        if self.diagnostics.input_reports.len() >= 32 {
            self.diagnostics.input_reports.remove(0);
        }
        self.diagnostics.input_reports.push(report);
    }

    fn push_hot_reload_report(&mut self, report: HotReloadReport) {
        if self.diagnostics.hot_reload_reports.len() >= 16 {
            self.diagnostics.hot_reload_reports.remove(0);
        }
        self.diagnostics.hot_reload_reports.push(report);
    }

    fn begin_input_report(
        &self,
        event_kind: &str,
        coordinates: Option<(f32, f32)>,
    ) -> InputDispatchReport {
        let mut order = vec![InputDispatchTarget::Platform];
        if shared_flag(&self.state, |st| st.auto_ui_input) {
            order.push(InputDispatchTarget::Ui);
        }
        order.push(InputDispatchTarget::Game);
        InputDispatchReport {
            event_kind: event_kind.to_string(),
            order,
            ui_consumed: false,
            callback_error: None,
            coordinates,
        }
    }

    fn record_last_error(&mut self, message: String, hint: Option<String>) {
        if let Some(state) = &self.state {
            state.borrow_mut().last_error = Some(crate::runtime::ErrorInfo {
                message,
                code: "app.callback".to_string(),
                category: "script".to_string(),
                hint,
            });
        }
    }

    fn handle_callback_error(&mut self, callback: &str, phase: &str, error: mlua::Error) -> bool {
        let policy = self.callback_failure_policy(callback);
        let message = error.to_string();
        self.record_last_error(
            format!("{} failed during {}: {}", callback, phase, message),
            Some("Check the Lua callback and recent host diagnostics.".to_string()),
        );
        self.push_callback_error(CallbackErrorRecord {
            callback: callback.to_string(),
            phase: phase.to_string(),
            message: message.clone(),
            policy,
        });
        if matches!(policy, CallbackFailurePolicy::Fatal) {
            let screen = if let Some(lua) = self.lua.as_ref() {
                try_errorhandler_or_screen(lua, &error)
            } else {
                ErrorScreen::from_lua_error(&error)
            };
            self.run_state = RunState::Error(screen);
            return true;
        }
        false
    }
    /// Open the native startup folder picker and try to load the selected game directory.
    fn browse_for_startup_game_dir(&mut self) {
        log::warn!("native startup folder picker is not built into this runtime build");
    }
    /// Load a startup target selected via drag-and-drop or the splash picker.
    fn load_startup_target_path(&mut self, path: &Path) {
        let report =
            classify_drop_startup_target_with_policy(path, &StartupTargetPolicy::default());
        for diagnostic in &report.diagnostics {
            match diagnostic {
                StartupTargetDiagnostic::SymlinkRejected(rejected) => {
                    log::warn!(
                        "startup path rejected due to symlink: {}",
                        rejected.display()
                    );
                }
                StartupTargetDiagnostic::MissingMainLua(dir) => {
                    log::warn!("startup path missing main.lua: {}", dir.display());
                }
                StartupTargetDiagnostic::ArchiveTooLarge {
                    path,
                    actual_bytes,
                    max_bytes,
                } => {
                    log::warn!(
                        "startup archive rejected: {} exceeds {} bytes (got {})",
                        path.display(),
                        max_bytes,
                        actual_bytes
                    );
                }
                StartupTargetDiagnostic::UnsafeArchiveEntry(entry) => {
                    log::warn!("startup archive rejected unsafe entry: {}", entry);
                }
            }
        }
        match report.target {
            DropStartupTarget::Archive => {
                log_msg!(info, L083_DROP_ARCHIVE, "{}", path.display());
                match LurekApp::extract_lurek_archive_with_policy(
                    path,
                    &StartupTargetPolicy::default(),
                ) {
                    Ok((dir, td)) => {
                        self.lurek_temp_dir = Some(td);
                        self.game_dir = dir;
                        self.explicit_game_dir = true;
                        self.restart_game();
                    }
                    Err(e) => {
                        log_msg!(warn, L084_DROP_ARCHIVE_FAIL, "{}: {}", path.display(), e);
                    }
                }
            }
            DropStartupTarget::GameDir(dir) => {
                if dir == path {
                    log_msg!(info, L044_DROP_GAME, "{}", path.display());
                } else {
                    log_msg!(info, L044_DROP_GAME, "parent folder: {}", dir.display());
                }
                self.lurek_temp_dir = None;
                self.game_dir = dir;
                self.explicit_game_dir = true;
                self.restart_game();
            }
            DropStartupTarget::Unsupported => {
                if path.is_dir() {
                    log_msg!(warn, L007_NO_MAIN_LUA, "no main.lua in: {}", path.display());
                }
            }
        }
    }

    fn reset_runtime_accumulators(&mut self) {
        self.ready_fired = false;
        self.physics_accumulator = 0.0;
        self.fixed_update_accumulator = 0.0;
        self.fixed_update_deprecation_warned = false;
        self.prev_mouse = [false; 5];
    }

    fn build_runtime_session(&self) -> Result<RuntimeSession, RuntimeSessionError> {
        let window_title = self.current_window_title();
        let mut shared_state = SharedState::new(
            self.config.window.width,
            self.config.window.height,
            &window_title,
            self.game_dir.clone(),
        );
        shared_state.runtime_mode = self.config.runtime.mode;
        if let Some(identity) = &self.config.identity {
            shared_state.filesystem_identity = identity.clone();
        }
        shared_state.window_state.vsync_mode = self.window_vsync_mode;
        shared_state.window = self.window.as_ref().map(Arc::clone);
        shared_state.physics_run.fixed_dt =
            1.0 / self.config.performance.physics_tick_rate.max(1) as f64;
        shared_state.physics_run.fixed_update_dt =
            match self.config.performance.fixed_update_tick_rate {
                Some(rate) if rate > 0 => 1.0 / rate as f64,
                _ => 0.0,
            };
        shared_state.set_configured_default_font(
            self.config.render.default_font_size,
            self.config.render.default_font_bold,
        );
        shared_state.frame_budget_warn_ms = self.config.performance.frame_budget_warn_ms;
        shared_state.lua_callback_timeout_ms = self.callback_timeout_ms();
        {
            let ws = &mut shared_state.window_state;
            ws.game_width = self
                .config
                .window
                .game_width
                .unwrap_or(self.config.window.width) as f32;
            ws.game_height = self
                .config
                .window
                .game_height
                .unwrap_or(self.config.window.height) as f32;
            ws.scale_mode_str = self.config.window.scale_mode.clone();
            let (ww, wh) = (shared_state.window_width, shared_state.window_height);
            recompute_viewport(ws, ww, wh);
        }
        let state = Rc::new(RefCell::new(shared_state));
        state.borrow_mut().load_default_fonts();
        let lua = match create_lua_vm(state.clone(), &self.config.modules) {
            Ok(lua) => lua,
            Err(error) => {
                log_msg!(error, L016_LUA_VM_INIT_FAIL, "{}", error);
                let summary = format!("Lua VM initialization failed: {}", error);
                return Err(RuntimeSessionError {
                    screen: ErrorScreen::from_error(&format!(
                        "Lua VM Initialization Failed\n{}",
                        error
                    )),
                    summary,
                    state: Some(state),
                });
            }
        };
        let main_lua = self.game_dir.join("main.lua");
        if main_lua.exists() {
            log_msg!(info, L003_GAME_LOADED, "{}", main_lua.display());
            let code = match std::fs::read_to_string(&main_lua) {
                Ok(code) => code,
                Err(error) => {
                    log_msg!(error, L017_MAIN_LUA_READ_FAIL, "{}", error);
                    return Err(RuntimeSessionError {
                        screen: ErrorScreen::from_error(&format!(
                            "Failed to read main.lua\n{}",
                            error
                        )),
                        summary: format!("Failed to read main.lua: {}", error),
                        state: Some(state),
                    });
                }
            };
            if let Err(error) = lua.load(&code).set_name("main.lua").exec() {
                log_msg!(error, L011_LUA_ERROR, "main.lua: {}", error);
                return Err(RuntimeSessionError {
                    screen: ErrorScreen::from_lua_error(&error),
                    summary: format!("main.lua execution failed: {}", error),
                    state: Some(state),
                });
            }
            if let Err(error) =
                call_lua_callback_checked_with_timeout(&lua, "init", (), self.callback_timeout_ms())
            {
                return Err(RuntimeSessionError {
                    screen: try_errorhandler_or_screen(&lua, &error),
                    summary: format!("lurek.init failed: {}", error),
                    state: Some(state),
                });
            }
            return Ok(RuntimeSession {
                lua,
                state,
                has_game: true,
            });
        }
        if self.explicit_game_dir {
            log_msg!(warn, L007_NO_MAIN_LUA, "{}", self.game_dir.display());
        }
        log_msg!(info, L006_SPLASH_SCREEN);
        Ok(RuntimeSession {
            lua,
            state,
            has_game: false,
        })
    }

    fn apply_runtime_session(&mut self, session: RuntimeSession) {
        let window_title = self.current_window_title();
        if let Some(window) = &self.window {
            window.set_title(&window_title);
        }
        self.lua = Some(session.lua);
        self.state = Some(session.state);
        self.has_game = session.has_game;
        self.run_state = RunState::Running;
    }

    /// Rebuild content file watchers after a game directory change.
    fn refresh_content_watchers(&mut self) {
        let (script_watcher, asset_watcher) = build_content_watchers(&self.game_dir);
        self.content_script_watcher = script_watcher;
        self.content_asset_watcher = asset_watcher;
    }

    fn reload_game_with_report(
        &mut self,
        trigger: &str,
        changed_paths: Vec<PathBuf>,
    ) -> ReloadReport {
        let mut report = ReloadReport {
            trigger: trigger.to_string(),
            changed_paths,
            phases: vec!["stop_callbacks".to_string()],
            reloaded: false,
            rolled_back: false,
            failure: None,
        };
        let old_lua = self.lua.take();
        let old_state = self.state.take();
        let old_has_game = self.has_game;
        let old_prev_mouse = self.prev_mouse;
        let old_run_state = std::mem::replace(&mut self.run_state, RunState::Restarting);
        self.reset_runtime_accumulators();
        report.phases.push("build_runtime".to_string());
        match self.build_runtime_session() {
            Ok(session) => {
                report.phases.push("refresh_watchers".to_string());
                self.refresh_content_watchers();
                report.phases.push("commit".to_string());
                self.apply_runtime_session(session);
                report.reloaded = true;
            }
            Err(error) => {
                report.failure = Some(error.summary.clone());
                if old_lua.is_some() || old_state.is_some() {
                    report.phases.push("rollback".to_string());
                    self.lua = old_lua;
                    self.state = old_state;
                    self.has_game = old_has_game;
                    self.prev_mouse = old_prev_mouse;
                    self.run_state = old_run_state;
                    report.rolled_back = true;
                    self.record_last_error(
                        format!("reload failed: {}", error.summary),
                        Some("The previous runtime session was restored.".to_string()),
                    );
                } else {
                    self.lua = None;
                    self.state = error.state;
                    self.has_game = false;
                    self.run_state = RunState::Error(error.screen);
                }
            }
        }
        report
    }
    /// Record frame phase timings and log a periodic PERF summary when enabled.
    fn perf_record_frame(&mut self, tick_ms: f64, update_ms: f64, render_ms: f64) {
        if !self.perf_log_enabled {
            return;
        }
        self.perf_frames += 1;
        self.perf_tick_ms_acc += tick_ms;
        self.perf_update_ms_acc += update_ms;
        self.perf_render_ms_acc += render_ms;
        let elapsed = self.perf_report_started.elapsed().as_secs_f64();
        if elapsed < 1.0 {
            return;
        }
        let n = (self.perf_frames as f64).max(1.0);
        log::info!(
            "PERF frame_cpu_ms avg: tick={:.3}, update={:.3}, render={:.3}, total={:.3}, fps_est={:.1}",
            self.perf_tick_ms_acc / n,
            self.perf_update_ms_acc / n,
            self.perf_render_ms_acc / n,
            (self.perf_tick_ms_acc + self.perf_update_ms_acc + self.perf_render_ms_acc) / n,
            n / elapsed,
        );
        self.perf_report_started = Instant::now();
        self.perf_frames = 0;
        self.perf_tick_ms_acc = 0.0;
        self.perf_update_ms_acc = 0.0;
        self.perf_render_ms_acc = 0.0;
    }
    /// Return `true` when no game is loaded and the splash screen should display.
    fn wants_splash_screen(&self) -> bool {
        !self.explicit_game_dir && !self.game_dir.join("main.lua").exists()
    }
    /// Return the window title string based on splash or game mode.
    fn current_window_title(&self) -> String {
        if self.wants_splash_screen() {
            splash_window_title(&self.config.window.title)
        } else {
            self.config.window.title.clone()
        }
    }
    /// Select supported present mode and normalized vsync flag from requested mode.
    pub fn resolve_present_mode(
        available_modes: &[wgpu::PresentMode],
        requested_mode: i32,
    ) -> (wgpu::PresentMode, i32) {
        let supports = |mode| available_modes.contains(&mode);
        match requested_mode {
            -1 if supports(wgpu::PresentMode::Mailbox) => {
                return (wgpu::PresentMode::Mailbox, -1);
            }
            0 if supports(wgpu::PresentMode::Immediate) => {
                return (wgpu::PresentMode::Immediate, 0);
            }
            _ if supports(wgpu::PresentMode::Fifo) => {
                return (wgpu::PresentMode::Fifo, 1);
            }
            _ => {}
        }
        if requested_mode == 0 && supports(wgpu::PresentMode::AutoNoVsync) {
            return (wgpu::PresentMode::AutoNoVsync, 0);
        }
        if requested_mode != 0 && supports(wgpu::PresentMode::AutoVsync) {
            return (wgpu::PresentMode::AutoVsync, 1);
        }
        if supports(wgpu::PresentMode::Immediate) {
            return (wgpu::PresentMode::Immediate, 0);
        }
        if supports(wgpu::PresentMode::Mailbox) {
            return (wgpu::PresentMode::Mailbox, -1);
        }
        if supports(wgpu::PresentMode::Fifo) {
            return (wgpu::PresentMode::Fifo, 1);
        }
        if requested_mode == 0 {
            (wgpu::PresentMode::AutoNoVsync, 0)
        } else {
            (wgpu::PresentMode::AutoVsync, 1)
        }
    }
    /// Clamp surface dimensions to the GPU maximum.
    fn clamp_surface_dims(&self, w: u32, h: u32) -> (u32, u32) {
        let m = self.max_surface_dim.max(1);
        (w.max(1).min(m), h.max(1).min(m))
    }
    /// Build a wgpu `SurfaceConfiguration` from current format, mode, and dimensions.
    fn surface_configuration(&self, width: u32, height: u32) -> wgpu::SurfaceConfiguration {
        wgpu::SurfaceConfiguration {
            usage: self.surface_usage,
            format: self.surface_format,
            width,
            height,
            present_mode: self.surface_present_mode,
            alpha_mode: self.surface_alpha_mode,
            view_formats: vec![],
            desired_maximum_frame_latency: 2,
        }
    }
    /// Apply a vsync mode change and reconfigure the surface present mode.
    fn apply_vsync_mode(&mut self, requested_mode: i32) {
        let (present_mode, vsync_mode) =
            Self::resolve_present_mode(&self.surface_present_modes, requested_mode);
        self.surface_present_mode = present_mode;
        self.window_vsync_mode = vsync_mode;
        self.config.window.vsync = vsync_mode != 0;
        if let Some(state) = &self.state {
            state.borrow_mut().window_state.vsync_mode = vsync_mode;
        }
        self.reconfigure_surface();
    }
    /// Create the wgpu instance, adapter, device, surface, and renderer.
    fn try_init_gpu(&mut self, window: Arc<Window>) -> Result<(), AppStartupError> {
        let t0 = Instant::now();
        let width = self.config.window.width;
        let height = self.config.window.height;
        let backend_name = self.config.render.backend.clone();
        let power_name = self.config.render.power_preference.clone();
        let backends = wgpu::util::backend_bits_from_env().unwrap_or(
            match self.config.render.backend.as_str() {
                "dx12" => wgpu::Backends::DX12,
                "vulkan" => wgpu::Backends::VULKAN,
                "metal" => wgpu::Backends::METAL,
                _ => wgpu::Backends::PRIMARY,
            },
        );
        let power_preference = match self.config.render.power_preference.as_str() {
            "low" => wgpu::PowerPreference::LowPower,
            "none" => wgpu::PowerPreference::None,
            _ => wgpu::PowerPreference::HighPerformance,
        };
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
            backends,
            ..Default::default()
        });
        let surface: wgpu::Surface<'static> = instance
            .create_surface(Arc::clone(&window))
            .map_err(|error| AppStartupError {
                stage: AppStartupStage::Surface,
                backend: backend_name.clone(),
                power_preference: power_name.clone(),
                details: format!("Failed to create wgpu surface: {}", error),
            })?;
        let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions {
            power_preference,
            compatible_surface: Some(&surface),
            force_fallback_adapter: false,
        }))
        .ok_or_else(|| AppStartupError {
            stage: AppStartupStage::Adapter,
            backend: backend_name.clone(),
            power_preference: power_name.clone(),
            details: "No compatible GPU adapter found. Try installing a display driver."
                .to_string(),
        })?;
        let adapter_info = adapter.get_info();
        log_msg!(
            info,
            L033_GPU_ADAPTER,
            "{} ({:?}, {:?}) [backend={}, power={}]",
            adapter_info.name,
            adapter_info.backend,
            adapter_info.device_type,
            self.config.render.backend,
            self.config.render.power_preference,
        );
        let (device, queue) = pollster::block_on(adapter.request_device(
            &wgpu::DeviceDescriptor {
                label: Some("Lurek2D Device"),
                required_features: wgpu::Features::empty(),
                required_limits: {
                    let mut limits = wgpu::Limits::downlevel_defaults();
                    limits.max_texture_dimension_2d = adapter
                        .limits()
                        .max_texture_dimension_2d
                        .max(limits.max_texture_dimension_2d);
                    limits
                },
                memory_hints: Default::default(),
            },
            None,
        ))
        .map_err(|error| AppStartupError {
            stage: AppStartupStage::Device,
            backend: backend_name.clone(),
            power_preference: power_name.clone(),
            details: format!(
                "Failed to create wgpu device for adapter '{}': {}",
                adapter_info.name, error
            ),
        })?;
        let caps = surface.get_capabilities(&adapter);
        if caps.formats.is_empty() {
            return Err(AppStartupError {
                stage: AppStartupStage::Device,
                backend: backend_name,
                power_preference: power_name,
                details: format!(
                    "Adapter '{}' reported no compatible surface formats",
                    adapter_info.name
                ),
            });
        }
        let surface_format = caps
            .formats
            .iter()
            .copied()
            .find(|f| f.is_srgb())
            .unwrap_or(caps.formats[0]);
        self.surface_format = surface_format;
        self.surface_alpha_mode = caps.alpha_modes[0];
        self.surface_present_modes = caps.present_modes.clone();
        self.surface_usage = if caps.usages.contains(wgpu::TextureUsages::COPY_SRC) {
            wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::COPY_SRC
        } else {
            log_msg!(warn, L070_SURFACE_NO_READBACK);
            wgpu::TextureUsages::RENDER_ATTACHMENT
        };
        (self.surface_present_mode, self.window_vsync_mode) =
            Self::resolve_present_mode(&self.surface_present_modes, self.window_vsync_mode);
        self.max_surface_dim = device.limits().max_texture_dimension_2d;
        log_msg!(info, L034_GPU_TEX_DIM, "{}", self.max_surface_dim);
        let (cw, ch) = self.clamp_surface_dims(width, height);
        if cw != width || ch != height {
            log_msg!(
                warn,
                L023_GPU_TEX_TOO_SMALL,
                "initial window {}x{} exceeds GPU max {}; clamping to {}x{}",
                width,
                height,
                self.max_surface_dim,
                cw,
                ch
            );
        }
        surface.configure(&device, &self.surface_configuration(cw, ch));
        let renderer = GpuRenderer::new(device, queue, surface_format, cw, ch);
        self.surface = Some(surface);
        self.renderer = Some(renderer);
        self.window = Some(window);
        log_msg!(
            info,
            L035_GPU_INIT,
            "{:.0?} (format={:?}, present={:?}, {}x{})",
            t0.elapsed(),
            surface_format,
            self.surface_present_mode,
            width,
            height,
        );
        Ok(())
    }
    /// Create the Lua VM, load main.lua, and fire `lurek.init()`.
    pub fn init_lua(&mut self) {
        self.reset_runtime_accumulators();
        if let Some(conf_err) = self.conf_error.take() {
            self.run_state = RunState::Error(ErrorScreen::from_error(&format!(
                "Configuration Error\n{}",
                conf_err
            )));
            return;
        }
        match self.build_runtime_session() {
            Ok(session) => self.apply_runtime_session(session),
            Err(error) => {
                self.state = error.state;
                self.lua = None;
                self.has_game = false;
                self.run_state = RunState::Error(error.screen);
            }
        }
    }
    /// Advance clocks, poll input devices, and update the debug overlay flag.
    fn tick_frame(&mut self) {
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            let dt = st.clock.tick();
            st.delta_time = dt;
            st.total_time = st.clock.total();
            st.fps = st.clock.fps();
            st.keyboard.begin_frame();
            st.mouse.begin_frame();
            st.touch.begin_frame();
            for gp in &mut st.gamepads {
                gp.begin_frame();
            }
            self.debug_overlay.enabled = st.debug_overlay_enabled;
        }
        self.apply_pending_window_actions();
    }

    fn validate_window_runtime_request(
        &self,
        pending_size: Option<(u32, u32)>,
        pending_scale_mode: Option<String>,
        pending_vsync: Option<i32>,
    ) -> WindowRuntimeValidation {
        let mut report = WindowRuntimeReport::default();
        let size = pending_size.map(|(width, height)| {
            let clamped = self.clamp_surface_dims(width, height);
            if clamped != (width, height) {
                report.clamped_size = Some(((width, height), clamped));
            }
            clamped
        });
        let scale_mode = pending_scale_mode.and_then(|mode| {
            if SUPPORTED_SCALE_MODES.contains(&mode.as_str()) {
                Some(mode)
            } else {
                report.invalid_scale_mode = Some(mode);
                None
            }
        });
        let vsync_mode = pending_vsync.map(|requested| {
            let (_, normalized) =
                Self::resolve_present_mode(&self.surface_present_modes, requested);
            if normalized != requested {
                report.vsync_adjustment = Some((requested, normalized));
            }
            normalized
        });
        (size, scale_mode, vsync_mode, report)
    }

    /// Expose window-runtime validation as a stable test seam.
    pub fn inspect_window_runtime_request_for_testing(
        &self,
        pending_size: Option<(u32, u32)>,
        pending_scale_mode: Option<String>,
        pending_vsync: Option<i32>,
    ) -> WindowRuntimeReport {
        let (_, _, _, report) =
            self.validate_window_runtime_request(pending_size, pending_scale_mode, pending_vsync);
        report
    }

    /// Apply deferred window property changes requested by Lua during the frame.
    fn apply_pending_window_actions(&mut self) {
        let window = match &self.window {
            Some(w) => w.clone(),
            None => return,
        };
        let state = match &self.state {
            Some(s) => s.clone(),
            None => return,
        };
        let (
            pending_title,
            pending_fullscreen,
            pending_fullscreen_type,
            pending_position,
            pending_display_index,
            pending_size,
            pending_minimize,
            pending_maximize,
            pending_restore,
            pending_focus,
            pending_attention,
            pending_icon_path,
            pending_vsync,
            pending_close,
            text_input_enabled,
            mouse_visible,
            mouse_grabbed,
            mouse_relative_mode,
            mouse_cursor,
            pending_cursor_position,
            pending_scale_mode,
        ) = {
            let mut st = state.borrow_mut();
            (
                st.window_state.pending_title.take(),
                st.window_state.pending_fullscreen.take(),
                st.window_state.pending_fullscreen_type,
                st.window_state.pending_position.take(),
                st.window_state.pending_display_index.take(),
                st.window_state.pending_size.take(),
                std::mem::take(&mut st.window_state.pending_minimize),
                std::mem::take(&mut st.window_state.pending_maximize),
                std::mem::take(&mut st.window_state.pending_restore),
                std::mem::take(&mut st.window_state.pending_focus),
                std::mem::take(&mut st.window_state.pending_attention),
                st.window_state.pending_icon_path.take(),
                st.window_state.pending_vsync.take(),
                std::mem::take(&mut st.window_state.pending_close),
                st.keyboard.has_text_input(),
                st.mouse.is_visible(),
                st.mouse.is_grabbed(),
                st.mouse.get_relative_mode(),
                st.mouse.get_cursor(),
                st.mouse.take_pending_position(),
                st.window_state.pending_scale_mode.take(),
            )
        };
        let (pending_size, pending_scale_mode, pending_vsync, mut runtime_report) =
            self.validate_window_runtime_request(pending_size, pending_scale_mode, pending_vsync);
        if let Some(title) = pending_title {
            window.set_title(&title);
            state.borrow_mut().window_title = title;
        }
        if let Some(fullscreen) = pending_fullscreen {
            if fullscreen {
                use winit::window::Fullscreen;
                match pending_fullscreen_type {
                    FullscreenType::Desktop => {
                        window.set_fullscreen(Some(Fullscreen::Borderless(None)));
                    }
                    FullscreenType::Exclusive => {
                        if let Some(monitor) = window.current_monitor() {
                            if let Some(mode) = monitor.video_modes().next() {
                                window.set_fullscreen(Some(Fullscreen::Exclusive(mode)));
                            }
                        }
                    }
                }
                state.borrow_mut().window_state.fullscreen = true;
                state.borrow_mut().window_state.fullscreen_type = pending_fullscreen_type;
            } else {
                window.set_fullscreen(None);
                state.borrow_mut().window_state.fullscreen = false;
            }
        }
        if let Some((x, y)) = pending_position {
            window.set_outer_position(winit::dpi::PhysicalPosition::new(x, y));
        }
        if let Some(display_index) = pending_display_index {
            if !move_window_to_display(window.as_ref(), display_index) {
                log::warn!("Requested display index {} is not available", display_index);
                runtime_report.invalid_display_index = Some(display_index);
            }
        }
        if let Some((w, h)) = pending_size {
            let _ = window.request_inner_size(winit::dpi::PhysicalSize::new(w, h));
        }
        if pending_minimize {
            window.set_minimized(true);
        }
        if pending_maximize {
            window.set_maximized(true);
        }
        if pending_restore {
            window.set_minimized(false);
            window.set_maximized(false);
        }
        if pending_focus {
            window.focus_window();
        }
        if pending_attention {
            window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
        }
        if let Some(icon_path) = pending_icon_path {
            let icon = {
                let st = state.borrow();
                load_window_icon(&st.game_dir, &icon_path)
            };
            if let Some(icon) = icon {
                window.set_window_icon(Some(icon));
            }
        }
        if let Some(vsync_mode) = pending_vsync {
            self.apply_vsync_mode(vsync_mode);
        }
        window.set_ime_allowed(text_input_enabled);
        let requested_grab_mode = if mouse_relative_mode {
            CursorGrabMode::Locked
        } else if mouse_grabbed {
            CursorGrabMode::Confined
        } else {
            CursorGrabMode::None
        };
        if let Err(error) = window.set_cursor_grab(requested_grab_mode) {
            if mouse_relative_mode {
                if let Err(confined_error) = window.set_cursor_grab(CursorGrabMode::Confined) {
                    log_msg!(debug, L071_CURSOR_GRAB_FAIL, "{}", confined_error);
                }
            } else if mouse_grabbed {
                log_msg!(debug, L072_CURSOR_GRAB_LOCK_FAIL, "{}", error);
            }
        }
        window.set_cursor_visible(if mouse_relative_mode {
            false
        } else {
            mouse_visible
        });
        window.set_cursor(system_cursor_to_winit_cursor(mouse_cursor));
        if let Some((x, y)) = pending_cursor_position {
            let cursor_position = winit::dpi::PhysicalPosition::new(x as f64, y as f64);
            if let Err(error) = window.set_cursor_position(cursor_position) {
                log_msg!(debug, L073_CURSOR_POS_FAIL, "{}", error);
            }
        }
        if pending_close {
            state.borrow_mut().quit_requested = true;
        }
        if let Some(new_mode) = pending_scale_mode {
            if let Some(state) = &self.state {
                let mut st = state.borrow_mut();
                st.window_state.scale_mode_str = new_mode;
                let (ww, wh) = (st.window_width, st.window_height);
                recompute_viewport(&mut st.window_state, ww, wh);
            }
        }
        self.push_window_report(runtime_report);
    }
    /// Run the full game-update sequence: physics, process, draw, and overlay.
    fn game_update(&mut self) {
        let Some(state) = self.state.as_ref().cloned() else {
            return;
        };
        if self.lua.is_none() {
            return;
        }
        let callback_timeout_ms = self.callback_timeout_ms();
        if self.auto_screenshot_path.is_some() && !self.auto_screenshot_done {
            if self.auto_screenshot_frame_count == 0 {
                self.auto_screenshot_start = Some(Instant::now());
            }
            self.auto_screenshot_frame_count += 1;
        }
        if (self.auto_quit_frames.is_some() || self.auto_quit_time.is_some())
            && !self.auto_quit_done
        {
            if self.auto_quit_frame_count == 0 {
                self.auto_quit_start = Some(Instant::now());
            }
            self.auto_quit_frame_count += 1;
        }
        if !self.ready_fired {
            self.ready_fired = true;
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "ready", (), callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("ready", "frame.ready", error) {
                    return;
                }
                return;
            }
        }
        let dt = state.borrow().clock.delta();
        let mut frame_profile = crate::runtime::FrameProfile::default();
        {
            let phase_start = Instant::now();
            let fixed_dt = state.borrow().physics_run.fixed_dt;
            self.physics_accumulator += dt;
            let max_steps = state.borrow().physics_run.max_steps as usize;
            let mut steps = 0;
            while self.physics_accumulator >= fixed_dt && steps < max_steps {
                self.physics_accumulator -= fixed_dt;
                steps += 1;
                let error = {
                    let lua = self.lua.as_ref().expect("lua checked above");
                    call_lua_callback_checked_with_timeout(
                        lua,
                        "process_physics",
                        fixed_dt,
                        callback_timeout_ms,
                    )
                    .err()
                };
                if let Some(error) = error {
                    if self.handle_callback_error("process_physics", "frame.process_physics", error)
                    {
                        return;
                    }
                    return;
                }
            }
            frame_profile.process_physics_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let fixed_dt = state.borrow().physics_run.fixed_update_dt;
            if fixed_dt > 0.0 {
                let has_fixed_update = self
                    .lua
                    .as_ref()
                    .map(|lua| has_lua_callback(lua, "fixedUpdate"))
                    .unwrap_or(false);
                if !self.fixed_update_deprecation_warned && has_fixed_update {
                    log::warn!(
                        "lurek.fixedUpdate(dt) is deprecated; use lurek.process_physics(dt)"
                    );
                    self.fixed_update_deprecation_warned = true;
                }
                self.fixed_update_accumulator += dt;
                let max_steps = 8;
                let mut steps = 0;
                while self.fixed_update_accumulator >= fixed_dt && steps < max_steps {
                    self.fixed_update_accumulator -= fixed_dt;
                    steps += 1;
                    let error = {
                        let lua = self.lua.as_ref().expect("lua checked above");
                        call_lua_callback_checked_with_timeout(
                            lua,
                            "fixedUpdate",
                            fixed_dt,
                            callback_timeout_ms,
                        )
                        .err()
                    };
                    if let Some(error) = error {
                        if self.handle_callback_error("fixedUpdate", "frame.fixed_update", error) {
                            return;
                        }
                        return;
                    }
                }
            }
            frame_profile.fixed_update_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "process", dt, callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("process", "frame.process", error) {
                    return;
                }
                return;
            }
            frame_profile.process_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "process_late", dt, callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("process_late", "frame.process_late", error) {
                    return;
                }
                return;
            }
            frame_profile.process_late_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        if shared_flag(&self.state, |st| st.auto_ui_update) {
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_ui_update(lua, dt as f32, callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("ui.update", "frame.ui_update", error) {
                    return;
                }
                return;
            }
        }
        {
            let mut s = state.borrow_mut();
            s.render_commands.clear();
            s.raycaster_output = None;
        }
        {
            let s = state.borrow();
            let cam_x = s.camera.position.x;
            let cam_y = s.camera.position.y;
            let screen_w = s.window_state.game_width;
            let screen_h = s.window_state.game_height;
            self.auto_parallax_buf.clear();
            self.auto_parallax_buf
                .extend(s.auto_parallax_layers.iter().filter_map(|w| w.upgrade()));
            drop(s);
            for rc in &self.auto_parallax_buf {
                let cmds = rc
                    .borrow()
                    .generate_render_commands(cam_x, cam_y, screen_w, screen_h);
                state.borrow_mut().render_commands.extend(cmds);
            }
            state
                .borrow_mut()
                .auto_parallax_layers
                .retain(|w| w.upgrade().is_some());
        }
        {
            let s = state.borrow();
            let cam_x = s.camera.position.x;
            let cam_y = s.camera.position.y;
            let cam_w = s.window_state.game_width;
            let cam_h = s.window_state.game_height;
            self.auto_tilemap_buf.clear();
            self.auto_tilemap_buf
                .extend(s.auto_tilemaps.iter().filter_map(|w| w.upgrade()));
            drop(s);
            for rc in &self.auto_tilemap_buf {
                let cmds = rc
                    .borrow()
                    .generate_render_commands(0.0, 0.0, cam_x, cam_y, cam_w, cam_h);
                state.borrow_mut().render_commands.extend(cmds);
            }
            state
                .borrow_mut()
                .auto_tilemaps
                .retain(|w| w.upgrade().is_some());
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "draw", (), callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("draw", "frame.draw", error) {
                    return;
                }
                return;
            }
            frame_profile.draw_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let scene_opt = state.borrow_mut().raycaster_output.take();
            if let Some(scene) = scene_opt {
                fn push_raycaster_background_commands(
                    cmds: &mut Vec<RenderCommand>,
                    background: &RaycasterBackground,
                    width: f32,
                    height: f32,
                ) {
                    match background {
                        RaycasterBackground::Solid { color } => {
                            let [r, g, b, a] = *color;
                            cmds.push(RenderCommand::SetColor(r, g, b, a));
                            cmds.push(RenderCommand::Rectangle {
                                mode: DrawMode::Fill,
                                x: 0.0,
                                y: 0.0,
                                w: width,
                                h: height,
                            });
                        }
                        RaycasterBackground::VerticalGradient { top, bottom } => {
                            cmds.push(RenderCommand::DrawGradientRect {
                                x: 0.0,
                                y: 0.0,
                                w: width,
                                h: height,
                                color1: *top,
                                color2: *bottom,
                                direction: GradientDirection::Vertical,
                            });
                        }
                        RaycasterBackground::Skybox {
                            texture_key,
                            tint,
                            offset,
                        } => {
                            cmds.push(RenderCommand::DrawTexturedQuad {
                                corners: [
                                    crate::math::Vec2::new(0.0, 0.0),
                                    crate::math::Vec2::new(width, 0.0),
                                    crate::math::Vec2::new(width, height),
                                    crate::math::Vec2::new(0.0, height),
                                ],
                                uvs: [
                                    crate::math::Vec2::new(*offset, 0.0),
                                    crate::math::Vec2::new(*offset + 1.0, 0.0),
                                    crate::math::Vec2::new(*offset + 1.0, 1.0),
                                    crate::math::Vec2::new(*offset, 1.0),
                                ],
                                corner_w: [1.0, 1.0, 1.0, 1.0],
                                texture_key: *texture_key,
                                color: *tint,
                            });
                        }
                    }
                }

                fn push_raycaster_overlay_commands(
                    cmds: &mut Vec<RenderCommand>,
                    overlays: &[RaycasterOverlayEffect],
                    width: f32,
                    height: f32,
                ) {
                    for overlay in overlays {
                        match *overlay {
                            RaycasterOverlayEffect::Fog { mut color, density } => {
                                color[3] = (color[3] * density.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                                let [r, g, b, a] = color;
                                cmds.push(RenderCommand::SetColor(r, g, b, a));
                                cmds.push(RenderCommand::Rectangle {
                                    mode: DrawMode::Fill,
                                    x: 0.0,
                                    y: 0.0,
                                    w: width,
                                    h: height,
                                });
                            }
                            RaycasterOverlayEffect::Snow {
                                color,
                                density,
                                wind,
                            } => {
                                let count = ((width * height * density.clamp(0.0, 2.0)) / 850.0)
                                    .round()
                                    .clamp(0.0, 800.0)
                                    as u32;
                                let [r, g, b, a] = color;
                                cmds.push(RenderCommand::SetColor(r, g, b, a));
                                let mut seed = 0x9e37_79b9_u32
                                    ^ (width.max(1.0) as u32).rotate_left(8)
                                    ^ height.max(1.0) as u32;
                                let wind_px = (wind * 4.0).round();
                                for _ in 0..count {
                                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                                    let x = (seed % width.max(1.0) as u32) as f32;
                                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                                    let y = (seed % height.max(1.0) as u32) as f32;
                                    let len = 2.0 + (seed % 4) as f32;
                                    cmds.push(RenderCommand::Line {
                                        x1: x,
                                        y1: y,
                                        x2: x + wind_px,
                                        y2: y + len,
                                    });
                                }
                            }
                        }
                    }
                }

                #[derive(Clone)]
                /// Screen-space textured quad with depth used for raycaster depth sorting.
                struct DepthQuad {
                    /// Quad corners in screen space.
                    corners: [crate::math::Vec2; 4],
                    /// UV coordinates per corner.
                    uvs: [crate::math::Vec2; 4],
                    /// Reciprocal depth values per corner for perspective-correct interpolation.
                    corner_w: [f32; 4],
                    /// Texture key used for textured draw.
                    texture_key: TextureKey,
                    /// Per-quad tint/light colour multiplier.
                    color: [f32; 4],
                    /// Depth key used for painter-style ordering.
                    depth: f32,
                }
                /// Depth-sorted render item used by the raycaster composition path.
                enum DepthItem {
                    /// Textured wall/floor/ceiling quad.
                    Quad(DepthQuad),
                    /// Mesh model with depth key.
                    Model(crate::render::Mesh, f32),
                }
                let mut depth_items: Vec<DepthItem> = Vec::with_capacity(scene.quad_count());
                for wall in &scene.walls {
                    if let Some(key) = wall.texture_key {
                        depth_items.push(DepthItem::Quad(DepthQuad {
                            corners: wall.corners,
                            uvs: wall.uvs,
                            corner_w: wall.corner_w,
                            texture_key: key,
                            color: wall.light,
                            depth: wall.depth,
                        }));
                    }
                }
                for floor in &scene.floors {
                    if let Some(key) = floor.texture_key {
                        depth_items.push(DepthItem::Quad(DepthQuad {
                            corners: floor.corners,
                            uvs: floor.uvs,
                            corner_w: floor.corner_w,
                            texture_key: key,
                            color: floor.light,
                            depth: floor.depth,
                        }));
                    }
                }
                for ceil in &scene.ceilings {
                    if let Some(key) = ceil.texture_key {
                        depth_items.push(DepthItem::Quad(DepthQuad {
                            corners: ceil.corners,
                            uvs: ceil.uvs,
                            corner_w: ceil.corner_w,
                            texture_key: key,
                            color: ceil.light,
                            depth: ceil.depth,
                        }));
                    }
                }
                for sprite in &scene.sprites {
                    depth_items.push(DepthItem::Quad(DepthQuad {
                        corners: sprite.corners,
                        uvs: sprite.uvs,
                        corner_w: [sprite.depth, sprite.depth, sprite.depth, sprite.depth],
                        texture_key: sprite.texture_key,
                        color: sprite.light,
                        depth: sprite.depth,
                    }));
                }
                for model in &scene.models {
                    depth_items.push(DepthItem::Model(model.mesh.clone(), model.depth));
                }
                depth_items.sort_by(|a, b| {
                    let ad = match a {
                        DepthItem::Quad(q) => q.depth,
                        DepthItem::Model(_, d) => *d,
                    };
                    let bd = match b {
                        DepthItem::Quad(q) => q.depth,
                        DepthItem::Model(_, d) => *d,
                    };
                    bd.partial_cmp(&ad).unwrap_or(std::cmp::Ordering::Equal)
                });
                let mut s = state.borrow_mut();
                if let Some(background) = &scene.background {
                    push_raycaster_background_commands(
                        &mut s.render_commands,
                        background,
                        scene.screen_width,
                        scene.screen_height,
                    );
                }
                for item in depth_items {
                    match item {
                        DepthItem::Quad(dq) => {
                            s.render_commands.push(RenderCommand::DrawTexturedQuad {
                                corners: dq.corners,
                                uvs: dq.uvs,
                                corner_w: dq.corner_w,
                                texture_key: dq.texture_key,
                                color: dq.color,
                            });
                        }
                        DepthItem::Model(mesh, _) => {
                            s.render_commands.push(RenderCommand::DrawMeshTransient {
                                mesh,
                                x: 0.0,
                                y: 0.0,
                                rotation: 0.0,
                                sx: 1.0,
                                sy: 1.0,
                                ox: 0.0,
                                oy: 0.0,
                            });
                        }
                    }
                }
                push_raycaster_overlay_commands(
                    &mut s.render_commands,
                    &scene.overlays,
                    scene.screen_width,
                    scene.screen_height,
                );
            }
        }
        {
            self.auto_particle_cmd_buf.clear();
            {
                let s = state.borrow();
                for ps in s.particle_systems.values() {
                    self.auto_particle_cmd_buf
                        .extend(ps.generate_render_commands());
                }
            }
            state
                .borrow_mut()
                .render_commands
                .extend(self.auto_particle_cmd_buf.iter().cloned());
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "draw_ui", (), callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("draw_ui", "frame.draw_ui", error) {
                    return;
                }
                return;
            }
            frame_profile.draw_ui_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            self.auto_ui_cmd_buf.clear();
            let ui_ctx = {
                let st = state.borrow();
                st.auto_ui_ctx.as_ref().and_then(|w| w.upgrade())
            };
            if let Some(rc) = ui_ctx {
                let st = state.borrow();
                if let Some(font_key) = st.active_font.or(st.default_font) {
                    self.auto_ui_cmd_buf.extend(
                        rc.borrow_mut()
                            .build_render_commands_with_fonts(font_key, &st.fonts),
                    );
                }
            }
            state
                .borrow_mut()
                .render_commands
                .extend(self.auto_ui_cmd_buf.iter().cloned());
        }
        let (fps, draw_calls, w) = {
            let st = state.borrow();
            (st.fps, st.render_stats.draw_calls, st.window_width)
        };
        let overlay_font = state.borrow().active_font.or(state.borrow().default_font);
        let overlay_cmds =
            self.debug_overlay
                .build_render_commands(w, fps, draw_calls, overlay_font);
        if !overlay_cmds.is_empty() {
            state.borrow_mut().render_commands.extend(overlay_cmds);
        }
        if let Some(font_key) = overlay_font {
            let shader_err = {
                let st = state.borrow();
                if st.shader_error_display_enabled {
                    st.last_shader_compile_error.clone()
                } else {
                    None
                }
            };
            if let Some(err) = shader_err {
                state
                    .borrow_mut()
                    .render_commands
                    .push(RenderCommand::Print {
                        font_key,
                        text: format!("Shader error: {}", err),
                        x: 12.0,
                        y: 28.0,
                        scale: 0.9,
                    });
            }
        }
        frame_profile.callback_total_ms = frame_profile.process_physics_ms
            + frame_profile.fixed_update_ms
            + frame_profile.process_ms
            + frame_profile.process_late_ms
            + frame_profile.draw_ms
            + frame_profile.draw_ui_ms;
        state.borrow_mut().frame_profile = frame_profile;
    }
    /// Present the frame: collect render commands, call the GPU renderer, and handle screenshots.
    fn render(&mut self) {
        let (Some(renderer), Some(surface), Some(state)) =
            (&mut self.renderer, &self.surface, &self.state)
        else {
            return;
        };
        let (
            commands,
            default_filter,
            bg,
            cam_matrix,
            frame_time,
            frame_count,
            vp_scale_x,
            vp_scale_y,
            vp_offset_x,
            vp_offset_y,
            vp_mode,
            game_w,
            game_h,
            screenshot_request,
            screen_capture_requested,
            textures,
            shaders,
            canvases,
            meshes,
            sprite_batches,
            mut fonts,
        ) = {
            let mut st = state.borrow_mut();
            (
                std::mem::take(&mut st.render_commands),
                st.default_filter.clone(),
                st.background_color,
                st.camera.view_matrix(),
                st.total_time as f32,
                st.frame_counter,
                st.window_state.viewport_scale_x,
                st.window_state.viewport_scale_y,
                st.window_state.viewport_offset_x,
                st.window_state.viewport_offset_y,
                st.window_state.scale_mode_str.clone(),
                st.window_state.game_width,
                st.window_state.game_height,
                st.pending_screenshot.take(),
                std::mem::replace(&mut st.pending_screen_capture, false),
                std::mem::take(&mut st.textures),
                std::mem::take(&mut st.shaders),
                std::mem::take(&mut st.canvases),
                std::mem::take(&mut st.meshes),
                std::mem::take(&mut st.sprite_batches),
                std::mem::take(&mut st.fonts),
            )
        };
        let use_viewport = vp_mode != "none"
            && (vp_scale_x != 1.0 || vp_scale_y != 1.0 || vp_offset_x != 0.0 || vp_offset_y != 0.0);
        if use_viewport {
            self.render_cmd_buf.clear();
            if vp_mode == "letterbox" || vp_mode == "pixel" {
                self.render_cmd_buf.push(RenderCommand::SetScissor(Some((
                    vp_offset_x,
                    vp_offset_y,
                    game_w * vp_scale_x,
                    game_h * vp_scale_y,
                ))));
            }
            self.render_cmd_buf.push(RenderCommand::PushTransform);
            self.render_cmd_buf.push(RenderCommand::Translate {
                x: vp_offset_x,
                y: vp_offset_y,
            });
            self.render_cmd_buf.push(RenderCommand::Scale {
                sx: vp_scale_x,
                sy: vp_scale_y,
            });
            self.render_cmd_buf.extend(commands.iter().cloned());
            self.render_cmd_buf.push(RenderCommand::PopTransform);
            if vp_mode == "letterbox" || vp_mode == "pixel" {
                self.render_cmd_buf.push(RenderCommand::SetScissor(None));
            }
        }
        let final_commands: &Vec<RenderCommand> = if use_viewport {
            &self.render_cmd_buf
        } else {
            &commands
        };
        let screenshot_supported = self.surface_usage.contains(wgpu::TextureUsages::COPY_SRC);
        let capture_screenshot = screenshot_request.is_some() && screenshot_supported;
        let capture_screen_image = screen_capture_requested && screenshot_supported;
        let auto_screenshot_ready = match self.auto_screenshot_time {
            Some(secs) => {
                self.auto_screenshot_start
                    .map(|s| s.elapsed().as_secs_f32() >= secs)
                    .unwrap_or(false)
                    && self.auto_screenshot_frame_count >= 3
            }
            None => self.auto_screenshot_frame_count >= self.auto_screenshot_frames,
        };
        let should_auto_capture = screenshot_supported
            && !self.auto_screenshot_done
            && self.auto_screenshot_path.is_some()
            && auto_screenshot_ready;
        let screenshot_pixels = {
            let s_ref = state.borrow();
            renderer.render_frame(
                surface,
                final_commands,
                &s_ref.province_registries,
                &textures,
                &mut fonts,
                &s_ref.light_world,
                &sprite_batches,
                &s_ref.shapes,
                &canvases,
                &meshes,
                &shaders,
                &default_filter,
                bg,
                &cam_matrix,
                frame_time,
                frame_count,
                capture_screenshot || should_auto_capture || capture_screen_image,
            )
        };
        let screenshot_pixels = match screenshot_pixels {
            Ok(screenshot) => screenshot,
            Err(e) => {
                if e == wgpu::SurfaceError::Lost || e == wgpu::SurfaceError::Outdated {
                    log_msg!(warn, L024_SURFACE_LOST);
                    {
                        let mut st = state.borrow_mut();
                        st.fonts = fonts;
                        st.sprite_batches = sprite_batches;
                        st.textures = textures;
                        st.shaders = shaders;
                        st.canvases = canvases;
                        st.meshes = meshes;
                        st.pending_screenshot = screenshot_request;
                        st.pending_screen_capture = screen_capture_requested;
                    }
                    self.reconfigure_surface();
                    return;
                } else {
                    log_msg!(error, L010_RENDER_ERROR, "{:?}", e);
                }
                None
            }
        };
        {
            let mut st = state.borrow_mut();
            st.fonts = fonts;
            st.sprite_batches = sprite_batches;
            st.textures = textures;
            st.shaders = shaders;
            st.canvases = canvases;
            st.meshes = meshes;
            if capture_screen_image {
                st.captured_screen_image =
                    screenshot_pixels
                        .as_ref()
                        .and_then(|(width, height, pixels)| {
                            crate::image::ImageData::from_bytes(*width, *height, pixels.clone())
                                .ok()
                        });
            }
        }
        state.borrow_mut().render_stats = renderer.render_stats.clone();
        if let Some(request) = screenshot_request {
            if !screenshot_supported {
                log_msg!(error, L074_SCREENSHOT_NO_READBACK, "path: {}", request.path);
            } else if let Some((width, height, ref pixels)) = screenshot_pixels {
                match crate::image::ImageData::from_bytes(width, height, pixels.clone())
                    .and_then(|image| image.encode_png())
                {
                    Ok(png) => {
                        if let Err(err) = state.borrow().fs.write_bytes(&request.path, &png) {
                            log_msg!(
                                error,
                                L075_SCREENSHOT_SAVE_FAIL,
                                "path: {}, err: {}",
                                request.path,
                                err
                            );
                        }
                    }
                    Err(err) => {
                        log_msg!(
                            error,
                            L076_SCREENSHOT_ENCODE_FAIL,
                            "path: {}, err: {}",
                            request.path,
                            err
                        );
                    }
                }
            }
            state.borrow_mut().pending_screenshot = None;
        }
        if should_auto_capture {
            if let Some(ref path) = self.auto_screenshot_path.clone() {
                if let Some((width, height, pixels)) = screenshot_pixels {
                    match crate::image::ImageData::from_bytes(width, height, pixels)
                        .and_then(|image| image.encode_png())
                    {
                        Ok(png) => {
                            if let Some(parent) = path.parent() {
                                let _ = std::fs::create_dir_all(parent);
                            }
                            if let Err(err) = std::fs::write(path, &png) {
                                log_msg!(
                                    error,
                                    L075_SCREENSHOT_SAVE_FAIL,
                                    "auto-screenshot path: {}, err: {}",
                                    path.display(),
                                    err
                                );
                            } else {
                                log_msg!(
                                    info,
                                    crate::runtime::log_messages::L001_ENGINE_START,
                                    "auto-screenshot saved to: {}",
                                    path.display()
                                );
                            }
                        }
                        Err(err) => {
                            log_msg!(
                                error,
                                L076_SCREENSHOT_ENCODE_FAIL,
                                "auto-screenshot path: {}, err: {}",
                                path.display(),
                                err
                            );
                        }
                    }
                }
                self.auto_screenshot_done = true;
                state.borrow_mut().quit_requested = true;
            }
        }
        if let Some(budget_ms) = self.config.performance.frame_budget_warn_ms {
            let elapsed_ms = self.last_frame.elapsed().as_secs_f64() * 1000.0;
            if elapsed_ms > budget_ms as f64 {
                log::warn!(
                    "frame budget exceeded: {:.2}ms > {}ms threshold",
                    elapsed_ms,
                    budget_ms
                );
            }
        }
    }
    /// Render the splash screen with embedded branding and drag-drop hint.
    fn render_splash(&mut self) {
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        let total_time = self
            .state
            .as_ref()
            .map_or(0.0, |s| s.borrow().clock.total());
        if self.engine_fonts.is_none() {
            let mut fonts: SlotMap<FontKey, crate::font::Font> = SlotMap::with_key();
            let all = crate::font::Font::load_all_sizes();
            let title_idx = crate::font::Font::nearest_size(36);
            let small_idx = crate::font::Font::nearest_size(18);
            let mut title_key = None;
            let mut small_key = None;
            for (i, (font, _cw, _ch)) in all.into_iter().enumerate() {
                let key = fonts.insert(font);
                if i == title_idx {
                    title_key = Some(key);
                }
                if i == small_idx {
                    small_key = Some(key);
                }
            }
            let tk = title_key.expect("embedded bitmap fonts");
            let sk = small_key.expect("embedded bitmap fonts");
            self.engine_fonts = Some((fonts, tk, sk));
        }
        let (splash_fonts, _title_key, small_key) = self
            .engine_fonts
            .as_mut()
            .expect("engine_fonts initialized above");
        if self.splash_branding.is_none() && !self.splash_branding_failed {
            self.splash_branding = load_splash_branding();
            self.splash_branding_failed = self.splash_branding.is_none();
        }
        let branding = self.splash_branding.as_ref();
        let cmds = make_splash_commands(
            renderer.width,
            renderer.height,
            *small_key,
            splash_fonts,
            branding,
            self.drag_hover,
        );
        let bg = [0.12, 0.08, 0.20, 1.0];
        let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> = SlotMap::with_key();
        let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> = SlotMap::with_key();
        let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
        let empty_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
        let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
        let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
        let default_filter = ("linear".to_string(), "linear".to_string(), 1);
        let no_lights = crate::light::light_world::LightWorld::new();
        let no_province_registries = std::collections::HashMap::new();
        let splash_textures = branding.map_or(&empty_textures, |assets| &assets.textures);
        if let Err(e) = renderer.render_frame(
            surface,
            &cmds,
            &no_province_registries,
            splash_textures,
            splash_fonts,
            &no_lights,
            &no_batches,
            &no_shapes,
            &no_canvases,
            &no_meshes,
            &no_shaders,
            &default_filter,
            bg,
            &crate::math::Mat3::identity(),
            total_time as f32,
            0u64,
            false,
        ) {
            if e == wgpu::SurfaceError::Lost || e == wgpu::SurfaceError::Outdated {
                self.reconfigure_surface();
            }
        }
    }
    /// Render the fatal error screen overlay.
    fn render_error(&mut self, error_screen: &ErrorScreen) {
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        if let Some(state_rc) = self.state.as_ref().cloned() {
            let mut st = state_rc.borrow_mut();
            if let Some(body_key) = st.active_font.or(st.default_font) {
                let heading_slot =
                    crate::font::Font::nearest_point_size(st.default_font_size.saturating_add(6));
                let heading_key = if st.active_bold {
                    Some(body_key)
                } else {
                    st.default_bold_fonts[heading_slot].or(Some(body_key))
                };
                let cmds = error_screen.build_render_commands(
                    renderer.width,
                    renderer.height,
                    heading_key,
                    Some(body_key),
                );
                let bg = [0.11, 0.22, 0.53, 1.0];
                let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> =
                    SlotMap::with_key();
                let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> =
                    SlotMap::with_key();
                let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
                let no_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
                let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
                let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
                let default_filter = ("linear".to_string(), "linear".to_string(), 1);
                let no_lights = crate::light::light_world::LightWorld::new();
                let no_province_registries = std::collections::HashMap::new();
                let render_result = renderer.render_frame(
                    surface,
                    &cmds,
                    &no_province_registries,
                    &no_textures,
                    &mut st.fonts,
                    &no_lights,
                    &no_batches,
                    &no_shapes,
                    &no_canvases,
                    &no_meshes,
                    &no_shaders,
                    &default_filter,
                    bg,
                    &crate::math::Mat3::identity(),
                    0.0,
                    0u64,
                    false,
                );
                let should_reconfigure = matches!(
                    render_result,
                    Err(wgpu::SurfaceError::Lost | wgpu::SurfaceError::Outdated)
                );
                drop(st);
                if should_reconfigure {
                    self.reconfigure_surface();
                }
                return;
            }
        }
        if self.engine_fonts.is_none() {
            let mut fonts: SlotMap<FontKey, crate::font::Font> = SlotMap::with_key();
            let all = crate::font::Font::load_all_sizes();
            let title_idx = crate::font::Font::nearest_size(36);
            let small_idx = crate::font::Font::nearest_size(18);
            let mut title_key = None;
            let mut small_key = None;
            for (i, (font, _cw, _ch)) in all.into_iter().enumerate() {
                let key = fonts.insert(font);
                if i == title_idx {
                    title_key = Some(key);
                }
                if i == small_idx {
                    small_key = Some(key);
                }
            }
            let tk = title_key.expect("embedded bitmap fonts");
            let sk = small_key.expect("embedded bitmap fonts");
            self.engine_fonts = Some((fonts, tk, sk));
        }
        let (error_fonts, heading_key, body_key) = self
            .engine_fonts
            .as_mut()
            .expect("engine_fonts initialized above");
        let cmds = error_screen.build_render_commands(
            renderer.width,
            renderer.height,
            Some(*heading_key),
            Some(*body_key),
        );
        let bg = [0.11, 0.22, 0.53, 1.0];
        let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> = SlotMap::with_key();
        let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> = SlotMap::with_key();
        let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
        let no_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
        let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
        let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
        let default_filter = ("linear".to_string(), "linear".to_string(), 1);
        let no_lights = crate::light::light_world::LightWorld::new();
        let no_province_registries = std::collections::HashMap::new();
        if let Err(e) = renderer.render_frame(
            surface,
            &cmds,
            &no_province_registries,
            &no_textures,
            error_fonts,
            &no_lights,
            &no_batches,
            &no_shapes,
            &no_canvases,
            &no_meshes,
            &no_shaders,
            &default_filter,
            bg,
            &crate::math::Mat3::identity(),
            0.0,
            0u64,
            false,
        ) {
            if e == wgpu::SurfaceError::Lost || e == wgpu::SurfaceError::Outdated {
                self.reconfigure_surface();
            }
        }
    }
    /// Extract `.lurek` archive into a temp directory and reject unsafe paths.
    pub fn extract_lurek_archive_with_policy(
        archive_path: &std::path::Path,
        policy: &StartupTargetPolicy,
    ) -> Result<(std::path::PathBuf, tempfile::TempDir), String> {
        let metadata = std::fs::metadata(archive_path)
            .map_err(|e| format!("Cannot stat archive '{}': {}", archive_path.display(), e))?;
        if metadata.len() > policy.max_archive_bytes {
            return Err(format!(
                "Archive '{}' exceeds max size {} bytes (got {})",
                archive_path.display(),
                policy.max_archive_bytes,
                metadata.len()
            ));
        }
        let _ = policy;
        Err(format!(
            ".lurek archives are not built into this runtime build; pass an extracted game folder instead: {}",
            archive_path.display()
        ))
    }
    /// Tear down the current game session and reinitialise from the game directory.
    fn restart_game(&mut self) {
        let report = self.reload_game_with_report("manual", Vec::new());
        if !report.reloaded && report.failure.is_some() && !report.rolled_back {
            log::warn!(
                "runtime restart failed without rollback: {}",
                report.failure.as_deref().unwrap_or("unknown error")
            );
        }
    }
    /// Poll content watchers and trigger a restart when scripts or assets changed.
    fn poll_content_hot_reload(&mut self) {
        if !self.has_game {
            return;
        }
        let mut changed_paths = self.content_script_watcher.poll();
        changed_paths.extend(self.content_asset_watcher.poll());
        changed_paths.sort();
        changed_paths.dedup();
        if !changed_paths.is_empty() {
            for path in changed_paths {
                if !self.pending_hot_reload_paths.contains(&path) {
                    self.pending_hot_reload_paths.push(path);
                }
            }
            self.pending_hot_reload_deadline = Some(Instant::now() + self.hot_reload_debounce);
            return;
        }
        let Some(deadline) = self.pending_hot_reload_deadline else {
            return;
        };
        if Instant::now() < deadline || self.pending_hot_reload_paths.is_empty() {
            return;
        }
        let changed_paths = std::mem::take(&mut self.pending_hot_reload_paths);
        self.pending_hot_reload_deadline = None;
        log::info!(
            "content hot-reload triggered after debounce ({} path(s))",
            changed_paths.len()
        );
        let reload = self.reload_game_with_report("hot_reload", changed_paths.clone());
        self.push_hot_reload_report(HotReloadReport {
            changed_paths,
            reload,
        });
    }
    /// Poll the config watcher and apply updated conf.toml values.
    fn poll_config_hot_reload(&mut self) {
        if self.conf_watcher.poll().is_empty() {
            return;
        }
        let (new_config, load_err) = Config::load(&self.game_dir);
        if let Some(err) = load_err {
            log::warn!("conf.toml hot-reload failed: {}", err);
            return;
        }
        let font_config_changed = self.config.render.default_font_size
            != new_config.render.default_font_size
            || self.config.render.default_font_bold != new_config.render.default_font_bold;
        self.config = new_config;
        self.window_vsync_mode = if self.config.window.vsync { 1 } else { 0 };
        if let Some(level) = self.config.log_level.as_deref() {
            crate::runtime::log_messages::set_log_level(level);
        }
        if let Some(window) = &self.window {
            window.set_title(&self.current_window_title());
        }
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            st.physics_run.fixed_dt = 1.0 / self.config.performance.physics_tick_rate.max(1) as f64;
            st.physics_run.fixed_update_dt = match self.config.performance.fixed_update_tick_rate {
                Some(rate) if rate > 0 => 1.0 / rate as f64,
                _ => 0.0,
            };
            st.frame_budget_warn_ms = self.config.performance.frame_budget_warn_ms;
            st.lua_callback_timeout_ms = self.callback_timeout_ms();
            st.set_configured_default_font(
                self.config.render.default_font_size,
                self.config.render.default_font_bold,
            );
            st.window_state.vsync_mode = self.window_vsync_mode;
            st.window_state.pending_vsync = Some(self.window_vsync_mode);
            st.window_state.game_width =
                self.config
                    .window
                    .game_width
                    .unwrap_or(self.config.window.width) as f32;
            st.window_state.game_height =
                self.config
                    .window
                    .game_height
                    .unwrap_or(self.config.window.height) as f32;
            st.window_state.scale_mode_str = self.config.window.scale_mode.clone();
            let (ww, wh) = (st.window_width, st.window_height);
            recompute_viewport(&mut st.window_state, ww, wh);
            st.config_reload_revision = st.config_reload_revision.saturating_add(1);
        }
        if font_config_changed {
            self.engine_fonts = None;
        }
        log::info!("conf.toml hot-reloaded successfully");
    }
    /// Reconfigure the wgpu surface after a lost or mode-change event.
    fn reconfigure_surface(&mut self) {
        let Some((w, h)) = self
            .renderer
            .as_ref()
            .map(|renderer| (renderer.width, renderer.height))
        else {
            return;
        };
        let (w, h) = self.clamp_surface_dims(w, h);
        let surface_config = self.surface_configuration(w, h);
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        surface.configure(&renderer.device, &surface_config);
    }
    /// Handle a window resize by updating renderer, surface, viewport, and firing `lurek.resize()`.
    fn handle_resize(&mut self, width: u32, height: u32) {
        if width == 0 || height == 0 {
            return;
        }
        let (width, height) = self.clamp_surface_dims(width, height);
        let surface_config = self.surface_configuration(width, height);
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        renderer.resize(width, height);
        surface.configure(&renderer.device, &surface_config);
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            st.window_width = width;
            st.window_height = height;
            recompute_viewport(&mut st.window_state, width, height);
        }
        if self.has_game {
            if let Some(lua) = &self.lua {
                call_lua_callback_with_timeout(
                    lua,
                    "resize",
                    (width, height),
                    self.callback_timeout_ms(),
                );
            }
        }
    }
    /// Poll gamepad backend events and dispatch Lua callbacks.
    fn poll_gamepads(&mut self) {
        self.poll_xinput_gamepads();
        self.process_pending_gamepad_vibration();
    }
    /// Poll standard Windows XInput controllers without the gilrs dependency.
    #[cfg(windows)]
    fn poll_xinput_gamepads(&mut self) {
        use windows_sys::Win32::UI::Input::XboxController::{
            XInputGetState, XINPUT_GAMEPAD_A, XINPUT_GAMEPAD_B, XINPUT_GAMEPAD_BACK,
            XINPUT_GAMEPAD_DPAD_DOWN, XINPUT_GAMEPAD_DPAD_LEFT, XINPUT_GAMEPAD_DPAD_RIGHT,
            XINPUT_GAMEPAD_DPAD_UP, XINPUT_GAMEPAD_LEFT_SHOULDER, XINPUT_GAMEPAD_LEFT_THUMB,
            XINPUT_GAMEPAD_RIGHT_SHOULDER, XINPUT_GAMEPAD_RIGHT_THUMB, XINPUT_GAMEPAD_START,
            XINPUT_GAMEPAD_X, XINPUT_GAMEPAD_Y, XINPUT_STATE,
        };
        let Some(state_rc) = &self.state else { return };
        let callback_timeout_ms = self.callback_timeout_ms();
        let mut callbacks: Vec<(&'static str, u32, Option<String>, Option<f32>)> = Vec::new();
        for id in 0..4usize {
            let mut xstate = XINPUT_STATE::default();
            let connected = unsafe { XInputGetState(id as u32, &mut xstate) == 0 };
            let was_connected = state_rc
                .borrow()
                .gamepads
                .get(id)
                .map(|gamepad| gamepad.connected)
                .unwrap_or(false);
            if !connected {
                if was_connected {
                    let mut st = state_rc.borrow_mut();
                    let gamepad = ensure_gamepad_slot(&mut st.gamepads, id);
                    gamepad.set_connected(false);
                    callbacks.push(("joystickremoved", id as u32, None, None));
                    callbacks.push(("gamepaddisconnected", id as u32, None, None));
                }
                continue;
            }

            if !was_connected {
                callbacks.push(("joystickadded", id as u32, None, None));
                callbacks.push(("gamepadconnected", id as u32, None, None));
            }

            let buttons = [
                (0, "a", XINPUT_GAMEPAD_A),
                (1, "b", XINPUT_GAMEPAD_B),
                (2, "x", XINPUT_GAMEPAD_X),
                (3, "y", XINPUT_GAMEPAD_Y),
                (4, "leftshoulder", XINPUT_GAMEPAD_LEFT_SHOULDER),
                (5, "rightshoulder", XINPUT_GAMEPAD_RIGHT_SHOULDER),
                (6, "back", XINPUT_GAMEPAD_BACK),
                (7, "start", XINPUT_GAMEPAD_START),
                (8, "leftstick", XINPUT_GAMEPAD_LEFT_THUMB),
                (9, "rightstick", XINPUT_GAMEPAD_RIGHT_THUMB),
                (10, "dpup", XINPUT_GAMEPAD_DPAD_UP),
                (11, "dpdown", XINPUT_GAMEPAD_DPAD_DOWN),
                (12, "dpleft", XINPUT_GAMEPAD_DPAD_LEFT),
                (13, "dpright", XINPUT_GAMEPAD_DPAD_RIGHT),
            ];
            let axes = [
                (
                    0,
                    "leftx",
                    normalize_xinput_thumb(xstate.Gamepad.sThumbLX, 7849),
                ),
                (
                    1,
                    "lefty",
                    -normalize_xinput_thumb(xstate.Gamepad.sThumbLY, 7849),
                ),
                (
                    2,
                    "rightx",
                    normalize_xinput_thumb(xstate.Gamepad.sThumbRX, 8689),
                ),
                (
                    3,
                    "righty",
                    -normalize_xinput_thumb(xstate.Gamepad.sThumbRY, 8689),
                ),
                (4, "triggerleft", xstate.Gamepad.bLeftTrigger as f32 / 255.0),
                (
                    5,
                    "triggerright",
                    xstate.Gamepad.bRightTrigger as f32 / 255.0,
                ),
            ];
            {
                let mut st = state_rc.borrow_mut();
                let gamepad = ensure_gamepad_slot(&mut st.gamepads, id);
                gamepad.set_connected(true);
                gamepad.set_vibration_supported(true);
                gamepad.name = format!("XInput Controller {}", id + 1);
                gamepad.set_guid(format!("xinput{:02}", id));
                for (button, name, mask) in buttons {
                    let pressed = xstate.Gamepad.wButtons & mask != 0;
                    let was_pressed = gamepad.is_button_pressed(button);
                    gamepad.update_button(button, pressed);
                    if pressed && !was_pressed {
                        callbacks.push(("gamepadpressed", id as u32, Some(name.to_string()), None));
                    } else if !pressed && was_pressed {
                        callbacks.push((
                            "gamepadreleased",
                            id as u32,
                            Some(name.to_string()),
                            None,
                        ));
                    }
                }
                for (axis, name, value) in axes {
                    let previous = gamepad.get_axis_value(axis);
                    gamepad.update_axis(axis, value);
                    if (previous - value).abs() > 0.01 {
                        callbacks.push((
                            "gamepadaxis",
                            id as u32,
                            Some(name.to_string()),
                            Some(value),
                        ));
                    }
                }
            }
        }
        if !self.has_game {
            return;
        }
        let Some(lua) = &self.lua else { return };
        for (callback, id, name, value) in callbacks {
            match (name, value) {
                (Some(name), Some(value)) => call_lua_callback_with_timeout(
                    lua,
                    callback,
                    (id, name, value),
                    callback_timeout_ms,
                ),
                (Some(name), None) => {
                    call_lua_callback_with_timeout(lua, callback, (id, name), callback_timeout_ms)
                }
                (None, None) => {
                    call_lua_callback_with_timeout(lua, callback, (id,), callback_timeout_ms)
                }
                (None, Some(_)) => {}
            }
        }
    }
    #[cfg(not(windows))]
    fn poll_xinput_gamepads(&mut self) {}
    /// Drain queued vibration requests when no native gamepad backend is built in.
    fn process_pending_gamepad_vibration(&mut self) {
        let Some(state) = &self.state else { return };
        let requests = std::mem::take(&mut state.borrow_mut().gamepad_vibration_requests);
        process_gamepad_vibration_requests(requests);
    }
}
#[cfg(windows)]
fn normalize_xinput_thumb(value: i16, deadzone: i16) -> f32 {
    let value = value as f32;
    let deadzone = deadzone as f32;
    if value.abs() <= deadzone {
        0.0
    } else if value > 0.0 {
        ((value - deadzone) / (32767.0 - deadzone)).clamp(0.0, 1.0)
    } else {
        ((value + deadzone) / (32768.0 - deadzone)).clamp(-1.0, 0.0)
    }
}
#[cfg(windows)]
fn process_gamepad_vibration_requests(requests: Vec<crate::input::GamepadVibrationRequest>) {
    use std::thread;
    use std::time::Duration;
    use windows_sys::Win32::UI::Input::XboxController::{XInputSetState, XINPUT_VIBRATION};
    for request in requests {
        if request.id >= 4 {
            continue;
        }
        let vibration = XINPUT_VIBRATION {
            wLeftMotorSpeed: (request.low_freq.clamp(0.0, 1.0) * u16::MAX as f32) as u16,
            wRightMotorSpeed: (request.high_freq.clamp(0.0, 1.0) * u16::MAX as f32) as u16,
        };
        unsafe {
            let _ = XInputSetState(request.id as u32, &vibration);
        }
        let id = request.id as u32;
        let duration_ms = request.duration_ms;
        thread::spawn(move || {
            thread::sleep(Duration::from_millis(duration_ms as u64));
            let stop = XINPUT_VIBRATION::default();
            unsafe {
                let _ = XInputSetState(id, &stop);
            }
        });
    }
}
#[cfg(not(windows))]
fn process_gamepad_vibration_requests(_requests: Vec<crate::input::GamepadVibrationRequest>) {}
/// Grow gamepad state vector and return mutable slot for `id_usize`.
fn ensure_gamepad_slot(
    gamepads: &mut Vec<crate::input::GamepadState>,
    id_usize: usize,
) -> &mut crate::input::GamepadState {
    while gamepads.len() <= id_usize {
        let new_id = gamepads.len() as u32;
        gamepads.push(crate::input::GamepadState::new(new_id));
    }
    &mut gamepads[id_usize]
}
/// Map a `SystemCursor` variant to a winit `CursorIcon`.
fn system_cursor_to_winit_cursor(cursor: SystemCursor) -> CursorIcon {
    match cursor {
        SystemCursor::Arrow => CursorIcon::Default,
        SystemCursor::IBeam => CursorIcon::Text,
        SystemCursor::Wait => CursorIcon::Wait,
        SystemCursor::Crosshair => CursorIcon::Crosshair,
        SystemCursor::Hand => CursorIcon::Pointer,
        SystemCursor::SizeNWSE => CursorIcon::NwseResize,
        SystemCursor::SizeNESW => CursorIcon::NeswResize,
        SystemCursor::SizeWE => CursorIcon::EwResize,
        SystemCursor::SizeNS => CursorIcon::NsResize,
        SystemCursor::SizeAll => CursorIcon::Move,
        SystemCursor::No => CursorIcon::NotAllowed,
    }
}
/// Load a custom window icon from the game directory.
fn load_window_icon(game_dir: &Path, icon_path: &str) -> Option<winit::window::Icon> {
    let resolved_path = {
        let path = Path::new(icon_path);
        if path.is_absolute() {
            path.to_path_buf()
        } else {
            game_dir.join(path)
        }
    };
    let image = match ::image::open(&resolved_path) {
        Ok(image) => image,
        Err(error) => {
            log_msg!(
                warn,
                L040_ICON_LOAD_FAIL,
                "'{}': {}",
                resolved_path.display(),
                error
            );
            return None;
        }
    };
    let rgba = image.to_rgba8();
    let (width, height) = (rgba.width(), rgba.height());
    match winit::window::Icon::from_rgba(rgba.into_raw(), width, height) {
        Ok(icon) => Some(icon),
        Err(error) => {
            log_msg!(
                warn,
                L041_ICON_CONV_FAIL,
                "'{}': {}",
                resolved_path.display(),
                error
            );
            None
        }
    }
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
/// Provide the ApplicationHandler behavior contract for LurekApp.
impl ApplicationHandler for LurekApp {
    /// Create the window, initialise GPU, and show the first frame.
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_some() {
            return;
        }
        let initial_title = self.current_window_title();
        let mut window_attrs = Window::default_attributes()
            .with_visible(false)
            .with_title(&initial_title)
            .with_inner_size(winit::dpi::PhysicalSize::new(
                self.config.window.width,
                self.config.window.height,
            ))
            .with_resizable(self.config.window.resizable)
            .with_decorations(!self.config.window.borderless);
        if let (Some(w), Some(h)) = (self.config.window.min_width, self.config.window.min_height) {
            window_attrs = window_attrs.with_min_inner_size(winit::dpi::PhysicalSize::new(w, h));
        }
        let startup_monitor = select_startup_monitor(event_loop, self.config.window.display_index);
        let window = Arc::new(
            event_loop
                .create_window(window_attrs)
                .expect("Failed to create window"),
        );
        if self.config.window.fullscreen {
            window.set_fullscreen(Some(winit::window::Fullscreen::Borderless(
                startup_monitor.clone(),
            )));
        } else if let Some((wx, wy)) = self.window_pos {
            window.set_outer_position(winit::dpi::PhysicalPosition::new(wx, wy));
        } else if let Some(monitor) = startup_monitor.as_ref() {
            center_window_on_monitor(
                window.as_ref(),
                monitor,
                self.config.window.width,
                self.config.window.height,
            );
        }
        if self.config.window.maximized && !self.config.window.fullscreen {
            window.set_maximized(true);
        }
        if let Some(icon_path) = self.config.window.icon.as_deref() {
            if let Some(icon) = load_window_icon(&self.game_dir, icon_path) {
                window.set_window_icon(Some(icon));
            }
        }
        if let Err(error) = self.try_init_gpu(window.clone()) {
            self.window = Some(window);
            log::error!(
                "GPU startup failed [backend={}, power={}]: {}",
                error.backend,
                error.power_preference,
                error.details
            );
            self.run_state = map_startup_error_to_run_state(&error);
            return;
        }
        self.last_frame = Instant::now();
        if let Some(win) = &self.window {
            win.set_visible(true);
            win.request_redraw();
        }
    }
    /// Dispatch a window event to the appropriate input, rendering, or lifecycle handler.
    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => {
                log_msg!(info, L039_WINDOW_CLOSE);
                if let Some(lua) = &self.lua {
                    call_lua_callback_with_timeout(lua, "exit", (), self.callback_timeout_ms());
                }
                event_loop.exit();
            }
            WindowEvent::Resized(size) => {
                self.handle_resize(size.width, size.height);
            }
            WindowEvent::ScaleFactorChanged {
                scale_factor,
                inner_size_writer: _,
            } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.dpi_scale = scale_factor;
                }
            }
            WindowEvent::Focused(focused) => {
                if let Some(state) = &self.state {
                    let mut state = state.borrow_mut();
                    state.window_state.focused = focused;
                    if !focused {
                        state.keyboard.clear_all();
                        self.ctrl_held = false;
                    }
                }
                if self.has_game {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "focus",
                            (focused,),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::Occluded(occluded) => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.visible = !occluded;
                }
                if self.has_game {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "visible",
                            (!occluded,),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::CursorEntered { .. } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.mouse_focused = true;
                }
            }
            WindowEvent::CursorLeft { .. } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.mouse_focused = false;
                }
            }
            WindowEvent::ModifiersChanged(mods) => {
                let state_mods = mods.state();
                self.ctrl_held = state_mods.control_key();
                if let Some(state) = &self.state {
                    state.borrow_mut().keyboard.set_modifiers(
                        state_mods.shift_key(),
                        state_mods.control_key(),
                        state_mods.alt_key(),
                        state_mods.super_key(),
                    );
                }
            }
            WindowEvent::KeyboardInput { event, .. } => {
                let scancode_str = if let PhysicalKey::Code(code) = event.physical_key {
                    winit_scancode_to_string(code).map(|s| s.to_string())
                } else {
                    None
                };
                if event.repeat {
                    let repeat_enabled = self
                        .state
                        .as_ref()
                        .map(|s| s.borrow().keyboard.has_key_repeat())
                        .unwrap_or(false);
                    if !repeat_enabled {
                        return;
                    }
                }
                if let Some(sc) = &scancode_str {
                    if let Some(state) = &self.state {
                        let mut st = state.borrow_mut();
                        match event.state {
                            ElementState::Pressed => st.keyboard.press_scancode(sc.clone()),
                            ElementState::Released => st.keyboard.release_scancode(sc.clone()),
                        }
                    }
                }
                if let Some(key_str) = winit_key_to_string(&event.logical_key) {
                    if matches!(self.run_state, RunState::Error(_)) {
                        if event.state == ElementState::Pressed {
                            if key_str == "escape" {
                                event_loop.exit();
                                return;
                            }
                            if key_str == "r" {
                                self.run_state = RunState::Restarting;
                                return;
                            }
                            if self.ctrl_held && key_str == "c" {
                                if let RunState::Error(ref screen) = self.run_state {
                                    let text = screen.as_text();
                                    let _ = text;
                                    log_msg!(warn, L021_CLIPBOARD_FAIL, "clipboard unavailable");
                                }
                                return;
                            }
                        }
                        return;
                    }
                    match event.state {
                        ElementState::Pressed => {
                            if !self.has_game
                                && should_open_startup_picker_on_key(&key_str, self.ctrl_held)
                            {
                                self.browse_for_startup_game_dir();
                                return;
                            }
                            if key_str == "f12" {
                                self.debug_overlay.enabled = !self.debug_overlay.enabled;
                                if let Some(state) = &self.state {
                                    state.borrow_mut().debug_overlay_enabled =
                                        self.debug_overlay.enabled;
                                }
                                return;
                            }
                            if let Some(state) = &self.state {
                                let mut st = state.borrow_mut();
                                st.keys_down.insert(key_str.clone());
                                st.keyboard.set_key_down(&key_str);
                            }
                            let mut dispatch_report = self.begin_input_report("keypressed", None);
                            let mut ui_consumed = false;
                            if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some()
                            {
                                let ui_result = {
                                    let lua = self.lua.as_ref().expect("lua should exist");
                                    call_lua_ui_bool(
                                        lua,
                                        "keypressed",
                                        key_str.clone(),
                                        self.callback_timeout_ms(),
                                    )
                                };
                                match ui_result {
                                    Ok(consumed) => {
                                        ui_consumed = consumed;
                                        dispatch_report.ui_consumed = consumed;
                                    }
                                    Err(e) => {
                                        let screen = {
                                            let lua = self.lua.as_ref().expect("lua should exist");
                                            try_errorhandler_or_screen(lua, &e)
                                        };
                                        dispatch_report.callback_error = Some(e.to_string());
                                        self.push_input_report(dispatch_report);
                                        self.run_state = RunState::Error(screen);
                                        return;
                                    }
                                }
                            }
                            if key_str == "escape" && !ui_consumed {
                                event_loop.exit();
                                return;
                            }
                            if self.has_game && !ui_consumed {
                                if let Some(lua) = &self.lua {
                                    let sc = scancode_str.clone().unwrap_or_default();
                                    call_lua_callback_with_timeout(
                                        lua,
                                        "keypressed",
                                        (key_str.clone(), sc.clone(), event.repeat),
                                        self.callback_timeout_ms(),
                                    );
                                }
                            }
                            if let Some(state) = &self.state {
                                let sc = scancode_str.clone().unwrap_or_default();
                                state.borrow_mut().event_queue.push_event(
                                    "keypressed",
                                    vec![
                                        EventArg::Str(key_str.clone()),
                                        EventArg::Str(sc),
                                        EventArg::Bool(event.repeat),
                                    ],
                                );
                            }
                            self.push_input_report(dispatch_report);
                        }
                        ElementState::Released => {
                            if let Some(state) = &self.state {
                                let mut st = state.borrow_mut();
                                st.keys_down.remove(&key_str);
                                st.keyboard.set_key_up(&key_str);
                            }
                            if self.has_game {
                                if let Some(lua) = &self.lua {
                                    let sc = scancode_str.clone().unwrap_or_default();
                                    call_lua_callback_with_timeout(
                                        lua,
                                        "keyreleased",
                                        (key_str.clone(), sc),
                                        self.callback_timeout_ms(),
                                    );
                                }
                            }
                            if let Some(state) = &self.state {
                                let sc = scancode_str.clone().unwrap_or_default();
                                state.borrow_mut().event_queue.push_event(
                                    "keyreleased",
                                    vec![EventArg::Str(key_str.clone()), EventArg::Str(sc)],
                                );
                            }
                            self.push_input_report(InputDispatchReport {
                                event_kind: "keyreleased".to_string(),
                                order: vec![
                                    InputDispatchTarget::Platform,
                                    InputDispatchTarget::Game,
                                ],
                                ui_consumed: false,
                                callback_error: None,
                                coordinates: None,
                            });
                        }
                    }
                }
            }
            WindowEvent::Ime(winit::event::Ime::Commit(text)) => {
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    if st.keyboard.has_text_input() {
                        st.keyboard.push_text_input(text.clone());
                        drop(st);
                        let mut dispatch_report = self.begin_input_report("textinput", None);
                        let mut ui_consumed = false;
                        if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "textinput",
                                    text.clone(),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        }
                        if self.has_game && !ui_consumed {
                            if let Some(lua) = &self.lua {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "textinput",
                                    text,
                                    self.callback_timeout_ms(),
                                );
                            }
                        }
                        self.push_input_report(dispatch_report);
                    }
                }
            }
            WindowEvent::CursorMoved { position, .. } => {
                let (gx, gy) = if let Some(state) = &self.state {
                    let st = state.borrow();
                    let ws = &st.window_state;
                    let gx = if ws.viewport_scale_x > 0.0 {
                        (position.x as f32 - ws.viewport_offset_x) / ws.viewport_scale_x
                    } else {
                        position.x as f32
                    };
                    let gy = if ws.viewport_scale_y > 0.0 {
                        (position.y as f32 - ws.viewport_offset_y) / ws.viewport_scale_y
                    } else {
                        position.y as f32
                    };
                    (gx, gy)
                } else {
                    (position.x as f32, position.y as f32)
                };
                let dx = gx - self.mouse_x;
                let dy = gy - self.mouse_y;
                self.mouse_x = gx;
                self.mouse_y = gy;
                let mut dispatch_report = self.begin_input_report("mousemoved", Some((gx, gy)));
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    st.mouse.x = gx;
                    st.mouse.y = gy;
                }
                let mut ui_consumed = false;
                if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                    let ui_result = {
                        let lua = self.lua.as_ref().expect("lua should exist");
                        call_lua_ui_bool(lua, "mousemoved", (gx, gy), self.callback_timeout_ms())
                    };
                    match ui_result {
                        Ok(consumed) => {
                            ui_consumed = consumed;
                            dispatch_report.ui_consumed = consumed;
                        }
                        Err(e) => {
                            let screen = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                try_errorhandler_or_screen(lua, &e)
                            };
                            dispatch_report.callback_error = Some(e.to_string());
                            self.push_input_report(dispatch_report);
                            self.run_state = RunState::Error(screen);
                            return;
                        }
                    }
                }
                if self.has_game && !ui_consumed {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "mousemoved",
                            (gx, gy, dx, dy),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::MouseWheel { delta, .. } => {
                let (dx, dy) = match delta {
                    winit::event::MouseScrollDelta::LineDelta(x, y) => (x as f64, y as f64),
                    winit::event::MouseScrollDelta::PixelDelta(pos) => (pos.x, pos.y),
                };
                let mut dispatch_report = self.begin_input_report("wheelmoved", None);
                if let Some(state) = &self.state {
                    state.borrow_mut().mouse.accumulate_scroll(dx, dy);
                }
                let mut ui_consumed = false;
                if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                    let ui_result = {
                        let lua = self.lua.as_ref().expect("lua should exist");
                        call_lua_ui_bool(lua, "wheelmoved", (dx, dy), self.callback_timeout_ms())
                    };
                    match ui_result {
                        Ok(consumed) => {
                            ui_consumed = consumed;
                            dispatch_report.ui_consumed = consumed;
                        }
                        Err(e) => {
                            let screen = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                try_errorhandler_or_screen(lua, &e)
                            };
                            dispatch_report.callback_error = Some(e.to_string());
                            self.push_input_report(dispatch_report);
                            self.run_state = RunState::Error(screen);
                            return;
                        }
                    }
                }
                if self.has_game && !ui_consumed {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "wheelmoved",
                            (dx, dy),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::MouseInput {
                state: btn_state,
                button,
                ..
            } => {
                let idx = match button {
                    MouseButton::Left => Some(0),
                    MouseButton::Right => Some(1),
                    MouseButton::Middle => Some(2),
                    MouseButton::Back => Some(3),
                    MouseButton::Forward => Some(4),
                    _ => None,
                };
                if let Some(i) = idx {
                    let pressed = btn_state == ElementState::Pressed;
                    if !self.has_game && i == 0 && pressed {
                        self.browse_for_startup_game_dir();
                        return;
                    }
                    if let Some(state) = &self.state {
                        state.borrow_mut().mouse.set_button(i, pressed);
                    }
                    let mx = self.mouse_x;
                    let my = self.mouse_y;
                    let button_index = (i + 1) as u32;
                    let mut dispatch_report = self.begin_input_report(
                        if pressed {
                            "mousepressed"
                        } else {
                            "mousereleased"
                        },
                        Some((mx, my)),
                    );
                    let mut ui_consumed = false;
                    if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                        if pressed && !self.prev_mouse[i] {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "mousepressed",
                                    (mx, my, button_index),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        } else if !pressed && self.prev_mouse[i] {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "mousereleased",
                                    (mx, my, button_index),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        }
                    }
                    if self.has_game && !ui_consumed {
                        if let Some(lua) = &self.lua {
                            if pressed && !self.prev_mouse[i] {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "mousepressed",
                                    (mx, my, button_index),
                                    self.callback_timeout_ms(),
                                );
                            } else if !pressed && self.prev_mouse[i] {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "mousereleased",
                                    (mx, my, button_index),
                                    self.callback_timeout_ms(),
                                );
                            }
                        }
                    }
                    if let Some(state) = &self.state {
                        let mx = self.mouse_x;
                        let my = self.mouse_y;
                        if pressed && !self.prev_mouse[i] {
                            state.borrow_mut().event_queue.push_event(
                                "mousepressed",
                                vec![
                                    EventArg::Num(mx as f64),
                                    EventArg::Num(my as f64),
                                    EventArg::Num((i + 1) as f64),
                                ],
                            );
                        } else if !pressed && self.prev_mouse[i] {
                            state.borrow_mut().event_queue.push_event(
                                "mousereleased",
                                vec![
                                    EventArg::Num(mx as f64),
                                    EventArg::Num(my as f64),
                                    EventArg::Num((i + 1) as f64),
                                ],
                            );
                        }
                    }
                    self.prev_mouse[i] = pressed;
                }
            }
            WindowEvent::RedrawRequested => {
                if !self.lua_initialized {
                    if let Some(win) = &self.window {
                        if !self.hidden_window {
                            win.set_visible(true);
                        }
                    }
                    self.init_lua();
                    self.lua_initialized = true;
                    if self.auto_screenshot_path.is_some() {
                        self.auto_screenshot_start = Some(Instant::now());
                    }
                    if self.auto_quit_frames.is_some() || self.auto_quit_time.is_some() {
                        self.auto_quit_start = Some(Instant::now());
                    }
                    if let (Some(window), Some(state)) = (&self.window, &self.state) {
                        let mut st = state.borrow_mut();
                        st.window_state.fullscreen = window.fullscreen().is_some();
                        if let Ok(position) = window.outer_position() {
                            st.window_state.position_x = position.x;
                            st.window_state.position_y = position.y;
                        }
                    }
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                    return;
                }
                if matches!(self.run_state, RunState::Restarting) {
                    self.restart_game();
                    return;
                }
                let mut restart_requested = false;
                let mut quit_requested = false;
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    if st.restart_requested {
                        st.restart_requested = false;
                        restart_requested = true;
                    }
                    quit_requested = st.quit_requested;
                }
                if restart_requested {
                    self.run_state = RunState::Restarting;
                    self.restart_game();
                    return;
                }
                if quit_requested {
                    event_loop.exit();
                    return;
                }
                let tick_start = Instant::now();
                self.poll_gamepads();
                self.tick_frame();
                let tick_ms = tick_start.elapsed().as_secs_f64() * 1000.0;
                let mut update_ms = 0.0;
                let mut render_ms = 0.0;
                let run_state = std::mem::replace(&mut self.run_state, RunState::Running);
                match run_state {
                    RunState::Error(ref screen) => {
                        let render_start = Instant::now();
                        self.render_error(screen);
                        render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        self.run_state = run_state;
                        if self.auto_screenshot_path.is_some() {
                            if let Some(state) = &self.state {
                                state.borrow_mut().quit_requested = true;
                            } else {
                                event_loop.exit();
                            }
                        }
                    }
                    RunState::Running => {
                        if self.has_game {
                            let update_start = Instant::now();
                            self.game_update();
                            update_ms = update_start.elapsed().as_secs_f64() * 1000.0;
                            let render_start = Instant::now();
                            self.render();
                            render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        } else {
                            let render_start = Instant::now();
                            self.render_splash();
                            render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        }
                    }
                    RunState::Restarting => {}
                }
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    st.frame_profile.app_tick_ms = tick_ms as f32;
                    st.frame_profile.app_update_ms = update_ms as f32;
                    st.frame_profile.app_render_ms = render_ms as f32;
                    st.frame_profile.app_frame_total_ms = (tick_ms + update_ms + render_ms) as f32;
                }
                self.perf_record_frame(tick_ms, update_ms, render_ms);
            }
            WindowEvent::Touch(touch) => {
                let id = touch.id;
                let x = touch.location.x;
                let y = touch.location.y;
                let event_kind = match touch.phase {
                    winit::event::TouchPhase::Started => "touchpressed",
                    winit::event::TouchPhase::Moved => "touchmoved",
                    winit::event::TouchPhase::Ended | winit::event::TouchPhase::Cancelled => {
                        "touchreleased"
                    }
                };
                let dispatch_report =
                    self.begin_input_report(event_kind, Some((x as f32, y as f32)));
                let pressure = touch.force.map_or(1.0, |f| match f {
                    winit::event::Force::Normalized(n) => n,
                    winit::event::Force::Calibrated {
                        force,
                        max_possible_force,
                        ..
                    } => {
                        if max_possible_force > 0.0 {
                            force / max_possible_force
                        } else {
                            1.0
                        }
                    }
                });
                match touch.phase {
                    winit::event::TouchPhase::Started => {
                        let dx = 0.0;
                        let dy = 0.0;
                        if let Some(state) = &self.state {
                            state.borrow_mut().touch.touch_start(id, x, y, pressure);
                        }
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchpressed",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                    winit::event::TouchPhase::Moved => {
                        let (dx, dy) = if let Some(state) = &self.state {
                            let mut st = state.borrow_mut();
                            let delta = st
                                .touch
                                .get_touch(id)
                                .map(|touch_point| (x - touch_point.x, y - touch_point.y))
                                .unwrap_or((0.0, 0.0));
                            st.touch.touch_move(id, x, y, pressure);
                            delta
                        } else {
                            (0.0, 0.0)
                        };
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchmoved",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                    winit::event::TouchPhase::Ended | winit::event::TouchPhase::Cancelled => {
                        let (dx, dy) = if let Some(state) = &self.state {
                            let mut st = state.borrow_mut();
                            let delta = st
                                .touch
                                .get_touch(id)
                                .map(|touch_point| (x - touch_point.x, y - touch_point.y))
                                .unwrap_or((0.0, 0.0));
                            st.touch.touch_end(id);
                            delta
                        } else {
                            (0.0, 0.0)
                        };
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchreleased",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                }
                self.push_input_report(dispatch_report);
            }
            WindowEvent::HoveredFile(path) => {
                log_msg!(debug, L077_DRAG_HOVER, "{}", path.display());
                if !self.has_game {
                    self.drag_hover = true;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
            }
            WindowEvent::HoveredFileCancelled => {
                log_msg!(debug, L078_DRAG_HOVER_CANCEL);
                if self.drag_hover {
                    self.drag_hover = false;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
            }
            WindowEvent::DroppedFile(path) => {
                log::debug!("[lurek drag-drop] DroppedFile: {}", path.display());
                log_msg!(info, L043_DROP_FILE, "{}", path.display());
                if self.drag_hover {
                    self.drag_hover = false;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
                if !self.has_game {
                    self.load_startup_target_path(&path);
                } else {
                    log_msg!(debug, L079_DRAG_DROP_IGNORED);
                }
            }
            _ => {}
        }
    }
    /// Run per-frame housekeeping: hot-reload polling, auto-screenshot timeout, and frame pacing.
    fn about_to_wait(&mut self, event_loop: &ActiveEventLoop) {
        use std::time::Duration;
        if let Some(state) = &self.state {
            let requested = state.borrow().pending_config_reload;
            if requested {
                state.borrow_mut().pending_config_reload = false;
                self.conf_watcher.force_changed();
            }
        }
        self.poll_config_hot_reload();
        self.poll_content_hot_reload();
        if !self.auto_screenshot_done {
            if let Some(start) = self.auto_screenshot_start {
                let expected_capture_secs = match self.auto_screenshot_time {
                    Some(secs) => secs.max(0.0),
                    None => {
                        let fps = self.config.performance.target_fps.max(1) as f32;
                        self.auto_screenshot_frames as f32 / fps
                    }
                };
                let deadline_secs = (expected_capture_secs + 2.0).max(3.0);
                if start.elapsed() > Duration::from_secs_f32(deadline_secs) {
                    if let Some(state) = &self.state {
                        state.borrow_mut().quit_requested = true;
                    } else {
                        event_loop.exit();
                    }
                }
            }
        }
        if !self.auto_quit_done {
            let auto_quit_ready = match self.auto_quit_time {
                Some(secs) => self
                    .auto_quit_start
                    .map(|start| start.elapsed() >= Duration::from_secs_f32(secs.max(0.0)))
                    .unwrap_or(false),
                None => self
                    .auto_quit_frames
                    .map(|frames| self.auto_quit_frame_count >= frames)
                    .unwrap_or(false),
            };
            if auto_quit_ready {
                self.auto_quit_done = true;
                if let Some(state) = &self.state {
                    state.borrow_mut().quit_requested = true;
                } else {
                    event_loop.exit();
                }
            }
        }
        let target = Duration::from_secs_f64(1.0 / self.config.performance.target_fps as f64);
        let elapsed = self.last_frame.elapsed();
        if elapsed >= target {
            self.last_frame = Instant::now();
            if let Some(win) = &self.window {
                win.request_redraw();
            }
            event_loop.set_control_flow(ControlFlow::Poll);
        } else {
            let remaining = target - elapsed;
            #[cfg(target_os = "windows")]
            {
                if remaining > Duration::from_micros(1500) {
                    std::thread::sleep(remaining - Duration::from_micros(1000));
                }
                event_loop.set_control_flow(ControlFlow::Poll);
            }
            #[cfg(not(target_os = "windows"))]
            {
                let next = Instant::now() + remaining;
                event_loop.set_control_flow(ControlFlow::WaitUntil(next));
            }
        }
    }
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
            .join("work")
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
