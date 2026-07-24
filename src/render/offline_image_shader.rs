//! Owns the render offline image shader implementation for the render subsystem and keeps related runtime rules local here.
//! Keeps draw commands, GPU resources, and render-pass configuration so helpers stay close to invariants this file updates.
//! Defines how render offline image shader data is validated, transformed, or stored before neighboring systems consume it.
//! Separates render offline image shader behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where render code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing render offline image shader defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near render offline image shader state that explains them instead of outward.

use std::sync::mpsc::{self, TryRecvError};
use std::time::{Duration, Instant};

use crate::image::ImageData;
use crate::render::shader::{Shader, ShaderTarget};

const OFFLINE_IMAGE_VERTEX: &str = r#"
struct VertexOutput {
    @builtin(position) clip_pos: vec4<f32>,
    @location(0)       uv:       vec2<f32>,
}
@vertex
fn vs_main(@builtin(vertex_index) vi: u32) -> VertexOutput {
    let u = f32((vi & 1u) << 1u);
    let v = f32(vi & 2u);
    var out: VertexOutput;
    out.clip_pos = vec4<f32>(u * 2.0 - 1.0, 1.0 - v * 2.0, 0.0, 1.0);
    out.uv       = vec2<f32>(u, v);
    return out;
}
"#;

/// Offline tools may wait for readback, but always have a finite bound.
const OFFLINE_READBACK_TIMEOUT: Duration = Duration::from_secs(5);

fn padded_bytes_per_row(width: u32) -> u32 {
    let unpadded = width.saturating_mul(4);
    let alignment = wgpu::COPY_BYTES_PER_ROW_ALIGNMENT;
    unpadded.div_ceil(alignment) * alignment
}

fn request_headless_device() -> Result<(wgpu::Device, wgpu::Queue), String> {
    let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
        backends: wgpu::util::backend_bits_from_env().unwrap_or(wgpu::Backends::PRIMARY),
        ..Default::default()
    });
    let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: None,
        force_fallback_adapter: false,
    }))
    .ok_or_else(|| "offline image shader: no compatible GPU adapter found".to_string())?;
    pollster::block_on(adapter.request_device(
        &wgpu::DeviceDescriptor {
            label: Some("Lurek2D Offline Image Shader Device"),
            required_features: wgpu::Features::empty(),
            required_limits: wgpu::Limits::downlevel_defaults(),
            memory_hints: Default::default(),
        },
        None,
    ))
    .map_err(|error| format!("offline image shader: failed to create GPU device: {error}"))
}

