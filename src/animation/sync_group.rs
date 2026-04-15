//! Named animation synchronisation groups.
//!
//! An [`AnimSyncGroup`] holds a collection of [`Animation`](crate::animation::Animation)
//! keys (slot-map `DefaultKey`) that should all receive the same [`tick`](no-link) call
//! together.  The group itself does **not** own the animations — it only stores the keys.
//! Ticking is performed in the Lua API layer so that it can borrow `SharedState`.

use slotmap::DefaultKey;

/// A named set of animation keys that advance in lock-step.
///
/// Create via [`AnimSyncGroup::new`], add members with [`AnimSyncGroup::add`], then call
/// `tick(dt)` on the Lua side to advance all member animations by the same delta.
#[derive(Debug, Clone, Default)]
pub struct AnimSyncGroup {
    members: Vec<DefaultKey>,
}

impl AnimSyncGroup {
    /// Creates an empty `AnimSyncGroup`.
    pub fn new() -> Self {
        Self {
            members: Vec::new(),
        }
    }

    /// Adds an animation key to the group.
    ///
    /// If the key is already a member, this is a no-op.
    ///
    /// # Parameters
    /// - `key` — [`DefaultKey`] referencing an `Animation` in the engine's resource pool.
    pub fn add(&mut self, key: DefaultKey) {
        if !self.members.contains(&key) {
            self.members.push(key);
        }
    }

    /// Removes an animation key from the group.
    ///
    /// If the key is not a member, this is a no-op.
    ///
    /// # Parameters
    /// - `key` — [`DefaultKey`] to remove.
    pub fn remove(&mut self, key: DefaultKey) {
        self.members.retain(|k| *k != key);
    }

    /// Removes all members from the group.
    pub fn clear(&mut self) {
        self.members.clear();
    }

    /// Returns the number of animation keys currently in the group.
    pub fn member_count(&self) -> usize {
        self.members.len()
    }

    /// Returns a reference to the member key slice.
    pub fn members(&self) -> &[DefaultKey] {
        &self.members
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn dummy_key() -> DefaultKey {
        use slotmap::SlotMap;
        let mut sm: SlotMap<DefaultKey, ()> = SlotMap::new();
        sm.insert(())
    }

    #[test]
    fn new_is_empty() {
        let g = AnimSyncGroup::new();
        assert_eq!(g.member_count(), 0);
    }

    #[test]
    fn add_increases_count() {
        let mut g = AnimSyncGroup::new();
        let k = dummy_key();
        g.add(k);
        assert_eq!(g.member_count(), 1);
    }

    #[test]
    fn add_duplicate_is_noop() {
        let mut g = AnimSyncGroup::new();
        let k = dummy_key();
        g.add(k);
        g.add(k);
        assert_eq!(g.member_count(), 1);
    }

    #[test]
    fn remove_decreases_count() {
        let mut g = AnimSyncGroup::new();
        let k = dummy_key();
        g.add(k);
        g.remove(k);
        assert_eq!(g.member_count(), 0);
    }

    #[test]
    fn clear_empties_group() {
        let mut g = AnimSyncGroup::new();
        let k1 = dummy_key();
        let k2 = dummy_key();
        g.add(k1);
        g.add(k2);
        g.clear();
        assert_eq!(g.member_count(), 0);
    }
}
