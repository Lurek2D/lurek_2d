//! This file owns cell behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate cell state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for cell work.
//! Serialization, indexing, and boundary checks stay here when they depend on cell internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when cell ownership changes, but keep unrelated subsystem policy in sibling modules.

use crate::tilefield::{TileLightEmitter, TileRef};
use std::collections::HashMap;

/// Gameplay channels tracked independently per cell.
///
/// # Variants
///
/// Each variant owns one independent blocker/cost channel; changing one does not infer changes in another.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TileChannel {
    /// Movement and pathfinding blockers/costs.
    Move,
    /// Sight blockers and line-of-sight queries.
    Vision,
    /// Action, interaction, and line-of-fire blockers/costs.
    Action,
    /// Point-light blockers.
    Light,
    /// Global top-light attenuation channel.
    Sun,
}

impl TileChannel {
    /// Parse a public Lua channel string.
    pub fn parse(value: &str) -> Result<Self, String> {
        match value {
            "move" => Ok(Self::Move),
            "vision" => Ok(Self::Vision),
            "action" => Ok(Self::Action),
            "light" => Ok(Self::Light),
            "sun" => Ok(Self::Sun),
            other => Err(format!(
                "invalid tilefield channel '{other}' (expected move, vision, action, light, or sun)"
            )),
        }
    }

    /// Return the public Lua channel name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Move => "move",
            Self::Vision => "vision",
            Self::Action => "action",
            Self::Light => "light",
            Self::Sun => "sun",
        }
    }

    /// Return the fixed array slot used to store this channel in each tile cell.
    pub(crate) fn index(self) -> usize {
        match self {
            Self::Move => 0,
            Self::Vision => 1,
            Self::Action => 2,
            Self::Light => 3,
            Self::Sun => 4,
        }
    }
}

/// Per-cell gameplay state with independent channel blockers, costs, and sun occlusion.
///
/// # Fields
///
/// The private arrays hold built-in channels; maps hold custom category overrides, refs, emitters, and modifier names.
#[derive(Debug, Clone)]
pub struct TileCell {
    blockers: [bool; 5],
    costs: [f32; 5],
    category_blockers: HashMap<String, bool>,
    category_costs: HashMap<String, f32>,
    category_transmission: HashMap<String, f32>,
    category_filters: HashMap<String, [f32; 3]>,
    sun_occlusion: f32,
    refs: HashMap<String, u32>,
    typed_refs: HashMap<String, TileRef>,
    lights: HashMap<String, TileLightEmitter>,
    modifiers: Vec<String>,
}

impl Default for TileCell {
    fn default() -> Self {
        Self {
            blockers: [false; 5],
            costs: [1.0; 5],
            category_blockers: HashMap::new(),
            category_costs: HashMap::new(),
            category_transmission: HashMap::new(),
            category_filters: HashMap::new(),
            sun_occlusion: 0.0,
            refs: HashMap::new(),
            typed_refs: HashMap::new(),
            lights: HashMap::new(),
            modifiers: Vec::new(),
        }
    }
}

impl TileCell {
    /// Return whether this cell blocks the channel.
    pub fn blocks(&self, channel: TileChannel) -> bool {
        self.blockers[channel.index()]
    }

    /// Set whether this cell blocks the channel.
    pub fn set_block(&mut self, channel: TileChannel, blocked: bool) {
        self.blockers[channel.index()] = blocked;
    }

    /// Return the movement-style cost for the channel.
    pub fn cost(&self, channel: TileChannel) -> f32 {
        self.costs[channel.index()]
    }

    /// Set a finite non-negative cost for the channel.
    pub fn set_cost(&mut self, channel: TileChannel, cost: f32) -> Result<(), String> {
        if !cost.is_finite() || cost < 0.0 {
            return Err("tilefield cost must be a finite number >= 0".to_string());
        }
        self.costs[channel.index()] = cost;
        Ok(())
    }

    /// Return whether this cell blocks a user-defined category.
    pub fn blocks_category(&self, category: &str) -> Option<bool> {
        self.category_blockers.get(category).copied()
    }

    /// Return all explicit category blocker overrides stored on this cell.
    pub fn category_blockers(&self) -> &HashMap<String, bool> {
        &self.category_blockers
    }

    /// Set or clear a user-defined category blocker.
    pub fn set_category_block(
        &mut self,
        category: String,
        blocked: Option<bool>,
    ) -> Result<(), String> {
        let category = category.trim();
        if category.is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        match blocked {
            Some(blocked) => {
                self.category_blockers.insert(category.to_string(), blocked);
            }
            None => {
                self.category_blockers.remove(category);
            }
        }
        Ok(())
    }

    /// Return the cost for a user-defined category when present.
    pub fn category_cost(&self, category: &str) -> Option<f32> {
        self.category_costs.get(category).copied()
    }

    /// Return all explicit category costs stored on this cell.
    pub fn category_costs(&self) -> &HashMap<String, f32> {
        &self.category_costs
    }

    /// Set or clear a user-defined category cost.
    pub fn set_category_cost(&mut self, category: String, cost: Option<f32>) -> Result<(), String> {
        let category = category.trim();
        if category.is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        match cost {
            Some(cost) => {
                if !cost.is_finite() || cost < 0.0 {
                    return Err("tilefield category cost must be a finite number >= 0".to_string());
                }
                self.category_costs.insert(category.to_string(), cost);
            }
            None => {
                self.category_costs.remove(category);
            }
        }
        Ok(())
    }

    /// Return the transmission multiplier for a category when present.
    pub fn category_transmission(&self, category: &str) -> Option<f32> {
        self.category_transmission.get(category).copied()
    }

