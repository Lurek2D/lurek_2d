//! - Dedicated fullscreen province-map GPU pipeline.
//! - Binds province id texture, border index texture, distance field texture, and storage buffers.
//! - Owns uniforms for viewport mapping and strategic/tactical mode selection.

use bytemuck::{Pod, Zeroable};
use wgpu::util::DeviceExt;

const PROVINCE_MAP_SHADER: &str = include_str!("../../assets/shaders/province_map.wgsl");

/// Uniforms used by the province map fullscreen shader.
#[repr(C)]
#[derive(Debug, Clone, Copy, Pod, Zeroable, PartialEq)]
pub struct ProvinceMapUniforms {
    /// Visible map rect in map-space pixels: left, top, right, bottom.
    pub viewport: [f32; 4],
    /// Source map size in pixels.
    pub map_size: [f32; 2],
    /// Target screen size in pixels.
    pub screen_size: [f32; 2],
    /// 0 = strategic, 1 = tactical.
    pub zoom_mode: u32,
    /// Time in seconds for optional shader animation.
    pub time: f32,
    /// Padding for 16-byte alignment.
    pub _pad1: [f32; 2],
}

impl ProvinceMapUniforms {
    /// Create default uniforms matching a full-map viewport.
    pub fn full_map(map_w: u32, map_h: u32, screen_w: f32, screen_h: f32) -> Self {
        Self {
            viewport: [0.0, 0.0, map_w as f32, map_h as f32],
            map_size: [map_w as f32, map_h as f32],
            screen_size: [screen_w, screen_h],
            zoom_mode: 1,
            time: 0.0,
            _pad1: [0.0, 0.0],
        }
    }
}

/// Province map GPU pipeline and bind-group layouts.
pub struct ProvinceMapPipeline {
    /// Render pipeline that draws a fullscreen triangle.
    pub pipeline: wgpu::RenderPipeline,
    /// Group-0 layout: textures and storage buffers.
    pub data_bind_group_layout: wgpu::BindGroupLayout,
    /// Group-1 layout: uniform block.
    pub uniform_bind_group_layout: wgpu::BindGroupLayout,
    /// Uniform GPU buffer.
    pub uniform_buffer: wgpu::Buffer,
    /// Uniform bind group bound at group 1.
    pub uniform_bind_group: wgpu::BindGroup,
}

impl ProvinceMapPipeline {
    /// Create province map render pipeline and uniform resources.
    pub fn new(device: &wgpu::Device, target_format: wgpu::TextureFormat) -> Self {
        let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("province_map_shader"),
            source: wgpu::ShaderSource::Wgsl(PROVINCE_MAP_SHADER.into()),
        });

        let data_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("province_map_data_bgl"),
            entries: &[
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Uint,
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Uint,
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 2,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Float { filterable: false },
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 3,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Storage { read_only: true },
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 4,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Storage { read_only: true },
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                },
            ],
        });

        let uniform_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("province_map_uniform_bgl"),
            entries: &[wgpu::BindGroupLayoutEntry {
                binding: 0,
                visibility: wgpu::ShaderStages::FRAGMENT,
                ty: wgpu::BindingType::Buffer {
                    ty: wgpu::BufferBindingType::Uniform,
                    has_dynamic_offset: false,
                    min_binding_size: None,
                },
                count: None,
            }],
        });

        let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("province_map_pipeline_layout"),
            bind_group_layouts: &[&data_bind_group_layout, &uniform_bind_group_layout],
            push_constant_ranges: &[],
        });

        let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("province_map_pipeline"),
            layout: Some(&pipeline_layout),
            vertex: wgpu::VertexState {
                module: &shader,
                entry_point: "vs_main",
                buffers: &[],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &shader,
                entry_point: "fs_main",
                targets: &[Some(wgpu::ColorTargetState {
                    format: target_format,
                    blend: Some(wgpu::BlendState::ALPHA_BLENDING),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Ccw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Fill,
                unclipped_depth: false,
                conservative: false,
            },
            depth_stencil: None,
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        });

        let uniform_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("province_map_uniform_buffer"),
            contents: bytemuck::bytes_of(&ProvinceMapUniforms::full_map(1, 1, 1.0, 1.0)),
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
        });

        let uniform_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("province_map_uniform_bg"),
            layout: &uniform_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: uniform_buffer.as_entire_binding(),
            }],
        });

        Self {
            pipeline,
            data_bind_group_layout,
            uniform_bind_group_layout,
            uniform_buffer,
            uniform_bind_group,
        }
    }

    /// Create bind group for province map textures and storage buffers.
    pub fn create_data_bind_group(
        &self,
        device: &wgpu::Device,
        province_id_view: &wgpu::TextureView,
        border_index_view: &wgpu::TextureView,
        distance_field_view: &wgpu::TextureView,
        province_data_buffer: &wgpu::Buffer,
        border_style_buffer: &wgpu::Buffer,
    ) -> wgpu::BindGroup {
        device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("province_map_data_bg"),
            layout: &self.data_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(province_id_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::TextureView(border_index_view),
                },
                wgpu::BindGroupEntry {
                    binding: 2,
                    resource: wgpu::BindingResource::TextureView(distance_field_view),
                },
                wgpu::BindGroupEntry {
                    binding: 3,
                    resource: province_data_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 4,
                    resource: border_style_buffer.as_entire_binding(),
                },
            ],
        })
    }

    /// Update province map uniforms.
    pub fn update_uniforms(&self, queue: &wgpu::Queue, uniforms: &ProvinceMapUniforms) {
        queue.write_buffer(&self.uniform_buffer, 0, bytemuck::bytes_of(uniforms));
    }
}
