//! Defines synchronization groups for animation instances that must maintain shared playback phase. `animation/sync_group` delivers the sync group implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Tracks unique membership so timing alignment stays stable across coordinated animated entities. The file owns or coordinates data contracts including `AnimSyncGroup`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Serves as lightweight grouping state for systems that enforce multi-entity animation sync. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `clear`, `member_count`, `members` stays attached to the local data model and invariants.

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
