//! Owns deterministic tile-line traversal for square, isometric-square, hex, and vertical level checks.
//! Converts two zero-based cell coordinates into ordered cells used by blocker and occlusion queries.
//! Implements Bresenham square lines, axial hex interpolation, and same-column vertical level traversal.
//! Keeps traversal math independent from movement, visibility, action, lighting, and rendering decisions.
//! Rejects arbitrary diagonal multi-level lines so callers get a clear v1 boundary instead of guessed cells.

use crate::tilefield::topology::TileTopology;

/// Zero-based tile coordinate including level.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct CellCoord {
    /// Zero-based column or axial q.
    pub x: u32,
    /// Zero-based row or axial r.
    pub y: u32,
    /// Zero-based level.
    pub z: u32,
}

/// Compute a topology-specific line between two cells.
pub fn line_between(
    topology: TileTopology,
    from: CellCoord,
    to: CellCoord,
    include_endpoints: bool,
) -> Result<Vec<CellCoord>, String> {
    let mut cells = Vec::new();
    visit_line_cells(topology, from, to, |coord| {
        cells.push(coord);
        true
    })?;
    if !include_endpoints {
        if !cells.is_empty() {
            cells.remove(0);
        }
        if !cells.is_empty() {
            cells.pop();
        }
    }
    Ok(cells)
}

/// Visit every cell on a topology-specific line until the visitor returns false.
pub fn visit_line_cells(
    topology: TileTopology,
    from: CellCoord,
    to: CellCoord,
    mut visitor: impl FnMut(CellCoord) -> bool,
) -> Result<(), String> {
    if from.z != to.z {
        if from.x != to.x || from.y != to.y {
            return Err(
                "tilefield v1 supports cross-level lines only on the same x/y column".into(),
            );
        }
        visit_vertical_line(from, to, &mut visitor);
    } else {
        match topology {
            TileTopology::Square | TileTopology::IsoSquare => {
                visit_square_line(from, to, &mut visitor);
            }
            TileTopology::Hex => visit_hex_line(from, to, &mut visitor),
        }
    }
    Ok(())
}

fn visit_vertical_line(from: CellCoord, to: CellCoord, visitor: &mut impl FnMut(CellCoord) -> bool) {
    let start = from.z.min(to.z);
    let end = from.z.max(to.z);
    let mut cells: Vec<_> = (start..=end)
        .map(|z| CellCoord {
            x: from.x,
            y: from.y,
            z,
        })
        .collect();
    if from.z > to.z {
        cells.reverse();
    }
    for coord in cells {
        if !visitor(coord) {
            break;
        }
    }
}

fn visit_square_line(from: CellCoord, to: CellCoord, visitor: &mut impl FnMut(CellCoord) -> bool) {
    let mut x0 = from.x as i32;
    let mut y0 = from.y as i32;
    let x1 = to.x as i32;
    let y1 = to.y as i32;
    let dx = (x1 - x0).abs();
    let sx = if x0 < x1 { 1 } else { -1 };
    let dy = -(y1 - y0).abs();
    let sy = if y0 < y1 { 1 } else { -1 };
    let mut err = dx + dy;
    loop {
        if !visitor(CellCoord {
            x: x0 as u32,
            y: y0 as u32,
            z: from.z,
        }) {
            break;
        }
        if x0 == x1 && y0 == y1 {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            x0 += sx;
        }
        if e2 <= dx {
            err += dx;
            y0 += sy;
        }
    }
}

fn visit_hex_line(from: CellCoord, to: CellCoord, visitor: &mut impl FnMut(CellCoord) -> bool) {
    let n = hex_distance_2d(from, to);
    if n == 0 {
        visitor(from);
        return;
    }
    let a = axial_to_cube(from.x as f32, from.y as f32);
    let b = axial_to_cube(to.x as f32, to.y as f32);
    let mut previous = None;
    for step in 0..=n {
        let t = step as f32 / n as f32;
        let cube = (lerp(a.0, b.0, t), lerp(a.1, b.1, t), lerp(a.2, b.2, t));
        let (q, r) = cube_round(cube);
        let coord = CellCoord {
            x: q.max(0) as u32,
            y: r.max(0) as u32,
            z: from.z,
        };
        if previous == Some(coord) {
            continue;
        }
        previous = Some(coord);
        if !visitor(coord) {
            break;
        }
    }
}

fn hex_distance_2d(a: CellCoord, b: CellCoord) -> u32 {
    let dx = (a.x as i32 - b.x as i32).abs();
    let dy = (a.y as i32 - b.y as i32).abs();
    let dz = (a.x as i32 + a.y as i32 - b.x as i32 - b.y as i32).abs();
    dx.max(dy).max(dz) as u32
}

fn axial_to_cube(q: f32, r: f32) -> (f32, f32, f32) {
    (q, -q - r, r)
}

fn lerp(a: f32, b: f32, t: f32) -> f32 {
    a + (b - a) * t
}

fn cube_round(cube: (f32, f32, f32)) -> (i32, i32) {
    let mut rx = cube.0.round();
    let ry = cube.1.round();
    let mut rz = cube.2.round();
    let x_diff = (rx - cube.0).abs();
    let y_diff = (ry - cube.1).abs();
    let z_diff = (rz - cube.2).abs();
    if x_diff > y_diff && x_diff > z_diff {
        rx = -ry - rz;
    } else if z_diff > y_diff {
        rz = -rx - ry;
    }
    (rx as i32, rz as i32)
}
