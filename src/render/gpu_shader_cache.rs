//! Owns the render GPU shader cache implementation for the render subsystem and keeps related runtime rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render GPU shader cache data is validated, transformed, or stored before neighboring systems consume it.
//! Separates render GPU shader cache behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render GPU shader cache defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near render GPU shader cache state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping render GPU shader cache calculations at their owning subsystem boundary.

use std::collections::HashMap;

use crate::render::gpu_pipeline::{
    build_custom_color_shader_source, build_custom_light_shader_source,
    build_custom_particle_shader_source, build_custom_texture_shader_source,
    build_custom_textured_particle_shader_source, create_render_pipeline, GeometryKind,
    PipelineKey,
};
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_shaders::{GpuShader, ShaderUniformKind};
use crate::render::gpu_tess::{uniform_bytes, uniform_kind};
use crate::render::shader::{Shader, ShaderTarget};
use crate::runtime::resource_keys::ShaderKey;

/// Hard ceiling for live user pipeline cache entries retained by one renderer.
const MAX_CACHED_USER_SHADERS: usize = 256;
/// Total specialized render pipelines retained by one user shader cache entry.
const MAX_PIPELINES_PER_USER_SHADER: usize = 64;

fn cached_pipeline_count(cache: &GpuShader) -> usize {
    cache
        .color_pipelines
        .len()
        .saturating_add(cache.texture_pipelines.len())
        .saturating_add(cache.particle_pipelines.len())
        .saturating_add(cache.textured_particle_pipelines.len())
        .saturating_add(cache.light_pipelines.len())
}

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
            let device_limits = self.device.limits();
            if uniform_signature.len() > device_limits.max_bindings_per_bind_group as usize {
                self.render_diagnostics.record_shader_pipeline_failure();
                log::warn!(
                    "Skipping user shader whose {} uniforms exceed the device binding limit {}",
                    uniform_signature.len(),
                    device_limits.max_bindings_per_bind_group
                );
                return;
            }
            if self.shader_cache.get(shader_key).is_none()
                && self.shader_cache.len() >= MAX_CACHED_USER_SHADERS
            {
                self.render_diagnostics.record_shader_pipeline_failure();
                log::warn!(
                    "Skipping user shader cache entry because the {}-entry budget is exhausted",
                    MAX_CACHED_USER_SHADERS
                );
                return;
            }
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
            let light_source = (shader.target() == ShaderTarget::Light)
                .then(|| build_custom_light_shader_source(shader, &uniform_signature));
            let particle_source = build_custom_particle_shader_source(shader, &uniform_signature);
            let textured_particle_source =
                build_custom_textured_particle_shader_source(shader, &uniform_signature);
            let texture_source = build_custom_texture_shader_source(shader, &uniform_signature);
            let color_module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("custom_color_shader"),
                    source: wgpu::ShaderSource::Wgsl(color_source.into()),
                });
            let particle_module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("custom_particle_shader"),
                    source: wgpu::ShaderSource::Wgsl(particle_source.into()),
                });
            let textured_particle_module =
                self.device
                    .create_shader_module(wgpu::ShaderModuleDescriptor {
                        label: Some("custom_textured_particle_shader"),
                        source: wgpu::ShaderSource::Wgsl(textured_particle_source.into()),
                    });
            let light_module = light_source.map(|source| {
                self.device
                    .create_shader_module(wgpu::ShaderModuleDescriptor {
                        label: Some("custom_light_shader"),
                        source: wgpu::ShaderSource::Wgsl(source.into()),
                    })
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
            let particle_layout = {
                let bind_group_layouts = match uniform_bind_group_layout.as_ref() {
                    Some(uniform_layout) => vec![&self.viewport_bind_group_layout, uniform_layout],
                    None => vec![&self.viewport_bind_group_layout],
                };
                self.device
                    .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                        label: Some("custom_particle_layout"),
                        bind_group_layouts: &bind_group_layouts,
                        push_constant_ranges: &[],
                    })
            };
            let textured_particle_layout = {
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
                        label: Some("custom_textured_particle_layout"),
                        bind_group_layouts: &bind_group_layouts,
                        push_constant_ranges: &[],
                    })
            };
            let light_layout = if shader.target() == ShaderTarget::Light {
                let Some(light_gpu) = self.light_gpu.as_ref() else {
                    return;
                };
                let bind_group_layouts = match uniform_bind_group_layout.as_ref() {
                    Some(uniform_layout) => vec![
                        &self.viewport_bind_group_layout,
                        &light_gpu.shadow_atlas_bind_group_layout,
                        uniform_layout,
                    ],
                    None => vec![
                        &self.viewport_bind_group_layout,
                        &light_gpu.shadow_atlas_bind_group_layout,
                    ],
                };
                Some(
                    self.device
                        .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                            label: Some("custom_light_layout"),
                            bind_group_layouts: &bind_group_layouts,
                            push_constant_ranges: &[],
                        }),
                )
            } else {
                None
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
                    particle_module,
                    textured_particle_module,
                    light_module,
                    color_layout,
                    texture_layout,
                    particle_layout,
                    textured_particle_layout,
                    light_layout,
                    color_pipelines: HashMap::new(),
                    texture_pipelines: HashMap::new(),
                    particle_pipelines: HashMap::new(),
                    textured_particle_pipelines: HashMap::new(),
                    light_pipelines: HashMap::new(),
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
        let target_matches_geometry = matches!(
            (geometry, shader.target()),
            (GeometryKind::Light, ShaderTarget::Light)
                | (GeometryKind::Particle, ShaderTarget::Particle)
                | (GeometryKind::ParticleTextured, ShaderTarget::Particle)
                | (GeometryKind::Color, ShaderTarget::Draw)
                | (GeometryKind::ColorInstanced, ShaderTarget::Draw)
                | (GeometryKind::Texture, ShaderTarget::Draw)
                | (GeometryKind::TextureInstanced, ShaderTarget::Draw)
                | (GeometryKind::Color, ShaderTarget::Overlay)
                | (GeometryKind::ColorInstanced, ShaderTarget::Overlay)
                | (GeometryKind::Texture, ShaderTarget::Overlay)
                | (GeometryKind::TextureInstanced, ShaderTarget::Overlay)
                | (GeometryKind::Color, ShaderTarget::PostFx)
                | (GeometryKind::ColorInstanced, ShaderTarget::PostFx)
                | (GeometryKind::Texture, ShaderTarget::PostFx)
                | (GeometryKind::TextureInstanced, ShaderTarget::PostFx)
                | (GeometryKind::Texture, ShaderTarget::Sprite)
                | (GeometryKind::TextureInstanced, ShaderTarget::Sprite)
                | (GeometryKind::Color, ShaderTarget::Tilemap)
                | (GeometryKind::ColorInstanced, ShaderTarget::Tilemap)
                | (GeometryKind::Texture, ShaderTarget::Tilemap)
                | (GeometryKind::TextureInstanced, ShaderTarget::Tilemap)
                | (GeometryKind::Color, ShaderTarget::MapViz)
                | (GeometryKind::ColorInstanced, ShaderTarget::MapViz)
                | (GeometryKind::Texture, ShaderTarget::MapViz)
                | (GeometryKind::TextureInstanced, ShaderTarget::MapViz)
                | (GeometryKind::Texture, ShaderTarget::Text)
                | (GeometryKind::TextureInstanced, ShaderTarget::Text)
                | (GeometryKind::Color, ShaderTarget::Ui)
                | (GeometryKind::ColorInstanced, ShaderTarget::Ui)
                | (GeometryKind::Texture, ShaderTarget::Ui)
                | (GeometryKind::TextureInstanced, ShaderTarget::Ui)
                | (GeometryKind::Color, ShaderTarget::DebugViz)
                | (GeometryKind::ColorInstanced, ShaderTarget::DebugViz)
                | (GeometryKind::Texture, ShaderTarget::DebugViz)
                | (GeometryKind::TextureInstanced, ShaderTarget::DebugViz)
        );
        if !target_matches_geometry {
            return None;
        }
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
                GeometryKind::Particle => !cache.particle_pipelines.contains_key(&key),
                GeometryKind::ParticleTextured => {
                    !cache.textured_particle_pipelines.contains_key(&key)
                }
                GeometryKind::Light => !cache.light_pipelines.contains_key(&key),
            }
        };
        if missing {
            let Some(cache) = self.shader_cache.get(shader_key) else {
                return None;
            };
            if cached_pipeline_count(cache) >= MAX_PIPELINES_PER_USER_SHADER {
                self.render_diagnostics.record_shader_pipeline_failure();
                log::warn!(
                    "Skipping user shader pipeline because the {}-pipeline budget is exhausted",
                    MAX_PIPELINES_PER_USER_SHADER
                );
                return None;
            }
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
                    GeometryKind::Particle => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.particle_layout,
                        &cache.particle_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                    ),
                    GeometryKind::ParticleTextured => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.textured_particle_layout,
                        &cache.textured_particle_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                    ),
                    GeometryKind::Light => {
                        let (Some(light_layout), Some(light_module)) =
                            (cache.light_layout.as_ref(), cache.light_module.as_ref())
                        else {
                            return None;
                        };
                        create_render_pipeline(
                            &self.device,
                            self.surface_format,
                            light_layout,
                            light_module,
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
                GeometryKind::Particle => {
                    cache.particle_pipelines.insert(key, pipeline);
                }
                GeometryKind::ParticleTextured => {
                    cache.textured_particle_pipelines.insert(key, pipeline);
                }
                GeometryKind::Light => {
                    cache.light_pipelines.insert(key, pipeline);
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
            GeometryKind::Particle => {
                let pipeline = cache.particle_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom particle pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::ParticleTextured => {
                let pipeline = cache.textured_particle_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom textured particle pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::Light => {
                let pipeline = cache.light_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom light pipeline missing after ensure"
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

    /// Return an already-created custom render pipeline without mutating the cache.
    pub(crate) fn cached_custom_pipeline(
        &self,
        shader_key: ShaderKey,
        geometry: GeometryKind,
        key: PipelineKey,
    ) -> Option<&wgpu::RenderPipeline> {
        let cache = self.shader_cache.get(shader_key)?;
        match geometry {
            GeometryKind::Color | GeometryKind::ColorInstanced => cache.color_pipelines.get(&key),
            GeometryKind::Texture | GeometryKind::TextureInstanced => {
                cache.texture_pipelines.get(&key)
            }
            GeometryKind::Particle => cache.particle_pipelines.get(&key),
            GeometryKind::ParticleTextured => cache.textured_particle_pipelines.get(&key),
            GeometryKind::Light => cache.light_pipelines.get(&key),
        }
    }
}
