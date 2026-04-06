//! Window management API for Luna2D.
//!
//! Exposes `luna.window.*` — title, fullscreen, VSync, DPI scaling, position,
//! size, minimize/maximize, focus query, icon, viewport scaling, and coordinate
//! conversion between game space and screen pixels.

/// Placeholder for the platform window event loop integration.
pub mod event_loop;

/// Set the window title shown in the OS title bar.
///
/// @param title : string
/// @return nil
pub fn set_title(_title: &str) {}

/// Enter or exit fullscreen mode.
///
/// `mode` is `"desktop"` (borderless) or `"exclusive"`.  Pass `""` to use the
/// current mode setting.
///
/// @param flag : boolean
/// @param mode : string
/// @return nil
pub fn set_fullscreen(_flag: bool, _mode: &str) {}

/// Return whether the window is currently in fullscreen mode.
///
/// @return boolean
pub fn is_fullscreen() -> bool { false }

/// Set the VSync presentation mode.
///
/// Values: `1` = Fifo (vsync on), `0` = Immediate (vsync off), `-1` = Mailbox
/// (adaptive vsync).
///
/// @param mode : integer
/// @return nil
pub fn set_vsync(_mode: i32) {}

/// Return the current VSync mode integer.
///
/// @return integer
pub fn get_vsync() -> i32 { 1 }

/// Return the DPI scale factor of the display the window is on.
///
/// On standard displays this is `1.0`; on HiDPI / Retina displays it may be
/// `2.0` or higher.
///
/// @return number
pub fn get_dpi_scale() -> f64 { 1.0 }

/// Return the current window X and Y position in screen coordinates.
///
/// @return integer
/// @return integer
pub fn get_position() -> (i32, i32) { (0, 0) }

/// Move the window to the given screen coordinate position.
///
/// @param x : integer
/// @param y : integer
/// @return nil
pub fn set_position(_x: i32, _y: i32) {}

/// Minimise the window to the taskbar.
///
/// @return nil
pub fn minimize() {}

/// Maximise the window to fill the screen.
///
/// @return nil
pub fn maximize() {}

/// Restore the window from minimised or maximised state.
///
/// @return nil
pub fn restore() {}

/// Return whether the window is currently minimised.
///
/// @return boolean
pub fn is_minimized() -> bool { false }

/// Return whether the window is currently maximised.
///
/// @return boolean
pub fn is_maximized() -> bool { false }

/// Return whether the window has keyboard focus.
///
/// @return boolean
pub fn has_focus() -> bool { true }

/// Flash the taskbar icon or bounce the dock icon to request user attention.
///
/// @return nil
pub fn request_attention() {}

/// Close the window and exit the game on the next frame.
///
/// @return nil
pub fn close() {}

/// Set the window icon from the given image file path.
///
/// @param path : string
/// @return nil
pub fn set_icon(_path: &str) {}

/// Resize the window to the given logical pixel dimensions.
///
/// @param w : integer
/// @param h : integer
/// @return nil
pub fn set_size(_w: u32, _h: u32) {}

/// Return the logical game width in virtual pixels.
///
/// @return number
pub fn get_width() -> f32 { 0.0 }

/// Return the logical game height in virtual pixels.
///
/// @return number
pub fn get_height() -> f32 { 0.0 }

/// Return the current viewport scale mode string.
///
/// One of `"none"`, `"letterbox"`, `"stretch"`, or `"pixel"`.
///
/// @return string
pub fn get_scale_mode() -> &'static str { "none" }

/// Set the viewport scale mode.
///
/// @param mode : string
/// @return nil
pub fn set_scale_mode(_mode: &str) {}

/// Convert game-space coordinates to window pixel coordinates.
///
/// @param x : number
/// @param y : number
/// @return number
/// @return number
pub fn to_pixels(_x: f32, _y: f32) -> (f32, f32) { (0.0, 0.0) }

/// Convert window pixel coordinates back to game-space coordinates.
///
/// @param x : number
/// @param y : number
/// @return number
/// @return number
pub fn from_pixels(_x: f32, _y: f32) -> (f32, f32) { (0.0, 0.0) }
