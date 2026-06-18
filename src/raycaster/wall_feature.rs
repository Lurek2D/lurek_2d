//! This file owns `WallFeatureKind` and `WallFeature`, the cell-local descriptors for wall behavior refinement.
//! It models half-height walls, window openings, and sliding doors without changing the base tile map schema.
//! Constructors clamp feature parameters into safe ranges so tools and scene builders share stable semantics.
//! Query helpers answer movement, visibility, and light blocking from the same payload used by rendering code.
//! Open this file when per-cell wall behavior changes; door state progression and scene assembly live in siblings.

use super::doors::DoorDirection;

/// Specialized wall behavior attached to one blocking raycaster cell.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum WallFeatureKind {
    /// A low wall that rises only partway from the floor.
    HalfHeight {
        /// Height of the solid section measured from the floor, 0.0..1.0.
        height: f32,
    },
    /// A wall with a transparent opening between sill and lintel heights.
    Window {
        /// Bottom of the opening measured from the floor, 0.0..1.0.
        sill_height: f32,
        /// Top of the opening measured from the floor, 0.0..1.0.
        lintel_height: f32,
    },
    /// A sliding door represented as a narrowing slab inside the cell.
    Door {
        /// Slide axis of the door.
        direction: DoorDirection,
        /// Open amount, 0.0 closed to 1.0 fully open.
        open_amount: f32,
    },
}

impl WallFeatureKind {
    /// Return true when this feature kind represents a sliding door.
    pub fn is_door(self) -> bool {
        matches!(self, WallFeatureKind::Door { .. })
    }
}

/// Full feature payload for one wall cell, including alpha override.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct WallFeature {
    /// Kind-specific render and collision behavior.
    pub kind: WallFeatureKind,
    /// Alpha override used for see-through materials such as windows or grates.
    pub alpha: f32,
}

impl WallFeature {
    /// Construct a half-height wall feature.
    pub fn half_height(height: f32) -> Self {
        Self {
            kind: WallFeatureKind::HalfHeight {
                height: height.clamp(0.05, 1.0),
            },
            alpha: 1.0,
        }
    }

    /// Construct a window feature with an opening between sill and lintel.
    pub fn window(sill_height: f32, lintel_height: f32, alpha: f32) -> Self {
        let sill = sill_height.clamp(0.0, 0.95);
        let lintel = lintel_height.clamp((sill + 0.05).min(1.0), 1.0);
        Self {
            kind: WallFeatureKind::Window {
                sill_height: sill,
                lintel_height: lintel,
            },
            alpha: alpha.clamp(0.0, 1.0),
        }
    }

    /// Construct a sliding door feature.
    pub fn door(direction: DoorDirection, open_amount: f32, alpha: f32) -> Self {
        Self {
            kind: WallFeatureKind::Door {
                direction,
                open_amount: open_amount.clamp(0.0, 1.0),
            },
            alpha: alpha.clamp(0.0, 1.0),
        }
    }

    /// Return the alpha override for this feature.
    pub fn alpha(self) -> f32 {
        self.alpha
    }

    /// Return true when the feature should stop 2D movement.
    pub fn blocks_movement(self) -> bool {
        match self.kind {
            WallFeatureKind::Door { open_amount, .. } => open_amount < 0.95,
            _ => true,
        }
    }

    /// Return true when the feature should stop line of sight.
    pub fn blocks_visibility(self) -> bool {
        match self.kind {
            WallFeatureKind::Window { .. } => false,
            WallFeatureKind::Door { open_amount, .. } => open_amount < 0.95,
            WallFeatureKind::HalfHeight { .. } => true,
        }
    }

    /// Return true when the feature should stop tile-level light propagation.
    pub fn blocks_light(self) -> bool {
        match self.kind {
            WallFeatureKind::Window { .. } => false,
            WallFeatureKind::Door { open_amount, .. } => open_amount < 0.95,
            WallFeatureKind::HalfHeight { .. } => true,
        }
    }
}
