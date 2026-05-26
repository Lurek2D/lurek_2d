//! Map orientation modes: TopDown and Isometric projection support.
//!
//! - `Orientation` enum controls how (grid_x, grid_y) maps to screen (pixel_x, pixel_y).
//! - `TopDown` uses a direct pixel-per-tile scale with no shear.
//! - `Isometric` applies the standard 2:1 diamond transform for 2.5D appearance.
//! - The active orientation is set in `MapBlockConfig` and applied by the tilemap renderer.

/// Projection / rendering orientation for the generated map.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MapOrientation {
    /// Standard top-down tile map (Dwarf Fortress style).
    TopDown,
    /// Isometric 2:1 diamond projection (UFO X-COM Defense style).
    Isometric,
}

impl MapOrientation {
    /// Parse orientation from string.
    pub fn from_str(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "topdown" | "top_down" | "top-down" => Some(Self::TopDown),
            "isometric" | "iso" => Some(Self::Isometric),
            _ => None,
        }
    }

    /// Convert to string representation.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::TopDown => "topdown",
            Self::Isometric => "isometric",
        }
    }
}
