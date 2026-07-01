//! This file owns `RaycasterScene::build` and `build_multilevel`, which turn camera state into prepared scene geometry.
//! It defines scene-build inputs such as `SceneBuildParams`, `LoweredFloorCell`, `WorldSprite`, and `LevelSprite`.
//! Wall hits are converted here into perspective-correct quads with texture routing, cell values, depths, and light tint.
//! Floor and ceiling tiles expand into screen-space spans with stable UVs, texture overrides, and roof-aware lighting.
//! Lowered-floor cells generate pits, bottoms, and side faces so vertical relief survives scene translation cleanly.
//! Lighting sampling blends ambient, point, and global light here, with a cache that keeps repeated queries affordable.
//! Roofed cells, ceiling holes, and multilevel visibility rules influence which surfaces are emitted and how they render.
//! Billboard sprites use the same camera model as walls, including directional texture selection from viewer angle.
//! Multilevel builds group sprites and lights per slice, compile level runtimes on demand, and merge visible slices.
//! Texture lookup callbacks keep resource routing outside the builder while geometry and lighting policy stay centralized.
//! This file is the staging boundary between grid-owned ray data and the renderer-facing `RaycasterScene` surface.
//! It is the right owner for changing surface emission, pit geometry, or light application without renderer rewrites.
//! Open this file when scene assembly semantics change; casting, picking, and draw translation live in siblings.

use crate::color::Color;
use crate::math::Vec2;
use crate::raycaster::contract::{RaycasterError, RaycasterLimits};
use crate::raycaster::dda::Raycaster2D;
use crate::raycaster::lighting::{apply_global_light, compute_lighting, PointLight};
use crate::raycaster::multilevel::MultiLevelGrid;
use crate::raycaster::projection::distance_shade;
use crate::raycaster::ray_hit::RayHit;
use crate::raycaster::scene::{
    BillboardSprite, CeilingQuad, FloorQuad, RaycasterBackground, RaycasterBuildStats,
    RaycasterMaterial, RaycasterMaterialFrameLayout, RaycasterOverlayEffect, RaycasterParticle,
    RaycasterScene, WallQuad,
};
use crate::raycaster::wall_feature::{WallFeature, WallFeatureKind};
use crate::render::renderer::ParticleRenderShape;
use crate::render::BlendMode;
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use std::collections::HashMap;
/// A floor cell that sits below the standard floor plane, used for pits and step-down areas.
#[derive(Debug, Clone, Copy)]
pub struct LoweredFloorCell {
    /// Texture applied to the lowered floor surface.
    pub texture_key: TextureKey,
    /// Downward offset from the standard floor plane (positive = lower), range 0..1.
    pub depth_offset: f32,
    /// RGB tint multiplier applied to the floor surface color.
    pub tint: [f32; 3],
    /// When true the lowered floor is emitted as a blocked render tile for pits or solid step-down cells.
    pub blocked: bool,
}

/// A billboard sprite attached to a specific multi-level slice.
#[derive(Debug, Clone)]
pub struct LevelSprite {
    /// Zero-based level index that owns the sprite.
    pub level_index: usize,
    /// Sprite payload projected within that level's floor plane.
    pub sprite: WorldSprite,
}

/// A world-space projected particle emitter attached to a specific multi-level slice.
#[derive(Debug, Clone)]
pub struct LevelParticleEmitter {
    /// Zero-based level index that owns the emitter.
    pub level_index: usize,
    /// Emitter payload projected within that level's floor plane.
    pub emitter: RaycasterParticleEmitter,
}
/// Build a 4-corner array for an axis-aligned rectangle in screen space.
fn corners_from_rect(x: f32, y: f32, w: f32, h: f32) -> [Vec2; 4] {
    [
        Vec2::new(x, y),
        Vec2::new(x + w, y),
        Vec2::new(x + w, y + h),
        Vec2::new(x, y + h),
    ]
}
/// Return the standard [0,0]..[1,1] UV coordinates for a quad's four corners.
fn rect_uvs() -> [Vec2; 4] {
    [
        Vec2::new(0.0, 0.0),
        Vec2::new(1.0, 0.0),
        Vec2::new(1.0, 1.0),
        Vec2::new(0.0, 1.0),
    ]
}
/// Return the fractional part of `v` in [0,1), wrapping negative values.
fn frac01(v: f32) -> f32 {
    let f = v - v.floor();
    if f < 0.0 {
        f + 1.0
    } else {
        f
    }
}
/// Return the grid cell just before a ray hit; used to look up the floor/ceiling texture at the approach tile.
#[allow(dead_code)]
fn floor_cell_before_hit(hit: &RayHit, ray_angle: f32) -> (u32, u32) {
    let wx = (hit.hit_x - ray_angle.cos() * 0.5).max(0.0);
    let wy = (hit.hit_y - ray_angle.sin() * 0.5).max(0.0);
    (wx.floor() as u32, wy.floor() as u32)
}
/// Build quad UV coordinates from near and far world-space fractional positions for a floor column strip.
#[allow(dead_code)]
fn column_uvs_from_world(near_x: f32, near_y: f32, far_x: f32, far_y: f32) -> [Vec2; 4] {
    let nu = frac01(near_x);
    let nv = frac01(near_y);
    let fu = frac01(far_x);
    let fv = frac01(far_y);
    [
        Vec2::new(nu, nv),
        Vec2::new(nu, nv),
        Vec2::new(fu, fv),
        Vec2::new(fu, fv),
    ]
}
/// Minimum camera-depth before which floor/ceiling geometry is discarded to avoid near-plane artifacts.
const FLOOR_NEAR: f32 = 0.05;

#[derive(Debug, Clone, Copy)]
struct VerticalPlanes {
    floor_plane: f32,
    ceiling_plane: f32,
}

#[inline]
fn vertical_planes(
    camera_world_z: f32,
    floor_world_z: f32,
    ceiling_world_z: f32,
) -> VerticalPlanes {
    VerticalPlanes {
        floor_plane: camera_world_z - floor_world_z,
        ceiling_plane: camera_world_z - ceiling_world_z,
    }
}
/// Project world point `(wx, wy)` onto the camera forward axis; return signed camera-space depth.
#[inline]
fn camera_depth(wx: f32, wy: f32, px: f32, py: f32, cos_a: f32, sin_a: f32) -> f32 {
    let rx = wx - px;
    let ry = wy - py;
    rx * cos_a + ry * sin_a
}
#[inline]
fn roofed_ambient(params: &SceneBuildParams, roofed: bool) -> f32 {
    if roofed {
        params.ambient_light * params.roofed_ambient_factor
    } else {
        params.ambient_light
    }
}

