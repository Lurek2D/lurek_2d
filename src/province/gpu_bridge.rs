//! Owns the province GPU bridge implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province GPU bridge data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province GPU bridge behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where province code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing province GPU bridge defaults, lifecycle handling, validation, or data ownership rules.

use bytemuck::{Pod, Zeroable};

use crate::province::border_index::ProvinceBorderIndex;
use crate::province::registry::ProvinceRegistry;
use crate::province::types::{BorderPairFlags, ProvinceId};

const BORDER_FLAG_COAST: u32 = 0x10;
const BORDER_FLAG_SEA: u32 = 0x20;
const BORDER_FLAG_EXPLICIT_COLOR: u32 = 0x80;

/// Per-province GPU record laid out for direct buffer upload; repr(C) guarantees field order.
#[repr(C)]
#[derive(Debug, Clone, Copy, Pod, Zeroable, PartialEq)]
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
    /// Climate id, weather id, effect flags, and deterministic province visual seed.
    pub visual_u32: [u32; 4],
    /// Weather strength plus reserved shader parameters for future expansion.
    pub visual_f32: [f32; 4],
}

/// Per-border-pair GPU style record laid out for direct storage-buffer upload.
#[repr(C)]
#[derive(Debug, Clone, Copy, Pod, Zeroable, PartialEq)]
pub struct BorderStyleGpuRecord {
    /// RGBA border color.
    pub color: [f32; 4],
    /// Border line thickness in map pixels.
    pub thickness: f32,
    /// Semantic style bitflags.
    pub flags: u32,
    /// First province id in the border pair.
    pub province_a: u32,
    /// Second province id in the border pair.
    pub province_b: u32,
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
            visual_u32: [
                snap.style.visual_state.climate_type as u32,
                snap.style.visual_state.weather_type as u32,
                snap.style.visual_state.effect_flags,
                snap.style.visual_state.visual_seed,
            ],
            visual_f32: [snap.style.visual_state.weather_strength, 0.0, 0.0, 0.0],
        })
        .collect()
}

/// Build province records indexed directly by raw province id, including slot 0 for empty/ocean pixels.
pub fn build_dense_gpu_records(registry: &ProvinceRegistry) -> Vec<ProvinceGpuRecord> {
    let ids = registry.province_ids();
    let max_id = ids.iter().map(|id| id.raw()).max().unwrap_or(0);
    let mut out = vec![default_province_gpu_record(); max_id as usize + 1];
    for id in ids {
        if let Some(snap) = registry.get_province(id) {
            out[id.raw() as usize] = ProvinceGpuRecord {
                political_color: snap.style.political_color,
                terrain_type: snap.style.terrain_type,
                border_style: snap.style.border_style,
                fog_state: snap.style.fog_state as u32,
                visibility_state: snap.style.visibility_state as u32,
                visual_u32: [
                    snap.style.visual_state.climate_type as u32,
                    snap.style.visual_state.weather_type as u32,
                    snap.style.visual_state.effect_flags,
                    snap.style.visual_state.visual_seed,
                ],
                visual_f32: [snap.style.visual_state.weather_strength, 0.0, 0.0, 0.0],
            };
        }
    }
    if out.is_empty() {
        out.push(default_province_gpu_record());
    }
    out
}

fn default_province_gpu_record() -> ProvinceGpuRecord {
    ProvinceGpuRecord {
        political_color: [0.05, 0.15, 0.35, 1.0],
        terrain_type: 0,
        border_style: 0,
        fog_state: 0,
        visibility_state: 2,
        visual_u32: [0, 0, 0, 0],
        visual_f32: [0.0, 0.0, 0.0, 0.0],
    }
}

fn effective_border_thickness(
    registry: &ProvinceRegistry,
    pair: (
        crate::province::types::ProvinceId,
        crate::province::types::ProvinceId,
    ),
) -> f32 {
    if let Some(style) = registry.get_border_pair_style(pair.0, pair.1) {
        return style.thickness.max(1.0);
    }
    registry
        .get_border_type(pair.0, pair.1)
        .and_then(|type_id| {
            registry
                .get_border_type_config(type_id)
                .map(|config| config.thickness)
        })
        .unwrap_or(1.0)
        .max(1.0)
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
        province_a: 0,
        province_b: 0,
    });

    for &(a, b) in border_index.id_to_pair.iter().skip(1) {
        let style = registry.get_border_pair_style(a, b).unwrap_or_default();
        let border_type = registry.get_border_type(a, b).unwrap_or(0);
        let border_type_config = registry.get_border_type_config(border_type);
        let default_color = border_type_config
            .map(|c| c.color)
            .unwrap_or([0.5, 0.5, 0.5, 1.0]);
        let color = style.color.unwrap_or(default_color);
        let mut flags = style.flags.bits() as u32;
        let mut semantic_type = false;
        if let Some(config) = border_type_config {
            let name = config.name.to_lowercase();
            if name.contains("coast") {
                flags |= BORDER_FLAG_COAST;
                semantic_type = true;
            }
            if name.contains("sea") || name.contains("water") {
                flags |= BORDER_FLAG_SEA;
                semantic_type = true;
            }
            if name.contains("country") {
                flags |= BorderPairFlags::COUNTRY as u32;
                semantic_type = true;
            }
        }
        if a.raw() == 0 || b.raw() == 0 {
            flags |= BORDER_FLAG_COAST;
        }
        if let Some(kind) = water_border_kind(registry, a, b) {
            match kind {
                WaterBorderKind::Coast => flags |= BORDER_FLAG_COAST,
                WaterBorderKind::Sea => flags |= BORDER_FLAG_SEA,
            }
        }
        if style.color.is_some() || (border_type_config.is_some() && !semantic_type) {
            flags |= BORDER_FLAG_EXPLICIT_COLOR;
        }
        out.push(BorderStyleGpuRecord {
            color,
            thickness: effective_border_thickness(registry, (a, b)),
            flags,
            province_a: a.raw(),
            province_b: b.raw(),
        });
    }

    out
}

enum WaterBorderKind {
    Coast,
    Sea,
}

fn water_border_kind(
    registry: &ProvinceRegistry,
    a: ProvinceId,
    b: ProvinceId,
) -> Option<WaterBorderKind> {
    if a.raw() == 0 || b.raw() == 0 {
        return Some(WaterBorderKind::Coast);
    }
    let a_water = registry
        .style_for(a)
        .map(|style| style.terrain_type == 0)
        .unwrap_or(false);
    let b_water = registry
        .style_for(b)
        .map(|style| style.terrain_type == 0)
        .unwrap_or(false);
    match (a_water, b_water) {
        (true, true) => Some(WaterBorderKind::Sea),
        (true, false) | (false, true) => Some(WaterBorderKind::Coast),
        _ => None,
    }
}
