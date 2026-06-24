//! Owns reusable tileset object archetypes and their engine-facing default parameters.

use crate::tilefield::TileChannel;
use crate::tileset::visual::TileVisual;
use std::collections::HashMap;

/// Tile-based light source defaults authored on a tileset object archetype.
#[derive(Debug, Clone)]
pub struct TileObjectLight {
    /// Radius in tiles.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color in 0..1.
    pub color: [f32; 3],
}

impl Default for TileObjectLight {
    fn default() -> Self {
        Self {
            radius: 1.0,
            intensity: 1.0,
            color: [1.0, 1.0, 1.0],
        }
    }
}

/// Reusable object archetype that can be referenced by `tilefield` slots.
#[derive(Debug, Clone)]
pub struct TileObjectArchetype {
    /// Stable object name chosen by the game.
    pub name: String,
    /// Optional default tilefield slot for this object type.
    pub slot: Option<String>,
    /// Visual data consumed by tilemap render ordering.
    pub visual: Option<TileVisual>,
    /// Per-channel blocker defaults.
    pub blockers: HashMap<TileChannel, bool>,
    /// Per-channel cost/transmission defaults.
    pub costs: HashMap<TileChannel, f32>,
    /// Per-category blocker defaults.
    pub category_blockers: HashMap<String, bool>,
    /// Per-category cost defaults.
    pub category_costs: HashMap<String, f32>,
    /// Per-category transmission defaults.
    pub category_transmission: HashMap<String, f32>,
    /// Per-category RGB filter defaults.
    pub category_filters: HashMap<String, [f32; 3]>,
    /// Optional footprint width/height in cells.
    pub footprint: Option<(u32, u32)>,
    /// Optional top-sun occlusion default in 0..1.
    pub sun_occlusion: Option<f32>,
    /// Optional tilelight source defaults.
    pub light: Option<TileObjectLight>,
    /// Custom game-defined properties.
    pub properties: HashMap<String, String>,
}

impl TileObjectArchetype {
    /// Create an empty archetype with a stable name.
    pub fn new(name: String) -> Result<Self, String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("tileset object archetype name must not be empty".to_string());
        }
        Ok(Self {
            name: name.to_string(),
            slot: None,
            visual: None,
            blockers: HashMap::new(),
            costs: HashMap::new(),
            category_blockers: HashMap::new(),
            category_costs: HashMap::new(),
            category_transmission: HashMap::new(),
            category_filters: HashMap::new(),
            footprint: None,
            sun_occlusion: None,
            light: None,
            properties: HashMap::new(),
        })
    }
}
