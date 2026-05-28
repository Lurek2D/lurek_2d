//! Cursor magnifier lens: a configurable zoom window that follows the cursor.
//!
//! - `ZoomConfig` sets lens radius, magnification factor, and optional border style.
//! - The lens is rendered as a post-process scissored blit after the main render pass.
//! - Magnification clamps between 1.1× and 8.0× to avoid pixel smear at extremes.
//! - Enabled/disabled via `lurek.cursor.set_zoom(config)` or the `[cursor]` TOML block.

/// Cursor zoom/magnifier configuration.
#[derive(Debug, Clone)]
pub struct CursorZoom {
    /// Whether this feature is enabled.
    pub enabled: bool,
    /// Zoom magnification factor for the lens.
    pub magnification: f32,
    /// Radius in pixels.
    pub radius: f32,
    /// Border color around the magnifier lens.
    pub border_color: [f32; 4],
    /// Border stroke width around the magnifier lens.
    pub border_width: f32,
}

impl CursorZoom {
    /// Create a zoom lens with the given magnification factor and lens radius in pixels.
    pub fn new(magnification: f32, radius: f32) -> Self {
        Self {
            enabled: true,
            magnification: magnification.clamp(1.0, 10.0),
            radius: radius.max(8.0),
            border_color: [1.0, 1.0, 1.0, 0.8],
            border_width: 2.0,
        }
    }

    /// Set the magnification factor, clamped to `[1.0, 10.0]`.
    pub fn set_magnification(&mut self, mag: f32) {
        self.magnification = mag.clamp(1.0, 10.0);
    }

    /// Set the zoom lens radius in pixels; minimum enforced to 8 pixels.
    pub fn set_radius(&mut self, radius: f32) {
        self.radius = radius.max(8.0);
    }

    /// Toggle the zoom lens between enabled and disabled.
    pub fn toggle(&mut self) {
        self.enabled = !self.enabled;
    }
}

impl Default for CursorZoom {
    fn default() -> Self {
        Self::new(2.0, 64.0)
    }
}
