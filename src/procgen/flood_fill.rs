//! BFS flood fill on a flat grid.
//!
//! Fills connected cells that match a threshold condition starting from a seed
//! coordinate, returning a binary mask.

/// BFS flood fill on a flat grid, returning a binary mask of all cells reachable from a
/// seed position whose values satisfy `threshold`. Cells with value `> threshold` are
/// considered walls and are excluded from the fill.
///
/// # Parameters
/// - `data` — `&[u8]`.
/// - `width` — `u32`.
/// - `height` — `u32`.
/// - `sx` — `u32`.
/// - `sy` — `u32`.
/// - `threshold` — `u8`.
/// - `above` — `bool`.
///
/// # Returns
/// `Vec<u8>`.
///
/// - `data`: flat grid values
/// - `threshold`: fill boundary value
/// - `above`: if true, fill cells >= threshold; if false, fill cells <= threshold
///
/// Returns a `Vec<u8>` mask of same size (1 = filled, 0 = not).
pub fn flood_fill(
    data: &[u8],
    width: u32,
    height: u32,
    sx: u32,
    sy: u32,
    threshold: u8,
    above: bool,
) -> Vec<u8> {
    let size = (width * height) as usize;
    if data.len() != size {
        return vec![0; size];
    }
    let mut result = vec![0u8; size];

    let start_idx = (sy * width + sx) as usize;
    if start_idx >= size {
        return result;
    }

    let matches = |v: u8| -> bool {
        if above {
            v >= threshold
        } else {
            v <= threshold
        }
    };

    if !matches(data[start_idx]) {
        return result;
    }

    let mut queue = std::collections::VecDeque::new();
    queue.push_back((sx, sy));
    result[start_idx] = 1;

    while let Some((x, y)) = queue.pop_front() {
        for &(dx, dy) in &[(-1i32, 0), (1, 0), (0, -1i32), (0, 1)] {
            let nx = x as i32 + dx;
            let ny = y as i32 + dy;
            if nx < 0 || ny < 0 || nx >= width as i32 || ny >= height as i32 {
                continue;
            }
            let nx = nx as u32;
            let ny = ny as u32;
            let ni = (ny * width + nx) as usize;
            if result[ni] == 0 && matches(data[ni]) {
                result[ni] = 1;
                queue.push_back((nx, ny));
            }
        }
    }

    result
}


