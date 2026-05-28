//! Distance-from-border precompute for province pixels.
//!
//! - Multi-source BFS seeded from border pixels where neighboring province ids differ.
//! - Produces a compact u8 field used by later shading or LOD passes.

use crate::province::registry::ProvinceRegistry;

/// Per-pixel distance to nearest province border, clamped to `max_distance`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProvinceDistanceField {
    /// Row-major distance values, length = width * height.
    pub data: Vec<u8>,
    /// Grid width in pixels.
    pub width: u32,
    /// Grid height in pixels.
    pub height: u32,
    /// Maximum propagated distance.
    pub max_distance: u8,
}

impl ProvinceDistanceField {
    /// Return field value at (x, y), or None when out of bounds.
    pub fn at(&self, x: u32, y: u32) -> Option<u8> {
        if x >= self.width || y >= self.height {
            return None;
        }
        self.data.get((y * self.width + x) as usize).copied()
    }
}

fn is_border_pixel(grid: &[u32], width: u32, height: u32, x: u32, y: u32) -> bool {
    let idx = (y * width + x) as usize;
    let id = grid[idx];

    if x > 0 && grid[(y * width + (x - 1)) as usize] != id {
        return true;
    }
    if x + 1 < width && grid[(y * width + (x + 1)) as usize] != id {
        return true;
    }
    if y > 0 && grid[((y - 1) * width + x) as usize] != id {
        return true;
    }
    if y + 1 < height && grid[((y + 1) * width + x) as usize] != id {
        return true;
    }

    false
}

/// Compute distance-to-border field from a raw province id grid.
pub fn compute_distance_field(
    grid: &[u32],
    width: u32,
    height: u32,
    max_distance: u8,
) -> ProvinceDistanceField {
    use std::collections::VecDeque;

    let expected_len = (width as usize).saturating_mul(height as usize);
    assert_eq!(
        grid.len(), expected_len,
        "grid length must be width*height"
    );

    let mut out = vec![u8::MAX; expected_len];
    let mut queue: VecDeque<(u32, u32)> = VecDeque::new();

    for y in 0..height {
        for x in 0..width {
            if is_border_pixel(grid, width, height, x, y) {
                let idx = (y * width + x) as usize;
                out[idx] = 0;
                queue.push_back((x, y));
            }
        }
    }

    while let Some((x, y)) = queue.pop_front() {
        let idx = (y * width + x) as usize;
        let d = out[idx];
        if d >= max_distance {
            continue;
        }

        if x > 0 {
            let nidx = (y * width + (x - 1)) as usize;
            let nd = d.saturating_add(1);
            if out[nidx] > nd {
                out[nidx] = nd;
                queue.push_back((x - 1, y));
            }
        }
        if x + 1 < width {
            let nidx = (y * width + (x + 1)) as usize;
            let nd = d.saturating_add(1);
            if out[nidx] > nd {
                out[nidx] = nd;
                queue.push_back((x + 1, y));
            }
        }
        if y > 0 {
            let nidx = ((y - 1) * width + x) as usize;
            let nd = d.saturating_add(1);
            if out[nidx] > nd {
                out[nidx] = nd;
                queue.push_back((x, y - 1));
            }
        }
        if y + 1 < height {
            let nidx = ((y + 1) * width + x) as usize;
            let nd = d.saturating_add(1);
            if out[nidx] > nd {
                out[nidx] = nd;
                queue.push_back((x, y + 1));
            }
        }
    }

    ProvinceDistanceField {
        data: out,
        width,
        height,
        max_distance,
    }
}

/// Build a distance field directly from the current registry pixel grid.
pub fn compute_distance_field_from_registry(
    registry: &ProvinceRegistry,
    max_distance: u8,
) -> ProvinceDistanceField {
    let width = registry.width();
    let height = registry.height();
    let mut ids = Vec::with_capacity((width as usize).saturating_mul(height as usize));
    for y in 0..height {
        for x in 0..width {
            ids.push(registry.get_at(x, y));
        }
    }
    compute_distance_field(&ids, width, height, max_distance)
}