    /// Return all explicit category transmissions stored on this cell.
    pub fn category_transmissions(&self) -> &HashMap<String, f32> {
        &self.category_transmission
    }

    /// Set or clear a category transmission multiplier in `[0, 1]`.
    pub fn set_category_transmission(
        &mut self,
        category: String,
        value: Option<f32>,
    ) -> Result<(), String> {
        let category = category.trim();
        if category.is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        match value {
            Some(value) => {
                if !value.is_finite() {
                    return Err("tilefield category transmission must be finite".to_string());
                }
                self.category_transmission
                    .insert(category.to_string(), value.clamp(0.0, 1.0));
            }
            None => {
                self.category_transmission.remove(category);
            }
        }
        Ok(())
    }

    /// Return the RGB filter for a category when present.
    pub fn category_filter(&self, category: &str) -> Option<[f32; 3]> {
        self.category_filters.get(category).copied()
    }

    /// Return all explicit category RGB filters stored on this cell.
    pub fn category_filters(&self) -> &HashMap<String, [f32; 3]> {
        &self.category_filters
    }

    /// Set or clear an RGB filter for a category.
    pub fn set_category_filter(
        &mut self,
        category: String,
        value: Option<[f32; 3]>,
    ) -> Result<(), String> {
        let category = category.trim();
        if category.is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        match value {
            Some(value) => {
                if value.iter().any(|component| !component.is_finite()) {
                    return Err("tilefield category filter must contain finite numbers".to_string());
                }
                self.category_filters.insert(
                    category.to_string(),
                    [
                        value[0].clamp(0.0, 1.0),
                        value[1].clamp(0.0, 1.0),
                        value[2].clamp(0.0, 1.0),
                    ],
                );
            }
            None => {
                self.category_filters.remove(category);
            }
        }
        Ok(())
    }

    /// Return sun occlusion in the inclusive range 0..1.
    pub fn sun_occlusion(&self) -> f32 {
        self.sun_occlusion
    }

    /// Set top-light occlusion in the inclusive range 0..1.
    pub fn set_sun_occlusion(&mut self, value: f32) -> Result<(), String> {
        if !value.is_finite() {
            return Err("tilefield sunOcclusion must be finite".to_string());
        }
        self.sun_occlusion = value.clamp(0.0, 1.0);
        Ok(())
    }

    /// Return a named object/tile reference stored on this cell.
    pub fn get_ref(&self, slot: &str) -> Option<u32> {
        self.refs.get(slot).copied()
    }

    /// Set or replace a named object/tile reference on this cell.
    pub fn set_ref(&mut self, slot: String, value: u32) -> Result<(), String> {
        let slot = slot.trim();
        if slot.is_empty() {
            return Err("tilefield ref slot must not be empty".to_string());
        }
        self.refs.insert(slot.to_string(), value);
        self.typed_refs.remove(slot);
        Ok(())
    }

    /// Return a typed reference stored on this cell.
    pub fn get_typed_ref(&self, slot: &str) -> Option<&TileRef> {
        self.typed_refs.get(slot)
    }

    /// Set or replace a typed reference on this cell.
    pub fn set_typed_ref(&mut self, slot: String, value: TileRef) -> Result<(), String> {
        let slot = slot.trim();
        if slot.is_empty() {
            return Err("tilefield ref slot must not be empty".to_string());
        }
        self.typed_refs.insert(slot.to_string(), value);
        self.refs.remove(slot);
        Ok(())
    }

    /// Remove a named object/tile reference from this cell.
    pub fn clear_ref(&mut self, slot: &str) {
        self.refs.remove(slot);
        self.typed_refs.remove(slot);
    }

    /// Return all named object/tile references stored on this cell.
    pub fn refs(&self) -> &HashMap<String, u32> {
        &self.refs
    }

    /// Return all typed references stored on this cell.
    pub fn typed_refs(&self) -> &HashMap<String, TileRef> {
        &self.typed_refs
    }

    /// Return the number of occupied legacy or typed reference slots.
    pub fn ref_count(&self) -> usize {
        self.refs.len() + self.typed_refs.len()
    }

    /// Remove all data that depends on a custom category.
    pub fn remove_category_data(&mut self, category: &str) {
        self.category_blockers.remove(category);
        self.category_costs.remove(category);
        self.category_transmission.remove(category);
        self.category_filters.remove(category);
    }

    /// Set, replace, or clear a named tile light emitter on this cell.
    pub fn set_light(
        &mut self,
        source: String,
        light: Option<TileLightEmitter>,
    ) -> Result<(), String> {
        let source = source.trim();
        if source.is_empty() {
            return Err("tilefield light source name must not be empty".to_string());
        }
        match light {
            Some(light) => {
                light.validate()?;
                self.lights.insert(source.to_string(), light);
            }
            None => {
                self.lights.remove(source);
            }
        }
        Ok(())
    }

    /// Return all named tile light emitters stored on this cell.
    pub fn lights(&self) -> &HashMap<String, TileLightEmitter> {
        &self.lights
    }

    /// Add an active modifier name to this cell.
    pub fn add_modifier(&mut self, name: String) {
        if !self.modifiers.iter().any(|existing| existing == &name) {
            self.modifiers.push(name);
        }
    }

    /// Remove an active modifier name from this cell.
    pub fn remove_modifier(&mut self, name: &str) -> bool {
        if let Some(index) = self.modifiers.iter().position(|existing| existing == name) {
            self.modifiers.remove(index);
            true
        } else {
            false
        }
    }

    /// Return active modifier names in application order.
    pub fn modifiers(&self) -> &[String] {
        &self.modifiers
    }
}
