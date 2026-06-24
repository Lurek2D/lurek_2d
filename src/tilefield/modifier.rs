//! This file owns modifier behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate modifier state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

use crate::tilefield::{TileChannel, TileLightEmitter};
use std::collections::HashMap;

/// Runtime modifier applied to one or more tilefield cells.
#[derive(Debug, Clone, Default)]
pub struct TileModifier {
    /// Stable modifier name.
    pub name: String,
    /// Optional blocker overrides per channel.
    pub blockers: HashMap<TileChannel, bool>,
    /// Additive cost changes per channel.
    pub cost_add: HashMap<TileChannel, f32>,
    /// Multiplicative cost changes per channel.
    pub cost_mul: HashMap<TileChannel, f32>,
    /// Optional blocker overrides per user-defined category.
    pub category_blockers: HashMap<String, bool>,
    /// Additive cost changes per user-defined category.
    pub category_cost_add: HashMap<String, f32>,
    /// Multiplicative cost changes per user-defined category.
    pub category_cost_mul: HashMap<String, f32>,
    /// Transmission multipliers per user-defined category.
    pub category_transmission: HashMap<String, f32>,
    /// RGB filters per user-defined category.
    pub category_filters: HashMap<String, [f32; 3]>,
    /// Additive top-sun occlusion change.
    pub sun_occlusion_add: f32,
    /// Optional tilelight source emitted by cells with this modifier.
    pub light: Option<TileLightEmitter>,
    /// Custom game-defined properties.
    pub properties: HashMap<String, String>,
}

impl TileModifier {
    /// Create an empty named modifier.
    pub fn new(name: String) -> Result<Self, String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("tilefield modifier name must not be empty".to_string());
        }
        Ok(Self {
            name: name.to_string(),
            ..Self::default()
        })
    }
}
