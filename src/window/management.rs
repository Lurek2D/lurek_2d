//! This file provides deferred window management operations staged for safe event-loop apply. `window/management` delivers the management implementation for the window subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It controls title, size, position, display target, and icon updates through queued state. The file owns or coordinates data contracts including `ModeInfo`, `WindowConfigRequest`, `FileDialogFilter`, `FileDialogOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It manages fullscreen and vsync mode changes across desktop and exclusive variants. Public callable behavior is centered on `set_title`, `focus`, `set_fullscreen`, `is_fullscreen`, `set_vsync`, and 31 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! It exposes minimize, maximize, restore, close, and attention requests for app lifecycle flow. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! It provides focus, visibility, and pointer-presence queries for runtime interaction logic. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

use crate::runtime::shared_state::{FullscreenType, WindowState};
/// Snapshot of the window's current mode returned by `get_mode`.
/// # Fields
pub struct ModeInfo {
    /// `true` when the window is currently in any fullscreen mode.
    pub fullscreen: bool,
    /// String name of the active fullscreen type: `"desktop"` or `"exclusive"`.
    pub fullscreen_type: &'static str,
    /// Current vsync mode integer (0 = off, 1 = on, -1 = adaptive).
    pub vsync: i32,
}
/// Deferred batch of optional window state updates parsed from Lua-facing config helpers.
pub(crate) struct WindowConfigRequest {
    /// Optional replacement title.
    pub title: Option<String>,
    /// Optional logical size.
    pub size: Option<(u32, u32)>,
    /// Optional fullscreen enable flag.
    pub fullscreen: Option<bool>,
    /// Optional fullscreen type string.
    pub fullscreen_type: Option<String>,
    /// Optional vsync mode integer.
    pub vsync: Option<i32>,
    /// Optional physical desktop position.
    pub position: Option<(i32, i32)>,
    /// Optional scale-mode name.
    pub scale_mode: Option<String>,
    /// Optional display index.
    pub display: Option<i32>,
}
/// One native file-dialog filter row.
pub(crate) struct FileDialogFilter {
    /// Display name shown by the OS picker.
    pub name: String,
    /// Allowed file extensions without dots.
    pub extensions: Vec<String>,
}
/// Native file-dialog options independent from the Lua table representation.
pub(crate) struct FileDialogOptions {
    /// Optional dialog title.
    pub title: Option<String>,
    /// Optional initial directory or file path.
    pub default_path: Option<String>,
    /// Whether multi-select mode is enabled.
    pub multiple: bool,
    /// Ordered list of extension filters.
    pub filters: Vec<FileDialogFilter>,
}
/// Stage a window title change to `title`; applied by the event loop next frame.
pub fn set_title(ws: &mut WindowState, title: &str) {
    ws.pending_title = Some(title.to_owned());
}
/// Stage a request for the OS window to receive user focus on the next event-loop apply.
pub fn focus(ws: &mut WindowState) {
    ws.pending_focus = true;
}
/// Stage a fullscreen toggle; `mode` is `"exclusive"` or `"desktop"`; applied next frame.
pub fn set_fullscreen(ws: &mut WindowState, flag: bool, mode: &str) {
    ws.pending_fullscreen = Some(flag);
    ws.pending_fullscreen_type = if mode == "exclusive" {
        FullscreenType::Exclusive
    } else {
        FullscreenType::Desktop
    };
}
/// Return `true` when the window is currently in fullscreen.
pub fn is_fullscreen(ws: &WindowState) -> bool {
    ws.fullscreen
}
/// Stage a vsync mode change (0 = off, 1 = on, -1 = adaptive); applied next frame.
pub fn set_vsync(ws: &mut WindowState, mode: i32) {
    ws.pending_vsync = Some(mode);
}
/// Return the current vsync mode integer.
pub fn get_vsync(ws: &WindowState) -> i32 {
    ws.vsync_mode
}
/// Return the DPI scaling factor reported by the OS.
pub fn get_dpi_scale(ws: &WindowState) -> f64 {
    ws.dpi_scale
}
/// Return the window's current `(x, y)` screen position in physical pixels.
pub fn get_position(ws: &WindowState) -> (i32, i32) {
    (ws.position_x, ws.position_y)
}
/// Stage a window position move to `(x, y)` in physical pixels; applied next frame.
pub fn set_position(ws: &mut WindowState, x: i32, y: i32) {
    ws.pending_position = Some((x, y));
}
/// Stage a move to `display_index`; return `false` when index is negative.
pub fn set_display(ws: &mut WindowState, display_index: i32) -> bool {
    if display_index < 0 {
        return false;
    }
    ws.pending_display_index = Some(display_index as usize);
    true
}
/// Stage a display change request or return a stable contract error string.
pub(crate) fn request_display_change(
    ws: &mut WindowState,
    display_index: i32,
) -> Result<(), String> {
    if set_display(ws, display_index) {
        Ok(())
    } else {
        Err("lurek.window.setDisplay: display index must be >= 0".to_string())
    }
}
/// Stage a minimize request; applied next frame.
pub fn minimize(ws: &mut WindowState) {
    ws.pending_minimize = true;
}
/// Stage a maximize request; applied next frame.
pub fn maximize(ws: &mut WindowState) {
    ws.pending_maximize = true;
}
/// Stage a restore-from-min/max request; applied next frame.
pub fn restore(ws: &mut WindowState) {
    ws.pending_restore = true;
}
/// Return `true` when the window is currently minimized.
pub fn is_minimized(ws: &WindowState) -> bool {
    ws.minimized
}
/// Return `true` when the window is currently maximized.
pub fn is_maximized(ws: &WindowState) -> bool {
    ws.maximized
}
/// Return `true` when the window has keyboard focus.
pub fn has_focus(ws: &WindowState) -> bool {
    ws.focused
}
/// Stage a taskbar attention request on platforms that support it.
pub fn request_attention(ws: &mut WindowState) {
    ws.pending_attention = true;
}
/// Alias for `request_attention` for platforms that use flash semantics.
pub fn flash(ws: &mut WindowState) {
    request_attention(ws);
}
/// Stage a close request; the event loop will process it and stop the run loop.
pub fn close(ws: &mut WindowState) {
    ws.pending_close = true;
}
/// Stage a window icon change from image file `path`; applied next frame.
pub fn set_icon(ws: &mut WindowState, path: &str) {
    ws.pending_icon_path = Some(path.to_owned());
}
/// Stage a resize to `(w, h)` in logical pixels; applied next frame.
pub fn set_size(ws: &mut WindowState, w: u32, h: u32) {
    ws.pending_size = Some((w, h));
}
/// Return the current fullscreen type string (`"desktop"` or `"exclusive"`).
pub fn get_fullscreen_type_str(ws: &WindowState) -> &'static str {
    match ws.fullscreen_type {
        FullscreenType::Desktop => "desktop",
        FullscreenType::Exclusive => "exclusive",
    }
}
/// Return the display orientation implied by logical window dimensions.
pub fn display_orientation(window_width: u32, window_height: u32) -> &'static str {
    if window_width >= window_height {
        "landscape"
    } else {
        "portrait"
    }
}
/// Return `(is_fullscreen, fullscreen_type_str)` as a convenience pair.
pub fn get_fullscreen(ws: &WindowState) -> (bool, &'static str) {
    (ws.fullscreen, get_fullscreen_type_str(ws))
}
/// Return `true` when the window is visible (not hidden).
pub fn is_visible(ws: &WindowState) -> bool {
    ws.visible
}
/// Return `true` when the mouse cursor is inside the window client area.
pub fn has_mouse_focus(ws: &WindowState) -> bool {
    ws.mouse_focused
}
/// Scale a logical `value` to physical pixels using the window's DPI factor.
pub fn to_dpi_pixels(ws: &WindowState, value: f64) -> f64 {
    value * ws.dpi_scale
}
/// Convert physical `value` back to logical pixels; return `value` unchanged when DPI scale is zero.
pub fn from_dpi_pixels(ws: &WindowState, value: f64) -> f64 {
    if ws.dpi_scale > 0.0 {
        value / ws.dpi_scale
    } else {
        value
    }
}
/// Return `(width, height)` in physical pixels by scaling logical dimensions by the DPI factor.
pub fn get_pixel_dimensions(ws: &WindowState, win_w: u32, win_h: u32) -> (u32, u32) {
    let scale = ws.dpi_scale;
    (
        (win_w as f64 * scale).round() as u32,
        (win_h as f64 * scale).round() as u32,
    )
}
/// Stage a combined mode update: size, optional fullscreen flag, optional fullscreen type, optional vsync.
pub fn set_mode(
    ws: &mut WindowState,
    w: u32,
    h: u32,
    fullscreen: Option<bool>,
    fstype: Option<&str>,
    vsync: Option<i32>,
) {
    set_size(ws, w, h);
    if let Some(fs) = fullscreen {
        set_fullscreen(ws, fs, fstype.unwrap_or("desktop"));
    }
    if let Some(v) = vsync {
        set_vsync(ws, v);
    }
}
/// Apply a parsed batch of optional window configuration fields using the existing deferred helpers.
pub(crate) fn apply_window_config_request(ws: &mut WindowState, request: WindowConfigRequest) {
    if let Some(title) = request.title.as_deref() {
        set_title(ws, title);
    }
    if let Some((w, h)) = request.size {
        set_size(ws, w, h);
    }
    if let Some(fullscreen) = request.fullscreen {
        set_fullscreen(
            ws,
            fullscreen,
            request.fullscreen_type.as_deref().unwrap_or("desktop"),
        );
    }
    if let Some(vsync) = request.vsync {
        set_vsync(ws, vsync);
    }
    if let Some((x, y)) = request.position {
        set_position(ws, x, y);
    }
    if let Some(scale_mode) = request.scale_mode.as_deref() {
        crate::window::viewport::set_scale_mode_validated(ws, scale_mode);
    }
    if let Some(display) = request.display {
        let _ = set_display(ws, display);
    }
}
/// Return a `ModeInfo` snapshot of the current fullscreen and vsync state.
pub fn get_mode(ws: &WindowState) -> ModeInfo {
    ModeInfo {
        fullscreen: ws.fullscreen,
        fullscreen_type: get_fullscreen_type_str(ws),
        vsync: ws.vsync_mode,
    }
}
/// Show a native OS dialog with `title`, `message`, `box_type` (`"info"`,`"warning"`,`"error"`), and `btn_type` (`"ok"`,`"okcancel"`,`"yesno"`); return the button string.
pub fn show_message_box(
    title: &str,
    message: &str,
    box_type: &str,
    btn_type: &str,
) -> &'static str {
    let level = match box_type {
        "warning" => rfd::MessageLevel::Warning,
        "error" => rfd::MessageLevel::Error,
        _ => rfd::MessageLevel::Info,
    };
    let buttons = match btn_type {
        "okcancel" => rfd::MessageButtons::OkCancel,
        "yesno" => rfd::MessageButtons::YesNo,
        _ => rfd::MessageButtons::Ok,
    };
    let result = rfd::MessageDialog::new()
        .set_title(title)
        .set_description(message)
        .set_level(level)
        .set_buttons(buttons)
        .show();
    match result {
        rfd::MessageDialogResult::Ok => "ok",
        rfd::MessageDialogResult::Yes => "yes",
        rfd::MessageDialogResult::No => "no",
        rfd::MessageDialogResult::Cancel => "cancel",
        rfd::MessageDialogResult::Custom(_) => "ok",
    }
}
/// Apply the portable option subset used by `lurek.window.openFileDialog`.
pub(crate) fn configure_file_dialog(
    mut dialog: rfd::FileDialog,
    options: &FileDialogOptions,
) -> rfd::FileDialog {
    if let Some(title) = options.title.as_deref() {
        dialog = dialog.set_title(title);
    }
    if let Some(default_path) = options.default_path.as_deref() {
        dialog = dialog.set_directory(default_path);
    }
    for filter in &options.filters {
        let ext_refs: Vec<&str> = filter.extensions.iter().map(String::as_str).collect();
        dialog = dialog.add_filter(&filter.name, &ext_refs);
    }
    dialog
}
/// Open a native file picker and return the selected paths as UTF-8 strings.
pub(crate) fn open_file_dialog_paths(options: &FileDialogOptions) -> Vec<String> {
    let dialog = configure_file_dialog(rfd::FileDialog::new(), options);
    if options.multiple {
        return dialog
            .pick_files()
            .unwrap_or_default()
            .into_iter()
            .map(|path| path.to_string_lossy().to_string())
            .collect();
    }
    dialog
        .pick_file()
        .into_iter()
        .map(|path| path.to_string_lossy().to_string())
        .collect()
}
