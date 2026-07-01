//! Defines the specialized GPU pipeline used to render detailed province-map views with dedicated shader inputs.
//! Binds region ids, border data, height-like fields, and viewport parameters needed by province-focused passes.
//! Packages uniforms for zoom, map size, viewport range, and time so province visuals update coherently.
//! Keeps province-specific bind groups and pipeline layout separate from the general-purpose render backend.
//! Acts as the province-map boundary between geographic data textures and shader-driven fullscreen presentation.
//! Open this file when province shader inputs, uniforms, or fullscreen province-map output behaves incorrectly.

use bytemuck::{Pod, Zeroable};
use wgpu::util::DeviceExt;

const PROVINCE_MAP_SHADER: &str = include_str!("shaders/province_map.wgsl");

fn default_province_watermark_rgba() -> [u8; 8 * 8 * 4] {
    let mut pixels = [0_u8; 8 * 8 * 4];
    let mark = [
        (3, 1, 96),
        (2, 2, 74),
        (3, 2, 92),
        (4, 2, 74),
        (1, 3, 58),
        (2, 3, 82),
        (3, 3, 96),
        (4, 3, 82),
        (5, 3, 58),
        (2, 4, 54),
        (3, 4, 80),
        (4, 4, 54),
        (3, 5, 80),
        (3, 6, 72),
    ];
    for (x, y, alpha) in mark {
        let offset = ((y * 8 + x) * 4) as usize;
        pixels[offset] = 96;
        pixels[offset + 1] = 96;
        pixels[offset + 2] = 88;
        pixels[offset + 3] = alpha;
    }
    pixels
}

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
    /// Repeating terrain texture scale in map pixels per tile.
    pub terrain_texture_scale: f32,
    /// Strength of the subtle terrain texture watermark, 0 disables it.
    pub terrain_texture_strength: f32,
    /// Global fill tint multiplied into all province colors at draw time.
    pub fill_tint: [f32; 4],
    /// RGBA color mixed into province interiors near borders by the edge-distance gradient.
    pub edge_gradient_color: [f32; 4],
    /// Edge gradient parameters: radius in output pixels, strength, softness, R8 distance decode scale.
    pub edge_gradient_params: [f32; 4],
    /// Default same-terrain province border color used when render border palette is enabled.
    pub province_border_color: [f32; 4],
    /// Default coast border color used when render border palette is enabled.
    pub coast_border_color: [f32; 4],
    /// Default country border color used when render border palette is enabled.
    pub country_border_color: [f32; 4],
    /// Border palette parameters: enabled flag, sea darken amount, reserved, reserved.
    pub border_palette_params: [f32; 4],
    /// Border-noise parameters: frequency, amplitude_px, softness_px, enabled flag.
    pub border_noise_params: [f32; 4],
    /// Water-effect parameters: strength, speed, scale, reserved.
    pub water_params: [f32; 4],
    /// Weather parameters: global strength, speed, direction x, direction y.
    pub weather_params: [f32; 4],
    /// Fog parameters: discovered desaturation, noise strength, enabled flag, reserved.
    pub fog_params: [f32; 4],
    /// Fog hidden-area fallback color.
    pub fog_hidden_color: [f32; 4],
    /// Climate parameters: tint strength, season phase, season strength, enabled flag.
    pub climate_params: [f32; 4],
    /// Province highlight ids: selected id, hovered id, reserved, reserved.
    pub highlight_ids: [u32; 4],
    /// Deterministic effect seeds: border noise seed plus reserved slots.
    pub effect_seeds: [u32; 4],
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
            terrain_texture_scale: 32.0,
            terrain_texture_strength: 0.0,
            fill_tint: [1.0, 1.0, 1.0, 1.0],
            edge_gradient_color: [64.0 / 255.0, 64.0 / 255.0, 60.0 / 255.0, 1.0],
            edge_gradient_params: [16.0, 0.25, 0.45, 255.0],
            province_border_color: [72.0 / 255.0, 58.0 / 255.0, 32.0 / 255.0, 1.0],
            coast_border_color: [224.0 / 255.0, 196.0 / 255.0, 128.0 / 255.0, 238.0 / 255.0],
            country_border_color: [230.0 / 255.0, 48.0 / 255.0, 44.0 / 255.0, 245.0 / 255.0],
            border_palette_params: [1.0, 0.15, 0.0, 0.0],
            border_noise_params: [0.07, 0.0, 1.0, 0.0],
            water_params: [0.0, 0.08, 48.0, 0.0],
            weather_params: [0.0, 1.0, 0.7, 1.0],
            fog_params: [1.0, 0.0, 0.0, 0.0],
            fog_hidden_color: [0.02, 0.02, 0.02, 1.0],
            climate_params: [0.0, 0.0, 0.0, 0.0],
            highlight_ids: [0, 0, 0, 0],
            effect_seeds: [0, 0, 0, 0],
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
    /// Neutral fallback terrain texture kept alive for draws without a supplied terrain image.
    pub(crate) _default_terrain_texture: wgpu::Texture,
    /// View for the neutral fallback terrain texture.
    pub default_terrain_view: wgpu::TextureView,
    /// Sampler for the neutral fallback terrain texture.
    pub default_terrain_sampler: wgpu::Sampler,
}

