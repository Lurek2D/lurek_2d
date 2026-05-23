//! - Precompute border-pair index map from province id grid.
//! - Assigns a stable u16 pair id for each detected border pixel.
//! - Optional dilation expands border coverage for thick styled borders.

use crate::province::registry::ProvinceRegistry;
use crate::province::types::{BorderPairStyle, ProvinceId};
use std::collections::HashMap;

/// Dense per-pixel border pair index map.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProvinceBorderIndex {
    /// Row-major pair ids. Zero means "not a border pixel".
    pub data: Vec<u16>,
    /// Grid width in pixels.
    pub width: u32,
    /// Grid height in pixels.
    pub height: u32,
    /// Pair id -> (province_a, province_b), index 0 unused.
    pub id_to_pair: Vec<(ProvinceId, ProvinceId)>,
    /// (province_a, province_b) -> pair id.
    pub pair_to_id: HashMap<(ProvinceId, ProvinceId), u16>,
}

impl ProvinceBorderIndex {
    /// Return pair id at (x, y), or None when out of bounds.
    pub fn at(&self, x: u32, y: u32) -> Option<u16> {
        if x >= self.width || y >= self.height {
            return None;
        }
        self.data.get((y * self.width + x) as usize).copied()
    }

    /// Return number of unique province pairs referenced by this index.
    pub fn pair_count(&self) -> usize {
        self.id_to_pair.len().saturating_sub(1)
    }
}

fn norm_pair(a: ProvinceId, b: ProvinceId) -> (ProvinceId, ProvinceId) {
    if a < b {
        (a, b)
    } else {
        (b, a)
    }
}

fn assign_pair_id(
    pair_to_id: &mut HashMap<(ProvinceId, ProvinceId), u16>,
    id_to_pair: &mut Vec<(ProvinceId, ProvinceId)>,
    a: ProvinceId,
    b: ProvinceId,
) -> Option<u16> {
    if a == b {
        return None;
    }
    let pair = norm_pair(a, b);
    if let Some(id) = pair_to_id.get(&pair) {
        return Some(*id);
    }
    let next = (id_to_pair.len()) as u16;
    if next == 0 {
        return None;
    }
    pair_to_id.insert(pair, next);
    id_to_pair.push(pair);
    Some(next)
}

/// Build border index map from raw province id grid.
pub fn build_border_index(grid: &[u32], width: u32, height: u32) -> ProvinceBorderIndex {
    let expected_len = (width as usize).saturating_mul(height as usize);
    assert_eq!(
        grid.len(), expected_len,
        "grid length must be width*height"
    );

    let mut data = vec![0_u16; expected_len];
    let mut pair_to_id: HashMap<(ProvinceId, ProvinceId), u16> = HashMap::new();
    let mut id_to_pair: Vec<(ProvinceId, ProvinceId)> = vec![(0, 0)];

    for y in 0..height {
        for x in 0..width {
            let idx = (y * width + x) as usize;
            let id = grid[idx];

            let mut assigned = 0_u16;
            if x + 1 < width {
                let right = grid[(y * width + (x + 1)) as usize];
                if right != id {
                    if let Some(pid) = assign_pair_id(&mut pair_to_id, &mut id_to_pair, id, right) {
                        assigned = pid;
                    }
                }
            }
            if assigned == 0 && y + 1 < height {
                let down = grid[((y + 1) * width + x) as usize];
                if down != id {
                    if let Some(pid) = assign_pair_id(&mut pair_to_id, &mut id_to_pair, id, down) {
                        assigned = pid;
                    }
                }
            }
            data[idx] = assigned;
        }
    }

    ProvinceBorderIndex {
        data,
        width,
        height,
        id_to_pair,
        pair_to_id,
    }
}

/// Expand border pixels by radius per pair style thickness.
pub fn dilate_border_index_with_styles(
    index: &mut ProvinceBorderIndex,
    styles: &HashMap<(ProvinceId, ProvinceId), BorderPairStyle>,
) {
    let width = index.width;
    let height = index.height;
    let src = index.data.clone();
    let mut dst = src.clone();

    for y in 0..height {
        for x in 0..width {
            let idx = (y * width + x) as usize;
            let pair_id = src[idx];
            if pair_id == 0 {
                continue;
            }
            let pair = index.id_to_pair[pair_id as usize];
            let style = styles.get(&pair).copied().unwrap_or_default();
            let radius = ((style.thickness.max(1.0) - 1.0) * 0.5).ceil() as i32;
            if radius <= 0 {
                continue;
            }
            for oy in -radius..=radius {
                for ox in -radius..=radius {
                    let nx = x as i32 + ox;
                    let ny = y as i32 + oy;
                    if nx < 0 || ny < 0 {
                        continue;
                    }
                    if nx >= width as i32 || ny >= height as i32 {
                        continue;
                    }
                    let nidx = (ny as u32 * width + nx as u32) as usize;
                    if dst[nidx] == 0 {
                        dst[nidx] = pair_id;
                    }
                }
            }
        }
    }

    index.data = dst;
}

/// Build border index map directly from current registry pixel grid.
pub fn build_border_index_from_registry(registry: &ProvinceRegistry) -> ProvinceBorderIndex {
    let width = registry.width();
    let height = registry.height();
    let mut ids = Vec::with_capacity((width as usize).saturating_mul(height as usize));
    for y in 0..height {
        for x in 0..width {
            ids.push(registry.get_at(x, y));
        }
    }
    build_border_index(&ids, width, height)
}
