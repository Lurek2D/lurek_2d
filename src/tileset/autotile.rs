//! Owns tileset-level autotile matching policy shared by tilemap rendering and tileset metadata.

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
