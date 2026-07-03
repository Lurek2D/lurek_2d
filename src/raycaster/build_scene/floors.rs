//! Owns the raycaster build scene floors implementation for the raycaster subsystem and keeps rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster build scene floors data is validated, transformed, or stored before systems consume it.
//! Separates raycaster build scene floors behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster build scene floors defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near raycaster build scene floors state that explains them instead of outward.
//! Preserves deterministic behavior by keeping raycaster build scene floors calculations at their owning boundary.

use super::*;

/// Emit `FloorQuad`, `CeilingQuad`, and lowered-floor side `WallQuad` entries for all visible open tiles.
#[allow(clippy::too_many_arguments)]
pub(super) fn build_floor_tiles(
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
