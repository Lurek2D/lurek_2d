//! - Province GPU upload helpers for id, border-index, and distance-field textures.
//! - Consistent texture descriptors for `R32Uint`, `R16Uint`, and `R8Unorm` data.
//! - Byte packing utilities used by upload paths and unit tests.

/// GPU texture bundle used by the province map renderer.
pub struct ProvinceGpuTextures {
    /// Province id map texture (`R32Uint`).
    pub province_id_texture: wgpu::Texture,
    /// Province id map view.
    pub province_id_view: wgpu::TextureView,
    /// Border index texture (`R16Uint`).
    pub border_index_texture: wgpu::Texture,
    /// Border index texture view.
    pub border_index_view: wgpu::TextureView,
    /// Distance field texture (`R8Unorm`).
    pub distance_field_texture: wgpu::Texture,
    /// Distance field texture view.
    pub distance_field_view: wgpu::TextureView,
    /// Grid width in pixels.
    pub width: u32,
    /// Grid height in pixels.
    pub height: u32,
}

fn make_extent(width: u32, height: u32) -> wgpu::Extent3d {
    wgpu::Extent3d {
        width,
        height,
        depth_or_array_layers: 1,
    }
}

/// Pack `u32` row-major pixels into little-endian bytes for `R32Uint` uploads.
pub fn pack_u32_pixels_le(data: &[u32]) -> Vec<u8> {
    let mut out = Vec::with_capacity(data.len() * 4);
    for value in data {
        out.extend_from_slice(&value.to_le_bytes());
    }
    out
}

/// Pack `u16` row-major pixels into little-endian bytes for `R16Uint` uploads.
pub fn pack_u16_pixels_le(data: &[u16]) -> Vec<u8> {
    let mut out = Vec::with_capacity(data.len() * 2);
    for value in data {
        out.extend_from_slice(&value.to_le_bytes());
    }
    out
}

/// Create and upload province id map texture (`R32Uint`).
pub fn create_province_id_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    province_ids: &[u32],
) -> (wgpu::Texture, wgpu::TextureView) {
    assert_eq!(
        province_ids.len(),
        (width as usize).saturating_mul(height as usize),
        "province_ids length must be width*height"
    );

    let texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("province_id_map"),
        size: make_extent(width, height),
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::R32Uint,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        view_formats: &[],
    });

    let bytes = pack_u32_pixels_le(province_ids);
    queue.write_texture(
        wgpu::ImageCopyTexture {
            texture: &texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        &bytes,
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(4 * width),
            rows_per_image: Some(height),
        },
        make_extent(width, height),
    );

    let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
    (texture, view)
}

/// Create and upload border index texture (`R16Uint`).
pub fn create_border_index_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    border_index: &[u16],
) -> (wgpu::Texture, wgpu::TextureView) {
    assert_eq!(
        border_index.len(),
        (width as usize).saturating_mul(height as usize),
        "border_index length must be width*height"
    );

    let texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("province_border_index"),
        size: make_extent(width, height),
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::R16Uint,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        view_formats: &[],
    });

    let bytes = pack_u16_pixels_le(border_index);
    queue.write_texture(
        wgpu::ImageCopyTexture {
            texture: &texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        &bytes,
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(2 * width),
            rows_per_image: Some(height),
        },
        make_extent(width, height),
    );

    let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
    (texture, view)
}

/// Create and upload distance field texture (`R8Unorm`).
pub fn create_distance_field_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    distance_field: &[u8],
) -> (wgpu::Texture, wgpu::TextureView) {
    assert_eq!(
        distance_field.len(),
        (width as usize).saturating_mul(height as usize),
        "distance_field length must be width*height"
    );

    let texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some("province_distance_field"),
        size: make_extent(width, height),
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::R8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        view_formats: &[],
    });

    queue.write_texture(
        wgpu::ImageCopyTexture {
            texture: &texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        distance_field,
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(width),
            rows_per_image: Some(height),
        },
        make_extent(width, height),
    );

    let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
    (texture, view)
}

/// Create all core province textures in one call.
pub fn create_province_gpu_textures(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    province_ids: &[u32],
    border_index: &[u16],
    distance_field: &[u8],
) -> ProvinceGpuTextures {
    let (province_id_texture, province_id_view) =
        create_province_id_texture(device, queue, width, height, province_ids);
    let (border_index_texture, border_index_view) =
        create_border_index_texture(device, queue, width, height, border_index);
    let (distance_field_texture, distance_field_view) =
        create_distance_field_texture(device, queue, width, height, distance_field);

    ProvinceGpuTextures {
        province_id_texture,
        province_id_view,
        border_index_texture,
        border_index_view,
        distance_field_texture,
        distance_field_view,
        width,
        height,
    }
}
