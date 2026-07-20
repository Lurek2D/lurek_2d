//! Shared ceilings for Lua-controlled UI input, retained state, traversal, and software capture.
//!
//! This policy is deliberately owned by `ui`: loaders, Lua conversion helpers,
//! event production, and image capture use the same defaults so one entry path
//! cannot bypass another. Trusted engine setup may replace the policy before a
//! game starts; normal Lua code cannot change it.

/// Bounded resource policy applied at UI trust boundaries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct UiLimits {
    /// Maximum number of live widgets, including the root.
    pub max_live_widgets: usize,
    /// Maximum number of direct children in one widget container.
    pub max_children_per_widget: usize,
    /// Maximum accepted retained-tree depth.
    pub max_tree_depth: usize,
    /// Maximum bytes accepted for a TOML layout source.
    pub max_layout_bytes: usize,
    /// Maximum UTF-8 bytes in one Lua/TOML UI string.
    pub max_string_bytes: usize,
    /// Maximum entries accepted by Lua array/table conversion helpers.
    pub max_collection_items: usize,
    /// Maximum queued events and callbacks dispatched in one update.
    pub max_pending_events: usize,
    /// Maximum retained render commands generated for one frame.
    pub max_render_commands: usize,
    /// Maximum screenshot width and height in pixels.
    pub max_image_width: u32,
    /// Maximum screenshot height in pixels.
    pub max_image_height: u32,
    /// Maximum screenshot pixel count.
    pub max_image_pixels: u64,
    /// Maximum encoded output size.
    pub max_encoded_image_bytes: usize,
    /// Maximum logical output path length in bytes.
    pub max_path_bytes: usize,
}

impl Default for UiLimits {
    fn default() -> Self {
        Self {
            max_live_widgets: 8_192,
            max_children_per_widget: 1_024,
            max_tree_depth: 128,
            max_layout_bytes: 1_048_576,
            max_string_bytes: 65_536,
            max_collection_items: 10_000,
            max_pending_events: 4_096,
            max_render_commands: 100_000,
            max_image_width: 4_096,
            max_image_height: 4_096,
            max_image_pixels: 16_777_216,
            max_encoded_image_bytes: 64 * 1024 * 1024,
            max_path_bytes: 512,
        }
    }
}

impl UiLimits {
    /// Validate a software-capture allocation before allocating pixel storage.
    pub fn validate_image_dimensions(&self, width: u32, height: u32) -> Result<(), String> {
        if width == 0 || height == 0 {
            return Err("lurek.ui: image dimensions must be positive".to_string());
        }
        if width > self.max_image_width || height > self.max_image_height {
            return Err(format!(
                "lurek.ui: image dimensions {}x{} exceed the {}x{} limit",
                width, height, self.max_image_width, self.max_image_height
            ));
        }
        let pixels = u64::from(width)
            .checked_mul(u64::from(height))
            .ok_or_else(|| "lurek.ui: image pixel count overflow".to_string())?;
        if pixels > self.max_image_pixels {
            return Err(format!(
                "lurek.ui: image pixel count {} exceeds the {} limit",
                pixels, self.max_image_pixels
            ));
        }
        pixels
            .checked_mul(4)
            .ok_or_else(|| "lurek.ui: RGBA byte count overflow".to_string())?;
        Ok(())
    }
    /// Normalize a frame delta to a finite, bounded value.
    pub fn normalized_dt(&self, dt: f32) -> f32 {
        if dt.is_finite() {
            dt.max(0.0).min(0.25)
        } else {
            0.0
        }
    }
}
