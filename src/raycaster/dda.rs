//! This file owns `Raycaster2D`, the grid-backed DDA engine that stores wall cells and answers render ray queries.
//! It stores map dimensions, row-major cells, wall alpha overrides, wall features, and synchronized door feature state.
//! Core casting methods produce single hits, layered transparent hits, fan casts, and packed ray buffers from one model.
//! Render visibility helpers reuse the same blocking rules so lighting and screen picking stay aligned with rendering.
//! Door synchronization translates `DoorManager` openness into wall features without replacing underlying tile identity.
//! Sprite and floor helpers project billboards and sample floor rows with the same camera conventions as wall casting.
//! Safe setters ignore invalid writes, and out-of-range reads fall back predictably for tools and runtime probes.
//! Pick attributes also live with the grid here so wall, floor, and ceiling metadata follow the owning cell surface.
//! Screen picking and scene builders read this owner when they need tile semantics beyond the raw numeric cell value.
//! Open this file when marching semantics or map-owned ray data change; debug views and scene building live in siblings.

use super::contract::{OutOfBoundsPolicy, RaycastParams, RaycasterError, RaycasterLimits};
use super::doors::DoorManager;
use super::ray_hit::RayHit;
use super::sprite_projection::SpriteProjection;
use super::tile_picker::PickAttrSurface;
use super::wall_feature::WallFeature;
use crate::log_msg;
use crate::runtime::log_messages::RC01;
use std::collections::{HashMap, HashSet};
/// 2D grid map and DDA ray-stepping engine used by the raycaster subsystem.
#[derive(Debug, Clone)]
pub struct Raycaster2D {
    /// Map width in tiles.
    width: u32,
    /// Map height in tiles.
    height: u32,
    /// Flat row-major tile values; 0 = open, non-zero = wall cell type.
    cells: Vec<u32>,
    /// Policy used by checked cell queries when callers probe outside authored bounds.
    oob_policy: OutOfBoundsPolicy,
    /// Per-tile-type alpha overrides for transparent walls; default 1.0 (opaque).
    wall_alphas: HashMap<u8, f32>,
    /// Per-cell wall feature descriptors used by rendering, picking, and ray probes.
    wall_features: HashMap<(u32, u32), WallFeature>,
    /// Per-cell pick metadata keyed by `(x, y, surface)`.
    pick_attrs: HashMap<(u32, u32, PickAttrSurface), HashMap<String, String>>,
    /// Door cells last synchronized from a `DoorManager`.
    synced_door_cells: HashSet<(u32, u32)>,
}
/// Core DDA grid map implementation with ray-casting, render visibility, and projection methods.
impl Raycaster2D {
    /// Create a new empty grid of `width × height` open cells.
    pub fn new(width: u32, height: u32) -> Self {
        log_msg!(debug, RC01, "{}x{}", width, height);
        let limits = RaycasterLimits::default();
        let (width, height, cell_count) = limits.sanitize_grid_dimensions(width, height);
        Self {
            width,
            height,
            cells: vec![0; cell_count],
            oob_policy: limits.default_oob_policy,
            wall_alphas: HashMap::new(),
            wall_features: HashMap::new(),
            pick_attrs: HashMap::new(),
            synced_door_cells: HashSet::new(),
        }
    }
    /// Create a validated empty grid using the shared raycaster limits.
    pub fn try_new(width: u32, height: u32) -> Result<Self, RaycasterError> {
        Self::try_new_with_limits(width, height, RaycasterLimits::default())
    }
    /// Create a validated empty grid using explicit raycaster limits.
    pub fn try_new_with_limits(
        width: u32,
        height: u32,
        limits: RaycasterLimits,
    ) -> Result<Self, RaycasterError> {
        let cell_count = limits.validate_grid_dimensions(width, height)?;
        Ok(Self {
            width,
            height,
            cells: vec![0; cell_count],
            oob_policy: limits.default_oob_policy,
            wall_alphas: HashMap::new(),
            wall_features: HashMap::new(),
            pick_attrs: HashMap::new(),
            synced_door_cells: HashSet::new(),
        })
    }
    /// Set the value of cell `(x, y)`; silently ignores out-of-bounds coordinates.
    pub fn set_cell(&mut self, x: u32, y: u32, value: u32) {
        if x < self.width && y < self.height {
            self.cells[(y * self.width + x) as usize] = value;
        }
    }
    /// Return the value of cell `(x, y)`, or 0 for out-of-bounds coordinates.
    pub fn get_cell(&self, x: u32, y: u32) -> u32 {
        if x < self.width && y < self.height {
            self.cells[(y * self.width + x) as usize]
        } else {
            0
        }
    }
    /// Return the configured out-of-bounds policy used by checked queries.
    pub fn out_of_bounds_policy(&self) -> OutOfBoundsPolicy {
        self.oob_policy
    }
    /// Set the policy used by checked out-of-bounds cell queries.
    pub fn set_out_of_bounds_policy(&mut self, policy: OutOfBoundsPolicy) {
        self.oob_policy = policy;
    }
    /// Return a checked cell value using the configured OOB policy.
    pub fn get_cell_checked(&self, x: i32, y: i32) -> Option<u32> {
        if x >= 0 && y >= 0 && x < self.width as i32 && y < self.height as i32 {
            return Some(self.cells[(y as u32 * self.width + x as u32) as usize]);
        }
        match self.oob_policy {
            OutOfBoundsPolicy::Open => Some(0),
            OutOfBoundsPolicy::Blocked => Some(1),
            OutOfBoundsPolicy::Stop => None,
        }
    }
    /// Replace the entire cell grid with `data`; no-op if length mismatches.
    pub fn set_cells(&mut self, data: Vec<u32>) {
        let _ = self.try_set_cells(data);
    }
    /// Replace the entire cell grid with `data`, rejecting wrong lengths explicitly.
    pub fn try_set_cells(&mut self, data: Vec<u32>) -> Result<(), RaycasterError> {
        let expected = (self.width as usize).saturating_mul(self.height as usize);
        if data.len() != expected {
            return Err(RaycasterError::DataLengthMismatch {
                context: "raycaster.set_cells",
                expected,
                actual: data.len(),
            });
        }
        self.cells = data;
        Ok(())
    }
    /// Return true when cell `(x, y)` has a non-zero value (solid wall).
    pub fn is_blocked(&self, x: u32, y: u32) -> bool {
        if self.get_cell(x, y) == 0 {
            return false;
        }
        self.wall_features
            .get(&(x, y))
            .copied()
            .map(|feature| feature.blocks_ray_hit())
            .unwrap_or(true)
    }
    /// Return a checked blocked result using the configured OOB policy.
    pub fn is_blocked_checked(&self, x: i32, y: i32) -> Option<bool> {
        let cell = self.get_cell_checked(x, y)?;
        if cell == 0 {
            return Some(false);
        }
        if x < 0 || y < 0 || x >= self.width as i32 || y >= self.height as i32 {
            return Some(true);
        }
        Some(
            self.wall_features
                .get(&(x as u32, y as u32))
                .copied()
                .map(|feature| feature.blocks_ray_hit())
                .unwrap_or(true),
        )
    }
    /// Return true when cell `(x, y)` stops render visibility probes.
    pub fn blocks_render_visibility_at(&self, x: u32, y: u32) -> bool {
        let cell = self.get_cell(x, y);
        if cell == 0 {
            return false;
        }
        self.wall_features
            .get(&(x, y))
            .copied()
            .map(|feature| feature.blocks_render_visibility())
            .unwrap_or_else(|| self.get_wall_alpha(cell as u8) >= 1.0)
    }
    /// Return true when cell `(x, y)` stops render light sampling.
    pub fn blocks_render_light_at(&self, x: u32, y: u32) -> bool {
        let cell = self.get_cell(x, y);
        if cell == 0 {
            return false;
        }
        self.wall_features
            .get(&(x, y))
            .copied()
            .map(|feature| feature.blocks_render_light())
            .unwrap_or_else(|| self.get_wall_alpha(cell as u8) >= 1.0)
    }
    /// Return the map width in tiles.
    pub fn width(&self) -> u32 {
        self.width
    }
    /// Return the map height in tiles.
    pub fn height(&self) -> u32 {
        self.height
    }
    /// Return a read-only slice of the raw cell grid.
    pub fn cells(&self) -> &[u32] {
        &self.cells
    }
    /// Attach a per-cell wall feature descriptor.
    pub fn set_wall_feature(&mut self, x: u32, y: u32, feature: WallFeature) {
        if x < self.width && y < self.height {
            self.wall_features.insert((x, y), feature);
        }
    }
    /// Remove any per-cell wall feature descriptor from `(x, y)`.
    pub fn clear_wall_feature(&mut self, x: u32, y: u32) {
        self.wall_features.remove(&(x, y));
    }
    /// Return the wall feature descriptor at `(x, y)`, if present.
    pub fn wall_feature(&self, x: u32, y: u32) -> Option<WallFeature> {
        self.wall_features.get(&(x, y)).copied()
    }

