//! Owns the render GPU renderer frame advanced implementation for the render subsystem and keeps rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU renderer frame advanced data is validated, transformed, or stored before systems consume it.
//! Separates render GPU renderer frame advanced behavior from Lua bindings, tests, and sibling owners so readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU renderer frame advanced defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near render GPU renderer frame advanced state that explains them instead of outward.
//! Preserves deterministic behavior by keeping render GPU renderer frame advanced calculations at their owning boundary.
//! Provides layer that lets callers reuse render GPU renderer frame advanced rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on render GPU renderer frame advanced state, rules.
//! Works with render owners while keeping main render GPU renderer frame advanced responsibility anchored in one file.

use super::frame::FrameCommandContext;
use super::*;

/// Bound persistent fullscreen capture textures keyed by game-controlled postfx stack IDs.
const MAX_POSTFX_CAPTURE_TEXTURES: usize = 128;

impl<'a> FrameCommandContext<'a> {
    #[allow(unused_mut, unused_variables)]
    /// Handles advanced render commands that expand complex geometry or multi-step GPU work.
    pub(super) fn handle_advanced_render_command(
        &mut self,
        renderer: &mut GpuRenderer,
        cmd: &RenderCommand,
    ) -> bool {
        let fonts = &mut *self.fonts;
        let sprite_batches = self.sprite_batches;
        let shapes = self.shapes;
        let canvases = self.canvases;
        let meshes = self.meshes;
        let shaders = self.shaders;
        let default_filter = self.default_filter;
        let camera_matrix = self.camera_matrix;
        let render_input_limits = self.render_input_limits;
        let mut current_target = self.current_target;
        let mut current_blend_mode = self.current_blend_mode;
        let mut current_scissor = self.current_scissor;
        let mut current_color = self.current_color;
        let mut color_mask_bits = self.color_mask_bits;
        let mut wireframe = self.wireframe;
        let mut line_width = self.line_width;
        let mut point_size = self.point_size;
        let mut transform_stack = std::mem::take(&mut self.transform_stack);
        let mut stencil_mode = self.stencil_mode;
        let mut stencil_reference = self.stencil_reference;
        let mut active_shader = self.active_shader;
        let mut active_text_shader = self.active_text_shader;
        let mut pending_postfx = std::mem::take(&mut self.pending_postfx);
        let mut pending_canvas_postfx = std::mem::take(&mut self.pending_canvas_postfx);
        let mut pending_canvas_effects = std::mem::take(&mut self.pending_canvas_effects);
        let mut pending_province_maps = std::mem::take(&mut self.pending_province_maps);
        let mut all_color_verts = std::mem::take(&mut self.all_color_verts);
        let mut all_color_idxs = std::mem::take(&mut self.all_color_idxs);
        let mut all_tex_verts = std::mem::take(&mut self.all_tex_verts);
        let mut all_tex_idxs = std::mem::take(&mut self.all_tex_idxs);
        let mut all_particle_verts = std::mem::take(&mut self.all_particle_verts);
        let mut all_particle_idxs = std::mem::take(&mut self.all_particle_idxs);
        let mut draws = std::mem::take(&mut self.draws);
        let mut frame_instances = std::mem::take(&mut self.frame_instances);
        let mut scratch_color_verts = std::mem::take(&mut self.scratch_color_verts);
        let mut scratch_color_idxs = std::mem::take(&mut self.scratch_color_idxs);
        let mut scratch_tex_verts = std::mem::take(&mut self.scratch_tex_verts);
        let mut scratch_tex_idxs = std::mem::take(&mut self.scratch_tex_idxs);

        macro_rules! restore_state {
            () => {
                self.current_target = current_target;
                self.current_blend_mode = current_blend_mode;
                self.current_scissor = current_scissor;
                self.current_color = current_color;
                self.color_mask_bits = color_mask_bits;
                self.wireframe = wireframe;
                self.line_width = line_width;
                self.point_size = point_size;
                self.transform_stack = transform_stack;
                self.stencil_mode = stencil_mode;
                self.stencil_reference = stencil_reference;
                self.active_shader = active_shader;
                self.active_text_shader = active_text_shader;
                self.pending_postfx = pending_postfx;
                self.pending_canvas_postfx = pending_canvas_postfx;
                self.pending_canvas_effects = pending_canvas_effects;
                self.pending_province_maps = pending_province_maps;
                self.all_color_verts = all_color_verts;
                self.all_color_idxs = all_color_idxs;
                self.all_tex_verts = all_tex_verts;
                self.all_tex_idxs = all_tex_idxs;
                self.all_particle_verts = all_particle_verts;
                self.all_particle_idxs = all_particle_idxs;
                self.draws = draws;
                self.frame_instances = frame_instances;
                self.scratch_color_verts = scratch_color_verts;
                self.scratch_color_idxs = scratch_color_idxs;
                self.scratch_tex_verts = scratch_tex_verts;
                self.scratch_tex_idxs = scratch_tex_idxs;
            };
        }

        // Advanced commands build temporary, Lua-sized geometry before it can be
        // merged into the frame buffers.  A failed reservation is a normal rejected
        // command, not a renderer panic or partially published draw.
        macro_rules! reserve_or_skip {
            ($values:expr, $additional:expr) => {
                if ($values).try_reserve($additional).is_err() {
                    renderer.render_diagnostics.record_invalid_render_input();
                    log::warn!(
                        "Skipping render command because temporary geometry reservation failed"
                    );
                    restore_state!();
                    return true;
                }
            };
        }

        match cmd {
            RenderCommand::DrawQuadBezier {
                start,
                control,
                end,
                segments,
            } => {
                let n = (*segments).clamp(4, 256) as usize;
                let t = transform_stack_last(&transform_stack);
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                let mut prev = *start;
                for i in 1..=n {
                    let tv = i as f32 / n as f32;
                    let mt = 1.0 - tv;
                    let nx = mt * mt * start.x + 2.0 * mt * tv * control.x + tv * tv * end.x;
                    let ny = mt * mt * start.y + 2.0 * mt * tv * control.y + tv * tv * end.y;
                    push_thick_line(
                        &mut verts,
                        &mut idxs,
                        t,
                        current_color,
                        prev.x,
                        prev.y,
                        nx,
                        ny,
                        line_width,
                    );
                    prev = Vec2::new(nx, ny);
                }
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::DrawCubicBezier {
                start,
                c1,
                c2,
                end,
                segments,
            } => {
                let n = (*segments).clamp(4, 256) as usize;
                let t = transform_stack_last(&transform_stack);
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                let mut prev = *start;
                for i in 1..=n {
                    let tv = i as f32 / n as f32;
                    let mt = 1.0 - tv;
                    let nx = mt * mt * mt * start.x
                        + 3.0 * mt * mt * tv * c1.x
                        + 3.0 * mt * tv * tv * c2.x
                        + tv * tv * tv * end.x;
                    let ny = mt * mt * mt * start.y
                        + 3.0 * mt * mt * tv * c1.y
                        + 3.0 * mt * tv * tv * c2.y
                        + tv * tv * tv * end.y;
                    push_thick_line(
                        &mut verts,
                        &mut idxs,
                        t,
                        current_color,
                        prev.x,
                        prev.y,
                        nx,
                        ny,
                        line_width,
                    );
                    prev = Vec2::new(nx, ny);
                }
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::DrawPath {
                segments: path_segs,
                mode,
                close,
            } => {
                let t = transform_stack_last(&transform_stack);
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                let mut points: Vec<[f32; 2]> = Vec::new();
                let mut pen = [0.0f32; 2];
                let mut anchor = [0.0f32; 2];
                for seg in path_segs {
                    match seg {
                        PathSegment::MoveTo { x, y } => {
                            if !points.is_empty() {
                                if *close {
                                    points.push(anchor);
                                }
                                for w in points.windows(2) {
                                    push_thick_line(
                                        &mut verts,
                                        &mut idxs,
                                        t,
                                        current_color,
                                        w[0][0],
                                        w[0][1],
                                        w[1][0],
                                        w[1][1],
                                        line_width,
                                    );
                                }
                                points.clear();
                            }
                            pen = [*x, *y];
                            anchor = pen;
                            points.push(pen);
                        }
                        PathSegment::LineTo { x, y } => {
                            pen = [*x, *y];
                            points.push(pen);
                        }
                        PathSegment::QuadTo { cx, cy, x, y } => {
                            let s = Vec2::new(pen[0], pen[1]);
                            let c = Vec2::new(*cx, *cy);
                            let e = Vec2::new(*x, *y);
                            for i in 1..=8usize {
                                let tv = i as f32 / 8.0;
                                let mt = 1.0 - tv;
                                let nx = mt * mt * s.x + 2.0 * mt * tv * c.x + tv * tv * e.x;
                                let ny = mt * mt * s.y + 2.0 * mt * tv * c.y + tv * tv * e.y;
                                points.push([nx, ny]);
                            }
                            pen = [*x, *y];
                        }
                        PathSegment::CubicTo {
                            cx1,
                            cy1,
                            cx2,
                            cy2,
                            x,
                            y,
                        } => {
                            let s = Vec2::new(pen[0], pen[1]);
                            let cp1 = Vec2::new(*cx1, *cy1);
                            let cp2 = Vec2::new(*cx2, *cy2);
                            let ep = Vec2::new(*x, *y);
                            for i in 1..=8usize {
                                let tv = i as f32 / 8.0;
                                let mt = 1.0 - tv;
                                let nx = mt * mt * mt * s.x
                                    + 3.0 * mt * mt * tv * cp1.x
                                    + 3.0 * mt * tv * tv * cp2.x
                                    + tv * tv * tv * ep.x;
                                let ny = mt * mt * mt * s.y
                                    + 3.0 * mt * mt * tv * cp1.y
                                    + 3.0 * mt * tv * tv * cp2.y
                                    + tv * tv * tv * ep.y;
                                points.push([nx, ny]);
                            }
                            pen = [*x, *y];
                        }
                    }
                }
                if !points.is_empty() {
                    if *close {
                        points.push(anchor);
                    }
                    match mode {
                        DrawMode::Line => {
                            for w in points.windows(2) {
                                push_thick_line(
                                    &mut verts,
                                    &mut idxs,
                                    t,
                                    current_color,
                                    w[0][0],
                                    w[0][1],
                                    w[1][0],
                                    w[1][1],
                                    line_width,
                                );
                            }
                        }
                        DrawMode::Fill => {
                            let flat: Vec<f32> = points.iter().flat_map(|p| [p[0], p[1]]).collect();
                            renderer.tess_polygon(
                                &mut verts,
                                &mut idxs,
                                t,
                                current_color,
                                &DrawMode::Fill,
                                &flat,
                                line_width,
                            );
                        }
                    }
                }
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::DrawGradientRect {
                x,
                y,
                w,
                h,
                color1,
                color2,
                direction,
            } => {
                let lerp = |a: &[f32; 4], b: &[f32; 4], f: f32| -> [f32; 4] {
                    [
                        a[0] + (b[0] - a[0]) * f,
                        a[1] + (b[1] - a[1]) * f,
                        a[2] + (b[2] - a[2]) * f,
                        a[3] + (b[3] - a[3]) * f,
                    ]
                };
                let corner_colors: [[f32; 4]; 4] = match direction {
                    GradientDirection::Horizontal => [*color1, *color2, *color2, *color1],
                    GradientDirection::Vertical => [*color1, *color1, *color2, *color2],
                    GradientDirection::DiagDown => {
                        let mid = lerp(color1, color2, 0.5);
                        [*color1, mid, *color2, mid]
                    }
                    GradientDirection::DiagUp => {
                        let mid = lerp(color1, color2, 0.5);
                        [mid, *color1, mid, *color2]
                    }
                    GradientDirection::Radial => [*color1, *color1, *color2, *color2],
                };
                let t = transform_stack_last(&transform_stack);
                let corner_pts = [(*x, *y), (*x + w, *y), (*x + w, *y + h), (*x, *y + h)];
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                reserve_or_skip!(verts, 4);
                reserve_or_skip!(idxs, 6);
                let base = 0;
                for (i, (px, py)) in corner_pts.iter().enumerate() {
                    let (sx, sy) = apply(t, *px, *py);
                    verts.push(ColorVertex {
                        position: [sx, sy],
                        color: corner_colors[i],
                    });
                }
                idxs.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::DrawColoredPolygon {
                vertices,
                colors,
                mode,
            } => {
                let n = vertices.len() / 2;
                if n >= 3 && colors.len() >= n {
                    let t = transform_stack_last(&transform_stack);
                    let Some(max_vertices) = n.checked_mul(4) else {
                        renderer.render_diagnostics.record_invalid_render_input();
                        restore_state!();
                        return true;
                    };
                    let Some(max_indices) = n.checked_mul(6) else {
                        renderer.render_diagnostics.record_invalid_render_input();
                        restore_state!();
                        return true;
                    };
                    let mut verts: Vec<ColorVertex> = Vec::new();
                    let mut idxs: Vec<u32> = Vec::new();
                    let mut poly: Vec<Vec2> = Vec::new();
                    reserve_or_skip!(verts, max_vertices);
                    reserve_or_skip!(idxs, max_indices);
                    reserve_or_skip!(poly, n);
                    match mode {
                        DrawMode::Fill => {
                            for i in 0..n {
                                let (sx, sy) = apply(t, vertices[i * 2], vertices[i * 2 + 1]);
                                verts.push(ColorVertex {
                                    position: [sx, sy],
                                    color: colors[i],
                                });
                            }
                            poly.extend(
                                vertices
                                    .chunks_exact(2)
                                    .map(|pair| Vec2::new(pair[0], pair[1])),
                            );
                            if let Ok(tris) = polygon::triangulate(&poly) {
                                for tri in tris {
                                    for point in tri {
                                        if let Some(index) = poly.iter().position(|candidate| {
                                            candidate.x.to_bits() == point.x.to_bits()
                                                && candidate.y.to_bits() == point.y.to_bits()
                                        }) {
                                            idxs.push(index as u32);
                                        }
                                    }
                                }
                            }
                            if idxs.len() < 3 {
                                for i in 1..(n as u32 - 1) {
                                    idxs.extend_from_slice(&[0, i, i + 1]);
                                }
                            }
                        }
                        DrawMode::Line => {
                            for i in 0..n {
                                let j = (i + 1) % n;
                                push_thick_line(
                                    &mut verts,
                                    &mut idxs,
                                    t,
                                    colors[i],
                                    vertices[i * 2],
                                    vertices[i * 2 + 1],
                                    vertices[j * 2],
                                    vertices[j * 2 + 1],
                                    line_width,
                                );
                            }
                        }
                    }
                    let (tw, th) = renderer.target_dimensions(current_target, canvases);
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        verts,
                        idxs,
                    );
                }
            }
            RenderCommand::DrawIsoCubeTile {
                screen_x,
                screen_y,
                half_w,
                half_h,
                depth: _,
                top_color,
                top_texture,
                left_color,
                left_texture,
                right_color,
                right_texture,
            } => {
                let t = transform_stack_last(&transform_stack);
                let sx = *screen_x;
                let sy = *screen_y;
                let hw = *half_w;
                let hh = *half_h;
                let top_corners = [
                    Vec2::new(sx, sy - hh),
                    Vec2::new(sx + hw, sy),
                    Vec2::new(sx, sy + hh / 2.0),
                    Vec2::new(sx - hw, sy),
                ];
                let left_corners = [
                    Vec2::new(sx - hw, sy),
                    Vec2::new(sx, sy + hh / 2.0),
                    Vec2::new(sx, sy + hh * 1.5),
                    Vec2::new(sx - hw, sy + hh),
                ];
                let right_corners = [
                    Vec2::new(sx, sy + hh / 2.0),
                    Vec2::new(sx + hw, sy),
                    Vec2::new(sx + hw, sy + hh),
                    Vec2::new(sx, sy + hh * 1.5),
                ];
                let full_uvs = [
                    Vec2::new(0.0, 0.0),
                    Vec2::new(1.0, 0.0),
                    Vec2::new(1.0, 1.0),
                    Vec2::new(0.0, 1.0),
                ];
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                let scissor = normalize_scissor(current_scissor, tw, th);
                for (corners, color, tex_opt) in [
                    (&top_corners, top_color, top_texture),
                    (&left_corners, left_color, left_texture),
                    (&right_corners, right_color, right_texture),
                ] {
                    if let Some(key) = tex_opt {
                        if renderer.gpu_textures.contains_key(*key) {
                            scratch_tex_verts.clear();
                            scratch_tex_idxs.clear();
                            push_tex_quad_corners(
                                &mut scratch_tex_verts,
                                &mut scratch_tex_idxs,
                                t,
                                *color,
                                corners,
                                &full_uvs,
                                &[1.0, 1.0, 1.0, 1.0],
                            );
                            append_tex_draw_slices(
                                &mut draws,
                                &mut all_tex_verts,
                                &mut all_tex_idxs,
                                current_target,
                                TexRef::Texture(*key),
                                current_blend_mode,
                                scissor,
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                                &scratch_tex_verts,
                                &scratch_tex_idxs,
                            );
                        }
                    } else {
                        let flat: Vec<f32> = corners.iter().flat_map(|v| [v.x, v.y]).collect();
                        let mut cv: Vec<ColorVertex> = Vec::new();
                        let mut ci: Vec<u32> = Vec::new();
                        renderer.tess_polygon(
                            &mut cv,
                            &mut ci,
                            t,
                            *color,
                            &DrawMode::Fill,
                            &flat,
                            line_width,
                        );
                        append_color_draw(
                            &mut draws,
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            current_target,
                            current_blend_mode,
                            scissor,
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            cv,
                            ci,
                        );
                    }
                }
            }
            RenderCommand::DrawHexTile {
                cx,
                cy,
                size,
                orientation,
                mode,
            } => {
                let t = transform_stack_last(&transform_stack);
                let angle_offset = match orientation {
                    HexOrientation::PointyTop => PI / 6.0,
                    HexOrientation::FlatTop => 0.0,
                };
                let mut flat = Vec::new();
                reserve_or_skip!(flat, 12);
                for k in 0..6u32 {
                    let a = k as f32 * PI / 3.0 + angle_offset;
                    flat.push(*cx + *size * a.cos());
                    flat.push(*cy + *size * a.sin());
                }
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                renderer.tess_polygon(
                    &mut verts,
                    &mut idxs,
                    t,
                    current_color,
                    mode,
                    &flat,
                    line_width,
                );
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::BeginSortGroup { .. } => {}
            RenderCommand::PushSortKey(_) => {}
            RenderCommand::FlushSortGroup { .. } => {}
            RenderCommand::DrawPhysicsDebug { shapes, config } => {
                let t = transform_stack_last(&transform_stack);
                let lw = config.line_width;
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                for shape in shapes {
                    let color = if shape.is_sensor {
                        config.sensor_color
                    } else if shape.is_sleeping {
                        config.sleep_color
                    } else if shape.is_static {
                        config.static_color
                    } else {
                        config.body_color
                    };
                    let mut cv: Vec<ColorVertex> = Vec::new();
                    let mut ci: Vec<u32> = Vec::new();
                    if shape.is_circle {
                        renderer.tess_ellipse(
                            &mut cv,
                            &mut ci,
                            t,
                            color,
                            &DrawMode::Line,
                            shape.x,
                            shape.y,
                            shape.half_w,
                            shape.half_w,
                            24,
                            lw,
                        );
                    } else if !shape.hull_verts.is_empty() {
                        let cos_a = shape.angle.cos();
                        let sin_a = shape.angle.sin();
                        let flat: Vec<f32> = shape
                            .hull_verts
                            .iter()
                            .flat_map(|[lx, ly]| {
                                let wx = shape.x + lx * cos_a - ly * sin_a;
                                let wy = shape.y + lx * sin_a + ly * cos_a;
                                [wx, wy]
                            })
                            .collect();
                        renderer.tess_polygon(
                            &mut cv,
                            &mut ci,
                            t,
                            color,
                            &DrawMode::Line,
                            &flat,
                            lw,
                        );
                    } else {
                        let cos_a = shape.angle.cos();
                        let sin_a = shape.angle.sin();
                        let corners: [[f32; 2]; 4] = [
                            [-shape.half_w, -shape.half_h],
                            [shape.half_w, -shape.half_h],
                            [shape.half_w, shape.half_h],
                            [-shape.half_w, shape.half_h],
                        ];
                        let flat: Vec<f32> = corners
                            .iter()
                            .flat_map(|[lx, ly]| {
                                let wx = shape.x + lx * cos_a - ly * sin_a;
                                let wy = shape.y + lx * sin_a + ly * cos_a;
                                [wx, wy]
                            })
                            .collect();
                        renderer.tess_polygon(
                            &mut cv,
                            &mut ci,
                            t,
                            color,
                            &DrawMode::Line,
                            &flat,
                            lw,
                        );
                    }
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, tw, th),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        cv,
                        ci,
                    );
                }
            }
            RenderCommand::DrawSpineSkeleton { slots } => {
                let t = transform_stack_last(&transform_stack);
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                let scissor = normalize_scissor(current_scissor, tw, th);
                for slot in slots {
                    let tex_ref = if let Some(canvas_key) = slot.canvas_key {
                        if canvases.contains_key(canvas_key) {
                            Some(TexRef::Canvas(canvas_key))
                        } else {
                            None
                        }
                    } else if renderer.gpu_textures.contains_key(slot.texture_key) {
                        Some(TexRef::Texture(slot.texture_key))
                    } else {
                        None
                    };

                    if let Some(resolved_tex) = tex_ref {
                        scratch_tex_verts.clear();
                        scratch_tex_idxs.clear();
                        push_tex_quad_corners(
                            &mut scratch_tex_verts,
                            &mut scratch_tex_idxs,
                            t,
                            slot.color,
                            &slot.corners,
                            &slot.uvs,
                            &[1.0, 1.0, 1.0, 1.0],
                        );
                        append_tex_draw_slices(
                            &mut draws,
                            &mut all_tex_verts,
                            &mut all_tex_idxs,
                            current_target,
                            resolved_tex,
                            slot.blend_mode,
                            scissor,
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            &scratch_tex_verts,
                            &scratch_tex_idxs,
                        );
                    }
                }
            }
            RenderCommand::DrawBevelRect {
                x,
                y,
                w,
                h,
                bevel_w,
                style,
                highlight,
                shadow,
                fill_color,
            } => {
                let t = transform_stack_last(&transform_stack);
                let bw = *bevel_w;
                let ix = *x + bw;
                let iy = *y + bw;
                let iw = *w - 2.0 * bw;
                let ih = *h - 2.0 * bw;
                let (top_c, left_c, bottom_c, right_c) = match style {
                    BevelStyle::Raised => (*highlight, *highlight, *shadow, *shadow),
                    BevelStyle::Sunken => (*shadow, *shadow, *highlight, *highlight),
                    BevelStyle::Ridge => (*highlight, *highlight, *shadow, *shadow),
                    BevelStyle::Groove => (*shadow, *shadow, *highlight, *highlight),
                    BevelStyle::Flat => (*fill_color, *fill_color, *fill_color, *fill_color),
                };
                let mut verts: Vec<ColorVertex> = Vec::new();
                let mut idxs: Vec<u32> = Vec::new();
                if iw > 0.0 && ih > 0.0 {
                    renderer.tess_rect(
                        &mut verts,
                        &mut idxs,
                        t,
                        *fill_color,
                        &DrawMode::Fill,
                        ix,
                        iy,
                        iw,
                        ih,
                        line_width,
                    );
                }
                let push_bevel_quad =
                    |cv: &mut Vec<ColorVertex>,
                     ci: &mut Vec<u32>,
                     pts: &[(f32, f32); 4],
                     colors: &[[f32; 4]; 4]| {
                        let base = cv.len() as u32;
                        for (i, &(px, py)) in pts.iter().enumerate() {
                            let (sx, sy) = apply(t, px, py);
                            cv.push(ColorVertex {
                                position: [sx, sy],
                                color: colors[i],
                            });
                        }
                        ci.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                    };
                push_bevel_quad(
                    &mut verts,
                    &mut idxs,
                    &[(*x, *y), (*x + *w, *y), (ix + iw, iy), (ix, iy)],
                    &[top_c, top_c, top_c, top_c],
                );
                push_bevel_quad(
                    &mut verts,
                    &mut idxs,
                    &[
                        (ix, iy + ih),
                        (ix + iw, iy + ih),
                        (*x + *w, *y + *h),
                        (*x, *y + *h),
                    ],
                    &[bottom_c, bottom_c, bottom_c, bottom_c],
                );
                push_bevel_quad(
                    &mut verts,
                    &mut idxs,
                    &[(*x, *y), (ix, iy), (ix, iy + ih), (*x, *y + *h)],
                    &[left_c, left_c, left_c, left_c],
                );
                push_bevel_quad(
                    &mut verts,
                    &mut idxs,
                    &[
                        (ix + iw, iy),
                        (*x + *w, *y),
                        (*x + *w, *y + *h),
                        (ix + iw, iy + ih),
                    ],
                    &[right_c, right_c, right_c, right_c],
                );
                let (tw, th) = renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, tw, th),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::PushLayer { .. } => {}
            RenderCommand::PopLayer { .. } => {}
            RenderCommand::BeginPostFx { stack_id } => {
                if renderer.postfx_pipeline.is_none() {
                    renderer.postfx_pipeline =
                        Some(crate::render::postfx_pipeline::PostFxPipeline::new(
                            &renderer.device,
                            renderer.surface_format,
                        ));
                }
                if !renderer.postfx_capture.contains_key(stack_id)
                    && renderer.postfx_capture.len() >= MAX_POSTFX_CAPTURE_TEXTURES
                {
                    renderer.render_diagnostics.record_invalid_render_input();
                    log::warn!(
                        "Skipping postfx stack because the {}-capture limit is exhausted",
                        MAX_POSTFX_CAPTURE_TEXTURES
                    );
                    restore_state!();
                    return true;
                }
                let (w, h) = (renderer.width, renderer.height);
                let fmt = renderer.surface_format;
                let dev = &renderer.device;
                renderer.postfx_capture.entry(*stack_id).or_insert_with(|| {
                    crate::render::postfx_pipeline::PostFxTexture::new(
                        dev,
                        w,
                        h,
                        "postfx_capture",
                        fmt,
                    )
                });
            }
            RenderCommand::EndPostFx { .. } => {}
            RenderCommand::ApplyPostFx {
                stack_id,
                passes,
                width,
                height,
            } => {
                pending_postfx.push((*stack_id, passes.clone(), *width, *height));
            }
            RenderCommand::ApplyShaderToCanvas { canvas_key, passes } => {
                pending_canvas_postfx.push((*canvas_key, passes.clone()));
            }
            RenderCommand::ApplyEffectToCanvas {
                source_canvas_key,
                target_canvas_key,
                passes,
            } => {
                pending_canvas_effects.push((
                    *source_canvas_key,
                    *target_canvas_key,
                    passes.clone(),
                ));
            }
            RenderCommand::DrawRichText {
                font_key,
                spans,
                x,
                y,
            } => {
                let t = transform_stack_last(&transform_stack);
                renderer.replay_rich_text(
                    *font_key,
                    spans,
                    *x,
                    *y,
                    t,
                    current_target,
                    current_blend_mode,
                    current_scissor,
                    color_mask_bits,
                    active_text_shader.or(active_shader),
                    stencil_mode,
                    stencil_reference,
                    canvases,
                    shaders,
                    fonts,
                    default_filter,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    &mut draws,
                );
            }
            RenderCommand::DrawRichTextTransformed {
                font_key,
                spans,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
            } => {
                let t = transformed_draw_matrix(
                    transform_stack_last(&transform_stack),
                    GpuDrawTransform {
                        x: *x,
                        y: *y,
                        rotation: *rotation,
                        sx: *sx,
                        sy: *sy,
                        ox: *ox,
                        oy: *oy,
                    },
                );
                renderer.replay_rich_text(
                    *font_key,
                    spans,
                    0.0,
                    0.0,
                    &t,
                    current_target,
                    current_blend_mode,
                    current_scissor,
                    color_mask_bits,
                    active_text_shader.or(active_shader),
                    stencil_mode,
                    stencil_reference,
                    canvases,
                    shaders,
                    fonts,
                    default_filter,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    &mut draws,
                );
            }
            RenderCommand::DrawConvexFan {
                vertices,
                tint,
                blend,
                ..
            } => {
                if vertices.len() < 3 {
                    restore_state!();
                    return true;
                }
                let t = transform_stack_last(&transform_stack);
                let Some(index_capacity) = vertices
                    .len()
                    .checked_sub(2)
                    .and_then(|count| count.checked_mul(3))
                else {
                    renderer.render_diagnostics.record_invalid_render_input();
                    restore_state!();
                    return true;
                };
                let mut verts = Vec::new();
                reserve_or_skip!(verts, vertices.len());
                for v in vertices {
                    let (px, py) = apply(t, v.x, v.y);
                    verts.push(ColorVertex {
                        position: [px, py],
                        color: *tint,
                    });
                }
                let mut idxs = Vec::new();
                reserve_or_skip!(idxs, index_capacity);
                for i in 1..(vertices.len() as u32 - 1) {
                    idxs.extend_from_slice(&[0, i, i + 1]);
                }
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw(
                    &mut draws,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    current_target,
                    *blend,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    verts,
                    idxs,
                );
            }
            RenderCommand::DrawProvinceMap {
                registry_name,
                viewport,
                screen_size,
                tint,
                province_tints,
                terrain_texture,
                effects,
                selected_id,
                hovered_id,
                zoom_mode,
                time,
            } => {
                pending_province_maps.push(PendingProvinceMapDraw {
                    registry_name: registry_name.clone(),
                    viewport: *viewport,
                    screen_size: *screen_size,
                    tint: *tint,
                    province_tints: province_tints.clone(),
                    terrain_texture: *terrain_texture,
                    effects: *effects,
                    selected_id: *selected_id,
                    hovered_id: *hovered_id,
                    zoom_mode: *zoom_mode,
                    time: *time,
                });
            }
            _ => {
                restore_state!();
                return false;
            }
        }
        restore_state!();
        true
    }
}
