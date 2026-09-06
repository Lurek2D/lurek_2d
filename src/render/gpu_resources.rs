//! Owns the gpu resources owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu resources data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu resources behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.
//! Use this file when changing gpu resources defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping gpu resources calculations explicit at their owner boundary.

use crate::render::gpu_state::{DepthStencilTarget, GpuTexture};
use crate::render::shader::Shader;
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ShaderKey, ShapeKey, StaticGeometryKey, TextureKey,
};

use crate::render::gpu_tess::parse_filter_mode;
use crate::render::gpu_types::{ColorVertex, ParticleVertex, TexVertex};
use crate::render::renderer::TextureData;
use slotmap::{Key, KeyData, SlotMap};
use std::hash::{Hash, Hasher};

use super::GpuRenderer;

/// Trusted process-wide ceilings for renderer-owned persistent texture resources.
const MAX_LIVE_TEXTURES: usize = 4_096;
const MAX_LIVE_CANVASES: usize = 256;
const MAX_LIVE_CANVAS_BYTES: u64 = 512 * 1024 * 1024;
const MAX_LIVE_TEXTURE_BYTES: u64 = 512 * 1024 * 1024;
const MAX_LIVE_STATIC_MESHES: usize = 4_096;
const MAX_LIVE_STATIC_MESH_BYTES: u64 = 512 * 1024 * 1024;
const MAX_LIVE_FONT_ATLASES: usize = 256;
const MAX_LIVE_FONT_ATLAS_BYTES: u64 = 256 * 1024 * 1024;
/// High-bit namespace separating retained-shape static keys from mesh slot keys.
const SHAPE_STATIC_KEY_NAMESPACE: u64 = 1u64 << 63;

/// Derive a process-stable static key from compiled geometry contents.
///
/// The previous implementation encoded the slotmap handle directly, which
/// forced two identical built-in shapes to allocate duplicate GPU buffers.  A
/// content key lets every handle share the same VBO/IBO while the per-handle
/// revision map still tracks invalidation and stale releases.
pub(crate) fn shape_geometry_static_key(
    compiled: &crate::render::shape::CompiledShape,
) -> StaticGeometryKey {
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    compiled.tolerance.to_bits().hash(&mut hasher);
    compiled.vertices.len().hash(&mut hasher);
    for vertex in &compiled.vertices {
        vertex.position[0].to_bits().hash(&mut hasher);
        vertex.position[1].to_bits().hash(&mut hasher);
        for channel in vertex.color {
            channel.to_bits().hash(&mut hasher);
        }
    }
    compiled.indices.len().hash(&mut hasher);
    compiled.indices.hash(&mut hasher);
    let hash = hasher.finish() | SHAPE_STATIC_KEY_NAMESPACE;
    StaticGeometryKey::from(KeyData::from_ffi(hash))
}

fn is_shape_static_geometry_key(key: StaticGeometryKey) -> bool {
    key.data().as_ffi() & SHAPE_STATIC_KEY_NAMESPACE != 0
}

/// Validate an RGBA8 texture upload before touching the GPU backend.
pub fn validate_rgba_texture_upload(
    width: u32,
    height: u32,
    pixel_len: usize,
    limits: &wgpu::Limits,
) -> Result<(), String> {
    if width == 0 || height == 0 {
        return Err("texture dimensions must be non-zero".to_string());
    }
    if width > limits.max_texture_dimension_2d || height > limits.max_texture_dimension_2d {
        return Err(format!(
            "texture dimensions {width}x{height} exceed device limit {}",
            limits.max_texture_dimension_2d
        ));
    }
    let expected_len = u64::from(width)
        .checked_mul(u64::from(height))
        .and_then(|pixels| pixels.checked_mul(4))
        .ok_or_else(|| format!("texture dimensions {width}x{height} overflow byte length"))?;
    if expected_len > usize::MAX as u64 {
        return Err(format!(
            "texture dimensions {width}x{height} exceed addressable memory"
        ));
    }
    if pixel_len != expected_len as usize {
        return Err(format!(
            "texture pixel buffer has {pixel_len} bytes, expected {expected_len}"
        ));
    }
    Ok(())
}

/// Validate a render-target canvas size before allocating its GPU backing texture.
pub fn validate_canvas_size(width: u32, height: u32, limits: &wgpu::Limits) -> Result<(), String> {
    if width == 0 || height == 0 {
        return Err("canvas dimensions must be non-zero".to_string());
    }
    if width > limits.max_texture_dimension_2d || height > limits.max_texture_dimension_2d {
        return Err(format!(
            "canvas dimensions {width}x{height} exceed device limit {}",
            limits.max_texture_dimension_2d
        ));
    }
    Ok(())
}

/// Validate dynamic geometry buffer byte sizes before a capacity growth can allocate.
pub fn validate_dynamic_buffer_bytes(
    counts_and_strides: &[(usize, usize)],
    limits: &wgpu::Limits,
) -> Result<(), String> {
    for (count, stride) in counts_and_strides {
        let bytes = u64::try_from(*count)
            .map_err(|_| "geometry item count exceeds u64".to_string())?
            .checked_mul(
                u64::try_from(*stride).map_err(|_| "vertex stride exceeds u64".to_string())?,
            )
            .ok_or_else(|| "geometry buffer byte count overflow".to_string())?;
        if bytes > limits.max_buffer_size {
            return Err(format!(
                "geometry buffer needs {bytes} bytes, device maximum is {}",
                limits.max_buffer_size
            ));
        }
    }
    Ok(())
}

