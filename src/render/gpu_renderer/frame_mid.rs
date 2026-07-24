//! Owns the render GPU renderer frame mid implementation for the render subsystem and keeps rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU renderer frame mid data is validated, transformed, or stored before systems consume it.
//! Separates render GPU renderer frame mid behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU renderer frame mid defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near render GPU renderer frame mid state that explains them instead of outward.
//! Preserves deterministic behavior by keeping render GPU renderer frame mid calculations at their owning boundary.
//! Provides layer that lets callers reuse render GPU renderer frame mid rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on render GPU renderer frame mid state, helpers, rules.
//! Works with render owners while keeping main render GPU renderer frame mid responsibility anchored in one file.
//! Changes to render GPU renderer frame mid names, caches, or helper boundaries should usually stay coupled inside owner.

use super::frame::FrameCommandContext;
use super::*;

impl<'a> FrameCommandContext<'a> {
    #[allow(unused_mut, unused_variables)]
    /// Handles mid-tier render commands that assemble textured or stateful draw operations.
    pub(super) fn handle_mid_render_command(
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

        macro_rules! reserve_or_skip {
            ($values:expr, $additional:expr) => {
                if ($values).try_reserve($additional).is_err() {
                    renderer.render_diagnostics.record_invalid_render_input();
                    log::warn!("Skipping render command because frame buffer reservation failed");
                    restore_state!();
                    return true;
                }
            };
        }

        match cmd {
            RenderCommand::DrawImage {
                texture_key,
                x,
                y,
                effect: _,
            } => {
                let Some(gt) = renderer.gpu_textures.get(*texture_key) else {
                    renderer.render_diagnostics.record_missing_texture();
                    restore_state!();
                    return true;
                };
                let w = gt.width as f32;
                let h = gt.height as f32;
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        *x,
                        *y,
                        w,
                        h,
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                push_tex_quad(
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    t,
                    current_color,
                    *x,
                    *y,
                    0.0,
                    1.0,
                    1.0,
                    0.0,
                    0.0,
                    w,
                    h,
                    0.0,
                    0.0,
                    1.0,
                    1.0,
                );
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Texture(*texture_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::DrawImageEx {
                texture_key,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
                effect: _,
            } => {
                let Some(gt) = renderer.gpu_textures.get(*texture_key) else {
                    renderer.render_diagnostics.record_missing_texture();
                    restore_state!();
                    return true;
                };
                let w = gt.width as f32;
                let h = gt.height as f32;
                let t = transform_stack_last(&transform_stack);
                if current_target == RenderTargetId::Screen
                    && !GpuRenderer::aabb_visible_2d(
                        *x - *ox * sx.abs(),
                        *y - *oy * sy.abs(),
                        w * sx.abs(),
                        h * sy.abs(),
                        t,
                        camera_matrix,
                        renderer.width as f32,
                        renderer.height as f32,
                    )
                {
                    restore_state!();
                    return true;
                }
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                push_tex_quad(
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    t,
                    current_color,
                    *x,
                    *y,
                    *rotation,
                    *sx,
                    *sy,
                    *ox,
                    *oy,
                    w,
                    h,
                    0.0,
                    0.0,
                    1.0,
                    1.0,
                );
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Texture(*texture_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::DrawQuad {
                texture_key,
                quad_x,
                quad_y,
                quad_w,
                quad_h,
                tex_w,
                tex_h,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
                effect: _,
            } => {
                if !renderer.gpu_textures.contains_key(*texture_key) {
                    renderer.render_diagnostics.record_missing_texture();
                    restore_state!();
                    return true;
                }
                let t = transform_stack_last(&transform_stack);
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                let u0 = quad_x / tex_w;
                let v0 = quad_y / tex_h;
                let u1 = (quad_x + quad_w) / tex_w;
                let v1 = (quad_y + quad_h) / tex_h;
                push_tex_quad(
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    t,
                    current_color,
                    *x,
                    *y,
                    *rotation,
                    *sx,
                    *sy,
                    *ox,
                    *oy,
                    *quad_w,
                    *quad_h,
                    u0,
                    v0,
                    u1,
                    v1,
                );
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Texture(*texture_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::DrawTexturedQuad {
                corners,
                uvs,
                corner_w,
                texture_key,
                color,
            } => {
                if !renderer.gpu_textures.contains_key(*texture_key) {
                    renderer.render_diagnostics.record_missing_texture();
                    restore_state!();
                    return true;
                }
                let t = transform_stack_last(&transform_stack);
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                push_tex_quad_corners(
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    t,
                    *color,
                    corners,
                    uvs,
                    corner_w,
                );
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Texture(*texture_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::DrawBatch { batch_key } => {
                if let Some(batch) = sprite_batches.get(*batch_key) {
                    let tex_key = batch.texture_key();
                    let Some(gt) = renderer.gpu_textures.get(tex_key) else {
                        renderer.render_diagnostics.record_missing_texture();
                        restore_state!();
                        return true;
                    };
                    let tex_w = gt.width as f32;
                    let tex_h = gt.height as f32;
                    let t = transform_stack_last(&transform_stack);
                    scratch_tex_verts.clear();
                    scratch_tex_idxs.clear();
                    reserve_or_skip!(scratch_tex_verts, batch.len().saturating_mul(4));
                    reserve_or_skip!(scratch_tex_idxs, batch.len().saturating_mul(6));
                    for entry in batch.entries() {
                        let qw = if entry.quad_w > 0.0 {
                            entry.quad_w
                        } else {
                            tex_w
                        };
                        let qh = if entry.quad_h > 0.0 {
                            entry.quad_h
                        } else {
                            tex_h
                        };
                        let u0 = entry.quad_x / tex_w;
                        let v0 = entry.quad_y / tex_h;
                        let u1 = (entry.quad_x + qw) / tex_w;
                        let v1 = (entry.quad_y + qh) / tex_h;
                        if current_target == RenderTargetId::Screen
                            && !GpuRenderer::aabb_visible_2d(
                                entry.x - entry.ox * entry.sx.abs(),
                                entry.y - entry.oy * entry.sy.abs(),
                                qw * entry.sx.abs(),
                                qh * entry.sy.abs(),
                                t,
                                camera_matrix,
                                renderer.width as f32,
                                renderer.height as f32,
                            )
                        {
                            continue;
                        }
                        push_tex_quad(
                            &mut scratch_tex_verts,
                            &mut scratch_tex_idxs,
                            t,
                            current_color,
                            entry.x,
                            entry.y,
                            entry.rotation,
                            entry.sx,
                            entry.sy,
                            entry.ox,
                            entry.oy,
                            qw,
                            qh,
                            u0,
                            v0,
                            u1,
                            v1,
                        );
                    }
                    let (target_width, target_height) =
                        renderer.target_dimensions(current_target, canvases);
                    append_tex_draw_slices(
                        &mut draws,
                        &mut all_tex_verts,
                        &mut all_tex_idxs,
                        current_target,
                        TexRef::Texture(tex_key),
                        current_blend_mode,
                        normalize_scissor(current_scissor, target_width, target_height),
                        color_mask_bits,
                        active_shader.filter(|key| shaders.contains_key(*key)),
                        stencil_mode,
                        stencil_reference,
                        &scratch_tex_verts,
                        &scratch_tex_idxs,
                    );
                }
            }
            RenderCommand::SetCanvas(canvas) => {
                current_target = match canvas {
                    Some(key) => RenderTargetId::Canvas(*key),
                    None => RenderTargetId::Screen,
                };
                renderer.render_stats.canvas_switches += 1;
            }
            RenderCommand::RegisterCanvas { .. } => {}
            RenderCommand::ResetCanvas(key) => {
                renderer.canvas_needs_clear.insert(*key, true);
            }
            RenderCommand::DrawCanvas {
                canvas_key,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
            } => {
                let Some(gt) = renderer.canvas_gpu_textures.get(*canvas_key) else {
                    renderer.render_diagnostics.record_missing_canvas();
                    restore_state!();
                    return true;
                };
                let w = gt.width as f32;
                let h = gt.height as f32;
                let t = transform_stack_last(&transform_stack);
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                push_tex_quad(
                    &mut scratch_tex_verts,
                    &mut scratch_tex_idxs,
                    t,
                    current_color,
                    *x,
                    *y,
                    *rotation,
                    *sx,
                    *sy,
                    *ox,
                    *oy,
                    w,
                    h,
                    0.0,
                    0.0,
                    1.0,
                    1.0,
                );
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Canvas(*canvas_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::SetPointSize(size) => {
                point_size = *size;
            }
            RenderCommand::SetScissor(rect) => {
                current_scissor = *rect;
            }
            RenderCommand::SetColorMask(r, g, b, a) => {
                color_mask_bits = color_write_mask_bits((*r, *g, *b, *a));
            }
            RenderCommand::SetWireframe(enabled) => {
                wireframe = *enabled;
            }
            RenderCommand::Points { points } => {
                let t = transform_stack_last(&transform_stack);
                let idx_start = all_color_idxs.len();
                let half = point_size * 0.5;
                for &(px, py) in points {
                    let pts = [
                        apply(t, px - half, py - half),
                        apply(t, px + half, py - half),
                        apply(t, px + half, py + half),
                        apply(t, px - half, py + half),
                    ];
                    push_quad_verts(
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        &pts,
                        current_color,
                    );
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
            RenderCommand::PrintFormatted {
                font_key,
                ref text,
                x,
                y,
                limit,
                align,
                scale,
            } => {
                let t = transform_stack_last(&transform_stack);
                renderer.replay_formatted_text(
                    *font_key,
                    text,
                    *x,
                    *y,
                    *limit,
                    *align,
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
            RenderCommand::StencilBegin { action, value } => {
                stencil_mode = GpuStencilMode::Write(*action);
                stencil_reference = *value;
            }
            RenderCommand::StencilEnd => {
                stencil_mode = GpuStencilMode::Disabled;
            }
            RenderCommand::SetStencilTest(test) => match test {
                Some((compare, value)) => {
                    stencil_mode = GpuStencilMode::Test(*compare);
                    stencil_reference = *value;
                }
                None => {
                    stencil_mode = GpuStencilMode::Disabled;
                    stencil_reference = 0;
                }
            },
            RenderCommand::DrawMesh {
                mesh_key,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
            } => {
                if let Some(mesh) = meshes.get(*mesh_key) {
                    let cos_r = rotation.cos();
                    let sin_r = rotation.sin();
                    let parent = transform_stack_last(&transform_stack);
                    let tri_indices = mesh.triangulate();
                    if let Some(tex_key) = mesh.texture {
                        if renderer.gpu_textures.contains_key(tex_key) {
                            scratch_tex_verts.clear();
                            scratch_tex_idxs.clear();
                            reserve_or_skip!(scratch_tex_verts, tri_indices.len());
                            reserve_or_skip!(scratch_tex_idxs, tri_indices.len());
                            let base_idx = 0u32;
                            for (i, &vi) in tri_indices.iter().enumerate() {
                                if let Some(mv) = mesh.vertices.get(vi) {
                                    let lx = (mv.x - ox) * sx;
                                    let ly = (mv.y - oy) * sy;
                                    let rx = lx * cos_r - ly * sin_r + x;
                                    let ry = lx * sin_r + ly * cos_r + y;
                                    let (wx, wy) = apply(parent, rx, ry);
                                    scratch_tex_verts.push(TexVertex {
                                        position: [wx, wy],
                                        uv: [mv.u, mv.v],
                                        color: [
                                            mv.r * current_color[0],
                                            mv.g * current_color[1],
                                            mv.b * current_color[2],
                                            mv.a * current_color[3],
                                        ],
                                        w_depth: 1.0,
                                        _pad: [0.0; 3],
                                    });
                                    scratch_tex_idxs.push(base_idx + i as u32);
                                }
                            }
                            let (target_width, target_height) =
                                renderer.target_dimensions(current_target, canvases);
                            append_tex_draw_slices(
                                &mut draws,
                                &mut all_tex_verts,
                                &mut all_tex_idxs,
                                current_target,
                                TexRef::Texture(tex_key),
                                current_blend_mode,
                                normalize_scissor(current_scissor, target_width, target_height),
                                color_mask_bits,
                                active_shader.filter(|key| shaders.contains_key(*key)),
                                stencil_mode,
                                stencil_reference,
                                &scratch_tex_verts,
                                &scratch_tex_idxs,
                            );
                        }
                    } else {
                        let idx_start = all_color_idxs.len();
                        reserve_or_skip!(all_color_verts, tri_indices.len());
                        reserve_or_skip!(all_color_idxs, tri_indices.len());
                        for &vi in &tri_indices {
                            if let Some(mv) = mesh.vertices.get(vi) {
                                let lx = (mv.x - ox) * sx;
                                let ly = (mv.y - oy) * sy;
                                let rx = lx * cos_r - ly * sin_r + x;
                                let ry = lx * sin_r + ly * cos_r + y;
                                let (wx, wy) = apply(parent, rx, ry);
                                let base = all_color_verts.len() as u32;
                                all_color_verts.push(ColorVertex {
                                    position: [wx, wy],
                                    color: [
                                        mv.r * current_color[0],
                                        mv.g * current_color[1],
                                        mv.b * current_color[2],
                                        mv.a * current_color[3],
                                    ],
                                });
                                all_color_idxs.push(base);
                            }
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
            }
            RenderCommand::DrawMeshTransient {
                mesh,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
            } => {
                let cos_r = rotation.cos();
                let sin_r = rotation.sin();
                let parent = transform_stack_last(&transform_stack);
                let tri_indices = mesh.triangulate();
                if let Some(tex_key) = mesh.texture {
                    if renderer.gpu_textures.contains_key(tex_key) {
                        scratch_tex_verts.clear();
                        scratch_tex_idxs.clear();
                        reserve_or_skip!(scratch_tex_verts, tri_indices.len());
                        reserve_or_skip!(scratch_tex_idxs, tri_indices.len());
                        let base_idx = 0u32;
                        for (i, &vi) in tri_indices.iter().enumerate() {
                            if let Some(mv) = mesh.vertices.get(vi) {
                                let lx = (mv.x - ox) * sx;
                                let ly = (mv.y - oy) * sy;
                                let rx = lx * cos_r - ly * sin_r + x;
                                let ry = lx * sin_r + ly * cos_r + y;
                                let (wx, wy) = apply(parent, rx, ry);
                                scratch_tex_verts.push(TexVertex {
                                    position: [wx, wy],
                                    uv: [mv.u, mv.v],
                                    color: [
                                        mv.r * current_color[0],
                                        mv.g * current_color[1],
                                        mv.b * current_color[2],
                                        mv.a * current_color[3],
                                    ],
                                    w_depth: 1.0,
                                    _pad: [0.0; 3],
                                });
                                scratch_tex_idxs.push(base_idx + i as u32);
                            }
                        }
                        let (target_width, target_height) =
                            renderer.target_dimensions(current_target, canvases);
                        append_tex_draw_slices(
                            &mut draws,
                            &mut all_tex_verts,
                            &mut all_tex_idxs,
                            current_target,
                            TexRef::Texture(tex_key),
                            current_blend_mode,
                            normalize_scissor(current_scissor, target_width, target_height),
                            color_mask_bits,
                            active_shader.filter(|key| shaders.contains_key(*key)),
                            stencil_mode,
                            stencil_reference,
                            &scratch_tex_verts,
                            &scratch_tex_idxs,
                        );
                    }
                } else {
                    let idx_start = all_color_idxs.len();
                    reserve_or_skip!(all_color_verts, tri_indices.len());
                    reserve_or_skip!(all_color_idxs, tri_indices.len());
                    for &vi in &tri_indices {
                        if let Some(mv) = mesh.vertices.get(vi) {
                            let lx = (mv.x - ox) * sx;
                            let ly = (mv.y - oy) * sy;
                            let rx = lx * cos_r - ly * sin_r + x;
                            let ry = lx * sin_r + ly * cos_r + y;
                            let (wx, wy) = apply(parent, rx, ry);
                            let base = all_color_verts.len() as u32;
                            all_color_verts.push(ColorVertex {
                                position: [wx, wy],
                                color: [
                                    mv.r * current_color[0],
                                    mv.g * current_color[1],
                                    mv.b * current_color[2],
                                    mv.a * current_color[3],
                                ],
                            });
                            all_color_idxs.push(base);
                        }
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
            RenderCommand::SyncMesh { mesh_key, mesh } => {
                if renderer.sync_mesh(*mesh_key, mesh).is_err() {
                    renderer.render_diagnostics.record_invalid_mesh();
                }
            }
            RenderCommand::DrawNineSlice {
                texture_key,
                tex_w,
                tex_h,
                top,
                right,
                bottom,
                left,
                x,
                y,
                w,
                h,
            } => {
                if !renderer.gpu_textures.contains_key(*texture_key) {
                    renderer.render_diagnostics.record_missing_texture();
                    restore_state!();
                    return true;
                }
                let t = transform_stack_last(&transform_stack);
                let ns = crate::sprite::NineSlice::new(
                    *texture_key,
                    *top,
                    *right,
                    *bottom,
                    *left,
                    *tex_w,
                    *tex_h,
                );
                let patches = ns.patches(*x, *y, *w, *h);
                scratch_tex_verts.clear();
                scratch_tex_idxs.clear();
                reserve_or_skip!(scratch_tex_verts, 4 * 9);
                reserve_or_skip!(scratch_tex_idxs, 6 * 9);
                for &(sx, sy, sw, sh, dx, dy, dw, dh) in &patches {
                    if sw <= 0.0 || sh <= 0.0 || dw <= 0.0 || dh <= 0.0 {
                        continue;
                    }
                    let u0 = sx / tex_w;
                    let v0 = sy / tex_h;
                    let u1 = (sx + sw) / tex_w;
                    let v1 = (sy + sh) / tex_h;
                    push_tex_quad(
                        &mut scratch_tex_verts,
                        &mut scratch_tex_idxs,
                        t,
                        current_color,
                        dx,
                        dy,
                        0.0,
                        1.0,
                        1.0,
                        0.0,
                        0.0,
                        dw,
                        dh,
                        u0,
                        v0,
                        u1,
                        v1,
                    );
                }
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                append_tex_draw_slices(
                    &mut draws,
                    &mut all_tex_verts,
                    &mut all_tex_idxs,
                    current_target,
                    TexRef::Texture(*texture_key),
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                    &scratch_tex_verts,
                    &scratch_tex_idxs,
                );
            }
            RenderCommand::SetShader(shader) => {
                active_shader = shader.filter(|key| shaders.contains_key(*key));
            }
            RenderCommand::SetTextShader(shader) => {
                active_text_shader = shader.filter(|key| shaders.contains_key(*key));
            }
            RenderCommand::DrawShape {
                shape_key,
                x,
                y,
                rotation,
                sx,
                sy,
                ox,
                oy,
            } => {
                let Some(shape) = shapes.get(*shape_key) else {
                    renderer.render_diagnostics.record_missing_shape();
                    restore_state!();
                    return true;
                };
                if let Err(err) = validate_compound_shape(shape, &render_input_limits) {
                    renderer.render_diagnostics.record_invalid_render_input();
                    log::warn!("Skipping invalid shape command: {}", err);
                    restore_state!();
                    return true;
                }
                let parent = transform_stack_last(&transform_stack);
                let local = Mat3::from_translation(Vec2 { x: *x, y: *y })
                    * Mat3::from_rotation(*rotation)
                    * Mat3::from_scale(Vec2 { x: *sx, y: *sy })
                    * Mat3::from_translation(Vec2 { x: -*ox, y: -*oy });
                let shape_transform = *parent * local;
                renderer.replay_compound_shape(
                    shape,
                    &shape_transform,
                    wireframe,
                    current_target,
                    current_blend_mode,
                    current_scissor,
                    color_mask_bits,
                    active_text_shader.or(active_shader),
                    stencil_mode,
                    stencil_reference,
                    canvases,
                    shaders,
                    &mut all_color_verts,
                    &mut all_color_idxs,
                    &mut draws,
                );
            }
            RenderCommand::DrawParticleSystem {
                ref particles,
                shader,
            } => {
                if particles.is_empty() {
                    restore_state!();
                    return true;
                }
                let t = transform_stack_last(&transform_stack);
                let (target_width, target_height) =
                    renderer.target_dimensions(current_target, canvases);
                let scissor = normalize_scissor(current_scissor, target_width, target_height);
                let max_particle_vertices = particles.len().saturating_mul(40);
                let max_particle_indices = particles.len().saturating_mul(120);
                let mut pverts: Vec<ColorVertex> = Vec::new();
                let mut pidxs: Vec<u32> = Vec::new();
                let mut shader_pverts: Vec<ParticleVertex> = Vec::new();
                let mut shader_pidxs: Vec<u32> = Vec::new();
                reserve_or_skip!(pverts, max_particle_vertices);
                reserve_or_skip!(pidxs, max_particle_indices);
                reserve_or_skip!(shader_pverts, max_particle_vertices);
                reserve_or_skip!(shader_pidxs, max_particle_indices);
                let mut shader_textured_batches: Vec<(TextureKey, Vec<ParticleVertex>, Vec<u32>)> =
                    Vec::new();
                use std::f32::consts::PI;
                for inst in particles {
                    let color = [inst.r, inst.g, inst.b, inst.a];
                    let half = inst.size * 0.5;
                    let vertex_start = pverts.len();
                    let index_start = pidxs.len();
                    match &inst.shape {
                        ParticleRenderShape::Square | ParticleRenderShape::Diamond => {
                            let cos_r = inst.rotation.cos();
                            let sin_r = inst.rotation.sin();
                            let corners =
                                [(-half, -half), (half, -half), (half, half), (-half, half)];
                            let base = pverts.len() as u32;
                            for (lx, ly) in corners {
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + lx * cos_r - ly * sin_r,
                                    inst.y + lx * sin_r + ly * cos_r,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            pidxs.extend_from_slice(&[
                                base,
                                base + 1,
                                base + 2,
                                base,
                                base + 2,
                                base + 3,
                            ]);
                        }
                        ParticleRenderShape::Circle => {
                            renderer.tess_ellipse(
                                &mut pverts,
                                &mut pidxs,
                                t,
                                color,
                                &DrawMode::Fill,
                                inst.x,
                                inst.y,
                                half,
                                half,
                                12,
                                0.0,
                            );
                        }
                        ParticleRenderShape::Puff => {
                            renderer.tess_ellipse(
                                &mut pverts,
                                &mut pidxs,
                                t,
                                color,
                                &DrawMode::Fill,
                                inst.x,
                                inst.y,
                                half,
                                half,
                                24,
                                0.0,
                            );
                        }
                        ParticleRenderShape::Triangle => {
                            let base = pverts.len() as u32;
                            for i in 0..3u32 {
                                let a = inst.rotation - PI * 0.5 + i as f32 * (2.0 * PI / 3.0);
                                let (sx, sy) =
                                    apply(t, inst.x + a.cos() * half, inst.y + a.sin() * half);
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            pidxs.extend_from_slice(&[base, base + 1, base + 2]);
                        }
                        ParticleRenderShape::Spark => {
                            let len = inst.size * 1.5;
                            let dx = inst.rotation.cos() * len;
                            let dy = inst.rotation.sin() * len;
                            push_thick_line(
                                &mut pverts,
                                &mut pidxs,
                                t,
                                color,
                                inst.x - dx,
                                inst.y - dy,
                                inst.x + dx,
                                inst.y + dy,
                                1.5,
                            );
                        }
                        ParticleRenderShape::Shrapnel { edges, seed } => {
                            let n = (*edges).clamp(3, 12) as usize;
                            let center_idx = pverts.len() as u32;
                            let (csx, csy) = apply(t, inst.x, inst.y);
                            pverts.push(ColorVertex {
                                position: [csx, csy],
                                color,
                            });
                            let mut rng = u64::from(*seed);
                            for i in 0..n {
                                let base_angle = inst.rotation + i as f32 * (2.0 * PI / n as f32);
                                rng = rng
                                    .wrapping_mul(6_364_136_223_846_793_005)
                                    .wrapping_add(1_442_695_040_888_963_407);
                                let jitter_a = (rng >> 33) as f32 / u32::MAX as f32 * 0.4 - 0.2;
                                rng = rng
                                    .wrapping_mul(6_364_136_223_846_793_005)
                                    .wrapping_add(1_442_695_040_888_963_407);
                                let jitter_r = 0.5 + (rng >> 33) as f32 / u32::MAX as f32 * 0.5;
                                let angle = base_angle + jitter_a * (2.0 * PI / n as f32);
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + angle.cos() * half * jitter_r,
                                    inst.y + angle.sin() * half * jitter_r,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            for i in 0..n as u32 {
                                let c = center_idx;
                                let b = center_idx + 1 + i;
                                let d = center_idx + 1 + (i + 1) % n as u32;
                                pidxs.extend_from_slice(&[c, b, d]);
                            }
                        }
                        ParticleRenderShape::Ray { aspect } => {
                            let a = if *aspect <= 0.0 { 4.0_f32 } else { *aspect };
                            let half_len = half * a;
                            let cos_r = inst.rotation.cos();
                            let sin_r = inst.rotation.sin();
                            let corners = [
                                (-half_len, -half),
                                (half_len, -half),
                                (half_len, half),
                                (-half_len, half),
                            ];
                            let base = pverts.len() as u32;
                            for (lx, ly) in corners {
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + lx * cos_r - ly * sin_r,
                                    inst.y + lx * sin_r + ly * cos_r,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            pidxs.extend_from_slice(&[
                                base,
                                base + 1,
                                base + 2,
                                base,
                                base + 2,
                                base + 3,
                            ]);
                        }
                        ParticleRenderShape::Ring { thickness } => {
                            let outer = half;
                            let inner = outer * (1.0 - (*thickness).clamp(0.05, 1.0));
                            /// Number of vertices used to approximate a circular arc in the fallback path.
                            const N: usize = 20;
                            let base = pverts.len() as u32;
                            for i in 0..N {
                                let angle = i as f32 * (2.0 * PI / N as f32);
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + angle.cos() * outer,
                                    inst.y + angle.sin() * outer,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + angle.cos() * inner,
                                    inst.y + angle.sin() * inner,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            for i in 0..N as u32 {
                                let j = (i + 1) % N as u32;
                                let o0 = base + i * 2;
                                let i0 = base + i * 2 + 1;
                                let o1 = base + j * 2;
                                let i1 = base + j * 2 + 1;
                                pidxs.extend_from_slice(&[o0, o1, i0, i0, o1, i1]);
                            }
                        }
                        ParticleRenderShape::Capsule => {
                            let half_len = half;
                            let cap_r = half * 0.4;
                            let cos_r = inst.rotation.cos();
                            let sin_r = inst.rotation.sin();
                            let corners = [
                                (-half_len, -cap_r),
                                (half_len, -cap_r),
                                (half_len, cap_r),
                                (-half_len, cap_r),
                            ];
                            let base = pverts.len() as u32;
                            for (lx, ly) in corners {
                                let (sx, sy) = apply(
                                    t,
                                    inst.x + lx * cos_r - ly * sin_r,
                                    inst.y + lx * sin_r + ly * cos_r,
                                );
                                pverts.push(ColorVertex {
                                    position: [sx, sy],
                                    color,
                                });
                            }
                            pidxs.extend_from_slice(&[
                                base,
                                base + 1,
                                base + 2,
                                base,
                                base + 2,
                                base + 3,
                            ]);
                            /// Number of vertices used to approximate a circle outline in the fallback path.
                            const N: usize = 8;
                            for side in [1.0_f32, -1.0] {
                                let cap_cx = inst.x + cos_r * half_len * side;
                                let cap_cy = inst.y + sin_r * half_len * side;
                                let center_idx = pverts.len() as u32;
                                let (csx, csy) = apply(t, cap_cx, cap_cy);
                                pverts.push(ColorVertex {
                                    position: [csx, csy],
                                    color,
                                });
                                let start_a =
                                    inst.rotation + if side > 0.0 { -PI * 0.5 } else { PI * 0.5 };
                                for i in 0..=N {
                                    let a = start_a + i as f32 * PI / N as f32;
                                    let (sx, sy) = apply(
                                        t,
                                        cap_cx + a.cos() * cap_r,
                                        cap_cy + a.sin() * cap_r,
                                    );
                                    pverts.push(ColorVertex {
                                        position: [sx, sy],
                                        color,
                                    });
                                }
                                for i in 0..N as u32 {
                                    pidxs.extend_from_slice(&[
                                        center_idx,
                                        center_idx + 1 + i,
                                        center_idx + 1 + i + 1,
                                    ]);
                                }
                            }
                        }
                    }
                    if shader.is_some() {
                        let mut particle_vertices = Vec::new();
                        let mut particle_indices = Vec::new();
                        reserve_or_skip!(
                            particle_vertices,
                            pverts.len().saturating_sub(vertex_start)
                        );
                        reserve_or_skip!(particle_indices, pidxs.len().saturating_sub(index_start));
                        let (center_x, center_y) = apply(t, inst.x, inst.y);
                        let inv_size = if inst.size.abs() > f32::EPSILON {
                            1.0 / inst.size.abs()
                        } else {
                            0.0
                        };
                        let atlas_quad = inst
                            .quad
                            .zip(inst.quad_tex_dims)
                            .filter(|(_, (tex_w, tex_h))| *tex_w > 0.0 && *tex_h > 0.0);
                        for vertex in &pverts[vertex_start..] {
                            let local_uv = [
                                ((vertex.position[0] - center_x) * inv_size + 0.5).clamp(0.0, 1.0),
                                ((vertex.position[1] - center_y) * inv_size + 0.5).clamp(0.0, 1.0),
                            ];
                            let uv = if let Some(([qx, qy, qw, qh], (tex_w, tex_h))) = atlas_quad {
                                [
                                    (qx + qw * local_uv[0]) / tex_w,
                                    (qy + qh * local_uv[1]) / tex_h,
                                ]
                            } else {
                                local_uv
                            };
                            particle_vertices.push(ParticleVertex {
                                position: vertex.position,
                                color: vertex.color,
                                uv,
                                local_pos: [inst.local_x, inst.local_y],
                                world_pos: [inst.x, inst.y],
                                velocity: [inst.velocity_x, inst.velocity_y],
                                normalized_age: inst.normalized_age,
                                lifetime: inst.lifetime,
                                seed: inst.seed as f32,
                                _pad: 0.0,
                            });
                        }
                        for idx in &pidxs[index_start..] {
                            particle_indices.push(idx.saturating_sub(vertex_start as u32));
                        }
                        if let Some(texture_key) = inst.texture_key {
                            let batch_index = shader_textured_batches
                                .iter()
                                .position(|(key, _, _)| *key == texture_key);
                            let batch = match batch_index {
                                Some(index) => &mut shader_textured_batches[index],
                                None => {
                                    shader_textured_batches.push((
                                        texture_key,
                                        Vec::new(),
                                        Vec::new(),
                                    ));
                                    let Some(batch) = shader_textured_batches.last_mut() else {
                                        renderer.render_diagnostics.record_invalid_render_input();
                                        restore_state!();
                                        return true;
                                    };
                                    batch
                                }
                            };
                            let particle_base = batch.1.len() as u32;
                            batch.1.extend_from_slice(&particle_vertices);
                            batch
                                .2
                                .extend(particle_indices.iter().map(|idx| particle_base + *idx));
                        } else {
                            let particle_base = shader_pverts.len() as u32;
                            shader_pverts.extend_from_slice(&particle_vertices);
                            shader_pidxs
                                .extend(particle_indices.iter().map(|idx| particle_base + *idx));
                        }
                    }
                }
                if let Some(shader_key) = shader.filter(|key| shaders.contains_key(*key)) {
                    if !shader_pverts.is_empty() {
                        let idx_start = all_particle_idxs.len() as u32;
                        let base = all_particle_verts.len() as u32;
                        let idx_count = shader_pidxs.len() as u32;
                        all_particle_verts.extend_from_slice(&shader_pverts);
                        all_particle_idxs.extend(shader_pidxs.iter().map(|idx| base + *idx));
                        draws.push(PreparedDraw {
                            target: current_target,
                            geometry: GeometryKind::Particle,
                            texture_ref: None,
                            idx_start,
                            idx_count,
                            blend_mode: current_blend_mode,
                            scissor,
                            color_mask_bits,
                            shader: Some(shader_key),
                            stencil_mode,
                            stencil_reference: stencil_reference as u32,
                            static_geometry: None,
                            instance_buffer: None,
                            instance_start: 0,
                            instance_count: 1,
                        });
                    }
                    for (texture_key, batch_verts, batch_idxs) in shader_textured_batches {
                        if batch_verts.is_empty() {
                            continue;
                        }
                        let idx_start = all_particle_idxs.len() as u32;
                        let base = all_particle_verts.len() as u32;
                        let idx_count = batch_idxs.len() as u32;
                        all_particle_verts.extend_from_slice(&batch_verts);
                        all_particle_idxs.extend(batch_idxs.iter().map(|idx| base + *idx));
                        draws.push(PreparedDraw {
                            target: current_target,
                            geometry: GeometryKind::ParticleTextured,
                            texture_ref: Some(TexRef::Texture(texture_key)),
                            idx_start,
                            idx_count,
                            blend_mode: current_blend_mode,
                            scissor,
                            color_mask_bits,
                            shader: Some(shader_key),
                            stencil_mode,
                            stencil_reference: stencil_reference as u32,
                            static_geometry: None,
                            instance_buffer: None,
                            instance_start: 0,
                            instance_count: 1,
                        });
                    }
                } else if !pverts.is_empty() {
                    let particle_shader = active_shader.filter(|key| shaders.contains_key(*key));
                    append_color_draw(
                        &mut draws,
                        &mut all_color_verts,
                        &mut all_color_idxs,
                        current_target,
                        current_blend_mode,
                        scissor,
                        color_mask_bits,
                        particle_shader,
                        stencil_mode,
                        stencil_reference,
                        pverts,
                        pidxs,
                    );
                }
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
