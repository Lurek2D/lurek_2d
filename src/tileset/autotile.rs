//! This file owns autotile behavior inside the tileset subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate autotile state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

/// Terrain-neighbour matching strategy used when applying autotile rules.
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
#[derive(Debug, Clone)]
pub struct TerrainProfile {
    /// Terrain set name or category.
    pub terrain_set: String,
    /// Neighbor matching strategy used by this terrain set.
    pub mode: AutoTileMode,
    /// Optional default local tile id used when no bitmask rule matches.
    pub default_tile_id: Option<u32>,
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
