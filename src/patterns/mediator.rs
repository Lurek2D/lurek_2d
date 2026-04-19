//! Mediator pattern — pub/sub message channels.
//!
//! The [`Mediator`] struct manages named channels and assigns numeric handler IDs to
//! subscribers.  Actual callbacks (Lua functions) are stored in the Lua API layer; this
//! module tracks only the channel-to-handler mapping and ID allocation.

use std::collections::HashMap;

// ── Mediator ─────────────────────────────────────────────────────────────────

/// Named-channel message broker.
///
/// Channels are created implicitly on first registration.  Handler IDs are
/// monotonically increasing u64 values — they serve as keys in the Lua API's
/// registry-key map.
#[derive(Debug, Default, Clone)]
pub struct Mediator {
    /// Channel name → ordered list of handler IDs.
    channels: HashMap<String, Vec<u64>>,
    next_id: u64,
}

impl Mediator {
    /// Creates a new, empty [`Mediator`].
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Registers a new handler on `channel` and returns its unique ID.
    ///
    /// # Parameters
    /// - `channel` — `&str`.
    ///
    /// # Returns
    /// `u64` — handler ID.
    pub fn register(&mut self, channel: &str) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.channels
            .entry(channel.to_string())
            .or_default()
            .push(id);
        id
    }

    /// Unregisters a handler by ID from `channel`.
    ///
    /// # Parameters
    /// - `channel` — `&str`.
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `bool` — `true` if the handler was found and removed.
    pub fn unregister(&mut self, channel: &str, id: u64) -> bool {
        if let Some(handlers) = self.channels.get_mut(channel) {
            let before = handlers.len();
            handlers.retain(|&h| h != id);
            return handlers.len() < before;
        }
        false
    }

    /// Returns all handler IDs registered on `channel`.
    ///
    /// # Parameters
    /// - `channel` — `&str`.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn get_handlers(&self, channel: &str) -> Vec<u64> {
        self.channels.get(channel).cloned().unwrap_or_default()
    }

    /// Returns the number of handlers on `channel`.
    ///
    /// # Parameters
    /// - `channel` — `&str`.
    ///
    /// # Returns
    /// `usize`.
    pub fn handler_count(&self, channel: &str) -> usize {
        self.channels.get(channel).map(|v| v.len()).unwrap_or(0)
    }

    /// Returns all registered channel names.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn channel_names(&self) -> Vec<String> {
        self.channels.keys().cloned().collect()
    }

    /// Removes an entire channel and all its handlers.
    ///
    /// # Parameters
    /// - `channel` — `&str`.
    pub fn remove_channel(&mut self, channel: &str) {
        self.channels.remove(channel);
    }

    /// Clears all channels and resets handler ID allocation to zero.
    pub fn clear(&mut self) {
        self.channels.clear();
        self.next_id = 0;
    }
}

// Tests migrated to tests/rust/unit/patterns_tests.rs
