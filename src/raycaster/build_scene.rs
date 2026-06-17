//! This file assembles the full per-frame raycaster scene from camera state, grid hits, texture routing, and lighting inputs.
//! It turns wall contacts into screen-space quads whose geometry already matches the perspective rules expected by the render stage.
//! Floor and ceiling strips are expanded into textured spans with stable UVs so long corridors and open rooms keep coherent surface motion.
//! Lowered cells become pits with visible bottoms, side faces, and transitions that preserve depth cues instead of flattening into one plane.
//! Roofed regions are darkened differently from open regions so covered space reads denser even before dynamic lights are applied.
//! Point lights, ambient light, and distance falloff are blended here so every emitted surface leaves this file with its final light tint.
//! Billboard sprites are projected into the same camera space as walls, which keeps monsters, props, and pickups aligned with corridor depth.
//! Static meshes can be injected beside billboarded elements without asking later stages to reconstruct world-space context.

use crate::color::Color;
use crate::math::Vec2;
use crate::raycaster::dda::Raycaster2D;
use crate::raycaster::lighting::{apply_global_light, compute_lighting, PointLight};
use crate::raycaster::multilevel::MultiLevelGrid;
use crate::raycaster::projection::distance_shade;
use crate::raycaster::ray_hit::RayHit;
use crate::raycaster::scene::{
    BillboardSprite, CeilingQuad, FloorQuad, RaycasterBuildStats, RaycasterScene, WallQuad,
};
use crate::raycaster::wall_feature::{WallFeature, WallFeatureKind};
use crate::runtime::resource_keys::TextureKey;
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
    /// When true the cell blocks movement even though it has a floor texture.
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
            let floor_tex = lowered.map(|c| c.texture_key).or(base_floor_tex);
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
                    uvs: rect_uvs(),
                    texture_key: floor_tex,
                    light: floor_light,
                    depth: dist,
                    corner_w: [tp0.2, tp1.2, tp2.2, tp3.2],
                });
            }
            if ceiling_visible {
                let ceil_light = if roofed_here {
                    floor_light
                } else {
                    default_ceil_light
                };
                ceilings.push(CeilingQuad {
                    corners: ceil_corners,
                    uvs: rect_uvs(),
                    texture_key: ceil_tex,
                    light: ceil_light,
                    depth: dist,
                    corner_w: [p0.cx, p1.cx, p2.cx, p3.cx],
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
                    let side_tex = base_floor_tex;
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
                                uvs: rect_uvs(),
                                texture_key: side_tex,
                                light: side_color,
                                depth: dist + 0.001,
                                corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                                cell_value: 0,
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
                            uvs: rect_uvs(),
                            texture_key: Some(roof_tex),
                            light: roof_side_light,
                            depth: (dist - 0.02).max(0.0),
                            corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                            cell_value: 0,
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
        uvs: rect_uvs(),
        texture_key: wall_texture(cell_value),
        light: color_to_light(&wall_color),
        depth,
        corner_w: [pta.2, ptb.2, pbb.2, pba.2],
        cell_value,
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
    wall_feature_at: &dyn Fn(u32, u32) -> Option<WallFeature>,
    ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
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
        Some(WallQuad {
            corners: [
                Vec2::new(pa.sx, pa.ceil_y),
                Vec2::new(pb.sx, pb.ceil_y),
                Vec2::new(pb.sx, pb.floor_y),
                Vec2::new(pa.sx, pa.floor_y),
            ],
            uvs: rect_uvs(),
            texture_key: wall_texture(cell_value),
            light: color_to_light(&wall_color),
            depth,
            corner_w: [pa.cx, pb.cx, pb.cx, pa.cx],
            cell_value,
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
                                uvs: rect_uvs(),
                                texture_key: Some(roof_tex),
                                light: roof_light,
                                depth: ((dx * dx + dy * dy).sqrt() - 0.02).max(0.0),
                                corner_w: [pta.2, ptb.2, pbb.2, pba.2],
                                cell_value: 0,
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

    #[allow(clippy::too_many_arguments)]
    fn build_scene_into(
        &mut self,
        raycaster: &Raycaster2D,
        level_index: usize,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        wall_feature_at: &dyn Fn(u32, u32) -> Option<WallFeature>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        floor_visible_at: &dyn Fn(u32, u32) -> bool,
        ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
        roofed_at: &dyn Fn(u32, u32) -> bool,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
        lighting_cache: &mut LightingSampleCache,
        planes: VerticalPlanes,
    ) {
        let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
        let wall_at = |x: i32, y: i32| -> bool {
            x < 0 || y < 0 || raycaster.blocks_light_at(x as u32, y as u32)
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
            wall_feature_at,
            ceiling_texture_at,
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
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        let mut lighting_cache = LightingSampleCache::default();
        scene.build_scene_into(
            raycaster,
            0,
            params,
            lights,
            sprites,
            wall_texture,
            &|x, y| raycaster.wall_feature(x, y),
            floor_texture_at,
            ceiling_texture_at,
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
        scene.build_stats = lighting_cache.stats();
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
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        let mut lighting_cache = LightingSampleCache::default();
        let eye = params.camera_height.clamp(0.1, 0.9);
        let camera_world_z = grid
            .get_active()
            .map(|level| level.floor_offset + eye)
            .unwrap_or(eye);
        let level_count = grid.level_count();
        let mut sprites_by_level = vec![Vec::new(); level_count];
        for sprite in sprites {
            if sprite.level_index < level_count {
                sprites_by_level[sprite.level_index].push(sprite.sprite.clone());
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
        for level_index in visible_levels {
            let _ = grid.with_runtime_level(level_index, |level, raycaster| {
                scene.build_scene_into(
                    raycaster,
                    level_index,
                    params,
                    &lights_by_level[level_index],
                    &sprites_by_level[level_index],
                    &|cell_value| wall_texture(level_index, cell_value),
                    &|x, y| raycaster.wall_feature(x, y),
                    &|x, y| {
                        floor_texture_at(level_index, x, y)
                            .or_else(|| level.floor_texture_at(x as usize, y as usize))
                    },
                    &|x, y| {
                        ceiling_texture_at(level_index, x, y)
                            .or_else(|| level.ceiling_texture_at(x as usize, y as usize))
                    },
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
        scene.build_stats = lighting_cache.stats();
        scene
    }
}
