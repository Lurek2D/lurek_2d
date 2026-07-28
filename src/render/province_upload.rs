//! Owns GPU texture creation and uploads for renderer-neutral province packets.
//!
//! This is the sole `wgpu` owner for province-map texture residency. Province
//! prepares CPU payloads; this module selects formats and writes them to the queue.

/// GPU texture bundle used by the province-map renderer.
pub(crate) struct ProvinceGpuTextures {
    pub(crate) province_id_texture: wgpu::Texture,
    pub(crate) province_id_view: wgpu::TextureView,
    pub(crate) border_index_texture: wgpu::Texture,
    pub(crate) border_index_view: wgpu::TextureView,
    pub(crate) distance_field_texture: wgpu::Texture,
    pub(crate) distance_field_view: wgpu::TextureView,
    pub(crate) width: u32,
    pub(crate) height: u32,
}

fn extent(width: u32, height: u32) -> wgpu::Extent3d {
    wgpu::Extent3d {
        width,
        height,
        depth_or_array_layers: 1,
    }
}

#[allow(clippy::too_many_arguments)] // Mirrors the independent wgpu texture/upload descriptor fields.
fn texture_and_view(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    label: &'static str,
    width: u32,
    height: u32,
    format: wgpu::TextureFormat,
    bytes: &[u8],
    bytes_per_row: u32,
) -> (wgpu::Texture, wgpu::TextureView) {
    let texture = device.create_texture(&wgpu::TextureDescriptor {
        label: Some(label),
        size: extent(width, height),
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format,
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
        bytes,
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(bytes_per_row),
            rows_per_image: Some(height),
        },
        extent(width, height),
    );
    let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
    (texture, view)
}

/// Upload province identifiers to the renderer-owned `R32Uint` texture.
pub(crate) fn create_province_id_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    values: &[u32],
) -> (wgpu::Texture, wgpu::TextureView) {
    debug_assert_eq!(
        values.len(),
        (width as usize).saturating_mul(height as usize)
    );
    let bytes: Vec<u8> = values
        .iter()
        .flat_map(|value| value.to_le_bytes())
        .collect();
    texture_and_view(
        device,
        queue,
        "province_id_map",
        width,
        height,
        wgpu::TextureFormat::R32Uint,
        &bytes,
        4 * width,
    )
}

/// Upload border-pair identifiers to the renderer-owned `R16Uint` texture.
pub(crate) fn create_border_index_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    values: &[u16],
) -> (wgpu::Texture, wgpu::TextureView) {
    debug_assert_eq!(
        values.len(),
        (width as usize).saturating_mul(height as usize)
    );
    let bytes: Vec<u8> = values
        .iter()
        .flat_map(|value| value.to_le_bytes())
        .collect();
    texture_and_view(
        device,
        queue,
        "province_border_index",
        width,
        height,
        wgpu::TextureFormat::R16Uint,
        &bytes,
        2 * width,
    )
}

/// Upload normalized border distances to the renderer-owned `R8Unorm` texture.
pub(crate) fn create_distance_field_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    width: u32,
    height: u32,
    values: &[u8],
) -> (wgpu::Texture, wgpu::TextureView) {
    debug_assert_eq!(
        values.len(),
        (width as usize).saturating_mul(height as usize)
    );
    texture_and_view(
        device,
        queue,
        "province_distance_field",
        width,
        height,
        wgpu::TextureFormat::R8Unorm,
        values,
        width,
    )
}

/// Create every renderer-owned texture for a snapshot.
pub(crate) fn create_province_gpu_textures(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    snapshot: &crate::province::render_snapshot::ProvinceRenderSnapshot,
) -> ProvinceGpuTextures {
    let (province_id_texture, province_id_view) = create_province_id_texture(
        device,
        queue,
        snapshot.width,
        snapshot.height,
        &snapshot.province_ids,
    );
    let (border_index_texture, border_index_view) = create_border_index_texture(
        device,
        queue,
        snapshot.width,
        snapshot.height,
        &snapshot.border_index,
    );
    let (distance_field_texture, distance_field_view) = create_distance_field_texture(
        device,
        queue,
        snapshot.width,
        snapshot.height,
        &snapshot.distance_field,
    );
    ProvinceGpuTextures {
        province_id_texture,
        province_id_view,
        border_index_texture,
        border_index_view,
        distance_field_texture,
        distance_field_view,
        width: snapshot.width,
        height: snapshot.height,
    }
}
