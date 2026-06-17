//! Orientation modes for interpreting generated mapblock layouts. `mapblock/orientation` delivers the orientation implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Provides top-down and isometric variants for different presentation styles. The file owns or coordinates data contracts including `MapOrientation`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supplies parsing and helpers used by config-driven renderer integration. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str` stays attached to the local data model and invariants.

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
