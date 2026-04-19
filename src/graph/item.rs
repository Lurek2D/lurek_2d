//! Graph item — a typed entity that flows through the network.
//!
//! This module is part of Lurek2D's `graph` subsystem and provides the implementation
//! details for item-related operations and data management.
//! Key types exported from this module: `ItemPosition`, `GraphItem`.
//! Primary functions: `new()`, `kill()`, `is_alive()`, `get_type()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

/// The current location of a [`GraphItem`] within the simulation graph.
///
/// # Variants
/// - `AtNode` — AtNode variant.
/// - `InTransit` — InTransit variant.
/// - `Unplaced` — Unplaced variant.
#[derive(Debug, Clone, PartialEq)]
pub enum ItemPosition {
    /// Sitting at a node.
    AtNode(u64),
    /// Travelling along an edge with a progress fraction in `[0, 1]`.
    InTransit {
        /// Edge the item is on.
        edge_id: u64,
        /// Travel progress `0.0` (just departed) to `1.0` (arrived).
        progress: f64,
    },
    /// Not placed anywhere yet.
    Unplaced,
}

/// A typed entity that flows through the graph network.
///
/// # Fields
/// - `id` — `u64`.
/// - `item_type` — `String`.
/// - `decay_time` — `f64`.
/// - `remaining_life` — `f64`.
/// - `alive` — `bool`.
/// - `priority` — `i32`.
/// - `position` — `ItemPosition`.
#[derive(Debug, Clone)]
pub struct GraphItem {
    /// Unique identifier.
    pub id: u64,
    /// Application-defined type tag (e.g. `"wood"`, `"gold"`).
    pub item_type: String,
    /// Time in seconds before the item decays. `-1.0` means no decay.
    pub decay_time: f64,
    /// Seconds of life remaining (decremented by simulation).
    pub remaining_life: f64,
    /// Whether the item is still alive.
    pub alive: bool,
    /// Priority for flow and delivery ordering.
    pub priority: i32,
    /// Current position in the graph.
    pub position: ItemPosition,
}

impl GraphItem {
    /// Create a new item with the given type and decay time.
    ///
    /// # Parameters
    /// - `id` — `u64`.
    /// - `item_type` — `&str`.
    /// - `decay_time` — `f64`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(id: u64, item_type: &str, decay_time: f64) -> Self {
        Self {
            id,
            item_type: item_type.to_string(),
            decay_time,
            remaining_life: decay_time,
            alive: true,
            priority: 0,
            position: ItemPosition::Unplaced,
        }
    }

    /// Marks this item as dead; it will be removed from the graph on the next tick.
    pub fn kill(&mut self) {
        self.alive = false;
    }

    /// Whether the item is still alive. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_alive(&self) -> bool {
        self.alive
    }

    /// Get the item type. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `&str`.
    pub fn get_type(&self) -> &str {
        &self.item_type
    }

    /// Set the item type. Replaces the current type value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `item_type` — `&str`.
    pub fn set_type(&mut self, item_type: &str) {
        self.item_type = item_type.to_string();
    }

    /// Get the decay time (`-1.0` = no decay).
    ///
    /// # Returns
    /// `f64`.
    pub fn get_decay_time(&self) -> f64 {
        self.decay_time
    }

    /// Set the decay time. Also resets remaining life if positive.
    ///
    /// # Parameters
    /// - `t` — `f64`.
    pub fn set_decay_time(&mut self, t: f64) {
        self.decay_time = t;
        if t > 0.0 {
            self.remaining_life = t;
        }
    }

    /// Get remaining life in seconds. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `f64`.
    pub fn get_remaining_life(&self) -> f64 {
        self.remaining_life
    }

    /// Set remaining life in seconds. Replaces the current remaining life value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `t` — `f64`.
    pub fn set_remaining_life(&mut self, t: f64) {
        self.remaining_life = t;
    }

    /// Get the priority value. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `i32`.
    pub fn get_priority(&self) -> i32 {
        self.priority
    }

    /// Set the priority value. Replaces the current priority value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `p` — `i32`.
    pub fn set_priority(&mut self, p: i32) {
        self.priority = p;
    }

    /// Get the current position. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `&ItemPosition`.
    pub fn get_position(&self) -> &ItemPosition {
        &self.position
    }

    /// Set the current position. Replaces the current position value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `pos` — `ItemPosition`.
    pub fn set_position(&mut self, pos: ItemPosition) {
        self.position = pos;
    }
}
