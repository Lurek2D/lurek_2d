//! Owns the mouse owner for the input subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Centers the implementation around CursorImageLimits, default, SystemCursor, with helpers kept close to their invariants.
//! Defines how mouse data is validated, transformed, or stored before neighboring systems use it.
//! Owns input behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on mouse behavior while Lua registration stays elsewhere.
//! Documents where input callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing mouse defaults, lifecycle handling, validation, or data ownership.

use std::collections::HashMap;

/// Limits enforced for custom cursor image validation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CursorImageLimits {
    /// Maximum allowed cursor width in pixels.
    pub max_width: u32,
    /// Maximum allowed cursor height in pixels.
    pub max_height: u32,
    /// Maximum allowed byte length for the RGBA buffer.
    pub max_pixels_len: usize,
}

impl Default for CursorImageLimits {
    fn default() -> Self {
        Self {
            max_width: 256,
            max_height: 256,
            max_pixels_len: 256 * 256 * 4,
        }
    }
}

/// OS-provided cursor shape variants available through `lurek.input.setCursor`.
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub enum SystemCursor {
    /// Standard pointer arrow (default).
    #[default]
    Arrow,
    /// Text I-beam for editable fields.
    IBeam,
    /// Spinning wait / busy indicator.
    Wait,
    /// Crosshair precision cursor.
    Crosshair,
    /// Hand pointer for clickable elements.
    Hand,
    /// Northwest–southeast resize arrows.
    SizeNWSE,
    /// Northeast–southwest resize arrows.
    SizeNESW,
    /// West–east horizontal resize arrows.
    SizeWE,
    /// North–south vertical resize arrows.
    SizeNS,
    /// Four-directional move/resize arrows.
    SizeAll,
    /// Blocked / not-allowed indicator.
    No,
}

impl SystemCursor {
    /// Parse a lower-case cursor name string and return the matching variant; unknown names fall back to `Arrow`.
    pub fn from_name(name: &str) -> Self {
        match name {
            "arrow" => SystemCursor::Arrow,
            "ibeam" => SystemCursor::IBeam,
            "wait" => SystemCursor::Wait,
            "crosshair" => SystemCursor::Crosshair,
            "hand" => SystemCursor::Hand,
            "sizenwse" => SystemCursor::SizeNWSE,
            "sizenesw" => SystemCursor::SizeNESW,
            "sizewe" => SystemCursor::SizeWE,
            "sizens" => SystemCursor::SizeNS,
            "sizeall" => SystemCursor::SizeAll,
            "no" => SystemCursor::No,
            _ => SystemCursor::Arrow,
        }
    }

    /// Return the lower-case name string for this variant.
    pub fn as_str(&self) -> &'static str {
        match self {
            SystemCursor::Arrow => "arrow",
            SystemCursor::IBeam => "ibeam",
            SystemCursor::Wait => "wait",
            SystemCursor::Crosshair => "crosshair",
            SystemCursor::Hand => "hand",
            SystemCursor::SizeNWSE => "sizenwse",
            SystemCursor::SizeNESW => "sizenesw",
            SystemCursor::SizeWE => "sizewe",
            SystemCursor::SizeNS => "sizens",
            SystemCursor::SizeAll => "sizeall",
            SystemCursor::No => "no",
        }
    }
}

/// Per-frame mouse state: position, button deltas, scroll, and cursor type.
pub struct MouseState {
    /// Current cursor X position in window pixels.
    pub x: f32,
    /// Current cursor Y position in window pixels.
    pub y: f32,
    /// Held state for buttons 0–4 (0 = left, 1 = right, 2 = middle).
    pub buttons: [bool; 5],
    /// True for each button index that transitioned to pressed this frame.
    pub buttons_pressed: [bool; 5],
    /// True for each button index that transitioned to released this frame.
    pub buttons_released: [bool; 5],
    /// Held state for additional mouse buttons, keyed by zero-based button index.
    extra_buttons: HashMap<usize, bool>,
    /// Extra buttons that transitioned to pressed this frame.
    extra_buttons_pressed: HashMap<usize, bool>,
    /// Extra buttons that transitioned to released this frame.
    extra_buttons_released: HashMap<usize, bool>,
    /// Click count and last timestamp per button for callback double-click information.
    click_state: HashMap<usize, (u64, u32)>,
    /// Raw pointer delta accumulated during the current frame.
    pub delta_x: f32,
    /// Raw pointer delta accumulated during the current frame.
    pub delta_y: f32,
    /// True when the OS cursor is visible.
    pub visible: bool,
    /// True when the cursor is grabbed (confined to window).
    pub grabbed: bool,
    /// True when relative (delta) mode is active — position reports deltas, not absolute coords.
    pub relative_mode: bool,
    /// Horizontal scroll accumulator for this frame.
    pub scroll_x: f64,
    /// Vertical scroll accumulator for this frame.
    pub scroll_y: f64,
    /// Currently active system cursor shape.
    pub cursor_type: SystemCursor,
    /// Pending warp-to position requested by the game; consumed by the runtime window loop.
    pending_position: Option<(f32, f32)>,
}

