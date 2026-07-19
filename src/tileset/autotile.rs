//! Owns autotile matching modes and terrain-profile metadata.
//!
//! The module describes authoring metadata only. Tilemap owns neighborhood scans,
//! map mutation, and dirty-region propagation when these rules are applied.

use crate::tileset::error::TilesetError;
use crate::tileset::limits::TilesetLimits;

/// Terrain-neighbour matching strategy used when applying autotile rules.
///
/// # Variants
///
/// Each variant selects which neighboring occupancy bits tilemap may interpret.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AutoTileMode {
    /// Match only north, east, south, and west sides.
    MatchSides,
    /// Match only corner/diagonal occupancy.
    MatchCorners,
    /// Match sides and valid corners together.
    MatchCornersAndSides,
}

/// Godot-style terrain-set profile metadata for autotile authoring.
///
/// # Fields
///
/// The profile names a terrain set, matching mode, and optional zero-based
/// fallback tile id.
#[derive(Debug, Clone)]
pub struct TerrainProfile {
    /// Terrain set name or category.
    pub terrain_set: String,
    /// Neighbor matching strategy used by this terrain set.
    pub mode: AutoTileMode,
    /// Optional default local tile id used when no bitmask rule matches.
    pub default_tile_id: Option<u32>,
}

impl TerrainProfile {
    /// Validate the profile without applying it to any map cells.
    pub fn validate(&self, limits: &TilesetLimits) -> Result<(), TilesetError> {
        if self.terrain_set.trim().is_empty() {
            return Err(TilesetError::invalid(
                "terrain profile terrain_set",
                "must not be empty",
            ));
        }
        if self.terrain_set.len() > limits.max_string_bytes {
            return Err(TilesetError::LimitExceeded {
                resource: "terrain set string bytes",
                requested: self.terrain_set.len() as u64,
                maximum: limits.max_string_bytes as u64,
            });
        }
        Ok(())
    }
}

impl AutoTileMode {
    /// Return the stable Lua/API name for this matching strategy.
    pub fn as_str(self) -> &'static str {
        match self {
            AutoTileMode::MatchSides => "matchSides",
            AutoTileMode::MatchCorners => "matchCorners",
            AutoTileMode::MatchCornersAndSides => "matchCornersAndSides",
        }
    }
}
