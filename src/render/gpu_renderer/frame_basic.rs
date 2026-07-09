//! Owns the render GPU renderer frame basic implementation for the render subsystem and keeps rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU renderer frame basic data is validated, transformed, or stored before systems consume it.
//! Separates render GPU renderer frame basic behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU renderer frame basic defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near render GPU renderer frame basic state that explains them instead of outward.
//! Preserves deterministic behavior by keeping render GPU renderer frame basic calculations at their owning boundary.
//! Provides layer that lets callers reuse render GPU renderer frame basic rules without duplicating engine decisions.

use super::frame::FrameCommandContext;
use super::*;

impl<'a> FrameCommandContext<'a> {
    #[allow(unused_mut, unused_variables)]
    /// Handles basic render commands that encode directly into the current frame buffers.
    pub(super) fn handle_basic_render_command(
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

        match cmd {
            RenderCommand::DrawStaticGeometry {
                geometry_key,
                x,
                y,
                rotation,
                sx,
                sy,
            } => {
                if let Some(geom) = renderer.mesh_cache.static_geometry.get(geometry_key) {
                    let parent = transform_stack_last(&transform_stack);
                    let local = Mat3::from_translation(Vec2 { x: *x, y: *y })
                        * Mat3::from_rotation(*rotation)
                        * Mat3::from_scale(Vec2 { x: *sx, y: *sy });
                    let model = *parent * local;
                    let instance = crate::render::gpu_types::InstanceData::from(model);

                    let inst_offset = frame_instances.len() as u32;
                    frame_instances.push(instance);

                    let (target_width, target_height) =
                        renderer.target_dimensions(current_target, canvases);

                    draws.push(PreparedDraw {
                        target: current_target,
                        geometry: geom.geometry_kind,
                        texture_ref: geom.texture.map(crate::render::gpu_types::TexRef::Texture),
                        idx_start: 0,
                        idx_count: geom.index_count,
                        blend_mode: current_blend_mode,
                        scissor: normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        shader: active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference: stencil_reference as u32,
                        static_geometry: Some(*geometry_key),
                        instance_buffer: None,
                        instance_start: inst_offset,
                        instance_count: 1,
                    });
                } else {
                    renderer.render_diagnostics.record_missing_static_geometry();
                }
            }
            RenderCommand::InstancedDraw {
                geometry_kind,
                instances,
            } => {
                let inst_buf_entry = renderer.mesh_cache.instance_buffers.get(instances);
                if let Some(inst_entry) = inst_buf_entry {
                    let (geom_kind, static_geom_key, idx_count, tex_ref) = match geometry_kind {
                        DrawableKind::Mesh(mesh_key) => {
                            let static_key = StaticGeometryKey::from(mesh_key.data());
                            if let Some(geom) = renderer.mesh_cache.static_geometry.get(&static_key)
                            {
                                (
                                    geom.geometry_kind,
                                    Some(static_key),
                                    geom.index_count,
                                    geom.texture.map(crate::render::gpu_types::TexRef::Texture),
                                )
                            } else {
                                renderer.render_diagnostics.record_missing_mesh();
                                restore_state!();
                                return true;
                            }
                        }
                        DrawableKind::Image(texture_key) => (
                            GeometryKind::TextureInstanced,
                            Some(StaticGeometryKey::default()),
                            6,
                            Some(crate::render::gpu_types::TexRef::Texture(*texture_key)),
                        ),
                        DrawableKind::Canvas(canvas_key) => (
                            GeometryKind::TextureInstanced,
                            Some(StaticGeometryKey::default()),
                            6,
                            Some(crate::render::gpu_types::TexRef::Canvas(*canvas_key)),
                        ),
                        DrawableKind::SpriteBatch(_) => {
                            renderer
                                .render_diagnostics
                                .record_unsupported_instanced_sprite_batch();
                            restore_state!();
                            return true;
                        }
                    };

                    let (target_width, target_height) =
                        renderer.target_dimensions(current_target, canvases);

                    draws.push(PreparedDraw {
                        target: current_target,
                        geometry: geom_kind,
                        texture_ref: tex_ref,
                        idx_start: 0,
                        idx_count,
                        blend_mode: current_blend_mode,
                        scissor: normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        shader: active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference: stencil_reference as u32,
                        static_geometry: static_geom_key,
                        instance_buffer: Some(*instances),
                        instance_start: 0,
                        instance_count: inst_entry.count,
                    });
                } else {
                    renderer.render_diagnostics.record_missing_instance_buffer();
                }
            }
            RenderCommand::SetColor(r, g, b, a) => {
                current_color = [*r, *g, *b, *a];
            }
            RenderCommand::SetLineWidth(w) => {
                line_width = *w;
            }
            RenderCommand::PushTransform => {
                let top = *transform_stack_last(&transform_stack);
                transform_stack.push(top);
            }
            RenderCommand::PopTransform => {
                if transform_stack.len() > 1 {
                    transform_stack.pop();
                }
            }
            RenderCommand::Translate { x, y } => {
                let m = Mat3::from_translation(Vec2 { x: *x, y: *y });
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = *top * m;
            }
            RenderCommand::Rotate { angle } => {
                let m = Mat3::from_rotation(*angle);
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = *top * m;
            }
            RenderCommand::Scale { sx, sy } => {
                let m = Mat3::from_scale(Vec2 { x: *sx, y: *sy });
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = *top * m;
            }
            RenderCommand::Shear { kx, ky } => {
                let m = Mat3::from_shear(*kx, *ky);
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = *top * m;
            }
            RenderCommand::Origin => {
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = Mat3::identity();
            }
            RenderCommand::ApplyTransform { matrix } => {
                let m = Mat3::from_row_major(matrix);
                let top = transform_stack_last_mut(&mut transform_stack);
                *top = *top * m;
            }
            RenderCommand::Rectangle { mode, x, y, w, h } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        *x,
                        *y,
                        *w,
                        *h,
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                let idx_start = all_color_idxs.len();
                renderer.tess_rect(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x,
                    *y,
                    *w,
                    *h,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::RoundedRectangle {
                mode,
                x,
                y,
                w,
                h,
                rx,
                ry,
            } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        *x,
                        *y,
                        *w,
                        *h,
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                let idx_start = all_color_idxs.len();
                renderer.tess_rounded_rect(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x,
                    *y,
                    *w,
                    *h,
                    *rx,
                    *ry,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Circle { mode, x, y, r } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        x - r,
                        y - r,
                        r * 2.0,
                        r * 2.0,
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                let segments = adaptive_circle_ellipse_segments(*r, *r);
                let idx_start = all_color_idxs.len();
                renderer.tess_ellipse(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x,
                    *y,
                    *r,
                    *r,
                    segments,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Ellipse { mode, x, y, rx, ry } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        x - rx,
                        y - ry,
                        rx * 2.0,
                        ry * 2.0,
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                let segments = adaptive_circle_ellipse_segments(*rx, *ry);
                let idx_start = all_color_idxs.len();
                renderer.tess_ellipse(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x,
                    *y,
                    *rx,
                    *ry,
                    segments,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Triangle {
                mode,
                x1,
                y1,
                x2,
                y2,
                x3,
                y3,
            } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                let idx_start = all_color_idxs.len();
                renderer.tess_triangle(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x1,
                    *y1,
                    *x2,
                    *y2,
                    *x3,
                    *y3,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Polygon { mode, vertices } => {
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let t = transform_stack_last(&transform_stack);
                let idx_start = all_color_idxs.len();
                renderer.tess_polygon(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    vertices,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Line { x1, y1, x2, y2 } => {
                let t = transform_stack_last(&transform_stack);
                let idx_start = all_color_idxs.len();
                push_thick_line(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    *x1,
                    *y1,
                    *x2,
                    *y2,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::Polyline { points } => {
                if points.len() >= 4 {
                    let t = transform_stack_last(&transform_stack);
                    let idx_start = all_color_idxs.len();
                    let mut i = 0;
                    while i + 3 < points.len() {
                        push_thick_line(
                            &mut all_color_verts,
                            &mut all_color_idxs,
                            t,
                            current_color,
                            points[i],
                            points[i + 1],
                            points[i + 2],
                            points[i + 3],
                            line_width,
                        );
                        i += 2;
                    }
                    let idx_end = all_color_idxs.len();
                    let (target_width, target_height) =
                        renderer.target_dimensions(current_target, canvases);
                    append_color_draw_range(
                        &mut draws,
                        idx_start,
                        idx_end,
                        current_target,
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                    );
                }
            }
            RenderCommand::Arc {
                mode,
                x,
                y,
                radius,
                angle1,
                angle2,
                segments,
            } => {
                let t = transform_stack_last(&transform_stack);
                let segs = if *segments == 0 { 32 } else { *segments };
                let mode = if wireframe { &DrawMode::Line } else { mode };
                let idx_start = all_color_idxs.len();
                renderer.tess_arc(
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    t,
                    current_color,
                    mode,
                    *x,
                    *y,
                    *radius,
                    *angle1,
                    *angle2,
                    segs,
                    line_width,
                );
                let idx_end = all_color_idxs.len();
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    &mut draws,
                    idx_start,
                    idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }
            RenderCommand::SetBlendMode(mode) => {
                current_blend_mode = *mode;
            }
            RenderCommand::Print {
                font_key,
                ref text,
                x,
                y,
                scale,
            } => {
                let t = transform_stack_last(&transform_stack);
                renderer.replay_plain_text(
                    *font_key,
                    text,
                    *x,
                    *y,
                    *scale,
                    current_color,
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
            RenderCommand::PrintTransformed {
                font_key,
                ref text,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
                scale,
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
                renderer.replay_plain_text(
                    *font_key,
                    text,
                    0.0,
                    0.0,
                    *scale,
                    current_color,
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
            _ => {
                restore_state!();
                return false;
            }
        }
        restore_state!();
        true
    }
}