/// Texture and buffer inputs bound by the province map fullscreen shader.
pub struct ProvinceMapDataBindings<'a> {
    /// Province id texture sampled from the imported id map.
    pub province_id_view: &'a wgpu::TextureView,
    /// Per-pixel border index texture.
    pub border_index_view: &'a wgpu::TextureView,
    /// Edge distance texture used for the configurable interior gradient.
    pub distance_field_view: &'a wgpu::TextureView,
    /// Dense per-province color/style buffer.
    pub province_data_buffer: &'a wgpu::Buffer,
    /// Per-border style buffer.
    pub border_style_buffer: &'a wgpu::Buffer,
    /// Optional terrain/watermark texture view, already resolved to a fallback when needed.
    pub terrain_texture_view: &'a wgpu::TextureView,
    /// Sampler for the terrain/watermark texture.
    pub terrain_texture_sampler: &'a wgpu::Sampler,
}

impl ProvinceMapPipeline {
    /// Create province map render pipeline and uniform resources.
    pub fn new(
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        target_format: wgpu::TextureFormat,
    ) -> Self {
        let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("province_map_shader"),
            source: wgpu::ShaderSource::Wgsl(PROVINCE_MAP_SHADER.into()),
        });

        let data_bind_group_layout =
            device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
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
                    wgpu::BindGroupLayoutEntry {
                        binding: 5,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Texture {
                            sample_type: wgpu::TextureSampleType::Float { filterable: true },
                            view_dimension: wgpu::TextureViewDimension::D2,
                            multisampled: false,
                        },
                        count: None,
                    },
                    wgpu::BindGroupLayoutEntry {
                        binding: 6,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                        count: None,
                    },
                ],
            });

        let uniform_bind_group_layout =
            device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
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
        let default_terrain_texture = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("province_map_default_terrain_texture"),
            size: wgpu::Extent3d {
                width: 8,
                height: 8,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8Unorm,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        queue.write_texture(
            wgpu::ImageCopyTexture {
                texture: &default_terrain_texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            &default_province_watermark_rgba(),
            wgpu::ImageDataLayout {
                offset: 0,
                bytes_per_row: Some(8 * 4),
                rows_per_image: Some(8),
            },
            wgpu::Extent3d {
                width: 8,
                height: 8,
                depth_or_array_layers: 1,
            },
        );
        let default_terrain_view =
            default_terrain_texture.create_view(&wgpu::TextureViewDescriptor::default());
        let default_terrain_sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("province_map_default_terrain_sampler"),
            address_mode_u: wgpu::AddressMode::Repeat,
            address_mode_v: wgpu::AddressMode::Repeat,
            address_mode_w: wgpu::AddressMode::Repeat,
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });

        Self {
            pipeline,
            data_bind_group_layout,
            uniform_bind_group_layout,
            uniform_buffer,
            uniform_bind_group,
            _default_terrain_texture: default_terrain_texture,
            default_terrain_view,
            default_terrain_sampler,
        }
    }

    /// Create bind group for province map textures and storage buffers.
    pub fn create_data_bind_group(
        &self,
        device: &wgpu::Device,
        bindings: ProvinceMapDataBindings<'_>,
    ) -> wgpu::BindGroup {
        device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("province_map_data_bg"),
            layout: &self.data_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(bindings.province_id_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::TextureView(bindings.border_index_view),
                },
                wgpu::BindGroupEntry {
                    binding: 2,
                    resource: wgpu::BindingResource::TextureView(bindings.distance_field_view),
                },
                wgpu::BindGroupEntry {
                    binding: 3,
                    resource: bindings.province_data_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 4,
                    resource: bindings.border_style_buffer.as_entire_binding(),
                },
                wgpu::BindGroupEntry {
                    binding: 5,
                    resource: wgpu::BindingResource::TextureView(bindings.terrain_texture_view),
                },
                wgpu::BindGroupEntry {
                    binding: 6,
                    resource: wgpu::BindingResource::Sampler(bindings.terrain_texture_sampler),
                },
            ],
        })
    }

    /// Update province map uniforms.
    pub fn update_uniforms(&self, queue: &wgpu::Queue, uniforms: &ProvinceMapUniforms) {
        queue.write_buffer(&self.uniform_buffer, 0, bytemuck::bytes_of(uniforms));
    }
}
