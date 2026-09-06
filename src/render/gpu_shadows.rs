//! Owns GPU shadow-map preparation, light culling, edge extraction, and compute dispatch for dynamic shadows.
//! Collects occluder edge geometry and uploads it into GPU buffers consumed by shadow compute passes.
//! Dispatches one-dimensional shadow map work per visible light source so light distance fields stay current.
//! Performs viewport and radius culling before queueing shadow work, reducing unnecessary compute load.
//! Manages the bind groups, buffers, and pipelines that connect light data to the shadow atlas workflow.
//! Filters occluders by light masks so only relevant blocking geometry contributes to a given light pass.
//! Reuses per-occluder world-space edge lists across shadow lights until occluder geometry generation changes.
//! Acts as the shadow-runtime boundary rather than the owner of general draw command interpretation.
//! Open this file when shadow edges, light culling, or compute-driven shadow atlas updates behave incorrectly.

use std::borrow::Borrow;
use std::collections::{hash_map::Entry, HashMap};

use crate::math::Mat3;
use crate::render::gpu_light::MAX_SHADOW_LIGHTS;
use crate::render::gpu_renderer::{LIGHT_SHADER, SHADOW_COMPUTE_SHADER};
use crate::render::gpu_types::{LightVertex, MAX_LIGHT_QUADS};
use crate::render::gpu_types::{ShadowComputeParams, ShadowDispatchInput, ShadowEdgeGpu};

use crate::render::gpu_pipeline::{blend_state_for, depth_stencil_state, GpuStencilMode};
use crate::render::renderer::BlendMode;

use super::GpuRenderer;
use crate::light::occluder::Occluder;
use crate::math::Vec2;
use crate::render::gpu_light::{LightGpuState, SHADOW_COMPUTE_WORKGROUP_SIZE, SHADOW_MAP_RES};

/// Maximum caster edges uploaded for one shadow-light compute dispatch.
///
/// This bounds both temporary CPU collection and the dynamic storage buffer even
/// when a game provides many valid occluders.
pub const MAX_SHADOW_EDGES_PER_DISPATCH: usize = 65_536;

/// Result of collecting shadow caster edges for one light.
#[derive(Default, Clone)]
pub struct ShadowEdgeCollection {
    /// Light-relative edges that should be uploaded to the GPU shadow pass.
    pub edges: Vec<ShadowEdgeGpu>,
    /// Number of edges kept after mask, enabled-state, and radius filtering.
    pub edges_collected: usize,
    /// Number of edges skipped because their occluder AABB was outside the light radius.
    pub edges_culled_by_radius: usize,
    /// Number of occluders whose cached world-space edge list was reused.
    pub cache_hits: usize,
    /// Number of occluders whose world-space edge list was rebuilt.
    pub cache_misses: usize,
    /// True when the trusted edge or allocation budget cut collection short.
    pub truncated: bool,
}

/// Reusable per-frame cache for shadow occluder edge geometry.
#[derive(Default)]
pub struct ShadowEdgeCache {
    entries: HashMap<usize, CachedShadowEdges>,
}

struct CachedShadowEdges {
    generation: u128,
    edge_count: usize,
    world_aabb: Option<(f32, f32, f32, f32)>,
    world_edges: Option<Vec<ShadowEdgeGpu>>,
}

/// Converts occluder polygons into light-relative shadow edge segments.
pub fn collect_shadow_edges(
    light_x: f32,
    light_y: f32,
    shadow_mask: u16,
    occluders: impl IntoIterator<Item = impl Borrow<Occluder>>,
) -> Vec<ShadowEdgeGpu> {
    collect_shadow_edges_with_stats(light_x, light_y, f32::INFINITY, shadow_mask, occluders).edges
}

/// Converts occluder polygons into light-relative shadow edge segments and culls distant casters.
pub fn collect_shadow_edges_with_stats(
    light_x: f32,
    light_y: f32,
    light_radius: f32,
    shadow_mask: u16,
    occluders: impl IntoIterator<Item = impl Borrow<Occluder>>,
) -> ShadowEdgeCollection {
    let mut cache = ShadowEdgeCache::default();
    collect_shadow_edges_with_cache(
        light_x,
        light_y,
        light_radius,
        shadow_mask,
        occluders,
        &mut cache,
    )
}

