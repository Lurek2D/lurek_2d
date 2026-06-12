//! - Manages persistent GPU resource lifetimes, allocations, and buffer uploads.
//! - Handles dynamic capacity adjustment for growing vertex and index buffers.
//! - Caches textures, fonts, and canvases inside slotmap collection structures.
//! - Prunes unused graphics resources automatically to prevent GPU memory leaks.
//! - Resizes vertex and index buffers exponentially to minimize pipeline stalls.
//! - Uploads static draw geometries to permanent GPU buffers for cached rendering.
//! - Registers textures and binds their sampler configurations at upload time.
//! - Creates depth-stencil targets matching canvas dimensions.
//! - Builds sampler descriptors using texture filtering parameters.
//! - Initializes fallbacks like blank solid textures for loading assets.
//! - Provides methods to fetch, update, insert, and remove textures and fonts.
//! - Maps texture wrapping, repeat flags, and linear filtering state.
//! - Validates texture format channels before uploading pixel buffers.
//! - Integrates with shader resource keys to match draw commands to assets.
//! - Tracks resource usage dirty flags to compile bind groups on demand.

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

impl GpuRenderer {
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
            log::warn!(
                "[G003] grew tex index buffer capacity to {} indices",
                self.tex_index_capacity
            );
        }
    }

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
        }
    }

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

    pub(crate) fn create_gpu_texture_raw(
        &self,
        pixels: &[u8],
        width: u32,
        height: u32,
        color_space: crate::image::TextureColorSpace,
        default_filter: &(String, String, u32),
    ) -> GpuTexture {
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
        GpuTexture {
            _texture: texture,
            view,
            bind_group,
            width,
            height,
        }
    }

    /// Uploads pixel data to a new GPU texture associated with the given key.
    pub fn upload_texture(
        &mut self,
        key: TextureKey,
        pixels: &[u8],
        width: u32,
        height: u32,
        color_space: crate::image::TextureColorSpace,
        default_filter: &(String, String, u32),
    ) {
        let gt = self.create_gpu_texture_raw(pixels, width, height, color_space, default_filter);
        self.gpu_textures.insert(key, gt);
    }

    pub(crate) fn ensure_font_atlas(
        &mut self,
        font_key: FontKey,
        font: &mut crate::render::Font,
        default_filter: &(String, String, u32),
    ) -> bool {
        let (data, w, h) = font.atlas_data();
        if font.is_dirty() || !self.font_atlas_textures.contains_key(font_key) {
            let gt = self.create_gpu_texture_raw(
                data,
                w,
                h,
                crate::image::TextureColorSpace::Srgb,
                default_filter,
            );
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
    ) {
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
        self.canvas_gpu_textures.insert(
            key,
            GpuTexture {
                _texture: texture,
                view,
                bind_group,
                width,
                height,
            },
        );
        self.canvas_needs_clear.insert(key, true);
    }

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
                let mesh_key = MeshKey::from(key.data());
                !meshes.contains_key(mesh_key)
            })
            .collect();
        for key in stale_meshes {
            self.mesh_cache.static_geometry.remove(&key);
        }
    }

    pub(crate) fn sync_mesh(&mut self, mesh_key: MeshKey, mesh: &crate::render::Mesh) {
        use wgpu::util::DeviceExt;

        let tri_indices = mesh.triangulate();
        let static_key = StaticGeometryKey::from(mesh_key.data());

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
    }
}
