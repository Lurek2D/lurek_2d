//! Defines the CPU-only render snapshot exported by the province domain.
//!
//! Province owns construction from `ProvinceRegistry`, topology, and semantic
//! style records. Render consumes this immutable packet without accessing a
//! registry or any `wgpu` type.

use crate::province::border_index::{build_border_index_from_registry, ProvinceBorderIndex};
use crate::province::distance_field::compute_distance_field_from_registry;
use crate::province::gpu_bridge::{
    build_border_style_gpu_records, build_dense_gpu_records, build_gpu_records,
    BorderStyleGpuRecord, ProvinceGpuRecord,
};
use crate::province::registry::ProvinceRegistry;
use crate::province::types::ProvinceGeometryKind;
use std::collections::HashMap;

/// One immutable polygon component prepared for a renderer-owned mesh.
#[derive(Clone, Debug, PartialEq)]
pub struct ProvincePolygonRenderComponent {
    /// Original province identity.
    pub province_id: u32,
    /// Source object retained for diagnostics and stable ordering.
    pub source_object_id: u32,
    /// Counter-clockwise map-space vertices.
    pub vertices: Vec<f32>,
    /// Triangle-list indexes into `vertices`.
    pub triangle_indices: Vec<u32>,
    /// Component AABB `(min_x, min_y, max_x, max_y)` in map coordinates.
    pub bounds: (f32, f32, f32, f32),
    /// Compact style-record slot.
    pub style_slot: u32,
}

/// One shared polygon edge prepared for a renderer-owned stroke mesh.
#[derive(Clone, Debug, PartialEq)]
pub struct ProvincePolygonRenderBorder {
    /// Lower province identity.
    pub province_a: u32,
    /// Higher province identity.
    pub province_b: u32,
    /// Segment endpoints in map coordinates.
    pub x0: f32,
    /// Segment endpoints in map coordinates.
    pub y0: f32,
    /// Segment endpoints in map coordinates.
    pub x1: f32,
    /// Segment endpoints in map coordinates.
    pub y1: f32,
    /// Compact border-style slot, matching `border_records`.
    pub style_slot: u32,
}

/// Renderer-neutral polygon geometry payload. It contains no GPU resources.
#[derive(Clone, Debug, PartialEq)]
pub struct PolygonRenderGeometrySnapshot {
    /// Map-space extent `(min_x, min_y, max_x, max_y)`.
    pub bounds: (f32, f32, f32, f32),
    /// Stable compact-to-original style slot mapping.
    pub province_ids: Vec<u32>,
    /// Authored components in source-object order.
    pub polygons: Vec<ProvincePolygonRenderComponent>,
    /// Exact shared border intervals.
    pub borders: Vec<ProvincePolygonRenderBorder>,
}

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
    /// Authoritative geometry representation used by this snapshot.
    pub geometry_kind: ProvinceGeometryKind,
    /// Stable hash of geometry/topology, independent from style versions.
    pub geometry_version: u64,
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
    /// Polygon mesh payload when `geometry_kind` is `Polygon`.
    pub polygon_geometry: Option<PolygonRenderGeometrySnapshot>,
}

impl ProvinceRenderSnapshot {
    /// Extract a bounded renderer-neutral packet from the authoritative registry.
    pub fn from_registry(registry: &ProvinceRegistry) -> Self {
        let width = registry.width();
        let height = registry.height();
        let geometry_kind = registry.geometry_kind();
        let (province_ids, border_index, distance_field, province_records, polygon_geometry) =
            if geometry_kind == ProvinceGeometryKind::Polygon {
                let polygon_geometry = registry.polygon_geometry().map(|geometry| {
                    let border_slot_map = polygon_border_index(geometry, width, height).pair_to_id;
                    let province_ids = registry
                        .province_ids()
                        .into_iter()
                        .map(|id| id.raw())
                        .collect::<Vec<_>>();
                    let slots = province_ids
                        .iter()
                        .enumerate()
                        .map(|(slot, id)| (*id, slot as u32))
                        .collect::<HashMap<_, _>>();
                    let polygons = geometry
                        .polygons
                        .iter()
                        .map(|polygon| ProvincePolygonRenderComponent {
                            province_id: polygon.province_id.raw(),
                            source_object_id: polygon.source_object_id,
                            vertices: polygon.vertices.clone(),
                            triangle_indices: polygon.triangle_indices.clone(),
                            bounds: polygon.bounds,
                            style_slot: slots.get(&polygon.province_id.raw()).copied().unwrap_or(0),
                        })
                        .collect();
                    let borders = geometry
                        .borders
                        .iter()
                        .map(|border| ProvincePolygonRenderBorder {
                            province_a: border.province_a.raw(),
                            province_b: border.province_b.raw(),
                            x0: border.x0,
                            y0: border.y0,
                            x1: border.x1,
                            y1: border.y1,
                            style_slot: border_slot_map
                                .get(&(border.province_a, border.province_b))
                                .copied()
                                .unwrap_or(0) as u32,
                        })
                        .collect();
                    PolygonRenderGeometrySnapshot {
                        bounds: (0.0, 0.0, geometry.width as f32, geometry.height as f32),
                        province_ids,
                        polygons,
                        borders,
                    }
                });
                let border_index = registry
                    .polygon_geometry()
                    .map(|geometry| polygon_border_index(geometry, width, height))
                    .unwrap_or_else(|| ProvinceBorderIndex {
                        data: Vec::new(),
                        width,
                        height,
                        id_to_pair: vec![(
                            crate::province::types::ProvinceId(0),
                            crate::province::types::ProvinceId(0),
                        )],
                        pair_to_id: HashMap::new(),
                    });
                let empty_distance = crate::province::distance_field::ProvinceDistanceField {
                    data: Vec::new(),
                    width,
                    height,
                    max_distance: 32,
                };
                (
                    Vec::new(),
                    border_index,
                    empty_distance,
                    build_gpu_records(registry),
                    polygon_geometry,
                )
            } else {
                let mut province_ids =
                    Vec::with_capacity((width as usize).saturating_mul(height as usize));
                for y in 0..height {
                    for x in 0..width {
                        province_ids.push(registry.get_at(x, y));
                    }
                }
                let border_index: ProvinceBorderIndex = build_border_index_from_registry(registry);
                let distance_field = compute_distance_field_from_registry(registry, 32);
                (
                    province_ids,
                    border_index,
                    distance_field,
                    build_dense_gpu_records(registry),
                    None,
                )
            };
        let border_records = build_border_style_gpu_records(registry, &border_index);
        let geometry_version = registry.geometry_version();

        Self {
            width,
            height,
            geometry_kind,
            geometry_version,
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
            polygon_geometry,
        }
    }
}

fn polygon_border_index(
    geometry: &crate::province::polygon_geometry::PolygonProvinceGeometry,
    width: u32,
    height: u32,
) -> ProvinceBorderIndex {
    let mut id_to_pair = vec![(
        crate::province::types::ProvinceId(0),
        crate::province::types::ProvinceId(0),
    )];
    let mut pair_to_id = HashMap::new();
    for border in &geometry.borders {
        let pair = (border.province_a, border.province_b);
        if pair_to_id.contains_key(&pair) {
            continue;
        }
        let id = id_to_pair.len() as u16;
        if id == 0 {
            continue;
        }
        pair_to_id.insert(pair, id);
        id_to_pair.push(pair);
    }
    ProvinceBorderIndex {
        data: Vec::new(),
        width,
        height,
        id_to_pair,
        pair_to_id,
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
