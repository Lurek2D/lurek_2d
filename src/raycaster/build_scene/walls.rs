//! Owns the raycaster build scene walls implementation for the raycaster subsystem and keeps rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster build scene walls data is validated, transformed, or stored before neighboring systems consume it.
//! Separates raycaster build scene walls behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster build scene walls defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near raycaster build scene walls state that explains them instead of outward.
//! Preserves deterministic behavior by keeping raycaster build scene walls calculations at their owning subsystem boundary.
//! Provides layer that lets callers reuse raycaster build scene walls rules without duplicating engine decisions.

use super::*;

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
pub(super) fn build_wall_faces(
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
