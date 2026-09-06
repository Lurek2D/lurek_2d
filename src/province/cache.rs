//! Persists compact province geometry blobs so expensive span and border extraction can be reused across repeated loads.
//! Owns ProvinceGeometryCache records plus binary encode and decode helpers for span lists and border segment payloads.
//! Provides a storage boundary between derived province shapes and callers that want fast startup without recomputation.
//! Open this file when cache schema, geometry serialization, or compatibility rules for saved province artifacts change.

use crate::province::registry::ProvinceRegistry;
use crate::province::types::ProvinceGeometryKind;

const CACHE_MAGIC: u32 = 0x5052_5643;
const CACHE_VERSION_RASTER: u32 = 1;
const CACHE_VERSION_POLYGON: u32 = 2;
const MAX_CACHE_ITEMS: usize = 10_000_000;

/// Polygon component persisted by the version-2 geometry cache.
#[derive(Debug, Clone, PartialEq)]
pub struct ProvincePolygonCacheComponent {
    /// Tiled source object identifier.
    pub source_object_id: u32,
    /// Province identity.
    pub province_id: u32,
    /// Flattened map-space vertices.
    pub vertices: Vec<f32>,
}

/// Shared authored border persisted by the version-2 geometry cache.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProvincePolygonCacheBorder {
    /// Lower province identity.
    pub province_a: u32,
    /// Higher province identity.
    pub province_b: u32,
    /// Segment endpoints.
    pub x0: f32,
    /// Segment endpoints.
    pub y0: f32,
    /// Segment endpoints.
    pub x1: f32,
    /// Segment endpoints.
    pub y1: f32,
}

/// Serialisable snapshot of province geometry extracted from ProvinceRegistry.
#[derive(Debug, Clone)]
pub struct ProvinceGeometryCache {
    /// Geometry representation stored in this cache.
    pub geometry_kind: ProvinceGeometryKind,
    /// Pixel span runs: (province_id, row_y, x_start, x_end_exclusive).
    pub spans: Vec<(u32, u32, u32, u32)>,
    /// Border segments: (province_a, province_b, x0, y0, x1, y1).
    pub border_segments: Vec<(u32, u32, u32, u32, u32, u32)>,
    /// Polygon components for version-2 polygon caches.
    pub polygon_components: Vec<ProvincePolygonCacheComponent>,
    /// Exact polygon shared borders for version-2 polygon caches.
    pub polygon_borders: Vec<ProvincePolygonCacheBorder>,
}

/// Methods for building, encoding, and decoding geometry caches.
impl ProvinceGeometryCache {
    /// Build a cache by copying spans and border_segments from the given registry.
    pub fn from_registry(registry: &ProvinceRegistry) -> Self {
        if registry.geometry_kind() == ProvinceGeometryKind::Polygon {
            let geometry = registry
                .polygon_geometry()
                .expect("polygon registry must retain polygon geometry");
            return Self {
                geometry_kind: ProvinceGeometryKind::Polygon,
                spans: Vec::new(),
                border_segments: Vec::new(),
                polygon_components: geometry
                    .polygons
                    .iter()
                    .map(|polygon| ProvincePolygonCacheComponent {
                        source_object_id: polygon.source_object_id,
                        province_id: polygon.province_id.raw(),
                        vertices: polygon.vertices.clone(),
                    })
                    .collect(),
                polygon_borders: geometry
                    .borders
                    .iter()
                    .map(|border| ProvincePolygonCacheBorder {
                        province_a: border.province_a.raw(),
                        province_b: border.province_b.raw(),
                        x0: border.x0,
                        y0: border.y0,
                        x1: border.x1,
                        y1: border.y1,
                    })
                    .collect(),
            };
        }
        Self {
            geometry_kind: ProvinceGeometryKind::Raster,
            spans: registry.spans().to_vec(),
            border_segments: registry.border_segments().to_vec(),
            polygon_components: Vec::new(),
            polygon_borders: Vec::new(),
        }
    }

