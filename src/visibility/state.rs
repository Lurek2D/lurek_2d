//! This file provides the visibility state model that describes player knowledge per region. `visibility/state` delivers the state container and transition helpers for the visibility subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It encodes hidden, discovered, visible, and extensible custom levels in one ordered enum. The file owns or coordinates data contracts including `VisibilityState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It standardizes information progression so reveal logic and fog rendering stay consistent. Public callable behavior is centered on no named public items, while method-level behavior such as `level`, `from_level`, `is_known`, `is_visible` stays attached to the local data model and invariants.

/// Visibility state for a region from a specific player's perspective.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum VisibilityState {
    /// Completely hidden — player knows nothing about this region.
    #[default]
    Hidden,
    /// Previously seen but not currently visible — shows last-known state.
    Discovered,
    /// Currently visible — real-time information.
    Visible,
    /// Custom visibility level (game-defined semantics).
    Custom(u8),
}

impl VisibilityState {
    /// Returns the numeric level (Hidden=0, Discovered=1, Visible=2, Custom=3+).
    pub fn level(&self) -> u8 {
        match self {
            Self::Hidden => 0,
            Self::Discovered => 1,
            Self::Visible => 2,
            Self::Custom(v) => v.saturating_add(3),
        }
    }

    /// Create a state from a numeric level value.
    pub fn from_level(level: u8) -> Self {
        match level {
            0 => Self::Hidden,
            1 => Self::Discovered,
            2 => Self::Visible,
            v => Self::Custom(v.saturating_sub(3)),
        }
    }

    /// Whether the region has been seen at least once.
    pub fn is_known(&self) -> bool {
        !matches!(self, Self::Hidden)
    }

    /// Whether the region is currently fully visible.
    pub fn is_visible(&self) -> bool {
        matches!(self, Self::Visible)
    }
}
