//! Owns named tilefield profiles that stamp blocker, cost, and sun-occlusion semantics onto cells.
//! Provides built-in wall, window, door, half-wall, and empty profiles for common tactical map objects.
//! Stores profile data only, keeping renderer geometry and gameplay consumers independent of each other.
//! Lets `TileField` apply reusable object semantics without duplicating channel maps at every call site.
//! Does not calculate movement, visibility, action lines, lighting, minimap overlays, or render geometry.

use crate::tilefield::cell::TileChannel;
use std::collections::HashMap;

/// Named collection of channel blockers, channel costs, and sun attenuation.
#[derive(Debug, Clone)]
pub struct TileProfile {
    /// Per-channel blocker overrides.
    pub blockers: HashMap<TileChannel, bool>,
    /// Per-channel cost overrides.
    pub costs: HashMap<TileChannel, f32>,
    /// Top-light occlusion value in 0..1.
    pub sun_occlusion: f32,
}

impl Default for TileProfile {
    fn default() -> Self {
        Self {
            blockers: HashMap::new(),
            costs: HashMap::new(),
            sun_occlusion: 0.0,
        }
    }
}

impl TileProfile {
    /// Create a profile from blocker states and sun occlusion.
    pub fn with_blocks(blocks: &[(TileChannel, bool)], sun_occlusion: f32) -> Self {
        let mut profile = Self {
            sun_occlusion: sun_occlusion.clamp(0.0, 1.0),
            ..Self::default()
        };
        for (channel, blocked) in blocks {
            profile.blockers.insert(*channel, *blocked);
        }
        profile
    }

    /// Return the built-in profile table.
    pub fn builtins() -> HashMap<String, Self> {
        use TileChannel::{Action, Light, Move, Vision};
        let mut profiles = HashMap::new();
        profiles.insert(
            "empty".to_string(),
            Self::with_blocks(
                &[
                    (Move, false),
                    (Vision, false),
                    (Action, false),
                    (Light, false),
                ],
                0.0,
            ),
        );
        profiles.insert(
            "wall".to_string(),
            Self::with_blocks(
                &[(Move, true), (Vision, true), (Action, true), (Light, true)],
                1.0,
            ),
        );
        profiles.insert(
            "window".to_string(),
            Self::with_blocks(
                &[
                    (Move, true),
                    (Vision, false),
                    (Action, true),
                    (Light, false),
                ],
                0.0,
            ),
        );
        profiles.insert(
            "door_closed".to_string(),
            Self::with_blocks(
                &[(Move, true), (Vision, true), (Action, true), (Light, true)],
                1.0,
            ),
        );
        profiles.insert(
            "door_open".to_string(),
            Self::with_blocks(
                &[
                    (Move, false),
                    (Vision, false),
                    (Action, false),
                    (Light, false),
                ],
                0.0,
            ),
        );
        profiles.insert(
            "half_wall".to_string(),
            Self::with_blocks(
                &[(Move, true), (Vision, true), (Action, false), (Light, true)],
                0.5,
            ),
        );
        profiles
    }
}