/// Converts occluder polygons into light-relative shadow edge segments using a reusable edge cache.
pub fn collect_shadow_edges_with_cache(
    light_x: f32,
    light_y: f32,
    light_radius: f32,
    shadow_mask: u16,
    occluders: impl IntoIterator<Item = impl Borrow<Occluder>>,
    cache: &mut ShadowEdgeCache,
) -> ShadowEdgeCollection {
    let mut edges = Vec::new();
    let mut edges_culled_by_radius = 0usize;
    let mut cache_hits = 0usize;
    let mut cache_misses = 0usize;
    let mut truncated = false;
    let light_pos = Vec2::new(light_x, light_y);
    for occ_ref in occluders {
        let occ = occ_ref.borrow();
        if !occ.enabled || !occ.is_render_valid() {
            continue;
        }
        if occ.light_mask & shadow_mask == 0 {
            continue;
        }
        let cached = cached_shadow_edges(cache, occ);
        if cached.cache_hit {
            cache_hits = cache_hits.saturating_add(1);
        } else {
            cache_misses = cache_misses.saturating_add(1);
        }
        if cached.edges.edge_count < 2 {
            continue;
        }
        if !aabb_intersects_light_radius(cached.edges.world_aabb, light_pos, light_radius) {
            edges_culled_by_radius = edges_culled_by_radius.saturating_add(cached.edges.edge_count);
            continue;
        }
        let world_edges = cached.edges.world_edges(occ);
        let remaining = MAX_SHADOW_EDGES_PER_DISPATCH.saturating_sub(edges.len());
        if remaining == 0 {
            truncated = true;
            break;
        }
        let accepted = world_edges.len().min(remaining);
        if edges.try_reserve(accepted).is_err() {
            truncated = true;
            break;
        }
        for edge in world_edges.iter().take(accepted) {
            edges.push(ShadowEdgeGpu {
                ax: edge.ax - light_x,
                ay: edge.ay - light_y,
                sx: edge.sx,
                sy: edge.sy,
            });
        }
        if accepted != world_edges.len() {
            truncated = true;
            break;
        }
    }
    ShadowEdgeCollection {
        edges_collected: edges.len(),
        edges,
        edges_culled_by_radius,
        cache_hits,
        cache_misses,
        truncated,
    }
}

struct CachedShadowEdgeLookup<'a> {
    edges: &'a mut CachedShadowEdges,
    cache_hit: bool,
}

fn cached_shadow_edges<'a>(
    cache: &'a mut ShadowEdgeCache,
    occ: &Occluder,
) -> CachedShadowEdgeLookup<'a> {
    let key = occ as *const Occluder as usize;
    let generation = occ.edge_generation();
    let mut cache_hit = false;
    let edges = match cache.entries.entry(key) {
        Entry::Occupied(mut entry) => {
            if entry.get().generation == generation {
                cache_hit = true;
            } else {
                entry.insert(CachedShadowEdges::from_occluder_bounds(occ));
            }
            entry.into_mut()
        }
        Entry::Vacant(entry) => entry.insert(CachedShadowEdges::from_occluder_bounds(occ)),
    };
    CachedShadowEdgeLookup { edges, cache_hit }
}

impl CachedShadowEdges {
    fn from_occluder_bounds(occ: &Occluder) -> Self {
        let verts = occ.get_vertices();
        let mut min_x = f32::INFINITY;
        let mut max_x = f32::NEG_INFINITY;
        let mut min_y = f32::INFINITY;
        let mut max_y = f32::NEG_INFINITY;
        let mut aabb_valid = true;
        for vertex in verts {
            let x = vertex.x + occ.position.x;
            let y = vertex.y + occ.position.y;
            if !x.is_finite() || !y.is_finite() {
                aabb_valid = false;
            }
            min_x = min_x.min(x);
            max_x = max_x.max(x);
            min_y = min_y.min(y);
            max_y = max_y.max(y);
        }
        let world_aabb = if aabb_valid
            && min_x.is_finite()
            && max_x.is_finite()
            && min_y.is_finite()
            && max_y.is_finite()
        {
            Some((min_x, max_x, min_y, max_y))
        } else {
            None
        };
        Self {
            generation: occ.edge_generation(),
            edge_count: verts.len(),
            world_aabb,
            world_edges: None,
        }
    }

