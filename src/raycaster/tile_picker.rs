//! This file owns screen-to-world picking for the raycaster, mapping a pixel back onto wall, floor, or ceiling space.
//! It defines `PickSurface`, `PickWallSection`, `ScreenPickParams`, `TilePicker`, and `PickResult` payloads.
//! `TilePicker` keeps camera pose, screen size, grid size, and tile scale for repeated first-person selection queries.
//! Helper math derives ray angle, corrected distance, horizon, projection depth, and plane intersections from the camera.
//! Wall picking reuses DDA stepping so hit ordering matches the same traversal semantics used for rendering and visibility.
//! Feature-aware logic distinguishes half-height walls, window bands, and door panels, returning the hit solid section.
//! Floor and ceiling picking projects the pixel onto horizontal planes and rejects cells hidden by closer walls or holes.
//! `Raycaster2D::pick_screen` resolves single-level maps, while `MultiLevelGrid::pick_screen` chooses the owning slice.
//! This file is the boundary between first-person UI input and render-space selection on grid or multilevel data.
//! Open this file when selection payloads or pick precedence change; scene building and ray hits live in siblings.

use super::contract::{RaycasterError, RaycasterLimits};
use super::dda::Raycaster2D;
use super::doors::DoorDirection;
use super::multilevel::MultiLevelGrid;
use super::wall_feature::{WallFeature, WallFeatureKind};
use std::collections::HashMap;

/// Surface class resolved by a screen pick.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PickSurface {
    /// Vertical wall face.
    Wall,
    /// Horizontal floor plane.
    Floor,
    /// Horizontal ceiling plane.
    Ceiling,
}

impl PickSurface {
    /// Return the Lua-facing stable string for this surface kind.
    pub fn as_str(self) -> &'static str {
        match self {
            PickSurface::Wall => "wall",
            PickSurface::Floor => "floor",
            PickSurface::Ceiling => "ceiling",
        }
    }
}

/// Solid wall section resolved inside a wall-feature cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PickWallSection {
    /// The main body of a half-height wall.
    Body,
    /// The solid band below a window opening.
    Lower,
    /// The solid band above a window opening.
    Upper,
    /// The centered sliding slab inside a door cell.
    Panel,
}

impl PickWallSection {
    /// Return the Lua-facing stable string for this feature section.
    pub fn as_str(self) -> &'static str {
        match self {
            PickWallSection::Body => "body",
            PickWallSection::Lower => "lower",
            PickWallSection::Upper => "upper",
            PickWallSection::Panel => "panel",
        }
    }
}

/// Camera and viewport parameters used for screen-to-world raycaster picking.
#[derive(Debug, Clone, Copy)]
pub struct ScreenPickParams {
    /// Player world X position.
    pub player_x: f32,
    /// Player world Y position.
    pub player_y: f32,
    /// Player facing angle in radians.
    pub player_angle: f32,
    /// Horizontal field of view in radians.
    pub fov: f32,
    /// Screen width in pixels.
    pub screen_width: f32,
    /// Screen height in pixels.
    pub screen_height: f32,
    /// Camera eye height as a fraction of cell height.
    pub camera_height: f32,
    /// Vertical shift applied to the horizon line in pixels.
    pub horizon_offset: f32,
    /// Maximum distance allowed for the pick result.
    pub max_distance: f32,
}

impl ScreenPickParams {
    /// Return the effective horizon Y coordinate used by the raycaster scene builder.
    pub fn horizon(self) -> f32 {
        self.screen_height * 0.5 - self.horizon_offset
    }

    /// Return the perspective projection distance for the current viewport and FOV.
    pub fn projection_distance(self) -> f32 {
        (self.screen_width * 0.5) / (self.fov * 0.5).tan()
    }

    /// Validate picking parameters against the shared raycaster limits.
    pub fn validate(self, limits: &RaycasterLimits) -> Result<(), RaycasterError> {
        limits.validate_finite("player_x", self.player_x)?;
        limits.validate_finite("player_y", self.player_y)?;
        limits.validate_finite("player_angle", self.player_angle)?;
        limits.validate_fov(self.fov)?;
        limits.validate_screen_dimensions(self.screen_width, self.screen_height)?;
        limits.validate_finite("camera_height", self.camera_height)?;
        limits.validate_finite("horizon_offset", self.horizon_offset)?;
        limits.validate_max_distance(self.max_distance)?;
        Ok(())
    }
}