    /// Serialise to a versioned little-endian byte buffer; always succeeds.
    pub fn encode(&self) -> Vec<u8> {
        if self.geometry_kind == ProvinceGeometryKind::Polygon {
            return self.encode_polygon();
        }
        let mut out = Vec::new();
        out.extend_from_slice(&CACHE_MAGIC.to_le_bytes());
        out.extend_from_slice(&CACHE_VERSION_RASTER.to_le_bytes());
        out.extend_from_slice(&(self.spans.len() as u32).to_le_bytes());
        for (id, y, x0, x1) in &self.spans {
            out.extend_from_slice(&id.to_le_bytes());
            out.extend_from_slice(&y.to_le_bytes());
            out.extend_from_slice(&x0.to_le_bytes());
            out.extend_from_slice(&x1.to_le_bytes());
        }
        out.extend_from_slice(&(self.border_segments.len() as u32).to_le_bytes());
        for (a, b, x0, y0, x1, y1) in &self.border_segments {
            out.extend_from_slice(&a.to_le_bytes());
            out.extend_from_slice(&b.to_le_bytes());
            out.extend_from_slice(&x0.to_le_bytes());
            out.extend_from_slice(&y0.to_le_bytes());
            out.extend_from_slice(&x1.to_le_bytes());
            out.extend_from_slice(&y1.to_le_bytes());
        }
        out
    }

    fn encode_polygon(&self) -> Vec<u8> {
        let mut out = Vec::new();
        out.extend_from_slice(&CACHE_MAGIC.to_le_bytes());
        out.extend_from_slice(&CACHE_VERSION_POLYGON.to_le_bytes());
        out.push(1); // geometry kind: polygon
        out.extend_from_slice(&[0, 0, 0]);
        out.extend_from_slice(&(self.polygon_components.len() as u32).to_le_bytes());
        for component in &self.polygon_components {
            out.extend_from_slice(&component.source_object_id.to_le_bytes());
            out.extend_from_slice(&component.province_id.to_le_bytes());
            out.extend_from_slice(&(component.vertices.len() as u32).to_le_bytes());
            for value in &component.vertices {
                out.extend_from_slice(&value.to_le_bytes());
            }
        }
        out.extend_from_slice(&(self.polygon_borders.len() as u32).to_le_bytes());
        for border in &self.polygon_borders {
            out.extend_from_slice(&border.province_a.to_le_bytes());
            out.extend_from_slice(&border.province_b.to_le_bytes());
            for value in [border.x0, border.y0, border.x1, border.y1] {
                out.extend_from_slice(&value.to_le_bytes());
            }
        }
        out
    }

    /// Deserialise from a byte buffer produced by encode; return None on magic mismatch or truncation.
    pub fn decode(data: &[u8]) -> Option<Self> {
        /// Read a u32 from data at offset off, advancing off by 4; return None on underflow.
        fn read_u32(data: &[u8], off: &mut usize) -> Option<u32> {
            if *off + 4 > data.len() {
                return None;
            }
            let v =
                u32::from_le_bytes([data[*off], data[*off + 1], data[*off + 2], data[*off + 3]]);
            *off += 4;
            Some(v)
        }
        let mut off = 0usize;
        let magic = read_u32(data, &mut off)?;
        if magic != 0x5052_5643 {
            return None;
        }
        let version = read_u32(data, &mut off)?;
        if version == CACHE_VERSION_POLYGON {
            return decode_polygon(data, &mut off);
        }
        if version != CACHE_VERSION_RASTER {
            return None;
        }
        let span_count = read_u32(data, &mut off)? as usize;
        if span_count > MAX_CACHE_ITEMS {
            return None;
        }
        let span_bytes = span_count.checked_mul(16)?;
        if data.len().checked_sub(off)? < span_bytes + 4 {
            return None;
        }
        let mut spans = Vec::with_capacity(span_count);
        for _ in 0..span_count {
            spans.push((
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
            ));
        }
        let seg_count = read_u32(data, &mut off)? as usize;
        if seg_count > MAX_CACHE_ITEMS {
            return None;
        }
        let segment_bytes = seg_count.checked_mul(24)?;
        if data.len().checked_sub(off)? < segment_bytes {
            return None;
        }
        let mut border_segments = Vec::with_capacity(seg_count);
        for _ in 0..seg_count {
            border_segments.push((
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
                read_u32(data, &mut off)?,
            ));
        }
        Some(Self {
            geometry_kind: ProvinceGeometryKind::Raster,
            spans,
            border_segments,
            polygon_components: Vec::new(),
            polygon_borders: Vec::new(),
        })
    }
}