    fn world_edges(&mut self, occ: &Occluder) -> &[ShadowEdgeGpu] {
        if self.world_edges.is_none() {
            let verts = occ.get_vertices();
            let mut edges = Vec::new();
            // Cached occluder geometry can originate in game content.  If a
            // reservation fails, retain an empty cache entry so the renderer
            // deterministically skips this occluder instead of panicking and
            // attempting the allocation again every frame.
            if edges.try_reserve(verts.len()).is_err() {
                self.world_edges = Some(edges);
                return self.world_edges.as_deref().unwrap_or_default();
            }
            for j in 0..verts.len() {
                let a = verts[j];
                let b = verts[(j + 1) % verts.len()];
                let ax = a.x + occ.position.x;
                let ay = a.y + occ.position.y;
                let bx = b.x + occ.position.x;
                let by = b.y + occ.position.y;
                edges.push(ShadowEdgeGpu {
                    ax,
                    ay,
                    sx: bx - ax,
                    sy: by - ay,
                });
            }
            self.world_edges = Some(edges);
        }
        self.world_edges.as_deref().unwrap_or_default()
    }
}

fn aabb_intersects_light_radius(
    world_aabb: Option<(f32, f32, f32, f32)>,
    light_pos: Vec2,
    light_radius: f32,
) -> bool {
    if !light_radius.is_finite() {
        return true;
    }
    if light_radius <= 0.0 {
        return false;
    }
    let Some((min_x, max_x, min_y, max_y)) = world_aabb else {
        return false;
    };
    let closest_x = light_pos.x.clamp(min_x, max_x);
    let closest_y = light_pos.y.clamp(min_y, max_y);
    let dx = closest_x - light_pos.x;
    let dy = closest_y - light_pos.y;
    dx.mul_add(dx, dy * dy) <= light_radius * light_radius
}