/// Return whether an existing GPU canvas texture is absent or no longer matches logical dimensions.
pub fn canvas_texture_needs_recreate(
    existing_size: Option<(u32, u32)>,
    width: u32,
    height: u32,
) -> bool {
    existing_size
        .map(|(existing_width, existing_height)| {
            existing_width != width || existing_height != height
        })
        .unwrap_or(true)
}

/// Return true when a GPU texture is missing or stale for the CPU texture source.
pub fn texture_needs_upload(existing: Option<(u32, u32, u64)>, source: &TextureData) -> bool {
    existing
        .map(|(existing_width, existing_height, existing_revision)| {
            existing_width != source.width
                || existing_height != source.height
                || existing_revision != source.revision
        })
        .unwrap_or(true)
}

/// Return true for static geometry owned by the renderer rather than a user mesh slot.
pub fn is_builtin_static_geometry_key(key: StaticGeometryKey) -> bool {
    key == StaticGeometryKey::default()
}

impl GpuRenderer {
    /// Ensure the multisampled screen color attachment matches the swapchain dimensions.
    pub(crate) fn ensure_screen_msaa_target(&mut self) {
        if self.sample_count <= 1 {
            self.screen_msaa_target = None;
            return;
        }
        let needs_recreate = self
            .screen_msaa_target
            .as_ref()
            .map(|target| target.width != self.width || target.height != self.height)
            .unwrap_or(true);
        if !needs_recreate {
            return;
        }
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("screen_msaa_color_target"),
            size: wgpu::Extent3d {
                width: self.width,
                height: self.height,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: self.sample_count,
            dimension: wgpu::TextureDimension::D2,
            format: self.surface_format,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        });
        let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        self.screen_msaa_target = Some(crate::render::gpu_state::MsaaColorTarget {
            _texture: texture,
            view,
            width: self.width,
            height: self.height,
        });
    }

    /// Validate a canvas replacement before allocating its color attachment.  The old
    /// allocation remains counted until the new attachment is fully constructed.
    fn validate_canvas_resource_budget(
        &self,
        replacing: Option<CanvasKey>,
        width: u32,
        height: u32,
    ) -> Result<(), String> {
        let requested = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|pixels| pixels.checked_mul(4))
            .ok_or_else(|| "canvas resource byte count overflow".to_string())?;
        let mut count = 0usize;
        let mut bytes = 0u64;
        for (key, canvas) in self.canvas_gpu_textures.iter() {
            if Some(key) == replacing {
                continue;
            }
            count = count
                .checked_add(1)
                .ok_or_else(|| "canvas count overflow".to_string())?;
            let size = u64::from(canvas.width)
                .checked_mul(u64::from(canvas.height))
                .and_then(|pixels| pixels.checked_mul(4))
                .ok_or_else(|| "tracked canvas resource byte count overflow".to_string())?;
            bytes = bytes
                .checked_add(size)
                .ok_or_else(|| "tracked canvas resource total overflow".to_string())?;
        }
        if count >= MAX_LIVE_CANVASES {
            return Err(format!(
                "live canvas count exceeds maximum of {MAX_LIVE_CANVASES}"
            ));
        }
        if bytes
            .checked_add(requested)
            .is_none_or(|total| total > MAX_LIVE_CANVAS_BYTES)
        {
            return Err(format!(
                "live canvas bytes exceed maximum of {MAX_LIVE_CANVAS_BYTES}"
            ));
        }
        Ok(())
    }

    /// Validate a static mesh replacement against the retained GPU mesh byte ceiling.
    fn validate_static_mesh_resource_budget(
        &self,
        replacing: StaticGeometryKey,
        requested: u64,
    ) -> Result<(), crate::render::mesh::MeshError> {
        let mut bytes = 0u64;
        for (key, entry) in &self.mesh_cache.static_geometry {
            if *key != replacing {
                bytes = bytes.checked_add(entry.byte_size).ok_or(
                    crate::render::mesh::MeshError::TooLarge {
                        field: "live GPU mesh bytes",
                        count: usize::MAX,
                        max: MAX_LIVE_STATIC_MESH_BYTES as usize,
                    },
                )?;
            }
        }
        if bytes
            .checked_add(requested)
            .is_none_or(|total| total > MAX_LIVE_STATIC_MESH_BYTES)
        {
            return Err(crate::render::mesh::MeshError::TooLarge {
                field: "live GPU mesh bytes",
                count: usize::MAX,
                max: MAX_LIVE_STATIC_MESH_BYTES as usize,
            });
        }
        Ok(())
    }

    /// Calculate both static mesh buffers with checked arithmetic before any GPU object is created.
    fn static_mesh_byte_size(
        vertex_len: usize,
        vertex_stride: usize,
        index_len: usize,
    ) -> Result<u64, crate::render::mesh::MeshError> {
        let vertex_bytes = u64::try_from(vertex_len)
            .ok()
            .and_then(|count| count.checked_mul(u64::try_from(vertex_stride).ok()?));
        let index_bytes = u64::try_from(index_len)
            .ok()
            .and_then(|count| count.checked_mul(u64::try_from(std::mem::size_of::<u32>()).ok()?));
        vertex_bytes
            .zip(index_bytes)
            .and_then(|(vertices, indices)| vertices.checked_add(indices))
            .ok_or(crate::render::mesh::MeshError::TooLarge {
                field: "GPU mesh bytes",
                count: vertex_len.saturating_add(index_len),
                max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
            })
    }
    /// Verify that a replacement or insertion stays within retained texture limits.
    fn validate_texture_resource_budget(
        &self,
        replacing: Option<TextureKey>,
        width: u32,
        height: u32,
    ) -> Result<(), String> {
        let requested = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|pixels| pixels.checked_mul(4))
            .ok_or_else(|| "texture resource byte count overflow".to_string())?;
        let mut count = 0usize;
        let mut bytes = 0u64;
        for (key, texture) in self.gpu_textures.iter() {
            if Some(key) == replacing {
                continue;
            }
            count = count.saturating_add(1);
            let size = u64::from(texture.width)
                .checked_mul(u64::from(texture.height))
                .and_then(|pixels| pixels.checked_mul(4))
                .ok_or_else(|| "tracked texture resource byte count overflow".to_string())?;
            bytes = bytes
                .checked_add(size)
                .ok_or_else(|| "tracked texture resource total overflow".to_string())?;
        }
        if count >= MAX_LIVE_TEXTURES {
            return Err(format!(
                "live texture count exceeds maximum of {MAX_LIVE_TEXTURES}"
            ));
        }
        if bytes.saturating_add(requested) > MAX_LIVE_TEXTURE_BYTES {
            return Err(format!(
                "live texture bytes exceed maximum of {MAX_LIVE_TEXTURE_BYTES}"
            ));
        }
        Ok(())
    }

    /// Verify that a font-atlas insertion stays inside the separate persistent atlas budget.
    fn validate_font_atlas_resource_budget(
        &self,
        replacing: Option<FontKey>,
        width: u32,
        height: u32,
    ) -> Result<(), String> {
        let requested = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|pixels| pixels.checked_mul(4))
            .ok_or_else(|| "font atlas byte count overflow".to_string())?;
        let mut count = 0usize;
        let mut bytes = 0u64;
        for (key, texture) in self.font_atlas_textures.iter() {
            if Some(key) == replacing {
                continue;
            }
            count = count.saturating_add(1);
            let size = u64::from(texture.width)
                .checked_mul(u64::from(texture.height))
                .and_then(|pixels| pixels.checked_mul(4))
                .ok_or_else(|| "tracked font atlas byte count overflow".to_string())?;
            bytes = bytes
                .checked_add(size)
                .ok_or_else(|| "tracked font atlas total overflow".to_string())?;
        }
        if count >= MAX_LIVE_FONT_ATLASES {
            return Err(format!(
                "live font atlas count exceeds maximum of {MAX_LIVE_FONT_ATLASES}"
            ));
        }
        if bytes.saturating_add(requested) > MAX_LIVE_FONT_ATLAS_BYTES {
            return Err(format!(
                "live font atlas bytes exceed maximum of {MAX_LIVE_FONT_ATLAS_BYTES}"
            ));
        }
        Ok(())
    }

    /// Returns a bounded next capacity and never silently overflows device limits.
    pub(crate) fn grow_capacity(current: u64, needed: u64, maximum: u64) -> Result<u64, String> {
        if needed > maximum {
            return Err(format!(
                "buffer needs {needed} elements, but its device-aware limit is {maximum}"
            ));
        }
        let mut cap = current.max(1);
        while cap < needed {
            cap = cap.saturating_mul(2).min(maximum);
        }
        Ok(cap.max(needed))
    }

    fn buffer_byte_size(capacity: u64, stride: usize) -> Result<u64, String> {
        capacity
            .checked_mul(u64::try_from(stride).map_err(|_| "buffer stride exceeds u64")?)
            .ok_or_else(|| "geometry buffer byte count overflow".to_string())
    }

    /// Recreates shared geometry buffers when the current capacities are too small.
    pub(crate) fn ensure_geometry_buffer_capacity(
        &mut self,
        color_verts_needed: usize,
        color_idxs_needed: usize,
        tex_verts_needed: usize,
        tex_idxs_needed: usize,
        particle_verts_needed: usize,
        particle_idxs_needed: usize,
    ) -> Result<(), String> {
        let limits = self.device.limits();
        let color_vertex_stride = std::mem::size_of::<ColorVertex>();
        let color_index_stride = std::mem::size_of::<u32>();
        let tex_vertex_stride = std::mem::size_of::<TexVertex>();
        let particle_vertex_stride = std::mem::size_of::<ParticleVertex>();
        let color_vertex_stride_u64 =
            u64::try_from(color_vertex_stride).map_err(|_| "color vertex stride exceeds u64")?;
        let color_index_stride_u64 =
            u64::try_from(color_index_stride).map_err(|_| "color index stride exceeds u64")?;
        let tex_vertex_stride_u64 =
            u64::try_from(tex_vertex_stride).map_err(|_| "texture vertex stride exceeds u64")?;
        let particle_vertex_stride_u64 = u64::try_from(particle_vertex_stride)
            .map_err(|_| "particle vertex stride exceeds u64")?;
        let color_v_needed =
            u64::try_from(color_verts_needed).map_err(|_| "color vertex count exceeds u64")?;
        if color_v_needed > self.color_vertex_capacity {
            let new_cap = Self::grow_capacity(
                self.color_vertex_capacity,
                color_v_needed,
                limits.max_buffer_size / color_vertex_stride_u64,
            )?;
            self.color_vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("color_vbo"),
                size: Self::buffer_byte_size(new_cap, color_vertex_stride)?,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.color_vertex_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        let color_i_needed =
            u64::try_from(color_idxs_needed).map_err(|_| "color index count exceeds u64")?;
        if color_i_needed > self.color_index_capacity {
            let new_cap = Self::grow_capacity(
                self.color_index_capacity,
                color_i_needed,
                limits.max_buffer_size / color_index_stride_u64,
            )?;
            self.color_index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("color_ibo"),
                size: Self::buffer_byte_size(new_cap, color_index_stride)?,
                usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.color_index_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        let tex_v_needed =
            u64::try_from(tex_verts_needed).map_err(|_| "texture vertex count exceeds u64")?;
        if tex_v_needed > self.tex_vertex_capacity {
            let new_cap = Self::grow_capacity(
                self.tex_vertex_capacity,
                tex_v_needed,
                limits.max_buffer_size / tex_vertex_stride_u64,
            )?;
            self.tex_vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("tex_vbo"),
                size: Self::buffer_byte_size(new_cap, tex_vertex_stride)?,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.tex_vertex_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
            log::warn!(
                "[G003] grew tex vertex buffer capacity to {} vertices",
                self.tex_vertex_capacity
            );
        }
        let tex_i_needed =
            u64::try_from(tex_idxs_needed).map_err(|_| "texture index count exceeds u64")?;
        if tex_i_needed > self.tex_index_capacity {
            let new_cap = Self::grow_capacity(
                self.tex_index_capacity,
                tex_i_needed,
                limits.max_buffer_size / color_index_stride_u64,
            )?;
            self.tex_index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("tex_ibo"),
                size: Self::buffer_byte_size(new_cap, color_index_stride)?,
                usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.tex_index_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
            log::warn!(
                "[G003] grew tex index buffer capacity to {} indices",
                self.tex_index_capacity
            );
        }
        let particle_v_needed = u64::try_from(particle_verts_needed)
            .map_err(|_| "particle vertex count exceeds u64")?;
        if particle_v_needed > self.particle_vertex_capacity {
            let new_cap = Self::grow_capacity(
                self.particle_vertex_capacity,
                particle_v_needed,
                limits.max_buffer_size / particle_vertex_stride_u64,
            )?;
            self.particle_vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("particle_vbo"),
                size: Self::buffer_byte_size(new_cap, particle_vertex_stride)?,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.particle_vertex_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        let particle_i_needed =
            u64::try_from(particle_idxs_needed).map_err(|_| "particle index count exceeds u64")?;
        if particle_i_needed > self.particle_index_capacity {
            let new_cap = Self::grow_capacity(
                self.particle_index_capacity,
                particle_i_needed,
                limits.max_buffer_size / color_index_stride_u64,
            )?;
            self.particle_index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("particle_ibo"),
                size: Self::buffer_byte_size(new_cap, color_index_stride)?,
                usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.particle_index_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        Ok(())
    }

    /// Recreates the instance buffer when the current capacity cannot hold `needed` instances.
    pub(crate) fn ensure_instance_buffer_capacity(&mut self, needed: usize) -> Result<(), String> {
        let needed_inst = u64::try_from(needed).map_err(|_| "instance count exceeds u64")?;
        if needed_inst > self.instance_capacity {
            let stride = std::mem::size_of::<crate::render::gpu_types::InstanceData>();
            let stride_u64 = u64::try_from(stride).map_err(|_| "instance stride exceeds u64")?;
            let new_cap = Self::grow_capacity(
                self.instance_capacity,
                needed_inst,
                self.device.limits().max_buffer_size / stride_u64,
            )?;
            self.instance_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("instance_vbo"),
                size: Self::buffer_byte_size(new_cap, stride)?,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.instance_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        Ok(())
    }

    /// Creates a sampler from the renderer's default min/mag filter and anisotropy tuple.
    pub(crate) fn create_sampler(&self, default_filter: &(String, String, u32)) -> wgpu::Sampler {
        let min_filter = parse_filter_mode(&default_filter.0);
        let mag_filter = parse_filter_mode(&default_filter.1);
        let anisotropy =
            if min_filter == wgpu::FilterMode::Linear && mag_filter == wgpu::FilterMode::Linear {
                default_filter.2.clamp(1, u16::MAX as u32) as u16
            } else {
                1
            };
        self.device.create_sampler(&wgpu::SamplerDescriptor {
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            mag_filter,
            min_filter,
            mipmap_filter: min_filter,
            anisotropy_clamp: anisotropy,
            ..Default::default()
        })
    }

    /// Creates a texture bind group using the renderer's standard texture layout.
    pub(crate) fn create_texture_bind_group(
        &self,
        view: &wgpu::TextureView,
        sampler: &wgpu::Sampler,
        label: &'static str,
    ) -> wgpu::BindGroup {
        self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some(label),
            layout: &self.texture_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(sampler),
                },
            ],
        })
    }

    /// Uploads raw RGBA pixels into a GPU texture and builds its view, sampler, and bind group.
    pub(crate) fn create_gpu_texture_raw(
        &self,
        pixels: &[u8],
        width: u32,
        height: u32,
        color_space: crate::image::TextureColorSpace,
        source_revision: u64,
        default_filter: &(String, String, u32),
    ) -> Result<GpuTexture, String> {
        validate_rgba_texture_upload(width, height, pixels.len(), &self.device.limits())?;
        let size = wgpu::Extent3d {
            width,
            height,
            depth_or_array_layers: 1,
        };
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("sprite_texture"),
            size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: match color_space {
                crate::image::TextureColorSpace::Srgb => wgpu::TextureFormat::Rgba8UnormSrgb,
                crate::image::TextureColorSpace::Linear => wgpu::TextureFormat::Rgba8Unorm,
            },
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        self.queue.write_texture(
            wgpu::ImageCopyTexture {
                texture: &texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            pixels,
            wgpu::ImageDataLayout {
                offset: 0,
                bytes_per_row: Some(4 * width),
                rows_per_image: Some(height),
            },
            size,
        );
        let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        let sampler = self.create_sampler(default_filter);
        let bind_group = self.create_texture_bind_group(&view, &sampler, "sprite_bg");
        Ok(GpuTexture {
            _texture: texture,
            view,
            bind_group,
            width,
            height,
            source_revision,
            _render_texture: None,
            render_view: None,
        })
    }

    /// Uploads pixel data to a new GPU texture associated with the given key.
    pub fn upload_texture(
        &mut self,
        key: TextureKey,
        source: &TextureData,
        default_filter: &(String, String, u32),
    ) -> Result<(), String> {
        self.validate_texture_resource_budget(
            // Build before publishing so a failed upload leaves the old texture intact;
            // account for that old allocation during the transient replacement.
            None,
            source.width,
            source.height,
        )?;
        let gt = self.create_gpu_texture_raw(
            &source.pixels,
            source.width,
            source.height,
            source.color_space,
            source.revision,
            default_filter,
        )?;
        self.gpu_textures.insert(key, gt);
        Ok(())
    }

    /// Ensures the font atlas texture exists and is synchronized with dirty font atlas data.
    pub(crate) fn ensure_font_atlas(
        &mut self,
        font_key: FontKey,
        font: &mut crate::font::Font,
        default_filter: &(String, String, u32),
    ) -> bool {
        let (data, w, h) = font.atlas_data();
        if font.is_dirty() || !self.font_atlas_textures.contains_key(font_key) {
            if self
                .validate_font_atlas_resource_budget(
                    // The old atlas remains alive until the new upload succeeds, so account
                    // for both during publication rather than allowing a transient overage.
                    None, w, h,
                )
                .is_err()
            {
                return false;
            }
            let Ok(gt) = self.create_gpu_texture_raw(
                data,
                w,
                h,
                crate::image::TextureColorSpace::Srgb,
                0,
                default_filter,
            ) else {
                return false;
            };
            self.font_atlas_textures.insert(font_key, gt);
            font.mark_clean();
        }
        self.font_atlas_textures.contains_key(font_key)
    }

    /// Allocates an off-screen render target texture associated with the given canvas key.
    pub fn create_canvas(
        &mut self,
        key: CanvasKey,
        width: u32,
        height: u32,
        default_filter: &(String, String, u32),
    ) -> Result<(), String> {
        validate_canvas_size(width, height, &self.device.limits())?;
        // Treat a resize/recreation as a replacement so the old attachment does
        // not consume a second slot while the new MSAA/resolve pair is built.
        self.validate_canvas_resource_budget(Some(key), width, height)?;
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("canvas_texture"),
            size: wgpu::Extent3d {
                width,
                height,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: self.surface_format,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
            view_formats: &[],
        });
        let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        let (render_texture, render_view) = if self.sample_count > 1 {
            let render_texture = self.device.create_texture(&wgpu::TextureDescriptor {
                label: Some("canvas_msaa_texture"),
                size: wgpu::Extent3d {
                    width,
                    height,
                    depth_or_array_layers: 1,
                },
                mip_level_count: 1,
                sample_count: self.sample_count,
                dimension: wgpu::TextureDimension::D2,
                format: self.surface_format,
                usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
                view_formats: &[],
            });
            let render_view = render_texture.create_view(&wgpu::TextureViewDescriptor::default());
            (Some(render_texture), Some(render_view))
        } else {
            (None, None)
        };
        let sampler = self.create_sampler(default_filter);
        let bind_group = self.create_texture_bind_group(&view, &sampler, "canvas_bg");
        self.canvas_stencil_targets.remove(key);
        self.canvas_gpu_textures.insert(
            key,
            GpuTexture {
                _texture: texture,
                view,
                bind_group,
                width,
                height,
                source_revision: 0,
                _render_texture: render_texture,
                render_view,
            },
        );
        self.canvas_needs_clear.insert(key, true);
        Ok(())
    }

    /// Creates a depth-stencil render target matching the provided dimensions.
    pub(crate) fn create_depth_stencil_target(
        &self,
        width: u32,
        height: u32,
        label: &'static str,
    ) -> DepthStencilTarget {
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some(label),
            size: wgpu::Extent3d {
                width,
                height,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: self.sample_count,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Depth24PlusStencil8,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        });
        let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        DepthStencilTarget {
            _texture: texture,
            view,
            width,
            height,
        }
    }

    /// Ensures the screen-sized stencil target exists and matches the current surface size.
    pub(crate) fn ensure_screen_stencil_target(&mut self) {
        let needs_recreate = self
            .screen_stencil_target
            .as_ref()
            .map(|target| target.width != self.width || target.height != self.height)
            .unwrap_or(true);
        if needs_recreate {
            self.screen_stencil_target = Some(self.create_depth_stencil_target(
                self.width,
                self.height,
                "screen_stencil_target",
            ));
        }
    }

    /// Ensures a canvas-specific stencil target exists and matches the canvas size.
    pub(crate) fn ensure_canvas_stencil_target(&mut self, key: CanvasKey, width: u32, height: u32) {
        let needs_recreate = self
            .canvas_stencil_targets
            .get(key)
            .map(|target| target.width != width || target.height != height)
            .unwrap_or(true);
        if needs_recreate {
            self.canvas_stencil_targets.insert(
                key,
                self.create_depth_stencil_target(width, height, "canvas_stencil_target"),
            );
        }
    }

    /// Drops GPU-side resources whose CPU-side slotmap entries no longer exist.
    pub(crate) fn prune_released_resources(
        &mut self,
        textures: &SlotMap<TextureKey, TextureData>,
        fonts: &SlotMap<FontKey, crate::font::Font>,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        meshes: &SlotMap<MeshKey, crate::render::Mesh>,
        shapes: &SlotMap<ShapeKey, crate::render::CompoundShape>,
    ) {
        let stale_textures: Vec<TextureKey> = self
            .gpu_textures
            .iter()
            .map(|(key, _)| key)
            .filter(|key| !textures.contains_key(*key))
            .collect();
        for key in stale_textures {
            self.gpu_textures.remove(key);
        }
        let stale_fonts: Vec<FontKey> = self
            .font_atlas_textures
            .iter()
            .map(|(key, _)| key)
            .filter(|key| !fonts.contains_key(*key))
            .collect();
        for key in stale_fonts {
            self.font_atlas_textures.remove(key);
        }
        let stale_canvases: Vec<CanvasKey> = self
            .canvas_gpu_textures
            .iter()
            .map(|(key, _)| key)
            .filter(|key| !canvases.contains_key(*key))
            .collect();
        for key in stale_canvases {
            self.canvas_gpu_textures.remove(key);
            self.canvas_stencil_targets.remove(key);
            self.canvas_needs_clear.remove(key);
        }
        let stale_shaders: Vec<ShaderKey> = self
            .shader_cache
            .iter()
            .map(|(key, _)| key)
            .filter(|key| !shaders.contains_key(*key))
            .collect();
        for key in stale_shaders {
            self.shader_cache.remove(key);
        }
        let stale_negative_shaders: Vec<ShaderKey> = self
            .shader_negative_cache
            .iter()
            .map(|(key, _)| key)
            .filter(|key| !shaders.contains_key(*key))
            .collect();
        for key in stale_negative_shaders {
            self.shader_negative_cache.remove(key);
        }
        // Shape handles are generational and may be released while their
        // content-keyed GPU entry is still shared by another handle.  Drop the
        // handle mappings first, then remove only unreferenced static buffers.
        let stale_shape_handles: Vec<ShapeKey> = self
            .mesh_cache
            .shape_geometry_keys
            .keys()
            .copied()
            .filter(|key| !shapes.contains_key(*key))
            .collect();
        for key in stale_shape_handles {
            self.mesh_cache.shape_geometry_keys.remove(&key);
            self.mesh_cache.shape_revisions.remove(&key);
        }
        let referenced_shape_geometry: std::collections::HashSet<StaticGeometryKey> = self
            .mesh_cache
            .shape_geometry_keys
            .values()
            .copied()
            .collect();
        let stale_meshes: Vec<StaticGeometryKey> = self
            .mesh_cache
            .static_geometry
            .keys()
            .cloned()
            .filter(|key| {
                if is_shape_static_geometry_key(*key) {
                    return referenced_shape_geometry.contains(key);
                }
                if is_builtin_static_geometry_key(*key) {
                    return false;
                }
                let mesh_key = MeshKey::from(key.data());
                !meshes.contains_key(mesh_key)
            })
            .collect();
        for key in stale_meshes {
            self.mesh_cache.static_geometry.remove(&key);
        }
    }

    /// Synchronizes one mesh into cached static GPU geometry buffers.
    pub(crate) fn sync_mesh(
        &mut self,
        mesh_key: MeshKey,
        mesh: &crate::render::Mesh,
    ) -> Result<(), crate::render::mesh::MeshError> {
        use wgpu::util::DeviceExt;

        let static_key = StaticGeometryKey::from(mesh_key.data());
        if !self.mesh_cache.static_geometry.contains_key(&static_key)
            && self.mesh_cache.static_geometry.len() >= MAX_LIVE_STATIC_MESHES
        {
            return Err(crate::render::mesh::MeshError::TooLarge {
                field: "live GPU meshes",
                count: self.mesh_cache.static_geometry.len().saturating_add(1),
                max: MAX_LIVE_STATIC_MESHES,
            });
        }
        let tri_indices = match mesh.try_triangulate() {
            Ok(indices) => indices,
            Err(err) => {
                self.mesh_cache.static_geometry.remove(&static_key);
                return Err(err);
            }
        };

        let entry = if mesh.texture.is_some() {
            let mut verts = Vec::new();
            let mut idxs = Vec::new();
            verts.try_reserve_exact(tri_indices.len()).map_err(|_| {
                crate::render::mesh::MeshError::TooLarge {
                    field: "GPU vertex allocation",
                    count: tri_indices.len(),
                    max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                }
            })?;
            idxs.try_reserve_exact(tri_indices.len()).map_err(|_| {
                crate::render::mesh::MeshError::TooLarge {
                    field: "GPU index allocation",
                    count: tri_indices.len(),
                    max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                }
            })?;
            for (i, &vi) in tri_indices.iter().enumerate() {
                if let Some(mv) = mesh.vertices.get(vi) {
                    verts.push(TexVertex {
                        position: [mv.x, mv.y],
                        uv: [mv.u, mv.v],
                        color: [mv.r, mv.g, mv.b, mv.a],
                        w_depth: 1.0,
                        _pad: [0.0; 3],
                    });
                    idxs.push(u32::try_from(i).map_err(|_| {
                        crate::render::mesh::MeshError::TooLarge {
                            field: "GPU indices",
                            count: i,
                            max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                        }
                    })?);
                }
            }
            validate_dynamic_buffer_bytes(
                &[
                    (verts.len(), std::mem::size_of::<TexVertex>()),
                    (idxs.len(), std::mem::size_of::<u32>()),
                ],
                &self.device.limits(),
            )
            .map_err(|_| crate::render::mesh::MeshError::TooLarge {
                field: "GPU buffer bytes",
                count: tri_indices.len(),
                max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
            })?;
            let byte_size = Self::static_mesh_byte_size(
                verts.len(),
                std::mem::size_of::<TexVertex>(),
                idxs.len(),
            )?;
            self.validate_static_mesh_resource_budget(static_key, byte_size)?;

            let v_buf = self
                .device
                .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                    label: Some("static_mesh_vbo"),
                    contents: bytemuck::cast_slice(&verts),
                    usage: wgpu::BufferUsages::VERTEX,
                });
            let i_buf = self
                .device
                .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                    label: Some("static_mesh_ibo"),
                    contents: bytemuck::cast_slice(&idxs),
                    usage: wgpu::BufferUsages::INDEX,
                });
            crate::render::gpu_state::StaticGeometryCacheEntry {
                vertex_buffer: v_buf,
                index_buffer: i_buf,
                index_count: u32::try_from(idxs.len()).map_err(|_| {
                    crate::render::mesh::MeshError::TooLarge {
                        field: "GPU indices",
                        count: idxs.len(),
                        max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                    }
                })?,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::TextureInstanced,
                texture: mesh.texture,
                byte_size,
            }
        } else {
            let mut verts = Vec::new();
            let mut idxs = Vec::new();
            verts.try_reserve_exact(tri_indices.len()).map_err(|_| {
                crate::render::mesh::MeshError::TooLarge {
                    field: "GPU vertex allocation",
                    count: tri_indices.len(),
                    max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                }
            })?;
            idxs.try_reserve_exact(tri_indices.len()).map_err(|_| {
                crate::render::mesh::MeshError::TooLarge {
                    field: "GPU index allocation",
                    count: tri_indices.len(),
                    max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                }
            })?;
            for (i, &vi) in tri_indices.iter().enumerate() {
                if let Some(mv) = mesh.vertices.get(vi) {
                    verts.push(ColorVertex {
                        position: [mv.x, mv.y],
                        color: [mv.r, mv.g, mv.b, mv.a],
                    });
                    idxs.push(u32::try_from(i).map_err(|_| {
                        crate::render::mesh::MeshError::TooLarge {
                            field: "GPU indices",
                            count: i,
                            max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                        }
                    })?);
                }
            }
            validate_dynamic_buffer_bytes(
                &[
                    (verts.len(), std::mem::size_of::<ColorVertex>()),
                    (idxs.len(), std::mem::size_of::<u32>()),
                ],
                &self.device.limits(),
            )
            .map_err(|_| crate::render::mesh::MeshError::TooLarge {
                field: "GPU buffer bytes",
                count: tri_indices.len(),
                max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
            })?;
            let byte_size = Self::static_mesh_byte_size(
                verts.len(),
                std::mem::size_of::<ColorVertex>(),
                idxs.len(),
            )?;
            self.validate_static_mesh_resource_budget(static_key, byte_size)?;

            let v_buf = self
                .device
                .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                    label: Some("static_mesh_vbo"),
                    contents: bytemuck::cast_slice(&verts),
                    usage: wgpu::BufferUsages::VERTEX,
                });
            let i_buf = self
                .device
                .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                    label: Some("static_mesh_ibo"),
                    contents: bytemuck::cast_slice(&idxs),
                    usage: wgpu::BufferUsages::INDEX,
                });
            crate::render::gpu_state::StaticGeometryCacheEntry {
                vertex_buffer: v_buf,
                index_buffer: i_buf,
                index_count: u32::try_from(idxs.len()).map_err(|_| {
                    crate::render::mesh::MeshError::TooLarge {
                        field: "GPU indices",
                        count: idxs.len(),
                        max: crate::render::mesh::MAX_MESH_TRIANGULATED_INDICES,
                    }
                })?,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::ColorInstanced,
                texture: None,
                byte_size,
            }
        };

        self.mesh_cache.static_geometry.insert(static_key, entry);
        Ok(())
    }

    /// Upload one compiled retained shape into the shared static geometry cache.
    ///
    /// Shape keys use a separate high-bit namespace so mesh and shape handles can
    /// coexist in the existing `PreparedDraw::static_geometry` slot without changing
    /// the render-pass encoder.  Re-upload is skipped when the CPU revision is already
    /// resident, which is the core retained-geometry performance guarantee.
    pub(crate) fn sync_shape_geometry(
        &mut self,
        shape_key: ShapeKey,
        compiled: &crate::render::shape::CompiledShape,
    ) -> Result<(), String> {
        let old_static_key = self.mesh_cache.shape_geometry_keys.get(&shape_key).copied();
        if compiled.indices.is_empty() {
            // Empty retained shapes are valid authoring assets, but wgpu does not
            // accept zero-byte vertex/index buffers. Leave them uncached so draw
            // simply becomes a no-op until geometry is added.
            self.mesh_cache.shape_geometry_keys.remove(&shape_key);
            self.mesh_cache.shape_revisions.remove(&shape_key);
            if let Some(old_key) = old_static_key {
                let still_referenced = self
                    .mesh_cache
                    .shape_geometry_keys
                    .values()
                    .any(|key| *key == old_key);
                if !still_referenced {
                    self.mesh_cache.static_geometry.remove(&old_key);
                }
            }
            return Ok(());
        }
        let static_key = shape_geometry_static_key(compiled);
        if self.mesh_cache.shape_revisions.get(&shape_key).copied() == Some(compiled.revision)
            && self.mesh_cache.shape_geometry_keys.get(&shape_key) == Some(&static_key)
            && self.mesh_cache.static_geometry.contains_key(&static_key)
        {
            return Ok(());
        }
        if compiled.vertices.len() > crate::render::shape::MAX_SHAPE_VERTICES {
            return Err(format!(
                "shape vertices exceed maximum of {}",
                crate::render::shape::MAX_SHAPE_VERTICES
            ));
        }
        if compiled.indices.len() > crate::render::shape::MAX_SHAPE_INDICES
            || !compiled.indices.len().is_multiple_of(3)
        {
            return Err(format!(
                "shape indices must be a triangle list below {}",
                crate::render::shape::MAX_SHAPE_INDICES
            ));
        }
        for (index, vertex) in compiled.vertices.iter().enumerate() {
            if vertex
                .position
                .iter()
                .chain(vertex.color.iter())
                .any(|value| !value.is_finite())
            {
                return Err(format!("shape vertex {index} contains a non-finite value"));
            }
        }
        for (index, &value) in compiled.indices.iter().enumerate() {
            if value as usize >= compiled.vertices.len() {
                return Err(format!(
                    "shape index {index} references vertex {value}, but the mesh has {} vertices",
                    compiled.vertices.len()
                ));
            }
        }
        // A compiled mesh can be shared by several handles (for example, by
        // built-in shapes with the same palette and tolerance).  Publish only
        // the handle-to-content mapping in that case; creating temporary GPU
        // buffers on every handle would defeat the retained upload guarantee.
        if self.mesh_cache.static_geometry.contains_key(&static_key) {
            if let Some(old_key) = old_static_key.filter(|old_key| *old_key != static_key) {
                let still_referenced = self
                    .mesh_cache
                    .shape_geometry_keys
                    .iter()
                    .any(|(key, geometry_key)| *key != shape_key && *geometry_key == old_key);
                if !still_referenced {
                    self.mesh_cache.static_geometry.remove(&old_key);
                }
            }
            self.mesh_cache
                .shape_geometry_keys
                .insert(shape_key, static_key);
            self.mesh_cache
                .shape_revisions
                .insert(shape_key, compiled.revision);
            return Ok(());
        }
        let vertex_bytes = compiled
            .vertices
            .len()
            .checked_mul(std::mem::size_of::<ColorVertex>())
            .ok_or_else(|| "shape vertex byte size overflow".to_string())?;
        let index_bytes = compiled
            .indices
            .len()
            .checked_mul(std::mem::size_of::<u32>())
            .ok_or_else(|| "shape index byte size overflow".to_string())?;
        validate_dynamic_buffer_bytes(
            &[
                (compiled.vertices.len(), std::mem::size_of::<ColorVertex>()),
                (compiled.indices.len(), std::mem::size_of::<u32>()),
            ],
            &self.device.limits(),
        )
        .map_err(|error| error.to_string())?;
        let byte_size = u64::try_from(vertex_bytes)
            .ok()
            .and_then(|vertices| {
                u64::try_from(index_bytes)
                    .ok()
                    .map(|indices| vertices + indices)
            })
            .ok_or_else(|| "shape GPU byte size overflow".to_string())?;
        if !self.mesh_cache.static_geometry.contains_key(&static_key)
            && self.mesh_cache.static_geometry.len() >= MAX_LIVE_STATIC_MESHES
        {
            return Err(format!(
                "live GPU geometry count exceeds maximum of {MAX_LIVE_STATIC_MESHES}"
            ));
        }
        self.validate_static_mesh_resource_budget(static_key, byte_size)
            .map_err(|error| error.to_string())?;
        use wgpu::util::DeviceExt;
        let vertex_buffer = self
            .device
            .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("compiled_shape_vbo"),
                contents: bytemuck::cast_slice(&compiled.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            });
        let index_buffer = self
            .device
            .create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("compiled_shape_ibo"),
                contents: bytemuck::cast_slice(&compiled.indices),
                usage: wgpu::BufferUsages::INDEX,
            });
        let index_count = u32::try_from(compiled.indices.len())
            .map_err(|_| "shape index count exceeds u32".to_string())?;
        if let std::collections::hash_map::Entry::Vacant(entry) =
            self.mesh_cache.static_geometry.entry(static_key)
        {
            entry.insert(crate::render::gpu_state::StaticGeometryCacheEntry {
                vertex_buffer,
                index_buffer,
                index_count,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::ColorInstanced,
                texture: None,
                byte_size,
            });
        }
        if let Some(old_key) = old_static_key.filter(|old_key| *old_key != static_key) {
            let still_referenced = self
                .mesh_cache
                .shape_geometry_keys
                .iter()
                .any(|(key, geometry_key)| *key != shape_key && *geometry_key == old_key);
            if !still_referenced {
                self.mesh_cache.static_geometry.remove(&old_key);
            }
        }
        self.mesh_cache
            .shape_geometry_keys
            .insert(shape_key, static_key);
        self.mesh_cache
            .shape_revisions
            .insert(shape_key, compiled.revision);
        Ok(())
    }
}
