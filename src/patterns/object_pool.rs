//! Object-pool slot manager without Lua coupling.
//!
//! [`ObjectPool`] tracks which pool slots are idle or active.  The actual
//! Lua values stored in slots live in the Lua API layer.

// ── ObjectPool ────────────────────────────────────────────────────────────

/// Slot-tracking object pool (metadata only; Lua objects stored in lua_api layer).
///
/// # Fields
/// - `name` — `String`.
/// - `capacity` — `usize`.
/// - `min_idle` — `usize`.
#[derive(Debug)]
pub struct ObjectPool {
    /// Display name for debugging.
    pub name: String,
    /// Maximum total slots (0 = unlimited).
    pub capacity: usize,
    /// Number of slots to keep warmed (pre-allocated idle).
    pub min_idle: usize,
    /// Free-slot handle list.
    idle: Vec<u64>,
    /// Active-slot handle set.
    active: std::collections::HashSet<u64>,
    next_id: u64,
}

impl ObjectPool {
    /// Creates a new pool.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `capacity` — `usize`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: &str, capacity: usize) -> Self {
        Self {
            name: name.to_string(),
            capacity,
            min_idle: 0,
            idle: Vec::new(),
            active: std::collections::HashSet::new(),
            next_id: 1,
        }
    }

    /// Acquires an idle slot, returning its handle.  Returns `None` when the
    /// pool is at capacity with no idle slots.
    ///
    /// # Returns
    /// `Option<u64>`.
    pub fn acquire(&mut self) -> Option<u64> {
        if let Some(id) = self.idle.pop() {
            self.active.insert(id);
            return Some(id);
        }
        // Allocate a new slot if below capacity
        let total = self.idle.len() + self.active.len();
        if self.capacity == 0 || total < self.capacity {
            let id = self.next_id;
            self.next_id += 1;
            self.active.insert(id);
            return Some(id);
        }
        None
    }

    /// Returns a slot handle to the idle pool.
    ///
    /// # Parameters
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `bool`.
    pub fn release(&mut self, id: u64) -> bool {
        if self.active.remove(&id) {
            self.idle.push(id);
            true
        } else {
            false
        }
    }

    /// Moves all active handles back to idle, returning the released IDs.
    ///
    /// # Returns
    /// `Vec<u64>`.
    pub fn release_all(&mut self) -> Vec<u64> {
        let ids: Vec<u64> = self.active.drain().collect();
        self.idle.extend(ids.iter().copied());
        ids
    }

    /// Pre-warms the idle pool to at least `count` total slots.
    ///
    /// # Parameters
    /// - `count` — `usize`.
    ///
    /// # Returns
    /// `Vec<u64>` — newly allocated idle slot IDs.
    pub fn prewarm(&mut self, count: usize) -> Vec<u64> {
        let mut new_ids = Vec::new();
        while self.idle.len() + self.active.len() < count {
            if self.capacity > 0 && self.idle.len() + self.active.len() >= self.capacity {
                break;
            }
            let id = self.next_id;
            self.next_id += 1;
            self.idle.push(id);
            new_ids.push(id);
        }
        new_ids
    }

    /// Number of idle (available) slots.
    ///
    /// # Returns
    /// `usize`.
    pub fn idle_count(&self) -> usize { self.idle.len() }

    /// Number of active (in-use) slots.
    ///
    /// # Returns
    /// `usize`.
    pub fn active_count(&self) -> usize { self.active.len() }

    /// Total slots tracked (idle + active).
    ///
    /// # Returns
    /// `usize`.
    pub fn total_count(&self) -> usize { self.idle.len() + self.active.len() }

    /// Whether a handle is currently active.
    ///
    /// # Parameters
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_active(&self, id: u64) -> bool { self.active.contains(&id) }
}

// Tests migrated to tests/rust/unit/patterns_tests.rs
