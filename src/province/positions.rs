//! Auto-position calculation for province capitals, labels, and object slots.
//!
//! Provides algorithms to find good interior positions within provinces for
//! placing capitals, text labels, and game objects.

use crate::math::Vec2;

use super::core::ProvinceMap;

/// Find a good interior position for a province capital.
///
/// Uses an approximate distance-from-edge approach: samples points on a grid
/// within the province bounding box, keeps only those inside the province (via
/// `pixel_lookup`), and picks the one farthest from any edge pixel.
/// Falls back to the province centroid if no better candidate is found.
pub fn calculate_capital(map: &ProvinceMap, province_id: u32) -> Vec2 {
    let province = match map.get_province(province_id) {
        Some(p) => p,
        None => return Vec2::ZERO,
    };

    let bb = &province.bounding_box;
    let cx = province.centroid.x as u32;
    let cy = province.centroid.y as u32;

    // Check if the centroid is inside the province
    if map.get_province_at(cx, cy) == Some(province_id) {
        // For convex shapes the centroid is good enough; for concave shapes
        // we try to find a better interior point.
        let centroid_dist = min_edge_distance(map, province_id, cx, cy);
        let mut best_pos = province.centroid;
        let mut best_dist = centroid_dist;

        // Sample a grid within the bounding box
        let step = ((bb.width.max(bb.height)) / 20.0).max(1.0) as u32;
        let x0 = bb.x as u32;
        let y0 = bb.y as u32;
        let x1 = (bb.x + bb.width) as u32;
        let y1 = (bb.y + bb.height) as u32;

        let mut sy = y0;
        while sy <= y1 {
            let mut sx = x0;
            while sx <= x1 {
                if map.get_province_at(sx, sy) == Some(province_id) {
                    let d = min_edge_distance(map, province_id, sx, sy);
                    if d > best_dist {
                        best_dist = d;
                        best_pos = Vec2::new(sx as f32, sy as f32);
                    }
                }
                sx += step;
            }
            sy += step;
        }

        return best_pos;
    }

    // Centroid is outside the province (concave shape) — full grid scan
    let step = ((bb.width.max(bb.height)) / 20.0).max(1.0) as u32;
    let x0 = bb.x as u32;
    let y0 = bb.y as u32;
    let x1 = (bb.x + bb.width) as u32;
    let y1 = (bb.y + bb.height) as u32;

    let mut best_pos = province.centroid;
    let mut best_dist: u32 = 0;

    let mut sy = y0;
    while sy <= y1 {
        let mut sx = x0;
        while sx <= x1 {
            if map.get_province_at(sx, sy) == Some(province_id) {
                let d = min_edge_distance(map, province_id, sx, sy);
                if d > best_dist {
                    best_dist = d;
                    best_pos = Vec2::new(sx as f32, sy as f32);
                }
            }
            sx += step;
        }
        sy += step;
    }

    best_pos
}

/// Calculate position and angle for a text label within a province.
///
/// Uses PCA on province pixel coordinates to find the main axis.
/// Returns `(position, angle_radians)` where position is the centroid (or
/// capital) and angle is the orientation of the principal component.
pub fn calculate_label_position(map: &ProvinceMap, province_id: u32) -> (Vec2, f32) {
    let province = match map.get_province(province_id) {
        Some(p) => p,
        None => return (Vec2::ZERO, 0.0),
    };

    let bb = &province.bounding_box;
    let cx = province.centroid.x;
    let cy = province.centroid.y;

    // Compute covariance matrix from province pixels
    let mut cov_xx: f64 = 0.0;
    let mut cov_xy: f64 = 0.0;
    let mut cov_yy: f64 = 0.0;
    let mut count: u64 = 0;

    let x0 = bb.x as u32;
    let y0 = bb.y as u32;
    let x1 = (bb.x + bb.width) as u32;
    let y1 = (bb.y + bb.height) as u32;

    // Sample every few pixels for large provinces to keep it fast
    let step = if province.area > 10000 { 3 } else { 1 };

    let mut py = y0;
    while py <= y1 {
        let mut px = x0;
        while px <= x1 {
            if map.get_province_at(px, py) == Some(province_id) {
                let dx = px as f64 - cx as f64;
                let dy = py as f64 - cy as f64;
                cov_xx += dx * dx;
                cov_xy += dx * dy;
                cov_yy += dy * dy;
                count += 1;
            }
            px += step;
        }
        py += step;
    }

    if count == 0 {
        return (province.centroid, 0.0);
    }

    let n = count as f64;
    cov_xx /= n;
    cov_xy /= n;
    cov_yy /= n;

    // Principal component via eigenvalue decomposition of 2×2 matrix
    let angle = (2.0 * cov_xy).atan2(cov_xx - cov_yy) / 2.0;

    (province.centroid, angle as f32)
}

