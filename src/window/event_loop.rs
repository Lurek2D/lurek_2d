//! This file provides event-loop side monitor and display helpers for window placement flow.
//! It enumerates displays and captures snapshot metadata used by window-facing APIs.
//! It selects startup and fallback monitors with deterministic preference ordering.
//! It supports centering and cross-display movement operations for runtime window control.
//! It anchors monitor-aware behavior required by multi-display desktop setups.

use winit::event_loop::ActiveEventLoop;
use winit::monitor::MonitorHandle;
use winit::window::Window;
/// Snapshot of one connected display returned by `get_displays`.
/// # Fields
#[derive(Debug, Clone)]
pub struct DisplayInfo {
    /// Zero-based index used in all other display-index parameters.
    pub index: i32,
    /// OS-reported display name; may be empty on some platforms.
    pub name: String,
    /// Physical X origin of the display in desktop coordinates.
    pub x: i32,
    /// Physical Y origin of the display in desktop coordinates.
    pub y: i32,
    /// Physical pixel width of the display.
    pub width: u32,
    /// Physical pixel height of the display.
    pub height: u32,
    /// HiDPI scaling factor reported by the OS for this display.
    pub scale_factor: f64,
    /// Maximum refresh rate in whole hertz (rounded down from millihertz).
    pub refresh_rate_hz: u32,
    /// `true` when this monitor is the OS-designated primary display.
    pub primary: bool,
}
/// Snapshot of one fullscreen video mode.
/// # Fields
#[derive(Debug, Clone, Copy)]
pub struct FullscreenModeInfo {
    /// Physical pixel width of the mode.
    pub width: u32,
    /// Physical pixel height of the mode.
    pub height: u32,
    /// Refresh rate in whole hertz.
    pub refresh_rate_hz: u32,
}
/// Return `(x, y, width, height)` uniquely identifying a `MonitorHandle` by position and size.
fn monitor_signature(monitor: &MonitorHandle) -> (i32, i32, u32, u32) {
    let pos = monitor.position();
    let size = monitor.size();
    (pos.x, pos.y, size.width, size.height)
}
/// Return the primary monitor signature for `window`; `None` when no primary is available.
fn primary_signature(window: &Window) -> Option<(i32, i32, u32, u32)> {
    window.primary_monitor().as_ref().map(monitor_signature)
}
/// Convert a `MonitorHandle` with an integer `index` into a `DisplayInfo`; marks primary when signature matches.
fn monitor_to_info(
    index: usize,
    monitor: &MonitorHandle,
    primary_sig: Option<(i32, i32, u32, u32)>,
) -> DisplayInfo {
    let pos = monitor.position();
    let size = monitor.size();
    let refresh_rate_hz = monitor
        .video_modes()
        .map(|mode| mode.refresh_rate_millihertz() / 1000)
        .max()
        .unwrap_or(60);
    let primary = primary_sig
        .map(|sig| sig == monitor_signature(monitor))
        .unwrap_or(false);
    DisplayInfo {
        index: index as i32,
        name: monitor
            .name()
            .unwrap_or_else(|| format!("Display {}", index)),
        x: pos.x,
        y: pos.y,
        width: size.width,
        height: size.height,
        scale_factor: monitor.scale_factor(),
        refresh_rate_hz,
        primary,
    }
}
/// Build a deterministic fallback display snapshot when no live window handle is available.
pub fn fallback_display_info(window_width: u32, window_height: u32, dpi_scale: f64) -> DisplayInfo {
    DisplayInfo {
        index: 0,
        name: String::from("Primary"),
        x: 0,
        y: 0,
        width: window_width,
        height: window_height,
        scale_factor: dpi_scale,
        refresh_rate_hz: 60,
        primary: true,
    }
}
/// Return a `Vec<DisplayInfo>` for every monitor accessible to `window`, in enumeration order.
pub fn get_displays(window: &Window) -> Vec<DisplayInfo> {
    let primary_sig = primary_signature(window);
    window
        .available_monitors()
        .enumerate()
        .map(|(index, monitor)| monitor_to_info(index, &monitor, primary_sig))
        .collect()
}
/// Return the best available display list, falling back to one synthetic primary display when needed.
pub fn display_snapshots(
    window: Option<&Window>,
    fallback_width: u32,
    fallback_height: u32,
    dpi_scale: f64,
) -> Vec<DisplayInfo> {
    if let Some(window) = window {
        let displays = get_displays(window);
        if !displays.is_empty() {
            return displays;
        }
    }
    vec![fallback_display_info(
        fallback_width,
        fallback_height,
        dpi_scale,
    )]
}
/// Return the enumeration index of the monitor `window` currently occupies, or `None` if unavailable.
pub fn current_display_index(window: &Window) -> Option<usize> {
    let current = window.current_monitor()?;
    let current_sig = monitor_signature(&current);
    window
        .available_monitors()
        .enumerate()
        .find(|(_, monitor)| monitor_signature(monitor) == current_sig)
        .map(|(idx, _)| idx)
}
/// Return the current display index or `0` when the window is unavailable.
pub fn current_display_index_or_default(window: Option<&Window>) -> i32 {
    window
        .and_then(current_display_index)
        .map(|idx| idx as i32)
        .unwrap_or(0)
}
/// Return the `MonitorHandle` for `display_index`; falls back to current → primary → first when `None`.
fn monitor_by_index(window: &Window, display_index: Option<usize>) -> Option<MonitorHandle> {
    if let Some(index) = display_index {
        return window.available_monitors().nth(index);
    }
    window
        .current_monitor()
        .or_else(|| window.primary_monitor())
        .or_else(|| window.available_monitors().next())
}
/// Return `(width, height)` in physical pixels for `display_index`; falls back to current/primary when `None`.
pub fn desktop_dimensions_for_display(
    window: &Window,
    display_index: Option<usize>,
) -> Option<(u32, u32)> {
    monitor_by_index(window, display_index).map(|monitor| {
        let size = monitor.size();
        (size.width, size.height)
    })
}
/// Return desktop dimensions for `display_index`, or the provided fallback size when unavailable.
pub fn desktop_dimensions_or_fallback(
    window: Option<&Window>,
    display_index: Option<usize>,
    fallback_width: u32,
    fallback_height: u32,
) -> (u32, u32) {
    window
        .and_then(|win| desktop_dimensions_for_display(win, display_index))
        .unwrap_or((fallback_width, fallback_height))
}
/// Return the OS name string for `display_index`; falls back to current/primary when `None`.
pub fn display_name_for_display(window: &Window, display_index: Option<usize>) -> Option<String> {
    monitor_by_index(window, display_index).map(|monitor| {
        monitor
            .name()
            .unwrap_or_else(|| String::from("Unknown display"))
    })
}
/// Return the display name for `display_index`, or `"Unknown"` when unavailable.
pub fn display_name_or_unknown(window: Option<&Window>, display_index: Option<usize>) -> String {
    window
        .and_then(|win| display_name_for_display(win, display_index))
        .unwrap_or_else(|| "Unknown".to_string())
}
/// Return every fullscreen mode visible to the current window across all monitors.
pub fn get_fullscreen_modes(window: &Window) -> Vec<FullscreenModeInfo> {
    let mut modes = Vec::new();
    for monitor in window.available_monitors() {
        for mode in monitor.video_modes() {
            let size = mode.size();
            modes.push(FullscreenModeInfo {
                width: size.width,
                height: size.height,
                refresh_rate_hz: mode.refresh_rate_millihertz() / 1000,
            });
        }
    }
    modes
}
/// Return every fullscreen mode for `window`, or an empty list when no live OS window exists yet.
pub fn fullscreen_mode_snapshots(window: Option<&Window>) -> Vec<FullscreenModeInfo> {
    window.map(get_fullscreen_modes).unwrap_or_default()
}
/// Move `window` to the center of monitor `display_index`; return `false` when that index doesn't exist.
pub(crate) fn move_window_to_display(window: &Window, display_index: usize) -> bool {
    let Some(monitor) = window.available_monitors().nth(display_index) else {
        return false;
    };
    let size = window.outer_size();
    center_window_on_monitor(window, &monitor, size.width, size.height);
    true
}
/// Return the `MonitorHandle` to use at startup for `display_index`; falls back to primary with a warning.
pub(crate) fn select_startup_monitor(
    event_loop: &ActiveEventLoop,
    display_index: u32,
) -> Option<MonitorHandle> {
    let primary = event_loop
        .primary_monitor()
        .or_else(|| event_loop.available_monitors().next());
    if display_index == 0 {
        return primary;
    }
    let monitor = event_loop.available_monitors().nth(display_index as usize);
    if monitor.is_none() {
        log::warn!(
            "Window display index {} unavailable, falling back to primary monitor",
            display_index
        );
    }
    monitor.or(primary)
}
/// Center `window` on `monitor` given its `width` × `height` in physical pixels.
pub(crate) fn center_window_on_monitor(
    window: &Window,
    monitor: &MonitorHandle,
    width: u32,
    height: u32,
) {
    let monitor_size = monitor.size();
    let monitor_position = monitor.position();
    let x = monitor_position.x + ((monitor_size.width as i32 - width as i32).max(0) / 2);
    let y = monitor_position.y + ((monitor_size.height as i32 - height as i32).max(0) / 2);
    window.set_outer_position(winit::dpi::PhysicalPosition::new(x, y));
}