    /// Attach one string pick attribute to cell `(x, y)` and surface channel.
    pub fn set_pick_attr(
        &mut self,
        x: u32,
        y: u32,
        surface: PickAttrSurface,
        key: impl Into<String>,
        value: impl Into<String>,
    ) {
        if x >= self.width || y >= self.height {
            return;
        }
        self.pick_attrs
            .entry((x, y, surface))
            .or_default()
            .insert(key.into(), value.into());
    }

    /// Read one pick attribute from cell `(x, y)` and surface channel.
    pub fn get_pick_attr(
        &self,
        x: u32,
        y: u32,
        surface: PickAttrSurface,
        key: &str,
    ) -> Option<&str> {
        self.pick_attrs
            .get(&(x, y, surface))
            .and_then(|attrs| attrs.get(key))
            .map(String::as_str)
    }

    /// Clear one pick attribute or the whole surface-channel map for cell `(x, y)`.
    pub fn clear_pick_attr(&mut self, x: u32, y: u32, surface: PickAttrSurface, key: Option<&str>) {
        let Some(attrs) = self.pick_attrs.get_mut(&(x, y, surface)) else {
            return;
        };
        if let Some(key) = key {
            attrs.remove(key);
            if attrs.is_empty() {
                self.pick_attrs.remove(&(x, y, surface));
            }
        } else {
            self.pick_attrs.remove(&(x, y, surface));
        }
    }

