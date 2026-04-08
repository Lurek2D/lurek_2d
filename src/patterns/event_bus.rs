//! Pure-Rust event bus: subscription metadata without Lua dependencies.
//!
//! [`EventBus`] manages named-event subscriptions as integer handles. The bus
//! tracks the order and priority of listeners but stores **no callbacks** —
//! callbacks are stored in the Lua API layer, keyed by the handles this module returns.

use std::collections::HashMap;

// ── EventBus ──────────────────────────────────────────────────────────────

/// Event subscription record (metadata only).
///
/// # Fields
/// - `id` — `u64`.
/// - `event` — `String`.
/// - `priority` — `i64`.
/// - `once` — `bool`.
#[derive(Debug, Clone)]
pub struct Subscription {
    /// Unique handle.
    pub id: u64,
    /// Event name.
    pub event: String,
    /// Higher numbers run earlier.
    pub priority: i64,
    /// If `true` the subscription is removed after first dispatch.
    pub once: bool,
}

/// Ordered subscription registry for a named event bus.
///
/// # Fields
/// - `name` — `String`.
/// - `enabled` — `bool`.
#[derive(Debug)]
pub struct EventBus {
    /// Optional bus name for display / debugging.
    pub name: String,
    /// Global enable switch; when `false` dispatch produces zero listeners.
    pub enabled: bool,
    next_id: u64,
    subs: HashMap<u64, Subscription>,
}

impl EventBus {
    /// Creates a new, enabled event bus.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            enabled: true,
            next_id: 1,
            subs: HashMap::new(),
        }
    }

    /// Registers a subscription and returns its handle ID.
    ///
    /// # Parameters
    /// - `event` — `&str`.
    /// - `priority` — `i64`.
    /// - `once` — `bool`.
    ///
    /// # Returns
    /// `u64`.
    pub fn subscribe(&mut self, event: &str, priority: i64, once: bool) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.subs.insert(id, Subscription { id, event: event.to_string(), priority, once });
        id
    }

    /// Removes a subscription by its handle.
    ///
    /// # Parameters
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `bool`.
    pub fn unsubscribe(&mut self, id: u64) -> bool {
        self.subs.remove(&id).is_some()
    }

    /// Returns ordered handles for dispatching `event` (highest priority first).
    ///
    /// # Parameters
    /// - `event` — `&str`.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn get_listeners(&self, event: &str) -> Vec<u64> {
        if !self.enabled { return Vec::new(); }
        let mut listeners: Vec<&Subscription> = self.subs.values()
            .filter(|s| s.event == event || s.event == "*")
            .collect();
        listeners.sort_by(|a, b| b.priority.cmp(&a.priority));
        listeners.iter().map(|s| s.id).collect()
    }

    /// Returns handles that marked `once = true` for use-after-dispatch cleanup.
    ///
    /// # Parameters
    /// - `ids` — `&[u64]`.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn drain_once(&mut self, ids: &[u64]) -> Vec<u64> {
        let once: Vec<u64> = ids.iter().copied()
            .filter(|id| self.subs.get(id).map(|s| s.once).unwrap_or(false))
            .collect();
        for id in &once {
            self.subs.remove(id);
        }
        once
    }

    /// Removes all subscriptions for an event, returning their handle IDs.
    ///
    /// # Parameters
    /// - `event` — `&str`.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn clear_event(&mut self, event: &str) -> Vec<u64> {
        let ids: Vec<u64> = self.subs.values()
            .filter(|s| s.event == event)
            .map(|s| s.id)
            .collect();
        for id in &ids { self.subs.remove(id); }
        ids
    }

    /// Removes every subscription, returning all handle IDs.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn clear_all(&mut self) -> Vec<u64> {
        let ids: Vec<u64> = self.subs.keys().copied().collect();
        self.subs.clear();
        ids
    }

    /// Returns the subscription count for an event.
    ///
    /// # Parameters
    /// - `event` — `&str`.
    ///
    /// # Returns
    /// `usize`.
    pub fn listener_count(&self, event: &str) -> usize {
        self.subs.values().filter(|s| s.event == event).count()
    }

    /// Returns all unique event names with at least one subscription.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn event_names(&self) -> Vec<String> {
        let mut events: Vec<String> = self.subs.values()
            .map(|s| s.event.clone())
            .collect::<std::collections::HashSet<_>>()
            .into_iter()
            .collect();
        events.sort();
        events
    }

    /// Total number of active subscriptions across all events.
    ///
    /// # Returns
    /// `usize`.
    pub fn total_count(&self) -> usize {
        self.subs.len()
    }
}
