//! Map orientation modes: TopDown and Isometric projection support.
//!
//! - Enum: `MapOrientation`.

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
    pub fn from_name(s: &str) -> Option<Self> {
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