/// Provide a default zeroed mouse state.
impl Default for MouseState {
    fn default() -> Self {
        Self::new()
    }
}

impl MouseState {
    /// Create a mouse state with all buttons up, cursor visible at (0, 0).
    pub fn new() -> Self {
        MouseState {
            x: 0.0,
            y: 0.0,
            buttons: [false; 5],
            buttons_pressed: [false; 5],
            buttons_released: [false; 5],
            extra_buttons: HashMap::new(),
            extra_buttons_pressed: HashMap::new(),
            extra_buttons_released: HashMap::new(),
            click_state: HashMap::new(),
            delta_x: 0.0,
            delta_y: 0.0,
            visible: true,
            grabbed: false,
            relative_mode: false,
            scroll_x: 0.0,
            scroll_y: 0.0,
            cursor_type: SystemCursor::default(),
            pending_position: None,
        }
    }

    /// Clear per-frame button delta arrays and scroll accumulators; call at frame start.
    pub fn begin_frame(&mut self) {
        self.buttons_pressed = [false; 5];
        self.buttons_released = [false; 5];
        self.extra_buttons_pressed.clear();
        self.extra_buttons_released.clear();
        self.delta_x = 0.0;
        self.delta_y = 0.0;
        self.scroll_x = 0.0;
        self.scroll_y = 0.0;
    }

    /// Update the cursor position without queuing a warp request.
    pub fn update_position(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
    }

    /// Adds raw device movement to the delta accumulated for this frame.
    pub fn accumulate_delta(&mut self, dx: f32, dy: f32) {
        self.delta_x += dx;
        self.delta_y += dy;
    }

    /// Set position and queue a warp request for the OS to move the hardware cursor.
    pub fn request_position(&mut self, x: f32, y: f32) {
        self.update_position(x, y);
        self.pending_position = Some((x, y));
    }

    /// Record a button state change for `button` (0–4) and update pressed/released delta flags.
    pub fn set_button(&mut self, button: usize, pressed: bool) {
        if button < 5 {
            let was_pressed = self.buttons[button];
            self.buttons[button] = pressed;
            if pressed && !was_pressed {
                self.buttons_pressed[button] = true;
            } else if !pressed && was_pressed {
                self.buttons_released[button] = true;
            }
        } else {
            let was_pressed = self.extra_buttons.get(&button).copied().unwrap_or(false);
            self.extra_buttons.insert(button, pressed);
            if pressed && !was_pressed {
                self.extra_buttons_pressed.insert(button, true);
            } else if !pressed && was_pressed {
                self.extra_buttons_released.insert(button, true);
            }
        }
    }

    /// Return true when `button` (0–4) is currently held down.
    pub fn is_down(&self, button: usize) -> bool {
        if button < 5 {
            self.buttons[button]
        } else {
            self.extra_buttons.get(&button).copied().unwrap_or(false)
        }
    }

    /// Register a press and return its click count using a 500 ms multi-click window.
    pub fn register_click(&mut self, button: usize, time_ms: u64) -> u32 {
        let (previous_time, previous_count) =
            self.click_state.get(&button).copied().unwrap_or((0, 0));
        let count = if time_ms.saturating_sub(previous_time) <= 500 {
            previous_count.saturating_add(1)
        } else {
            1
        };
        self.click_state.insert(button, (time_ms, count));
        count
    }

    /// Return the most recent click count for a button, or zero when never pressed.
    pub fn click_count(&self, button: usize) -> u32 {
        self.click_state.get(&button).map_or(0, |(_, count)| *count)
    }

    /// Return true when a zero-based button index transitioned to pressed this frame.
    pub fn was_pressed(&self, button: usize) -> bool {
        if button < 5 {
            self.buttons_pressed[button]
        } else {
            self.extra_buttons_pressed.contains_key(&button)
        }
    }

    /// Return true when a zero-based button index transitioned to released this frame.
    pub fn was_released(&self, button: usize) -> bool {
        if button < 5 {
            self.buttons_released[button]
        } else {
            self.extra_buttons_released.contains_key(&button)
        }
    }

    /// Return the current cursor position as (x, y) in window pixels.
    pub fn get_position(&self) -> (f32, f32) {
        (self.x, self.y)
    }