    /// Return merged pick attributes for one surface, including shared `any` attrs.
    pub fn pick_attrs_at(
        &self,
        x: u32,
        y: u32,
        surface: PickAttrSurface,
    ) -> HashMap<String, String> {
        let mut attrs = self
            .pick_attrs
            .get(&(x, y, PickAttrSurface::Any))
            .cloned()
            .unwrap_or_default();
        if surface != PickAttrSurface::Any {
            if let Some(surface_attrs) = self.pick_attrs.get(&(x, y, surface)) {
                attrs.extend(surface_attrs.clone());
            }
        }
        attrs
    }
    /// Synchronize door wall-features from `doors`, leaving underlying cell values unchanged.
    ///
    /// Door cells are expected to keep their non-zero tile identity in the base map while the
    /// door manager controls openness over time. Cells that were previously synchronized but are
    /// no longer present in `doors` have their door feature removed.
    pub fn sync_doors(&mut self, doors: &DoorManager, alpha: f32) {
        let _ = self.try_sync_doors(doors, alpha);
    }
    /// Synchronize doors strictly, rejecting out-of-bounds or empty-tile definitions.
    pub fn try_sync_doors(
        &mut self,
        doors: &DoorManager,
        alpha: f32,
    ) -> Result<(), RaycasterError> {
        let mut next_cells = HashSet::new();
        let alpha = alpha.clamp(0.0, 1.0);

        for door in doors.doors() {
            let pos = (door.x, door.y);
            next_cells.insert(pos);
            if door.x >= self.width || door.y >= self.height {
                return Err(RaycasterError::DoorOutOfBounds {
                    x: door.x,
                    y: door.y,
                    width: self.width,
                    height: self.height,
                });
            }
            if self.get_cell(door.x, door.y) == 0 {
                return Err(RaycasterError::DoorOnEmptyCell {
                    x: door.x,
                    y: door.y,
                });
            }
            self.set_wall_feature(
                door.x,
                door.y,
                WallFeature::door(door.direction, door.open_amount, alpha),
            );
        }

        for pos in self.synced_door_cells.drain() {
            if next_cells.contains(&pos) {
                continue;
            }
            if matches!(self.wall_features.get(&pos), Some(feature) if feature.kind.is_door()) {
                self.wall_features.remove(&pos);
            }
        }

        self.synced_door_cells = next_cells;
        Ok(())
    }
    /// Remove every door feature previously synchronized from a `DoorManager`.
    pub fn clear_synced_doors(&mut self) {
        for pos in self.synced_door_cells.drain() {
            if matches!(self.wall_features.get(&pos), Some(feature) if feature.kind.is_door()) {
                self.wall_features.remove(&pos);
            }
        }
    }
    /// Set the alpha for walls of `tile_type`; clamped to 0.0..1.0.
    pub fn set_wall_alpha(&mut self, tile_type: u8, alpha: f32) {
        self.wall_alphas.insert(tile_type, alpha.clamp(0.0, 1.0));
    }
    /// Return the wall alpha for `tile_type`; defaults to 1.0 if not set.
    pub fn get_wall_alpha(&self, tile_type: u8) -> f32 {
        self.wall_alphas.get(&tile_type).copied().unwrap_or(1.0)
    }
    #[inline]
    fn cell_alpha(&self, x: u32, y: u32, cell: u32) -> f32 {
        self.wall_feature(x, y)
            .map(|feature| feature.alpha())
            .unwrap_or_else(|| self.wall_alphas.get(&(cell as u8)).copied().unwrap_or(1.0))
    }
    fn cast_ray_impl(&self, ox: f32, oy: f32, angle: f32, max_dist: f32) -> Option<RayHit> {
        let dir_x = angle.cos();
        let dir_y = angle.sin();
        let mut map_x = ox.floor() as i32;
        let mut map_y = oy.floor() as i32;
        let delta_dist_x = if dir_x.abs() < 1e-10 {
            f32::MAX
        } else {
            (1.0 / dir_x).abs()
        };
        let delta_dist_y = if dir_y.abs() < 1e-10 {
            f32::MAX
        } else {
            (1.0 / dir_y).abs()
        };
        let (step_x, mut side_dist_x) = if dir_x < 0.0 {
            (-1, (ox - map_x as f32) * delta_dist_x)
        } else {
            (1, (map_x as f32 + 1.0 - ox) * delta_dist_x)
        };
        let (step_y, mut side_dist_y) = if dir_y < 0.0 {
            (-1, (oy - map_y as f32) * delta_dist_y)
        } else {
            (1, (map_y as f32 + 1.0 - oy) * delta_dist_y)
        };
        let mut side: u8;
        loop {
            if side_dist_x < side_dist_y {
                side_dist_x += delta_dist_x;
                map_x += step_x;
                side = 0;
            } else {
                side_dist_y += delta_dist_y;
                map_y += step_y;
                side = 1;
            }
            let perp_dist = if side == 0 {
                side_dist_x - delta_dist_x
            } else {
                side_dist_y - delta_dist_y
            };
            if perp_dist > max_dist {
                return None;
            }
            if map_x < 0 || map_y < 0 || map_x >= self.width as i32 || map_y >= self.height as i32 {
                return None;
            }
            let cell = self.cells[(map_y as u32 * self.width + map_x as u32) as usize];
            if cell > 0 {
                if self
                    .wall_feature(map_x as u32, map_y as u32)
                    .is_some_and(|feature| !feature.blocks_ray_hit())
                {
                    continue;
                }
                let hit_x = ox + dir_x * perp_dist;
                let hit_y = oy + dir_y * perp_dist;
                let tex_u = if side == 0 {
                    (hit_y - hit_y.floor()).abs()
                } else {
                    (hit_x - hit_x.floor()).abs()
                };
                let raw_distance = perp_dist;
                let alpha = self.cell_alpha(map_x as u32, map_y as u32, cell);
                return Some(RayHit {
                    distance: perp_dist,
                    raw_distance,
                    cell_value: cell,
                    alpha,
                    side,
                    tex_u,
                    hit_x,
                    hit_y,
                    hit: true,
                });
            }
        }
    }
    /// Cast a single DDA ray from `(ox, oy)` in direction `angle`; return the first solid hit or `None`.
    pub fn cast_ray(&self, ox: f32, oy: f32, angle: f32, max_dist: f32) -> Option<RayHit> {
        let params = RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: None,
            count: None,
            max_distance: max_dist,
            max_hits: None,
        };
        if params.validate(&RaycasterLimits::default()).is_err() {
            return None;
        }
        self.cast_ray_impl(ox, oy, angle, max_dist)
    }
    /// Cast a validated DDA ray and return either the first hit or `None` on range exhaustion.
    pub fn try_cast_ray(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        max_dist: f32,
    ) -> Result<Option<RayHit>, RaycasterError> {
        RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: None,
            count: None,
            max_distance: max_dist,
            max_hits: None,
        }
        .validate(&RaycasterLimits::default())?;
        Ok(self.cast_ray_impl(ox, oy, angle, max_dist))
    }
    fn cast_ray_multi_impl(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        max_dist: f32,
        max_hits: u32,
    ) -> Vec<RayHit> {
        let cap = (max_hits as usize).min(8);
        let mut hits: Vec<RayHit> = Vec::with_capacity(cap);
        let dir_x = angle.cos();
        let dir_y = angle.sin();
        let mut map_x = ox.floor() as i32;
        let mut map_y = oy.floor() as i32;
        let delta_dist_x = if dir_x.abs() < 1e-10 {
            f32::MAX
        } else {
            (1.0 / dir_x).abs()
        };
        let delta_dist_y = if dir_y.abs() < 1e-10 {
            f32::MAX
        } else {
            (1.0 / dir_y).abs()
        };
        let (step_x, mut side_dist_x) = if dir_x < 0.0 {
            (-1, (ox - map_x as f32) * delta_dist_x)
        } else {
            (1, (map_x as f32 + 1.0 - ox) * delta_dist_x)
        };
        let (step_y, mut side_dist_y) = if dir_y < 0.0 {
            (-1, (oy - map_y as f32) * delta_dist_y)
        } else {
            (1, (map_y as f32 + 1.0 - oy) * delta_dist_y)
        };
        loop {
            if side_dist_x < side_dist_y {
                side_dist_x += delta_dist_x;
                map_x += step_x;
                let perp_dist = side_dist_x - delta_dist_x;
                if perp_dist > max_dist {
                    break;
                }
                if map_x < 0
                    || map_x >= self.width as i32
                    || map_y < 0
                    || map_y >= self.height as i32
                {
                    break;
                }
                let cell = self.cells[(map_y as u32 * self.width + map_x as u32) as usize];
                if cell > 0 {
                    if self
                        .wall_feature(map_x as u32, map_y as u32)
                        .is_some_and(|feature| !feature.blocks_ray_hit())
                    {
                        continue;
                    }
                    let alpha = self.cell_alpha(map_x as u32, map_y as u32, cell);
                    let hit_x = ox + dir_x * perp_dist;
                    let hit_y = oy + dir_y * perp_dist;
                    let tex_u = (hit_y - hit_y.floor()).abs();
                    hits.push(RayHit {
                        distance: perp_dist,
                        raw_distance: perp_dist,
                        cell_value: cell,
                        alpha,
                        side: 0,
                        tex_u,
                        hit_x,
                        hit_y,
                        hit: true,
                    });
                    if alpha >= 1.0 || hits.len() >= cap {
                        break;
                    }
                }
            } else {
                side_dist_y += delta_dist_y;
                map_y += step_y;
                let perp_dist = side_dist_y - delta_dist_y;
                if perp_dist > max_dist {
                    break;
                }
                if map_y < 0
                    || map_y >= self.height as i32
                    || map_x < 0
                    || map_x >= self.width as i32
                {
                    break;
                }
                let cell = self.cells[(map_y as u32 * self.width + map_x as u32) as usize];
                if cell > 0 {
                    if self
                        .wall_feature(map_x as u32, map_y as u32)
                        .is_some_and(|feature| !feature.blocks_ray_hit())
                    {
                        continue;
                    }
                    let alpha = self.cell_alpha(map_x as u32, map_y as u32, cell);
                    let hit_x = ox + dir_x * perp_dist;
                    let hit_y = oy + dir_y * perp_dist;
                    let tex_u = (hit_x - hit_x.floor()).abs();
                    hits.push(RayHit {
                        distance: perp_dist,
                        raw_distance: perp_dist,
                        cell_value: cell,
                        alpha,
                        side: 1,
                        tex_u,
                        hit_x,
                        hit_y,
                        hit: true,
                    });
                    if alpha >= 1.0 || hits.len() >= cap {
                        break;
                    }
                }
            }
        }
        hits
    }
    /// Cast a ray and collect up to `max_hits` (≤ 8) consecutive hits, stopping at the first opaque wall.
    pub fn cast_ray_multi(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        max_dist: f32,
        max_hits: u32,
    ) -> Vec<RayHit> {
        let limits = RaycasterLimits::default();
        let max_hits = max_hits.clamp(1, limits.max_multi_hits);
        let params = RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: None,
            count: None,
            max_distance: max_dist,
            max_hits: Some(max_hits),
        };
        if params.validate(&limits).is_err() {
            return Vec::new();
        }
        self.cast_ray_multi_impl(ox, oy, angle, max_dist, max_hits)
    }
    /// Cast a validated layered ray and return every transparent-wall hit until an opaque stop.
    pub fn try_cast_ray_multi(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        max_dist: f32,
        max_hits: u32,
    ) -> Result<Vec<RayHit>, RaycasterError> {
        RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: None,
            count: None,
            max_distance: max_dist,
            max_hits: Some(max_hits),
        }
        .validate(&RaycasterLimits::default())?;
        Ok(self.cast_ray_multi_impl(ox, oy, angle, max_dist, max_hits))
    }
    /// Cast `count` rays spread across `fov` from `(ox, oy)`; return one `RayHit` per ray with fish-eye correction.
    pub fn cast_rays(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        fov: f32,
        count: u32,
        max_dist: f32,
    ) -> Vec<RayHit> {
        let limits = RaycasterLimits::default();
        let count = count.min(limits.max_rays);
        let params = RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: Some(fov),
            count: Some(count),
            max_distance: max_dist,
            max_hits: None,
        };
        if count == 0 || params.validate(&limits).is_err() {
            return Vec::new();
        }
        let mut results = Vec::with_capacity(count as usize);
        let half_fov = fov / 2.0;
        for i in 0..count {
            let ray_angle = if count > 1 {
                angle - half_fov + fov * (i as f32) / (count - 1) as f32
            } else {
                angle
            };
            let angle_diff = ray_angle - angle;
            match self.cast_ray_impl(ox, oy, ray_angle, max_dist) {
                Some(mut hit) => {
                    hit.raw_distance = hit.distance;
                    hit.distance *= angle_diff.cos();
                    results.push(hit);
                }
                None => {
                    results.push(RayHit {
                        distance: max_dist,
                        raw_distance: max_dist,
                        cell_value: 0,
                        alpha: 1.0,
                        side: 0,
                        tex_u: 0.0,
                        hit_x: ox + ray_angle.cos() * max_dist,
                        hit_y: oy + ray_angle.sin() * max_dist,
                        hit: false,
                    });
                }
            }
        }
        results
    }
    /// Cast a validated ray fan and return one corrected hit per ray.
    pub fn try_cast_rays(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        fov: f32,
        count: u32,
        max_dist: f32,
    ) -> Result<Vec<RayHit>, RaycasterError> {
        RaycastParams {
            origin_x: ox,
            origin_y: oy,
            angle,
            fov: Some(fov),
            count: Some(count),
            max_distance: max_dist,
            max_hits: None,
        }
        .validate(&RaycasterLimits::default())?;
        Ok(self.cast_rays(ox, oy, angle, fov, count, max_dist))
    }
    /// Cast `count` rays and pack each hit as 5 floats `[dist, cell, side, tex_u, hit]`.
    pub fn cast_rays_flat(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        fov: f32,
        count: u32,
        max_dist: f32,
    ) -> Vec<f32> {
        let hits = self.cast_rays(ox, oy, angle, fov, count, max_dist);
        let mut flat = Vec::with_capacity(hits.len() * 5);
        for h in &hits {
            flat.push(h.distance);
            flat.push(h.cell_value as f32);
            flat.push(h.side as f32);
            flat.push(h.tex_u);
            flat.push(if h.hit { 1.0 } else { 0.0 });
        }
        flat
    }
    /// Cast a validated ray fan and flatten the results into `[dist, cell, side, tex_u, hit]`.
    pub fn try_cast_rays_flat(
        &self,
        ox: f32,
        oy: f32,
        angle: f32,
        fov: f32,
        count: u32,
        max_dist: f32,
    ) -> Result<Vec<f32>, RaycasterError> {
        self.try_cast_rays(ox, oy, angle, fov, count, max_dist)?;
        Ok(self.cast_rays_flat(ox, oy, angle, fov, count, max_dist))
    }
    /// Project world sprite at `(sx, sy)` onto the screen given player position and orientation; return a `SpriteProjection`.
    #[allow(clippy::too_many_arguments)]
    pub fn project_sprite(
        &self,
        sx: f32,
        sy: f32,
        px: f32,
        py: f32,
        pa: f32,
        fov: f32,
        screen_w: f32,
    ) -> SpriteProjection {
        let dx = sx - px;
        let dy = sy - py;
        let cos_a = pa.cos();
        let sin_a = pa.sin();
        let transform_x = dx * cos_a + dy * sin_a;
        let transform_y = -dx * sin_a + dy * cos_a;
        if transform_y <= 0.0 {
            return SpriteProjection {
                screen_x: 0.0,
                scale: 0.0,
                distance: (dx * dx + dy * dy).sqrt(),
                visible: false,
            };
        }
        let half_fov_tan = (fov / 2.0).tan();
        let screen_x = (screen_w / 2.0) * (1.0 + transform_x / (transform_y * half_fov_tan));
        let scale = 1.0 / transform_y;
        SpriteProjection {
            screen_x,
            scale,
            distance: transform_y,
            visible: true,
        }
    }
    #[allow(clippy::too_many_arguments)]
    fn cast_floor_row_impl(
        &self,
        cam_x: f32,
        cam_y: f32,
        dir_x: f32,
        dir_y: f32,
        plane_x: f32,
        plane_y: f32,
        row: i32,
        screen_width: i32,
        screen_height: i32,
    ) -> Vec<(f32, f32)> {
        let w = screen_width;
        let h = screen_height;
        let half_h = h / 2;
        let p = row - half_h;
        if p == 0 {
            return vec![(0.0, 0.0); w as usize];
        }
        let row_distance = 0.5 * h as f32 / p.abs() as f32;
        let floor_step_x = row_distance * (dir_x + plane_x - (dir_x - plane_x)) / w as f32;
        let floor_step_y = row_distance * (dir_y + plane_y - (dir_y - plane_y)) / w as f32;
        let mut floor_x = cam_x + row_distance * (dir_x - plane_x);
        let mut floor_y = cam_y + row_distance * (dir_y - plane_y);
        let mut result = Vec::with_capacity(w as usize);
        for _ in 0..w {
            let tx = floor_x - floor_x.floor();
            let ty = floor_y - floor_y.floor();
            floor_x += floor_step_x;
            floor_y += floor_step_y;
            result.push((tx, ty));
        }
        log::debug!(
            "raycaster: cast_floor_row row={row} -> {} samples",
            result.len()
        );
        result
    }
    /// Return per-pixel `(tex_u, tex_v)` world UV coordinates for every pixel in floor row `row`.
    #[allow(clippy::too_many_arguments)]
    pub fn cast_floor_row(
        &self,
        cam_x: f32,
        cam_y: f32,
        dir_x: f32,
        dir_y: f32,
        plane_x: f32,
        plane_y: f32,
        row: i32,
    ) -> Vec<(f32, f32)> {
        let w = self.width as i32;
        let h = self.height as i32;
        let half_h = h / 2;
        let p = row - half_h;
        if p == 0 {
            return vec![(0.0, 0.0); w as usize];
        }
        let row_distance = 0.5 * h as f32 / p.abs() as f32;
        let floor_step_x = row_distance * (dir_x + plane_x - (dir_x - plane_x)) / w as f32;
        let floor_step_y = row_distance * (dir_y + plane_y - (dir_y - plane_y)) / w as f32;
        let mut floor_x = cam_x + row_distance * (dir_x - plane_x);
        let mut floor_y = cam_y + row_distance * (dir_y - plane_y);
        let mut result = Vec::with_capacity(w as usize);
        for _ in 0..w {
            let tx = floor_x - floor_x.floor();
            let ty = floor_y - floor_y.floor();
            floor_x += floor_step_x;
            floor_y += floor_step_y;
            result.push((tx, ty));
        }
        log::debug!(
            "raycaster: cast_floor_row row={row} → {} samples",
            result.len()
        );
        result
    }
    /// Return per-pixel floor-row UV coordinates using explicit viewport dimensions.
    #[allow(clippy::too_many_arguments)]
    pub fn cast_floor_row_with_viewport(
        &self,
        cam_x: f32,
        cam_y: f32,
        dir_x: f32,
        dir_y: f32,
        plane_x: f32,
        plane_y: f32,
        row: i32,
        screen_width: u32,
        screen_height: u32,
    ) -> Vec<(f32, f32)> {
        if RaycasterLimits::default()
            .validate_screen_dimensions(screen_width as f32, screen_height as f32)
            .is_err()
        {
            return Vec::new();
        }
        self.cast_floor_row_impl(
            cam_x,
            cam_y,
            dir_x,
            dir_y,
            plane_x,
            plane_y,
            row,
            screen_width as i32,
            screen_height as i32,
        )
    }
    /// Return per-pixel floor-row UV coordinates using validated viewport dimensions.
    #[allow(clippy::too_many_arguments)]
    pub fn try_cast_floor_row_with_viewport(
        &self,
        cam_x: f32,
        cam_y: f32,
        dir_x: f32,
        dir_y: f32,
        plane_x: f32,
        plane_y: f32,
        row: i32,
        screen_width: u32,
        screen_height: u32,
    ) -> Result<Vec<(f32, f32)>, RaycasterError> {
        let limits = RaycasterLimits::default();
        limits.validate_finite("cam_x", cam_x)?;
        limits.validate_finite("cam_y", cam_y)?;
        limits.validate_finite("dir_x", dir_x)?;
        limits.validate_finite("dir_y", dir_y)?;
        limits.validate_finite("plane_x", plane_x)?;
        limits.validate_finite("plane_y", plane_y)?;
        limits.validate_screen_dimensions(screen_width as f32, screen_height as f32)?;
        Ok(self.cast_floor_row_impl(
            cam_x,
            cam_y,
            dir_x,
            dir_y,
            plane_x,
            plane_y,
            row,
            screen_width as i32,
            screen_height as i32,
        ))
    }
}
