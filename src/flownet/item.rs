//! Provides flownet item records that carry typed payload identity through nodes and transit edges. `flownet/item` delivers the item implementation for the flownet subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Tracks location state as node-bound, in-transit, or unplaced to drive simulation decisions. The file owns or coordinates data contracts including `ItemPosition`, `GraphItem`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Stores decay lifetime, priority, and alive status for scheduling and cleanup behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `kill`, `is_alive`, `get_type`, `set_type`, `get_decay_time`, and 7 more stays attached to the local data model and invariants.
//! Delivers the movable unit model consumed by demand, conversion, and transport mechanics. Runtime integration reaches sibling engine areas through crate modules `flownet`, which explains the subsystem dependencies an agent should inspect before changing behavior.

use crate::flownet::types::ItemId;

/// Current location of an item in the graph.
#[derive(Debug, Clone, PartialEq)]
pub enum ItemPosition {
    /// Item is stored on a node id.
    AtNode(u64),
    /// Item is moving on an edge with progress from 0 to 1.
    InTransit { edge_id: u64, progress: f64 },
    /// Item is not placed anywhere.
    Unplaced,
}
/// Item carried by the graph simulation.
#[derive(Debug, Clone)]
pub struct GraphItem {
    /// Stable item identifier.
    pub id: ItemId,
    /// Item type name.
    pub item_type: String,
    /// Total decay time in seconds.
    pub decay_time: f64,
    /// Remaining lifetime in seconds.
    pub remaining_life: f64,
    /// Flag that marks the item as alive.
    pub alive: bool,
    /// Priority value used by scheduling.
    pub priority: i32,
    /// Current placement state.
    pub position: ItemPosition,
}
impl GraphItem {
    /// Create an item with the supplied id, type, and decay time.
    pub fn new(id: u64, item_type: &str, decay_time: f64) -> Self {
        Self {
            id: ItemId(id),
            item_type: item_type.to_string(),
            decay_time,
            remaining_life: decay_time,
            alive: true,
            priority: 0,
            position: ItemPosition::Unplaced,
        }
    }
    /// Mark the item as dead. This function is part of the public API.
    pub fn kill(&mut self) {
        self.alive = false;
    }
    /// Return true when the item is alive.
    pub fn is_alive(&self) -> bool {
        self.alive
    }
    /// Return the item type string. This function is part of the public API.
    pub fn get_type(&self) -> &str {
        &self.item_type
    }
    /// Set the item type string. This function is part of the public API.
    pub fn set_type(&mut self, item_type: &str) {
        self.item_type = item_type.to_string();
    }
    /// Return the configured decay time.
    pub fn get_decay_time(&self) -> f64 {
        self.decay_time
    }
    /// Set decay time and reset remaining life when the new time is positive.
    pub fn set_decay_time(&mut self, t: f64) {
        self.decay_time = t;
        if t > 0.0 {
            self.remaining_life = t;
        }
    }
    /// Return the remaining lifetime.
    pub fn get_remaining_life(&self) -> f64 {
        self.remaining_life
    }
    /// Set the remaining lifetime. This function is part of the public API.
    pub fn set_remaining_life(&mut self, t: f64) {
        self.remaining_life = t;
    }
    /// Return the item priority. This function is part of the public API.
    pub fn get_priority(&self) -> i32 {
        self.priority
    }
    /// Set the item priority. This function is part of the public API.
    pub fn set_priority(&mut self, p: i32) {
        self.priority = p;
    }
    /// Return the current placement state.
    pub fn get_position(&self) -> &ItemPosition {
        &self.position
    }
    /// Set the current placement state.
    pub fn set_position(&mut self, pos: ItemPosition) {
        self.position = pos;
    }
}