/// Tile picker that maps screen coordinates to raycaster grid tiles.
#[derive(Debug, Clone)]
pub struct TilePicker {
    /// Grid width.
    pub grid_width: usize,
    /// Grid height.
    pub grid_height: usize,
    /// Tile size.
    pub tile_size: f32,
    /// Camera x.
    pub camera_x: f32,
    /// Camera y.
    pub camera_y: f32,
    /// Camera angle.
    pub camera_angle: f32,
    /// Screen width.
    pub screen_width: f32,
    /// Screen height.
    pub screen_height: f32,
    /// Flat row-major tile values used when `pick_tile()` delegates to the full raycaster picker.
    cells: Vec<u32>,
    /// Per-cell wall feature descriptors used when `pick_tile()` delegates to the full raycaster picker.
    wall_features: HashMap<(u32, u32), WallFeature>,
}

/// Result of a tile pick operation.
#[derive(Debug, Clone, Copy)]
pub struct PickResult {
    /// Multi-level slice index owning the picked surface.
    pub level_index: usize,
    /// Grid x.
    pub grid_x: usize,
    /// Grid y.
    pub grid_y: usize,
    /// Distance.
    pub distance: f32,
    /// Wall side for wall picks: 0 = vertical wall plane, 1 = horizontal wall plane.
    pub wall_side: Option<u8>,
    /// Resolved surface category at the picked pixel.
    pub surface: PickSurface,
    /// World-space hit X coordinate.
    pub hit_x: f32,
    /// World-space hit Y coordinate.
    pub hit_y: f32,
    /// Horizontal texture coordinate or floor/ceiling U coordinate.
    pub tex_u: f32,
    /// Vertical texture coordinate or floor/ceiling V coordinate.
    pub tex_v: f32,
    /// Local wall height from the picked tile floor in cell-height units when the pick hit a wall.
    pub wall_height: Option<f32>,
    /// Cell value occupying the picked tile.
    pub cell_value: u32,
    /// Ray angle used to resolve the pick.
    pub ray_angle: f32,
    /// Optional feature descriptor attached to the picked wall cell.
    pub wall_feature: Option<WallFeature>,
    /// Optional solid section inside the picked wall feature.
    pub wall_section: Option<PickWallSection>,
}

impl TilePicker {
    /// Create a `TilePicker` for a grid of the given dimensions and tile size in world units.
    pub fn new(grid_width: usize, grid_height: usize, tile_size: f32) -> Self {
        let size = RaycasterLimits::default()
            .validate_grid_dimensions_usize(grid_width, grid_height)
            .unwrap_or(0);
        Self {
            grid_width: if size == 0 { 0 } else { grid_width },
            grid_height: if size == 0 { 0 } else { grid_height },
            tile_size: if tile_size.is_finite() && tile_size > 0.0 {
                tile_size
            } else {
                1.0
            },
            camera_x: 0.0,
            camera_y: 0.0,
            camera_angle: 0.0,
            screen_width: 800.0,
            screen_height: 600.0,
            cells: vec![0; size],
            wall_features: HashMap::new(),
        }
    }

    /// Update camera position and angle.
    pub fn set_camera(&mut self, x: f32, y: f32, angle: f32) {
        self.camera_x = x;
        self.camera_y = y;
        self.camera_angle = angle;
    }

    /// Set the screen width and height dimensions.
    pub fn set_screen_size(&mut self, width: f32, height: f32) {
        self.screen_width = width;
        self.screen_height = height;
    }

    /// Set the value of one cell in the picker-owned grid; out-of-bounds writes are ignored.
    pub fn set_cell(&mut self, x: usize, y: usize, value: u32) {
        if x < self.grid_width && y < self.grid_height {
            self.cells[y * self.grid_width + x] = value;
        }
    }

