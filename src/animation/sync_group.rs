//! This file owns `AnimSyncGroup`, the membership list used to keep multiple animation instances phase-aligned.
//! It stores unique slotmap keys and exposes small mutation helpers so synchronization systems share one contract.
//! Open it when coordination-group semantics change; actual playback state and stepping live in sibling files.

use slotmap::DefaultKey;
/// Set of animation keys that should stay in sync.
#[derive(Debug, Clone, Default)]
pub struct AnimSyncGroup {
    /// Registered members.
    members: Vec<DefaultKey>,
}
impl AnimSyncGroup {
    /// Create an empty sync group. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            members: Vec::new(),
        }
    }
    /// Add `key` when it is not already present.
    pub fn add(&mut self, key: DefaultKey) {
        if !self.members.contains(&key) {
            self.members.push(key);
        }
    }
    /// Remove `key` from the group. This function is part of the public API.
    pub fn remove(&mut self, key: DefaultKey) {
        self.members.retain(|k| *k != key);
    }
    /// Remove all members. This function is part of the public API.
    pub fn clear(&mut self) {
        self.members.clear();
    }
    /// Return the number of members.
    pub fn member_count(&self) -> usize {
        self.members.len()
    }
    /// Return the member slice. This function is part of the public API.
    pub fn members(&self) -> &[DefaultKey] {
        &self.members
    }
}