impl GpuRenderer {
    /// Creates or recreates all GPU resources needed for light and shadow rendering.
    pub(crate) fn ensure_light_resources(&mut self) {
        let needs_recreate = match &self.light_gpu {
            Some(lg) => lg.width != self.width || lg.height != self.height,
            None => true,
        };
        if !needs_recreate {
            return;
        }
        let w = self.width;
        let h = self.height;
        let accum_texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("light_accum_texture"),
            size: wgpu::Extent3d {
                width: w,
                height: h,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: self.surface_format,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
            view_formats: &[],
        });
        let accum_view = accum_texture.create_view(&wgpu::TextureViewDescriptor::default());
        let sampler = self.device.create_sampler(&wgpu::SamplerDescriptor {
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            ..Default::default()
        });
        let accum_bind_group =
            self.create_texture_bind_group(&accum_view, &sampler, "light_accum_bg");
        let shadow_atlas_texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("shadow_atlas_texture"),
            size: wgpu::Extent3d {
                width: SHADOW_MAP_RES as u32,
                height: MAX_SHADOW_LIGHTS as u32,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::R32Float,
            usage: wgpu::TextureUsages::TEXTURE_BINDING
                | wgpu::TextureUsages::STORAGE_BINDING
                | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        let shadow_atlas_view =
            shadow_atlas_texture.create_view(&wgpu::TextureViewDescriptor::default());
        let shadow_bgl = self
            .device
            .create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                label: Some("shadow_atlas_bgl"),
                entries: &[
                    wgpu::BindGroupLayoutEntry {
                        binding: 0,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Texture {
                            sample_type: wgpu::TextureSampleType::Float { filterable: false },
                            view_dimension: wgpu::TextureViewDimension::D2,
                            multisampled: false,
                        },
                        count: None,
                    },
                    wgpu::BindGroupLayoutEntry {
                        binding: 1,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::NonFiltering),
                        count: None,
                    },
                ],
            });
        let shadow_sampler = self.device.create_sampler(&wgpu::SamplerDescriptor {
            mag_filter: wgpu::FilterMode::Nearest,
            min_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });
        let shadow_atlas_bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("shadow_atlas_bg"),
            layout: &shadow_bgl,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(&shadow_atlas_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(&shadow_sampler),
                },
            ],
        });
        let light_pipeline_layout =
            self.device
                .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                    label: Some("light_pipeline_layout"),
                    bind_group_layouts: &[&self.viewport_bind_group_layout, &shadow_bgl],
                    push_constant_ranges: &[],
                });
        let light_module = self
            .device
            .create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("light_shader"),
                source: wgpu::ShaderSource::Wgsl(LIGHT_SHADER.into()),
            });
        let additive_pipeline =
            self.device
                .create_render_pipeline(&wgpu::RenderPipelineDescriptor {
                    label: Some("light_additive_pipeline"),
                    layout: Some(&light_pipeline_layout),
                    vertex: wgpu::VertexState {
                        module: &light_module,
                        entry_point: "vs_main",
                        compilation_options: Default::default(),
                        buffers: &[wgpu::VertexBufferLayout {
                            array_stride: std::mem::size_of::<LightVertex>() as wgpu::BufferAddress,
                            step_mode: wgpu::VertexStepMode::Vertex,
                            attributes: &wgpu::vertex_attr_array![
                                0 => Float32x2,
                                1 => Float32x2,
                                2 => Float32x4,
                                3 => Float32,
                                4 => Float32x4,
                                5 => Float32x2,
                                6 => Float32,
                                7 => Float32,
                                8 => Float32x2
                            ],
                        }],
                    },
                    fragment: Some(wgpu::FragmentState {
                        module: &light_module,
                        entry_point: "fs_main",
                        compilation_options: Default::default(),
                        targets: &[Some(wgpu::ColorTargetState {
                            format: self.surface_format,
                            blend: Some(blend_state_for(BlendMode::Add)),
                            write_mask: wgpu::ColorWrites::ALL,
                        })],
                    }),
                    primitive: wgpu::PrimitiveState {
                        topology: wgpu::PrimitiveTopology::TriangleList,
                        ..Default::default()
                    },
                    depth_stencil: None,
                    multisample: wgpu::MultisampleState::default(),
                    multiview: None,
                    cache: None,
                });
        // The composite quad is stored in the same LightVertex buffer (52-byte stride).
        // Using create_render_pipeline(GeometryKind::Texture) would declare TexVertex stride
        // (48 bytes), misaligning every composite vertex read.  Build the pipeline manually
        // so the buffer layout matches the actual data.
        let composite_pipeline = {
            let device = &self.device;
            let layout = &self.default_texture_layout;
            let shader = &self.default_texture_shader;
            let fmt = self.surface_format;
            device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
                label: Some("light_composite_pipeline"),
                layout: Some(layout),
                vertex: wgpu::VertexState {
                    module: shader,
                    entry_point: "vs_main",
                    compilation_options: Default::default(),
                    buffers: &[wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<LightVertex>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Vertex,
                        attributes: &wgpu::vertex_attr_array![
                            0 => Float32x2, // position
                            1 => Float32x2, // uv
                            2 => Float32x4, // color
                            3 => Float32,   // shadow_v → read as w_depth by TEXTURE_SHADER
                            4 => Float32x4, // shadow_params (unused by TEXTURE_SHADER)
                        ],
                    }],
                },
                fragment: Some(wgpu::FragmentState {
                    module: shader,
                    entry_point: "fs_main",
                    compilation_options: Default::default(),
                    targets: &[Some(wgpu::ColorTargetState {
                        format: fmt,
                        blend: Some(blend_state_for(BlendMode::Multiply)),
                        write_mask: wgpu::ColorWrites::ALL,
                    })],
                }),
                primitive: wgpu::PrimitiveState {
                    topology: wgpu::PrimitiveTopology::TriangleList,
                    ..Default::default()
                },
                depth_stencil: Some(depth_stencil_state(GpuStencilMode::Disabled)),
                multisample: crate::render::gpu_pipeline::multisample_state(self.sample_count),
                multiview: None,
                cache: None,
            })
        };
        let max_verts = (MAX_LIGHT_QUADS + 1) * 4;
        let max_idxs = (MAX_LIGHT_QUADS + 1) * 6;
        let vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("light_vbo"),
            size: (max_verts * std::mem::size_of::<LightVertex>()) as u64,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("light_ibo"),
            size: (max_idxs * std::mem::size_of::<u32>()) as u64,
            usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let shadow_edge_capacity = 1usize;
        let shadow_edge_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("shadow_edge_buffer"),
            size: std::mem::size_of::<ShadowEdgeGpu>() as u64,
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let shadow_params_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("shadow_compute_params"),
            size: std::mem::size_of::<ShadowComputeParams>() as u64,
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let shadow_compute_bind_group_layout =
            self.device
                .create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                    label: Some("shadow_compute_bgl"),
                    entries: &[
                        wgpu::BindGroupLayoutEntry {
                            binding: 0,
                            visibility: wgpu::ShaderStages::COMPUTE,
                            ty: wgpu::BindingType::Buffer {
                                ty: wgpu::BufferBindingType::Storage { read_only: true },
                                has_dynamic_offset: false,
                                min_binding_size: None,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 1,
                            visibility: wgpu::ShaderStages::COMPUTE,
                            ty: wgpu::BindingType::Buffer {
                                ty: wgpu::BufferBindingType::Uniform,
                                has_dynamic_offset: false,
                                min_binding_size: None,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 2,
                            visibility: wgpu::ShaderStages::COMPUTE,
                            ty: wgpu::BindingType::StorageTexture {
                                access: wgpu::StorageTextureAccess::WriteOnly,
                                format: wgpu::TextureFormat::R32Float,
                                view_dimension: wgpu::TextureViewDimension::D2,
                            },
                            count: None,
                        },
                    ],
                });
        let shadow_compute_bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("shadow_compute_bg"),
            layout: &shadow_compute_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: shadow_edge_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: shadow_params_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 2,
                    resource: wgpu::BindingResource::TextureView(&shadow_atlas_view),
                },
            ],
        });
        let shadow_compute_layout =
            self.device
                .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                    label: Some("shadow_compute_layout"),
                    bind_group_layouts: &[&shadow_compute_bind_group_layout],
                    push_constant_ranges: &[],
                });
        let shadow_compute_module =
            self.device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("shadow_compute_shader"),
                    source: wgpu::ShaderSource::Wgsl(SHADOW_COMPUTE_SHADER.into()),
                });
        let shadow_compute_pipeline =
            self.device
                .create_compute_pipeline(&wgpu::ComputePipelineDescriptor {
                    label: Some("shadow_compute_pipeline"),
                    layout: Some(&shadow_compute_layout),
                    module: &shadow_compute_module,
                    entry_point: "cs_main",
                    compilation_options: Default::default(),
                    cache: None,
                });
        self.light_gpu = Some(LightGpuState {
            accum_texture,
            accum_view,
            accum_bind_group,
            additive_pipeline,
            composite_pipeline,
            vertex_buffer,
            index_buffer,
            shadow_atlas_texture,
            shadow_atlas_view,
            shadow_atlas_bind_group,
            shadow_atlas_bind_group_layout: shadow_bgl,
            shadow_compute_bind_group_layout,
            shadow_compute_bind_group,
            shadow_compute_pipeline,
            shadow_edge_buffer,
            shadow_edge_capacity,
            shadow_params_buffer,
            width: w,
            height: h,
        });
    }

    /// Grows the shadow edge storage buffer to hold the required edge count.
    pub(crate) fn ensure_shadow_edge_capacity(&mut self, required_edges: usize) -> bool {
        let Some(lg) = self.light_gpu.as_mut() else {
            return false;
        };
        if required_edges <= lg.shadow_edge_capacity {
            return true;
        }
        let Some(new_capacity) = required_edges.max(1).checked_next_power_of_two() else {
            return false;
        };
        let Some(byte_size) = new_capacity.checked_mul(std::mem::size_of::<ShadowEdgeGpu>()) else {
            return false;
        };
        let Ok(byte_size) = u64::try_from(byte_size) else {
            return false;
        };
        if byte_size > self.device.limits().max_buffer_size {
            return false;
        }
        let shadow_edge_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("shadow_edge_buffer"),
            size: byte_size,
            usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let shadow_compute_bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("shadow_compute_bg"),
            layout: &lg.shadow_compute_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: shadow_edge_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: lg.shadow_params_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 2,
                    resource: wgpu::BindingResource::TextureView(&lg.shadow_atlas_view),
                },
            ],
        });
        lg.shadow_edge_buffer = shadow_edge_buffer;
        lg.shadow_edge_capacity = new_capacity;
        lg.shadow_compute_bind_group = shadow_compute_bind_group;
        self.render_diagnostics.record_buffer_growth_event();
        true
    }

    /// Uploads shadow edges and dispatches the compute shader for one light row.
    pub(crate) fn dispatch_shadow_map_gpu(
        &mut self,
        encoder: &mut wgpu::CommandEncoder,
        input: ShadowDispatchInput<'_>,
        shadow_edge_cache: &mut ShadowEdgeCache,
    ) {
        let edge_collection = collect_shadow_edges_with_cache(
            input.light_x,
            input.light_y,
            input.light_radius,
            input.shadow_mask,
            input.occluders.iter().copied(),
            shadow_edge_cache,
        );
        self.render_diagnostics.record_shadow_dispatch(
            edge_collection.edges_collected,
            edge_collection.edges_culled_by_radius,
        );
        let edges = edge_collection.edges;
        if edge_collection.truncated || !self.ensure_shadow_edge_capacity(edges.len()) {
            self.render_diagnostics.record_invalid_render_input();
            return;
        }
        let Some(lg) = self.light_gpu.as_ref() else {
            return;
        };
        if !edges.is_empty() {
            self.queue
                .write_buffer(&lg.shadow_edge_buffer, 0, bytemuck::cast_slice(&edges));
        }
        let params = ShadowComputeParams {
            inv_radius: if input.light_radius > 0.0 {
                1.0 / input.light_radius
            } else {
                0.0
            },
            edge_count: edges.len() as u32,
            row: input.row as u32,
            _pad: 0,
        };
        self.queue
            .write_buffer(&lg.shadow_params_buffer, 0, bytemuck::bytes_of(&params));
        let mut cpass = encoder.begin_compute_pass(&wgpu::ComputePassDescriptor {
            label: Some("shadow_compute_pass"),
            timestamp_writes: None,
        });
        cpass.set_pipeline(&lg.shadow_compute_pipeline);
        cpass.set_bind_group(0, &lg.shadow_compute_bind_group, &[]);
        cpass.dispatch_workgroups(
            (SHADOW_MAP_RES as u32).div_ceil(SHADOW_COMPUTE_WORKGROUP_SIZE),
            1,
            1,
        );
    }

    #[allow(clippy::too_many_arguments)]
    /// Tests whether a transformed 2D axis-aligned rectangle intersects the viewport.
    pub(crate) fn aabb_visible_2d(
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        model: &Mat3,
        camera: &Mat3,
        vp_w: f32,
        vp_h: f32,
    ) -> bool {
        let corners = [
            crate::math::Vec2 { x, y },
            crate::math::Vec2 { x: x + w, y },
            crate::math::Vec2 { x, y: y + h },
            crate::math::Vec2 { x: x + w, y: y + h },
        ];
        let mvp = *camera * *model;
        let mut min_x = f32::INFINITY;
        let mut max_x = f32::NEG_INFINITY;
        let mut min_y = f32::INFINITY;
        let mut max_y = f32::NEG_INFINITY;
        for c in &corners {
            let s = mvp.transform_point(*c);
            if s.x < min_x {
                min_x = s.x;
            }
            if s.x > max_x {
                max_x = s.x;
            }
            if s.y < min_y {
                min_y = s.y;
            }
            if s.y > max_y {
                max_y = s.y;
            }
        }
        const MARGIN: f32 = 4.0;
        max_x >= -MARGIN && min_x <= vp_w + MARGIN && max_y >= -MARGIN && min_y <= vp_h + MARGIN
    }
}