    /// Replace the picker-owned grid; no-op on wrong length for backward compatibility.
    pub fn set_cells(&mut self, cells: Vec<u32>) {
        let _ = self.try_set_cells(cells);
    }

    /// Replace the picker-owned grid strictly, rejecting wrong lengths.
    pub fn try_set_cells(&mut self, cells: Vec<u32>) -> Result<(), RaycasterError> {
        let expected = self.grid_width.saturating_mul(self.grid_height);
        if cells.len() != expected {
            return Err(RaycasterError::DataLengthMismatch {
                context: "tile_picker.set_cells",
                expected,
                actual: cells.len(),
            });
        }
        self.cells = cells;
        Ok(())
    }

    /// Attach a wall feature override to one picker-owned cell.
    pub fn set_wall_feature(&mut self, x: u32, y: u32, feature: WallFeature) {
        if x < self.grid_width as u32 && y < self.grid_height as u32 {
            self.wall_features.insert((x, y), feature);
        }
    }

    /// Clear any wall feature override from one picker-owned cell.
    pub fn clear_wall_feature(&mut self, x: u32, y: u32) {
        self.wall_features.remove(&(x, y));
    }

    /// Pick a tile from screen coordinates using the same screen-volume picker as `Raycaster2D`.
    pub fn pick_tile(&self, screen_x: f32, screen_y: f32) -> Option<PickResult> {
        if self.grid_width == 0 || self.grid_height == 0 {
            return None;
        }
        let mut raycaster = Raycaster2D::try_new(self.grid_width as u32, self.grid_height as u32).ok()?;
        raycaster.try_set_cells(self.cells.clone()).ok()?;
        for (pos, feature) in &self.wall_features {
            raycaster.set_wall_feature(pos.0, pos.1, *feature);
        }
        let max_distance = ((self.grid_width.pow(2) + self.grid_height.pow(2)) as f32)
            .sqrt()
            .max(1.0)
            + 1.0;
        let params = ScreenPickParams {
            player_x: self.camera_x / self.tile_size,
            player_y: self.camera_y / self.tile_size,
            player_angle: self.camera_angle,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: self.screen_width,
            screen_height: self.screen_height,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance,
        };
        let mut pick = raycaster.pick_screen(&params, screen_x, screen_y)?;
        pick.distance *= self.tile_size;
        pick.hit_x *= self.tile_size;
        pick.hit_y *= self.tile_size;
        Some(pick)
    }

    /// Get tile coordinates directly from world position.
    pub fn world_to_tile(&self, world_x: f32, world_y: f32) -> Option<(usize, usize)> {
        let tx = (world_x / self.tile_size) as i32;
        let ty = (world_y / self.tile_size) as i32;
        if tx >= 0 && ty >= 0 && (tx as usize) < self.grid_width && (ty as usize) < self.grid_height
        {
            Some((tx as usize, ty as usize))
        } else {
            None
        }
    }
}

#[inline]
fn frac01(v: f32) -> f32 {
    v - v.floor()
}

#[inline]
fn pick_ray_angle(params: &ScreenPickParams, screen_x: f32) -> f32 {
    params.player_angle + (screen_x / params.screen_width - 0.5) * params.fov
}

#[inline]
fn corrected_pick_distance(ray_angle: f32, player_angle: f32, raw_distance: f32) -> f32 {
    raw_distance * (ray_angle - player_angle).cos().abs()
}

#[inline]
fn wall_height_at_screen_y(
    params: &ScreenPickParams,
    screen_y: f32,
    camera_world_z: f32,
    floor_world_z: f32,
    corrected_distance: f32,
) -> f32 {
    let world_z = camera_world_z
        - (screen_y - params.horizon()) * corrected_distance
            / params.projection_distance().max(1e-4);
    world_z - floor_world_z
}

#[inline]
fn pick_world_point_at_depth(params: &ScreenPickParams, screen_x: f32, depth: f32) -> (f32, f32) {
    let proj_dist = params.projection_distance();
    let camera_y = (screen_x - params.screen_width * 0.5) * depth / proj_dist;
    let rx = depth * params.player_angle.cos() - camera_y * params.player_angle.sin();
    let ry = depth * params.player_angle.sin() + camera_y * params.player_angle.cos();
    (params.player_x + rx, params.player_y + ry)
}

