//! Owns the render GPU renderer frame implementation for the render subsystem and keeps related runtime rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU renderer frame data is validated, transformed, or stored before neighboring systems consume it.
//! Separates render GPU renderer frame behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU renderer frame defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near render GPU renderer frame state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping render GPU renderer frame calculations at their owning subsystem boundary.
//! Provides adaptation layer that lets callers reuse render GPU renderer frame rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on render GPU renderer frame state, helpers, or rules.

use super::*;

/// Carries mutable frame encoding state across the split GPU renderer command handlers.
pub(super) struct FrameCommandContext<'a> {
    pub(super) fonts: &'a mut SlotMap<FontKey, crate::font::Font>,
    pub(super) sprite_batches: &'a SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch>,
    pub(super) shapes: &'a SlotMap<ShapeKey, crate::render::CompoundShape>,
    pub(super) canvases: &'a SlotMap<CanvasKey, crate::render::Canvas>,
    pub(super) meshes: &'a SlotMap<MeshKey, Mesh>,
    pub(super) shaders: &'a SlotMap<ShaderKey, Shader>,
    pub(super) default_filter: &'a (String, String, u32),
    pub(super) camera_matrix: &'a Mat3,
    pub(super) render_input_limits: RenderInputLimits,
    pub(super) current_target: RenderTargetId,
    pub(super) current_blend_mode: BlendMode,
    pub(super) current_scissor: Option<(f32, f32, f32, f32)>,
    pub(super) current_color: [f32; 4],
    pub(super) color_mask_bits: u32,
    pub(super) wireframe: bool,
    pub(super) line_width: f32,
    pub(super) point_size: f32,
    pub(super) transform_stack: Vec<Mat3>,
    pub(super) stencil_mode: GpuStencilMode,
    pub(super) stencil_reference: u8,
    pub(super) active_shader: Option<ShaderKey>,
    pub(super) active_text_shader: Option<ShaderKey>,
    pub(super) pending_postfx: Vec<(u64, Vec<crate::render::renderer::PostFxPass>, u32, u32)>,
    pub(super) pending_canvas_postfx: Vec<(CanvasKey, Vec<crate::render::renderer::PostFxPass>)>,
    pub(super) pending_canvas_effects: Vec<(
        CanvasKey,
        CanvasKey,
        Vec<crate::render::renderer::PostFxPass>,
    )>,
    pub(super) pending_province_maps: Vec<PendingProvinceMapDraw>,
    pub(super) all_color_verts: Vec<ColorVertex>,
    pub(super) all_color_idxs: Vec<u32>,
    pub(super) all_tex_verts: Vec<TexVertex>,
    pub(super) all_tex_idxs: Vec<u32>,
    pub(super) all_particle_verts: Vec<ParticleVertex>,
    pub(super) all_particle_idxs: Vec<u32>,
    pub(super) draws: Vec<PreparedDraw>,
    pub(super) frame_instances: Vec<crate::render::gpu_types::InstanceData>,
    pub(super) scratch_color_verts: Vec<ColorVertex>,
    pub(super) scratch_color_idxs: Vec<u32>,
    pub(super) scratch_tex_verts: Vec<TexVertex>,
    pub(super) scratch_tex_idxs: Vec<u32>,
}

