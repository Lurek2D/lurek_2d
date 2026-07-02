//! `src/cursor/zoom.rs` owns the magnifier lens config used by the shared cursor overlay runtime.
//! `CursorZoom` stores magnification, radius, border styling, softness, and an optional shader override.
//! The runtime reads this owner when it decides whether to draw a live circular lens over the captured frame.
//! Open this file when zoom-lens tuning or persisted cursor magnifier defaults change across integrations.

use crate::runtime::resource_keys::ShaderKey;

/// Cursor zoom/magnifier configuration.
#[derive(Debug, Clone)]
pub struct CursorZoom {
    pub enabled: bool,
    pub magnification: f32,
    pub radius: f32,
    pub border_color: [f32; 4],
    pub border_width: f32,
    pub softness: f32,
    pub shader_key: Option<ShaderKey>,
}

impl CursorZoom {
    /// Create a zoom lens with one magnification factor and lens radius.
    pub fn new(magnification: f32, radius: f32) -> Self {
        Self {
            enabled: true,
            magnification: magnification.clamp(1.0, 10.0),
            radius: radius.max(8.0),
            border_color: [1.0, 1.0, 1.0, 0.9],
            border_width: 2.0,
            softness: 1.5,
            shader_key: None,
        }
    }

    /// Set magnification, clamped to `[1.0, 10.0]`.
    pub fn set_magnification(&mut self, magnification: f32) {
        self.magnification = magnification.clamp(1.0, 10.0);
    }

    /// Set lens radius in pixels.
    pub fn set_radius(&mut self, radius: f32) {
        self.radius = radius.max(8.0);
    }

    /// Set border width in pixels.
    pub fn set_border_width(&mut self, border_width: f32) {
        self.border_width = border_width.max(0.0);
    }

    /// Toggle the zoom lens on or off.
    pub fn toggle(&mut self) {
        self.enabled = !self.enabled;
    }
}

impl Default for CursorZoom {
    fn default() -> Self {
        Self::new(2.0, 64.0)
    }
}
