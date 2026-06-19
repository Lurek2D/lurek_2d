//! Owns persistent GPU resource lifetimes, uploads, and resizing for textures, fonts, canvases, and buffers.
//! Grows vertex, index, and instance buffers on demand so render workloads can scale without manual sizing.
//! Caches texture and sampler bind groups so compatible resources reuse stable GPU-side descriptors.
//! Creates raw textures and canvas resources while hiding wgpu allocation details from higher render layers.
//! Prunes stale resources to keep GPU memory usage bounded during long sessions or heavy content churn.
//! Uploads static geometry into dedicated buffers so later frames can reuse cached meshes efficiently.
//! Acts as the resource-allocation boundary rather than the owner of draw ordering or pass sequencing.
//! Open this file when GPU buffers, textures, samplers, or resource cleanup behavior looks incorrect.

use crate::render::gpu_state::{DepthStencilTarget, GpuTexture};
use crate::render::shader::Shader;
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ShaderKey, StaticGeometryKey, TextureKey,
};

use crate::render::gpu_tess::parse_filter_mode;
use crate::render::gpu_types::{ColorVertex, TexVertex};
use crate::render::renderer::TextureData;
use slotmap::{Key, SlotMap};

use super::GpuRenderer;

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
    /// Returns the next power-of-two-style capacity large enough for `needed`.
    pub(crate) fn grow_capacity(current: u64, needed: u64) -> u64 {
        let mut cap = current.max(1);
        while cap < needed {
            cap = cap.saturating_mul(2);
            if cap == u64::MAX {
                break;
            }
        }
        cap.max(needed)
    }

    /// Recreates shared geometry buffers when the current capacities are too small.
    pub(crate) fn ensure_geometry_buffer_capacity(
        &mut self,
        color_verts_needed: usize,
        color_idxs_needed: usize,
        tex_verts_needed: usize,
        tex_idxs_needed: usize,
    ) {
        let color_v_needed = color_verts_needed as u64;
        if color_v_needed > self.color_vertex_capacity {
            let new_cap = Self::grow_capacity(self.color_vertex_capacity, color_v_needed);
            self.color_vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("color_vbo"),
                size: new_cap * std::mem::size_of::<ColorVertex>() as u64,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.color_vertex_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        let color_i_needed = color_idxs_needed as u64;
        if color_i_needed > self.color_index_capacity {
            let new_cap = Self::grow_capacity(self.color_index_capacity, color_i_needed);
            self.color_index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("color_ibo"),
                size: new_cap * std::mem::size_of::<u32>() as u64,
                usage: wgpu::BufferUsages::INDEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.color_index_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
        let tex_v_needed = tex_verts_needed as u64;
        if tex_v_needed > self.tex_vertex_capacity {
            let new_cap = Self::grow_capacity(self.tex_vertex_capacity, tex_v_needed);
            self.tex_vertex_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("tex_vbo"),
                size: new_cap * std::mem::size_of::<TexVertex>() as u64,
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
        let tex_i_needed = tex_idxs_needed as u64;
        if tex_i_needed > self.tex_index_capacity {
            let new_cap = Self::grow_capacity(self.tex_index_capacity, tex_i_needed);
            self.tex_index_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("tex_ibo"),
                size: new_cap * std::mem::size_of::<u32>() as u64,
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
    }

    /// Recreates the instance buffer when the current capacity cannot hold `needed` instances.
    pub(crate) fn ensure_instance_buffer_capacity(&mut self, needed: usize) {
        let needed_inst = needed as u64;
        if needed_inst > self.instance_capacity {
            let new_cap = Self::grow_capacity(self.instance_capacity, needed_inst);
            self.instance_buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
                label: Some("instance_vbo"),
                size: new_cap
                    * std::mem::size_of::<crate::render::gpu_types::InstanceData>() as u64,
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
                mapped_at_creation: false,
            });
            self.instance_capacity = new_cap;
            self.render_diagnostics.record_buffer_growth_event();
        }
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
        })
    }

    /// Uploads pixel data to a new GPU texture associated with the given key.
    pub fn upload_texture(
        &mut self,
        key: TextureKey,
        source: &TextureData,
        default_filter: &(String, String, u32),
    ) -> Result<(), String> {
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
        font: &mut crate::render::Font,
        default_filter: &(String, String, u32),
    ) -> bool {
        let (data, w, h) = font.atlas_data();
        if font.is_dirty() || !self.font_atlas_textures.contains_key(font_key) {
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
            sample_count: 1,
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
        fonts: &SlotMap<FontKey, crate::render::Font>,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        meshes: &SlotMap<MeshKey, crate::render::Mesh>,
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
        let stale_meshes: Vec<StaticGeometryKey> = self
            .mesh_cache
            .static_geometry
            .keys()
            .cloned()
            .filter(|key| {
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
        let tri_indices = match mesh.try_triangulate() {
            Ok(indices) => indices,
            Err(err) => {
                self.mesh_cache.static_geometry.remove(&static_key);
                return Err(err);
            }
        };

        let entry = if mesh.texture.is_some() {
            let mut verts = Vec::with_capacity(tri_indices.len());
            let mut idxs = Vec::with_capacity(tri_indices.len());
            for (i, &vi) in tri_indices.iter().enumerate() {
                if let Some(mv) = mesh.vertices.get(vi) {
                    verts.push(TexVertex {
                        position: [mv.x, mv.y],
                        uv: [mv.u, mv.v],
                        color: [mv.r, mv.g, mv.b, mv.a],
                        w_depth: 1.0,
                        _pad: [0.0; 3],
                    });
                    idxs.push(i as u32);
                }
            }

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
                index_count: idxs.len() as u32,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::TextureInstanced,
                texture: mesh.texture,
            }
        } else {
            let mut verts = Vec::with_capacity(tri_indices.len());
            let mut idxs = Vec::with_capacity(tri_indices.len());
            for (i, &vi) in tri_indices.iter().enumerate() {
                if let Some(mv) = mesh.vertices.get(vi) {
                    verts.push(ColorVertex {
                        position: [mv.x, mv.y],
                        color: [mv.r, mv.g, mv.b, mv.a],
                    });
                    idxs.push(i as u32);
                }
            }

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
                index_count: idxs.len() as u32,
                geometry_kind: crate::render::gpu_pipeline::GeometryKind::ColorInstanced,
                texture: None,
            }
        };

        self.mesh_cache.static_geometry.insert(static_key, entry);
        Ok(())
    }
}
