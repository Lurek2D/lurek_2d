//! Owns logical tilefield topology parsing and distance rules for square, isometric-square, and axial hex grids.
//! Treats isometric-square as square gameplay math because projection belongs to tilemap and render code.
//! Provides distance helpers used by field lighting, ranges, and topology-aware line generation.
//! Does not store map data, render coordinates, pathfinding policies, player masks, or minimap presentation.

use crate::tilefield::line::CellCoord;

/// Logical tile topology for line and distance queries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TileTopology {
    /// Orthogonal square grid.
    Square,
    /// Isometric presentation over square gameplay cells.
    IsoSquare,
    /// Axial hex grid using x=q and y=r.
    Hex,
}

impl TileTopology {
    /// Parse a public topology string.
    pub fn parse(value: &str) -> Result<Self, String> {
        match value {
            "square" => Ok(Self::Square),
            "iso_square" => Ok(Self::IsoSquare),
            "hex" => Ok(Self::Hex),
            other => Err(format!(
                "invalid tilefield topology '{other}' (expected square, iso_square, or hex)"
            )),
        }
    }

    /// Return the public topology string.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Square => "square",
            Self::IsoSquare => "iso_square",
            Self::Hex => "hex",
        }
    }

    /// Return tile distance between two same-level cells.
    pub fn distance(self, a: CellCoord, b: CellCoord) -> u32 {
        let dx = (a.x as i32 - b.x as i32).unsigned_abs();
        let dy = (a.y as i32 - b.y as i32).unsigned_abs();
        match self {
            Self::Square | Self::IsoSquare => dx.max(dy),
            Self::Hex => {
                let dz = (a.x as i32 + a.y as i32 - b.x as i32 - b.y as i32).unsigned_abs();
                dx.max(dy).max(dz)
            }
        }
    }
}
