//! Owns the province border index implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province border index data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province border index behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where province code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing province border index defaults, lifecycle handling, validation, or data ownership rules.

use crate::province::registry::ProvinceRegistry;
use crate::province::types::{BorderPairStyle, ProvinceGeometryKind, ProvinceId};
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

fn place_pair_id(data: &mut [u16], width: u32, height: u32, x: i32, y: i32, pair_id: u16) -> bool {
    if x < 0 || y < 0 || x >= width as i32 || y >= height as i32 {
        return false;
    }
    let idx = (y as u32 * width + x as u32) as usize;
    if data[idx] == 0 || data[idx] == pair_id {
        data[idx] = pair_id;
        return true;
    }
    false
}

fn place_horizontal_pair(data: &mut [u16], width: u32, height: u32, x: u32, y: u32, pair_id: u16) {
    let x = x as i32;
    let y = y as i32;
    let _ = place_pair_id(data, width, height, x, y, pair_id)
        || place_pair_id(data, width, height, x + 1, y, pair_id)
        || place_pair_id(data, width, height, x, y - 1, pair_id)
        || place_pair_id(data, width, height, x + 1, y - 1, pair_id)
        || place_pair_id(data, width, height, x, y + 1, pair_id)
        || place_pair_id(data, width, height, x + 1, y + 1, pair_id);
}

fn place_vertical_pair(data: &mut [u16], width: u32, height: u32, x: u32, y: u32, pair_id: u16) {
    let x = x as i32;
    let y = y as i32;
    let _ = place_pair_id(data, width, height, x, y, pair_id)
        || place_pair_id(data, width, height, x, y + 1, pair_id)
        || place_pair_id(data, width, height, x - 1, y, pair_id)
        || place_pair_id(data, width, height, x - 1, y + 1, pair_id)
        || place_pair_id(data, width, height, x + 1, y, pair_id)
        || place_pair_id(data, width, height, x + 1, y + 1, pair_id);
}

/// Build border index map from raw province id grid.
pub fn build_border_index(grid: &[u32], width: u32, height: u32) -> ProvinceBorderIndex {
    let expected_len = (width as usize).saturating_mul(height as usize);
    assert_eq!(grid.len(), expected_len, "grid length must be width*height");

    let mut data = vec![0_u16; expected_len];
    let mut pair_to_id: HashMap<(ProvinceId, ProvinceId), u16> = HashMap::new();
    let mut id_to_pair: Vec<(ProvinceId, ProvinceId)> = vec![(ProvinceId(0), ProvinceId(0))];

    for y in 0..height {
        for x in 0..width {
            let idx = (y * width + x) as usize;
            let id = ProvinceId(grid[idx]);

            if x + 1 < width {
                let right = ProvinceId(grid[(y * width + (x + 1)) as usize]);
                if right != id {
                    if let Some(pid) = assign_pair_id(&mut pair_to_id, &mut id_to_pair, id, right) {
                        place_horizontal_pair(&mut data, width, height, x, y, pid);
                    }
                }
            }
            if y + 1 < height {
                let down = ProvinceId(grid[((y + 1) * width + x) as usize]);
                if down != id {
                    if let Some(pid) = assign_pair_id(&mut pair_to_id, &mut id_to_pair, id, down) {
                        place_vertical_pair(&mut data, width, height, x, y, pid);
                    }
                }
            }
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
    dilate_border_index_by_thickness(index, |a, b| {
        styles
            .get(&norm_pair(a, b))
            .map(|style| style.thickness)
            .unwrap_or(1.0)
    });
}

fn registry_border_thickness(registry: &ProvinceRegistry, a: ProvinceId, b: ProvinceId) -> f32 {
    if let Some(style) = registry.get_border_pair_style(a, b) {
        return style.thickness.max(1.0);
    }
    registry
        .get_border_type(a, b)
        .and_then(|type_id| {
            registry
                .get_border_type_config(type_id)
                .map(|config| config.thickness)
        })
        .unwrap_or(1.0)
        .max(1.0)
}

/// Expand border pixels using the current registry border-pair or border-type thickness settings.
pub fn dilate_border_index_with_registry_styles(
    index: &mut ProvinceBorderIndex,
    registry: &ProvinceRegistry,
) {
    dilate_border_index_by_thickness(index, |a, b| registry_border_thickness(registry, a, b));
}

fn dilate_border_index_by_thickness<F>(index: &mut ProvinceBorderIndex, mut thickness_for_pair: F)
where
    F: FnMut(ProvinceId, ProvinceId) -> f32,
{
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
            let radius = ((thickness_for_pair(pair.0, pair.1).max(1.0) - 1.0) * 0.5).ceil() as i32;
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
    if registry.geometry_kind() == ProvinceGeometryKind::Polygon {
        // Polygon topology is already represented by exact floating-point
        // segments. Keep this raster-only index empty instead of sampling the
        // authored map into a dense cell grid.
        let mut id_to_pair = vec![(ProvinceId(0), ProvinceId(0))];
        let mut pair_to_id = HashMap::new();
        if let Some(segments) = registry.polygon_border_segments() {
            for segment in segments {
                let _ = assign_pair_id(
                    &mut pair_to_id,
                    &mut id_to_pair,
                    segment.province_a,
                    segment.province_b,
                );
            }
        }
        return ProvinceBorderIndex {
            data: Vec::new(),
            width,
            height,
            id_to_pair,
            pair_to_id,
        };
    }
    let mut ids = Vec::with_capacity((width as usize).saturating_mul(height as usize));
    for y in 0..height {
        for x in 0..width {
            ids.push(registry.get_at(x, y));
        }
    }
    build_border_index(&ids, width, height)
}

/// Build a registry border index with border-pair and border-type thickness already baked into pixels.
pub fn build_styled_border_index_from_registry(registry: &ProvinceRegistry) -> ProvinceBorderIndex {
    let mut index = build_border_index_from_registry(registry);
    dilate_border_index_with_registry_styles(&mut index, registry);
    index
}