#[inline]
fn apply_global_light_tint(
    light_rgb: [f32; 3],
    x: f32,
    y: f32,
    roofed: bool,
    params: &SceneBuildParams,
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> [f32; 3] {
    apply_global_light(
        light_rgb,
        x,
        y,
        roofed,
        [
            params.global_light_color.r,
            params.global_light_color.g,
            params.global_light_color.b,
        ],
        params.global_light_intensity,
        params.sun_angle,
        params.max_distance.min(12.0),
        wall_at,
    )
}

#[derive(Default)]
struct LightingSampleCache {
    samples: HashMap<(usize, i32, i32, bool), [f32; 3]>,
    hits: u32,
    misses: u32,
}

impl LightingSampleCache {
    #[allow(clippy::too_many_arguments)]
    fn sample(
        &mut self,
        level_index: usize,
        x: f32,
        y: f32,
        roofed: bool,
        params: &SceneBuildParams,
        lights: &[PointLight],
        wall_at: &dyn Fn(i32, i32) -> bool,
    ) -> [f32; 3] {
        let cell_x = x.floor() as i32;
        let cell_y = y.floor() as i32;
        let key = (level_index, cell_x, cell_y, roofed);
        if let Some(light) = self.samples.get(&key).copied() {
            self.hits = self.hits.saturating_add(1);
            return light;
        }

        self.misses = self.misses.saturating_add(1);
        let ambient = roofed_ambient(params, roofed);
        let sample_x = cell_x as f32 + 0.5;
        let sample_y = cell_y as f32 + 0.5;
        let light = apply_global_light_tint(
            compute_lighting(sample_x, sample_y, ambient, lights, wall_at),
            sample_x,
            sample_y,
            roofed,
            params,
            wall_at,
        );
        self.samples.insert(key, light);
        light
    }

    fn stats(&self) -> RaycasterBuildStats {
        RaycasterBuildStats {
            lighting_samples: self.hits.saturating_add(self.misses),
            lighting_cache_hits: self.hits,
            lighting_cache_misses: self.misses,
            wall_quads: 0,
            floor_quads: 0,
            ceiling_quads: 0,
            sprites: 0,
            models: 0,
            particles: 0,
            visible_levels: 0,
            depth_columns: 0,
        }
    }
}

/// Cached projection of one grid corner to screen space for floor/ceiling quad building.
#[derive(Debug, Clone, Copy)]
struct ProjectedGroundPoint {
    /// Screen-space X coordinate of the corner.
    sx: f32,
    /// Screen-space Y coordinate of the floor plane at this corner.
    floor_y: f32,
    /// Screen-space Y coordinate of the ceiling plane at this corner.
    ceil_y: f32,
    /// Camera-space depth (positive forward), used for perspective-correct UV interpolation.
    cx: f32,
}
/// Project world corner `(wx, wy)` to screen space for both floor and ceiling planes; return a `ProjectedGroundPoint`.
#[allow(clippy::too_many_arguments)]
#[inline]
fn project_ground_point(
    wx: f32,
    wy: f32,
    px: f32,
    py: f32,
    cos_a: f32,
    sin_a: f32,
    proj_dist: f32,
    screen_w: f32,
    horizon: f32,
    floor_plane: f32,
    ceiling_plane: f32,
) -> ProjectedGroundPoint {
    let rx = wx - px;
    let ry = wy - py;
    let cx = (rx * cos_a + ry * sin_a).max(FLOOR_NEAR);
    let cy = -rx * sin_a + ry * cos_a;
    let sx = (screen_w * 0.5 + (cy / cx) * proj_dist).clamp(-screen_w * 2.0, screen_w * 3.0);
    let sy_floor = horizon + proj_dist * floor_plane / cx;
    let sy_ceil = horizon + proj_dist * ceiling_plane / cx;
    ProjectedGroundPoint {
        sx: snap_half(sx),
        floor_y: snap_half(sy_floor),
        ceil_y: snap_half(sy_ceil),
        cx,
    }
}
/// Project world point `(wx, wy)` onto a single horizontal plane at `plane_offset`; return `(screen_x, screen_y, camera_depth)`.
#[allow(clippy::too_many_arguments)]
#[inline]
fn project_horizontal_plane(
    wx: f32,
    wy: f32,
    px: f32,
    py: f32,
    cos_a: f32,
    sin_a: f32,
    proj_dist: f32,
    screen_w: f32,
    horizon: f32,
    plane_offset: f32,
) -> (f32, f32, f32) {
    let rx = wx - px;
    let ry = wy - py;
    let cx = (rx * cos_a + ry * sin_a).max(FLOOR_NEAR);
    let cy = -rx * sin_a + ry * cos_a;
    let sx = (screen_w * 0.5 + (cy / cx) * proj_dist).clamp(-screen_w * 2.0, screen_w * 3.0);
    let sy = horizon + proj_dist * plane_offset / cx;
    (snap_half(sx), snap_half(sy), cx)
}
/// Round `v` to the nearest 0.5 to reduce sub-pixel jitter on floor/ceiling edges.
#[inline]
fn snap_half(v: f32) -> f32 {
    (v * 2.0).round() * 0.5
}

fn hash_u32(mut value: u32) -> u32 {
    value ^= value >> 16;
    value = value.wrapping_mul(0x7feb_352d);
    value ^= value >> 15;
    value = value.wrapping_mul(0x846c_a68b);
    value ^ (value >> 16)
}

fn random01(seed: u32, stream: u32) -> f32 {
    let hashed = hash_u32(seed ^ stream.wrapping_mul(0x9e37_79b9));
    hashed as f32 / u32::MAX as f32
}

fn random_signed(seed: u32, stream: u32) -> f32 {
    random01(seed, stream) * 2.0 - 1.0
}

fn build_depth_columns(raycaster: &Raycaster2D, params: &SceneBuildParams) -> Vec<f32> {
    raycaster
        .cast_rays(
            params.player_x,
            params.player_y,
            params.player_angle,
            params.fov,
            params.ray_count.max(1),
            params.max_distance,
        )
        .into_iter()
        .map(|hit| hit.distance.max(0.0))
        .collect()
}
/// Emit `FloorQuad`, `CeilingQuad`, and lowered-floor side `WallQuad` entries for all visible open tiles.
#[allow(clippy::too_many_arguments)]
fn build_floor_tiles(
    raycaster: &Raycaster2D,
    level_index: usize,
    params: &SceneBuildParams,
    proj_dist: f32,
    planes: VerticalPlanes,
    lights: &[PointLight],
    wall_at: &dyn Fn(i32, i32) -> bool,
    floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
    ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
    floor_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
    ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
    floor_visible_at: &dyn Fn(u32, u32) -> bool,
    ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
    roofed_at: &dyn Fn(u32, u32) -> bool,
    lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    lighting_cache: &mut LightingSampleCache,
    walls: &mut Vec<WallQuad>,
    floors: &mut Vec<FloorQuad>,
    ceilings: &mut Vec<CeilingQuad>,
) {
    let horizon = params.screen_height * 0.5 - params.horizon_offset;
    let floor_plane = planes.floor_plane;
    let ceiling_plane = planes.ceiling_plane;
    let cos_a = params.player_angle.cos();
    let sin_a = params.player_angle.sin();
    let px = params.player_x;
    let py = params.player_y;
    let sw = params.screen_width;
    let md = params.max_distance;
    let map_w = raycaster.width() as i32;
    let map_h = raycaster.height() as i32;
    let tx0 = (px - md - 1.0).floor() as i32;
    let tx1 = (px + md + 1.0).ceil() as i32;
    let ty0 = (py - md - 1.0).floor() as i32;
    let ty1 = (py + md + 1.0).ceil() as i32;
    let tx0 = tx0.max(0);
    let ty0 = ty0.max(0);
    let tx1 = tx1.min(map_w - 1);
    let ty1 = ty1.min(map_h - 1);
    let vx0 = tx0.max(0);
    let vy0 = ty0.max(0);
    let vx1 = (tx1 + 1).min(map_w);
    let vy1 = (ty1 + 1).min(map_h);
    let proj_w = (vx1 - vx0 + 1).max(0) as usize;
    let proj_h = (vy1 - vy0 + 1).max(0) as usize;
    let mut proj: Vec<ProjectedGroundPoint> = Vec::with_capacity(proj_w * proj_h);
    let proj_idx =
        |gx: i32, gy: i32| -> usize { ((gy - vy0) as usize) * proj_w + (gx - vx0) as usize };
    for gy in vy0..=vy1 {
        for gx in vx0..=vx1 {
            proj.push(project_ground_point(
                gx as f32,
                gy as f32,
                px,
                py,
                cos_a,
                sin_a,
                proj_dist,
                sw,
                horizon,
                floor_plane,
                ceiling_plane,
            ));
        }
    }
    for ty in ty0..=ty1 {
        for tx in tx0..=tx1 {
            if raycaster.get_cell(tx as u32, ty as u32) != 0 {
                continue;
            }
            let dist = {
                let dx = tx as f32 + 0.5 - px;
                let dy = ty as f32 + 0.5 - py;
                (dx * dx + dy * dy).sqrt()
            };
            if dist > md + 1.5 {
                continue;
            }
            if tx < vx0 || ty < vy0 || tx + 1 > vx1 || ty + 1 > vy1 {
                continue;
            }
            let p0 = proj[proj_idx(tx, ty)];
            let p1 = proj[proj_idx(tx + 1, ty)];
            let p2 = proj[proj_idx(tx + 1, ty + 1)];
            let p3 = proj[proj_idx(tx, ty + 1)];
            let c0 = camera_depth(tx as f32, ty as f32, px, py, cos_a, sin_a);
            let c1 = camera_depth(tx as f32 + 1.0, ty as f32, px, py, cos_a, sin_a);
            let c2 = camera_depth(tx as f32 + 1.0, ty as f32 + 1.0, px, py, cos_a, sin_a);
            let c3 = camera_depth(tx as f32, ty as f32 + 1.0, px, py, cos_a, sin_a);
            if c0 <= FLOOR_NEAR && c1 <= FLOOR_NEAR && c2 <= FLOOR_NEAR && c3 <= FLOOR_NEAR {
                continue;
            }
            let floor_visible = floor_visible_at(tx as u32, ty as u32);
            let ceiling_visible = ceiling_visible_at(tx as u32, ty as u32);
            if !floor_visible && !ceiling_visible {
                continue;
            }
            let lowered = lowered_floor_at(tx as u32, ty as u32);
            let top_plane = floor_plane + lowered.map(|c| c.depth_offset).unwrap_or(0.0);
            let tile_cx = tx as f32 + 0.5;
            let tile_cy = ty as f32 + 0.5;
            let roofed_here = roofed_at(tx as u32, ty as u32);
            let ceil_tex = if ceiling_visible {
                ceiling_texture_at(tx as u32, ty as u32)
            } else {
                None
            };
            let light_rgb = lighting_cache.sample(
                level_index,
                tile_cx,
                tile_cy,
                roofed_here,
                params,
                lights,
                wall_at,
            );
            let floor_base = if let Some(cell) = lowered {
                Color::new(cell.tint[0], cell.tint[1], cell.tint[2], 1.0)
            } else {
                params.floor_color
            };
            let floor_light = {
                let c = lit_surface_color(&floor_base, light_rgb, 1.0);
                color_to_light(&c)
            };
            let default_ceil_light = {
                let c = lit_surface_color(&params.ceiling_color, light_rgb, 1.0);
                color_to_light(&c)
            };
            let base_floor_tex = floor_texture_at(tx as u32, ty as u32);
            let floor_material = floor_material_at(tx as u32, ty as u32);
            let ceiling_material = ceiling_material_at(tx as u32, ty as u32);
            let floor_tex = material_texture(
                floor_material.as_ref(),
                lowered.map(|c| c.texture_key).or(base_floor_tex),
            );
            let tp0 = project_horizontal_plane(
                tx as f32, ty as f32, px, py, cos_a, sin_a, proj_dist, sw, horizon, top_plane,
            );
            let tp1 = project_horizontal_plane(
                tx as f32 + 1.0,
                ty as f32,
                px,
                py,
                cos_a,
                sin_a,
                proj_dist,
                sw,
                horizon,
                top_plane,
            );
            let tp2 = project_horizontal_plane(
                tx as f32 + 1.0,
                ty as f32 + 1.0,
                px,
                py,
                cos_a,
                sin_a,
                proj_dist,
                sw,
                horizon,
                top_plane,
            );
            let tp3 = project_horizontal_plane(
                tx as f32,
                ty as f32 + 1.0,
                px,
                py,
                cos_a,
                sin_a,
                proj_dist,
                sw,
                horizon,
                top_plane,
            );
            let floor_corners = [
                Vec2::new(tp0.0, tp0.1),
                Vec2::new(tp1.0, tp1.1),
                Vec2::new(tp2.0, tp2.1),
                Vec2::new(tp3.0, tp3.1),
            ];
            let ceil_corners = [
                Vec2::new(p0.sx, p0.ceil_y),
                Vec2::new(p1.sx, p1.ceil_y),
                Vec2::new(p2.sx, p2.ceil_y),
                Vec2::new(p3.sx, p3.ceil_y),
            ];
            if floor_visible {
                floors.push(FloorQuad {
                    corners: floor_corners,
                    uvs: material_uvs(rect_uvs(), floor_material.as_ref(), params.time_seconds),
                    texture_key: floor_tex,
                    light: tint_light(floor_light, floor_material.as_ref()),
                    depth: dist,
                    corner_w: [tp0.2, tp1.2, tp2.2, tp3.2],
                    level_index,
                    material: floor_material.clone(),
                });
            }
            if ceiling_visible {
                let ceil_light = if roofed_here {
                    floor_light
                } else {
                    default_ceil_light
                };
                let ceil_tex = material_texture(ceiling_material.as_ref(), ceil_tex);
                ceilings.push(CeilingQuad {
                    corners: ceil_corners,
                    uvs: material_uvs(rect_uvs(), ceiling_material.as_ref(), params.time_seconds),
                    texture_key: ceil_tex,
                    light: tint_light(ceil_light, ceiling_material.as_ref()),
                    depth: dist,
                    corner_w: [p0.cx, p1.cx, p2.cx, p3.cx],
                    level_index,
                    material: ceiling_material.clone(),
                });
            }
            if floor_visible {
                if let Some(cell) = lowered {
                    let top = floor_plane;
                    let bottom = floor_plane + cell.depth_offset;
                    let side_color = color_to_light(&lit_surface_color(
                        &Color::new(
                            cell.tint[0] * 0.75,
                            cell.tint[1] * 0.75,
                            cell.tint[2] * 0.75,
                            1.0,
                        ),
                        light_rgb,
                        1.0,
                    ));
                    let side_tex = material_texture(floor_material.as_ref(), base_floor_tex);
                    let neighbour_drop = |nx: i32, ny: i32| {
                        lowered_floor_at(nx as u32, ny as u32)
                            .map(|c| c.depth_offset)
                            .unwrap_or(0.0)
                    };
                    let render_side = |walls: &mut Vec<WallQuad>,
                                       ax: f32,
                                       ay: f32,
                                       bx: f32,
                                       by: f32,
                                       nx: i32,
                                       ny: i32| {
                        let should_render = if nx < 0 || ny < 0 || nx >= map_w || ny >= map_h {
                            true
                        } else if raycaster.get_cell(nx as u32, ny as u32) != 0 {
                            false
                        } else {
                            neighbour_drop(nx, ny) + 1e-4 < cell.depth_offset
                        };
                        if should_render {
                            let ca = camera_depth(ax, ay, px, py, cos_a, sin_a);
                            let cb = camera_depth(bx, by, px, py, cos_a, sin_a);
                            if ca <= FLOOR_NEAR || cb <= FLOOR_NEAR {
                                return;
                            }
                            let pta = project_horizontal_plane(
                                ax, ay, px, py, cos_a, sin_a, proj_dist, sw, horizon, top,
                            );
                            let ptb = project_horizontal_plane(
                                bx, by, px, py, cos_a, sin_a, proj_dist, sw, horizon, top,
                            );
                            let pba = project_horizontal_plane(
                                ax, ay, px, py, cos_a, sin_a, proj_dist, sw, horizon, bottom,
                            );
                            let pbb = project_horizontal_plane(
                                bx, by, px, py, cos_a, sin_a, proj_dist, sw, horizon, bottom,
                            );
                            walls.push(WallQuad {
                                corners: [
                                    Vec2::new(pta.0, pta.1),
                                    Vec2::new(ptb.0, ptb.1),
                                    Vec2::new(pbb.0, pbb.1),
                                    Vec2::new(pba.0, pba.1),
                                ],
                                uvs: material_uvs(
                                    rect_uvs(),
                                    floor_material.as_ref(),
                                    params.time_seconds,
                                ),
                                texture_key: side_tex,
                                light: tint_light(side_color, floor_material.as_ref()),
                                depth: dist + 0.001,
                                corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                                cell_value: 0,
                                level_index,
                                material: floor_material.clone(),
                            });
                        }
                    };
                    render_side(
                        walls,
                        tx as f32,
                        ty as f32,
                        tx as f32 + 1.0,
                        ty as f32,
                        tx,
                        ty - 1,
                    );
                    render_side(
                        walls,
                        tx as f32 + 1.0,
                        ty as f32 + 1.0,
                        tx as f32,
                        ty as f32 + 1.0,
                        tx,
                        ty + 1,
                    );
                    render_side(
                        walls,
                        tx as f32,
                        ty as f32 + 1.0,
                        tx as f32,
                        ty as f32,
                        tx - 1,
                        ty,
                    );
                    render_side(
                        walls,
                        tx as f32 + 1.0,
                        ty as f32,
                        tx as f32 + 1.0,
                        ty as f32 + 1.0,
                        tx + 1,
                        ty,
                    );
                }
            }
            if let Some(roof_tex) = ceil_tex {
                let roof_bottom = ceiling_plane;
                let roof_thickness = lowered
                    .map(|c| c.depth_offset)
                    .unwrap_or(0.25)
                    .clamp(0.05, 0.5);
                let roof_top = roof_bottom - roof_thickness;
                let roof_side_light = floor_light;
                let neighbour_roof_thickness = |nx: i32, ny: i32| -> Option<f32> {
                    if nx < 0 || ny < 0 || nx >= map_w || ny >= map_h {
                        return None;
                    }
                    ceiling_texture_at(nx as u32, ny as u32).map(|_| {
                        lowered_floor_at(nx as u32, ny as u32)
                            .map(|c| c.depth_offset)
                            .unwrap_or(0.25)
                            .clamp(0.05, 0.5)
                    })
                };
                let render_roof_side = |walls: &mut Vec<WallQuad>,
                                        ax: f32,
                                        ay: f32,
                                        bx: f32,
                                        by: f32,
                                        nx: i32,
                                        ny: i32| {
                    let should_render = match neighbour_roof_thickness(nx, ny) {
                        None => true,
                        Some(t) => t + 1e-4 < roof_thickness,
                    };
                    if should_render {
                        let ca = camera_depth(ax, ay, px, py, cos_a, sin_a);
                        let cb = camera_depth(bx, by, px, py, cos_a, sin_a);
                        if ca <= FLOOR_NEAR || cb <= FLOOR_NEAR {
                            return;
                        }
                        let pta = project_horizontal_plane(
                            ax, ay, px, py, cos_a, sin_a, proj_dist, sw, horizon, roof_top,
                        );
                        let ptb = project_horizontal_plane(
                            bx, by, px, py, cos_a, sin_a, proj_dist, sw, horizon, roof_top,
                        );
                        let pba = project_horizontal_plane(
                            ax,
                            ay,
                            px,
                            py,
                            cos_a,
                            sin_a,
                            proj_dist,
                            sw,
                            horizon,
                            roof_bottom,
                        );
                        let pbb = project_horizontal_plane(
                            bx,
                            by,
                            px,
                            py,
                            cos_a,
                            sin_a,
                            proj_dist,
                            sw,
                            horizon,
                            roof_bottom,
                        );
                        walls.push(WallQuad {
                            corners: [
                                Vec2::new(pta.0, pta.1),
                                Vec2::new(ptb.0, ptb.1),
                                Vec2::new(pbb.0, pbb.1),
                                Vec2::new(pba.0, pba.1),
                            ],
                            uvs: material_uvs(
                                rect_uvs(),
                                ceiling_material.as_ref(),
                                params.time_seconds,
                            ),
                            texture_key: material_texture(
                                ceiling_material.as_ref(),
                                Some(roof_tex),
                            ),
                            light: tint_light(roof_side_light, ceiling_material.as_ref()),
                            depth: (dist - 0.02).max(0.0),
                            corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                            cell_value: 0,
                            level_index,
                            material: ceiling_material.clone(),
                        });
                    }
                };
                render_roof_side(
                    walls,
                    tx as f32,
                    ty as f32,
                    tx as f32 + 1.0,
                    ty as f32,
                    tx,
                    ty - 1,
                );
                render_roof_side(
                    walls,
                    tx as f32 + 1.0,
                    ty as f32 + 1.0,
                    tx as f32,
                    ty as f32 + 1.0,
                    tx,
                    ty + 1,
                );
                render_roof_side(
                    walls,
                    tx as f32,
                    ty as f32 + 1.0,
                    tx as f32,
                    ty as f32,
                    tx - 1,
                    ty,
                );
                render_roof_side(
                    walls,
                    tx as f32 + 1.0,
                    ty as f32,
                    tx as f32 + 1.0,
                    ty as f32 + 1.0,
                    tx + 1,
                    ty,
                );
            }
        }
    }
}

#[allow(clippy::too_many_arguments)]
fn push_feature_face_segment(
    walls: &mut Vec<WallQuad>,
    level_index: usize,
    params: &SceneBuildParams,
    lights: &[PointLight],
    wall_at: &dyn Fn(i32, i32) -> bool,
    wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
    wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
    roofed_at: &dyn Fn(u32, u32) -> bool,
    lighting_cache: &mut LightingSampleCache,
    proj_dist: f32,
    horizon: f32,
    floor_plane: f32,
    px: f32,
    py: f32,
    cos_a: f32,
    sin_a: f32,
    map_w: i32,
    map_h: i32,
    max_distance: f32,
    ax: f32,
    ay: f32,
    bx: f32,
    by: f32,
    cell_value: u32,
    face_cx: f32,
    face_cy: f32,
    top_height: f32,
    bottom_height: f32,
    alpha: f32,
) {
    let ca = camera_depth(ax, ay, px, py, cos_a, sin_a);
    let cb = camera_depth(bx, by, px, py, cos_a, sin_a);
    if ca <= FLOOR_NEAR || cb <= FLOOR_NEAR {
        return;
    }
    let depth = ((face_cx - px).powi(2) + (face_cy - py).powi(2)).sqrt();
    if depth > max_distance + 2.0 {
        return;
    }
    let gx = face_cx.floor().clamp(0.0, (map_w - 1) as f32) as u32;
    let gy = face_cy.floor().clamp(0.0, (map_h - 1) as f32) as u32;
    let roofed_here = roofed_at(gx, gy);
    let light_rgb = lighting_cache.sample(
        level_index,
        face_cx,
        face_cy,
        roofed_here,
        params,
        lights,
        wall_at,
    );
    let mut wall_color = lit_surface_color(&Color::WHITE, light_rgb, 1.0);
    wall_color.a *= alpha.clamp(0.0, 1.0);
    let material = wall_material(cell_value);
    let top_plane = floor_plane - top_height.clamp(0.0, 1.0);
    let bottom_plane = floor_plane - bottom_height.clamp(0.0, 1.0);
    let pta = project_horizontal_plane(
        ax,
        ay,
        px,
        py,
        cos_a,
        sin_a,
        proj_dist,
        params.screen_width,
        horizon,
        top_plane,
    );
    let ptb = project_horizontal_plane(
        bx,
        by,
        px,
        py,
        cos_a,
        sin_a,
        proj_dist,
        params.screen_width,
        horizon,
        top_plane,
    );
    let pba = project_horizontal_plane(
        ax,
        ay,
        px,
        py,
        cos_a,
        sin_a,
        proj_dist,
        params.screen_width,
        horizon,
        bottom_plane,
    );
    let pbb = project_horizontal_plane(
        bx,
        by,
        px,
        py,
        cos_a,
        sin_a,
        proj_dist,
        params.screen_width,
        horizon,
        bottom_plane,
    );
    walls.push(WallQuad {
        corners: [
            Vec2::new(pta.0, pta.1),
            Vec2::new(ptb.0, ptb.1),
            Vec2::new(pbb.0, pbb.1),
            Vec2::new(pba.0, pba.1),
        ],
        uvs: material_uvs(rect_uvs(), material.as_ref(), params.time_seconds),
        texture_key: material_texture(material.as_ref(), wall_texture(cell_value)),
        light: tint_light(color_to_light(&wall_color), material.as_ref()),
        depth,
        corner_w: [pta.2, ptb.2, pbb.2, pba.2],
        cell_value,
        level_index,
        material,
    });
}

/// Emit `WallQuad` entries for each visible solid-cell face and its optional roof geometry.
#[allow(clippy::too_many_arguments)]
fn build_wall_faces(
    raycaster: &Raycaster2D,
    level_index: usize,
    params: &SceneBuildParams,
    proj_dist: f32,
    planes: VerticalPlanes,
    lights: &[PointLight],
    wall_at: &dyn Fn(i32, i32) -> bool,
    wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
    wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
    wall_feature_at: &dyn Fn(u32, u32) -> Option<WallFeature>,
    ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
    ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
    ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
    roofed_at: &dyn Fn(u32, u32) -> bool,
    lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    lighting_cache: &mut LightingSampleCache,
    walls: &mut Vec<WallQuad>,
) {
    let horizon = params.screen_height * 0.5 - params.horizon_offset;
    let floor_plane = planes.floor_plane;
    let ceiling_plane = planes.ceiling_plane;
    let cos_a = params.player_angle.cos();
    let sin_a = params.player_angle.sin();
    let px = params.player_x;
    let py = params.player_y;
    let sw = params.screen_width;
    let md = params.max_distance;
    let map_w = raycaster.width() as i32;
    let map_h = raycaster.height() as i32;
    let vx0 = ((px - md - 2.0).floor() as i32).max(0);
    let vy0 = ((py - md - 2.0).floor() as i32).max(0);
    let vx1 = ((px + md + 2.0).ceil() as i32).min(map_w);
    let vy1 = ((py + md + 2.0).ceil() as i32).min(map_h);
    let proj_w = (vx1 - vx0 + 1).max(0) as usize;
    let proj_h = (vy1 - vy0 + 1).max(0) as usize;
    let mut proj: Vec<ProjectedGroundPoint> = Vec::with_capacity(proj_w * proj_h);
    let proj_idx =
        |gx: i32, gy: i32| -> usize { ((gy - vy0) as usize) * proj_w + (gx - vx0) as usize };
    for gy in vy0..=vy1 {
        for gx in vx0..=vx1 {
            proj.push(project_ground_point(
                gx as f32,
                gy as f32,
                px,
                py,
                cos_a,
                sin_a,
                proj_dist,
                sw,
                horizon,
                floor_plane,
                ceiling_plane,
            ));
        }
    }
    let maybe_face = |ax: i32,
                      ay: i32,
                      bx: i32,
                      by: i32,
                      cell_value: u32,
                      face_cx: f32,
                      face_cy: f32,
                      lighting_cache: &mut LightingSampleCache|
     -> Option<WallQuad> {
        if ax < vx0
            || ay < vy0
            || bx < vx0
            || by < vy0
            || ax > vx1
            || ay > vy1
            || bx > vx1
            || by > vy1
        {
            return None;
        }
        let ca = camera_depth(ax as f32, ay as f32, px, py, cos_a, sin_a);
        let cb = camera_depth(bx as f32, by as f32, px, py, cos_a, sin_a);
        if ca <= FLOOR_NEAR || cb <= FLOOR_NEAR {
            return None;
        }
        let pa = proj[proj_idx(ax, ay)];
        let pb = proj[proj_idx(bx, by)];
        let dx = face_cx - px;
        let dy = face_cy - py;
        let depth = (dx * dx + dy * dy).sqrt();
        if depth > md + 2.0 {
            return None;
        }
        let gx = face_cx.floor().clamp(0.0, (map_w - 1) as f32) as u32;
        let gy = face_cy.floor().clamp(0.0, (map_h - 1) as f32) as u32;
        let roofed_here = roofed_at(gx, gy);
        let light_rgb = lighting_cache.sample(
            level_index,
            face_cx,
            face_cy,
            roofed_here,
            params,
            lights,
            wall_at,
        );
        let wall_color = lit_surface_color(&Color::WHITE, light_rgb, 1.0);
        let material = wall_material(cell_value);
        Some(WallQuad {
            corners: [
                Vec2::new(pa.sx, pa.ceil_y),
                Vec2::new(pb.sx, pb.ceil_y),
                Vec2::new(pb.sx, pb.floor_y),
                Vec2::new(pa.sx, pa.floor_y),
            ],
            uvs: material_uvs(rect_uvs(), material.as_ref(), params.time_seconds),
            texture_key: material_texture(material.as_ref(), wall_texture(cell_value)),
            light: tint_light(color_to_light(&wall_color), material.as_ref()),
            depth,
            corner_w: [pa.cx, pb.cx, pb.cx, pa.cx],
            cell_value,
            level_index,
            material,
        })
    };
    for ty in 0..map_h {
        for tx in 0..map_w {
            let cell_value = raycaster.get_cell(tx as u32, ty as u32);
            if cell_value == 0 {
                continue;
            }
            let center_x = tx as f32 + 0.5;
            let center_y = ty as f32 + 0.5;
            let dx = center_x - px;
            let dy = center_y - py;
            if (dx * dx + dy * dy).sqrt() > md + 2.0 {
                continue;
            }
            if let Some(feature) = wall_feature_at(tx as u32, ty as u32) {
                match feature.kind {
                    WallFeatureKind::HalfHeight { height } => {
                        if ty == 0 || !wall_at(tx, ty - 1) {
                            push_feature_face_segment(
                                walls,
                                level_index,
                                params,
                                lights,
                                wall_at,
                                wall_texture,
                                wall_material,
                                roofed_at,
                                lighting_cache,
                                proj_dist,
                                horizon,
                                floor_plane,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                map_w,
                                map_h,
                                md,
                                tx as f32,
                                ty as f32,
                                tx as f32 + 1.0,
                                ty as f32,
                                cell_value,
                                center_x,
                                ty as f32,
                                height,
                                0.0,
                                feature.alpha(),
                            );
                        }
                        if ty == map_h - 1 || !wall_at(tx, ty + 1) {
                            push_feature_face_segment(
                                walls,
                                level_index,
                                params,
                                lights,
                                wall_at,
                                wall_texture,
                                wall_material,
                                roofed_at,
                                lighting_cache,
                                proj_dist,
                                horizon,
                                floor_plane,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                map_w,
                                map_h,
                                md,
                                tx as f32 + 1.0,
                                ty as f32 + 1.0,
                                tx as f32,
                                ty as f32 + 1.0,
                                cell_value,
                                center_x,
                                ty as f32 + 1.0,
                                height,
                                0.0,
                                feature.alpha(),
                            );
                        }
                        if tx == 0 || !wall_at(tx - 1, ty) {
                            push_feature_face_segment(
                                walls,
                                level_index,
                                params,
                                lights,
                                wall_at,
                                wall_texture,
                                wall_material,
                                roofed_at,
                                lighting_cache,
                                proj_dist,
                                horizon,
                                floor_plane,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                map_w,
                                map_h,
                                md,
                                tx as f32,
                                ty as f32 + 1.0,
                                tx as f32,
                                ty as f32,
                                cell_value,
                                tx as f32,
                                center_y,
                                height,
                                0.0,
                                feature.alpha(),
                            );
                        }
                        if tx == map_w - 1 || !wall_at(tx + 1, ty) {
                            push_feature_face_segment(
                                walls,
                                level_index,
                                params,
                                lights,
                                wall_at,
                                wall_texture,
                                wall_material,
                                roofed_at,
                                lighting_cache,
                                proj_dist,
                                horizon,
                                floor_plane,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                map_w,
                                map_h,
                                md,
                                tx as f32 + 1.0,
                                ty as f32,
                                tx as f32 + 1.0,
                                ty as f32 + 1.0,
                                cell_value,
                                tx as f32 + 1.0,
                                center_y,
                                height,
                                0.0,
                                feature.alpha(),
                            );
                        }
                        continue;
                    }
                    WallFeatureKind::Window {
                        sill_height,
                        lintel_height,
                    } => {
                        let mut emit_window_spans =
                            |ax: f32, ay: f32, bx: f32, by: f32, face_cx: f32, face_cy: f32| {
                                push_feature_face_segment(
                                    walls,
                                    level_index,
                                    params,
                                    lights,
                                    wall_at,
                                    wall_texture,
                                    wall_material,
                                    roofed_at,
                                    lighting_cache,
                                    proj_dist,
                                    horizon,
                                    floor_plane,
                                    px,
                                    py,
                                    cos_a,
                                    sin_a,
                                    map_w,
                                    map_h,
                                    md,
                                    ax,
                                    ay,
                                    bx,
                                    by,
                                    cell_value,
                                    face_cx,
                                    face_cy,
                                    sill_height,
                                    0.0,
                                    feature.alpha(),
                                );
                                push_feature_face_segment(
                                    walls,
                                    level_index,
                                    params,
                                    lights,
                                    wall_at,
                                    wall_texture,
                                    wall_material,
                                    roofed_at,
                                    lighting_cache,
                                    proj_dist,
                                    horizon,
                                    floor_plane,
                                    px,
                                    py,
                                    cos_a,
                                    sin_a,
                                    map_w,
                                    map_h,
                                    md,
                                    ax,
                                    ay,
                                    bx,
                                    by,
                                    cell_value,
                                    face_cx,
                                    face_cy,
                                    1.0,
                                    lintel_height,
                                    feature.alpha(),
                                );
                            };
                        if ty == 0 || !wall_at(tx, ty - 1) {
                            emit_window_spans(
                                tx as f32,
                                ty as f32,
                                tx as f32 + 1.0,
                                ty as f32,
                                center_x,
                                ty as f32,
                            );
                        }
                        if ty == map_h - 1 || !wall_at(tx, ty + 1) {
                            emit_window_spans(
                                tx as f32 + 1.0,
                                ty as f32 + 1.0,
                                tx as f32,
                                ty as f32 + 1.0,
                                center_x,
                                ty as f32 + 1.0,
                            );
                        }
                        if tx == 0 || !wall_at(tx - 1, ty) {
                            emit_window_spans(
                                tx as f32,
                                ty as f32 + 1.0,
                                tx as f32,
                                ty as f32,
                                tx as f32,
                                center_y,
                            );
                        }
                        if tx == map_w - 1 || !wall_at(tx + 1, ty) {
                            emit_window_spans(
                                tx as f32 + 1.0,
                                ty as f32,
                                tx as f32 + 1.0,
                                ty as f32 + 1.0,
                                tx as f32 + 1.0,
                                center_y,
                            );
                        }
                        continue;
                    }
                    WallFeatureKind::Door {
                        direction,
                        open_amount,
                    } => {
                        let span = (1.0 - open_amount.clamp(0.0, 1.0)).max(0.02);
                        match direction {
                            crate::raycaster::doors::DoorDirection::Horizontal => {
                                push_feature_face_segment(
                                    walls,
                                    level_index,
                                    params,
                                    lights,
                                    wall_at,
                                    wall_texture,
                                    wall_material,
                                    roofed_at,
                                    lighting_cache,
                                    proj_dist,
                                    horizon,
                                    floor_plane,
                                    px,
                                    py,
                                    cos_a,
                                    sin_a,
                                    map_w,
                                    map_h,
                                    md,
                                    tx as f32 + open_amount.clamp(0.0, 0.98),
                                    ty as f32 + 0.5,
                                    tx as f32 + open_amount.clamp(0.0, 0.98) + span,
                                    ty as f32 + 0.5,
                                    cell_value,
                                    tx as f32 + 0.5,
                                    ty as f32 + 0.5,
                                    1.0,
                                    0.0,
                                    feature.alpha(),
                                );
                            }
                            crate::raycaster::doors::DoorDirection::Vertical => {
                                push_feature_face_segment(
                                    walls,
                                    level_index,
                                    params,
                                    lights,
                                    wall_at,
                                    wall_texture,
                                    wall_material,
                                    roofed_at,
                                    lighting_cache,
                                    proj_dist,
                                    horizon,
                                    floor_plane,
                                    px,
                                    py,
                                    cos_a,
                                    sin_a,
                                    map_w,
                                    map_h,
                                    md,
                                    tx as f32 + 0.5,
                                    ty as f32 + open_amount.clamp(0.0, 0.98),
                                    tx as f32 + 0.5,
                                    ty as f32 + open_amount.clamp(0.0, 0.98) + span,
                                    cell_value,
                                    tx as f32 + 0.5,
                                    ty as f32 + 0.5,
                                    1.0,
                                    0.0,
                                    feature.alpha(),
                                );
                            }
                        }
                        continue;
                    }
                }
            }
            if ty == 0 || raycaster.get_cell(tx as u32, (ty - 1) as u32) == 0 {
                if let Some(face) = maybe_face(
                    tx,
                    ty,
                    tx + 1,
                    ty,
                    cell_value,
                    center_x,
                    ty as f32,
                    lighting_cache,
                ) {
                    walls.push(face);
                }
            }
            if ty == map_h - 1 || raycaster.get_cell(tx as u32, (ty + 1) as u32) == 0 {
                if let Some(face) = maybe_face(
                    tx + 1,
                    ty + 1,
                    tx,
                    ty + 1,
                    cell_value,
                    center_x,
                    ty as f32 + 1.0,
                    lighting_cache,
                ) {
                    walls.push(face);
                }
            }
            if tx == 0 || raycaster.get_cell((tx - 1) as u32, ty as u32) == 0 {
                if let Some(face) = maybe_face(
                    tx,
                    ty + 1,
                    tx,
                    ty,
                    cell_value,
                    tx as f32,
                    center_y,
                    lighting_cache,
                ) {
                    walls.push(face);
                }
            }
            if tx == map_w - 1 || raycaster.get_cell((tx + 1) as u32, ty as u32) == 0 {
                if let Some(face) = maybe_face(
                    tx + 1,
                    ty,
                    tx + 1,
                    ty + 1,
                    cell_value,
                    tx as f32 + 1.0,
                    center_y,
                    lighting_cache,
                ) {
                    walls.push(face);
                }
            }
            let ceiling_visible = ceiling_visible_at(tx as u32, ty as u32);
            if let Some(roof_tex) = if ceiling_visible {
                ceiling_texture_at(tx as u32, ty as u32)
            } else {
                None
            } {
                let ceiling_material = ceiling_material_at(tx as u32, ty as u32);
                let roof_thickness = lowered_floor_at(tx as u32, ty as u32)
                    .map(|c| c.depth_offset)
                    .unwrap_or(0.25)
                    .clamp(0.05, 0.5);
                let roof_bottom = ceiling_plane;
                let roof_top = roof_bottom - roof_thickness;
                {
                    let roofed_here = roofed_at(tx as u32, ty as u32);
                    let light_rgb = lighting_cache.sample(
                        level_index,
                        center_x,
                        center_y,
                        roofed_here,
                        params,
                        lights,
                        wall_at,
                    );
                    let roof_light =
                        color_to_light(&lit_surface_color(&Color::WHITE, light_rgb, 1.0));
                    let neigh_roof = |nx: i32, ny: i32| -> Option<f32> {
                        if nx < 0 || ny < 0 || nx >= map_w || ny >= map_h {
                            return None;
                        }
                        if !ceiling_visible_at(nx as u32, ny as u32) {
                            return None;
                        }
                        ceiling_texture_at(nx as u32, ny as u32).map(|_| {
                            lowered_floor_at(nx as u32, ny as u32)
                                .map(|c| c.depth_offset)
                                .unwrap_or(0.25)
                                .clamp(0.05, 0.5)
                        })
                    };
                    let mut render_roof_side =
                        |ax: f32, ay: f32, bx: f32, by: f32, nx: i32, ny: i32| {
                            let should_render = match neigh_roof(nx, ny) {
                                None => true,
                                Some(t) => t + 1e-4 < roof_thickness,
                            };
                            if !should_render {
                                return;
                            }
                            let ca = camera_depth(ax, ay, px, py, cos_a, sin_a);
                            let cb = camera_depth(bx, by, px, py, cos_a, sin_a);
                            if ca <= FLOOR_NEAR || cb <= FLOOR_NEAR {
                                return;
                            }
                            let pta = project_horizontal_plane(
                                ax, ay, px, py, cos_a, sin_a, proj_dist, sw, horizon, roof_top,
                            );
                            let ptb = project_horizontal_plane(
                                bx, by, px, py, cos_a, sin_a, proj_dist, sw, horizon, roof_top,
                            );
                            let pba = project_horizontal_plane(
                                ax,
                                ay,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                proj_dist,
                                sw,
                                horizon,
                                roof_bottom,
                            );
                            let pbb = project_horizontal_plane(
                                bx,
                                by,
                                px,
                                py,
                                cos_a,
                                sin_a,
                                proj_dist,
                                sw,
                                horizon,
                                roof_bottom,
                            );
                            walls.push(WallQuad {
                                corners: [
                                    Vec2::new(pta.0, pta.1),
                                    Vec2::new(ptb.0, ptb.1),
                                    Vec2::new(pbb.0, pbb.1),
                                    Vec2::new(pba.0, pba.1),
                                ],
                                uvs: material_uvs(
                                    rect_uvs(),
                                    ceiling_material.as_ref(),
                                    params.time_seconds,
                                ),
                                texture_key: material_texture(
                                    ceiling_material.as_ref(),
                                    Some(roof_tex),
                                ),
                                light: tint_light(roof_light, ceiling_material.as_ref()),
                                depth: ((dx * dx + dy * dy).sqrt() - 0.02).max(0.0),
                                corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                                cell_value: 0,
                                level_index,
                                material: ceiling_material.clone(),
                            });
                        };
                    render_roof_side(tx as f32, ty as f32, tx as f32 + 1.0, ty as f32, tx, ty - 1);
                    render_roof_side(
                        tx as f32 + 1.0,
                        ty as f32 + 1.0,
                        tx as f32,
                        ty as f32 + 1.0,
                        tx,
                        ty + 1,
                    );
                    render_roof_side(tx as f32, ty as f32 + 1.0, tx as f32, ty as f32, tx - 1, ty);
                    render_roof_side(
                        tx as f32 + 1.0,
                        ty as f32,
                        tx as f32 + 1.0,
                        ty as f32 + 1.0,
                        tx + 1,
                        ty,
                    );
                }
            }
        }
    }
}
/// Multiply `base` color by `light_rgb` and `shade`; preserve alpha.
fn lit_surface_color(base: &Color, light_rgb: [f32; 3], shade: f32) -> Color {
    Color::new(
        base.r * light_rgb[0] * shade,
        base.g * light_rgb[1] * shade,
        base.b * light_rgb[2] * shade,
        base.a,
    )
}
/// Convert a `Color` to a `[r, g, b, a]` f32 array used as a light multiplier.
fn color_to_light(c: &Color) -> [f32; 4] {
    [c.r, c.g, c.b, c.a]
}
/// All camera and world parameters consumed by `RaycasterScene::build` each frame.
#[derive(Debug, Clone)]
pub struct SceneBuildParams {
    /// Player world X position.
    pub player_x: f32,
    /// Player world Y position.
    pub player_y: f32,
    /// Player view angle in radians.
    pub player_angle: f32,
    /// Horizontal field of view in radians.
    pub fov: f32,
    /// Number of DDA rays cast across the screen width.
    pub ray_count: u32,
    /// Maximum tile distance at which geometry is rendered.
    pub max_distance: f32,
    /// Render target width in pixels.
    pub screen_width: f32,
    /// Render target height in pixels.
    pub screen_height: f32,
    /// Base ambient light level, 0.0..1.0.
    pub ambient_light: f32,
    /// Global day/night or sun-light tint applied after local lighting.
    pub global_light_color: Color,
    /// Scalar multiplier applied to `global_light_color`.
    pub global_light_intensity: f32,
    /// Optional world-space direction from the lit sample toward the sun source, in radians.
    pub sun_angle: Option<f32>,
    /// Fraction of ambient light that survives under a roof or ceiling texture.
    pub roofed_ambient_factor: f32,
    /// Distance at which walls are fully dark; controls distance-shading fall-off.
    pub shade_distance: f32,
    /// Flat tint color for untextured floor surfaces.
    pub floor_color: Color,
    /// Flat tint color for untextured ceiling surfaces.
    pub ceiling_color: Color,
    /// Camera eye height as a fraction of cell height, 0.1..0.9.
    pub camera_height: f32,
    /// Vertical offset applied to the horizon line in pixels (positive = up).
    pub horizon_offset: f32,
    /// Optional scene background drawn behind first-person geometry.
    pub background: Option<RaycasterBackground>,
    /// Optional full-frame overlay effects drawn after first-person geometry.
    pub overlays: Vec<RaycasterOverlayEffect>,
    /// Deterministic time source used for animated UVs and projected particle simulation.
    pub time_seconds: f32,
}

impl SceneBuildParams {
    /// Validate scene-build parameters against shared raycaster limits.
    pub fn validate(&self, limits: &RaycasterLimits) -> Result<(), RaycasterError> {
        limits.validate_finite("player_x", self.player_x)?;
        limits.validate_finite("player_y", self.player_y)?;
        limits.validate_finite("player_angle", self.player_angle)?;
        limits.validate_fov(self.fov)?;
        limits.validate_max_distance(self.max_distance)?;
        limits.validate_screen_dimensions(self.screen_width, self.screen_height)?;
        if self.ray_count == 0 || self.ray_count > limits.max_rays {
            return Err(RaycasterError::InvalidRayCount {
                count: self.ray_count,
                max: limits.max_rays,
            });
        }
        limits.validate_finite("horizon_offset", self.horizon_offset)?;
        limits.validate_finite("time_seconds", self.time_seconds)?;
        if let Some(sun_angle) = self.sun_angle {
            limits.validate_finite("sun_angle", sun_angle)?;
        }
        Ok(())
    }
}

fn material_texture(
    material: Option<&RaycasterMaterial>,
    fallback: Option<TextureKey>,
) -> Option<TextureKey> {
    material
        .and_then(|material| material.texture_key)
        .or(fallback)
}

fn tint_light(mut light: [f32; 4], material: Option<&RaycasterMaterial>) -> [f32; 4] {
    if let Some(material) = material {
        for (value, tint) in light.iter_mut().zip(material.tint) {
            *value *= tint;
        }
    }
    light
}

fn material_uvs(
    base_uvs: [Vec2; 4],
    material: Option<&RaycasterMaterial>,
    time_seconds: f32,
) -> [Vec2; 4] {
    let Some(material) = material else {
        return base_uvs;
    };
    let frame_count = material.frame_count.max(1);
    let animated = if frame_count > 1 && material.frame_rate > 0.0 {
        ((time_seconds.max(0.0) * material.frame_rate).floor() as u32) % frame_count
    } else {
        0
    };
    base_uvs.map(|uv| {
        let mut u = frac01(
            uv.x * material.uv_scale[0]
                + material.uv_offset[0]
                + material.uv_scroll[0] * time_seconds,
        );
        let mut v = frac01(
            uv.y * material.uv_scale[1]
                + material.uv_offset[1]
                + material.uv_scroll[1] * time_seconds,
        );
        if frame_count > 1 {
            let frame_count_f = frame_count as f32;
            match material.frame_layout {
                RaycasterMaterialFrameLayout::Horizontal => {
                    u = (u + animated as f32) / frame_count_f;
                }
                RaycasterMaterialFrameLayout::Vertical => {
                    v = (v + animated as f32) / frame_count_f;
                }
            }
        }
        Vec2::new(u, v)
    })
}

fn normalize_signed_angle(mut angle: f32) -> f32 {
    while angle > std::f32::consts::PI {
        angle -= 2.0 * std::f32::consts::PI;
    }
    while angle < -std::f32::consts::PI {
        angle += 2.0 * std::f32::consts::PI;
    }
    angle
}

/// Optional 4-direction texture set for bitmap actors that should read as front/side/back sprites.
#[derive(Debug, Clone, Copy)]
pub struct DirectionalSpriteTextures {
    /// Texture shown when the camera sees the sprite from the front.
    pub front: TextureKey,
    /// Texture shown when the camera sees the sprite's right side.
    pub right: TextureKey,
    /// Texture shown when the camera sees the sprite from behind.
    pub back: TextureKey,
    /// Texture shown when the camera sees the sprite's left side.
    pub left: TextureKey,
    /// World-space facing angle of the sprite's front, in radians.
    pub facing_angle: f32,
}

impl DirectionalSpriteTextures {
    fn select_texture(
        &self,
        viewer_x: f32,
        viewer_y: f32,
        sprite_x: f32,
        sprite_y: f32,
    ) -> TextureKey {
        let to_viewer = (viewer_y - sprite_y).atan2(viewer_x - sprite_x);
        let relative = normalize_signed_angle(to_viewer - self.facing_angle);
        let quarter_turn = std::f32::consts::FRAC_PI_4;
        let three_quarter_turn = quarter_turn * 3.0;

        if relative.abs() <= quarter_turn {
            self.front
        } else if relative > quarter_turn && relative < three_quarter_turn {
            self.right
        } else if relative < -quarter_turn && relative > -three_quarter_turn {
            self.left
        } else {
            self.back
        }
    }
}
/// A billboard sprite placed in world space and projected to screen by `RaycasterScene::build`.
#[derive(Debug, Clone)]
pub struct WorldSprite {
    /// Optional stable caller-supplied id for this sprite instance.
    pub entity_id: Option<u32>,
    /// Multi-level slice index owning this sprite.
    pub level_index: usize,
    /// World X position of the sprite center.
    pub world_x: f32,
    /// World Y position of the sprite center.
    pub world_y: f32,
    /// Texture used for the billboard quad.
    pub texture_key: TextureKey,
    /// Optional 4-direction texture set selected from the viewer angle.
    pub directional_textures: Option<DirectionalSpriteTextures>,
    /// World-space size of the sprite (height and width are equal).
    pub size: f32,
}

/// A deterministic world-space particle emitter projected into the raycaster view.
#[derive(Debug, Clone)]
pub struct RaycasterParticleEmitter {
    /// Stable caller-assigned emitter id.
    pub emitter_id: u32,
    /// Multi-level slice index that owns this emitter.
    pub level_index: usize,
    /// World X position of the emitter origin.
    pub world_x: f32,
    /// World Y position of the emitter origin.
    pub world_y: f32,
    /// Height above the owning level floor where particles begin.
    pub world_z: f32,
    /// Horizontal spawn radius around the emitter origin.
    pub radius: f32,
    /// Vertical spawn span applied before velocity motion.
    pub height: f32,
    /// Spawn rate in particles per second.
    pub rate: f32,
    /// Minimum and maximum lifetime in seconds.
    pub lifetime_range: [f32; 2],
    /// Base XYZ velocity in world units per second.
    pub velocity: [f32; 3],
    /// Symmetric random XYZ velocity jitter added per particle.
    pub velocity_jitter: [f32; 3],
    /// Minimum and maximum particle size in world units.
    pub size_range: [f32; 2],
    /// RGBA color multiplied into the projected particle.
    pub color: [f32; 4],
    /// Fallback particle shape.
    pub shape: ParticleRenderShape,
    /// Optional texture applied to the particle billboard.
    pub texture_key: Option<TextureKey>,
    /// Optional particle-target shader.
    pub shader_key: Option<ShaderKey>,
    /// Blend mode used while presenting this emitter.
    pub blend_mode: BlendMode,
    /// When true, particles hidden behind nearer wall columns are culled.
    pub occlude_walls: bool,
    /// Deterministic seed driving per-particle jitter.
    pub seed: u32,
}
/// Callback type mapping a wall cell value to an optional `TextureKey`.
pub type TextureLookup = dyn Fn(u32) -> Option<TextureKey>;
/// Callback type mapping a grid `(x, y)` cell to an optional `TextureKey`.
pub type CellTextureLookup = dyn Fn(u32, u32) -> Option<TextureKey>;
impl RaycasterScene {
    #[allow(clippy::too_many_arguments)]
    fn build_level_sprites(
        &mut self,
        raycaster: &Raycaster2D,
        level_index: usize,
        params: &SceneBuildParams,
        lights: &[PointLight],
        wall_at: &dyn Fn(i32, i32) -> bool,
        roofed_at: &dyn Fn(u32, u32) -> bool,
        lighting_cache: &mut LightingSampleCache,
        sprites: &[WorldSprite],
        planes: VerticalPlanes,
    ) {
        let floor_plane = planes.floor_plane;
        for ws in sprites {
            let dx = ws.world_x - params.player_x;
            let dy = ws.world_y - params.player_y;
            let dist = (dx * dx + dy * dy).sqrt();
            if dist < 0.1 || dist > params.max_distance {
                continue;
            }
            let sprite_angle = dy.atan2(dx);
            let angle_diff = normalize_signed_angle(sprite_angle - params.player_angle);
            let half_fov = params.fov / 2.0;
            if angle_diff.abs() > half_fov {
                continue;
            }
            let screen_x_center =
                params.screen_width / 2.0 + (angle_diff / half_fov) * (params.screen_width / 2.0);
            let horizon = params.screen_height * 0.5 - params.horizon_offset;
            let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
            let base = project_horizontal_plane(
                ws.world_x,
                ws.world_y,
                params.player_x,
                params.player_y,
                params.player_angle.cos(),
                params.player_angle.sin(),
                proj_dist,
                params.screen_width,
                horizon,
                floor_plane,
            );
            let top = project_horizontal_plane(
                ws.world_x,
                ws.world_y,
                params.player_x,
                params.player_y,
                params.player_angle.cos(),
                params.player_angle.sin(),
                proj_dist,
                params.screen_width,
                horizon,
                floor_plane - ws.size,
            );
            let (_, base_y, _) = base;
            let (_, top_y, _) = top;
            let projected_size = (base_y - top_y).abs().max(1.0);
            let gx = ws
                .world_x
                .floor()
                .clamp(0.0, (raycaster.width().saturating_sub(1)) as f32)
                as u32;
            let gy = ws
                .world_y
                .floor()
                .clamp(0.0, (raycaster.height().saturating_sub(1)) as f32)
                as u32;
            let roofed_here = roofed_at(gx, gy);
            let sprite_light = lighting_cache.sample(
                level_index,
                ws.world_x,
                ws.world_y,
                roofed_here,
                params,
                lights,
                wall_at,
            );
            let sprite_shade = distance_shade(dist, params.shade_distance);
            let sprite_color = Color::new(
                sprite_shade * sprite_light[0],
                sprite_shade * sprite_light[1],
                sprite_shade * sprite_light[2],
                1.0,
            );
            let texture_key = ws
                .directional_textures
                .as_ref()
                .map(|textures| {
                    textures.select_texture(
                        params.player_x,
                        params.player_y,
                        ws.world_x,
                        ws.world_y,
                    )
                })
                .unwrap_or(ws.texture_key);
            self.sprites.push(BillboardSprite {
                corners: corners_from_rect(
                    screen_x_center - projected_size / 2.0,
                    base_y - projected_size,
                    projected_size,
                    projected_size,
                ),
                uvs: rect_uvs(),
                texture_key,
                light: color_to_light(&sprite_color),
                depth: dist,
                entity_id: ws.entity_id,
                level_index: ws.level_index,
                world_x: ws.world_x,
                world_y: ws.world_y,
            });
        }
    }

    fn build_level_particles(
        &mut self,
        level_index: usize,
        params: &SceneBuildParams,
        emitters: &[RaycasterParticleEmitter],
        planes: VerticalPlanes,
    ) {
        let floor_plane = planes.floor_plane;
        let half_fov = params.fov * 0.5;
        let horizon = params.screen_height * 0.5 - params.horizon_offset;
        let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
        let cos_a = params.player_angle.cos();
        let sin_a = params.player_angle.sin();
        let screen_w = params.screen_width.max(1.0);
        let screen_h = params.screen_height.max(1.0);

        for emitter in emitters {
            if emitter.level_index != level_index {
                continue;
            }
            let rate = emitter.rate.max(0.0);
            if rate <= 0.0 {
                continue;
            }
            let min_lifetime = emitter.lifetime_range[0].max(0.05);
            let max_lifetime = emitter.lifetime_range[1].max(min_lifetime);
            let max_live = (rate * max_lifetime).ceil().clamp(1.0, 192.0) as i32;
            let last_spawn = (params.time_seconds.max(0.0) * rate).floor() as i32;
            let first_spawn = (last_spawn - max_live - 2).max(0);

            for spawn_index in first_spawn..=last_spawn {
                let spawn_time = spawn_index as f32 / rate;
                let age = params.time_seconds - spawn_time;
                if age < 0.0 {
                    continue;
                }

                let seed = hash_u32(
                    emitter.seed
                        ^ emitter.emitter_id.wrapping_mul(0x045d_9f3b)
                        ^ spawn_index as u32,
                );
                let lifetime = min_lifetime + (max_lifetime - min_lifetime) * random01(seed, 0);
                if age > lifetime {
                    continue;
                }
                let normalized_age = (age / lifetime).clamp(0.0, 1.0);
                let spawn_angle = random01(seed, 1) * std::f32::consts::TAU;
                let spawn_radius = emitter.radius.max(0.0) * random01(seed, 2).sqrt();
                let local_x = spawn_angle.cos() * spawn_radius;
                let local_y = spawn_angle.sin() * spawn_radius;
                let local_z = emitter.height.max(0.0) * random01(seed, 3);
                let velocity = [
                    emitter.velocity[0] + emitter.velocity_jitter[0] * random_signed(seed, 4),
                    emitter.velocity[1] + emitter.velocity_jitter[1] * random_signed(seed, 5),
                    emitter.velocity[2] + emitter.velocity_jitter[2] * random_signed(seed, 6),
                ];
                let world_x = emitter.world_x + local_x + velocity[0] * age;
                let world_y = emitter.world_y + local_y + velocity[1] * age;
                let world_z = emitter.world_z + local_z + velocity[2] * age;
                let dx = world_x - params.player_x;
                let dy = world_y - params.player_y;
                let depth = (dx * dx + dy * dy).sqrt();
                if depth < 0.05 || depth > params.max_distance + 1.0 {
                    continue;
                }
                let particle_angle = dy.atan2(dx);
                let angle_diff = normalize_signed_angle(particle_angle - params.player_angle);
                if angle_diff.abs() > half_fov {
                    continue;
                }
                let screen_x = params.screen_width * 0.5
                    + (angle_diff / half_fov) * (params.screen_width * 0.5);
                let sample_x = screen_x.clamp(0.0, screen_w - 1.0);
                if emitter.occlude_walls && !self.depth_columns.is_empty() {
                    let depth_index = ((sample_x / screen_w) * self.depth_columns.len() as f32)
                        .floor()
                        .clamp(0.0, self.depth_columns.len().saturating_sub(1) as f32)
                        as usize;
                    if depth > self.depth_columns[depth_index] + 0.05 {
                        continue;
                    }
                }
                let size_world = (emitter.size_range[0]
                    + (emitter.size_range[1] - emitter.size_range[0]) * random01(seed, 7))
                .max(0.05);
                let (_, base_y, _) = project_horizontal_plane(
                    world_x,
                    world_y,
                    params.player_x,
                    params.player_y,
                    cos_a,
                    sin_a,
                    proj_dist,
                    params.screen_width,
                    horizon,
                    floor_plane - world_z,
                );
                let (_, top_y, _) = project_horizontal_plane(
                    world_x,
                    world_y,
                    params.player_x,
                    params.player_y,
                    cos_a,
                    sin_a,
                    proj_dist,
                    params.screen_width,
                    horizon,
                    floor_plane - (world_z + size_world),
                );
                let projected_size = (base_y - top_y).abs().max(1.0);
                let screen_y = base_y - projected_size * 0.5;
                if screen_x + projected_size < 0.0
                    || screen_x - projected_size > params.screen_width
                    || screen_y + projected_size < 0.0
                    || screen_y - projected_size > screen_h
                {
                    continue;
                }

                let mut color = emitter.color;
                color[3] *= 1.0 - normalized_age;
                if color[3] <= 0.01 {
                    continue;
                }
                let rotation = match emitter.shape {
                    ParticleRenderShape::Spark | ParticleRenderShape::Ray { .. } => {
                        velocity[1].atan2(velocity[0])
                    }
                    _ => random01(seed, 8) * std::f32::consts::TAU + normalized_age * 1.5,
                };
                self.particles.push(RaycasterParticle {
                    x: screen_x,
                    y: screen_y,
                    rotation,
                    size: projected_size,
                    color,
                    shape: emitter.shape.clone(),
                    texture_key: emitter.texture_key,
                    quad: None,
                    quad_tex_dims: None,
                    local_x,
                    local_y,
                    velocity_x: velocity[0],
                    velocity_y: velocity[1],
                    normalized_age,
                    lifetime,
                    seed,
                    depth,
                    shader_key: emitter.shader_key,
                    blend_mode: emitter.blend_mode,
                    level_index,
                    emitter_id: emitter.emitter_id,
                });
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn build_scene_into(
        &mut self,
        raycaster: &Raycaster2D,
        level_index: usize,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        particle_emitters: &[RaycasterParticleEmitter],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
        wall_feature_at: &dyn Fn(u32, u32) -> Option<WallFeature>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        floor_visible_at: &dyn Fn(u32, u32) -> bool,
        ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
        roofed_at: &dyn Fn(u32, u32) -> bool,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
        lighting_cache: &mut LightingSampleCache,
        planes: VerticalPlanes,
    ) {
        let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
        let wall_at = |x: i32, y: i32| -> bool {
            x < 0 || y < 0 || raycaster.blocks_render_light_at(x as u32, y as u32)
        };
        build_floor_tiles(
            raycaster,
            level_index,
            params,
            proj_dist,
            planes,
            lights,
            &wall_at,
            floor_texture_at,
            ceiling_texture_at,
            floor_material_at,
            ceiling_material_at,
            floor_visible_at,
            ceiling_visible_at,
            roofed_at,
            lowered_floor_at,
            lighting_cache,
            &mut self.walls,
            &mut self.floors,
            &mut self.ceilings,
        );
        build_wall_faces(
            raycaster,
            level_index,
            params,
            proj_dist,
            planes,
            lights,
            &wall_at,
            wall_texture,
            wall_material,
            wall_feature_at,
            ceiling_texture_at,
            ceiling_material_at,
            ceiling_visible_at,
            roofed_at,
            lowered_floor_at,
            lighting_cache,
            &mut self.walls,
        );
        self.build_level_sprites(
            raycaster,
            level_index,
            params,
            lights,
            &wall_at,
            roofed_at,
            lighting_cache,
            sprites,
            planes,
        );
        self.build_level_particles(level_index, params, particle_emitters, planes);
    }

    /// Build a complete `RaycasterScene` from camera params, lights, sprites, and texture lookups.
    #[allow(clippy::too_many_arguments)]
    pub fn build_with_scene_features(
        raycaster: &Raycaster2D,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        particle_emitters: &[RaycasterParticleEmitter],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        scene.background = params.background.clone();
        scene.overlays = params.overlays.clone();
        scene.time_seconds = params.time_seconds;
        let limits = RaycasterLimits::default();
        if params.validate(&limits).is_err()
            || limits
                .validate_scene_counts(sprites.len(), 0, lights.len())
                .is_err()
        {
            return scene;
        }
        scene.depth_columns = build_depth_columns(raycaster, params);
        let mut lighting_cache = LightingSampleCache::default();
        scene.build_scene_into(
            raycaster,
            0,
            params,
            lights,
            sprites,
            particle_emitters,
            wall_texture,
            wall_material,
            &|x, y| raycaster.wall_feature(x, y),
            floor_texture_at,
            ceiling_texture_at,
            floor_material_at,
            ceiling_material_at,
            &|_, _| true,
            &|_, _| true,
            &|x, y| ceiling_texture_at(x, y).is_some(),
            lowered_floor_at,
            &mut lighting_cache,
            vertical_planes(params.camera_height.clamp(0.1, 0.9), 0.0, 1.0),
        );
        scene.sprites.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.particles.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.build_stats = RaycasterBuildStats {
            wall_quads: scene.walls.len(),
            floor_quads: scene.floors.len(),
            ceiling_quads: scene.ceilings.len(),
            sprites: scene.sprites.len(),
            models: scene.models.len(),
            particles: scene.particles.len(),
            visible_levels: 1,
            depth_columns: scene.depth_columns.len(),
            ..lighting_cache.stats()
        };
        scene
    }

    /// Build a complete `RaycasterScene` from camera params, lights, sprites, and texture lookups.
    #[allow(clippy::too_many_arguments)]
    pub fn build(
        raycaster: &Raycaster2D,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        Self::build_with_scene_features(
            raycaster,
            params,
            lights,
            sprites,
            &[],
            wall_texture,
            &|_| None,
            floor_texture_at,
            ceiling_texture_at,
            &|_, _| None,
            &|_, _| None,
            lowered_floor_at,
        )
    }

    /// Build a complete `RaycasterScene` from a stack of raycaster levels sharing one camera.
    #[allow(clippy::too_many_arguments)]
    pub fn build_multilevel_with_scene_features(
        grid: &MultiLevelGrid,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[LevelSprite],
        particle_emitters: &[LevelParticleEmitter],
        wall_texture: &dyn Fn(usize, u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(usize, u32) -> Option<RaycasterMaterial>,
        floor_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(usize, u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(usize, u32, u32) -> Option<RaycasterMaterial>,
        lowered_floor_at: &dyn Fn(usize, u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        scene.background = params.background.clone();
        scene.overlays = params.overlays.clone();
        scene.time_seconds = params.time_seconds;
        let limits = RaycasterLimits::default();
        if params.validate(&limits).is_err()
            || limits
                .validate_scene_counts(sprites.len(), 0, lights.len())
                .is_err()
        {
            return scene;
        }
        let mut lighting_cache = LightingSampleCache::default();
        let eye = params.camera_height.clamp(0.1, 0.9);
        let camera_world_z = grid
            .get_active()
            .map(|level| level.floor_offset + eye)
            .unwrap_or(eye);
        if let Some(active_depth) = grid.with_runtime_level(grid.active_level(), |_, raycaster| {
            build_depth_columns(raycaster, params)
        }) {
            scene.depth_columns = active_depth;
        }
        let level_count = grid.level_count();
        let mut sprites_by_level = vec![Vec::new(); level_count];
        for sprite in sprites {
            if sprite.level_index < level_count {
                sprites_by_level[sprite.level_index].push(sprite.sprite.clone());
            }
        }
        let mut emitters_by_level = vec![Vec::new(); level_count];
        for emitter in particle_emitters {
            if emitter.level_index < level_count {
                emitters_by_level[emitter.level_index].push(emitter.emitter.clone());
            }
        }
        let mut lights_by_level = vec![Vec::new(); level_count];
        for light in lights {
            match light.level_index {
                Some(level_index) if level_index < level_count => {
                    lights_by_level[level_index].push(light.clone());
                }
                Some(_) => {}
                None => {
                    for bucket in &mut lights_by_level {
                        bucket.push(light.clone());
                    }
                }
            }
        }

        let visible_levels =
            grid.visible_level_indices(params.player_x, params.player_y, params.max_distance);
        let visible_level_count = visible_levels.len();
        for level_index in visible_levels {
            let _ = grid.with_runtime_level(level_index, |level, raycaster| {
                scene.build_scene_into(
                    raycaster,
                    level_index,
                    params,
                    &lights_by_level[level_index],
                    &sprites_by_level[level_index],
                    &emitters_by_level[level_index],
                    &|cell_value| wall_texture(level_index, cell_value),
                    &|cell_value| wall_material(level_index, cell_value),
                    &|x, y| raycaster.wall_feature(x, y),
                    &|x, y| {
                        floor_texture_at(level_index, x, y)
                            .or_else(|| level.floor_texture_at(x as usize, y as usize))
                    },
                    &|x, y| {
                        ceiling_texture_at(level_index, x, y)
                            .or_else(|| level.ceiling_texture_at(x as usize, y as usize))
                    },
                    &|x, y| floor_material_at(level_index, x, y),
                    &|x, y| ceiling_material_at(level_index, x, y),
                    &|x, y| !level.is_floor_hole(x as usize, y as usize),
                    &|x, y| !level.is_ceiling_hole(x as usize, y as usize),
                    &|x, y| !level.is_ceiling_hole(x as usize, y as usize),
                    &|x, y| {
                        lowered_floor_at(level_index, x, y)
                            .or_else(|| level.lowered_floor(x as usize, y as usize))
                    },
                    &mut lighting_cache,
                    vertical_planes(camera_world_z, level.floor_offset, level.ceiling_height),
                );
            });
        }

        scene.sprites.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.particles.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.build_stats = RaycasterBuildStats {
            wall_quads: scene.walls.len(),
            floor_quads: scene.floors.len(),
            ceiling_quads: scene.ceilings.len(),
            sprites: scene.sprites.len(),
            models: scene.models.len(),
            particles: scene.particles.len(),
            visible_levels: visible_level_count,
            depth_columns: scene.depth_columns.len(),
            ..lighting_cache.stats()
        };
        scene
    }

    /// Build a complete `RaycasterScene` from a stack of raycaster levels sharing one camera.
    #[allow(clippy::too_many_arguments)]
    pub fn build_multilevel(
        grid: &MultiLevelGrid,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[LevelSprite],
        wall_texture: &dyn Fn(usize, u32) -> Option<TextureKey>,
        floor_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        lowered_floor_at: &dyn Fn(usize, u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        Self::build_multilevel_with_scene_features(
            grid,
            params,
            lights,
            sprites,
            &[],
            wall_texture,
            &|_, _| None,
            floor_texture_at,
            ceiling_texture_at,
            &|_, _, _| None,
            &|_, _, _| None,
            lowered_floor_at,
        )
    }
}