#[inline]
fn candidate_priority(surface: PickSurface) -> u8 {
    match surface {
        PickSurface::Wall => 0,
        PickSurface::Floor => 1,
        PickSurface::Ceiling => 2,
    }
}

fn pick_precedes(candidate: &PickResult, current: &PickResult) -> bool {
    const PICK_EPS: f32 = 1e-4;
    candidate.distance + PICK_EPS < current.distance
        || ((candidate.distance - current.distance).abs() <= PICK_EPS
            && candidate_priority(candidate.surface) < candidate_priority(current.surface))
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum WallPickDecision {
    Hit,
    Continue,
    Stop,
}

impl Raycaster2D {
    #[allow(clippy::too_many_arguments)]
    fn make_wall_pick_result(
        &self,
        params: &ScreenPickParams,
        level_index: usize,
        ray_angle: f32,
        grid_x: usize,
        grid_y: usize,
        raw_distance: f32,
        wall_side: u8,
        hit_x: f32,
        hit_y: f32,
        tex_u: f32,
        tex_v: f32,
        wall_height: f32,
        cell_value: u32,
        wall_feature: Option<WallFeature>,
        wall_section: Option<PickWallSection>,
    ) -> PickResult {
        PickResult {
            level_index,
            grid_x,
            grid_y,
            distance: corrected_pick_distance(ray_angle, params.player_angle, raw_distance),
            wall_side: Some(wall_side),
            surface: PickSurface::Wall,
            hit_x,
            hit_y,
            tex_u,
            tex_v,
            wall_height: Some(wall_height.max(0.0)),
            cell_value,
            ray_angle,
            wall_feature,
            wall_section,
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn pick_wall_candidate(
        &self,
        params: &ScreenPickParams,
        screen_y: f32,
        level_index: usize,
        camera_world_z: f32,
        floor_world_z: f32,
        ceiling_world_z: f32,
        ray_angle: f32,
        dir_x: f32,
        dir_y: f32,
        grid_x: usize,
        grid_y: usize,
        cell_value: u32,
        side: u8,
        boundary_distance: f32,
    ) -> (WallPickDecision, Option<PickResult>) {
        let full_height = (ceiling_world_z - floor_world_z).max(1e-4);
        let corrected_boundary_distance =
            corrected_pick_distance(ray_angle, params.player_angle, boundary_distance);
        let local_height = wall_height_at_screen_y(
            params,
            screen_y,
            camera_world_z,
            floor_world_z,
            corrected_boundary_distance,
        );
        let boundary_hit_x = params.player_x + dir_x * boundary_distance;
        let boundary_hit_y = params.player_y + dir_y * boundary_distance;
        let boundary_tex_u = if side == 0 {
            frac01(boundary_hit_y).abs()
        } else {
            frac01(boundary_hit_x).abs()
        };

        let Some(feature) = self.wall_feature(grid_x as u32, grid_y as u32) else {
            if (-1e-4..=full_height + 1e-4).contains(&local_height) {
                return (
                    WallPickDecision::Hit,
                    Some(self.make_wall_pick_result(
                        params,
                        level_index,
                        ray_angle,
                        grid_x,
                        grid_y,
                        boundary_distance,
                        side,
                        boundary_hit_x,
                        boundary_hit_y,
                        boundary_tex_u,
                        (local_height / full_height).clamp(0.0, 1.0),
                        local_height.clamp(0.0, full_height),
                        cell_value,
                        None,
                        None,
                    )),
                );
            }
            return (WallPickDecision::Stop, None);
        };

        if local_height < -1e-4 || local_height > full_height + 1e-4 {
            return (WallPickDecision::Stop, None);
        }

        match feature.kind {
            WallFeatureKind::HalfHeight { height } => {
                if local_height <= height + 1e-4 {
                    (
                        WallPickDecision::Hit,
                        Some(self.make_wall_pick_result(
                            params,
                            level_index,
                            ray_angle,
                            grid_x,
                            grid_y,
                            boundary_distance,
                            side,
                            boundary_hit_x,
                            boundary_hit_y,
                            boundary_tex_u,
                            (local_height / height.max(1e-4)).clamp(0.0, 1.0),
                            local_height.clamp(0.0, height),
                            cell_value,
                            Some(feature),
                            Some(PickWallSection::Body),
                        )),
                    )
                } else {
                    (WallPickDecision::Continue, None)
                }
            }
            WallFeatureKind::Window {
                sill_height,
                lintel_height,
            } => {
                if local_height <= sill_height + 1e-4 {
                    (
                        WallPickDecision::Hit,
                        Some(self.make_wall_pick_result(
                            params,
                            level_index,
                            ray_angle,
                            grid_x,
                            grid_y,
                            boundary_distance,
                            side,
                            boundary_hit_x,
                            boundary_hit_y,
                            boundary_tex_u,
                            (local_height / sill_height.max(1e-4)).clamp(0.0, 1.0),
                            local_height.clamp(0.0, sill_height),
                            cell_value,
                            Some(feature),
                            Some(PickWallSection::Lower),
                        )),
                    )
                } else if local_height >= lintel_height - 1e-4 && local_height <= 1.0 + 1e-4 {
                    (
                        WallPickDecision::Hit,
                        Some(
                            self.make_wall_pick_result(
                                params,
                                level_index,
                                ray_angle,
                                grid_x,
                                grid_y,
                                boundary_distance,
                                side,
                                boundary_hit_x,
                                boundary_hit_y,
                                boundary_tex_u,
                                ((local_height - lintel_height) / (1.0 - lintel_height).max(1e-4))
                                    .clamp(0.0, 1.0),
                                local_height.clamp(0.0, 1.0),
                                cell_value,
                                Some(feature),
                                Some(PickWallSection::Upper),
                            ),
                        ),
                    )
                } else {
                    (WallPickDecision::Continue, None)
                }
            }
            WallFeatureKind::Door {
                direction,
                open_amount,
            } => {
                if local_height > 1.0 + 1e-4 {
                    return (WallPickDecision::Continue, None);
                }
                let open_offset = open_amount.clamp(0.0, 0.98);
                let span = (1.0 - open_amount.clamp(0.0, 1.0)).max(0.02);
                match direction {
                    DoorDirection::Horizontal => {
                        if dir_y.abs() < 1e-6 {
                            return (WallPickDecision::Continue, None);
                        }
                        let slab_y = grid_y as f32 + 0.5;
                        let slab_distance = (slab_y - params.player_y) / dir_y;
                        if slab_distance <= 0.0 || slab_distance > params.max_distance {
                            return (WallPickDecision::Continue, None);
                        }
                        let slab_x = params.player_x + dir_x * slab_distance;
                        let start_x = grid_x as f32 + open_offset;
                        let end_x = start_x + span;
                        if slab_x < start_x - 1e-4
                            || slab_x > end_x + 1e-4
                            || slab_x < grid_x as f32 - 1e-4
                            || slab_x > grid_x as f32 + 1.0 + 1e-4
                        {
                            return (WallPickDecision::Continue, None);
                        }
                        (
                            WallPickDecision::Hit,
                            Some(self.make_wall_pick_result(
                                params,
                                level_index,
                                ray_angle,
                                grid_x,
                                grid_y,
                                slab_distance,
                                1,
                                slab_x,
                                slab_y,
                                ((slab_x - start_x) / span).clamp(0.0, 1.0),
                                local_height.clamp(0.0, 1.0),
                                local_height.clamp(0.0, 1.0),
                                cell_value,
                                Some(feature),
                                Some(PickWallSection::Panel),
                            )),
                        )
                    }
                    DoorDirection::Vertical => {
                        if dir_x.abs() < 1e-6 {
                            return (WallPickDecision::Continue, None);
                        }
                        let slab_x = grid_x as f32 + 0.5;
                        let slab_distance = (slab_x - params.player_x) / dir_x;
                        if slab_distance <= 0.0 || slab_distance > params.max_distance {
                            return (WallPickDecision::Continue, None);
                        }
                        let slab_y = params.player_y + dir_y * slab_distance;
                        let start_y = grid_y as f32 + open_offset;
                        let end_y = start_y + span;
                        if slab_y < start_y - 1e-4
                            || slab_y > end_y + 1e-4
                            || slab_y < grid_y as f32 - 1e-4
                            || slab_y > grid_y as f32 + 1.0 + 1e-4
                        {
                            return (WallPickDecision::Continue, None);
                        }
                        (
                            WallPickDecision::Hit,
                            Some(self.make_wall_pick_result(
                                params,
                                level_index,
                                ray_angle,
                                grid_x,
                                grid_y,
                                slab_distance,
                                0,
                                slab_x,
                                slab_y,
                                ((slab_y - start_y) / span).clamp(0.0, 1.0),
                                local_height.clamp(0.0, 1.0),
                                local_height.clamp(0.0, 1.0),
                                cell_value,
                                Some(feature),
                                Some(PickWallSection::Panel),
                            )),
                        )
                    }
                }
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn pick_visible_wall_hit(
        &self,
        params: &ScreenPickParams,
        screen_y: f32,
        level_index: usize,
        camera_world_z: f32,
        floor_world_z: f32,
        ceiling_world_z: f32,
        ray_angle: f32,
    ) -> Option<PickResult> {
        let dir_x = ray_angle.cos();
        let dir_y = ray_angle.sin();
        let mut map_x = params.player_x.floor() as i32;
        let mut map_y = params.player_y.floor() as i32;
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
            (-1, (params.player_x - map_x as f32) * delta_dist_x)
        } else {
            (1, (map_x as f32 + 1.0 - params.player_x) * delta_dist_x)
        };
        let (step_y, mut side_dist_y) = if dir_y < 0.0 {
            (-1, (params.player_y - map_y as f32) * delta_dist_y)
        } else {
            (1, (map_y as f32 + 1.0 - params.player_y) * delta_dist_y)
        };

        loop {
            let (side, boundary_distance) = if side_dist_x < side_dist_y {
                side_dist_x += delta_dist_x;
                map_x += step_x;
                (0u8, side_dist_x - delta_dist_x)
            } else {
                side_dist_y += delta_dist_y;
                map_y += step_y;
                (1u8, side_dist_y - delta_dist_y)
            };
            if boundary_distance > params.max_distance {
                return None;
            }
            if map_x < 0
                || map_y < 0
                || map_x >= self.width() as i32
                || map_y >= self.height() as i32
            {
                return None;
            }

            let cell_value = self.get_cell(map_x as u32, map_y as u32);
            if cell_value == 0 {
                continue;
            }

            let (decision, pick) = self.pick_wall_candidate(
                params,
                screen_y,
                level_index,
                camera_world_z,
                floor_world_z,
                ceiling_world_z,
                ray_angle,
                dir_x,
                dir_y,
                map_x as usize,
                map_y as usize,
                cell_value,
                side,
                boundary_distance,
            );
            match decision {
                WallPickDecision::Hit => return pick,
                WallPickDecision::Continue => continue,
                WallPickDecision::Stop => return None,
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn pick_screen_volume(
        &self,
        params: &ScreenPickParams,
        screen_x: f32,
        screen_y: f32,
        level_index: usize,
        camera_world_z: f32,
        floor_world_z: f32,
        ceiling_world_z: f32,
        floor_visible_at: &dyn Fn(u32, u32) -> bool,
        ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
    ) -> Option<PickResult> {
        if params.validate(&RaycasterLimits::default()).is_err() {
            return None;
        }

        let sx = screen_x.clamp(0.0, params.screen_width - 1.0);
        let sy = screen_y.clamp(0.0, params.screen_height - 1.0);
        let ray_angle = pick_ray_angle(params, sx);
        let horizon = params.horizon();
        let proj_dist = params.projection_distance();
        let mut best_pick: Option<PickResult> = self.pick_visible_wall_hit(
            params,
            sy,
            level_index,
            camera_world_z,
            floor_world_z,
            ceiling_world_z,
            ray_angle,
        );
        let corrected_wall_dist = best_pick
            .as_ref()
            .map(|pick| pick.distance)
            .unwrap_or(params.max_distance);
        let wall_covers_pixel = best_pick
            .as_ref()
            .map(|pick| pick.surface == PickSurface::Wall)
            .unwrap_or(false);

        let mut try_plane =
            |plane_z: f32, surface: PickSurface, visible_at: &dyn Fn(u32, u32) -> bool| {
                let plane_offset = camera_world_z - plane_z;
                let denom = sy - horizon;
                if denom.abs() < 1e-4 {
                    return;
                }
                let plane_depth = proj_dist * plane_offset / denom;
                if plane_depth <= 0.0 || plane_depth > params.max_distance {
                    return;
                }
                if wall_covers_pixel && plane_depth >= corrected_wall_dist {
                    return;
                }

                let (world_x, world_y) = pick_world_point_at_depth(params, sx, plane_depth);
                if world_x < 0.0
                    || world_y < 0.0
                    || world_x >= self.width() as f32
                    || world_y >= self.height() as f32
                {
                    return;
                }

                let grid_x = world_x.floor() as usize;
                let grid_y = world_y.floor() as usize;
                if !visible_at(grid_x as u32, grid_y as u32) {
                    return;
                }

                let candidate = PickResult {
                    level_index,
                    grid_x,
                    grid_y,
                    distance: plane_depth,
                    wall_side: None,
                    surface,
                    hit_x: world_x,
                    hit_y: world_y,
                    tex_u: frac01(world_x),
                    tex_v: frac01(world_y),
                    wall_height: None,
                    cell_value: self.get_cell(grid_x as u32, grid_y as u32),
                    ray_angle,
                    wall_feature: None,
                    wall_section: None,
                };
                if best_pick
                    .as_ref()
                    .map(|current| pick_precedes(&candidate, current))
                    .unwrap_or(true)
                {
                    best_pick = Some(candidate);
                }
            };

        try_plane(floor_world_z, PickSurface::Floor, floor_visible_at);
        try_plane(ceiling_world_z, PickSurface::Ceiling, ceiling_visible_at);

        best_pick
    }

    /// Resolve a screen pixel back into the world-space wall, floor, or ceiling surface it points at.
    pub fn pick_screen(
        &self,
        params: &ScreenPickParams,
        screen_x: f32,
        screen_y: f32,
    ) -> Option<PickResult> {
        let eye = params.camera_height.clamp(0.1, 0.9);
        self.pick_screen_volume(
            params,
            screen_x,
            screen_y,
            0,
            eye,
            0.0,
            1.0,
            &|_, _| true,
            &|_, _| true,
        )
    }
}

impl MultiLevelGrid {
    /// Resolve a screen pixel against a stacked raycaster world and return the owning level.
    pub fn pick_screen(
        &self,
        params: &ScreenPickParams,
        screen_x: f32,
        screen_y: f32,
    ) -> Option<PickResult> {
        let eye = params.camera_height.clamp(0.1, 0.9);
        let camera_world_z = self
            .get_active()
            .map(|level| level.floor_offset + eye)
            .unwrap_or(eye);
        let mut best_pick: Option<PickResult> = None;

        for level_index in
            self.visible_level_indices(params.player_x, params.player_y, params.max_distance)
        {
            let Some(candidate) = self.with_runtime_level(level_index, |level, raycaster| {
                raycaster.pick_screen_volume(
                    params,
                    screen_x,
                    screen_y,
                    level_index,
                    camera_world_z,
                    level.floor_offset,
                    level.ceiling_height,
                    &|x, y| !level.is_floor_hole(x as usize, y as usize),
                    &|x, y| !level.is_ceiling_hole(x as usize, y as usize),
                )
            }) else {
                continue;
            };
            let Some(candidate) = candidate else {
                continue;
            };

            if best_pick
                .as_ref()
                .map(|current| pick_precedes(&candidate, current))
                .unwrap_or(true)
            {
                best_pick = Some(candidate);
            }
        }

        best_pick
    }
}
