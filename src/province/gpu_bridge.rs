//! GPU-uploadable province data bridge between registry and render pipeline.
//!
//! - Packs province style fields into a repr(C) record for direct buffer upload.
//! - Builds sorted record arrays from the province registry for deterministic GPU ordering.

use crate::province::border_index::ProvinceBorderIndex;
use crate::province::registry::ProvinceRegistry;

/// Per-province GPU record laid out for direct buffer upload; repr(C) guarantees field order.
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProvinceGpuRecord {
    /// RGBA political fill colour, matching ProvinceStyle::political_color.
    pub political_color: [f32; 4],
    /// Terrain type index matching ProvinceStyle::terrain_type.
    pub terrain_type: u32,
    /// Border style index matching ProvinceStyle::border_style.
    pub border_style: u32,
    /// Fog state packed as u32 for alignment; matches ProvinceStyle::fog_state.
    pub fog_state: u32,
    /// Visibility state packed as u32 for alignment; matches ProvinceStyle::visibility_state.
    pub visibility_state: u32,
}

/// Per-border-pair GPU style record laid out for direct storage-buffer upload.
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct BorderStyleGpuRecord {
    /// RGBA border color.
    pub color: [f32; 4],
    /// Border line thickness in map pixels.
    pub thickness: f32,
    /// Semantic style bitflags.
    pub flags: u32,
    /// Padding for 16-byte alignment.
    pub _pad: [f32; 2],
}

/// Build a sorted Vec of ProvinceGpuRecord from registry province ids; result order follows sorted ids.
pub fn build_gpu_records(registry: &ProvinceRegistry) -> Vec<ProvinceGpuRecord> {
    let mut ids = registry.province_ids();
    ids.sort_unstable();
    ids.into_iter()
        .filter_map(|id| registry.get_province(id))
        .map(|snap| ProvinceGpuRecord {
            political_color: snap.style.political_color,
            terrain_type: snap.style.terrain_type,
            border_style: snap.style.border_style,
            fog_state: snap.style.fog_state as u32,
            visibility_state: snap.style.visibility_state as u32,
        })
        .collect()
}

/// Build border style GPU records aligned to `ProvinceBorderIndex::id_to_pair`.
pub fn build_border_style_gpu_records(
    registry: &ProvinceRegistry,
    border_index: &ProvinceBorderIndex,
) -> Vec<BorderStyleGpuRecord> {
    let mut out = Vec::with_capacity(border_index.id_to_pair.len());
    out.push(BorderStyleGpuRecord {
        color: [0.0, 0.0, 0.0, 0.0],
        thickness: 0.0,
        flags: 0,
        _pad: [0.0, 0.0],
    });

    for &(a, b) in border_index.id_to_pair.iter().skip(1) {
        let style = registry.get_border_pair_style(a, b).unwrap_or_default();
        let border_type = registry.get_border_type(a, b).unwrap_or(0);
        let default_color = registry
            .get_border_type_config(border_type)
            .map(|c| c.color)
            .unwrap_or([0.5, 0.5, 0.5, 1.0]);
        let color = style.color.unwrap_or(default_color);
        out.push(BorderStyleGpuRecord {
            color,
            thickness: style.thickness.max(1.0),
            flags: style.flags.bits() as u32,
            _pad: [0.0, 0.0],
        });
    }

    out
}
