//! This file owns modifier behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate modifier state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

use crate::tilefield::limits::TileFieldLimits;
use crate::tilefield::{TileChannel, TileLightEmitter};
use std::collections::HashMap;

/// Runtime modifier applied to one or more tilefield cells.
///
/// # Fields
///
/// The maps hold additive, multiplicative, blocker, transmission, and filter overrides. `light` and `properties` carry optional authored metadata.
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

    /// Validate every numeric and string member before registration.
    pub fn validate(&self, limits: &TileFieldLimits) -> Result<(), String> {
        limits.validate_string(&self.name, "modifier name")?;
        for (channel, value) in &self.cost_add {
            if !value.is_finite() {
                return Err(format!(
                    "tilefield modifier costAdd for {} must be finite",
                    channel.as_str()
                ));
            }
        }
        for (channel, value) in &self.cost_mul {
            if !value.is_finite() || *value < 0.0 {
                return Err(format!(
                    "tilefield modifier costMul for {} must be finite and >= 0",
                    channel.as_str()
                ));
            }
        }
        for name in self.category_blockers.keys() {
            limits.validate_string(name, "category name")?;
        }
        for (name, value) in self
            .category_cost_add
            .iter()
            .chain(self.category_cost_mul.iter())
            .chain(self.category_transmission.iter())
        {
            limits.validate_string(name, "category name")?;
            if !value.is_finite() {
                return Err(format!(
                    "tilefield modifier value for '{name}' must be finite"
                ));
            }
        }
        if self.category_cost_mul.values().any(|value| *value < 0.0)
            || self
                .category_transmission
                .values()
                .any(|value| !(0.0..=1.0).contains(value))
        {
            return Err("tilefield modifier category values are out of range".to_string());
        }
        if !self.sun_occlusion_add.is_finite() {
            return Err("tilefield modifier sun occlusion must be finite".to_string());
        }
        for (name, filter) in &self.category_filters {
            limits.validate_string(name, "category name")?;
            if filter
                .iter()
                .any(|value| !value.is_finite() || *value < 0.0 || *value > 1.0)
            {
                return Err(format!(
                    "tilefield modifier filter for '{name}' is out of range"
                ));
            }
        }
        for name in self.properties.keys() {
            limits.validate_string(name, "modifier property name")?;
        }
        for value in self.properties.values() {
            limits.validate_string(value, "modifier property")?;
        }
        if let Some(light) = self.light.as_ref() {
            light.validate()?;
        }
        Ok(())
    }
}