impl GpuRenderer {
    /// Renders a full frame of deferred draw commands to the surface swapchain texture.
    #[allow(clippy::too_many_arguments)]
    #[allow(unused_mut)]
    pub fn render_frame(
        &mut self,
        surface: &wgpu::Surface<'static>,
        commands: &[RenderCommand],
        province_registries: &HashMap<String, crate::province::registry::ProvinceRegistry>,
        textures: &SlotMap<TextureKey, TextureData>,
        fonts: &mut SlotMap<FontKey, crate::font::Font>,
        light_world: &crate::light::light_world::LightWorld,
        sprite_batches: &SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch>,
        shapes: &SlotMap<ShapeKey, crate::render::CompoundShape>,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        meshes: &SlotMap<MeshKey, Mesh>,
        shaders: &SlotMap<ShaderKey, Shader>,
        default_filter: &(String, String, u32),
        background_color: [f32; 4],
        camera_matrix: &Mat3,
        frame_time: f32,
        frame_count: u64,
        capture_screenshot: bool,
    ) -> Result<Option<(u32, u32, Vec<u8>)>, wgpu::SurfaceError> {
        let frame_start = Instant::now();
        let completed_screenshot = self.poll_surface_readback();
        self.render_diagnostics_total
            .accumulate(&self.render_diagnostics);
        self.render_diagnostics.reset();
        self.prune_released_resources(textures, fonts, canvases, shaders, meshes);
        for (key, tex_data) in textures.iter() {
            let existing = self
                .gpu_textures
                .get(key)
                .map(|texture| (texture.width, texture.height, texture.source_revision));
            if texture_needs_upload(existing, tex_data) {
                if let Err(err) = self.upload_texture(key, tex_data, default_filter) {
                    self.render_diagnostics.record_invalid_texture_upload();
                    log::warn!("Skipping invalid texture upload for {:?}: {}", key, err);
                }
            }
        }
        self.sync_canvas_targets(canvases, default_filter);
        self.render_stats = RenderStats::default();
        let mut frame_buffers = std::mem::take(&mut self.frame_buffers);
        frame_buffers.clear_for_frame();
        let FrameRenderBuffers {
            color_verts: mut all_color_verts,
            color_idxs: mut all_color_idxs,
            tex_verts: mut all_tex_verts,
            tex_idxs: mut all_tex_idxs,
            particle_verts: mut all_particle_verts,
            particle_idxs: mut all_particle_idxs,
            mut draws,
            instances: mut frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            mut scratch_tex_verts,
            mut scratch_tex_idxs,
            mut merged_draws,
        } = frame_buffers;
        let mut current_target = RenderTargetId::Screen;
        let mut current_blend_mode = BlendMode::Alpha;
        let mut current_scissor: Option<(f32, f32, f32, f32)> = None;
        let mut current_color = [1.0f32, 1.0, 1.0, 1.0];
        let mut color_mask_bits = color_write_mask_bits((true, true, true, true));
        let mut wireframe = false;
        let mut line_width = 1.0f32;
        let mut point_size = 1.0f32;
        let mut transform_stack: Vec<Mat3> = vec![Mat3::identity()];
        let mut stencil_mode = GpuStencilMode::Disabled;
        let mut stencil_reference = 0u8;
        let mut active_shader: Option<ShaderKey> = None;
        let mut active_text_shader: Option<ShaderKey> = None;
        let render_input_limits = RenderInputLimits::default();
        let render_budget_limits = RenderBudgetLimits::for_device(&self.device.limits());
        let mut render_budget = RenderBudget::default();
        let mut pending_postfx: Vec<(u64, Vec<crate::render::renderer::PostFxPass>, u32, u32)> =
            Vec::new();
        let mut pending_canvas_postfx: Vec<(CanvasKey, Vec<crate::render::renderer::PostFxPass>)> =
            Vec::new();
        let mut pending_canvas_effects: Vec<(
            CanvasKey,
            CanvasKey,
            Vec<crate::render::renderer::PostFxPass>,
        )> = Vec::new();
        let mut pending_province_maps: Vec<PendingProvinceMapDraw> = Vec::new();
        let mut command_context = FrameCommandContext {
            fonts,
            sprite_batches,
            shapes,
            canvases,
            meshes,
            shaders,
            default_filter,
            camera_matrix,
            render_input_limits,
            current_target,
            current_blend_mode,
            current_scissor,
            current_color,
            color_mask_bits,
            wireframe,
            line_width,
            point_size,
            transform_stack,
            stencil_mode,
            stencil_reference,
            active_shader,
            active_text_shader,
            pending_postfx,
            pending_canvas_postfx,
            pending_canvas_effects,
            pending_province_maps,
            all_color_verts,
            all_color_idxs,
            all_tex_verts,
            all_tex_idxs,
            all_particle_verts,
            all_particle_idxs,
            draws,
            frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            scratch_tex_verts,
            scratch_tex_idxs,
        };
        let commands = match validate_render_frame_state(commands) {
            Ok(()) => commands,
            Err(error) => {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!("Rejecting frame with invalid render scope state: {error}");
                &[]
            }
        };
        for cmd in commands {
            if let Err(err) = validate_render_command_with_category(cmd, &render_input_limits) {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!("Skipping invalid render command: {}", err);
                continue;
            }
            let batch_items = match cmd {
                RenderCommand::DrawBatch { batch_key } => command_context
                    .sprite_batches
                    .get(*batch_key)
                    .map_or(0, crate::sprite::SpriteBatch::len),
                _ => 0,
            };
            if let Err(err) =
                render_budget.try_accept_with_batch_items(cmd, batch_items, &render_budget_limits)
            {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!(
                    "Skipping render command that exceeds the frame budget: {}",
                    err
                );
                continue;
            }
            if command_context.handle_basic_render_command(self, cmd)
                || command_context.handle_mid_render_command(self, cmd)
                || command_context.handle_advanced_render_command(self, cmd)
            {
                continue;
            }
        }
        let FrameCommandContext {
            pending_postfx,
            pending_canvas_postfx,
            pending_canvas_effects,
            pending_province_maps,
            mut all_color_verts,
            mut all_color_idxs,
            mut all_tex_verts,
            mut all_tex_idxs,
            mut all_particle_verts,
            mut all_particle_idxs,
            mut draws,
            mut frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            scratch_tex_verts,
            scratch_tex_idxs,
            ..
        } = command_context;
        self.render_stats.batched_draws +=
            merge_adjacent_prepared_draws(&mut draws, &mut merged_draws) as u32;
        {
            let color_v_pct = all_color_verts.len() * 100 / self.color_vertex_capacity as usize;
            if color_v_pct >= 90 {
                log::warn!(
                    "[G003] color vertex buffer at {}% capacity ({}/{}) Ă˘â‚¬â€ť consider reducing draw calls or increasing MAX_COLOR_VERTS",
                    color_v_pct, all_color_verts.len(), self.color_vertex_capacity
                );
            }
            let color_i_pct = all_color_idxs.len() * 100 / self.color_index_capacity as usize;
            if color_i_pct >= 90 {
                log::warn!(
                    "[G003] color index buffer at {}% capacity ({}/{}) Ă˘â‚¬â€ť consider reducing draw calls or increasing MAX_COLOR_IDXS",
                    color_i_pct, all_color_idxs.len(), self.color_index_capacity
                );
            }
            let tex_v_pct = all_tex_verts.len() * 100 / self.tex_vertex_capacity as usize;
            if tex_v_pct >= 90 {
                log::warn!(
                    "[G003] tex vertex buffer at {}% capacity ({}/{}) Ă˘â‚¬â€ť consider reducing sprite draws or increasing MAX_TEX_VERTS",
                    tex_v_pct, all_tex_verts.len(), self.tex_vertex_capacity
                );
            }
            let tex_i_pct = all_tex_idxs.len() * 100 / self.tex_index_capacity as usize;
            if tex_i_pct >= 90 {
                log::warn!(
                    "[G003] tex index buffer at {}% capacity ({}/{}) Ă˘â‚¬â€ť consider reducing sprite draws or increasing MAX_TEX_IDXS",
                    tex_i_pct, all_tex_idxs.len(), self.tex_index_capacity
                );
            }
        }
        let geometry_limits = self.device.limits();
        if let Err(error) = crate::render::gpu_resources::validate_dynamic_buffer_bytes(
            &[
                (all_color_verts.len(), std::mem::size_of::<ColorVertex>()),
                (all_color_idxs.len(), std::mem::size_of::<u32>()),
                (all_tex_verts.len(), std::mem::size_of::<TexVertex>()),
                (all_tex_idxs.len(), std::mem::size_of::<u32>()),
                (
                    all_particle_verts.len(),
                    std::mem::size_of::<ParticleVertex>(),
                ),
                (all_particle_idxs.len(), std::mem::size_of::<u32>()),
                (
                    frame_instances.len(),
                    std::mem::size_of::<crate::render::gpu_types::InstanceData>(),
                ),
            ],
            &geometry_limits,
        ) {
            self.render_diagnostics.record_invalid_render_input();
            log::warn!("Skipping frame geometry that exceeds the device buffer budget: {error}");
            all_color_verts.clear();
            all_color_idxs.clear();
            all_tex_verts.clear();
            all_tex_idxs.clear();
            all_particle_verts.clear();
            all_particle_idxs.clear();
            draws.clear();
            frame_instances.clear();
        }
        if let Err(error) = self.ensure_geometry_buffer_capacity(
            all_color_verts.len(),
            all_color_idxs.len(),
            all_tex_verts.len(),
            all_tex_idxs.len(),
            all_particle_verts.len(),
            all_particle_idxs.len(),
        ) {
            self.render_diagnostics.record_invalid_render_input();
            log::warn!("Skipping frame because geometry buffer growth was rejected: {error}");
            all_color_verts.clear();
            all_color_idxs.clear();
            all_tex_verts.clear();
            all_tex_idxs.clear();
            all_particle_verts.clear();
            all_particle_idxs.clear();
            draws.clear();
            frame_instances.clear();
        }
        if !all_color_verts.is_empty() {
            self.queue.write_buffer(
                &self.color_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_color_verts),
            );
            self.queue.write_buffer(
                &self.color_index_buffer,
                0,
                bytemuck::cast_slice(&all_color_idxs),
            );
        }
        if !all_tex_verts.is_empty() {
            self.queue.write_buffer(
                &self.tex_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_tex_verts),
            );
            self.queue.write_buffer(
                &self.tex_index_buffer,
                0,
                bytemuck::cast_slice(&all_tex_idxs),
            );
        }
        if !all_particle_verts.is_empty() {
            self.queue.write_buffer(
                &self.particle_vertex_buffer,
                0,
                bytemuck::cast_slice(&all_particle_verts),
            );
            self.queue.write_buffer(
                &self.particle_index_buffer,
                0,
                bytemuck::cast_slice(&all_particle_idxs),
            );
        }
        if !frame_instances.is_empty() {
            if let Err(error) = self.ensure_instance_buffer_capacity(frame_instances.len()) {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!(
                    "Skipping instances because instance buffer growth was rejected: {error}"
                );
                frame_instances.clear();
            }
        }
        if !frame_instances.is_empty() {
            self.queue.write_buffer(
                &self.instance_buffer,
                0,
                bytemuck::cast_slice(&frame_instances),
            );
        }
        let output = match surface.get_current_texture() {
            Ok(output) => output,
            Err(err) => {
                self.frame_buffers = FrameRenderBuffers {
                    color_verts: all_color_verts,
                    color_idxs: all_color_idxs,
                    tex_verts: all_tex_verts,
                    tex_idxs: all_tex_idxs,
                    particle_verts: all_particle_verts,
                    particle_idxs: all_particle_idxs,
                    draws,
                    instances: frame_instances,
                    scratch_color_verts,
                    scratch_color_idxs,
                    scratch_tex_verts,
                    scratch_tex_idxs,
                    merged_draws,
                };
                return Err(err);
            }
        };
        let view = output
            .texture
            .create_view(&wgpu::TextureViewDescriptor::default());
        self.ensure_screen_stencil_target();
        let mut encoder = self
            .device
            .create_command_encoder(&wgpu::CommandEncoderDescriptor {
                label: Some("render_encoder"),
            });
        let mut screen_started = false;
        if !pending_province_maps.is_empty() {
            self.draw_province_maps_to_screen(
                &mut encoder,
                &view,
                &pending_province_maps,
                province_registries,
                background_color,
                &mut screen_started,
            );
        }
        let mut touched_canvases: HashSet<CanvasKey> = HashSet::new();
        let mut cursor = 0usize;
        while cursor < draws.len() {
            let target = draws[cursor].target;
            match target {
                RenderTargetId::Screen => {}
                RenderTargetId::Canvas(key) => {
                    let Some(canvas) = canvases.get(key) else {
                        self.render_diagnostics.record_missing_canvas();
                        while cursor < draws.len() && draws[cursor].target == target {
                            cursor += 1;
                        }
                        continue;
                    };
                    self.ensure_canvas_stencil_target(key, canvas.width, canvas.height);
                }
            }
            let (target_width, target_height) = self.target_dimensions(target, canvases);
            self.update_viewport_uniform(target_width, target_height, camera_matrix, frame_time);
            let (color_view, color_load, stencil_view, stencil_load, clear_canvas_after_pass) =
                match target {
                    RenderTargetId::Screen => {
                        let Some(stencil_target) = self.screen_stencil_target.as_ref() else {
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let stencil_view = &stencil_target.view;
                        let color_load = if screen_started {
                            wgpu::LoadOp::Load
                        } else {
                            wgpu::LoadOp::Clear(wgpu::Color {
                                r: background_color[0] as f64,
                                g: background_color[1] as f64,
                                b: background_color[2] as f64,
                                a: background_color[3] as f64,
                            })
                        };
                        let stencil_load = if screen_started {
                            wgpu::LoadOp::Load
                        } else {
                            wgpu::LoadOp::Clear(0)
                        };
                        (&view, color_load, stencil_view, stencil_load, None)
                    }
                    RenderTargetId::Canvas(key) => {
                        let Some(canvas_texture) = self.canvas_gpu_textures.get(key) else {
                            self.render_diagnostics.record_missing_canvas();
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let Some(stencil_target) = self.canvas_stencil_targets.get(key) else {
                            self.render_diagnostics.record_missing_canvas();
                            while cursor < draws.len() && draws[cursor].target == target {
                                cursor += 1;
                            }
                            continue;
                        };
                        let canvas_view = &canvas_texture.view;
                        let stencil_view = &stencil_target.view;
                        let first_use_this_frame = touched_canvases.insert(key);
                        let needs_clear = self.canvas_needs_clear.get(key).copied().unwrap_or(true);
                        let color_load = if needs_clear {
                            wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT)
                        } else {
                            wgpu::LoadOp::Load
                        };
                        let stencil_load = if first_use_this_frame {
                            wgpu::LoadOp::Clear(0)
                        } else {
                            wgpu::LoadOp::Load
                        };
                        (
                            canvas_view,
                            color_load,
                            stencil_view,
                            stencil_load,
                            if needs_clear { Some(key) } else { None },
                        )
                    }
                };
            {
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("ordered_render_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: color_view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: color_load,
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: stencil_load,
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
                let mut previous_pipeline: Option<PipelineSelectionKey> = None;
                let mut previous_texture: Option<TexRef> = None;
                while cursor < draws.len() && draws[cursor].target == target {
                    let draw = draws[cursor];
                    let pipeline_key = self.pipeline_selection_key(draw);
                    if previous_pipeline != Some(pipeline_key) {
                        self.render_stats.shader_switches += 1;
                        previous_pipeline = Some(pipeline_key);
                    }
                    if draw.geometry == GeometryKind::Texture
                        && previous_texture != draw.texture_ref
                    {
                        self.render_stats.texture_switches += 1;
                        previous_texture = draw.texture_ref;
                    }
                    if self.issue_draw(&mut pass, draw, shaders) {
                        self.render_stats.draw_calls += 1;
                    }
                    cursor += 1;
                }
            }
            if let Some(key) = clear_canvas_after_pass {
                self.canvas_needs_clear.insert(key, false);
            }
            if target == RenderTargetId::Screen {
                screen_started = true;
            }
        }
        if !pending_canvas_postfx.is_empty() {
            if self.postfx_pipeline.is_none() {
                self.postfx_pipeline = Some(crate::render::postfx_pipeline::PostFxPipeline::new(
                    &self.device,
                    self.surface_format,
                ));
            }
            for (canvas_key, passes) in &pending_canvas_postfx {
                let Some(canvas) = canvases.get(*canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                let Some(canvas_texture) = self.canvas_gpu_textures.get(*canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                if let Some(pipeline) = self.postfx_pipeline.as_mut() {
                    pipeline.apply_in_place(
                        &self.device,
                        &self.queue,
                        &mut encoder,
                        &canvas_texture.view,
                        passes,
                        shaders,
                        canvas.width,
                        canvas.height,
                        frame_time,
                        frame_count,
                    );
                    self.canvas_needs_clear.insert(*canvas_key, false);
                }
            }
        }
        if !pending_canvas_effects.is_empty() {
            if self.postfx_pipeline.is_none() {
                self.postfx_pipeline = Some(crate::render::postfx_pipeline::PostFxPipeline::new(
                    &self.device,
                    self.surface_format,
                ));
            }
            for (source_canvas_key, target_canvas_key, passes) in &pending_canvas_effects {
                let Some(source_canvas) = canvases.get(*source_canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                let Some(target_canvas) = canvases.get(*target_canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                let Some(source_texture) = self.canvas_gpu_textures.get(*source_canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                let Some(target_texture) = self.canvas_gpu_textures.get(*target_canvas_key) else {
                    self.render_diagnostics.record_missing_canvas();
                    continue;
                };
                if let Some(pipeline) = self.postfx_pipeline.as_mut() {
                    if source_canvas_key == target_canvas_key {
                        pipeline.apply_in_place(
                            &self.device,
                            &self.queue,
                            &mut encoder,
                            &target_texture.view,
                            passes,
                            shaders,
                            target_canvas.width,
                            target_canvas.height,
                            frame_time,
                            frame_count,
                        );
                    } else {
                        pipeline.apply(
                            &self.device,
                            &self.queue,
                            &mut encoder,
                            &source_texture.view,
                            &target_texture.view,
                            passes,
                            shaders,
                            target_canvas.width,
                            target_canvas.height,
                            frame_time,
                            frame_count,
                        );
                    }
                    let _ = source_canvas;
                    self.canvas_needs_clear.insert(*target_canvas_key, false);
                }
            }
        }
        if !screen_started {
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
            if let Some(stencil_target) = self.screen_stencil_target.as_ref() {
                let screen_stencil_view = &stencil_target.view;
                let _pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("screen_clear_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color {
                                r: background_color[0] as f64,
                                g: background_color[1] as f64,
                                b: background_color[2] as f64,
                                a: background_color[3] as f64,
                            }),
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: screen_stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: wgpu::LoadOp::Clear(0),
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
            }
        }
        if light_world.enabled && !light_world.lights.is_empty() {
            let mut selected_lights = light_world.selected_render_lights();
            let shadow_lights = selected_lights
                .iter()
                .filter(|(_, light)| light.shadow_enabled)
                .count()
                .min(MAX_SHADOW_LIGHTS);
            if let Err(error) = render_budget.try_accept_light_work(
                selected_lights.len(),
                shadow_lights,
                &render_budget_limits,
            ) {
                self.render_diagnostics.record_invalid_render_input();
                log::warn!("Skipping lighting work that exceeds the frame budget: {error}");
                selected_lights.clear();
            }
            self.ensure_light_resources();
            let mut shadow_row = 0usize;
            let occluder_list: Vec<&crate::light::occluder::Occluder> =
                light_world.occluders.values().collect();
            let mut light_shadow_rows: Vec<Option<usize>> = Vec::new();
            let mut shadow_edge_cache = ShadowEdgeCache::default();
            for (_, light) in &selected_lights {
                if light.shadow_enabled && shadow_row < MAX_SHADOW_LIGHTS {
                    self.dispatch_shadow_map_gpu(
                        &mut encoder,
                        ShadowDispatchInput {
                            row: shadow_row,
                            light_x: light.x,
                            light_y: light.y,
                            light_radius: light.radius * light.energy,
                            shadow_mask: light.shadow_mask,
                            occluders: &occluder_list,
                        },
                        &mut shadow_edge_cache,
                    );
                    light_shadow_rows.push(Some(shadow_row));
                    shadow_row += 1;
                } else {
                    light_shadow_rows.push(None);
                }
            }
            let mut light_verts: Vec<LightVertex> = Vec::new();
            let mut light_idxs: Vec<u32> = Vec::new();
            let mut light_draw_shaders: Vec<Option<ShaderKey>> = Vec::new();
            let mut light_count = 0usize;
            let atlas_height = MAX_SHADOW_LIGHTS as f32;
            let ambient_color = [
                light_world.ambient.r,
                light_world.ambient.g,
                light_world.ambient.b,
                light_world.ambient.a,
            ];
            for ((_, light), shadow_opt) in selected_lights.iter().zip(light_shadow_rows.iter()) {
                if light_count >= MAX_LIGHT_QUADS {
                    break;
                }
                let r = light.radius * light.energy;
                if r <= 0.0 {
                    continue;
                }
                let ci = light.intensity * light.energy;
                let c = [light.color.r, light.color.g, light.color.b, 1.0];
                let sv = match shadow_opt {
                    Some(row) => (*row as f32 + 0.5) / atlas_height,
                    None => -1.0,
                };
                let filter_mode = match light.shadow_filter {
                    crate::light::ShadowFilter::None => 0.0,
                    crate::light::ShadowFilter::Pcf5 => 1.0,
                    crate::light::ShadowFilter::Pcf13 => 2.0,
                };
                let softness = (light.shadow_smooth * light.shadow_softness).max(0.0);
                let shadow_params = [filter_mode, softness, 1.0 / SHADOW_MAP_RES as f32, 0.0];
                let light_shader = light.shader.or(light_world.shader).filter(|key| {
                    shaders
                        .get(*key)
                        .map(|shader| shader.target() == ShaderTarget::Light)
                        .unwrap_or(false)
                });
                let direction_spot = [
                    light.direction.cos(),
                    light.direction.sin(),
                    light.inner_angle,
                    light.outer_angle,
                ];
                let normal_strength = if light.normal_map_path.is_some() {
                    light.normal_strength.clamp(0.0, 1.0)
                } else {
                    0.0
                };
                let normal_hint = [
                    light.direction.cos() * normal_strength,
                    light.direction.sin() * normal_strength,
                ];
                let base = light_verts.len() as u32;
                light_verts.push(LightVertex {
                    position: [light.x - r, light.y - r],
                    uv: [0.0, 0.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x + r, light.y - r],
                    uv: [1.0, 0.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x + r, light.y + r],
                    uv: [1.0, 1.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_verts.push(LightVertex {
                    position: [light.x - r, light.y + r],
                    uv: [0.0, 1.0],
                    color: c,
                    shadow_v: sv,
                    shadow_params,
                    light_pos: [light.x, light.y],
                    radius: r,
                    intensity: ci,
                    normal_hint,
                    ambient_color,
                    direction_spot,
                    _pad: [0.0; 2],
                });
                light_idxs.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                light_draw_shaders.push(light_shader);
                light_count += 1;
            }
            let composite_base = light_verts.len() as u32;
            let sw = self.width as f32;
            let sh = self.height as f32;
            light_verts.push(LightVertex {
                position: [0.0, 0.0],
                uv: [0.0, 0.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [sw, 0.0],
                uv: [1.0, 0.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [sw, sh],
                uv: [1.0, 1.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_verts.push(LightVertex {
                position: [0.0, sh],
                uv: [0.0, 1.0],
                color: [1.0; 4],
                shadow_v: -1.0,
                shadow_params: [0.0; 4],
                light_pos: [0.0, 0.0],
                radius: 0.0,
                intensity: 0.0,
                normal_hint: [0.0, 0.0],
                ambient_color: [0.0; 4],
                direction_spot: [0.0; 4],
                _pad: [0.0; 2],
            });
            light_idxs.extend_from_slice(&[
                composite_base,
                composite_base + 1,
                composite_base + 2,
                composite_base,
                composite_base + 2,
                composite_base + 3,
            ]);
            let composite_idx_start = (light_count * 6) as u32;
            if let Some(lg) = self.light_gpu.as_ref() {
                self.queue
                    .write_buffer(&lg.vertex_buffer, 0, bytemuck::cast_slice(&light_verts));
                self.queue
                    .write_buffer(&lg.index_buffer, 0, bytemuck::cast_slice(&light_idxs));
            }
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
            let light_pipeline_key = PipelineKey {
                blend_mode: BlendMode::Add,
                color_mask_bits: 0xF,
                stencil_mode: GpuStencilMode::Disabled,
            };
            let mut prepared_light_shaders = HashSet::new();
            for shader_key in light_draw_shaders.iter().flatten().copied() {
                if !prepared_light_shaders.insert(shader_key) {
                    continue;
                }
                let Some(shader) = shaders.get(shader_key) else {
                    continue;
                };
                if self
                    .custom_pipeline(shader_key, shader, GeometryKind::Light, light_pipeline_key)
                    .is_none()
                {
                    self.render_diagnostics.record_shader_pipeline_failure();
                }
            }
            if let Some(lg) = self.light_gpu.as_ref() {
                let ambient = &light_world.ambient;
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("light_accum_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &lg.accum_view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color {
                                r: ambient.r as f64,
                                g: ambient.g as f64,
                                b: ambient.b as f64,
                                a: 1.0,
                            }),
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: None,
                    ..Default::default()
                });
                if light_count > 0 {
                    pass.set_bind_group(0, &self.viewport_bind_group, &[]);
                    pass.set_bind_group(1, &lg.shadow_atlas_bind_group, &[]);
                    pass.set_vertex_buffer(0, lg.vertex_buffer.slice(..));
                    pass.set_index_buffer(lg.index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                    let mut run_start = 0usize;
                    while run_start < light_count {
                        let run_shader = light_draw_shaders[run_start];
                        let mut run_end = run_start + 1;
                        while run_end < light_count && light_draw_shaders[run_end] == run_shader {
                            run_end += 1;
                        }
                        if let Some(shader_key) = run_shader {
                            if let Some(pipeline) = self.cached_custom_pipeline(
                                shader_key,
                                GeometryKind::Light,
                                light_pipeline_key,
                            ) {
                                pass.set_pipeline(pipeline);
                                if let Some(bind_group) = self.shader_bind_group(shader_key) {
                                    pass.set_bind_group(2, bind_group, &[]);
                                }
                            } else {
                                pass.set_pipeline(&lg.additive_pipeline);
                            }
                        } else {
                            pass.set_pipeline(&lg.additive_pipeline);
                        }
                        pass.draw_indexed((run_start * 6) as u32..(run_end * 6) as u32, 0, 0..1);
                        run_start = run_end;
                    }
                }
            }
            self.update_viewport_uniform(self.width, self.height, &Mat3::identity(), frame_time);
            if let (Some(lg), Some(stencil_target)) =
                (self.light_gpu.as_ref(), self.screen_stencil_target.as_ref())
            {
                let screen_stencil_view = &stencil_target.view;
                let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("light_composite_pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Load,
                            store: wgpu::StoreOp::Store,
                        },
                    })],
                    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                        view: screen_stencil_view,
                        depth_ops: None,
                        stencil_ops: Some(wgpu::Operations {
                            load: wgpu::LoadOp::Load,
                            store: wgpu::StoreOp::Store,
                        }),
                    }),
                    ..Default::default()
                });
                pass.set_pipeline(&lg.composite_pipeline);
                pass.set_bind_group(0, &self.viewport_bind_group, &[]);
                pass.set_bind_group(1, &lg.accum_bind_group, &[]);
                pass.set_vertex_buffer(0, lg.vertex_buffer.slice(..));
                pass.set_index_buffer(lg.index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                pass.set_scissor_rect(0, 0, self.width, self.height);
                pass.set_stencil_reference(0);
                pass.draw_indexed(composite_idx_start..composite_idx_start + 6, 0, 0..1);
            }
            self.update_viewport_uniform(self.width, self.height, camera_matrix, frame_time);
        }
        let pending_readback = if capture_screenshot
            && completed_screenshot.is_none()
            && self.pending_surface_readback.is_none()
        {
            self.begin_surface_readback(&mut encoder, &output.texture, self.width, self.height)
        } else {
            None
        };
        for (stack_id, passes, w, h) in &pending_postfx {
            if let (Some(pipeline), Some(capture)) = (
                self.postfx_pipeline.as_mut(),
                self.postfx_capture.get(stack_id),
            ) {
                encoder.copy_texture_to_texture(
                    wgpu::ImageCopyTexture {
                        texture: &output.texture,
                        mip_level: 0,
                        origin: wgpu::Origin3d::ZERO,
                        aspect: wgpu::TextureAspect::All,
                    },
                    wgpu::ImageCopyTexture {
                        texture: &capture.texture,
                        mip_level: 0,
                        origin: wgpu::Origin3d::ZERO,
                        aspect: wgpu::TextureAspect::All,
                    },
                    wgpu::Extent3d {
                        width: self.width.min(*w),
                        height: self.height.min(*h),
                        depth_or_array_layers: 1,
                    },
                );
                pipeline.apply(
                    &self.device,
                    &self.queue,
                    &mut encoder,
                    &capture.view,
                    &view,
                    passes,
                    shaders,
                    *w,
                    *h,
                    frame_time,
                    frame_count,
                );
            }
        }
        self.queue.submit(std::iter::once(encoder.finish()));
        output.present();
        if let Some(mut readback) = pending_readback {
            self.start_surface_readback(&mut readback);
            self.pending_surface_readback = Some(readback);
        }
        self.render_stats.cpu_render_ms = frame_start.elapsed().as_secs_f32() * 1000.0;
        self.frame_buffers = FrameRenderBuffers {
            color_verts: all_color_verts,
            color_idxs: all_color_idxs,
            tex_verts: all_tex_verts,
            tex_idxs: all_tex_idxs,
            particle_verts: all_particle_verts,
            particle_idxs: all_particle_idxs,
            draws,
            instances: frame_instances,
            scratch_color_verts,
            scratch_color_idxs,
            scratch_tex_verts,
            scratch_tex_idxs,
            merged_draws,
        };
        Ok(completed_screenshot)
    }
}