    /// Returns raw device movement accumulated during the current frame.
    pub fn get_delta(&self) -> (f32, f32) {
        (self.delta_x, self.delta_y)
    }

    /// Clears held and transient mouse state after focus loss without callbacks.
    pub fn clear_all(&mut self) {
        self.buttons = [false; 5];
        self.buttons_pressed = [false; 5];
        self.buttons_released = [false; 5];
        self.extra_buttons.clear();
        self.extra_buttons_pressed.clear();
        self.extra_buttons_released.clear();
        self.click_state.clear();
        self.delta_x = 0.0;
        self.delta_y = 0.0;
    }

    /// Show or hide the OS cursor. This function is part of the public API.
    pub fn set_visible(&mut self, visible: bool) {
        self.visible = visible;
    }

    /// Return true when the OS cursor is currently visible.
    pub fn is_visible(&self) -> bool {
        self.visible
    }

    /// Confine or release the cursor from the window bounds.
    pub fn set_grabbed(&mut self, grabbed: bool) {
        self.grabbed = grabbed;
    }

    /// Return true when the cursor is currently grabbed.
    pub fn is_grabbed(&self) -> bool {
        self.grabbed
    }

    /// Enable or disable relative (delta) mouse mode.
    pub fn set_relative_mode(&mut self, relative: bool) {
        self.relative_mode = relative;
    }

    /// Return true when relative mode is active.
    pub fn get_relative_mode(&self) -> bool {
        self.relative_mode
    }

    /// Add `dx` and `dy` to the scroll accumulators for this frame.
    pub fn accumulate_scroll(&mut self, dx: f64, dy: f64) {
        self.scroll_x += dx;
        self.scroll_y += dy;
    }

    /// Return accumulated scroll amounts as (scroll_x, scroll_y) for this frame.
    pub fn get_scroll(&self) -> (f64, f64) {
        (self.scroll_x, self.scroll_y)
    }

    /// Set the active system cursor shape.
    pub fn set_cursor(&mut self, cursor: SystemCursor) {
        self.cursor_type = cursor;
    }

    /// Return the current active system cursor shape.
    pub fn get_cursor(&self) -> SystemCursor {
        self.cursor_type
    }

    /// Consume and return the pending warp-position request, or `None` when no warp is queued.
    pub(crate) fn take_pending_position(&mut self) -> Option<(f32, f32)> {
        self.pending_position.take()
    }
}

/// Describes the shape source for a cursor: either a system preset or a custom RGBA pixel buffer.
#[derive(Debug, Clone)]
pub enum CursorKind {
    /// A standard OS-provided cursor shape.
    System(SystemCursor),
    /// A custom image-based cursor with a pixel buffer and hotspot.
    Custom {
        /// Raw RGBA pixel data for the cursor image.
        pixels: Vec<u8>,
        /// Image width in pixels.
        width: u32,
        /// Image height in pixels.
        height: u32,
        /// Hotspot X offset from the top-left corner.
        hotx: u32,
        /// Hotspot Y offset from the top-left corner.
        hoty: u32,
    },
}

/// Holds a cursor description used to set the active OS cursor.
#[derive(Debug, Clone)]
pub struct CursorHandle {
    /// The cursor shape description.
    pub kind: CursorKind,
}

/// Return true; custom cursor images are supported on the desktop target.
pub fn is_cursor_supported() -> bool {
    true
}

/// Validate a custom RGBA cursor image against dimension, buffer, and hotspot constraints.
pub fn validate_cursor_image(
    width: u32,
    height: u32,
    pixels_len: usize,
    hotx: u32,
    hoty: u32,
    limits: CursorImageLimits,
) -> Result<(), String> {
    if width == 0 || height == 0 {
        return Err("cursor width and height must be greater than zero".to_string());
    }
    if width > limits.max_width || height > limits.max_height {
        return Err(format!(
            "cursor dimensions {}x{} exceed limit {}x{}",
            width, height, limits.max_width, limits.max_height
        ));
    }
    let expected_len = (width as usize)
        .checked_mul(height as usize)
        .and_then(|count| count.checked_mul(4))
        .ok_or_else(|| "cursor RGBA buffer size overflowed".to_string())?;
    if expected_len > limits.max_pixels_len {
        return Err(format!(
            "cursor RGBA buffer size {} exceeds limit {}",
            expected_len, limits.max_pixels_len
        ));
    }
    if pixels_len != expected_len {
        return Err(format!(
            "cursor RGBA buffer length {} does not match expected {}",
            pixels_len, expected_len
        ));
    }
    if hotx >= width || hoty >= height {
        return Err(format!(
            "cursor hotspot ({}, {}) must stay within {}x{} image bounds",
            hotx, hoty, width, height
        ));
    }
    Ok(())
}
