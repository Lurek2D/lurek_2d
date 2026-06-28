//! Owns the gpu draw encode owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu draw encode data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu draw encode behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.
//! Use this file when changing gpu draw encode defaults, lifecycle handling, validation, or data ownership.

use slotmap::SlotMap;

use crate::render::gpu_pipeline::{
    create_render_pipeline, GeometryKind, PipelineKey, PipelineSelectionKey,
};
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_tess::shader_for_draw;
use crate::render::gpu_types::{PreparedDraw, RenderTargetId, TexRef};
use crate::render::shader::Shader;
use crate::runtime::resource_keys::ShaderKey;

impl GpuRenderer {
    /// Build the full pipeline selection key for a prepared draw call.
    pub(crate) fn pipeline_selection_key(&self, draw: PreparedDraw) -> PipelineSelectionKey {
        let geometry = draw.geometry;
        let pipeline = PipelineKey {
            blend_mode: draw.blend_mode,
            color_mask_bits: draw.color_mask_bits,
            stencil_mode: draw.stencil_mode,
        };
        match shader_for_draw(draw) {
            Some(shader) => PipelineSelectionKey::Custom {
                shader,
                geometry,
                pipeline,
            },
            None => PipelineSelectionKey::Default { geometry, pipeline },
        }
    }

