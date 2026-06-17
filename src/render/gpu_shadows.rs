//! Manages 1D shadow map rendering, dynamic light lists, and compute dispatches. `render/gpu_shadows` delivers the gpu shadows implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Gathers occluder edge geometry and transforms it into GPU edge storage buffers. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Dispatches shadow compute shaders per light source to map distances into the shadow atlas. Public callable behavior is centered on `collect_shadow_edges`, while method-level behavior such as `ensure_light_resources`, `ensure_shadow_edge_capacity`, `dispatch_shadow_map_gpu`, `aabb_visible_2d` stays attached to the local data model and invariants.
//! Performs viewport culling on light sources before queuing commands. Runtime integration reaches sibling engine areas through crate modules `math`, `render`, `light`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Binds and manages GPU buffers, bind groups, and pipelines for light passes. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! Filters occluding shapes by light bitmasks and culls lines outside light radii. The file boundary separates render implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use crate::math::Mat3;
use crate::render::gpu_light::MAX_SHADOW_LIGHTS;
use crate::render::gpu_renderer::{LIGHT_SHADER, SHADOW_COMPUTE_SHADER};
use crate::render::gpu_types::{LightVertex, MAX_LIGHT_QUADS};
use crate::render::gpu_types::{ShadowComputeParams, ShadowDispatchInput, ShadowEdgeGpu};

use crate::render::gpu_pipeline::{blend_state_for, depth_stencil_state, GpuStencilMode};
use crate::render::renderer::BlendMode;

use super::GpuRenderer;
use crate::light::occluder::Occluder;
use crate::render::gpu_light::{LightGpuState, SHADOW_COMPUTE_WORKGROUP_SIZE, SHADOW_MAP_RES};

/// Converts occluder polygons into light-relative shadow edge segments.
pub(crate) fn collect_shadow_edges(
    light_x: f32,
    light_y: f32,
    shadow_mask: u16,
    occluders: impl IntoIterator<Item = impl std::borrow::Borrow<Occluder>>,
) -> Vec<ShadowEdgeGpu> {
    let mut edges = Vec::new();
    for occ_ref in occluders {
        let occ = occ_ref.borrow();
        if !occ.enabled {
            continue;
        }
        if occ.light_mask & shadow_mask == 0 {
            continue;
        }
        let verts = occ.get_vertices();
        let n = verts.len();
        if n < 2 {
            continue;
        }
        for j in 0..n {
            let a = verts[j];
            let b = verts[(j + 1) % n];
            let ax = a.x + occ.position.x - light_x;
            let ay = a.y + occ.position.y - light_y;
            let bx = b.x + occ.position.x - light_x;
            let by = b.y + occ.position.y - light_y;
            edges.push(ShadowEdgeGpu {
                ax,
                ay,
                sx: bx - ax,
                sy: by - ay,
            });
        }
    }
    edges
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
                                4 => Float32x4
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
                multisample: wgpu::MultisampleState::default(),
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
    pub(crate) fn ensure_shadow_edge_capacity(&mut self, required_edges: usize) {
        let Some(lg) = self.light_gpu.as_mut() else {
            return;
        };
        if required_edges <= lg.shadow_edge_capacity {
            return;
        }
        let new_capacity = required_edges.max(1).next_power_of_two();
        let shadow_edge_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("shadow_edge_buffer"),
            size: (new_capacity * std::mem::size_of::<ShadowEdgeGpu>()) as u64,
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
    }

    /// Uploads shadow edges and dispatches the compute shader for one light row.
    pub(crate) fn dispatch_shadow_map_gpu(
        &mut self,
        encoder: &mut wgpu::CommandEncoder,
        input: ShadowDispatchInput<'_>,
    ) {
        let edges = collect_shadow_edges(
            input.light_x,
            input.light_y,
            input.shadow_mask,
            input.occluders.iter().copied(),
        );
        self.ensure_shadow_edge_capacity(edges.len());
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