fn decode_polygon(data: &[u8], off: &mut usize) -> Option<ProvinceGeometryCache> {
    fn read_u32(data: &[u8], off: &mut usize) -> Option<u32> {
        let bytes = [
            *data.get(*off)?,
            *data.get(*off + 1)?,
            *data.get(*off + 2)?,
            *data.get(*off + 3)?,
        ];
        *off += 4;
        Some(u32::from_le_bytes(bytes))
    }
    fn read_u8(data: &[u8], off: &mut usize) -> Option<u8> {
        let value = *data.get(*off)?;
        *off += 1;
        Some(value)
    }
    fn read_f32(data: &[u8], off: &mut usize) -> Option<f32> {
        let bytes = [
            *data.get(*off)?,
            *data.get(*off + 1)?,
            *data.get(*off + 2)?,
            *data.get(*off + 3)?,
        ];
        *off += 4;
        let value = f32::from_le_bytes(bytes);
        value.is_finite().then_some(value)
    }
    let kind = read_u8(data, off)?;
    if kind != 1 || read_u8(data, off)? != 0 || read_u8(data, off)? != 0 || read_u8(data, off)? != 0
    {
        return None;
    }
    let component_count = read_u32(data, off)? as usize;
    if component_count > MAX_CACHE_ITEMS {
        return None;
    }
    let minimum_component_bytes = component_count.checked_mul(12)?;
    if data.len().checked_sub(*off)? < minimum_component_bytes + 4 {
        return None;
    }
    let mut polygon_components = Vec::with_capacity(component_count);
    let mut total_vertices = 0usize;
    for _ in 0..component_count {
        let source_object_id = read_u32(data, off)?;
        let province_id = read_u32(data, off)?;
        if source_object_id == 0 || province_id == 0 {
            return None;
        }
        let vertex_count = read_u32(data, off)? as usize;
        if !(6..=MAX_CACHE_ITEMS).contains(&vertex_count) || !vertex_count.is_multiple_of(2) {
            return None;
        }
        total_vertices = total_vertices.checked_add(vertex_count)?;
        if total_vertices > MAX_CACHE_ITEMS {
            return None;
        }
        let vertex_bytes = vertex_count.checked_mul(4)?;
        if data.len().checked_sub(*off)? < vertex_bytes {
            return None;
        }
        let mut vertices = Vec::with_capacity(vertex_count);
        for _ in 0..vertex_count {
            vertices.push(read_f32(data, off)?);
        }
        polygon_components.push(ProvincePolygonCacheComponent {
            source_object_id,
            province_id,
            vertices,
        });
    }
    let border_count = read_u32(data, off)? as usize;
    if border_count > MAX_CACHE_ITEMS {
        return None;
    }
    let border_bytes = border_count.checked_mul(24)?;
    if data.len().checked_sub(*off)? < border_bytes {
        return None;
    }
    let mut polygon_borders = Vec::with_capacity(border_count);
    for _ in 0..border_count {
        let province_a = read_u32(data, off)?;
        let province_b = read_u32(data, off)?;
        let x0 = read_f32(data, off)?;
        let y0 = read_f32(data, off)?;
        let x1 = read_f32(data, off)?;
        let y1 = read_f32(data, off)?;
        if province_a == 0 || province_b == 0 || province_a >= province_b || (x0 == x1 && y0 == y1)
        {
            return None;
        }
        polygon_borders.push(ProvincePolygonCacheBorder {
            province_a,
            province_b,
            x0,
            y0,
            x1,
            y1,
        });
    }
    Some(ProvinceGeometryCache {
        geometry_kind: ProvinceGeometryKind::Polygon,
        spans: Vec::new(),
        border_segments: Vec::new(),
        polygon_components,
        polygon_borders,
    })
}
