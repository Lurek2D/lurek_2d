//! Owns the gpu shader cache owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu shader cache data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu shader cache behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.

use std::collections::HashMap;

use crate::render::gpu_pipeline::{
    build_custom_color_shader_source, build_custom_texture_shader_source, create_render_pipeline,
    GeometryKind, PipelineKey,
};
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_shaders::{GpuShader, ShaderUniformKind};
use crate::render::gpu_tess::{uniform_bytes, uniform_kind};
use crate::render::shader::Shader;
use crate::runtime::resource_keys::ShaderKey;

impl GpuRenderer {
    /// Compile and cache a user shader if its source or uniform signature changed.
    fn ensure_shader_cache(&mut self, shader_key: ShaderKey, shader: &Shader) {
        let ordered_uniforms = shader.ordered_uniforms();
        let uniform_signature: Vec<(String, ShaderUniformKind)> = ordered_uniforms
            .iter()
            .map(|(name, value)| ((*name).to_string(), uniform_kind(value)))
            .collect();
        let needs_rebuild = self
            .shader_cache
            .get(shader_key)
            .map(|cached| {
                cached.source != shader.source || cached.uniform_signature != uniform_signature
            })
            .unwrap_or(true);
        if needs_rebuild {
            let uniform_bind_group_layout = if uniform_signature.is_empty() {
                None
            } else {
                Some(
                    self.device
                        .create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                            label: Some("custom_shader_uniform_bgl"),
                            entries: &uniform_signature
                                .iter()
                                .enumerate()
                                .map(|(binding, (_, _))| wgpu::BindGroupLayoutEntry {
                                    binding: binding as u32,
                                    visibility: wgpu::ShaderStages::FRAGMENT,
                                    ty: wgpu::BindingType::Buffer {
                                        ty: wgpu::BufferBindingType::Uniform,
                                        has_dynamic_offset: false,
                                        min_binding_size: None,
                                    },
                                    count: None,
                                })
                                .collect::<Vec<_>>(),
                        }),
                )
            };
            let uniform_buffers = uniform_signature
                .iter()
                .map(|_| {
                    self.device.create_buffer(&wgpu::BufferDescriptor {
                        label: Some("custom_shader_uniform_buffer"),
                        size: 16,
                        usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
                        mapped_at_creation: false,
                    })
                })
                .collect::<Vec<_>>();
            let uniform_bind_group = uniform_bind_group_layout.as_ref().map(|layout| {
                self.device.create_bind_group(&wgpu::BindGroupDescriptor {
                    label: Some("custom_shader_uniform_bg"),
                    layout,
                    entries: &uniform_buffers
                        .iter()
                        .enumerate()
                        .map(
                            |(binding, buffer): (usize, &wgpu::Buffer)| wgpu::BindGroupEntry {
                                binding: binding as u32,
                                resource: buffer.as_entire_binding(),
                            },
                        )
                        .collect::<Vec<_>>(),
                })
            });
            let color_source = build_custom_color_shader_source(shader, &uniform_signature);
            let texture_source = build_custom_texture_shader_source(shader, &uniform_signature);
            let color_module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("custom_color_shader"),
                    source: wgpu::ShaderSource::Wgsl(color_source.into()),
                });
            let texture_module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("custom_texture_shader"),
                    source: wgpu::ShaderSource::Wgsl(texture_source.into()),
                });
            let color_layout = {
                let bind_group_layouts = match uniform_bind_group_layout.as_ref() {
                    Some(uniform_layout) => vec![&self.viewport_bind_group_layout, uniform_layout],
                    None => vec![&self.viewport_bind_group_layout],
                };
                self.device
                    .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                        label: Some("custom_color_layout"),
                        bind_group_layouts: &bind_group_layouts,
                        push_constant_ranges: &[],
                    })
            };
            let texture_layout = {
                let bind_group_layouts = match uniform_bind_group_layout.as_ref() {
                    Some(uniform_layout) => vec![
                        &self.viewport_bind_group_layout,
                        &self.texture_bind_group_layout,
                        uniform_layout,
                    ],
                    None => vec![
                        &self.viewport_bind_group_layout,
                        &self.texture_bind_group_layout,
                    ],
                };
                self.device
                    .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                        label: Some("custom_texture_layout"),
                        bind_group_layouts: &bind_group_layouts,
                        push_constant_ranges: &[],
                    })
            };
            self.shader_cache.insert(
                shader_key,
                GpuShader {
                    source: shader.source.clone(),
                    uniform_signature,
                    uniform_buffers,
                    uniform_bind_group,
                    color_module,
                    texture_module,
                    color_layout,
                    texture_layout,
                    color_pipelines: HashMap::new(),
                    texture_pipelines: HashMap::new(),
                },
            );
        }
        if let Some(cache) = self.shader_cache.get(shader_key) {
            for ((_, value), buffer) in ordered_uniforms.iter().zip(cache.uniform_buffers.iter()) {
                let bytes = uniform_bytes(value);
                self.queue.write_buffer(buffer, 0, &bytes);
            }
        }
    }

    /// Return or create a user-shader render pipeline for the given geometry and blend/stencil key.
    pub(crate) fn custom_pipeline(
        &mut self,
        shader_key: ShaderKey,
        shader: &Shader,
        geometry: GeometryKind,
        key: PipelineKey,
    ) -> Option<&wgpu::RenderPipeline> {
        self.ensure_shader_cache(shader_key, shader);
        let missing = {
            let Some(cache) = self.shader_cache.get(shader_key) else {
                debug_assert!(false, "shader cache missing after ensure");
                return None;
            };
            match geometry {
                GeometryKind::Color | GeometryKind::ColorInstanced => {
                    !cache.color_pipelines.contains_key(&key)
                }
                GeometryKind::Texture | GeometryKind::TextureInstanced => {
                    !cache.texture_pipelines.contains_key(&key)
                }
            }
        };
        if missing {
            let pipeline = {
                let Some(cache) = self.shader_cache.get(shader_key) else {
                    debug_assert!(false, "shader cache missing during pipeline build");
                    return None;
                };
                match geometry {
                    GeometryKind::Color | GeometryKind::ColorInstanced => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.color_layout,
                        &cache.color_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                    ),
                    GeometryKind::Texture | GeometryKind::TextureInstanced => {
                        create_render_pipeline(
                            &self.device,
                            self.surface_format,
                            &cache.texture_layout,
                            &cache.texture_module,
                            geometry,
                            key,
                            "lurek_fragment_main",
                        )
                    }
                }
            };
            let Some(cache) = self.shader_cache.get_mut(shader_key) else {
                debug_assert!(false, "shader cache missing for pipeline insertion");
                return None;
            };
            match geometry {
                GeometryKind::Color | GeometryKind::ColorInstanced => {
                    cache.color_pipelines.insert(key, pipeline);
                }
                GeometryKind::Texture | GeometryKind::TextureInstanced => {
                    cache.texture_pipelines.insert(key, pipeline);
                }
            }
        }
        let Some(cache) = self.shader_cache.get(shader_key) else {
            debug_assert!(false, "shader cache missing after pipeline ensure");
            return None;
        };
        match geometry {
            GeometryKind::Color | GeometryKind::ColorInstanced => {
                let pipeline = cache.color_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom color pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::Texture | GeometryKind::TextureInstanced => {
                let pipeline = cache.texture_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom texture pipeline missing after ensure"
                );
                pipeline
            }
        }
    }

    /// Return the uniform bind group for a cached user shader, if present.
    pub(crate) fn shader_bind_group(&self, shader_key: ShaderKey) -> Option<&wgpu::BindGroup> {
        self.shader_cache
            .get(shader_key)
            .and_then(|cache| cache.uniform_bind_group.as_ref())
    }
}