/// Apply an image-target shader to RGBA `ImageData` and return a GPU-readback image.
pub fn apply_image_shader_blocking(
    image: &ImageData,
    shader: &Shader,
) -> Result<ImageData, String> {
    if shader.target() != ShaderTarget::Image {
        return Err(format!(
            "offline image shader requires image target, got {}",
            shader.target()
        ));
    }
    let (width, height) = image.dimensions();
    if width == 0 || height == 0 {
        return Err("offline image shader requires non-zero image dimensions".to_string());
    }

    let (device, queue) = request_headless_device()?;
    let max_dim = device.limits().max_texture_dimension_2d;
    if width > max_dim || height > max_dim {
        return Err(format!(
            "offline image shader dimensions {}x{} exceed GPU max texture dimension {}",
            width, height, max_dim
        ));
    }

    let size = wgpu::Extent3d {
        width,
        height,
        depth_or_array_layers: 1,
    };
    let source_texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("offline_image_shader_source"),
        size,
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        view_formats: &[],
    });
    queue.write_texture(
        wgpu::ImageCopyTexture {
            texture: &source_texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        image.as_bytes(),
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(width * 4),
            rows_per_image: Some(height),
        },
        size,
    );

    let output_texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("offline_image_shader_output"),
        size,
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::COPY_SRC,
        view_formats: &[],
    });
    let source_view = source_texture.create_view(&wgpu::TextureViewDescriptor::default());
    let output_view = output_texture.create_view(&wgpu::TextureViewDescriptor::default());
    let sampler = device.create_sampler(&wgpu::SamplerDescriptor {
        label: Some("offline_image_shader_sampler"),
        address_mode_u: wgpu::AddressMode::ClampToEdge,
        address_mode_v: wgpu::AddressMode::ClampToEdge,
        address_mode_w: wgpu::AddressMode::ClampToEdge,
        mag_filter: wgpu::FilterMode::Nearest,
        min_filter: wgpu::FilterMode::Nearest,
        mipmap_filter: wgpu::FilterMode::Nearest,
        ..Default::default()
    });
    let params_buf = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("offline_image_shader_params"),
        size: 64,
        usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });
    queue.write_buffer(&params_buf, 0, &[0_u8; 64]);

    let bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
        label: Some("offline_image_shader_bind_group_layout"),
        entries: &[
            wgpu::BindGroupLayoutEntry {
                binding: 0,
                visibility: wgpu::ShaderStages::FRAGMENT,
                ty: wgpu::BindingType::Texture {
                    multisampled: false,
                    view_dimension: wgpu::TextureViewDimension::D2,
                    sample_type: wgpu::TextureSampleType::Float { filterable: true },
                },
                count: None,
            },
            wgpu::BindGroupLayoutEntry {
                binding: 1,
                visibility: wgpu::ShaderStages::FRAGMENT,
                ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                count: None,
            },
            wgpu::BindGroupLayoutEntry {
                binding: 2,
                visibility: wgpu::ShaderStages::FRAGMENT,
                ty: wgpu::BindingType::Buffer {
                    ty: wgpu::BufferBindingType::Uniform,
                    has_dynamic_offset: false,
                    min_binding_size: None,
                },
                count: None,
            },
        ],
    });
    let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        label: Some("offline_image_shader_bind_group"),
        layout: &bind_group_layout,
        entries: &[
            wgpu::BindGroupEntry {
                binding: 0,
                resource: wgpu::BindingResource::TextureView(&source_view),
            },
            wgpu::BindGroupEntry {
                binding: 1,
                resource: wgpu::BindingResource::Sampler(&sampler),
            },
            wgpu::BindGroupEntry {
                binding: 2,
                resource: params_buf.as_entire_binding(),
            },
        ],
    });

    let shader_source = format!(
        "{}\n{}",
        OFFLINE_IMAGE_VERTEX,
        shader.fullscreen_postfx_source()
    );
    let shader_module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("offline_image_shader_module"),
        source: wgpu::ShaderSource::Wgsl(shader_source.into()),
    });
    let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("offline_image_shader_pipeline_layout"),
        bind_group_layouts: &[&bind_group_layout],
        push_constant_ranges: &[],
    });
    let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("offline_image_shader_pipeline"),
        layout: Some(&pipeline_layout),
        vertex: wgpu::VertexState {
            module: &shader_module,
            entry_point: "vs_main",
            buffers: &[],
            compilation_options: Default::default(),
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader_module,
            entry_point: "fs_main",
            targets: &[Some(wgpu::ColorTargetState {
                format: wgpu::TextureFormat::Rgba8Unorm,
                blend: Some(wgpu::BlendState::REPLACE),
                write_mask: wgpu::ColorWrites::ALL,
            })],
            compilation_options: Default::default(),
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

    let row_stride = padded_bytes_per_row(width);
    let readback = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("offline_image_shader_readback"),
        size: row_stride as u64 * height as u64,
        usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
        mapped_at_creation: false,
    });
    let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
        label: Some("offline_image_shader_encoder"),
    });
    {
        let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
            label: Some("offline_image_shader_render_pass"),
            color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                view: &output_view,
                resolve_target: None,
                ops: wgpu::Operations {
                    load: wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT),
                    store: wgpu::StoreOp::Store,
                },
            })],
            depth_stencil_attachment: None,
            timestamp_writes: None,
            occlusion_query_set: None,
        });
        pass.set_pipeline(&pipeline);
        pass.set_bind_group(0, &bind_group, &[]);
        pass.draw(0..3, 0..1);
    }
    encoder.copy_texture_to_buffer(
        wgpu::ImageCopyTexture {
            texture: &output_texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        wgpu::ImageCopyBuffer {
            buffer: &readback,
            layout: wgpu::ImageDataLayout {
                offset: 0,
                bytes_per_row: Some(row_stride),
                rows_per_image: Some(height),
            },
        },
        size,
    );
    queue.submit(Some(encoder.finish()));

    let slice = readback.slice(..);
    let (sender, receiver) = mpsc::channel();
    slice.map_async(wgpu::MapMode::Read, move |result| {
        let _ = sender.send(result.map_err(|error| error.to_string()));
    });
    let deadline = Instant::now() + OFFLINE_READBACK_TIMEOUT;
    loop {
        let _ = device.poll(wgpu::Maintain::Poll);
        match receiver.try_recv() {
            Ok(result) => {
                result.map_err(|error| format!("offline image shader readback map failed: {error}"))?;
                break;
            }
            Err(TryRecvError::Disconnected) => {
                return Err("offline image shader readback channel disconnected".to_string());
            }
            Err(TryRecvError::Empty) if Instant::now() >= deadline => {
                return Err("offline image shader readback timed out after 5 seconds".to_string());
            }
            Err(TryRecvError::Empty) => std::thread::sleep(Duration::from_millis(1)),
        }
    }

    let mut pixels = vec![0_u8; (width * height * 4) as usize];
    {
        let mapped = slice.get_mapped_range();
        let compact_row_len = (width * 4) as usize;
        for row in 0..height as usize {
            let src = row * row_stride as usize;
            let dst = row * compact_row_len;
            pixels[dst..dst + compact_row_len].copy_from_slice(&mapped[src..src + compact_row_len]);
        }
    }
    readback.unmap();
    ImageData::from_bytes(width, height, pixels)
}
