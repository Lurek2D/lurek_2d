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
    build_custom_color_instanced_shader_source, build_custom_color_shader_source,
    build_custom_light_shader_source, build_custom_particle_shader_source,
    build_custom_texture_instanced_shader_source, build_custom_texture_shader_source,
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
/// Bounded CPU source retained by compiled user shader entries.
const MAX_CACHED_USER_SHADER_SOURCE_BYTES: usize = 16 * 1024 * 1024;
/// Bounded number of rejected shader signatures retained to suppress repeat work.
const MAX_NEGATIVE_CACHED_USER_SHADERS: usize = 256;
/// Bounded CPU source retained by rejected shader signatures.
const MAX_NEGATIVE_SHADER_SOURCE_BYTES: usize = 4 * 1024 * 1024;
/// Total specialized render pipelines retained by one user shader cache entry.
const MAX_PIPELINES_PER_USER_SHADER: usize = 64;

fn cached_pipeline_count(cache: &GpuShader) -> usize {
    cache
        .color_pipelines
        .len()
        .saturating_add(cache.color_instanced_pipelines.len())
        .saturating_add(cache.texture_pipelines.len())
        .saturating_add(cache.texture_instanced_pipelines.len())
        .saturating_add(cache.particle_pipelines.len())
        .saturating_add(cache.textured_particle_pipelines.len())
        .saturating_add(cache.light_pipelines.len())
}

impl GpuRenderer {
    /// Compile at most `limit` known shaders through the normal bounded cache path.
    ///
    /// Callers schedule this only at a frame boundary. Prewarming deliberately
    /// shares eviction, source-byte, binding, and negative-cache policy with
    /// ordinary draw-time preparation, so it cannot create an unbounded second
    /// compilation path.
    pub fn prewarm_shader_cache(
        &mut self,
        shaders: &slotmap::SlotMap<ShaderKey, Shader>,
        shader_keys: &[ShaderKey],
        limit: usize,
    ) -> usize {
        let mut completed: usize = 0;
        for shader_key in shader_keys.iter().copied().take(limit) {
            let Some(shader) = shaders.get(shader_key) else {
                continue;
            };
            self.ensure_shader_cache(shader_key, shader);
            completed = completed.saturating_add(1);
        }
        completed
    }

    /// Compile the scheduled prewarm keys and report one cache outcome per request.
    ///
    /// This is intentionally frame-boundary-only orchestration; it delegates every
    /// allocation, eviction, and rejection decision to [`Self::ensure_shader_cache`].
    pub fn prewarm_scheduled_shader_cache(
        &mut self,
        shaders: &slotmap::SlotMap<ShaderKey, Shader>,
        scheduled: &[(u64, ShaderKey)],
    ) -> Vec<(u64, bool)> {
        scheduled
            .iter()
            .map(|(request_id, shader_key)| {
                let Some(shader) = shaders.get(*shader_key) else {
                    return (*request_id, false);
                };
                self.ensure_shader_cache(*shader_key, shader);
                (*request_id, self.shader_cache.get(*shader_key).is_some())
            })
            .collect()
    }

    fn shader_cache_source_bytes(&self) -> usize {
        self.shader_cache
            .iter()
            .map(|(_, cached)| cached.source.len())
            .sum()
    }

    fn negative_shader_cache_source_bytes(&self) -> usize {
        self.shader_negative_cache
            .iter()
            .map(|(_, (source, _))| source.len())
            .sum()
    }

    /// Evict one unrelated compiled entry before creating another GPU allocation.
    ///
    /// Entries are not user-visible objects, so deterministic key order is sufficient here;
    /// the owning Lua shader remains valid and is lazily rebuilt on its next use.
    fn evict_compiled_shader_entry(&mut self, protected: ShaderKey) -> bool {
        let candidate = self
            .shader_cache
            .iter()
            .map(|(key, _)| key)
            .find(|key| *key != protected);
        let Some(candidate) = candidate else {
            return false;
        };
        self.shader_cache.remove(candidate);
        self.render_stats.shader_cache_evictions =
            self.render_stats.shader_cache_evictions.saturating_add(1);
        true
    }

