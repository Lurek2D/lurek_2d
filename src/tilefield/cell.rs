//! Owns per-cell gameplay channel data for blockers, traversal costs, and sun occlusion in tilefield maps.
//! Defines the fixed semantic channels used by Lua, pathfind adapters, visibility checks, and tile lighting.
//! Keeps movement, vision, action, point-light, top-light, and author-defined object references independent.
//! Provides parsing and default-state helpers for field mutation without depending on higher-level systems.
//! Does not know about topology, rendering, minimap presentation, player masks, or pathfinding algorithms.

use crate::tilefield::TileLightEmitter;
use std::collections::HashMap;

/// Gameplay channels tracked independently per cell.
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
#[derive(Debug, Clone)]
pub struct TileCell {
    blockers: [bool; 5],
    costs: [f32; 5],
    sun_occlusion: f32,
    refs: HashMap<String, u32>,
    lights: HashMap<String, TileLightEmitter>,
    modifiers: Vec<String>,
}

impl Default for TileCell {
    fn default() -> Self {
        Self {
            blockers: [false; 5],
            costs: [1.0; 5],
            sun_occlusion: 0.0,
            refs: HashMap::new(),
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
        Ok(())
    }

    /// Remove a named object/tile reference from this cell.
    pub fn clear_ref(&mut self, slot: &str) {
        self.refs.remove(slot);
    }

    /// Return all named object/tile references stored on this cell.
    pub fn refs(&self) -> &HashMap<String, u32> {
        &self.refs
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