    /// Return or create the default render pipeline for the given geometry and blend/stencil key.
    fn default_pipeline(
        &mut self,
        geometry: GeometryKind,
        key: PipelineKey,
    ) -> Option<&wgpu::RenderPipeline> {
        let missing = match geometry {
            GeometryKind::Color => !self.default_color_pipelines.contains_key(&key),
            GeometryKind::Texture => !self.default_texture_pipelines.contains_key(&key),
            GeometryKind::ColorInstanced => {
                !self.default_color_instanced_pipelines.contains_key(&key)
            }
            GeometryKind::TextureInstanced => {
                !self.default_texture_instanced_pipelines.contains_key(&key)
            }
            GeometryKind::Particle | GeometryKind::ParticleTextured | GeometryKind::Light => {
                return None
            }
        };
        if missing {
            let pipeline = match geometry {
                GeometryKind::Color => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_color_layout,
                    &self.default_color_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
                GeometryKind::Texture => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_texture_layout,
                    &self.default_texture_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
                GeometryKind::ColorInstanced => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_color_layout,
                    &self.default_color_instanced_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
                GeometryKind::TextureInstanced => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_texture_layout,
                    &self.default_texture_instanced_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
                GeometryKind::Particle | GeometryKind::ParticleTextured | GeometryKind::Light => {
                    return None
                }
            };
            match geometry {
                GeometryKind::Color => {
                    self.default_color_pipelines.insert(key, pipeline);
                }
                GeometryKind::Texture => {
                    self.default_texture_pipelines.insert(key, pipeline);
                }
                GeometryKind::ColorInstanced => {
                    self.default_color_instanced_pipelines.insert(key, pipeline);
                }
                GeometryKind::TextureInstanced => {
                    self.default_texture_instanced_pipelines
                        .insert(key, pipeline);
                }
                GeometryKind::Particle | GeometryKind::ParticleTextured | GeometryKind::Light => {
                    return None
                }
            }
        }
        match geometry {
            GeometryKind::Color => {
                let pipeline = self.default_color_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "default color pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::Texture => {
                let pipeline = self.default_texture_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "default texture pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::ColorInstanced => {
                let pipeline = self.default_color_instanced_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "default instanced color pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::TextureInstanced => {
                let pipeline = self.default_texture_instanced_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "default instanced texture pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::Particle | GeometryKind::ParticleTextured | GeometryKind::Light => None,
        }
    }

    /// Resolve a `TexRef` to its GPU bind group for texture sampling.
    fn texture_bind_group(&self, texture_ref: TexRef) -> Option<&wgpu::BindGroup> {
        match texture_ref {
            TexRef::Texture(key) => self
                .gpu_textures
                .get(key)
                .map(|texture| &texture.bind_group),
            TexRef::Canvas(key) => self
                .canvas_gpu_textures
                .get(key)
                .map(|texture| &texture.bind_group),
            TexRef::FontAtlas(key) => self
                .font_atlas_textures
                .get(key)
                .map(|texture| &texture.bind_group),
        }
    }

    /// Record a missing texture-like resource for a prepared draw.
    fn record_missing_texture_ref(&mut self, texture_ref: TexRef) {
        match texture_ref {
            TexRef::Texture(_) | TexRef::FontAtlas(_) => {
                self.render_diagnostics.record_missing_texture();
            }
            TexRef::Canvas(_) => {
                self.render_diagnostics.record_missing_canvas();
            }
        }
    }

    /// Encode a single prepared draw call into the active render pass.
    pub(crate) fn issue_draw(
        &mut self,
        pass: &mut wgpu::RenderPass<'_>,
        draw: PreparedDraw,
        shaders: &SlotMap<ShaderKey, Shader>,
    ) -> bool {
        if let (RenderTargetId::Canvas(active_canvas), Some(TexRef::Canvas(source_canvas))) =
            (draw.target, draw.texture_ref)
        {
            if active_canvas == source_canvas {
                self.render_diagnostics.record_dropped_command();
                return false;
            }
        }
        let pipeline_key = PipelineKey {
            blend_mode: draw.blend_mode,
            color_mask_bits: draw.color_mask_bits,
            stencil_mode: draw.stencil_mode,
        };
        let effective_shader = shader_for_draw(draw);

        let (vertex_buf, index_buf) = match draw.static_geometry {
            Some(geom_key) => {
                if let Some(geom) = self.mesh_cache.static_geometry.get(&geom_key) {
                    (&geom.vertex_buffer, &geom.index_buffer)
                } else {
                    self.render_diagnostics.record_missing_static_geometry();
                    return false;
                }
            }
            None => match draw.geometry {
                GeometryKind::Color | GeometryKind::ColorInstanced => {
                    (&self.color_vertex_buffer, &self.color_index_buffer)
                }
                GeometryKind::Texture | GeometryKind::TextureInstanced => {
                    (&self.tex_vertex_buffer, &self.tex_index_buffer)
                }
                GeometryKind::Particle | GeometryKind::ParticleTextured => {
                    (&self.particle_vertex_buffer, &self.particle_index_buffer)
                }
                GeometryKind::Light => {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    self.render_diagnostics.record_dropped_command();
                    return false;
                }
            },
        };

        let inst_buf_ref = match draw.instance_buffer {
            Some(inst_key) => {
                if let Some(inst_entry) = self.mesh_cache.instance_buffers.get(&inst_key) {
                    Some(&inst_entry.buffer)
                } else {
                    self.render_diagnostics.record_missing_instance_buffer();
                    return false;
                }
            }
            None => {
                if draw.geometry == GeometryKind::ColorInstanced
                    || draw.geometry == GeometryKind::TextureInstanced
                {
                    Some(&self.instance_buffer)
                } else {
                    None
                }
            }
        };

        pass.set_bind_group(0, &self.viewport_bind_group, &[]);
        pass.set_vertex_buffer(0, vertex_buf.slice(..));
        pass.set_index_buffer(index_buf.slice(..), wgpu::IndexFormat::Uint32);

        if let Some(inst_buf) = inst_buf_ref {
            pass.set_vertex_buffer(1, inst_buf.slice(..));
        }

        match draw.geometry {
            GeometryKind::Color | GeometryKind::ColorInstanced => {
                if let Some(shader_key) = effective_shader {
                    if let Some(shader) = shaders.get(shader_key) {
                        let custom_pipeline_ready = {
                            if let Some(pipeline) = self.custom_pipeline(
                                shader_key,
                                shader,
                                draw.geometry,
                                pipeline_key,
                            ) {
                                pass.set_pipeline(pipeline);
                                true
                            } else {
                                false
                            }
                        };
                        if custom_pipeline_ready {
                            if let Some(bind_group) = self.shader_bind_group(shader_key) {
                                pass.set_bind_group(1, bind_group, &[]);
                            }
                        } else {
                            self.render_diagnostics.record_shader_pipeline_failure();
                            let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key)
                            else {
                                self.render_diagnostics.record_shader_pipeline_failure();
                                self.render_diagnostics.record_dropped_command();
                                return false;
                            };
                            pass.set_pipeline(pipeline);
                        }
                    } else {
                        let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key)
                        else {
                            self.render_diagnostics.record_shader_pipeline_failure();
                            self.render_diagnostics.record_dropped_command();
                            return false;
                        };
                        pass.set_pipeline(pipeline);
                    }
                } else {
                    let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key) else {
                        self.render_diagnostics.record_shader_pipeline_failure();
                        self.render_diagnostics.record_dropped_command();
                        return false;
                    };
                    pass.set_pipeline(pipeline);
                }
            }
            GeometryKind::Particle | GeometryKind::ParticleTextured => {
                let Some(shader_key) = effective_shader else {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    self.render_diagnostics.record_dropped_command();
                    return false;
                };
                let Some(shader) = shaders.get(shader_key) else {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    self.render_diagnostics.record_dropped_command();
                    return false;
                };
                if let Some(pipeline) =
                    self.custom_pipeline(shader_key, shader, draw.geometry, pipeline_key)
                {
                    pass.set_pipeline(pipeline);
                    if draw.geometry == GeometryKind::ParticleTextured {
                        let Some(texture_ref) = draw.texture_ref else {
                            self.render_diagnostics.record_missing_texture();
                            return false;
                        };
                        let Some(texture_bind_group) = self.texture_bind_group(texture_ref) else {
                            self.record_missing_texture_ref(texture_ref);
                            return false;
                        };
                        pass.set_bind_group(1, texture_bind_group, &[]);
                        if let Some(bind_group) = self.shader_bind_group(shader_key) {
                            pass.set_bind_group(2, bind_group, &[]);
                        }
                    } else if let Some(bind_group) = self.shader_bind_group(shader_key) {
                        pass.set_bind_group(1, bind_group, &[]);
                    }
                } else {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    self.render_diagnostics.record_dropped_command();
                    return false;
                }
            }
            GeometryKind::Texture | GeometryKind::TextureInstanced => {
                let Some(texture_ref) = draw.texture_ref else {
                    self.render_diagnostics.record_missing_texture();
                    return false;
                };
                if let Some(shader_key) = effective_shader {
                    if let Some(shader) = shaders.get(shader_key) {
                        let custom_pipeline_ready = {
                            if let Some(pipeline) = self.custom_pipeline(
                                shader_key,
                                shader,
                                draw.geometry,
                                pipeline_key,
                            ) {
                                pass.set_pipeline(pipeline);
                                true
                            } else {
                                false
                            }
                        };
                        if !custom_pipeline_ready {
                            self.render_diagnostics.record_shader_pipeline_failure();
                            let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key)
                            else {
                                self.render_diagnostics.record_shader_pipeline_failure();
                                self.render_diagnostics.record_dropped_command();
                                return false;
                            };
                            pass.set_pipeline(pipeline);
                        }
                        {
                            let Some(texture_bind_group) = self.texture_bind_group(texture_ref)
                            else {
                                self.record_missing_texture_ref(texture_ref);
                                return false;
                            };
                            pass.set_bind_group(1, texture_bind_group, &[]);
                        }
                        if custom_pipeline_ready {
                            if let Some(bind_group) = self.shader_bind_group(shader_key) {
                                pass.set_bind_group(2, bind_group, &[]);
                            }
                        }
                    } else {
                        let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key)
                        else {
                            self.render_diagnostics.record_shader_pipeline_failure();
                            self.render_diagnostics.record_dropped_command();
                            return false;
                        };
                        pass.set_pipeline(pipeline);
                        let Some(texture_bind_group) = self.texture_bind_group(texture_ref) else {
                            self.record_missing_texture_ref(texture_ref);
                            return false;
                        };
                        pass.set_bind_group(1, texture_bind_group, &[]);
                    }
                } else {
                    let Some(pipeline) = self.default_pipeline(draw.geometry, pipeline_key) else {
                        self.render_diagnostics.record_shader_pipeline_failure();
                        self.render_diagnostics.record_dropped_command();
                        return false;
                    };
                    pass.set_pipeline(pipeline);
                    let Some(texture_bind_group) = self.texture_bind_group(texture_ref) else {
                        self.record_missing_texture_ref(texture_ref);
                        return false;
                    };
                    pass.set_bind_group(1, texture_bind_group, &[]);
                }
            }
            GeometryKind::Light => {
                self.render_diagnostics.record_shader_pipeline_failure();
                self.render_diagnostics.record_dropped_command();
                return false;
            }
        }
        let (target_width, target_height) = self.target_dimensions_from_gpu(draw.target);
        match draw.scissor {
            Some((sx, sy, sw, sh)) => pass.set_scissor_rect(sx, sy, sw, sh),
            None => pass.set_scissor_rect(0, 0, target_width, target_height),
        }
        pass.set_stencil_reference(draw.stencil_reference);

        let inst_start = draw.instance_start;
        let inst_count = if draw.geometry == GeometryKind::ColorInstanced
            || draw.geometry == GeometryKind::TextureInstanced
            || draw.geometry == GeometryKind::ParticleTextured
        {
            draw.instance_count
        } else {
            1
        };
        pass.draw_indexed(
            draw.idx_start..draw.idx_start + draw.idx_count,
            0,
            inst_start..inst_start + inst_count,
        );
        true
    }
}