    /// Insert a known-invalid signature while bounding both count and retained source bytes.
    fn cache_shader_rejection(
        &mut self,
        shader_key: ShaderKey,
        source: String,
        signature: Vec<(String, ShaderUniformKind)>,
    ) {
        let source_bytes = source.len();
        if source_bytes > MAX_NEGATIVE_SHADER_SOURCE_BYTES {
            return;
        }
        while self.shader_negative_cache.len() >= MAX_NEGATIVE_CACHED_USER_SHADERS
            || self
                .negative_shader_cache_source_bytes()
                .saturating_add(source_bytes)
                > MAX_NEGATIVE_SHADER_SOURCE_BYTES
        {
            let candidate = self.shader_negative_cache.iter().map(|(key, _)| key).next();
            let Some(candidate) = candidate else {
                return;
            };
            self.shader_negative_cache.remove(candidate);
            self.render_stats.shader_cache_evictions =
                self.render_stats.shader_cache_evictions.saturating_add(1);
        }
        self.shader_negative_cache
            .insert(shader_key, (source, signature));
    }

    /// Compile and cache a user shader if its source or uniform signature changed.
    fn ensure_shader_cache(&mut self, shader_key: ShaderKey, shader: &Shader) {
        let ordered_uniforms = shader.ordered_uniforms();
        let uniform_signature: Vec<(String, ShaderUniformKind)> = ordered_uniforms
            .iter()
            .map(|(name, value)| ((*name).to_string(), uniform_kind(value)))
            .collect();
        if self
            .shader_negative_cache
            .get(shader_key)
            .is_some_and(|(source, signature)| {
                source == &shader.source && signature == &uniform_signature
            })
        {
            self.render_stats.shader_negative_cache_hits = self
                .render_stats
                .shader_negative_cache_hits
                .saturating_add(1);
            // The same device-limit rejection was already reported.  Avoid both
            // repeat preparation work and per-frame diagnostic/log spam.
            return;
        }
        let needs_rebuild = self
            .shader_cache
            .get(shader_key)
            .map(|cached| {
                cached.source != shader.source || cached.uniform_signature != uniform_signature
            })
            .unwrap_or(true);
        if needs_rebuild {
            self.render_stats.shader_cache_misses =
                self.render_stats.shader_cache_misses.saturating_add(1);
        } else {
            self.render_stats.shader_cache_hits =
                self.render_stats.shader_cache_hits.saturating_add(1);
        }
        if needs_rebuild {
            let device_limits = self.device.limits();
            if uniform_signature.len() > device_limits.max_bindings_per_bind_group as usize {
                self.render_diagnostics.record_shader_pipeline_failure();
                self.render_stats.shader_cache_rejections =
                    self.render_stats.shader_cache_rejections.saturating_add(1);
                self.cache_shader_rejection(
                    shader_key,
                    shader.source.clone(),
                    uniform_signature.clone(),
                );
                log::warn!(
                    "Skipping user shader whose {} uniforms exceed the device binding limit {}",
                    uniform_signature.len(),
                    device_limits.max_bindings_per_bind_group
                );
                return;
            }
            let source_bytes = shader.source.len();
            if source_bytes > MAX_CACHED_USER_SHADER_SOURCE_BYTES {
                self.render_diagnostics.record_shader_pipeline_failure();
                self.render_stats.shader_cache_rejections =
                    self.render_stats.shader_cache_rejections.saturating_add(1);
                log::warn!(
                    "Skipping user shader cache entry because its source exceeds the {}-byte cache budget",
                    MAX_CACHED_USER_SHADER_SOURCE_BYTES
                );
                return;
            }
            while self.shader_cache.get(shader_key).is_none()
                && (self.shader_cache.len() >= MAX_CACHED_USER_SHADERS
                    || self
                        .shader_cache_source_bytes()
                        .saturating_add(source_bytes)
                        > MAX_CACHED_USER_SHADER_SOURCE_BYTES)
            {
                if !self.evict_compiled_shader_entry(shader_key) {
                    self.render_diagnostics.record_shader_pipeline_failure();
                    self.render_stats.shader_cache_rejections =
                        self.render_stats.shader_cache_rejections.saturating_add(1);
                    log::warn!(
                        "Skipping user shader cache entry because no evictable cache entry remains"
                    );
                    return;
                }
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
            let color_instanced_source =
                build_custom_color_instanced_shader_source(shader, &uniform_signature);
            let light_source = (shader.target() == ShaderTarget::Light)
                .then(|| build_custom_light_shader_source(shader, &uniform_signature));
            let particle_source = build_custom_particle_shader_source(shader, &uniform_signature);
            let textured_particle_source =
                build_custom_textured_particle_shader_source(shader, &uniform_signature);
            let texture_source = build_custom_texture_shader_source(shader, &uniform_signature);
            let texture_instanced_source =
                build_custom_texture_instanced_shader_source(shader, &uniform_signature);
            let color_module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("custom_color_shader"),
                    source: wgpu::ShaderSource::Wgsl(color_source.into()),
                });
            let color_instanced_module =
                self.device
                    .create_shader_module(wgpu::ShaderModuleDescriptor {
                        label: Some("custom_color_instanced_shader"),
                        source: wgpu::ShaderSource::Wgsl(color_instanced_source.into()),
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
            let texture_instanced_module =
                self.device
                    .create_shader_module(wgpu::ShaderModuleDescriptor {
                        label: Some("custom_texture_instanced_shader"),
                        source: wgpu::ShaderSource::Wgsl(texture_instanced_source.into()),
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
                    color_instanced_module,
                    texture_module,
                    texture_instanced_module,
                    particle_module,
                    textured_particle_module,
                    light_module,
                    color_layout,
                    texture_layout,
                    particle_layout,
                    textured_particle_layout,
                    light_layout,
                    color_pipelines: HashMap::new(),
                    color_instanced_pipelines: HashMap::new(),
                    texture_pipelines: HashMap::new(),
                    texture_instanced_pipelines: HashMap::new(),
                    particle_pipelines: HashMap::new(),
                    textured_particle_pipelines: HashMap::new(),
                    light_pipelines: HashMap::new(),
                },
            );
            self.shader_negative_cache.remove(shader_key);
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
                GeometryKind::Color => !cache.color_pipelines.contains_key(&key),
                GeometryKind::ColorInstanced => !cache.color_instanced_pipelines.contains_key(&key),
                GeometryKind::Texture => !cache.texture_pipelines.contains_key(&key),
                GeometryKind::TextureInstanced => {
                    !cache.texture_instanced_pipelines.contains_key(&key)
                }
                GeometryKind::Particle => !cache.particle_pipelines.contains_key(&key),
                GeometryKind::ParticleTextured => {
                    !cache.textured_particle_pipelines.contains_key(&key)
                }
                GeometryKind::Light => !cache.light_pipelines.contains_key(&key),
            }
        };
        if missing {
            let cache = self.shader_cache.get(shader_key)?;
            if cached_pipeline_count(cache) >= MAX_PIPELINES_PER_USER_SHADER {
                self.render_diagnostics.record_shader_pipeline_failure();
                self.render_stats.shader_cache_rejections =
                    self.render_stats.shader_cache_rejections.saturating_add(1);
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
                    GeometryKind::Color => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.color_layout,
                        &cache.color_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
                    ),
                    GeometryKind::ColorInstanced => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.color_layout,
                        &cache.color_instanced_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
                    ),
                    GeometryKind::Texture => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.texture_layout,
                        &cache.texture_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
                    ),
                    GeometryKind::TextureInstanced => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.texture_layout,
                        &cache.texture_instanced_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
                    ),
                    GeometryKind::Particle => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.particle_layout,
                        &cache.particle_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
                    ),
                    GeometryKind::ParticleTextured => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &cache.textured_particle_layout,
                        &cache.textured_particle_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                        key.sample_count,
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
                            1,
                        )
                    }
                }
            };
            let Some(cache) = self.shader_cache.get_mut(shader_key) else {
                debug_assert!(false, "shader cache missing for pipeline insertion");
                return None;
            };
            match geometry {
                GeometryKind::Color => {
                    cache.color_pipelines.insert(key, pipeline);
                }
                GeometryKind::ColorInstanced => {
                    cache.color_instanced_pipelines.insert(key, pipeline);
                }
                GeometryKind::Texture => {
                    cache.texture_pipelines.insert(key, pipeline);
                }
                GeometryKind::TextureInstanced => {
                    cache.texture_instanced_pipelines.insert(key, pipeline);
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
            GeometryKind::Color => {
                let pipeline = cache.color_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom color pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::ColorInstanced => {
                let pipeline = cache.color_instanced_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom instanced color pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::Texture => {
                let pipeline = cache.texture_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom texture pipeline missing after ensure"
                );
                pipeline
            }
            GeometryKind::TextureInstanced => {
                let pipeline = cache.texture_instanced_pipelines.get(&key);
                debug_assert!(
                    pipeline.is_some(),
                    "custom instanced texture pipeline missing after ensure"
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
            GeometryKind::Color => cache.color_pipelines.get(&key),
            GeometryKind::ColorInstanced => cache.color_instanced_pipelines.get(&key),
            GeometryKind::Texture => cache.texture_pipelines.get(&key),
            GeometryKind::TextureInstanced => cache.texture_instanced_pipelines.get(&key),
            GeometryKind::Particle => cache.particle_pipelines.get(&key),
            GeometryKind::ParticleTextured => cache.textured_particle_pipelines.get(&key),
            GeometryKind::Light => cache.light_pipelines.get(&key),
        }
    }
}
