//! Owns the tilefield topology implementation for the tilefield subsystem and keeps related runtime rules local here.
//! Keeps tilefield topology, authored grid data, and lookup helpers so helpers stay close to invariants this file updates.
//! Defines how tilefield topology data is validated, transformed, or stored before neighboring systems consume it.
//! Separates tilefield topology behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where tilefield code accepts inputs, reports errors, allocates state, or emits outputs.

use crate::tilefield::line::CellCoord;

/// Logical tile topology for line and distance queries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TileTopology {
    /// Orthogonal square grid using four-way movement distance.
    Square4,
    /// Orthogonal square grid using eight-way movement distance.
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
            "square4" => Ok(Self::Square4),
            "square8" => Ok(Self::Square),
            "square" => Ok(Self::Square),
            "iso_square" => Ok(Self::IsoSquare),
            "hex" => Ok(Self::Hex),
            other => Err(format!(
                "invalid tilefield topology '{other}' (expected square, square4, square8, iso_square, or hex)"
            )),
        }
    }

    /// Return the public topology string.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Square4 => "square4",
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
            Self::Square4 => dx + dy,
            Self::Square | Self::IsoSquare => dx.max(dy),
            Self::Hex => {
                let dz = (a.x as i32 + a.y as i32 - b.x as i32 - b.y as i32).unsigned_abs();
                dx.max(dy).max(dz)
            }
        }
    }

    /// Return a range metric suitable for radial budgets on one same-level field.
    pub fn range_distance(self, a: CellCoord, b: CellCoord) -> f32 {
        let dx = a.x.abs_diff(b.x) as f32;
        let dy = a.y.abs_diff(b.y) as f32;
        match self {
            Self::Square4 => dx + dy,
            Self::Square | Self::IsoSquare => (dx * dx + dy * dy).sqrt(),
            Self::Hex => self.distance(a, b) as f32,
        }
    }

    /// Return same-level neighbour cells inside the supplied bounds.
    pub fn neighbors(self, coord: CellCoord, width: u32, height: u32) -> Vec<CellCoord> {
        let offsets: &[(i32, i32)] = match self {
            Self::Square4 => &[(0, -1), (1, 0), (0, 1), (-1, 0)],
            Self::Square | Self::IsoSquare => &[
                (0, -1),
                (1, -1),
                (1, 0),
                (1, 1),
                (0, 1),
                (-1, 1),
                (-1, 0),
                (-1, -1),
            ],
            Self::Hex => &[(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)],
        };
        let mut result = Vec::with_capacity(offsets.len());
        for (dx, dy) in offsets {
            let x = coord.x as i32 + dx;
            let y = coord.y as i32 + dy;
            if x >= 0 && y >= 0 && (x as u32) < width && (y as u32) < height {
                result.push(CellCoord {
                    x: x as u32,
                    y: y as u32,
                    z: coord.z,
                });
            }
        }
        result
    }
}
