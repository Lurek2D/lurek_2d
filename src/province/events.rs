//! Change-log entries for single-field province mutations (colour, terrain, border, fog, visibility).
//!
//! - High-level map events emitted to Lua callbacks after batched province updates.
//! - Typed signals for map-mode switches, palette replacements, and fog overlays.

use crate::province::types::{BorderType, ProvinceId};

/// Single field mutation recorded in the registry change log, keyed by revision.
#[derive(Debug, Clone, PartialEq)]
pub enum ProvinceChange {
    /// Political fill colour was updated for the given province.
    PoliticalColor {
        /// Province that changed.
        province_id: ProvinceId,
        /// New RGBA colour value.
        color: [f32; 4],
    },
    /// Terrain type index was updated for the given province.
    TerrainType {
        /// Province that changed.
        province_id: ProvinceId,
        /// New terrain type index.
        terrain_type: u32,
    },
    /// Border style index was updated for the given province.
    BorderStyle {
        /// Province that changed.
        province_id: ProvinceId,
        /// New border style index.
        border_style: u32,
    },
    /// Fog-of-war state byte was updated for the given province.
    FogState {
        /// Province that changed.
        province_id: ProvinceId,
        /// New fog state byte.
        fog_state: u8,
    },
    /// Visibility state byte was updated for the given province.
    VisibilityState {
        /// Province that changed.
        province_id: ProvinceId,
        /// New visibility state byte.
        visibility_state: u8,
    },
    /// Shared border type between two provinces was updated.
    BorderType {
        /// Lower-id province of the pair (normalised).
        province_a: ProvinceId,
        /// Higher-id province of the pair (normalised).
        province_b: ProvinceId,
        /// New border type identifier.
        border_type: BorderType,
    },
    /// Shared border pair style between two provinces was updated.
    BorderPairStyle {
        /// Lower-id province of the pair (normalised).
        province_a: ProvinceId,
        /// Higher-id province of the pair (normalised).
        province_b: ProvinceId,
        /// Optional RGBA color override.
        color: Option<[f32; 4]>,
        /// New line thickness.
        thickness: f32,
        /// Semantic style flag bits.
        flags: u8,
    },
    /// Active map mode was changed to a new named mode.
    MapModeChanged {
        /// New map mode name string.
        mode: String,
    },
}

/// High-level map signal emitted to Lua callbacks after province mutations are batched.
#[derive(Debug, Clone, PartialEq)]
pub enum ProvinceEvent {
    /// One or more province styles changed; Lua should redraw affected provinces.
    ProvinceStateChanged,
    /// Active map mode changed to the given string token.
    MapModeChanged {
        /// New map mode token (e.g. "political", "terrain").
        mode: String,
    },
    /// Terrain colour palette was replaced; full repaint required.
    TerrainPaletteChanged,
    /// Global border style setting changed; border geometry needs redraw.
    BorderStyleChanged,
    /// Fog state changed across provinces; fog overlay needs update.
    FogStateChanged,
}