/// Generate evenly-spaced positions inside a province for placing game objects.
///
/// Divides the bounding box into a grid, filters points that are inside the
/// province, and selects `count` well-spaced positions using a simple
/// deterministic strategy seeded by `seed`.
pub fn calculate_slots(
    map: &ProvinceMap,
    province_id: u32,
    count: usize,
    seed: u64,
) -> Vec<Vec2> {
    if count == 0 {
        return Vec::new();
    }

    let province = match map.get_province(province_id) {
        Some(p) => p,
        None => return Vec::new(),
    };

    let bb = &province.bounding_box;
    let x0 = bb.x as u32;
    let y0 = bb.y as u32;
    let x1 = (bb.x + bb.width) as u32;
    let y1 = (bb.y + bb.height) as u32;

    // Collect candidate points inside the province
    let step = ((bb.width.max(bb.height)) / 30.0).max(1.0) as u32;
    let mut candidates: Vec<Vec2> = Vec::new();

    let mut py = y0;
    while py <= y1 {
        let mut px = x0;
        while px <= x1 {
            if map.get_province_at(px, py) == Some(province_id) {
                candidates.push(Vec2::new(px as f32, py as f32));
            }
            px += step;
        }
        py += step;
    }

    if candidates.is_empty() {
        return vec![province.centroid];
    }

    if candidates.len() <= count {
        return candidates;
    }

    // Deterministic shuffle using seed, then pick well-spaced points
    let mut rng = SimpleRng(seed);
    for i in (1..candidates.len()).rev() {
        let j = (rng.next() as usize) % (i + 1);
        candidates.swap(i, j);
    }

    // Greedy farthest-point sampling
    let mut selected = vec![candidates[0]];
    let mut used = vec![false; candidates.len()];
    used[0] = true;

    while selected.len() < count {
        let mut best_idx = 0;
        let mut best_min_dist: f32 = -1.0;

        for (i, candidate) in candidates.iter().enumerate() {
            if used[i] {
                continue;
            }
            let min_dist = selected
                .iter()
                .map(|s| {
                    let dx = candidate.x - s.x;
                    let dy = candidate.y - s.y;
                    dx * dx + dy * dy
                })
                .fold(f32::MAX, f32::min);

            if min_dist > best_min_dist {
                best_min_dist = min_dist;
                best_idx = i;
            }
        }

        used[best_idx] = true;
        selected.push(candidates[best_idx]);
    }

    selected
}

/// Compute and set `positions[0]` (primary position) for all provinces.
pub fn calculate_all_positions(map: &mut ProvinceMap) {
    let ids = map.province_ids();
    let primaries: Vec<(u32, Vec2)> = ids
        .iter()
        .map(|&id| (id, calculate_capital(map, id)))
        .collect();

    for (id, pos) in primaries {
        if let Some(p) = map.get_province_mut(id) {
            if p.positions.is_empty() {
                p.positions.push(pos);
            } else {
                p.positions[0] = pos;
            }
        }
    }

    log::info!("Calculated primary positions for {} provinces", ids.len());
}

/// Compute the minimum distance from `(px, py)` to a non-province edge pixel.
///
/// Checks cardinal neighbours in expanding layers. Returns the layer count at
/// which a different province (or map edge) is first encountered.
fn min_edge_distance(map: &ProvinceMap, province_id: u32, px: u32, py: u32) -> u32 {
    let max_radius = 50u32;
    for r in 1..=max_radius {
        // Check cardinal points at distance r
        let checks: [(i64, i64); 4] = [
            (px as i64 - r as i64, py as i64),
            (px as i64 + r as i64, py as i64),
            (px as i64, py as i64 - r as i64),
            (px as i64, py as i64 + r as i64),
        ];

        for (cx, cy) in checks {
            if cx < 0 || cy < 0 || cx >= map.width() as i64 || cy >= map.height() as i64 {
                return r;
            }
            if map.get_province_at(cx as u32, cy as u32) != Some(province_id) {
                return r;
            }
        }
    }
    max_radius
}

/// Minimal deterministic RNG for slot shuffling.
struct SimpleRng(u64);

impl SimpleRng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
}
