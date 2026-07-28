//! Defines the CPU-only render snapshot exported by the province domain.
//!
//! Province owns construction from `ProvinceRegistry`, topology, and semantic
//! style records. Render consumes this immutable packet without accessing a
//! registry or any `wgpu` type.

use crate::province::border_index::{build_border_index_from_registry, ProvinceBorderIndex};
use crate::province::distance_field::compute_distance_field_from_registry;
use crate::province::gpu_bridge::{
    build_border_style_gpu_records, build_dense_gpu_records, BorderStyleGpuRecord,
    ProvinceGpuRecord,
};
use crate::province::registry::ProvinceRegistry;

/// Bounded CPU data required to upload and draw one province map.
///
/// The packet is versioned per payload family so a renderer can update only
/// the GPU resource whose source changed. It deliberately contains no GPU
/// handle, device, queue, or registry reference.
#[derive(Clone, Debug, PartialEq)]
pub struct ProvinceRenderSnapshot {
    /// Map dimensions in cells.
    pub width: u32,
    /// Map dimensions in cells.
    pub height: u32,
    /// Registry revision from which this packet was built.
    pub revision: u64,
    /// Stable version of province-id pixels.
    pub province_ids_version: u64,
    /// Stable version of border-index pixels.
    pub border_index_version: u64,
    /// Stable version of distance-field pixels.
    pub distance_field_version: u64,
    /// Stable version of per-province style records.
    pub province_records_version: u64,
    /// Stable version of border-style records.
    pub border_records_version: u64,
    /// Row-major province identifiers for the `R32Uint` upload.
    pub province_ids: Vec<u32>,
    /// Row-major border-pair indexes for the `R16Uint` upload.
    pub border_index: Vec<u16>,
    /// Row-major normalized distance values for the `R8Unorm` upload.
    pub distance_field: Vec<u8>,
    /// Dense province style records indexed by province identifier.
    pub province_records: Vec<ProvinceGpuRecord>,
    /// Border style records indexed by border-pair identifier.
    pub border_records: Vec<BorderStyleGpuRecord>,
}

impl ProvinceRenderSnapshot {
    /// Extract a bounded renderer-neutral packet from the authoritative registry.
    pub fn from_registry(registry: &ProvinceRegistry) -> Self {
        let width = registry.width();
        let height = registry.height();
        let mut province_ids = Vec::with_capacity((width as usize).saturating_mul(height as usize));
        for y in 0..height {
            for x in 0..width {
                province_ids.push(registry.get_at(x, y));
            }
        }
        let border_index: ProvinceBorderIndex = build_border_index_from_registry(registry);
        let distance_field = compute_distance_field_from_registry(registry, 32);
        let province_records = build_dense_gpu_records(registry);
        let border_records = build_border_style_gpu_records(registry, &border_index);

        Self {
            width,
            height,
            revision: registry.revision(),
            province_ids_version: version_u32(&province_ids),
            border_index_version: version_u16(&border_index.data),
            distance_field_version: version_bytes(&distance_field.data),
            province_records_version: version_records(&province_records),
            border_records_version: version_records(&border_records),
            province_ids,
            border_index: border_index.data,
            distance_field: distance_field.data,
            province_records,
            border_records,
        }
    }
}

fn version_bytes(bytes: &[u8]) -> u64 {
    bytes.iter().fold(0xcbf2_9ce4_8422_2325_u64, |hash, byte| {
        (hash ^ u64::from(*byte)).wrapping_mul(0x100_0000_01b3)
    })
}

fn version_u16(values: &[u16]) -> u64 {
    let mut hash = 0xcbf2_9ce4_8422_2325_u64;
    for value in values {
        for byte in value.to_le_bytes() {
            hash = (hash ^ u64::from(byte)).wrapping_mul(0x100_0000_01b3);
        }
    }
    hash
}

fn version_u32(values: &[u32]) -> u64 {
    let mut hash = 0xcbf2_9ce4_8422_2325_u64;
    for value in values {
        for byte in value.to_le_bytes() {
            hash = (hash ^ u64::from(byte)).wrapping_mul(0x100_0000_01b3);
        }
    }
    hash
}

fn version_records<T: bytemuck::Pod>(records: &[T]) -> u64 {
    version_bytes(bytemuck::cast_slice(records))
}
