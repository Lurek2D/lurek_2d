//! This file owns edge state, covering endpoints, type filters, transit capacity, travel timing, and cooldown behavior.
//! `Edge` stores bidirectionality, weights, reservations, and in-transit item ids that pathfinding and simulation both use.
//! Capacity reservation helpers live here so planners and runtime sends evaluate the same available-space calculations.
//! Filtering and cooldown checks here define whether an item type may enter an edge before any transit update begins.
//! Open it when connection constraints change; node policy, route search, and graph indexing live in sibling files.

use std::collections::HashSet;

use crate::flownet::types::EdgeId;

/// Directed connection between two graph nodes.
#[derive(Clone)]
pub struct Edge {
    /// Stable edge identifier.
    pub id: EdgeId,
    /// Edge type name.
    pub edge_type: String,
    /// Source node id.
    pub from_node: u64,
    /// Destination node id.
    pub to_node: u64,
    /// Maximum items in transit, or negative for unlimited.
    pub capacity: i32,
    /// Maximum items that can move per update window.
    pub throughput: f64,
    /// Travel time in seconds.
    pub travel_time: f64,
    /// Pathfinding weight.
    pub weight: f64,
    /// Speed multiplier applied during transit.
    pub speed_modifier: f64,
    /// Cooldown duration between sends.
    pub cooldown: f64,
    /// Remaining cooldown time.
    pub cooldown_timer: f64,
    /// Flag that marks the edge as bidirectional.
    pub bidirectional: bool,
    /// Flag that enables the edge in simulation.
    pub active: bool,
    /// Allowed item types, or empty for no restriction.
    pub allowed_types: HashSet<String>,
    /// Transit capacity reservations keyed by planner or reservation tag.
    pub(crate) capacity_reservations: std::collections::HashMap<String, u32>,
    /// Item ids currently moving along the edge.
    pub items_in_transit: Vec<u64>,
}
impl Edge {
    /// Create an edge with default transit settings.
    pub fn new(id: u64, from: u64, to: u64, edge_type: &str) -> Self {
        Self {
            id: EdgeId(id),
            edge_type: edge_type.to_string(),
            from_node: from,
            to_node: to,
            capacity: -1,
            throughput: 1.0,
            travel_time: 1.0,
            weight: 1.0,
            speed_modifier: 1.0,
            cooldown: 0.0,
            cooldown_timer: 0.0,
            bidirectional: false,
            active: true,
            allowed_types: HashSet::new(),
            capacity_reservations: std::collections::HashMap::new(),
            items_in_transit: Vec::new(),
        }
    }
    /// Return the edge type string. This function is part of the public API.
    pub fn get_type(&self) -> &str {
        &self.edge_type
    }
    /// Set the edge type string. This function is part of the public API.
    pub fn set_type(&mut self, t: &str) {
        self.edge_type = t.to_string();
    }
    /// Return true when the edge is still on cooldown.
    pub fn is_on_cooldown(&self) -> bool {
        self.cooldown_timer > 0.0
    }
    /// Return true when the item type is allowed by the edge filter.
    pub fn is_item_type_allowed(&self, t: &str) -> bool {
        self.allowed_types.is_empty() || self.allowed_types.contains(t)
    }
    /// Allow an item type on the edge.
    pub fn add_allowed_type(&mut self, t: &str) {
        self.allowed_types.insert(t.to_string());
    }
    /// Remove an allowed item type and return true when it existed.
    pub fn remove_allowed_type(&mut self, t: &str) -> bool {
        self.allowed_types.remove(t)
    }
    /// Remove all allowed item type filters.
    pub fn clear_allowed_types(&mut self) {
        self.allowed_types.clear();
    }
    /// Return the total reserved transit capacity on this edge.
    pub fn get_reserved_capacity(&self) -> u32 {
        self.capacity_reservations.values().copied().sum()
    }
    /// Return the currently available transit capacity after reservations, or -1 when unlimited.
    pub fn get_available_capacity(&self) -> i32 {
        if self.capacity < 0 {
            -1
        } else {
            let occupied = self
                .items_in_transit
                .len()
                .saturating_add(self.get_reserved_capacity() as usize);
            (self.capacity as i64 - occupied as i64).max(0) as i32
        }
    }
    /// Return true when the edge can reserve the requested number of transit slots.
    pub fn can_reserve_capacity(&self, slots: u32) -> bool {
        if self.capacity < 0 {
            true
        } else {
            self.get_available_capacity() >= slots as i32
        }
    }
    /// Reserve edge transit capacity under a caller-provided key.
    pub fn reserve_capacity(&mut self, key: &str, slots: u32) -> bool {
        if !self.can_reserve_capacity(slots) {
            return false;
        }
        *self
            .capacity_reservations
            .entry(key.to_string())
            .or_insert(0) += slots;
        true
    }
    /// Release up to `slots` transit reservations for a key and return the amount removed.
    pub fn release_capacity_reservation(&mut self, key: &str, slots: Option<u32>) -> u32 {
        let Some(current) = self.capacity_reservations.get_mut(key) else {
            return 0;
        };
        let removed = slots.unwrap_or(*current).min(*current);
        *current -= removed;
        if *current == 0 {
            self.capacity_reservations.remove(key);
        }
        removed
    }
    /// Remove every transit capacity reservation from this edge.
    pub fn clear_capacity_reservations(&mut self) {
        self.capacity_reservations.clear();
    }
    /// Return true when the transit buffer is at or above capacity.
    pub fn is_transit_full(&self) -> bool {
        if self.capacity < 0 {
            false
        } else {
            self.items_in_transit.len() >= self.capacity as usize
        }
    }
}
