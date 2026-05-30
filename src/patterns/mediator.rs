//! Mediator registry for coordinating communication through named channels when systems should meet through a broker rather than pointing at each other directly.
//! The file assigns durable handler identities per channel so registration, removal, counting, and inspection all speak the same compact vocabulary.
//! By storing channel membership centrally it becomes easy to clear one lane of traffic or reset the whole routing surface without leaking per-subscriber bookkeeping into callers.
//! Functionally this delivers a message rendezvous layer for decoupled gameplay features, scripted services, and hub-style coordination flows.

use std::collections::HashMap;
#[derive(Debug, Default, Clone)]
/// Defines the public mediator data type used by this module.
pub struct Mediator {
    /// Per-channel handler id lists.
    channels: HashMap<String, Vec<u64>>,
    /// Next handler id to assign.
    next_id: u64,
}
/// All methods for `Mediator`.
impl Mediator {
    /// Create an empty mediator. This function is part of the public API.
    pub fn new() -> Self {
        Self::default()
    }
    /// Register a handler on `channel` and return its unique id.
    pub fn register(&mut self, channel: &str) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.channels
            .entry(channel.to_string())
            .or_default()
            .push(id);
        id
    }
    /// Remove handler `id` from `channel`; return true when it was found.
    pub fn unregister(&mut self, channel: &str, id: u64) -> bool {
        if let Some(handlers) = self.channels.get_mut(channel) {
            let before = handlers.len();
            handlers.retain(|&h| h != id);
            return handlers.len() < before;
        }
        false
    }
    /// Return all handler ids registered on `channel`.
    pub fn get_handlers(&self, channel: &str) -> Vec<u64> {
        self.channels.get(channel).cloned().unwrap_or_default()
    }
    /// Return the number of handlers on `channel`.
    pub fn handler_count(&self, channel: &str) -> usize {
        self.channels.get(channel).map(|v| v.len()).unwrap_or(0)
    }
    /// Return all known channel names.
    pub fn channel_names(&self) -> Vec<String> {
        self.channels.keys().cloned().collect()
    }
    /// Remove `channel` and all its handlers.
    pub fn remove_channel(&mut self, channel: &str) {
        self.channels.remove(channel);
    }
    /// Remove all channels and reset the id counter.
    pub fn clear(&mut self) {
        self.channels.clear();
        self.next_id = 0;
    }
}
